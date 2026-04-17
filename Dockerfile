FROM node:18-alpine
RUN apk add --no-cache nginx curl
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies and the missing Node types
RUN npm install && \
    npm install --save-dev @types/node && \
    npm install -g ts-node typescript

# COPY EVERYTHING (including tsconfig.json and src folder)
COPY . . 

RUN chmod +x start.sh

# Create folder for file uploads
RUN mkdir -p /app/files

# Configure Nginx
# Configure Nginx with your specific External API IP
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    \
    # Frontend / Dashboard \
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
    # Your External API Server (Restored IP) \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/http.d/default.conf

# Expose the external port
EXPOSE 30469

# Run the startup script
CMD ["./start.sh"]
