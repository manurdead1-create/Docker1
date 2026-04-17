# 1. Start with Python base
FROM python:3.11-slim

# 2. Install Nginx and system tools
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Setup workspace
WORKDIR /app
RUN pip install --no-cache-dir flask flask-cors werkzeug
COPY app.py .
RUN mkdir -p uploads

# 4. CONFIGURE NGINX (Explicitly using your IP)
# This ensures traffic to wardenx.dpdns.org/api/ hits your IP server logic
RUN rm -f /etc/nginx/sites-enabled/default
RUN echo 'server { \
    listen 80; \
    server_name wardenx.dpdns.org; \
\
    # Forward domain API calls to the local IP process \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
\
    # Serve your main dashboard / static files \
    location / { \
        root /var/www/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/wardenx.conf

# 5. Startup script to run both services
RUN echo '#!/bin/sh\n\
nginx\n\
python app.py' > /app/start.sh
RUN chmod +x /app/start.sh

# 6. Open the doors
EXPOSE 80
EXPOSE 30469

CMD ["/app/start.sh"]
