# Use official Node.js Alpine image (lightweight)
FROM node:18-alpine

# Set working directory
WORKDIR /etc/newman

# Install Newman and HTML extra reporter globally
RUN npm install -g newman newman-reporter-htmlextra

# Copy your Postman collection into the container
COPY E2E_Ecommerce.postman_collection.json .

# Copy the product image to the same directory
COPY headerimage@2x.jpg .

# Default command (overridden by Jenkinsfile at runtime)
CMD ["newman", "run", "E2E_Ecommerce.postman_collection.json"]
