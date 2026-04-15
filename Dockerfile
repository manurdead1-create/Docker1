FROM nginx:alpine

# Install curl (optional, keeping for future use)
RUN apk add --no-cache curl

# Remove default nginx files
RUN rm /usr/share/nginx/html/index.html && rm /etc/nginx/conf.d/default.conf

# Create custom nginx config
RUN echo 'server { \
    listen 30469; \
    \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Allow download of ANY zip dynamically \
    location ~* \.zip$ { \
        root /usr/share/nginx/html; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment"; \
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

# Copy index.html
COPY index.html /usr/share/nginx/html/index.html

# Create downloads folder
RUN mkdir -p /usr/share/nginx/html

EXPOSE 30469

CMD ["nginx", "-g", "daemon off;"]
