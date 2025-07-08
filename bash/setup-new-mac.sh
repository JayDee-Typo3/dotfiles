#!/bin/bash

# Exit immediately on error
set -e

echo "🔧 Starting macOS setup..."

###############################################################################
# Install Oh My Zsh
###############################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

###############################################################################
# Install Homebrew
###############################################################################
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to path (for Apple Silicon)
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed."
fi

###############################################################################
# Update Homebrew and Repositories
###############################################################################
echo "🔄 Updating Homebrew..."
brew update
brew upgrade
brew doctor

###############################################################################
# Install DDEV
###############################################################################
echo "🧱 Installing DDEV..."
brew install drud/ddev/ddev

###############################################################################
# Install mkcert and set up local CA
###############################################################################
echo "🔐 Installing mkcert..."
brew install mkcert
brew install nss # required for Firefox trust (optional but recommended)

echo "📜 Setting up local CA with mkcert..."
mkcert -install

###############################################################################
# Install CLI Tools
###############################################################################
echo "📦 Installing CLI tools..."
brew install git
brew install composer
brew install cmake
brew install ffind
brew install fzf
brew install gd
brew install neovim

###############################################################################
# Install LazyVim
###############################################################################
echo "🎨 Installing LazyVim config..."

# Backup existing config if any
if [ -d "$HOME/.config/nvim" ] || [ -d "$HOME/.local/share/nvim" ]; then
    echo "📦 Backing up existing Neovim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)" 2>/dev/null || true
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup.$(date +%s)" 2>/dev/null || true
fi

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
cd ~/.config/nvim
rm -rf .git

# Trigger plugin installation
echo "🚀 Launching Neovim to install plugins (this may take a while)..."
nvim --headless "+Lazy! sync" +qa

###############################################################################
# Install GUI Apps (via Homebrew Cask)
###############################################################################
echo "🖥️ Installing GUI apps..."

brew install --cask wezterm
brew install --cask arc
brew install --cask google-chrome
brew install --cask firefox
brew install --cask brave-browser
brew install --cask postman
brew install --cask visual-studio-code
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask docker
brew install --cask jordanbaird-ice
brew install --cask raycast
brew install --cask 1password
brew install --cask chatgpt
brew install --cask telegram
brew install --cask whatsapp

###############################################################################
# SSH Key (RSA, no passphrase)
###############################################################################
echo "🔐 Generating SSH key (RSA, no passphrase)..."

SSH_KEY_PATH="$HOME/.ssh/id_rsa"

if [ -f "$SSH_KEY_PATH" ]; then
    echo "⚠️ SSH key already exists at $SSH_KEY_PATH – skipping."
else
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""
    echo "✅ SSH key created at: $SSH_KEY_PATH"
    echo "📋 Public key:"
    cat "${SSH_KEY_PATH}.pub"
fi

###############################################################################
# Create Development folder and change into it
###############################################################################
echo "📁 Creating ~/Development folder..."
mkdir -p "$HOME/Development"
cd "$HOME/Development"
echo "📍 Changed into ~/Development"

###############################################################################
# Done – ready for your custom steps
###############################################################################
echo "✅ Base setup complete. You can now add your custom steps here."
