# Use Node (needed for upload server)
FROM node:18-alpine

# Install nginx + curl
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# Copy package.json
COPY package.json .

# Install dependencies
RUN npm install

# Copy all project files
COPY . .

# Create uploads folder
RUN mkdir -p /app/files

# Remove default nginx config
RUN rm -f /etc/nginx/http.d/default.conf

# Create custom nginx config
RUN echo 'server { \
    listen 30469; \
    \
    location / { \
        proxy_pass http://localhost:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
    \
    # ZIP downloads \
    location /files/ { \
        proxy_pass http://localhost:3000/files/; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment"; \
    } \
    \
    # Your External API Server \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/http.d/default.conf

# Expose port
EXPOSE 30469

# Start Node + Nginx
CMD node server.js & nginx -g "daemon off;"
