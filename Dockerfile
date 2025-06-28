FROM node:lts-alpine3.19

ARG APP_HOME=/home/node/app

RUN apk add gcompat tini git jq curl

ENTRYPOINT [ "tini", "--" ]

WORKDIR ${APP_HOME}

ENV NODE_ENV=production

ENV fetch ""

ENV reverse_proxy ""

ENV proxy_password ""

ENV api_key_makersuite ""

ENV github_secret ""

ENV github_project ""


RUN git clone https://github.com/SillyTavern/SillyTavern.git --branch v1.13.0 .

RUN \
  echo "*** Install npm packages ***" && \
  npm install && npm cache clean --force

ADD launch.sh launch.sh
RUN curl -JLO  https://github.com/bincooo/SillyTavern-Docker/releases/download/v1.0.0/git-batch
RUN chmod +x launch.sh && chmod +x git-batch && ./git-batch -h

RUN \
  echo "*** Install npm packages ***" && \
  npm i --no-audit --no-fund --loglevel=error --no-progress --omit=dev && npm cache clean --force

RUN \
  rm -f "config.yaml" || true && \
  ln -s "./config/config.yaml" "config.yaml" || true && \
  mkdir "config" || true

RUN \
  echo "*** Cleanup ***" && \
  mv "./docker/docker-entrypoint.sh" "./" && \
  rm -rf "./docker" && \
  echo "*** Make docker-entrypoint.sh executable ***" && \
  chmod +x "./docker-entrypoint.sh" && \
  echo "*** Convert line endings to Unix format ***" && \
  dos2unix "./docker-entrypoint.sh"
RUN sed -i 's/# Start the server/.\/launch.sh env \&\& .\/launch.sh init/g' docker-entrypoint.sh
RUN chmod -R 777 ${APP_HOME}

EXPOSE 8000

CMD [ "./docker-entrypoint.sh" ]
