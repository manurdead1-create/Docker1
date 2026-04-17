FROM node:18-alpine

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# 1. Copy everything from the root
# This ensures /app/lib and /app/services/api both exist
COPY . .

# 2. Install dependencies (Clean install)
RUN npm install && npm install -g tsx typescript

# 3. Configure Nginx to talk to the local API
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    server_name wardenx.dpdns.org; \
    \
    location / { \
        proxy_pass http://127.0.0.1:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
    \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/http.d/default.conf

# 4. Make sure start.sh is executable (searching the whole /app folder)
RUN find . -name "start.sh" -exec chmod +x {} +

# 5. Move to your API service folder
WORKDIR /app/services/api

EXPOSE 30469

# Run the startup script
CMD ["/bin/sh", "./start.sh"]
