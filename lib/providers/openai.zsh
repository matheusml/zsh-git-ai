#!/usr/bin/env zsh

# OpenAI provider for git-commit-ai

# Source the prompt builder
source "${0:A:h}/../prompt_builder.zsh"

openai_api_url="https://api.openai.com/v1/chat/completions"
openai_model="gpt-4-turbo-preview"

openai_check_requirements() {
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "Error: OPENAI_API_KEY is not set. Please set it to use the OpenAI provider."
        return 1
    fi
    return 0
}

openai_generate_commit_message() {
    local git_diff="$1"
    local status_output="$2"
    
    local prompt=$(build_commit_prompt "$git_diff" "$status_output")

    local json_payload
    if command -v jq &> /dev/null; then
        json_payload=$(jq -n \
            --arg model "$openai_model" \
            --arg prompt "$prompt" \
            '{
                model: $model,
                messages: [{
                    role: "system",
                    content: "You are a helpful assistant that writes concise git commit messages."
                }, {
                    role: "user",
                    content: $prompt
                }],
                temperature: 0.3,
                max_tokens: 100
            }')
    else
        # Fallback: Manually construct JSON if jq is not available
        json_payload=$(cat <<EOF
{
    "model": "$openai_model",
    "messages": [{
        "role": "system",
        "content": "You are a helpful assistant that writes concise git commit messages."
    }, {
        "role": "user",
        "content": $(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
    }],
    "temperature": 0.3,
    "max_tokens": 100
}
EOF
        )
    fi

    local response=$(curl -s -X POST "$openai_api_url" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$json_payload")

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to communicate with OpenAI API"
        return 1
    fi

    # Extract the message content from the response
    local commit_message
    if command -v jq &> /dev/null; then
        commit_message=$(echo "$response" | jq -r '.choices[0].message.content // empty')
    else
        # Fallback: Basic extraction if jq is not available
        commit_message=$(echo "$response" | grep -o '"content":"[^"]*"' | head -1 | sed 's/"content":"\([^"]*\)"/\1/')
    fi

    if [[ -z "$commit_message" ]]; then
        echo "Error: Failed to generate commit message"
        echo "Response: $response"
        return 1
    fi

    echo "$commit_message"
}