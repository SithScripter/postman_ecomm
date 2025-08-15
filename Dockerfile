# Base image
FROM node:18-alpine

# Set work directory
WORKDIR /etc/newman

# Install Newman & HTML Extra reporter
RUN npm install -g newman newman-reporter-htmlextra

# Copy collection and any assets
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Default command
ENTRYPOINT ["newman", "run"]