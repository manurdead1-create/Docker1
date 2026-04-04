FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y nginx

COPY index.html /var/www/html/index.html

RUN echo 'server { \n\
    listen 30469 default_server; \n\
    root /var/www/html; \n\
    index index.html; \n\
    \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    \n\
    # Routes License Validation to Orihost \n\
    location /api/ { \n\
        proxy_pass http://176.100.37.91:30469; \n\
        proxy_set_header Host $host; \n\
    } \n\
    \n\
    # Routes Live Stats from your .exe to Orihost \n\
    location /stats { \n\
        proxy_pass http://176.100.37.91:30469; \n\
        proxy_set_header Host $host; \n\
    } \n\
}' > /etc/nginx/sites-available/default

EXPOSE 30469
CMD ["nginx", "-g", "daemon off;"]
