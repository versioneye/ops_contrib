# ops_contrib

Scripts for [VersionEye](https://www.versioneye.com) operations. Everybody can contribute!

## Environment

The scripts in this repository are all tested with Docker for Linux on Ubuntu 14.04.

## Start backend services for VersionEye

VersionEye is currently using this backend systems:

  - MongoDB
  - RabbitMQ
  - ElasticSearch
  - Memcached

They are all available as Docker images from Docker Hub. There is a file `versioneye-base.yml`
for [Docker Compose](https://docs.docker.com/compose/).
You can start all backend systems like this:

```
docker-compose -f versioneye-base.yml up -d
```

That will start all 4 Docker containers in deamon mode.
The MongoDB and ElasticSearch container is not persistent! If the Docker containers are
getting stopped/killed the data is lost. For persistence you need to comment in the
mount volumes in the `versioneye-base.yml` file and adjust the paths to a directory on the
host system.

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

To initialise the database run this command once: 

```
docker exec -it tasks /app/init_enterprise.sh
```

That will create a default user `admin` with a super secret password `admin` and do some other initialising steps. 

### Boot2Docker on Mac OS X

If you are using [Boot2Docker](http://boot2docker.io/) on Mac OS X the Docker containers are running in an virtual machine
on [VirtualBox](https://www.virtualbox.org/wiki/Downloads). In that case you have to find out the IP of your VirtualBox VM and the application
will be available under the IP of the VM on port 8080.

To find out the IP of your VirtualBox VM you have to open VirtualBox and connect to the `default` VM.
Get a console on the `default` VM and run:

```
ifconfig | less
```

Usually with the IP of `eth1` you can reach the VM from outside. Use that IP address and port 8080 like this `http://<ETH1_IP>:8080`.

### Docker for Windows

The non native [Docker for Windows](https://docs.docker.com/windows/step_one/) is similar to Boot2Docker on Mac OS X. Please follow the instructions from the above section.

## Stop the VersionEye containers

With this command the VersionEye containers can be stopped:

```
./versioneye-stop
```

That will stop the VersionEye containers, but not the backend services.

## Monitoring

With this command the running containers can be monitored.

```
./docker-mon
```

That will display in real time how much CPU, RAM and IO each containers is using.

## Support

For commercial support send a message to `support@versioneye.com`.

## License

ops_contrib is licensed under the MIT license!

Copyright (c) 2016 VersionEye GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
