# Entando App Engine base Docker image

This repository provides a base Docker image for Apache Tomcat 10. This image is supposed to be inherited by child projects.

## Build locally

```bash
docker build -f Dockerfile.tomcat -t entando/entando-tomcat-base:<version> .
```

### Build with Apple M1

You can build linux/amd64 images with the help of `buildx` plugin (embedded in Docker Desktop)

```bash
# Build
docker buildx build --platform linux/amd64 -f Dockerfile.tomcat -t entando/entando-tomcat-base:<version> .

# Build and push to local registry
docker buildx build --platform linux/amd64 -f Dockerfile.tomcat -t entando/entando-tomcat-base:<version> --output type=docker .
```

# Environment variables

```
:PORTDB_URL: the full JDBC connection string used to connect to the Entando PORT database
:PORTDB_DATABASE: the name of the Entando PORT database that is created and hosted in the image
:PORTDB_JNDI: the full JNDI name where the Entando PORT datasource will be made available to the Entando Engine JEE application
:PORTDB_DRIVER: the name of the driver for the Entando PORT database as configured in the JEE application server
:PORTDB_USERNAME: the username of the user that has read/write access to the Entando PORT database
:PORTDB_PASSWORD: the password of the above-mentioned username.
:PORTDB_SERVICE_HOST: the name of the server that hosts the Entando PORT database.
:PORTDB_SERVICE_PORT: the port on the above-mentioned server that serves the Entando PORT database. Generally we keep to the default port for each RDBMS, e.g. for PostgreSQL it is 5432
:SERVDB_URL: the full JDBC connection string used to connect to the Entando SERV database
:SERVDB_DATABASE: the name of the Entando SERV database that is created and hosted in the image
:SERVDB_JNDI: the full JNDI name where the Entando SERV datasource will be made available to the Entando Engine JEE application
:SERVDB_DRIVER: the name of the driver for the Entando SERV database as configured in the JEE application server
:SERVDB_USERNAME: the username of the user that has read/write access to the Entando SERV database. For compatibility with mvn jetty:run, please keep this the same as PORTDB_USERNAME
:SERVDB_PASSWORD: the password of the above-mentioned username. For compatibility with mvn jetty:run, please keep this the same as PORTDB_PASSWORD
:SERVDB_SERVICE_HOST: the name of the server that hosts the Entando SERV database
:SERVDB_SERVICE_PORT: the port on the above-mentioned server that serves the Entando SERV database. Generally we keep to the default port for each RDBMS, e.g. for PostgreSQL it is 5432
:ADMIN_USERNAME: the username of a user that has admin rights on both the SERV and PORT databases. For compatibility with Postgresql, keep this value to 'postgres'
:ADMIN_PASSWORD: the password of the above-mentioned username.
:ENTANDO_OIDC_ACTIVE: set this variable's value to "true" to activate Entando's Open ID Connect and the related OAuth authentication infrastructure. If set to "false" all the subsequent OIDC variables will be ignored. Once activated, you may need to log into Entando using the following url: <application_base_url>/<lang_code>/<any_public_page_code>.page?username=<MY_USERNAME>&password=<MY_PASSWORD>
:ENTANDO_OIDC_AUTH_LOCATION: the URL of the authentication service, e.g. the 'login page' that Entando needs to redirect the user to in order to allow the OAuth provider to authenticate the user.
:ENTANDO_OIDC_TOKEN_LOCATION: the URL of the token service where Entando can retrieve the OAuth token from after authentication
:ENTANDO_OIDC_CLIENT_ID: the Client ID that uniquely identifies the Entando App in the OAuth provider's configuration
:ENTANDO_OIDC_REDIRECT_BASE_URL: the optional base URL, typically the protocol, host and port (https://some.host.com:8080/) that will be prepended to the path segment of the URL requested by the user and provided as a redirect URL to the OAuth provider. If empty, the requested URL will be used as is.
:DOMAIN: the HTTP URL on which the associated Entando Engine instance will be served
:CLIENT_SECRET: the secret associated with the 'appbuilder' Oauth Client ID in the Entando OAuth infrastructure.
:PORT_8080: the port for the HTTP service hosted by the Tomcat Servlet Container
```