FROM node:18-alpine
WORKDIR /etc/newman
RUN apk add --no-cache ca-certificates curl && update-ca-certificates \
    && npm install -g newman newman-reporter-htmlextra
ENTRYPOINT ["newman"]
