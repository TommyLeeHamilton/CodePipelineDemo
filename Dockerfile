FROM nginx:1.17.2
COPY CustomNginx/indexv2.html /usr/share/nginx/html/index.html
CMD ["nginx", "-g", "daemon off;"]