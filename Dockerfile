FROM nginx:alpine

# 1. Install curl to fetch the file from Discord
RUN apk add --no-cache curl

# 2. Download WardenX_v1.0.0.zip directly into the web root
RUN curl -A "Mozilla/5.0" -L -o /usr/share/nginx/html/WardenX_v1.0.0.zip "https://cdn.discordapp.com/attachments/1483356944633692252/1490318762736353570/WardenX_v1.0.0.zip?ex=69d39f01&is=69d24d81&hm=ffd4f76c79be18029ccaeb6efc19adbcf1409734df0d3dcb4b57a817731edb01&"

# 3. CRITICAL: Remove the default Nginx index and config 
# This stops the "Welcome to nginx" page from appearing
RUN rm /usr/share/nginx/html/index.html && rm /etc/nginx/conf.d/default.conf

# 4. Create your custom Nginx configuration
# This version assumes you have an index.html in your build folder
RUN echo 'server { \
    listen 30469; \
    \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location = /WardenX_v1.0.0.zip { \
        root /usr/share/nginx/html; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment; filename=WardenX_v1.0.0.zip"; \
    } \
    \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 5. Copy YOUR index.html from your computer to the container
# This is what will show instead of the "Welcome to nginx" page
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 30469

CMD ["nginx", "-g", "daemon off;"]
