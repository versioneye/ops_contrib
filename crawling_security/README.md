# Security Crawlers

This document describes how to run the security crawlers to crawl security vulnerabilities from external resources.

For the security crawling this Docker image is needed:

 - versioneye/security:0.11.13

The same Docker image is started with 2 different configurations for supervisord.
Supervisord is the master process and is managing other processes inside of the container.

## Start the consumers

The consumer processes can be started like this:

```
docker run --name security_workers --restart=always --env RAILS_ENV=enterprise --link mongodb:db --link elasticsearch:es --link memcached:mc --link rabbitmq:rm -v /mnt/logs:/app/log -v /opt/docker_security_worker/supervisord_workers.conf:/etc/supervisord.conf -d versioneye/security:0.11.13
```

Make sure that you adjust the path to `supervisord_workers.conf` and to the logs. That is mandatory!

This container will run multiple RabbitMQ consumers. A consumer is waiting for a message from RabbitMQ to process it. A typical message for a security consumer would be an URL to a yml file for example, where the file contains information about a security vulnerability.

## Start the producers

The producers can be started like this:

```
docker run --name security_scheduler --restart=always --env RAILS_ENV=enterprise --link mongodb:db --link memcached:mc --link rabbitmq:rm -v /mnt/logs:/app/log -v /opt/docker_security_worker/supervisord_scheduler.conf:/etc/supervisord.conf -d versioneye/security:0.11.13
```

Make sure that you adjust the path to `supervisord_scheduler.conf` and to the logs. **That is mandatory!**

This Docker containers contains a Rufus scheduler which is triggering the security crawls every hour.
The initial security crawl processes are fetching an index and iterating through it. For every new security vulnerability they send a message to RabbitMQ and on the other side the security consumers can handle the heavy parsing & storing work.
