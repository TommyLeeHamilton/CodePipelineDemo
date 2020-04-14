FROM nginx:1.17.2
#Image from 23 Jul 2019
#COPY CustomNginx/index.html /usr/share/nginx/html/index.html
#RUN echo y | apt-get update
#RUN echo y | apt-get upgrade
CMD ["nginx", "-g", "daemon off;"]