FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy your landing page
COPY index.html /var/www/html/index.html

# Configure Nginx to proxy /api/ requests to Orihost
RUN echo 'server { \n\
    listen 30469 default_server; \n\
    root /var/www/html; \n\
    index index.html; \n\
    \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    \n\
    # This block redirects API calls from Railway to Orihost \n\
    location /api/ { \n\
        proxy_pass http://176.100.37.91:30469; \n\
        proxy_set_header Host $host; \n\
        proxy_set_header X-Real-IP $remote_addr; \n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \n\
        proxy_set_header X-Forwarded-Proto $scheme; \n\
    } \n\
}' > /etc/nginx/sites-available/default

EXPOSE 30469

CMD ["nginx", "-g", "daemon off;"]
