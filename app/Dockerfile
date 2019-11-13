FROM node:10

WORKDIR /app

# Precompile the vendors.
ADD package.json yarn.lock package-lock.json /app/
RUN yarn install

# Add the code.
ADD . /app/

ENTRYPOINT ["yarn", "start"]
