#!/bin/bash

# Function to check input arguments
function helper() {
    expected_cmd_args=2
    if [ $# -ne $expected_cmd_args ]; then
        echo "❌ Please execute the script with required arguments."
        echo "✅ Usage: $0 <repo_owner> <repo_name>"
        exit 1
    fi
}

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# Check if required arguments are passed
helper "$@"

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    response="$(github_api_get "$endpoint")"


    # Extract users with read access
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions? and .permissions.pull == true) | .login')

    if [[ -z "$collaborators" ]]; then
        echo "⚠️ No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "✅ Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main execution
echo "🔍 Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
