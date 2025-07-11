#!/usr/bin/env zsh

# Initialize configuration with defaults
_zsh_git_ai_init_config() {
    # Set default provider if not already set
    : ${ZSH_GIT_AI_PROVIDER:=anthropic}
    
    # Export the configuration
    export ZSH_GIT_AI_PROVIDER
    
    # Determine plugin directory
    local plugin_dir=""
    
    # Try multiple methods to find the plugin directory
    if [[ -n "${ZSH_GIT_AI_DIR}" ]]; then
        # User explicitly set the directory
        plugin_dir="${ZSH_GIT_AI_DIR}"
    elif [[ -n "${(%):-%x}" ]]; then
        # ZSH-specific method for sourced files
        plugin_dir="${${(%):-%x}:A:h:h}"
    elif [[ -n "${BASH_SOURCE[0]}" ]]; then
        # Bash compatibility
        plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    elif [[ "${0}" != "zsh" ]] && [[ "${0}" != "-zsh" ]] && [[ "${0}" != "/bin/zsh" ]] && [[ "${0}" != "/usr/bin/zsh" ]]; then
        # Fallback to $0 if it's not the shell itself
        plugin_dir="${0:A:h:h}"
    fi
    
    # Validate plugin directory
    if [[ -z "$plugin_dir" ]] || [[ ! -d "$plugin_dir/lib/providers" ]]; then
        echo "Error: Could not determine git-commit-ai plugin directory" >&2
        echo "Please set ZSH_GIT_AI_DIR environment variable to the plugin directory" >&2
        return 1
    fi
    
    # Export plugin directory
    export ZSH_GIT_AI_DIR="${plugin_dir}"
    
    return 0
}

# Initialize configuration
_zsh_git_ai_init_config