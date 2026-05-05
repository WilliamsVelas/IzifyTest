# Etapa 1: Instalación de dependencias
FROM node:20-alpine AS deps
RUN apk add --no-cache python3 make g++
WORKDIR /app
COPY package*.json ./
RUN npm install

# Etapa 2: Construcción de la aplicación
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Etapa 3: Imagen final de producción
FROM node:20-alpine AS production
WORKDIR /app

# Re-instalamos solo dependencias de producción (necesario para módulos nativos en Alpine)
RUN apk add --no-cache python3 make g++
COPY package*.json ./
RUN npm install --only=production && npm cache clean --force

# Copiamos solo lo necesario desde la etapa de construcción
COPY --from=build /app/dist ./dist

# Seguridad: ejecutamos como usuario no privilegiado
RUN addgroup -S nodejs && adduser -S nodejs -G nodejs
USER nodejs

EXPOSE 3000
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
