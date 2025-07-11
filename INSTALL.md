# Installation Guide

This guide covers all installation methods for zsh-git-ai.

## Prerequisites

- ✅ zsh 5.0+ (you probably already have this)
- ✅ `git` (you probably already have this)
- ✅ `curl` (already on macOS/Linux)
- ➕ `jq` (optional, for better reliability)

## Quick Install

### 🍺 Homebrew (Recommended)

```bash
# Install via Homebrew
brew tap matheusml/zsh-git-ai
brew install zsh-git-ai

# Add to your .zshrc
echo "source $(brew --prefix)/share/zsh-git-ai/zsh-git-ai.plugin.zsh" >> ~/.zshrc

# Set your API key
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/matheusml/zsh-git-ai ~/.zsh-git-ai

# Add to your .zshrc
echo "source ~/.zsh-git-ai/zsh-git-ai.plugin.zsh" >> ~/.zshrc

# Set your API key
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

## Installation Methods

### 1. Homebrew (Recommended for macOS/Linux)

```bash
# Add the tap
brew tap matheusml/zsh-git-ai

# Install the package
brew install zsh-git-ai

# Add to your shell configuration
echo "source $(brew --prefix)/share/zsh-git-ai/zsh-git-ai.plugin.zsh" >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

#### Updating via Homebrew

```bash
brew update
brew upgrade zsh-git-ai
```

#### Uninstalling via Homebrew

```bash
brew uninstall zsh-git-ai
brew untap matheusml/zsh-git-ai
```

### 2. Manual Installation

```bash
# Clone to your preferred location
git clone https://github.com/matheusml/zsh-git-ai ~/Apps/zsh-git-ai

# Source in your .zshrc
echo "source ~/Apps/zsh-git-ai/zsh-git-ai.plugin.zsh" >> ~/.zshrc

# Reload
source ~/.zshrc
```

### 3. Oh My Zsh Plugin

```bash
# Clone to Oh My Zsh custom plugins
git clone https://github.com/matheusml/zsh-git-ai \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-git-ai

# Add to your .zshrc plugins list
# Edit ~/.zshrc and add zsh-git-ai to plugins=()
# Example: plugins=(git zsh-git-ai)

# Reload
source ~/.zshrc
```

### 4. Antigen

Add to your `.zshrc`:
```bash
antigen bundle matheusml/zsh-git-ai
```

### 5. Zplug

Add to your `.zshrc`:
```bash
zplug "matheusml/zsh-git-ai"
```

### 6. Direct Download

```bash
# Download the script directly
curl -o ~/.zsh-git-ai.plugin.zsh \
  https://raw.githubusercontent.com/matheusml/zsh-git-ai/main/zsh-git-ai.plugin.zsh

# Make it executable
chmod +x ~/.zsh-git-ai.plugin.zsh

# Source it
echo "source ~/.zsh-git-ai.plugin.zsh" >> ~/.zshrc
source ~/.zshrc
```

## Configuration

zsh-git-ai supports multiple AI providers and extensive customization options.

### Quick Setup

```bash
# Set your provider (default: anthropic)
export ZSH_GIT_AI_PROVIDER="anthropic"

# Set your API key
export ANTHROPIC_API_KEY="your-api-key-here"
```

> 📚 **For detailed configuration options**, including:
> - All supported providers and their settings
> - Commit message customization (styles, length, custom prompts)
> - Provider-specific configuration
> - Advanced setup (per-project config, SSH, tmux)
>
> **See the [Configuration Guide](CONFIGURATION.md)**

## API Key Setup

### Getting Your API Key

