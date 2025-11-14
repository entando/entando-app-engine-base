#!/bin/bash
export CATALINA_OPTS="$CATALINA_OPTS -server"

##################
# JVM agent
##################
if ${AGENT_ENABLED:-false}; then
  export CATALINA_OPTS="$CATALINA_OPTS ${AGENT_OPTS}"
fi


##################
# JVM configs
##################
export CATALINA_OPTS="$CATALINA_OPTS -XshowSettings:vm"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE:-30.0}"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxMetaspaceSize=${MAX_METASPACE:-512m}"

GC_OPTS="${GC_OPTS:--XX:+UseG1GC -XX:MaxGCPauseMillis=500 -XX:+DisableExplicitGC}"
export CATALINA_OPTS="$CATALINA_OPTS ${GC_OPTS}"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseStringDeduplication"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+ParallelRefProcEnabled"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxTenuringThreshold=5"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+AlwaysPreTouch"

##################
# Tomcat configs
##################
export CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=${FILE_ENCODING:-UTF8}"
export CATALINA_OPTS="$CATALINA_OPTS -Duser.timezone=Europe/Rome"
export CATALINA_OPTS="$CATALINA_OPTS -DtomcatMaxThreads=${TOMCAT_MAX_THREADS:-300}"
export CATALINA_OPTS="$CATALINA_OPTS -DtomcatMaxHttpHeaderSize=${TOMCAT_MAX_HEADER_SIZE:-65536}"
export CATALINA_OPTS="$CATALINA_OPTS -DtomcatMaxPostSize=${TOMCAT_MAX_POST_SIZE:-209715200}"
export CATALINA_OPTS="$CATALINA_OPTS -DtomcatConnectionTimeout=${TOMCAT_CONN_TIMEOUT:-5000}"

if ${JMX_ENABLED:-false}; then
  JMX_OPTS=${JMX_OPTS:--Dcom.sun.management.jmxremote.rmi.port=9099 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Djava.rmi.server.hostname=localhost}    
  export CATALINA_OPTS="$CATALINA_OPTS ${JMX_OPTS}"
fi


##################
# DBs configs
##################
export CATALINA_OPTS="$CATALINA_OPTS -Dservdb.jndi='${SERVDB_JNDI}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dportdb.jndi='${PORTDB_JNDI}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dportdb.url='${PORTDB_URL}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dservdb.url='${SERVDB_URL}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dportdb.username='${PORTDB_USERNAME}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dservdb.username='${SERVDB_USERNAME}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dportdb.password='${PORTDB_PASSWORD}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dservdb.password='${SERVDB_PASSWORD}'"
export CATALINA_OPTS="$CATALINA_OPTS -Dprofile.database.driverClassName=${PORTDATASOURCECLASSNAME}"
export CATALINA_OPTS="$CATALINA_OPTS -Dportdb.driverClassName=${PORTDATASOURCECLASSNAME}"
export CATALINA_OPTS="$CATALINA_OPTS -Dservdb.driverClassName=${SERVDATASOURCECLASSNAME}"
export CATALINA_OPTS="$CATALINA_OPTS -DportDataSourceClassName=${PORTDATASOURCECLASSNAME}"
export CATALINA_OPTS="$CATALINA_OPTS -DservDataSourceClassName=${SERVDATASOURCECLASSNAME}"

##################
# Logs configs
##################
export LOG_LEVEL=${LOG_LEVEL:-INFO}
echo "LOG_LEVEL: $LOG_LEVEL"
export ROOT_LOG_LEVEL=${ROOT_LOG_LEVEL:-WARN}
echo "ROOT_LOG_LEVEL: $ROOT_LOG_LEVEL"
export CATALINA_OPTS="$CATALINA_OPTS -Dlogback.configurationFile='${LOG_CONFIG_FILE_PATH:-logback-default.xml}'"
export CATALINA_OPTS="$CATALINA_OPTS -DlogFilePrefix='${LOGFILEPREFIX}'"
export CATALINA_OPTS="$CATALINA_OPTS -DlogName='${LOGNAME}'"
export CATALINA_OPTS="$CATALINA_OPTS -DlogFileRotatePattern='${LOGFILEROTATEPATTERN}'"
export CATALINA_OPTS="$CATALINA_OPTS -DlogActiveFileOutput='${LOGACTIVEFILEOUTPUT}'"

##################
# Entando configs
##################
export CATALINA_OPTS="$CATALINA_OPTS -Dstatic.resources.cache=${STATIC_RESOURCES_CACHE_SIZE}"
export CATALINA_OPTS="$CATALINA_OPTS -Dentando.web.context=${ENTANDO_WEB_CONTEXT}"
export CATALINA_OPTS="$CATALINA_OPTS -DappBuilderIntegration=${APPBUILDERINTEGRATIONENABLED}"
export CATALINA_OPTS="$CATALINA_OPTS -DredisActive=${REDIS_ACTIVE}"
export CATALINA_OPTS="$CATALINA_OPTS -DredisAddress='${REDIS_ADDRESS}'"
export CATALINA_OPTS="$CATALINA_OPTS -DredisAddresses='${REDIS_ADDRESSES}'"
export CATALINA_OPTS="$CATALINA_OPTS -DSolarAddress='${SOLR_ADDRESS}'"
export CATALINA_OPTS="$CATALINA_OPTS -DresourceRootURL=${RESOURCEROOTURL}"
# manage if it's different from `/`(i.e: /portale)
if [[ "$ENTANDO_WEB_CONTEXT" = "/" ]] ; then
  export CATALINA_OPTS="$CATALINA_OPTS -DprotectedResourceRootURL=/protected/"
else
  export CATALINA_OPTS="$CATALINA_OPTS -DprotectedResourceRootURL=${ENTANDO_WEB_CONTEXT}/protected/"
fi
export CATALINA_OPTS="$CATALINA_OPTS -DresourceDiskRootFolder=/entando-data/resources/"
export CATALINA_OPTS="$CATALINA_OPTS -DprotectedResourceDiskRootFolder=/entando-data/protected/"
export CATALINA_OPTS="$CATALINA_OPTS -DindexDiskRootFolder=/entando-data/entando-indices"
export CATALINA_OPTS="$CATALINA_OPTS -Ddb.environment=production"
export CATALINA_OPTS="$CATALINA_OPTS -Dfile.upload.maxSize=${FILE_UPLOAD_MAX_SIZE:-52428800}"

##################
# CORS configs
##################
export CATALINA_OPTS="$CATALINA_OPTS -Dcors.enabled=${CORS_ENABLED:-true}"
export CATALINA_OPTS="$CATALINA_OPTS -Dcors.access.control.allow.origin=${CORS_ALLOW_ORIGIN:-*}"

##################
# Cookie SameSite policies / secure
##################
export CATALINA_OPTS="$CATALINA_OPTS -Ddefault.samesite.policy=${DEFAULT_SAMESITE_POLICY:-}"
export CATALINA_OPTS="$CATALINA_OPTS -Djsessionid.samesite.policy=${JSESSIONID_SAMESITE_POLICY:-Strict}"
export CATALINA_OPTS="$CATALINA_OPTS -Djsessionid.secure=${JSESSIONID_SECURE:-false}"