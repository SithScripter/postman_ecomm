FROM node:18-alpine

WORKDIR /etc/newman

# Install Newman + HTML extra reporter
RUN npm install -g newman newman-reporter-htmlextra newman-reporter-allure

# Copy the collection and image file into the container
COPY E2E_Ecommerce.postman_collection.json .
COPY headerimage@2x.jpg .

# Set the default command for the container
ENTRYPOINT ["newman"]