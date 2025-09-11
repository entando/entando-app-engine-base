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
      JETTY_VERSION=10.0.7
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


cp /jetty-runner/jetty.xml .
# Running without -jar option in order to add SLF4J classes to the classpath and actually see Jetty logs
export JETTY_COMMAND="java -cp "/jetty-runner/*" \
    -Ddb.migration.strategy=auto \
    -Ddb.startup.check=true \
    -Ddb.restore.enabled=true \
    -Dentando.web.context="${ENTANDO_WEB_CONTEXT}" \
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
    org.eclipse.jetty.runner.Runner \
    --lib /jetty-runner . jetty.xml"
