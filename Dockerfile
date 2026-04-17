# 1. Use a tiny Nginx image
FROM nginx:alpine

# 2. Install curl for health checks
RUN apk add --no-cache curl

# 3. Configure Nginx (Explicitly using your IP: 176.100.37.91)
# This routes domain traffic (Port 80) to your Python API (Port 30469)
RUN rm -f /etc/nginx/conf.d/default.conf
RUN echo 'server { \
    listen 80; \
    server_name wardenx.dpdns.org; \
\
    # Forward domain API calls to your Python Server running at the IP \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
\
    # Serve static files if you have them, or just a basic response \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
    } \
}' > /etc/nginx/conf.d/wardenx.conf

# 4. Expose Port 80 for the Domain
EXPOSE 80

# 5. Run Nginx
CMD ["nginx", "-g", "daemon off;"]
