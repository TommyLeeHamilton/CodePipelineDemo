FROM nginx:1.11.0
COPY CustomNginx/index.html /usr/share/nginx/html/index.html
#RUN echo y | apt-get update
#RUN echo y | apt-get upgrade
CMD ["nginx", "-g", "daemon off;"]