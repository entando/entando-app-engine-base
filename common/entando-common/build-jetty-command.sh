#!/usr/bin/env bash
#NB!!! This file is copied from common/s2i in the Docker build hook. Only modify the original file!
source $(dirname ${BASH_SOURCE[0]})/translate-jboss-variables.sh
for i in "$@"
do
  case $i in
    --jetty-version=*)
      JETTY_VERSION="${i#*=}"
      shift # past argument=value
    ;;
    --war-file=*)
      WAR_FILE="${i#*=}"
      shift # past argument=value
    ;;
    *)
    echo "Unknown option: $i"
    exit -1
  esac
done
#Ensure that a JETTY_VERSION is set, and that the associated JAR file is in the jetty-runner directory
if [ -z "$JETTY_VERSION" ]; then
  case $ENTANDO_VERSION in
    5.0.2*)
      JETTY_VERSION=9.4.8.v20180619
    ;;
    5.0.3*)
      JETTY_VERSION=9.4.8.v20180619
    ;;
    *)
      JETTY_VERSION=12.0.27
    ;;
  esac
fi
#Try best to find a WAR file
if [ -z "$WAR_FILE" ]; then
  if [ -z "$DEPLOYMENTS_DIR" ]; then
    echo "No WAR file specified and no DEPLOYMENTS_DIR environment variable"
    exit 1
  else
    WARS="$(dir $DEPLOYMENTS_DIR/*.war)"
    if [ ${#WARS[@]} = 0 ]; then
      echo "No WAR file specified and no WAR files found in ${DEPLOYMENTS_DIR}"
      exit 2
    else
      WAR_FILE=${WARS[0]}
    fi
  fi
fi
#TODO check if this is still necessary - it is in translate-jboss-variables.sh
if [ -z "$ENTANDO_WEB_CONTEXT" ]; then
  ENTANDO_WEB_CONTEXT="${WAR_FILE%.war}"
  while [[ "$ENTANDO_WEB_CONTEXT" == *"/"* ]] ; do
    ENTANDO_WEB_CONTEXT=${ENTANDO_WEB_CONTEXT#*/}
  done
  ENTANDO_WEB_CONTEXT="/${ENTANDO_WEB_CONTEXT}"
fi

mkdir -p /tmp/entando-db-build
pushd /tmp/entando-db-build

#Copy resources and backups to the place that the WAR file expects them to be
jar -xf $WAR_FILE
cp -Rf resources /entando-data/
cp -Rf protected /entando-data/


# Use Jetty Home 12 with proper configuration
export JETTY_HOME=/jetty-home
export JETTY_BASE=/tmp/entando-jetty-base

# Create Jetty base directory structure
mkdir -p $JETTY_BASE/{webapps,lib,etc,resources}

# Copy the exploded WAR as ROOT webapp (will be deployed at /)
cp -r /tmp/entando-db-build $JETTY_BASE/webapps/ROOT

# Copy JDBC drivers to webapp lib so they're available to the application
cp /jetty-runner/derby*.jar $JETTY_BASE/webapps/ROOT/WEB-INF/lib/
cp /jetty-runner/postgresql.jar $JETTY_BASE/webapps/ROOT/WEB-INF/lib/
cp /jetty-runner/mysql-connector-java.jar $JETTY_BASE/webapps/ROOT/WEB-INF/lib/
cp /jetty-runner/ojdbc8.jar $JETTY_BASE/webapps/ROOT/WEB-INF/lib/

# Copy additional libraries needed for JNDI datasources to Jetty base lib
cp /jetty-runner/*.jar $JETTY_BASE/lib/

# Copy the existing jetty.xml configuration file as jetty-web.xml for the webapp
cp /jetty-runner/jetty.xml $JETTY_BASE/webapps/ROOT/WEB-INF/jetty-web.xml

# Create jetty base start configuration
cat > $JETTY_BASE/start.ini << 'INI_EOF'
--module=server
--module=http
--module=ee10-deploy
--module=ee10-webapp
--module=ee10-plus
--module=ee10-annotations
--module=ee10-jsp
jetty.http.port=8080
INI_EOF

# Build Jetty command directly like the old version
export JETTY_COMMAND="java \
    -Djetty.home=/jetty-home \
    -Djetty.base=/tmp/entando-jetty-base \
    -Ddb.migration.strategy=auto \
    -Ddb.restore.enabled=true \
    -Dentando.web.context=${ENTANDO_WEB_CONTEXT} \
    -Dprofile.datasource.jndiname.servdb=${SERVDB_JNDI} \
    -Dprofile.datasource.jndiname.portdb=${PORTDB_JNDI} \
    -Dprofile.database.url.portdb=${PORTDB_URL} \
    -Dprofile.database.url.servdb=${SERVDB_URL} \
    -Dprofile.database.username.portdb=${PORTDB_USERNAME} \
    -Dprofile.database.username.servdb=${SERVDB_USERNAME} \
    -Dprofile.database.password.portdb=${PORTDB_PASSWORD} \
    -Dprofile.database.password.servdb=${SERVDB_PASSWORD} \
    -Dprofile.database.driverClassName=$($(dirname ${BASH_SOURCE[0]})/determine-driver.sh $PORTDB_DRIVER) \
    -Dprofile.portDataSourceClassName=$($(dirname ${BASH_SOURCE[0]})/determine-driver.sh $PORTDB_DRIVER) \
    -Dprofile.servDataSourceClassName=$($(dirname ${BASH_SOURCE[0]})/determine-driver.sh $SERVDB_DRIVER) \
    -DportDataSourceClassName=$($(dirname ${BASH_SOURCE[0]})/determine-driver.sh $PORTDB_DRIVER) \
    -DservDataSourceClassName=$($(dirname ${BASH_SOURCE[0]})/determine-driver.sh $SERVDB_DRIVER) \
    -DlogFilePrefix=/tmp/entando-logs \
    -DlogName=/tmp/entando-logs/entando.log \
    -DresourceRootURL=${ENTANDO_WEB_CONTEXT}/resources/ \
    -DprotectedResourceRootURL=${ENTANDO_WEB_CONTEXT}/protected/ \
    -DresourceDiskRootFolder=/entando-data/resources/ \
    -DprotectedResourceDiskRootFolder=/entando-data/protected/ \
    -DindexDiskRootFolder=/tmp/entando-indices \
    -jar /jetty-home/start.jar"
