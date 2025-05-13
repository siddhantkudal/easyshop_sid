FROM node:18 AS builder
WORKDIR /app
COPY ../package.json ../package-lock.json .

COPY ../scripts ./scripts
COPY ../.db ./.db

RUN npm install

CMD ["npm", "run", "migrate"]

