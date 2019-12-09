FROM alpine:3.10.3

LABEL "com.github.actions.name"="Comment on approved pull requests"
LABEL "com.github.actions.description"="Auto-comment on pull requests once approved"

LABEL version="0.0.0"
LABEL repository="https://github.com/changhc/comment-when-approved-action"
LABEL homepage="https://github.com/changhc/comment-when-approved-action"
LABEL maintainer="Huan-Cheng Chang <changhc84@gmail.com>"

RUN apk add --no-cache bash curl jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
