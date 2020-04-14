FROM nginx
#COPY CustomNginx/index.html /usr/share/nginx/html/index.html
CMD ["nginx", "-g", "daemon off;"]