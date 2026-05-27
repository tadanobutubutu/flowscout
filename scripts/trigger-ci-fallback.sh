#!/bin/bash

# trigger-ci-fallback.sh
# GitHub Actionsから呼び出され、各CIサービスの無料枠制限を検知しながら
# 優先順位（Codemagic -> Bitrise -> Travis -> CircleCI）に沿ってビルドをトリガーする。

BRANCH_NAME=${1:-"dev"}
echo "🚀 Flowscout Fallback CI/CD Trigger Initiated for branch: $BRANCH_NAME"

# 🛠️ 1. Codemagic Trigger
echo "Checking Codemagic..."
if [ -n "$CODEMAGIC_API_KEY" ] && [ -n "$CODEMAGIC_APP_ID" ]; then
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $CODEMAGIC_API_KEY" \
    -d "{\"appId\": \"$CODEMAGIC_APP_ID\", \"workflowId\": \"flutter-android\", \"branch\": \"$BRANCH_NAME\"}" \
    https://api.codemagic.io/builds)
  
  if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
    echo "✅ Codemagic build successfully triggered!"
    exit 0
  else
    echo "⚠️ Codemagic trigger failed or limit reached (HTTP: $RESPONSE). Falling back to Bitrise..."
  fi
else
  echo "⚠️ Codemagic credentials missing. Skipping..."
fi

# 🛠️ 2. Bitrise Trigger
echo "Checking Bitrise..."
if [ -n "$BITRISE_APP_SLUG" ] && [ -n "$BITRISE_APP_TOKEN" ]; then
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"hook_info\":{\"type\":\"bitrise\"},\"build_params\":{\"branch\":\"$BRANCH_NAME\",\"workflow_id\":\"primary\"}}" \
    https://app.bitrise.io/app/$BITRISE_APP_SLUG/build/start.json?api_token=$BITRISE_APP_TOKEN)
  
  if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
    echo "✅ Bitrise build successfully triggered!"
    exit 0
  else
    echo "⚠️ Bitrise trigger failed or limit reached (HTTP: $RESPONSE). Falling back to Travis..."
  fi
else
  echo "⚠️ Bitrise credentials missing. Skipping..."
fi

# 🛠️ 3. Travis CI Trigger
echo "Checking Travis CI..."
if [ -n "$TRAVIS_TOKEN" ] && [ -n "$TRAVIS_REPO" ]; then
  # Travisはリポジトリ名をURLエンコードする必要がある (例: tadanobutubutu%2Fflowscout)
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token $TRAVIS_TOKEN" \
    -d "{\"request\": {\"branch\":\"$BRANCH_NAME\"}}" \
    https://api.travis-ci.com/repo/$TRAVIS_REPO/requests)
  
  if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 202 ]; then
    echo "✅ Travis CI build successfully triggered!"
    exit 0
  else
    echo "⚠️ Travis CI trigger failed or limit reached (HTTP: $RESPONSE). Falling back to CircleCI..."
  fi
else
  echo "⚠️ Travis CI credentials missing. Skipping..."
fi

# 🛠️ 4. CircleCI Trigger
echo "Checking CircleCI..."
if [ -n "$CIRCLE_TOKEN" ] && [ -n "$CIRCLE_PROJECT_SLUG" ]; then
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Circle-Token: $CIRCLE_TOKEN" \
    -d "{\"branch\":\"$BRANCH_NAME\"}" \
    https://circleci.com/api/v2/project/$CIRCLE_PROJECT_SLUG/pipeline)
  
  if [ "$RESPONSE" -eq 201 ] || [ "$RESPONSE" -eq 200 ]; then
    echo "✅ CircleCI build successfully triggered!"
    exit 0
  else
    echo "❌ CircleCI trigger failed (HTTP: $RESPONSE). No more fallbacks available."
  fi
else
  echo "⚠️ CircleCI credentials missing. Fallback trigger aborted."
fi

exit 1
