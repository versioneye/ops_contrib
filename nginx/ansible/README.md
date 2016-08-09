# NGinx proxy for VersionEye

This directory includes an Ansible playbook to setup an Nginx webserver on Ubuntu as proxy for the
VersionEye App and API Docker containers.

This directory includes 2 different roles for Nginx. There is a simple `nginx` role which installs an
Nginx on port 80 with a configuration to forward requests to `localhost:8080` (VersionEye Web App) and to
`localhost:9090` (VersionEye API). Beside that there is another role called `nginx_ssl`, which is a bit
more complex but it includes everything to spin up an Nginx with SSL certificates.

Let's start with the simple setup.

## Role nginx

Some little changes are needed before this plyabook can be executed.

 1. Configure the IP address of your Host (VersionEye server) in the [hosts](hosts) file.
 2. Configure the server name in the [nginx config](https://github.com/versioneye/ops_contrib/blob/master/nginx/ansible/roles/nginx/files/default.conf#L15).

Execute the playbook:

```
ansible-playbook setup_nginx.yml
```
