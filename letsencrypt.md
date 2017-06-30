# LetsEncrypt Certs


To generate or renewe the SSL certificats via [letsencrypt](https://letsencrypt.org) the domain must be accessible from the internet. The webserver for the domain must be able to serve static assets. The letsencrypt tool will generate a random file in the root directory of the domain. The generated random file must be accessible from the Internet to verify the owner ship of the domain. For Nginx the configuration of the domain can look like this: 

```
server {
  listen 80;
  server_name www.versioneye.com;
  location / {
    root /var/www;
  }
}
```

With that the Nginx server will serve static files from the `/var/www` directory for the domain `www.versioneye.com`. Now the certificates can be generate with this command: 

```
sudo letsencrypt certonly -a webroot --webroot-path=/var/www/html -d www.versioneye.com
```

Or for multiple domains like this:

```
sudo letsencrypt certonly -a webroot --webroot-path=/var/www/html -d www.versioneye.com -d versioneye.com
```

Lets Encrypt certificates are valid for 90 days only!
