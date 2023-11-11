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

The complete documentation of the APIs can be found at [swagger]()

### MySql server

The MySql server uses the official Docker Hub MySql image to expose the database. 
See the docker-compose file for more information about it's configuration.

## The Docker-compose configuraion

As mentioned above the project uses two different services, the database and the api.

The API service use the dockerfile contained in the root folder of the project to build the server. For more info about the dockerfile see the [Shelf](https://pub.dev/packages/shelf)  package documentation.

To talk to eachother the two services share a network (bridge driver) called backend-net.

The MySql server uses a volume (mysql-volume) to persist data.

The API uses two environment variables to set the default values to use for paginating results.

The project has the capability to use two files  that contains the credentials for the root user of MySql, passing them to some environment variables through the secret feature of docker-compose. The files need to be created in the secrets folder inside the root directory of the project. If you don't want to change the docker-compose file, create the two files using the following names: "db_user.txt" and "db_password.txt".

The deployment configuration of the Api service enables the server to restart until the Mysql server is up and running.



```
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
      restart_policy:
        condition: on-failure
        delay: 5s
    environment:
      - PORT=8080
      - API_QUERIES_LIMIT=100
      - API_QUERIES_PAGE=1
      - MYSQL_HOST=mysql
      - MYSQL_PORT=3306
      - MYSQL_USER_FILE=/run/secrets/db_user
      - MYSQL_PASSWORD_FILE=/run/secrets/db_password
    ports:
      - "8080:8080"
    depends_on:
      - database
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