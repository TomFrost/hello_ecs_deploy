FROM mhart/alpine-node:6

COPY src /app/src/
COPY node_modules /app/node_modules/
COPY package.json /app/

WORKDIR /app
EXPOSE 8081

CMD ["node", "."]

