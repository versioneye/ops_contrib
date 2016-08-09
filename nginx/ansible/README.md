# NGinx proxy for VersionEye

This directory includes an [Ansible](https://www.ansible.com/) playbook to setup an Nginx webserver on Ubuntu as proxy for the
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

## Role nginx_ssl

This changes are needed before this plyabook can be executed.

 1. Configure the IP address of your Host (VersionEye server) in the [hosts](hosts) file.
 2. Configure the server name in the [nginx config](https://github.com/versioneye/ops_contrib/blob/master/nginx/ansible/roles/nginx_ssl/files/default.conf). In this file the server_name occurs at 2 places.
 3. Copy the files for your SSL certificate into the [roles/nginx_ssl/files/](roles/nginx_ssl/files) directory. There are already some empty files as an example.
 4. Adjust the paths in the [roles/nginx_ssl/tasks/main.yml](roles/nginx_ssl/tasks/main.yml) according to your SSL files.
 5. Adjust the paths in the [default.conf](https://github.com/versioneye/ops_contrib/blob/master/nginx/ansible/roles/nginx_ssl/files/default.conf#L23) file according to your SSL files.

Execute the playbook:

```
ansible-playbook setup_nginx_ssl.yml
```
