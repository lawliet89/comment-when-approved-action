FROM node:12-alpine

LABEL "com.github.actions.name"="Comment on approved pull requests"
LABEL "com.github.actions.description"="Auto-comment on pull requests once approved"
LABEL "com.github.actions.icon"="git-pull-request"
LABEL "com.github.actions.color"="gray-dark"

RUN apk add --no-cache bash curl jq

ADD index.js /index.js
CMD ["node", "/index.js"]
