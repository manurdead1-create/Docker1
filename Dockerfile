FROM nginx:alpine

# 1. Set working directory
WORKDIR /usr/share/nginx/html

# 2. Copy your index.html (Make sure it is in the same folder as this Dockerfile)
COPY index.html .

# 3. Configure Nginx to bridge the gap
RUN rm -f /etc/nginx/conf.d/default.conf
RUN echo 'server { \
    listen 30469; \
    server_name wardenx.dpdns.org; \
\
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
\
    # This sends any call to /api/... to your Python server \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
    } \
}' > /etc/nginx/conf.d/wardenx.conf

EXPOSE 30469

CMD ["nginx", "-g", "daemon off;"]
