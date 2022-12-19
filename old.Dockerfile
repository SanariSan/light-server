FROM node:16 as build
# RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
COPY --chown=root:root dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
WORKDIR /home/node/proj
COPY --chown=root:root package*.json yarn.lock ./
RUN yarn install --pure-lockfile --frozen-lockfile
COPY --chown=root:root . .
# RUN yarn build

FROM node:16 as prod_modules
WORKDIR /home/node/proj
COPY --chown=root:root package*.json yarn.lock ./
RUN yarn install --prod --pure-lockfile --frozen-lockfile

FROM node:16
WORKDIR /home/node/proj
COPY --chown=root:root --from=build /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --chown=root:root --from=build /home/node/proj ./
COPY --chown=root:root --from=prod_modules /home/node/proj/node_modules ./node_modules
COPY --chown=root:root package.json ./
COPY --chown=root:root .env ./
USER root
# avoid calling yarn script, instead call directly to obtain right pid and provide graceful shutdown
CMD ["dumb-init", "node", "./node_modules/cross-env/src/bin/cross-env.js", "NODE_ENV=production", "node", "-r", "dotenv/config", "./src/app.js"]