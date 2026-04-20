# Stage 1: Build
FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Stage 2: Runtime (minimal image)
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080

CMD ["/app/bin/server"]
