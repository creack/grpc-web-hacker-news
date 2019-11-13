ARG NODE_BASE_I=node:10
FROM ${NODE_BASE_I}

WORKDIR /app

# Precompile the vendors.
ADD package.json yarn.lock /app/
RUN yarn install

# Add the code.
ADD . /app/

ENTRYPOINT ["yarn", "start"]
