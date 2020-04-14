####
#### Copied directly from https://gist.github.com/pahud/4bdc6cde7b55c4fb8bd8c886dd57787e
####
name: "Demo workflow" {
  on = "push"
  resolves = ["SNS Notification"]
}

action "Build Image" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  runs = ["/bin/sh", "-c", "docker build -t $IMAGE_URI ."]
  env = {
    IMAGE_URI = "041906867979.dkr.ecr.us-east-2.amazonaws.com/ci-cd-demo:latest"
  }
}

action "ECR Login" {
  uses = "actions/aws/cli@51b5c9b60da75d1d3f97ff91ed2e4efc19dd5474"
  needs = ["Build Image"]
  env = {
    AWS_DEFAULT_REGION = "us-east-2"
    AWS_REGION = "$AWS_DEFAULT_REGION"
  }
  runs = ["/bin/sh", "-c", "aws ecr get-login --no-include-email | sh"]
  secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
}


action "Push ECR" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["ECR Login"]
  runs = ["/bin/sh", "-c",  "docker push $IMAGE_URI"]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    IMAGE_URI = "041906867979.dkr.ecr.us-east-2.amazonaws.com/ci-cd-demo:latest"
  }

}

action "Deploy to EKS" {
  uses = "actions/aws/kubectl@master"
  #   args = ["get all"]
  args = ["apply -f app.yaml"]
  needs = ["Push ECR"]
  secrets = [
    "KUBE_CONFIG_DATA",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
  env = {
    AWS_DEFAULT_REGION = "us-east-2"
  }
}

action "Verify EKS Deployment" {
  uses = "actions/aws/kubectl@master"
  needs = ["Deploy to EKS"]
  args = ["get all"]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "KUBE_CONFIG_DATA"]
  env = {
    AWS_DEFAULT_REGION = "us-east-2"
  }
}

action "SNS Notification" {
  uses = "actions/aws/cli@51b5c9b60da75d1d3f97ff91ed2e4efc19dd5474"
  needs = ["Verify EKS Deployment"]
  runs = ["/bin/sh", "-c", "aws --region us-east-2 sns publish --topic-arn $SNS_TOPIC_ARN --message '[OK] Deploy completed'"]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    AWS_DEFAULT_REGION = "us-east-2",
    SNS_TOPIC_ARN = "arn:aws:sns:us-east-2:041906867979:ci-cd-sns",
  }
}
