FROM node:16 as build
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
RUN chmod +x /usr/local/bin/dumb-init
WORKDIR /usr/project
COPY --chown=node:node package*.json yarn.lock ./
RUN yarn install --pure-lockfile --frozen-lockfile
COPY --chown=node:node . .
# RUN yarn build

FROM node:16 as prod_modules
WORKDIR /usr/project
COPY --chown=node:node package*.json yarn.lock ./
RUN yarn install --prod --pure-lockfile --frozen-lockfile

FROM node:16
WORKDIR /usr/project
COPY --chown=node:node --from=build /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --chown=node:node --from=build /usr/project ./
COPY --chown=node:node --from=prod_modules /usr/project/node_modules ./node_modules
COPY --chown=node:node package.json ./
COPY --chown=node:node .env ./
USER node
# avoid calling yarn script, instead call directly to obtain right pid and provide graceful shutdown
CMD ["dumb-init", "node", "./node_modules/cross-env/src/bin/cross-env.js", "NODE_ENV=production", "node", "-r", "dotenv/config", "./src/app.js"]