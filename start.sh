#!/bin/sh

# Start the TypeScript API using tsx (it replaces ts-node/esm)
# No loaders or complex flags needed
tsx src/index.ts &

# Start Nginx
nginx -g "daemon off;"
