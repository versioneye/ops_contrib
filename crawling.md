# Java Crawlers

This document describes how to run the Java crawlers to crawl external Maven repositories such as Maven Central, ConJars and many more. 

For the crawling of external Maven repositories 2 Docker images are needed: 

 - versioneye/crawlj_worker:2.4.17
 - versioneye/crawlj:2.4.44

The Docker image `versioneye/crawlj_worker` contains RabbitMQ consumers to process single pom.xml files. The consumers are running in an endless loop and waiting for messages from the RabbitMQ server. A typical message contains the URL to a pom.xml file. The consumer process is downloading and parsing the file, stores the results in the database and waits for the next message. 

The Docker image `versioneye/crawlj` contains the scheduler for the initial crawling processes. A typical crawling process, for example for Maven Central, is fetching the Maven index from a Maven repository and iterates through it. The process is checking on each entry if it exists already in the database or not. For entries which are new it sends a message with name and pom URL to RabbitMQ and moves on to the next entry. RabbitMQ consumers in another Docker container (`versioneye/crawlj_worker`) then can handle the hard work of parsing and storing. 

