FROM node:18-alpine

WORKDIR /etc/newman

# Install curl + certs + Newman + reporters
RUN apk add --no-cache ca-certificates curl && update-ca-certificates && \
    npm install -g newman newman-reporter-htmlextra newman-reporter-allure

ENTRYPOINT ["newman"]
