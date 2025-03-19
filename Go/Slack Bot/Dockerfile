FROM docker-mirror-io.domain.ru/golang:1.13.4-alpine AS build
ADD . /src
ENV GOPROXY=https://nexus.domain.ru/repository/go/
RUN cd /src && go build -o app

FROM docker-mirror-io.domain.ru/alpine
COPY --from=build /src/app /app
ENTRYPOINT /app