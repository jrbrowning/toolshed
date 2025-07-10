#!/bin/bash

NVM_VERSION="0.39.7"
NODE_VERSION="20.19.2"

echo "📦 Bootstrapping Node environment (Node v$NODE_VERSION, NVM v$NVM_VERSION)..."

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

# Ensure jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ 'jq' is required but not installed. Add it to your node-tools.json and re-run this script."
    exit 1
fi

# Install packages one at a time in JSON order
for tool in $(jq -r '.dependencies | to_entries[] | "\(.key)@\(.value | sub("^"; ""))"' "$TOOLS_JSON"); do
    echo "📥 Installing $tool..."
    npm install -g "$tool"
done

# Show final list
echo "📄 Final list of globally installed npm packages:"
npm ls -g --depth=0

# Write local .czrc to current directory
echo "🛠 Writing global .czrc pointing to global adapter in $HOME/.czrc..."
echo '{ "path": "cz-conventional-changelog" }' > "$HOME/.czrc"

echo "✅ Bootstrapping complete! Run \`npx cz\` here to use the standard commit wizard."
