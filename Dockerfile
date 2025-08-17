FROM node:18-alpine

WORKDIR /etc/newman

# Install Newman and reporters
RUN apk add --no-cache ca-certificates curl && update-ca-certificates && \
    npm install -g newman \
    newman-reporter-htmlextra \
    newman-reporter-allure2

COPY . .

ENTRYPOINT ["newman"]
