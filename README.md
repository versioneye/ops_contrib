# ops_contrib

Scripts for [VersionEye](https://www.versioneye.com) operations. Everybody can contribute!

# Start backend services for VersionEye

VersionEye is currently using this backend systems:

  - MongoDB
  - RabbitMQ
  - ElasticSearch
  - Memcached

They are all available as Docker images from Docker Hub. In the [docker-compose](docker-compose)
directory there is a file `versioneye-base.yml` for [Docker Compose](https://docs.docker.com/compose/).
Maybe you need to adjust the mount volumes for MongoDB and Elasticsearch in the `versioneye-base.yml`. 
Then you can start all backend systems like this: 

```
docker-compose -f docker-compose/versioneye-base.yml up -d
```

That will start all 4 Docker containers in deamon mode.

