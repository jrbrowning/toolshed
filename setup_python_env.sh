#!/bin/bash
# Ensure pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "❌ pyenv is not installed. Install it first: https://github.com/pyenv/pyenv"
    exit 1
fi

# Define the Python version
PYTHON_VERSION="3.12.2"

# Install the specified Python version using pyenv
echo "🔄 Installing Python $PYTHON_VERSION with pyenv..."
pyenv install -s "$PYTHON_VERSION"
pyenv global "$PYTHON_VERSION"
pyenv rehash

# Verify the Python version
echo "✅ Using Python version:"
python3 --version

# Set up virtual environment
echo "🔄 Creating virtual environment..."
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Confirm the active Python version inside the virtual environment
echo "🐍 Python version inside venv:"
python --version

# Install required libraries from requirements file
echo "📦 Installing dependencies from global-tools/requirements.txt..."
pip install --upgrade pip
pip install -r global-tools/requirements.txt

echo "✅ Python3 environment setup complete!"