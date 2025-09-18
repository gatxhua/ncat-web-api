#!/bin/sh
PORT=3000

echo "Starting ncat API server on port $PORT..."
ncat -l -p "$PORT" -k -C -c "$(dirname $0)/handler.sh"


