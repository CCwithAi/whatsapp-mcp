#!/usr/bin/env bash
# WhatsApp MCP - Start Script
# Starts the Go bridge (background) and the Python MCP server
#
# Usage:
#   ./start.sh          - Start everything
#   ./start.sh bridge   - Start only the Go bridge
#   ./start.sh server   - Start only the MCP server (assumes bridge is already running)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE_DIR="$SCRIPT_DIR/whatsapp-bridge"
SERVER_DIR="$SCRIPT_DIR/whatsapp-mcp-server"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cleanup() {
    echo -e "\n${YELLOW}Shutting down...${NC}"
    if [ -n "$BRIDGE_PID" ]; then
        kill "$BRIDGE_PID" 2>/dev/null && echo -e "${GREEN}Bridge stopped.${NC}"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

start_bridge() {
    echo -e "${GREEN}Starting WhatsApp bridge...${NC}"
    echo -e "${YELLOW}If this is your first run, scan the QR code with WhatsApp on your phone.${NC}"
    echo -e "${YELLOW}Go to WhatsApp > Settings > Linked Devices > Link a Device${NC}"
    echo ""
    cd "$BRIDGE_DIR"
    ./whatsapp-bridge &
    BRIDGE_PID=$!
    echo -e "${GREEN}Bridge started (PID: $BRIDGE_PID) on http://localhost:8080${NC}"
    # Give bridge time to initialize and show QR code
    sleep 3
}

start_server() {
    echo -e "${GREEN}Starting MCP server...${NC}"
    cd "$SERVER_DIR"
    uv run main.py
}

case "${1:-all}" in
    bridge)
        start_bridge
        echo -e "${GREEN}Bridge is running. Press Ctrl+C to stop.${NC}"
        wait "$BRIDGE_PID"
        ;;
    server)
        start_server
        ;;
    all|*)
        start_bridge
        start_server
        ;;
esac
