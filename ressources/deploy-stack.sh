#!/bin/bash

if [ ! -f "$STACK_NAME/compose.yaml" ]; then
  echo "Error: compose.yaml not found for stack $STACK_NAME"
  exit 1;
fi

VAULT_PATH="kv/data/$STACK_NAME"
echo "Reading variables from Vault path: $VAULT_PATH"
response=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/$VAULT_PATH")

if echo "$response" | jq -e '.data.data' > /dev/null 2>&1; then
  ENV_VARS=$(echo "$response" | jq -r '.data.data | to_entries | map({"name": .key, "value": .value})')
else
  echo "Warning: No variables found in Vault for $STACK_NAME"
  ENV_VARS="[]"
fi

STACK_ID=$(curl -s \
  -H "X-API-KEY: ${PORTAINER_TOKEN}" \
  "${PORTAINER_ADDR}/api/stacks" \
  | jq -r '.[] | select(.Name == "'$STACK_NAME'") | .Id')

# Determine if creating a new stack or updating an existing one
if [ -z "$STACK_ID" ] || [ "$STACK_ID" == "null" ]; then
  echo "Stack not found, creating new stack $STACK_NAME"
  
  JSON_PAYLOAD=$(jq -n \
    --arg name "$STACK_NAME" \
    --arg swarmID "$PORTAINER_SWARM_ID" \
    --arg stackFile "$(cat $STACK_NAME/compose.yaml)" \
    --argjson env "$ENV_VARS" \
    '{
      "name": $name,
      "swarmID": $swarmID,
      "stackFileContent": $stackFile,
      "env": $env,
      "fromAppTemplate": false
    }')

  METHOD="POST"
  URL="${PORTAINER_ADDR}/api/stacks?type=1&method=string&endpointId=${PORTAINER_ENDPOINT_ID}"
else
  echo "Found Stack ID: $STACK_ID for $STACK_NAME"
  
  JSON_PAYLOAD=$(jq -n \
    --arg content "$(cat $STACK_NAME/compose.yaml)" \
    --argjson env "$ENV_VARS" \
    '{
      "stackFileContent": $content,
      "env": $env,
      "prune": true,
      "pullImage": true
    }')

  METHOD="PUT"
  URL="${PORTAINER_ADDR}/api/stacks/${STACK_ID}?endpointId=${PORTAINER_ENDPOINT_ID}"
fi

# Send the request (either creating or updating the stack)
RESPONSE=$(curl -s -w "\n%{http_code}" -X $METHOD \
  -H "X-API-KEY: ${PORTAINER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "$URL")

HTTP_BODY=$(echo "$RESPONSE" | head -n 1)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

# Common error evaluation
if [ "$HTTP_STATUS" -eq 500 ]; then
  echo "Error with stack $STACK_NAME:"
  echo "$HTTP_BODY" | jq '.'
  exit 1
elif [ "$HTTP_STATUS" -ne 200 ] && [ "$HTTP_STATUS" -ne 201 ]; then
  echo "Unexpected status code $HTTP_STATUS when processing stack $STACK_NAME:"
  echo "$HTTP_BODY"
  exit 1
else
  if [ "$METHOD" == "POST" ]; then
    echo "Successfully created stack $STACK_NAME"
  else
    echo "Successfully updated stack $STACK_NAME"
  fi
fi
