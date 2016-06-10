# ops_contrib

Scripts for [VersionEye](https://www.versioneye.com) operations. Everybody can contribute!

## Start backend services for VersionEye

VersionEye is currently using this backend systems:

  - MongoDB
  - RabbitMQ
  - ElasticSearch
  - Memcached

They are all available as Docker images from Docker Hub. There is a file `versioneye-base.yml`
for [Docker Compose](https://docs.docker.com/compose/).
Maybe you need to adjust the mount volumes for MongoDB and Elasticsearch in the `versioneye-base.yml`.
Then you can start all backend systems like this:

```
docker-compose -f versioneye-base.yml up -d
```

That will start all 4 Docker containers in deamon mode.

## Start the VersionEye containers

The next command will start the VersionEye containers. That includes the web application, the API and some background services: 

```
./versioneye-update
```

This script will: 

 - Fetch the newest versions for the Docker images from the VersionEye API
 - Set some environment variables
 - Pull down the Docker images from Docher Hub 
 - Start the Docker containers with docker-compose

If everything goes well you can access the VersionEye web application on `http://localhost:8080`. 
