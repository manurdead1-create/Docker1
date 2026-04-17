#!/bin/sh

# Start the TypeScript API using the ESM loader
# This tells Node.js how to handle the .ts extension
node --loader ts-node/esm src/index.ts &

# Start Nginx
nginx -g "daemon off;"
