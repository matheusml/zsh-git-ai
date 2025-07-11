# Configuration Guide

This guide covers all configuration options for zsh-git-ai.

## Table of Contents
- [Provider Selection](#provider-selection)
- [API Keys](#api-keys)
- [Commit Message Customization](#commit-message-customization)
- [Provider-Specific Settings](#provider-specific-settings)
- [Advanced Configuration](#advanced-configuration)

## Provider Selection

Choose your AI provider by setting the `ZSH_GIT_AI_PROVIDER` environment variable:

```bash
export ZSH_GIT_AI_PROVIDER="anthropic"  # Default
```

Available providers:
- `anthropic` - Claude (default)
- `openai` - GPT
- `gemini` - Google Gemini
- `ollama` - Local models

## API Keys

Each provider requires an API key (except Ollama for local models):

```bash
# Anthropic Claude
export ANTHROPIC_API_KEY="your-api-key-here"

# OpenAI GPT
export OPENAI_API_KEY="your-api-key-here"

# Google Gemini
export GEMINI_API_KEY="your-api-key-here"
```

> 💡 **Tip**: Add these to your `~/.zshrc` to make them permanent

## Commit Message Customization

### Message Style

Control the format of generated commit messages:

```bash
export ZSH_GIT_AI_STYLE="simple"  # Options: simple (default), conventional, semantic
```

#### Style Examples:

**Simple** (default):
```
Add user authentication feature
```

**Conventional** (follows [Conventional Commits](https://www.conventionalcommits.org/)):
```
feat(auth): add user authentication
```

**Semantic**:
```
Add user authentication with JWT support
```

### Message Length

Customize the maximum length of commit messages:

```bash
export ZSH_GIT_AI_MAX_LENGTH="100"  # Default: 72
```

### Custom Prompt

For complete control, provide your own prompt template:

```bash
export ZSH_GIT_AI_PROMPT="Generate a commit message that explains the why, not just the what:"
```

Creative examples:
```bash
# Haiku style
export ZSH_GIT_AI_PROMPT="Write a commit message as a haiku:"

# Explain like I'm 5
export ZSH_GIT_AI_PROMPT="Write a commit message that a 5-year-old could understand:"

# Include ticket numbers
export ZSH_GIT_AI_PROMPT="Generate a commit message and always prefix with [JIRA-XXX] if you see a ticket number in the branch name:"
```

## Provider-Specific Settings

### Ollama Configuration

For local Ollama models:

```bash
export OLLAMA_MODEL="llama2"                    # Default: llama2
export OLLAMA_API_URL="http://localhost:11434"  # Default: http://localhost:11434
```

Popular Ollama models:
- `llama2` - Default, balanced
- `codellama` - Optimized for code
- `mistral` - Fast and efficient
- `mixtral` - High quality

## Advanced Configuration

### Environment Persistence

Make your configuration permanent by adding to your shell config:

```bash
# Add to ~/.zshrc
echo 'export ZSH_GIT_AI_PROVIDER="openai"' >> ~/.zshrc
echo 'export OPENAI_API_KEY="your-key"' >> ~/.zshrc
echo 'export ZSH_GIT_AI_STYLE="conventional"' >> ~/.zshrc
echo 'export ZSH_GIT_AI_MAX_LENGTH="100"' >> ~/.zshrc
```

### Configuration Precedence

Settings are applied in this order (later overrides earlier):
1. Default values
2. Environment variables
3. Custom prompt (overrides style settings)

### Per-Project Configuration

You can set different configurations per project using direnv:

1. Install direnv: `brew install direnv`
2. Create `.envrc` in your project:
```bash
export ZSH_GIT_AI_STYLE="conventional"
export ZSH_GIT_AI_MAX_LENGTH="50"
```
3. Allow direnv: `direnv allow`

### SSH and Remote Sessions

To use zsh-git-ai over SSH:

1. Configure SSH to forward environment variables:
```bash
# ~/.ssh/config
Host myserver
    SendEnv ANTHROPIC_API_KEY ZSH_GIT_AI_*
```

2. Configure the server to accept them:
```bash
# /etc/ssh/sshd_config (on server)
AcceptEnv ANTHROPIC_API_KEY ZSH_GIT_AI_*
```

### tmux Configuration

For tmux users, ensure environment variables are updated:

```bash
# ~/.tmux.conf
set-option -g update-environment "ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY ZSH_GIT_AI_*"
```

## Examples

### Example 1: Conventional Commits for a TypeScript Project

```bash
export ZSH_GIT_AI_PROVIDER="anthropic"
export ZSH_GIT_AI_STYLE="conventional"
export ZSH_GIT_AI_MAX_LENGTH="72"
```

### Example 2: Detailed Commits for Documentation

```bash
export ZSH_GIT_AI_STYLE="semantic"
export ZSH_GIT_AI_MAX_LENGTH="100"
export ZSH_GIT_AI_PROMPT="Write a detailed commit message focusing on what changed and why it matters to users:"
```

### Example 3: Quick Local Development with Ollama

```bash
export ZSH_GIT_AI_PROVIDER="ollama"
export OLLAMA_MODEL="codellama"
export ZSH_GIT_AI_STYLE="simple"
```

## Troubleshooting

### Configuration Not Working?

1. Verify environment variables are set:
```bash
echo $ZSH_GIT_AI_PROVIDER
echo $ZSH_GIT_AI_STYLE
```

2. Reload your shell configuration:
```bash
source ~/.zshrc
```

3. Check for typos in variable names (they're case-sensitive)

### Need Help?

- Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
- Open an issue on [GitHub](https://github.com/matheusml/zsh-git-ai/issues)