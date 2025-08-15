# Base image
FROM node:18-alpine

# Set work directory
WORKDIR /etc/newman

# Install Newman & HTML Extra reporter
RUN npm install -g newman newman-reporter-htmlextra

# Copy collection and any assets (permissions safe for mounted volumes)
COPY --chown=node:node E2E_Ecommerce.postman_collection.json .
COPY --chown=node:node headerimage@2x.jpg .

# Use a non-root user for better security
USER node

# Default command for local runs (Jenkins can override in `docker run`)
CMD ["newman", "run", "E2E_Ecommerce.postman_collection.json", "-r", "cli"]
