#!/bin/sh

# Start the API using tsx
# tsx automatically reads the 'paths' in your tsconfig.json
tsx src/index.ts &

# Start Nginx
nginx -g "daemon off;"
