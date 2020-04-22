FROM nginx:1.17.2
COPY CustomNginx/index2.html /usr/share/nginx/html/index.html
RUN echo y | apt-get update
RUN echo y | apt-get upgrade
CMD ["nginx", "-g", "daemon off;"]