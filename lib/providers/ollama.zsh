#!/usr/bin/env zsh

# Ollama provider for git-commit-ai

# Source the prompt builder
source "${0:A:h}/../prompt_builder.zsh"

ollama_api_url="${OLLAMA_API_URL:-http://localhost:11434}"
ollama_model="${OLLAMA_MODEL:-llama2}"

ollama_check_requirements() {
    # Check if Ollama is running
    if ! curl -s "${ollama_api_url}/api/tags" > /dev/null 2>&1; then
        echo "Error: Cannot connect to Ollama at ${ollama_api_url}. Make sure Ollama is running."
        return 1
    fi
    
    # Check if the model exists
    local models=$(curl -s "${ollama_api_url}/api/tags" | grep -o "\"name\":\"${ollama_model}\"" || true)
    if [[ -z "$models" ]]; then
        echo "Warning: Model '${ollama_model}' not found. You may need to pull it with: ollama pull ${ollama_model}"
    fi
    
    return 0
}

ollama_generate_commit_message() {
    local git_diff="$1"
    local status_output="$2"
    
    local prompt=$(build_commit_prompt "$git_diff" "$status_output")

    local json_payload
    if command -v jq &> /dev/null; then
        json_payload=$(jq -n \
            --arg model "$ollama_model" \
            --arg prompt "$prompt" \
            '{
                model: $model,
                prompt: $prompt,
                stream: false,
                options: {
                    temperature: 0.3,
                    num_predict: 100
                }
            }')
    else
        # Fallback: Manually construct JSON if jq is not available
        json_payload=$(cat <<EOF
{
    "model": "$ollama_model",
    "prompt": $(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//'),
    "stream": false,
    "options": {
        "temperature": 0.3,
        "num_predict": 100
    }
}
EOF
        )
    fi

    local response=$(curl -s -X POST "${ollama_api_url}/api/generate" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to communicate with Ollama API"
        return 1
    fi

    # Extract the message content from the response
    local commit_message
    if command -v jq &> /dev/null; then
        commit_message=$(echo "$response" | jq -r '.response // empty')
    else
        # Fallback: Basic extraction if jq is not available
        commit_message=$(echo "$response" | grep -o '"response":"[^"]*"' | head -1 | sed 's/"response":"\([^"]*\)"/\1/')
    fi

    if [[ -z "$commit_message" ]]; then
        echo "Error: Failed to generate commit message"
        echo "Response: $response"
        return 1
    fi

    # Clean up the message (remove any extra newlines or formatting)
    commit_message=$(echo "$commit_message" | head -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "$commit_message"
}