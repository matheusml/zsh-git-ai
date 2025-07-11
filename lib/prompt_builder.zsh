#!/usr/bin/env zsh

# Function to build the commit message prompt based on configuration
build_commit_prompt() {
    local diff="$1"
    local git_status="$2"
    local max_length="${ZSH_GIT_AI_MAX_LENGTH:-72}"
    local style="${ZSH_GIT_AI_STYLE:-simple}"
    
    # If custom prompt is provided, use it directly
    if [[ -n "$ZSH_GIT_AI_PROMPT" ]]; then
        echo "$ZSH_GIT_AI_PROMPT"
        echo ""
        echo "Git status:"
        echo "$git_status"
        echo ""
        echo "Git diff:"
        echo "$diff"
        return
    fi
    
    # Otherwise, build prompt based on style
    case "$style" in
        conventional)
            cat <<EOF
You are a helpful assistant that writes git commit messages following the Conventional Commits specification.

Based on the following git diff and status, generate a commit message that:
- Follows the format: <type>(<scope>): <subject>
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
- Be no longer than $max_length characters for the subject line
- Use lowercase for type and scope
- No period at the end
- Only output the commit message, nothing else

Git status:
$git_status

Git diff:
$diff
EOF
            ;;
            
        semantic)
            cat <<EOF
You are a helpful assistant that writes semantic git commit messages.

Based on the following git diff and status, generate a commit message that:
- Starts with a semantic prefix: Add, Update, Fix, Remove, Refactor, Rename, Move, Improve
- Be no longer than $max_length characters
- Clearly describes what changed and why (if apparent)
- Use present tense and imperative mood
- Only output the commit message, nothing else

Git status:
$git_status

Git diff:
$diff
EOF
            ;;
            
        simple|*)
            cat <<EOF
You are a helpful assistant that writes concise and descriptive git commit messages.

Based on the following git diff and status, generate a clear and concise commit message.
The commit message should:
- Be written in the imperative mood (e.g., 'Add feature' not 'Added feature')
- Be no longer than $max_length characters
- Clearly describe what the change does, not how it does it
- Only output the commit message, nothing else

Git status:
$git_status

Git diff:
$diff
EOF
            ;;
    esac
}