FROM golang:bookworm AS app
RUN mkdir -p /yopass
WORKDIR /yopass
COPY . .
RUN go build ./cmd/yopass && go build ./cmd/yopass-server

FROM node:22 AS website
COPY website /website
WORKDIR /website
# Add cache busting and ensure clean install
RUN rm -rf node_modules package-lock.json
RUN yarn cache clean
RUN yarn install --network-timeout 600000 --frozen-lockfile && yarn build

# Set environment variable to disable features
ENV YOPASS_DISABLE_FEATURES_CARDS=1

FROM gcr.io/distroless/base
COPY --from=app /yopass/yopass /yopass/yopass-server /
COPY --from=website /website/build /public
ENV YOPASS_DISABLE_FEATURES_CARDS=1
ENTRYPOINT ["/yopass-server"]
