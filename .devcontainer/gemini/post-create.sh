#!/bin/bash
set -e

echo "🚀 Setting up Gemini CLI Development Environment..."

# Ensure correct permissions
sudo chown -R node:node /home/node/.config || true
sudo chown -R node:node /commandhistory || true

# Create Gemini config directory
mkdir -p /home/node/.config/gemini

# Install workspace dependencies if package.json exists
if [ -f "/workspace/package.json" ]; then
    echo "📦 Installing workspace dependencies..."
    cd /workspace && npm install
fi

# Set up git config if not already set
if [ -z "$(git config --global user.email)" ]; then
    echo "📧 Setting up git config..."
    git config --global user.email "developer@gemini-devcontainer.local"
    git config --global user.name "Gemini Developer"
fi

# Install Powerline fonts for better terminal experience
echo "🎨 Configuring terminal..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
if [ ! -f "MesloLGS NF Regular.ttf" ]; then
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fi

# Configure Powerlevel10k
if [ ! -f ~/.p10k.zsh ]; then
    echo "⚡ Configuring Powerlevel10k..."
    # Create a basic p10k configuration
    cat > ~/.p10k.zsh << 'EOF'
# Basic Powerlevel10k configuration
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_INSTANT_PROMPT=quiet
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status node_version)
POWERLEVEL9K_DISABLE_GITSTATUS=false
EOF
    echo "source ~/.p10k.zsh" >> ~/.zshrc
fi

echo "✅ Gemini CLI Development Environment setup complete!"
echo ""
echo "🔧 Quick Start:"
echo "  - Run 'gemini' to start the Gemini CLI"
echo "  - Your workspace is mounted at /workspace"
echo "  - Gemini config is persisted in ~/.config/gemini"
echo ""
echo "🔐 Security:"
echo "  - Firewall is ${ENABLE_FIREWALL:-disabled} (set ENABLE_FIREWALL=true to enable)"
echo "  - Only approved domains are accessible when firewall is enabled"
echo ""
echo "Happy coding! 🎉"
