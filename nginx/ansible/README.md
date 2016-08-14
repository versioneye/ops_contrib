# NGinx proxy for VersionEye

This directory includes an [Ansible](https://www.ansible.com/) playbook to setup an Nginx webserver on Ubuntu as proxy for the
VersionEye App and API Docker containers. On Ubuntu Ansible can be installed like this: 

```
sudo apt-get install ansible
```

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
ansible-playbook setup_remote_nginx.yml
```

If you wanna execute the playbook on the Host itself, means on localhost, than please use this playbook:

```
ansible-playbook setup_locale_nginx.yml
```

## Role nginx_ssl

This changes are needed before this plyabook can be executed.

 1. Configure the IP address of your Host (VersionEye server) in the [hosts](hosts) file.
 2. Configure the server name in the [nginx config](https://github.com/versioneye/ops_contrib/blob/master/nginx/ansible/roles/nginx_ssl/files/default.conf). In this file the server_name occurs at 2 places.

This playbook assumes that you create your own self signed SSL certifaces like described in this [blog post](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04) and the
cert files are placed in this places:

```
/etc/ssl/certs/nginx-selfsigned.crt;
/etc/ssl/private/nginx-selfsigned.key;
```

If you have already other certifaces please place them at the directories described above or adjut the paths in this playbooks.
To create your own self signed certificate run this command on the server:

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
```

Now adjust the server_name in the [default.conf#L15](roles/nginx_ssl/files/default.conf#L15) and [default.conf#L21](roles/nginx_ssl/files/default.conf#L21) file and execute the playbook:

```
ansible-playbook setup_remote_nginx_ssl.yml
```

If you wanna execute the playbook on the Host itself, means on localhost, than please use this playbook:

```
ansible-playbook setup_locale_nginx_ssl.yml
```
