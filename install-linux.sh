#!/bin/bash
# Hermes Agent Quick Install Script for Linux
# Run: ./install-linux.sh

echo "============================================"
echo "Hermes Agent Quick Install (Linux)"
echo "============================================"
echo ""

echo "This script will:"
echo "1. Install Node.js v22 via nvm (if not installed)"
echo "2. Install Python 3.11 via pyenv (if not installed)"
echo "3. Install Hermes Agent"
echo "4. Ask for your OpenRouter API key"
echo ""
echo "All installations will be in your user folder (no sudo required)"
echo ""
read -p "Press Enter to continue..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the PowerShell-style script adapted for bash
bash "$SCRIPT_DIR/quick-install.sh"

echo ""
echo "Installation complete!"
echo ""
echo "To start Hermes, run: hermes"
echo ""
