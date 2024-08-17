FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/AlexNisnevich/untrusted.git && \
    cd untrusted && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git

FROM alpine AS build

WORKDIR /untrusted
COPY --from=base /git/untrusted .
RUN apk add make openjdk8-jre && \
    make release && \
    echo "cp -r \$2/ site" > deploy.sh && \
    chmod +x deploy.sh && \
    make deploy-full

FROM lipanski/docker-static-website

COPY --from=build /untrusted/site .
