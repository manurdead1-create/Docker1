# Use Node (needed for upload server)
FROM node:18-alpine

# Install nginx + curl + build tools (needed for some npm packages)
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# Copy package.json and package-lock.json if available
COPY package*.json ./

# Install dependencies (including typescript and ts-node)
RUN npm install

# Install ts-node globally to execute the .ts file directly
RUN npm install -g ts-node typescript

# Copy all project files
COPY . .

# Create uploads folder
RUN mkdir -p /app/files

# Remove default nginx config
RUN rm -f /etc/nginx/http.d/default.conf

# Create custom nginx config (keeping your existing proxy logic)
RUN echo 'server { \
    listen 30469; \
    location / { \
        proxy_pass http://localhost:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
    location /files/ { \
        proxy_pass http://localhost:3000/files/; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment"; \
    } \
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

# Start Node (running index.ts via ts-node) + Nginx
# Using "ts-node index.ts" instead of "node server.js"
CMD ts-node index.ts & nginx -g "daemon off;"