#### Anthropic Claude
1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (it won't be shown again!)

#### OpenAI GPT
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key

#### Google Gemini
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Get API Key"
4. Create a new API key or use existing one
5. Copy the key

#### Ollama (Local)
1. Install Ollama from [ollama.ai](https://ollama.ai/)
2. Pull a model: `ollama pull llama2`
3. No API key needed - runs locally!

### Setting the API Key

Choose one of these methods:

#### Option 1: Add to .zshrc (Recommended)
```bash
# For Anthropic (default)
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc

# For OpenAI
echo 'export ZSH_GIT_AI_PROVIDER="openai"' >> ~/.zshrc
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.zshrc

# For Gemini
echo 'export ZSH_GIT_AI_PROVIDER="gemini"' >> ~/.zshrc
echo 'export GEMINI_API_KEY="AI..."' >> ~/.zshrc

# For Ollama
echo 'export ZSH_GIT_AI_PROVIDER="ollama"' >> ~/.zshrc

source ~/.zshrc
```

#### Option 2: Add to .zshenv
```bash
# Example for Anthropic
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshenv
source ~/.zshenv
```

#### Option 3: Use a secrets manager
```bash
# Example with 1Password CLI
export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API Key/credential")
```

## Optional Dependencies

### Installing jq

While not required, `jq` improves JSON handling and is recommended:

#### macOS
```bash
brew install jq
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install jq
```

#### Fedora
```bash
sudo dnf install jq
```

#### Arch Linux
```bash
sudo pacman -S jq
```

## Verification

Verify your installation:

```bash
# Check if the function is loaded
type git | grep -q "git is a shell function" && echo "✓ Plugin loaded" || echo "✗ Plugin not loaded"

# Check if API key is set (adjust based on your provider)
# For Anthropic (default)
[[ -n "$ANTHROPIC_API_KEY" ]] && echo "✓ API key set" || echo "✗ API key not set"
# For OpenAI
# [[ -n "$OPENAI_API_KEY" ]] && echo "✓ API key set" || echo "✗ API key not set"
# For Gemini
# [[ -n "$GEMINI_API_KEY" ]] && echo "✓ API key set" || echo "✗ API key not set"

# Test with a dummy commit
mkdir /tmp/zsh-git-ai-test
cd /tmp/zsh-git-ai-test
git init
echo "test" > test.txt
git add test.txt
git commit  # Should trigger the AI
```

## Troubleshooting

### Plugin Not Loading

1. Check your shell:
```bash
echo $SHELL  # Should show /bin/zsh or similar
```

2. Verify source path:
```bash
ls -la ~/.zsh-git-ai/zsh-git-ai.plugin.zsh  # File should exist
```

3. Check .zshrc:
```bash
grep zsh-git-ai ~/.zshrc  # Should show the source line
```

### API Key Issues

1. Verify key is set:
```bash
# Check based on your provider
echo $ANTHROPIC_API_KEY  # For Anthropic
# echo $OPENAI_API_KEY  # For OpenAI
# echo $GEMINI_API_KEY  # For Gemini
```

2. Test API directly:
```bash
curl -X POST https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

### Permission Denied

```bash
chmod +x ~/.zsh-git-ai/zsh-git-ai.plugin.zsh
```

### Conflicts with Other Plugins

If you have other git aliases or functions:

1. Check for conflicts:
```bash
type git  # See what's overriding
alias | grep git  # Check aliases
```

2. Load order matters in .zshrc:
```bash
# Load zsh-git-ai after other git plugins
source ~/.zsh-git-ai/zsh-git-ai.plugin.zsh
```

## Uninstallation

To remove zsh-git-ai:

```bash
# Remove the source line from .zshrc
sed -i '' '/zsh-git-ai/d' ~/.zshrc

# Remove the installation
rm -rf ~/.zsh-git-ai

# Remove API key (optional) - adjust based on your provider
sed -i '' '/ANTHROPIC_API_KEY/d' ~/.zshrc
sed -i '' '/OPENAI_API_KEY/d' ~/.zshrc
sed -i '' '/GEMINI_API_KEY/d' ~/.zshrc
sed -i '' '/ZSH_GIT_AI_PROVIDER/d' ~/.zshrc

# Reload shell
source ~/.zshrc
```

## Updating

To update to the latest version:

### Homebrew
```bash
brew update
brew upgrade zsh-git-ai
```

### Manual Installation
```bash
cd ~/.zsh-git-ai
git pull origin main
source ~/.zshrc
```

Or set up an alias:
```bash
echo 'alias update-zsh-git-ai="cd ~/.zsh-git-ai && git pull && cd - && source ~/.zshrc"' >> ~/.zshrc
```

## Advanced Setup

### Custom Installation Location

```bash
# Install anywhere you want
git clone https://github.com/matheusml/zsh-git-ai /custom/path/zsh-git-ai

# Source from custom path
echo "source /custom/path/zsh-git-ai/zsh-git-ai.plugin.zsh" >> ~/.zshrc
```

> 📚 **For more advanced configuration options**, including:
> - tmux integration
> - SSH environment forwarding
> - Per-project configuration
> - Custom commit message styles and prompts
>
> **See the [Configuration Guide](CONFIGURATION.md)**

---

Need help? Check our [Troubleshooting](#troubleshooting) section or [open an issue](https://github.com/matheusml/zsh-git-ai/issues).
