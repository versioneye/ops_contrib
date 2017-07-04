#!/bin/bash

set +e
keytool -delete -alias versioneye -storepass changeit -noprompt -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts || true
keytool -import -alias versioneye -storepass changeit -noprompt -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -file /certs/www.versioneye.com
set -e

/usr/bin/supervisord
