#!/bin/bash
set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

if [[ -z "$COMMENT" ]]; then
  echo "Set the COMMENT env variable."
  exit 1
fi

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
state=$(jq --raw-output .review.state "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

comment_when_approved() {
  # https://developer.github.com/v3/pulls/reviews/#list-reviews-on-a-pull-request
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
  rState=$(echo "$body" | jq --raw-output '[.[] | .state][-1]')

  if [[ "$rState" == "APPROVED" ]]; then
    echo "Commenting on pull request"
    # https://developer.github.com/v3/pulls/comments/#create-a-comment
    curl -sSL \
      -H "${AUTH_HEADER}" \
      -H "${API_HEADER}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "{\"body\":\"${COMMENT}\"}" \
      "${URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/comments"
  fi
}

if [[ "$action" == "submitted" ]] && [[ "$state" == "approved" ]]; then
  comment_when_approved
else
  echo "Ignoring event ${action}/${state}"
fi
