FROM node:18.20.4-bullseye as base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

FROM base as build-develop
WORKDIR /app
RUN sed -i 's|baseURL: .*$|baseURL: "http://139.59.229.65:8081",|' /app/src/services/Api.js
RUN npm run build

FROM base as build-staging
WORKDIR /app
RUN sed -i 's|baseURL: .*$|baseURL: "https://staging.thienvuvan.shop",|' /app/src/services/Api.js
RUN npm run build

FROM base as build-production
WORKDIR /app
RUN sed -i 's|baseURL: .*$|baseURL: "https://thienvuvan.shop",|' /app/src/services/Api.js
RUN npm run build

FROM nginx:stable as develop
COPY --from=build-develop /app/dist/ /usr/share/nginx/html/
COPY ./default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

FROM nginx:stable as staging
COPY --from=build-staging /app/dist/ /usr/share/nginx/html/
COPY ./default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

FROM nginx:stable as production
COPY --from=build-production /app/dist/ /usr/share/nginx/html/
COPY ./default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

# FROM nginx:stable as production
# RUN useradd -u 1001 emark
# RUN mkdir -p /var/cache/nginx/client_temp && chown -R emark:emark /var/cache/nginx
# RUN mkdir -p /var/run/ && chown -R emark:emark /var/run/
# COPY --chown=emark:emark --from=build-production /app/dist/ /usr/share/nginx/html/
# COPY --chown=emark:emark ./default.conf /etc/nginx/conf.d/default.conf
# USER emark
# CMD ["nginx", "-g", "daemon off;"]

