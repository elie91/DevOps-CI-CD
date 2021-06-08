FROM node:alpine

WORKDIR usr/app

# le fait de mettre ici une instruction COPY évite de relancer npm install à chaque modification de fichier du serveur
# c'est seulement si le package.json est modifié que le cache du container précédent sera invalidé et relancera la commande npm install
# si le cache d'une instruction a en effet était modifié, cela relance toutes les commandes dessous et ne prend pas la version caché
COPY ./package.json ./

RUN npm install

COPY ./ ./

CMD ["npm", "start"]
