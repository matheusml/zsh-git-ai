#!/usr/bin/env zsh

# Git Commit AI - Generate commit messages with AI providers

# Get plugin directory for initial config loading
local plugin_dir="${0:A:h}"

# Source configuration
source "${plugin_dir}/lib/config.zsh" || return 1

# Now use the configured directory
SCRIPT_DIR="${ZSH_GIT_AI_DIR}"

# Source the selected provider
load_provider() {
    local provider="$1"
    local provider_file="${SCRIPT_DIR}/lib/providers/${provider}.zsh"
    
    if [[ ! -f "$provider_file" ]]; then
        echo "Error: Provider '$provider' not found" >&2
        echo "Available providers: anthropic, openai, gemini, ollama" >&2
        return 1
    fi
    
    source "$provider_file"
    
    # Check provider requirements
    if ! ${provider}_check_requirements; then
        return 1
    fi
    
    return 0
}

# Load the configured provider
if ! load_provider "$ZSH_GIT_AI_PROVIDER"; then
    return 1
fi

# Function to show a spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r\033[36m%s\033[0m Generating commit message..." "${spinstr:0:1}"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r\033[K"
}

# Function to generate commit message using the selected provider
generate_commit_message() {
    local diff="$1"
    local status_output="$2"
    
    # Call the provider-specific function
    ${ZSH_GIT_AI_PROVIDER}_generate_commit_message "$diff" "$status_output"
}

# Override git function
git() {
    # Check if it's a commit command without -m flag
    if [[ "$1" == "commit" && "$#" -eq 1 ]]; then
        # Check if there are staged changes
        if ! command git diff --cached --quiet; then
            # Get the diff of staged changes
            local diff=$(command git diff --cached)
            local status_output=$(command git status --short)
            
            # Disable job control messages
            set +m
            
            # Generate commit message with spinner
            (generate_commit_message "$diff" "$status_output" > /tmp/zsh-git-ai-message.tmp 2>&1) &
            local generate_pid=$!
            show_spinner $generate_pid
            wait $generate_pid 2>/dev/null
            
            # Re-enable job control
            set -m
            
            if [[ ! -f /tmp/zsh-git-ai-message.tmp ]]; then
                echo "Error: Failed to generate commit message"
                return 1
            fi
            
            local generated_message=$(cat /tmp/zsh-git-ai-message.tmp)
            rm -f /tmp/zsh-git-ai-message.tmp
            
            if [[ -z "$generated_message" ]]; then
                echo "Error: Generated message is empty"
                return 1
            fi
            
            # Move cursor to beginning of line and clear it
            echo -ne "\r\033[K"
            
            # Put the command in the buffer for editing
            print -z "git commit -m \"$generated_message\""
            
            # Return false to prevent execution of the original command
            return 1
        else
            echo "No changes staged for commit"
            return 1
        fi
    else
        # Pass through to regular git command
        command git "$@"
    fi
}