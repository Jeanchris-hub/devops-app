# Utiliser l'image officielle Node.js
FROM node:20

# Définir le répertoire de travail
WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le reste de l'application
COPY . .

# Exposer le port sur lequel l'app va tourner
EXPOSE 3000

# Commande pour lancer l'application
CMD ["node", "server.js"]
