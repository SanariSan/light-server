FROM node:16 as prod
COPY --chown=root:root dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
WORKDIR /home/node/proj
COPY --chown=root:root . .
RUN yarn install --prod --pure-lockfile --frozen-lockfile

FROM node:16

ARG HOST=0.0.0.0
ARG PORT=80
ENV HOST=$HOST
ENV PORT=$PORT

WORKDIR /home/node/proj
COPY --chown=root:root --from=prod /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --chown=root:root --from=prod /home/node/proj/ ./
USER root
# avoid calling yarn script, instead call directly to obtain right pid and provide graceful shutdown
CMD ["dumb-init", "node", "./node_modules/cross-env/src/bin/cross-env.js", "NODE_ENV=production", "HOST=${HOST}", "PORT=${PORT}", "node", "./src/app.js"]
# CMD ["dumb-init", "node", "./node_modules/cross-env/src/bin/cross-env.js", "NODE_ENV=production", "HOST=${HOST}", "PORT=${PORT}", "node", "-r", "dotenv/config", "./src/app.js"]
# CMD "/bin/bash"