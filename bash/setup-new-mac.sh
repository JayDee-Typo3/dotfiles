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
# Install Powerlevel10k theme
###############################################################################
echo "🎨 Installing Powerlevel10k ZSH theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

# Set theme in .zshrc (only if not already set)
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
    echo "🛠️  Setting ZSH_THEME to powerlevel10k..."
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
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
brew install fd
brew install ffind
brew install fzf
brew install gd
brew install neovim
brew install awk
brew install tmux
brew install ddev
brew install lazygit

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
brew install --cask docker-desktop
brew install --cask jordanbaird-ice
brew install --cask raycast
brew install --cask 1password
brew install --cask chatgpt
brew install --cask telegram
brew install --cask whatsapp
brew install --cask spotify

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
# Create /Development/Repositories folder and change into it
###############################################################################
if [ -d "$HOME/Development/Repositories" ]; then
    echo "✅ ~/Development/Repositories already exists"
else
    echo "📁 Creating ~/Development/Repositories"
    mkdir -p "$HOME/Development/Repositories"
fi
cd "$HOME/Development/Repositories"
echo "📍 Now in $(pwd)"

###############################################################################
# Clone repository if git is available
###############################################################################
if command -v git &>/dev/null; then
    DOT_FILE_REPO="https://github.com/JayDee-Typo3/dotfiles.git" # 👉🏽 set this to the repo you want to clone
    if [ -n "$DOT_FILE_REPO" ]; then
        echo "🔄 Cloning repository: $DOT_FILE_REPO"
        git clone "$DOT_FILE_REPO"
    else
        echo "⚠️  DOT_FILE_REPO is empty. Skipping git clone."
    fi
else
    echo "❌ git is not installed (unexpected, since we installed it earlier)."
fi

###############################################################################
# Check if ~/.config folder already exists in your home directory.
###############################################################################
if [ -d "$HOME/.config" ]; then
    echo "✅ ~/.config already exists"
else
    echo "📁 Creating ~/.config"
    mkdir -p "$HOME/.config"
fi

###############################################################################
# Symlink dotfiles from cloned repo/config to ~/.config (if not already there)
###############################################################################

CONFIG_SOURCE="$HOME/Development/Repositories/dotfiles/config"
CONFIG_TARGET="$HOME/.config"

if [ -d "$CONFIG_SOURCE" ]; then
    echo "🔗 Linking files from $CONFIG_SOURCE to $CONFIG_TARGET"

    mkdir -p "$CONFIG_TARGET"

    for item in "$CONFIG_SOURCE"/*; do
        name=$(basename "$item")

        # ❌ Skip nvim folder
        if [ "$name" = "nvim" ]; then
            echo "⏭️  Skipping $name (handled separately)"
            continue
        fi

        target="$CONFIG_TARGET/$name"

        if [ -e "$target" ] || [ -L "$target" ]; then
            echo "⚠️  $target already exists. Skipping."
            # Optionally backup:
            # mv "$target" "$target.backup.$(date +%s)"
        else
            echo "✅ Linking $name to ~/.config/"
            ln -s "$item" "$target"
        fi
    done
else
    echo "❌ Source config directory not found at $CONFIG_SOURCE"
fi

###############################################################################
# Link or copy .p10k.zsh config
###############################################################################
DOTFILES_REPO="$HOME/Development/Repositories/dotfiles"
P10K_SOURCE="$DOTFILES_REPO/.p10k.zsh"
P10K_TARGET="$HOME/.p10k.zsh"

if [ -f "$P10K_SOURCE" ]; then
    if [ -e "$P10K_TARGET" ] || [ -L "$P10K_TARGET" ]; then
        echo "⚠️  $P10K_TARGET already exists. Skipping."
    else
        echo "🔗 Linking .p10k.zsh config..."
        ln -s "$P10K_SOURCE" "$P10K_TARGET"
    fi
else
    echo "❌ No .p10k.zsh config found at $P10K_SOURCE"
fi

###############################################################################
# Symlink individual files/folders from dotfiles config/nvim to ~/.config/nvim
###############################################################################

NVIM_SOURCE="$HOME/Development/Repositories/dotfiles/config/nvim"
NVIM_TARGET="$HOME/.config/nvim"

if [ -d "$NVIM_SOURCE" ]; then
    echo "📂 Preparing Neovim config..."

    mkdir -p "$NVIM_TARGET"

    for item in "$NVIM_SOURCE"/*; do
        name=$(basename "$item")
        target="$NVIM_TARGET/$name"

        if [ -e "$target" ] || [ -L "$target" ]; then
            echo "🔄 Backing up existing $target to $target.bak"
            mv "$target" "$target.bak"
        fi

        echo "🔗 Linking $name to ~/.config/nvim/"
        ln -s "$item" "$target"
    done
else
    echo "❌ No Neovim config found at $NVIM_SOURCE"
fi

###############################################################################
# Done – ready for your custom steps
###############################################################################
echo "✅ Base setup complete. You can now add your custom steps here."
