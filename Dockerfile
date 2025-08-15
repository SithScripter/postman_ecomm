# Use a lightweight Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /etc/newman

# Install Newman + HTML Extra reporter
RUN npm install -g newman newman-reporter-htmlextra

# Copy Postman collection and assets into container
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Default entrypoint runs newman
ENTRYPOINT ["newman", "run"]
