FROM nginx:alpine

# 1. Copy your website files
COPY . /usr/share/nginx/html

# 2. Create the Proxy configuration
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ =404; \
    } \
    # THIS IS THE MISSING LINK: \
    location /api/ { \
        proxy_pass http://YOUR_ORIHOST_IP:5000/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
