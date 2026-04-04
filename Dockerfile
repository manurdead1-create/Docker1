FROM nginx:alpine

# Copy your index.html to the default nginx location
COPY index.html /usr/share/nginx/html/index.html

# Overwrite the default Nginx config to support proxying
RUN echo 'server { \
    listen 30469; \
    server_name localhost; \
    \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Proxy requests to your Orihost Backend \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Important: Railway needs to know you are using 30469
EXPOSE 30469
