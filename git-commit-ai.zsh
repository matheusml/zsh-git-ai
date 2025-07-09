#!/usr/bin/env zsh

# Git Commit AI - Generate commit messages with Claude

# Check if Claude API key is set
if [[ -z "$ANTHROPIC_API_KEY" ]]; then
    echo "Error: ANTHROPIC_API_KEY environment variable not set" >&2
    echo "Please set it with: export ANTHROPIC_API_KEY='your-api-key'" >&2
    return 1
fi

# Function to show a spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] Generating commit message..." "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        printf "\r"
        sleep $delay
    done
    printf "    \r"
}

# Function to call Claude API
generate_commit_message() {
    local diff="$1"
    
    # Use printf and jq for proper JSON encoding
    local json_payload
    if command -v jq >/dev/null 2>&1; then
        # Use jq if available for proper JSON encoding
        json_payload=$(jq -n \
            --arg model "claude-3-5-sonnet-20241022" \
            --arg content "Generate a concise git commit message for the following changes. Only return the commit message, nothing else:

$diff" \
            '{
                model: $model,
                max_tokens: 100,
                messages: [{
                    role: "user",
                    content: $content
                }]
            }')
    else
        # Fallback: use a more aggressive escaping approach
        local escaped_diff=$(printf '%s' "$diff" | sed 's/[\\]/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
        json_payload="{
            \"model\": \"claude-3-5-sonnet-20241022\",
            \"max_tokens\": 100,
            \"messages\": [{
                \"role\": \"user\",
                \"content\": \"Generate a concise git commit message for the following changes. Only return the commit message, nothing else:\\n\\n${escaped_diff}\"
            }]
        }"
    fi
    
    # Prepare the API request
    local response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_payload"
    )
    
    # Extract the message from the response using more robust JSON parsing
    local message=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"//; s/"$//')
    
    # Handle JSON escape sequences
    message=$(echo "$message" | sed 's/\\n/\n/g; s/\\"/"/g; s/\\\\/\\/g')
    
    if [[ -z "$message" ]]; then
        # Debug: show the actual response for troubleshooting
        echo "Error: Failed to parse commit message from API response" >&2
        echo "Response: $response" >&2
        return 1
    fi
    
    echo "$message"
}

# Override git function
git() {
    # Check if it's a commit command without -m flag
    if [[ "$1" == "commit" && "$#" -eq 1 ]]; then
        # Check if there are staged changes
        if ! command git diff --cached --quiet; then
            # Get the diff of staged changes
            local diff=$(command git diff --cached)
            
            # Generate commit message with spinner
            (generate_commit_message "$diff" > /tmp/git-commit-ai-message.tmp 2>&1) &
            local generate_pid=$!
            show_spinner $generate_pid
            wait $generate_pid 2>/dev/null
            
            if [[ ! -f /tmp/git-commit-ai-message.tmp ]]; then
                echo "Error: Failed to generate commit message"
                return 1
            fi
            
            local generated_message=$(cat /tmp/git-commit-ai-message.tmp)
            rm -f /tmp/git-commit-ai-message.tmp
            
            if [[ -z "$generated_message" ]]; then
                echo "Error: Generated message is empty"
                return 1
            fi
            
            # Display the generated message
            echo "\nGenerated commit message:"
            echo "------------------------"
            echo "$generated_message"
            echo "------------------------"
            
            # Prompt user for action
            while true; do
                echo -n "\n[A]ccept, [E]dit, [R]egenerate, or [C]ancel? "
                read -k 1 choice
                echo
                
                case "$choice" in
                    a|A)
                        command git commit -m "$generated_message"
                        break
                        ;;
                    e|E)
                        # Create a temporary file with the message for editing
                        local tmpfile=$(mktemp)
                        echo "$generated_message" > "$tmpfile"
                        ${EDITOR:-nano} "$tmpfile"
                        local edited_message=$(cat "$tmpfile")
                        rm -f "$tmpfile"
                        
                        if [[ -n "$edited_message" ]]; then
                            command git commit -m "$edited_message"
                        else
                            echo "Commit cancelled (empty message)"
                        fi
                        break
                        ;;
                    r|R)
                        # Regenerate the message
                        echo "Regenerating commit message..."
                        (generate_commit_message "$diff" > /tmp/git-commit-ai-message.tmp 2>&1) &
                        local regenerate_pid=$!
                        show_spinner $regenerate_pid
                        wait $regenerate_pid 2>/dev/null
                        
                        generated_message=$(cat /tmp/git-commit-ai-message.tmp)
                        rm -f /tmp/git-commit-ai-message.tmp
                        
                        echo "\nGenerated commit message:"
                        echo "------------------------"
                        echo "$generated_message"
                        echo "------------------------"
                        ;;
                    c|C)
                        echo "Commit cancelled"
                        break
                        ;;
                    *)
                        echo "Invalid choice. Please select A, E, R, or C."
                        ;;
                esac
            done
        else
            echo "No changes staged for commit"
            return 1
        fi
    else
        # Pass through to regular git command
        command git "$@"
    fi
}
