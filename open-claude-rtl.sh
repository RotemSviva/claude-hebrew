#!/bin/bash
cd "$(dirname "$0")"

echo "Closing existing Claude Desktop..."
pkill -x "Claude" 2>/dev/null
sleep 1

echo "Opening Claude Desktop with debug port..."
"/Applications/Claude.app/Contents/MacOS/Claude" --remote-debugging-port=9222 &

echo "Starting RTL injector..."
node inject-rtl.js
