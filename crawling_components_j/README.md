# Java Crawlers

This document describes how to run the Java crawlers to crawl external Maven repositories such as Maven Central, ConJars and many more.

For the crawling of external Maven repositories 2 Docker images are needed:

 - versioneye/crawlj_worker:2.4.20
 - versioneye/crawlj:2.4.49

The Docker image `versioneye/crawlj_worker` contains RabbitMQ consumers to process single pom.xml files. The consumers are running in an endless loop and waiting for messages from the RabbitMQ server. A typical message contains the URL to a pom.xml file. The consumer process is downloading and parsing the file, stores the results in the database and waits for the next message. The consumer processes can be scaled out in high numbers on multiple servers to speed up the crawling.

The Docker image `versioneye/crawlj` contains the scheduler for the initial crawling processes. A typical crawling process, for example for Maven Central, is fetching the Maven index from a Maven repository and iterates through it. The process is checking on each entry if it exists already in the database or not. For entries which are new it sends a message with name and URL to RabbitMQ and moves on to the next entry. RabbitMQ consumers in another Docker container (`versioneye/crawlj_worker`), and even different hardware servers, then can handle the hard work of parsing and storing.

## Start the containers

There is a `docker-compose.yml` file in this directory which
describes the stack for the Java crawlers.

**It is absolutely mandatory the the paths for the volumes are adjusted before the start!
Commenting out the volumes section will lead to errors!**

First of all adjust the path to a log directory on the host.
Volume paths on Docker follow this structure:

```
volumes:
   - PATH_ON_THE_HOST:PATH_INSIDE_OF_THE_DOCKER_CONTAINER
```

For example:

```
volumes:
   - /mnt/logs:/mnt/logs
```

Make sure that the directory `/mnt/logs` exist on your host or adjust it to another existing directory.

For the `crawlj_scheduler_ext` Container it is absolutely mandatory that the `crontab_enterprise` file from this directory is mounted. Mounting files into a Docker Container works only with absolute paths. Adjust the path to your `crawlj_scheduler_ext` file on the host system:

```
volumes:
   - /mnt/logs:/mnt/logs
   - /mnt/crontab_enterprise:/mnt/crawl_j/crontab_enterprise
```

If all paths are adjusted the stack can be started like this: 

```
docker-compose up -d
```

That should bring up two new containers successfully and `docker ps -a` should look similar to this output: 

```
CONTAINER ID        IMAGE                                  COMMAND                  CREATED             STATUS              PORTS                                 NAMES
54a2630fd378        versioneye/crawlj_worker:2.4.20        "/usr/bin/supervisord"   39 seconds ago      Up 42 seconds                                             crawlingcomponentsj_crawlj_worker_ext_1
177ba6f4d858        versioneye/crawlj:2.4.49               "/bin/sh -c /mnt/cra…"   39 seconds ago      Up 42 seconds                                             crawlj_scheduler_ext
e3366d5ede56        versioneye/mongodb:3.4.6               "/bin/sh -c /start_m…"   4 hours ago         Up 4 hours          0.0.0.0:27017->27017/tcp, 28017/tcp   mongodb
5aab78a566e3        reiz/elasticsearch:0.9.1-1             "/bin/sh -c '/elasti…"   4 hours ago         Up 17 minutes       0.0.0.0:9200->9200/tcp, 9300/tcp      elasticsearch
bc78ddb5be51        versioneye/rabbitmq:3.6.10-1           "/bin/sh -c rabbitmq…"   4 hours ago         Up 4 hours          0.0.0.0:5672->5672/tcp                rabbitmq
1c763e7c4a1d        versioneye/memcached:1.4.33-1ubuntu2   "/bin/sh -c '/usr/bi…"   4 hours ago         Up 4 hours          0.0.0.0:11211->11211/tcp              memcached
```

The `crawlingcomponentsj_crawlj_worker_ext_1` Container should run 8 Java processes. 4 HTML consumers and 4 Index consumers. The processes are controlled by supervisord. The command `docker logs -f crawlingcomponentsj_crawlj_worker_ext_1` should output something like this: 

```
2017-11-26 13:37:51,669 CRIT Supervisor running as root (no user in config file)
2017-11-26 13:37:51,674 INFO supervisord started with pid 1
2017-11-26 13:37:52,678 INFO spawned: 'html_worker_01' with pid 8
2017-11-26 13:37:52,680 INFO spawned: 'html_worker_00' with pid 9
2017-11-26 13:37:52,683 INFO spawned: 'html_worker_03' with pid 10
2017-11-26 13:37:52,685 INFO spawned: 'html_worker_02' with pid 11
2017-11-26 13:37:52,687 INFO spawned: 'index_worker_03' with pid 15
2017-11-26 13:37:52,688 INFO spawned: 'index_worker_02' with pid 16
2017-11-26 13:37:52,689 INFO spawned: 'index_worker_01' with pid 19
2017-11-26 13:37:52,690 INFO spawned: 'index_worker_00' with pid 21
2017-11-26 13:37:53,703 INFO success: html_worker_01 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,703 INFO success: html_worker_00 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,703 INFO success: html_worker_03 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,704 INFO success: html_worker_02 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,704 INFO success: index_worker_03 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,704 INFO success: index_worker_02 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,704 INFO success: index_worker_01 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2017-11-26 13:37:53,704 INFO success: index_worker_00 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

Now we know that the workers (RabbitMQ consumers) are up and running. 
They are waiting for input. 

The command `docker logs -f crawlj_scheduler_ext` should output something like this: 

```
VersionEye CrawlJ cron job is running
VersionEye CrawlJ cron job is running
```

Inside of the `crawlj_scheduler_ext` Container a cron job is running 
which triggers the crawls regulary, according to the crontab file we 
mounted into the Container. 

## Start the producers manually (optional)

In the Docker container there are several cron jobs which are starting the Java crawling processes. If you want to start the crawling process immediately, get a bash on the running container:

```
docker exec -it crawlj_scheduler_ext bash
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

## Scale the workers

The workers (RabbitMQ consumers) can be scaled up via docker-compose. 
Let's say the crawling process is too slow for us and we want to speed up
everything. In that case we could run:

```
docker-compose scale crawlj_worker_ext=5
```

That would start 5 instances of the `crawlingcomponentsj_crawlj_worker_ext_X` Container. In that case we would have 5 times more workers than by default. 
Keep in mind that by doing that more hardware resources are needed/consumed. 


