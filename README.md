# ops_contrib

Scripts for [VersionEye](https://www.versioneye.com) operations. Everybody can contribute!

The software for [VersionEye](https://www.versioneye.com) is shipped in multiple [Docker](https://www.docker.com/) images. VersionEye is a distributed system which is a composition of at least 8 Docker images. The Docker images and there relations to each other are described in docker compose files.
This repository describes how to fetch, start, stop and monitor the VersionEye Docker images.

## Table of Contents

- [Starting Point](#starting-point)
- [Vagrant](#vagrant)
- [System requirements](#system-requirements)
- [Network configuration](#network-configuration)
- [Environment dependencies](#environment-dependencies)
- [Start backend services for VersionEye](#start-backend-services-for-VersionEye)
- [Start the VersionEye containers](#start-the-versioneye-containers)
- [Stop the VersionEye containers](#stop-the-versioneye-containers)
- [Use Nginx as proxy](#use-nginx-as-proxy)
- [Configure cron jobs for crawling](#configure-cron-jobs-for-crawling)
- [RabbitMQ Management Plugin](#rabbitmq-management-plugin)
- [Monitoring](#monitoring)
- [Backup your data](#backup-your-data)
- [Restore your data](#restore-your-data)
- [Support](#support)
- [License](#license)

## Starting point

Clone this repository and `cd` into it:

`git clone https://github.com/versioneye/ops_contrib.git && cd ops_contrib`

Some of the commands and files below are found on the root of this repository, thus cloning the repository is the easier way to get access to them. Alternatively you can download the files or use the [repository archive](https://github.com/versioneye/ops_contrib/archive/master.zip).

There are 2 ways of running the VersionEye software.
The simplest is to run the Vagrant box in the next section.
That is perfect for a quick start to try out the software.
For production environments we recommend to setup the Docker containers natively.
In that case you can skip the Vagrant section.

## Vagrant

There is a Vagrantfile in this directory which describes a Vagrant box for VersionEye.
[Vagrant](https://www.vagrantup.com) is a cool technology to describe and manage VMs.
If you don't have it yet, please download it from [here](https://www.vagrantup.com/downloads.html).
By default Vagrant is using VirtualBox as VM provider. You can download VirtualBox from [here](https://www.virtualbox.org/wiki/Downloads). This setup is tested with Vagrant version
 1.8.5 and VirtualBox version 5.0.16 r105871.

Open a console and navigate to the root of this git repository and run simply this command:

```
vagrant up
```

That will create a new virtual machine image in VirtualBox and install the VersionEye Docker images
on it. Dependening on your internet connection it can take a couple minutes. If everything is done
you can reach the VersionEye application under `http://127.0.0.1:7070`.

**But keep it mind that this Vagrant setup is just for development and testing. It's not a production setup! If you shut down the Vagrant box it might be that you loose data!**

If you don't
want to use Vagrant and you are interested in running the Docker containers natively
on your machine then keep reading. The following sections describe how to start, stop
and monitor the VersionEye Docker images natively.

## System requirements

We recommend a minimum resource configuration of:
 - 2 vCPUS
 - 8GB of RAM
 - 25GB of storage

This setup will allow you to get VersionEye of the ground successfully. It's the equivalent to an [AWS `t2-large`](https://aws.amazon.com/ec2/instance-types/). For more detailed requirements analysis please contact the VersionEye team at `support@versioneye.com`

## Network configuration

The VersionEye host will need the following ports open:

| Port  | Protocol  | Description  |
|---|---|---|
| 8080  | HTTP | Web application  |
| 9090  | HTTP | API endpoint     |
| 22  | SSH | Host management     |

If you [configure Nginx](#use-nginx-as-proxy) in front of the Web Application and API you can configure the following ports instead:

| Port  | Protocol  | Description  |
|---|---|---|
| 80   | HTTP  | Web application & API Endpoint |
| 433  | HTTPS | Web application & API Endpoint over SSL |
| 22   | SSH   | Host management |

You might still want to leave `8080` and `9090` open if you still want direct access to the those services.

## Environment dependencies

The scripts in this repository are all tested with Docker for Linux on Ubuntu 14.04. This instalation guide requires that you have the following libraries installed:
 - jq
 - docker
 - docker-compose

### Installing jq

On Ubuntu you can install it by running the following command on the terminal:
```
apt-get install jq
```

Alternatively you can also check the official [jq docs](https://stedolan.github.io/jq/)

### Installing docker and docker-compose

Follow these guides to install docker and docker-compose:
 - [Installing docker engine in Ubuntu](https://docs.docker.com/engine/installation/linux/ubuntulinux/) ([or other distributions](https://docs.docker.com/engine/installation/))
 - [Installing docker-compose](https://docs.docker.com/compose/install/)

Make sure you've tested the docker dependencies before moving to the net next. On Ubuntu you can test them by running:

```
sudo docker run hello-world
```

and:

```
docker-compose --version
```

## Start backend services for VersionEye

VersionEye is currently using this backend systems:

  - MongoDB
  - RabbitMQ
  - ElasticSearch
  - Memcached


These are all available as Docker images from Docker Hub. This repository contains a file `versioneye-base.yml` for Docker Compose. You can start all backend systems like this:

Start the docker containers:

```
sudo docker-compose -f versioneye-base.yml up -d
```

That will start all 4 Docker containers in deamon mode.
The MongoDB and ElasticSearch container is not persistent! If the Docker containers are
getting stopped/killed the data is lost. For persistence you need to comment in the
mount volumes in the `versioneye-base.yml` file and adjust the paths to a directory on the host system.

To stop backend services you can run:

```sh
docker-compose -f versioneye-base.yml stop
```

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

### Boot2Docker on Mac OS X

If you are using [Boot2Docker](http://boot2docker.io/) on Mac OS X the Docker containers are running in a virtual machine
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

## Use Nginx as proxy

By default the VersionEye Web App is running on port 8080 and the API on port 9090.
It makes sense to use a webserver in fornt of it on port 80, which does forward the
requests to port 8080 and 9090. Beside that the webserver can be used for SSL
termination. On Ubuntu the Nginx webserver can be installed like this:

```
apt-get install nginx
```

Assuming this repository is checked out into `/opt/ops_contrib`,
the Nginx can be re configured as proxy for VersionEye by copying this 2 files to the right location:

```
sudo cp /opt/ops_contrib/nginx/ansible/roles/nginx/files/nginx.conf /etc/nginx/nginx.conf
sudo cp /opt/ops_contrib/nginx/ansible/roles/nginx/files/default.conf /etc/nginx/conf.d/default.conf
```

After that the Nginx needs to be restarted:

```
sudo service nginx restart
```

Now the VersionEye web app should be available on port 80.

Here is an [Ansible playbook](https://github.com/versioneye/ops_contrib/tree/master/nginx/ansible)
which is automating this steps.

## Configure cron jobs for crawling

The Docker image `versioneye/crawlj` contains the crawlers which enable you to crawl internal Maven repositories such as Sonatype Nexus, JFrog Artifactory or Apache Archiva. Inside of the Docker container the crawlers are triggered by a cron job. The crontab for that can be found [here](https://github.com/versioneye/crawl_j/blob/master/crontab_enterprise). If you want to trigger the crawlers on a different schedule you have to mount another crontab file into the Docker container to `/mnt/crawl_j/crontab_enterprise`.

## RabbitMQ Management Plugin

By default the RabbitMQ container is running without a UI. But if the management plugin
is enabled a Web UI can be used to watch and control the queues. Do do that you need
to get a shell on the running rabbitmq container:

```
docker exec -it rabbitmq bash
```

Then run this command to enable the management plugin:

```
rabbitmq-plugins enable rabbitmq_management
```

and leave the container with `exit`. Now leave the Host server and build up an SSH tunnel
from your local machine to the Host and the running container:

```
ssh -f <USER>@<HOST_IP> -L 15672:<IP_OF_DOCKER_CONTAINER>:15672 -N
```

For example:

```
ssh -f ubuntu@192.168.0.33 -L 15672:172.17.0.4:15672 -N
```

Now open a browser on your machine and navigate to `http://localhost:15672/`. Now you should be able to see the RabbitMQ UI.

## Monitoring

With this command the running containers can be monitored.

```
./docker-mon
```

That will display in real time how much CPU, RAM and IO each containers is using.

## Backup your data

The primary database for this application is MongoDB. If you run the MongoDB container
with a persistent volume your MongoDB config in the `versioneye-base` might look like this:

```
mongodb:
  image: versioneye/mongodb:3.2.8
  container_name: mongodb
  restart: always
  volumes:
   - /mnt/mongodb:/data
```

In the above configuration we use `/mnt/mongodb` on the host system to persiste the data
for MongoDB. To create a dump get a shell on the running MongoDB container like this:

```
docker exec -it mongodb bash
```

Than navigate to the `/data` directory and create a dump with this command:

```
mongodump --db veye_enterprise
```

That will create a complete database dump which will be persisted in `/mnt/mongodb/dump` on the host.
From there you can zip it and copy it to somewhere else.

## Restore your data

Assume you created a dump of one of your VersionEye instances and now you would like to restore the data
on another VersionEye instance. If your Docker container is persisting the data under `/mnt/mongodb` on the host
than simply compy your dump into that directory. Get a shell on the running MongoDB container:

```
docker exec -it mongodb bash
```

Navigate to `/data` and run the restore process:

```
mongorestore --db veye_enterprise dump/veye_enterprise/
```

Assuming that your MongoDB is empty, this will restore all the data from the previous backup.

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
