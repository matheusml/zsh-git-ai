#!/usr/bin/env zsh

# Gemini provider for git-commit-ai

# Source the prompt builder
source "${0:A:h}/../prompt_builder.zsh"

gemini_api_url="https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
gemini_model="gemini-pro"

gemini_check_requirements() {
    if [[ -z "$GEMINI_API_KEY" ]]; then
        echo "Error: GEMINI_API_KEY is not set. Please set it to use the Gemini provider."
        return 1
    fi
    return 0
}

gemini_generate_commit_message() {
    local git_diff="$1"
    local status_output="$2"
    
    local prompt=$(build_commit_prompt "$git_diff" "$status_output")

    local json_payload
    if command -v jq &> /dev/null; then
        json_payload=$(jq -n \
            --arg prompt "$prompt" \
            '{
                contents: [{
                    parts: [{
                        text: $prompt
                    }]
                }],
                generationConfig: {
                    temperature: 0.3,
                    maxOutputTokens: 100
                }
            }')
    else
        # Fallback: Manually construct JSON if jq is not available
        json_payload=$(cat <<EOF
{
    "contents": [{
        "parts": [{
            "text": $(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
        }]
    }],
    "generationConfig": {
        "temperature": 0.3,
        "maxOutputTokens": 100
    }
}
EOF
        )
    fi

    local response=$(curl -s -X POST "${gemini_api_url}?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to communicate with Gemini API"
        return 1
    fi

    # Extract the message content from the response
    local commit_message
    if command -v jq &> /dev/null; then
        commit_message=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty')
    else
        # Fallback: Basic extraction if jq is not available
        commit_message=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"\([^"]*\)"/\1/')
    fi

    if [[ -z "$commit_message" ]]; then
        echo "Error: Failed to generate commit message"
        echo "Response: $response"
        return 1
    fi

    # Gemini sometimes adds extra formatting, so we'll clean it up
    commit_message=$(echo "$commit_message" | head -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "$commit_message"
}