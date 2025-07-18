#!/bin/bash

# Python + Poetry Environment Setup Script
# Usage: source setup_python_poetry.sh

# Define the Python version
PYTHON_VERSION="3.12.2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Python + Poetry Environment Setup${NC}"
echo "Target Python version: ${PYTHON_VERSION}"
echo "Current directory: $(pwd)"

# Check if pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo -e "${RED}❌ pyenv is not installed. Install it first: https://github.com/pyenv/pyenv${NC}"
    return 1 2>/dev/null || exit 1
fi

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}❌ Poetry is not installed. Install it first: https://python-poetry.org/docs/#installation${NC}"
    return 1 2>/dev/null || exit 1
fi

# Install and set Python version with pyenv
echo -e "${YELLOW}🔄 Setting up Python ${PYTHON_VERSION} with pyenv...${NC}"
pyenv install -s "$PYTHON_VERSION"

# Check if we're in a directory with pyproject.toml
if [ -f "pyproject.toml" ]; then
    echo -e "${GREEN}✅ Found pyproject.toml in current directory${NC}"
    
    # Set local Python version for this directory
    pyenv local "$PYTHON_VERSION"
    echo -e "${GREEN}📌 Set Python ${PYTHON_VERSION} as local version for this directory${NC}"
    
    # Verify Python version
    echo -e "${BLUE}🐍 Python version:${NC}"
    python --version
    
    # Configure Poetry to use the pyenv Python
    poetry env use python
    
    # Install dependencies with Poetry
    echo -e "${YELLOW}📦 Installing dependencies with Poetry...${NC}"
    poetry install
    
    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Poetry dependencies installed successfully!${NC}"
        
        # Activate Poetry shell
        echo -e "${YELLOW}🔄 Activating Poetry virtual environment...${NC}"
        
        # Note: We can't directly activate poetry shell in a sourced script
        # Instead, we'll show the user how to activate it
        echo -e "${BLUE}📋 To activate the Poetry environment, run:${NC}"
        echo -e "${GREEN}   poetry shell${NC}"
        echo ""
        echo -e "${BLUE}💡 Or run commands with Poetry:${NC}"
        echo -e "${GREEN}   poetry run python your_script.py${NC}"
        echo ""
        echo -e "${BLUE}📍 Virtual environment location:${NC}"
        poetry env info --path
        
    else
        echo -e "${RED}❌ Poetry installation failed!${NC}"
        return 1 2>/dev/null || exit 1
    fi
    
else
    echo -e "${YELLOW}⚠️  No pyproject.toml found in current directory${NC}"
    echo -e "${BLUE}Available options:${NC}"
    echo "1. Set global Python version only"
    echo "2. Look for pyproject.toml in subdirectories"
    
    read -p "Enter choice (1 or 2): " choice
    
    case $choice in
        1)
            pyenv global "$PYTHON_VERSION"
            echo -e "${GREEN}✅ Set Python ${PYTHON_VERSION} as global version${NC}"
            python --version
            ;;
        2)
            echo -e "${BLUE}🔍 Searching for pyproject.toml files...${NC}"
            find . -name "pyproject.toml" -type f | head -5
            echo -e "${YELLOW}💡 Navigate to one of these directories and run this script again${NC}"
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            return 1 2>/dev/null || exit 1
            ;;
    esac
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"