FROM node:alpine AS builder
WORKDIR /api
COPY /api/package.json ./
RUN npm install --production
COPY /api .

# Étape finale : image légère pour exécuter l'application
# Image plus légère de ~25MB car on transfère uniquement les fichiers nécessaires, pas le cache d'installation
# De plus, moins d'instructions Docker = moins de layers, donc image plus légère
FROM node:alpine
WORKDIR /api

# .dockerignore exclut les fichiers inutiles, donc on peut copier tout le contenu du builder
COPY --from=builder /api ./ 

EXPOSE 3000
CMD ["npm", "start"]