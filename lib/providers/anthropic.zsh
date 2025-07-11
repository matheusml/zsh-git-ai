#!/usr/bin/env zsh

# Anthropic provider for git-commit-ai

# Source the prompt builder
source "${0:A:h}/../prompt_builder.zsh"

anthropic_api_url="https://api.anthropic.com/v1/messages"
anthropic_model="claude-3-5-sonnet-20241022"

anthropic_check_requirements() {
    if [[ -z "$ANTHROPIC_API_KEY" ]]; then
        echo "Error: ANTHROPIC_API_KEY is not set. Please set it to use the Anthropic provider."
        return 1
    fi
    return 0
}

anthropic_generate_commit_message() {
    local git_diff="$1"
    local status_output="$2"
    
    local prompt=$(build_commit_prompt "$git_diff" "$status_output")

    local json_payload
    if command -v jq &> /dev/null; then
        json_payload=$(jq -n \
            --arg model "$anthropic_model" \
            --arg prompt "$prompt" \
            '{
                model: $model,
                max_tokens: 1024,
                messages: [{
                    role: "user",
                    content: $prompt
                }]
            }')
    else
        # Fallback: Manually construct JSON if jq is not available
        json_payload=$(cat <<EOF
{
    "model": "$anthropic_model",
    "max_tokens": 1024,
    "messages": [{
        "role": "user",
        "content": $(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
    }]
}
EOF
        )
    fi

    local response=$(curl -s -X POST "$anthropic_api_url" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_payload")

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to communicate with Anthropic API"
        return 1
    fi

    # Extract the message content from the response
    local commit_message
    if command -v jq &> /dev/null; then
        commit_message=$(echo "$response" | jq -r '.content[0].text // empty')
    else
        # Fallback: Basic extraction if jq is not available
        commit_message=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"\([^"]*\)"/\1/')
    fi

    if [[ -z "$commit_message" ]]; then
        echo "Error: Failed to generate commit message"
        echo "Response: $response"
        return 1
    fi

    echo "$commit_message"
}