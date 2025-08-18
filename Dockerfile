# Dockerfile.standalone
FROM node:18-alpine

WORKDIR /etc/newman

# Install Newman + Allure + HTML Extra reporters
RUN npm install -g newman newman-reporter-htmlextra newman-reporter-allure

# Copy test collection + assets into container
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Default entrypoint
ENTRYPOINT ["newman"]

# Run collection by default (can be overridden)
CMD ["run", "E2E_Ecommerce.postman_collection.json", "-r", "cli,allure"]
