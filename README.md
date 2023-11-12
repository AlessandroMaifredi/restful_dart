# RestfulDart by Alessandro Maifredi 851610 #

This project aims to provide a Restful API for managing a simple database for volleyball players.

The architecture is quite small and it is composed by two services:
- The web server exposing the API
- The MySql server

The project uses docker-compose to create two different containers,one for each of the services.

## Web Server

The web server is built in Dart using the [Shelf](https://pub.dev/packages/shelf) package. 
The inside architecture is straightforward.
There's a server file that functions as the entry point of the app, and then there are three main components:
- The DbDriver
- The RootApi
- The PlayersApi

The RootApi manages the calls to the root route
"/" returning the 
link to the swagger of the app.

The PlayersApi component uses the repository pattern to provide access to the database through the DbDriver component, and manages the calls to the various URIs such as "/api/v1/players/".

For simplicity of development, the server does not handle all of the possible erroneous conditions, and so it uses quite often the 500 error code response. Please see the documentation for better understanding of which conditions are explicitly handled.

The complete documentation of the APIs can be found at [swagger](https://app.swaggerhub.com/apis-docs/AMAIFREDI/RestfulDart/0.0.1-oas3.1)

### MySql server

The MySql server uses the official Docker Hub MySql image to expose the database. 
See the docker-compose file for more information about it's configuration.

## The Docker-compose configuraion

As mentioned above the project uses two different services, the database and the api.

The API service use the dockerfile contained in the root folder of the project to build the server.
The build is divided in two stages, the first one uses the official Dart image to compile the server,
 the second one uses the official Alpine image to build the minimal serving image.
Originally the second stage used the scratch image, but for debugging purposes I changed it to the Alpine image.
The api exposes the port 8080 to the host machine.
```dockerfile
# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM alpine:latest
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
```
For more info about the dockerfile see the [Shelf](https://pub.dev/packages/shelf) package documentation.

To talk to each-other the two services share a network (bridge driver) called backend-net.

The MySql server uses a volume (mysql-volume) to persist data.

The API uses two environment variables to set the default values to use for paginating results.

The project has the capability to use two files that contains the credentials for the root user of MySql, passing them to some environment variables through the secret feature of docker-compose. 
The files need to be created in the secrets folder inside the root directory of the project. If you don't want to change the docker-compose file, create the two files using the following names: "db_user.txt" and "db_password.txt".
The api service uses explicit environment variables to set the credentials for the user that the server uses to connect to the database.
If you want you can explicitly set the credentials for the root user of MySql using the environment variables MYSQL_ROOT_PASSWORD, MYSQL_USER and MYSQL_PASSWORD.

To wait for the MySql server to be up and running the api service uses the depends_on feature of docker-compose, and the condition service_healthy.
The healthcheck of the MySql server is set to wait for the server to be up and running before returning a healthy status, and uses the mysqladmin command to ping the server.
To avoid false positives from the ping command, the healthcheck searches for the string "mysqld is alive" in the output of the command.
Furthermore the deployment configuration of the Api service enables the server to restart until the Mysql server is up and running.

```yaml
services:
  database:
    image: mysql:latest
    container_name: database
    ports:
      - "3306:3306"
      - "33060:33060"
    environment:
        - MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_password
        - MYSQL_DATABASE=restfuldart
        - MYSQL_USER_FILE=/run/secrets/db_user
        - MYSQL_PASSWORD_FILE=/run/secrets/db_password
    command: ["--default-authentication-plugin=mysql_native_password"]
    healthcheck:
      test: out=$$(mysqladmin ping -h localhost -P 3306 -u root --password=$$(cat $${MYSQL_ROOT_PASSWORD_FILE}) 2>&1); echo $$out | grep 'mysqld is alive' || { echo $$out; exit 1; }
      retries: 60
      interval: 5s
    volumes:
      - mysql-volume:/var/lib/mysql
    networks:
      backend-net:
        aliases:
          - mysql
    secrets:
        - db_user
        - db_password

  api:
    build: .
    container_name: api
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
    environment:
      - PORT=8080
      - API_QUERIES_LIMIT=100
      - API_QUERIES_PAGE=1
      - MYSQL_HOST=mysql
      - MYSQL_PORT=3306
      - MYSQL_USER=alessandromaifredi
      - MYSQL_PASSWORD=851610
    ports:
      - "8080:8080"
    depends_on:
      database:
        condition: service_healthy
        required: true
        restart: true
    networks:
      backend-net:
        aliases:
          - api
    secrets:
        - db_user
        - db_password

networks:
  backend-net:
    driver: bridge

secrets:
  db_user:
    file: ./secrets/db_user.txt
  db_password:
    file: ./secrets/db_password.txt

volumes:
    mysql-volume:
```

## Running the project with Docker-compose 

Just use the docker-compose up command from the root directory of the project.