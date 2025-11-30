#!/bin/bash

# Git Hooks Setup Script
# This script installs and configures Git hooks for the repository

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Git Hooks Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}✗ Error: Not a git repository${NC}"
    echo "Please run this script from the root of your git repository"
    exit 1
fi

HOOKS_DIR=".git/hooks"
TEMPLATE_DIR="hooks-templates"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Function to install a hook
install_hook() {
    local hook_name=$1
    local source_file=$2
    local dest_file="$HOOKS_DIR/$hook_name"
    
    if [ -f "$source_file" ]; then
        echo -e "${YELLOW}Installing $hook_name hook...${NC}"
        cp "$source_file" "$dest_file"
        chmod +x "$dest_file"
        echo -e "${GREEN}✓ $hook_name hook installed${NC}"
    else
        echo -e "${YELLOW}⚠ $source_file not found, skipping${NC}"
    fi
}

# Check if hooks already exist
if [ -f "$HOOKS_DIR/commit-msg" ] || [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo -e "${YELLOW}⚠ Existing hooks detected${NC}"
    read -p "Do you want to overwrite existing hooks? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
    echo ""
fi

# Install hooks from .git/hooks if they exist (for this repo)
if [ -f "$HOOKS_DIR/commit-msg" ]; then
    chmod +x "$HOOKS_DIR/commit-msg"
    echo -e "${GREEN}✓ commit-msg hook is ready${NC}"
fi

if [ -f "$HOOKS_DIR/pre-commit" ]; then
    chmod +x "$HOOKS_DIR/pre-commit"
    echo -e "${GREEN}✓ pre-commit hook is ready${NC}"
fi

# If template directory exists, install from there
if [ -d "$TEMPLATE_DIR" ]; then
    install_hook "commit-msg" "$TEMPLATE_DIR/commit-msg"
    install_hook "pre-commit" "$TEMPLATE_DIR/pre-commit"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Git hooks setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Installed hooks:"
echo "  • commit-msg: Validates commit message format (CDE-XXXXX: message)"
echo "  • pre-commit: Runs code quality checks"
echo ""
echo "Configuration file: .githooks-config.json"
echo ""
echo "To test the hooks:"
echo "  1. Stage some changes: git add ."
echo "  2. Try to commit: git commit -m 'CDE-123: Add new feature'"
echo ""
echo "To bypass hooks (not recommended):"
echo "  git commit --no-verify"
echo ""
echo -e "${YELLOW}Note: Hooks are local to your repository and not tracked by git${NC}"
echo -e "${YELLOW}Each team member needs to run this setup script${NC}"
echo ""
