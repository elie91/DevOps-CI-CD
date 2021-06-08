# builder phase
FROM node:alpine
WORKDIR /app
COPY package.json .
RUN yarn install
COPY . .
RUN yarn build

# run phase
FROM nginx

# cette instruction n'expose pas réellement le port sur notre environnement local
# on doit toujours le spécifier dans le docker run
# mais AWS lui, regarde cette instruction, et map directement le port listé 
EXPOSE 80

# copy from the builder phase
COPY --from=0 /app/build /usr/share/nginx/html

# the default nginx container start the server automaticaly