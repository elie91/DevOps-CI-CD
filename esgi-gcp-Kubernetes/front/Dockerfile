# First stage, build the application
FROM node:alpine as build
WORKDIR /app
COPY package*.json ./
RUN yarn install
COPY . .

# Second stage, copy the artifacts in a new stage and
# build the image
FROM nginx
EXPOSE 3000
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]