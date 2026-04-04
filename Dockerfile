FROM node:alpine AS builder
WORKDIR /api
COPY /api/package.json ./
RUN npm install --production
COPY /api .

# Étape finale : image légère pour exécuter l'application
FROM node:alpine
WORKDIR /api

# .dockerignore exclut les fichiers inutiles, donc on peut copier tout le contenu du builder
COPY --from=builder /api ./ 

EXPOSE 3000
CMD ["npm", "start"]