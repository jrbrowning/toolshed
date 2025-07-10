#!/bin/bash

NVM_VERSION="0.39.7"
NODE_VERSION="20.19.2"

echo "📦 Bootstrapping Node environment (Node v$NODE_VERSION, NVM v$NVM_VERSION)..."

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "🔧 'jq' not found. Installing..."
    if [ "$(uname)" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew not found. Please install jq manually."
            exit 1
        fi
        brew install jq
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y epel-release && sudo yum install -y jq
    else
        echo "❌ Unsupported OS. Please install jq manually."
        exit 1
    fi
fi

# Ensure NVM is installed or install it
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "⬇️ Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
else
    . "$NVM_DIR/nvm.sh"
fi

# Install and use specified Node version
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

# Parse node-tools.json and install global packages
echo "📦 Installing global npm packages from node-tools.json..."
TOOLS_JSON="global-tools/node-tools.json"
if [ ! -f "$TOOLS_JSON" ]; then
    echo "❌ node-tools.json not found at $TOOLS_JSON"
    exit 1
fi

# Read each package and strip version prefix like ^
for tool in $(jq -r '.dependencies | to_entries[] | "\(.key)@\(.value | sub("^"; ""))"' "$TOOLS_JSON"); do
    echo "📥 Installing $tool..."
    npm install -g "$tool"
done

# List globally installed packages (shallow view)
echo "📄 Globally installed npm packages:"
npm ls -g --depth=0

echo "✅ Bootstrapping complete!"