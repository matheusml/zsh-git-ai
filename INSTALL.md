# Installation Guide

This guide covers all installation methods for git-commit-ai.

## Prerequisites

- **zsh** 5.0 or higher
- **git**
- **curl** (for API calls)
- **Claude API key** from [Anthropic Console](https://console.anthropic.com/)
- Optional: **jq** (for better JSON handling)

## Quick Install

```bash
# Clone the repository
git clone https://github.com/matheusml/git-commit-ai ~/.git-commit-ai

# Add to your .zshrc
echo "source ~/.git-commit-ai/git-commit-ai.zsh" >> ~/.zshrc

# Set your API key
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

## Installation Methods

### 1. Manual Installation (Recommended)

```bash
# Clone to your preferred location
git clone https://github.com/matheusml/git-commit-ai ~/Apps/git-commit-ai

# Source in your .zshrc
echo "source ~/Apps/git-commit-ai/git-commit-ai.zsh" >> ~/.zshrc

# Reload
source ~/.zshrc
```

### 2. Oh My Zsh Plugin

```bash
# Clone to Oh My Zsh custom plugins
git clone https://github.com/matheusml/git-commit-ai \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-commit-ai

# Add to your .zshrc plugins list
# Edit ~/.zshrc and add git-commit-ai to plugins=()
# Example: plugins=(git git-commit-ai)

# Reload
source ~/.zshrc
```

### 3. Antigen

Add to your `.zshrc`:
```bash
antigen bundle matheusml/git-commit-ai
```

### 4. Zplug

Add to your `.zshrc`:
```bash
zplug "matheusml/git-commit-ai"
```

### 5. Direct Download

```bash
# Download the script directly
curl -o ~/.git-commit-ai.zsh \
  https://raw.githubusercontent.com/matheusml/git-commit-ai/main/git-commit-ai.zsh

# Make it executable
chmod +x ~/.git-commit-ai.zsh

# Source it
echo "source ~/.git-commit-ai.zsh" >> ~/.zshrc
source ~/.zshrc
```

## API Key Setup

### Getting Your API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (it won't be shown again!)

### Setting the API Key

Choose one of these methods:

#### Option 1: Add to .zshrc (Recommended)
```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
source ~/.zshrc
```

#### Option 2: Add to .zshenv
```bash
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

# Check if API key is set
[[ -n "$ANTHROPIC_API_KEY" ]] && echo "✓ API key set" || echo "✗ API key not set"

# Test with a dummy commit
mkdir /tmp/git-commit-ai-test
cd /tmp/git-commit-ai-test
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
ls -la ~/.git-commit-ai/git-commit-ai.zsh  # File should exist
```

3. Check .zshrc:
```bash
grep git-commit-ai ~/.zshrc  # Should show the source line
```

### API Key Issues

1. Verify key is set:
```bash
echo $ANTHROPIC_API_KEY  # Should show your key (be careful sharing!)
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
chmod +x ~/.git-commit-ai/git-commit-ai.zsh
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
# Load git-commit-ai after other git plugins
source ~/.git-commit-ai/git-commit-ai.zsh
```

## Uninstallation

To remove git-commit-ai:

```bash
# Remove the source line from .zshrc
sed -i '' '/git-commit-ai/d' ~/.zshrc

# Remove the installation
rm -rf ~/.git-commit-ai

# Remove API key (optional)
sed -i '' '/ANTHROPIC_API_KEY/d' ~/.zshrc

# Reload shell
source ~/.zshrc
```

## Updating

To update to the latest version:

```bash
cd ~/.git-commit-ai
git pull origin main
source ~/.zshrc
```

Or set up an alias:
```bash
echo 'alias update-git-commit-ai="cd ~/.git-commit-ai && git pull && cd - && source ~/.zshrc"' >> ~/.zshrc
```

## Advanced Configuration

### Custom Installation Location

```bash
# Install anywhere you want
git clone https://github.com/matheusml/git-commit-ai /custom/path/git-commit-ai

# Source from custom path
echo "source /custom/path/git-commit-ai/git-commit-ai.zsh" >> ~/.zshrc
```

### Using with Tmux

Add to `.tmux.conf` to preserve environment:
```bash
set-option -g update-environment "ANTHROPIC_API_KEY"
```

### Using with SSH

Forward your API key when SSHing:
```bash
ssh -o SendEnv=ANTHROPIC_API_KEY user@host
```

Add to server's `/etc/ssh/sshd_config`:
```
AcceptEnv ANTHROPIC_API_KEY
```

---

Need help? Check our [Troubleshooting](#troubleshooting) section or [open an issue](https://github.com/matheusml/git-commit-ai/issues).