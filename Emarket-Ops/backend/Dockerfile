FROM node:18.20.4-bullseye AS base
WORKDIR /app
COPY package*.json ./
RUN npm install --silent
COPY . .

FROM base as test
WORKDIR /app
CMD ["tail", "-f", "/dev/null"]

FROM base as develop
WORKDIR /app
ENTRYPOINT ["npm", "start"]

FROM node:18-alpine as production
WORKDIR /app
RUN npm install -g pm2
COPY package*.json ./
RUN npm install --production --silent
COPY . .
# RUN chown -R node:node /app
# USER node
ENTRYPOINT ["pm2-runtime", "ecosystem.config.js", "--env", "production"]
