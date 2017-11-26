# Java Crawlers

This document describes how to run the Java crawlers to crawl external Maven repositories such as Maven Central, ConJars and many more.

For the crawling of external Maven repositories 2 Docker images are needed:

 - versioneye/crawlj_worker:2.4.17
 - versioneye/crawlj:2.4.44

The Docker image `versioneye/crawlj_worker` contains RabbitMQ consumers to process single pom.xml files. The consumers are running in an endless loop and waiting for messages from the RabbitMQ server. A typical message contains the URL to a pom.xml file. The consumer process is downloading and parsing the file, stores the results in the database and waits for the next message. The consumer processes can be scaled out in high numbers on multiple servers to speed up the crawling.

The Docker image `versioneye/crawlj` contains the scheduler for the initial crawling processes. A typical crawling process, for example for Maven Central, is fetching the Maven index from a Maven repository and iterates through it. The process is checking on each entry if it exists already in the database or not. For entries which are new it sends a message with name and URL to RabbitMQ and moves on to the next entry. RabbitMQ consumers in another Docker container (`versioneye/crawlj_worker`), and even different hardware servers, then can handle the hard work of parsing and storing.

## Start the consumers

The consumer processes can be started like this:

```
docker run --name crawlj_worker_ext --restart=always --link mongodb:db --link elasticsearch:es --link memcached:mc --link rabbitmq:rm -v /mnt logs:/mnt/logs -d versioneye/crawlj_worker:2.4.17
```

That should start a Docker container with 8 Java processes. 4 HTML consumers and 4 Index consumers. The processes are controlled by supervisord.

It is mandatory that a directory is mounted into `/mnt/logs`. If that directory doesn't exist the Java process will exit with an error code.

## Start the producers

The producers can be started like this:

```
docker run --name crawlj_ext --restart=always --link mongodb:db --link memcached:mc --link rabbitmq:rm -v /mnt/logs:/mnt/logs -v /mnt/crontab_enterprise:/mnt/crawl_j/crontab_enterprise -d versioneye/crawlj:2.4.44
```

The file `/mnt/crontab_enterprise` is the `crontab_enterprise` file from this directory.

It is mandatory that a directory is mounted into `/mnt/logs`. If that directory doesn't exist the Java process will exit with an error code.

In the Docker container there are several cron jobs which are starting the Java crawling processes. If you want to start the crawling process immediately, get a bash on the running container:

```
docker exec -it crawlj_ext bash
```

And take a look to the cron jobs:

```
crontab -l
```

You can start the Maven Central crawler immediately with this command, insode of the running Docker container:

```
M2=/opt/apache-maven-3.0.5/bin && M2_HOME=/opt/apache-maven-3.0.5 && /opt/apache-maven-3.0.5/bin/mvn -f /mnt/maven-indexer/pom.xml crawl:central
```

In parallel you can check the log files on the host to see the current status.
