# Use Node 18 Alpine for a small footprint
FROM node:18-alpine

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install all dependencies (including typescript and ts-node)
RUN npm install
RUN npm install -g ts-node typescript

# Copy the entire project
COPY . .

# Ensure the start script is executable
RUN chmod +x start.sh

# Create folder for file uploads
RUN mkdir -p /app/files

# Configure Nginx
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    \
    # Frontend / Dashboard \
    location / { \
        proxy_pass http://localhost:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
    \
    # API Backend \
    location /api/ { \
        proxy_pass http://localhost:3000/api/; \
        proxy_set_header Host $host; \
    } \
    \
    # ZIP/File downloads \
    location /files/ { \
        root /app; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment"; \
    } \
}' > /etc/nginx/http.d/default.conf

# Expose the external port
EXPOSE 30469

# Run the startup script
CMD ["./start.sh"]
