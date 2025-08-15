FROM node:18-alpine

WORKDIR /etc/newman

# Install Newman and HTML Extra Reporter
RUN npm install -g newman newman-reporter-htmlextra

# Copy collection and any assets into the container
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Set entrypoint to run Newman automatically when container starts
ENTRYPOINT ["newman", "run"]
