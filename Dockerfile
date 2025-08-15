# Step 1: Start from the official Node.js image
FROM node:18-alpine

# Step 2: Set the working directory
WORKDIR /etc/newman

# Step 3 (NEW): Install 'curl' and download a placeholder image.
# This saves the image with the exact name your Postman collection expects.
RUN apk add --no-cache curl && \
    curl -L -o headerimage@2x.jpg "https://via.placeholder.com/200"

# Step 4: Install Newman and the reporter
RUN npm install -g newman newman-reporter-htmlextra

# Step 5: Copy your local files (like the collection.json) into the container
COPY . .

# Step 6: Set the default command for the container
ENTRYPOINT ["newman"]