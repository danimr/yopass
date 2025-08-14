FROM golang:bookworm AS app
RUN mkdir -p /yopass
WORKDIR /yopass
COPY . .
RUN go build ./cmd/yopass && go build ./cmd/yopass-server

FROM node:22 AS website
# Add build argument for features
ARG YOPASS_DISABLE_FEATURES_CARDS=1
# Set environment variable for the build process
ENV YOPASS_DISABLE_FEATURES_CARDS=$YOPASS_DISABLE_FEATURES_CARDS

COPY website /website
WORKDIR /website
# Add cache busting and ensure clean install
RUN rm -rf node_modules package-lock.json
RUN yarn cache clean
RUN yarn install --network-timeout 600000 --frozen-lockfile && yarn build

FROM gcr.io/distroless/base
COPY --from=app /yopass/yopass /yopass/yopass-server /
COPY --from=website /website/build /public
ENTRYPOINT ["/yopass-server"]
