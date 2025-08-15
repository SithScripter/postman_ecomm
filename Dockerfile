FROM node:18-alpine

WORKDIR /etc/newman

RUN npm install -g newman newman-reporter-htmlextra

# Copy collection & assets
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Default command can be overridden in docker run
ENTRYPOINT ["newman"]
