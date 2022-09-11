# Nginx

A tool available for domain name management along with Nginx server and SSL certificates.

## Features

* Automatic SSL certificate generation,
* Automatic directory permissions.

## Requirements

* Ubuntu (tested on Ubuntu 22.04, Ubuntu 20.04, Ubuntu 18.04, Ubuntu 16.04, Ubuntu 14.04)

## Install & Create Domain

```
wget https://raw.githubusercontent.com/x-shell-codes/nginx/master/nginx.sh
sudo bash nginx.sh -d=example.com -s=api
```

#### Options

- -d | --domain Domain name (example.com)
- -s | --subdomain Subdomain name (api)
- -l | --isLocal Is local env (auto-deject). Values: true, false"
- -c | --certificate SSL Certificate installation (true). Values: true, false"

## Install

```
wget https://raw.githubusercontent.com/x-shell-codes/nginx/master/install_nginx.sh
sudo bash install_nginx.sh
```

## Create Domain

```
wget https://raw.githubusercontent.com/x-shell-codes/nginx/master/create_domain.sh
sudo bash create_domain.sh -d=example.com -s=api
```

#### Options

- -d | --domain Domain name (example.com)
- -s | --subdomain Subdomain name (api)
- -l | --isLocal Is local env (auto-deject). Values: true, false"
- -c | --certificate SSL Certificate installation (true). Values: true, false"

## Attentions

* When creating a swap area, there must be enough space for the file to be created.
* DO NOT RUN THIS SCRIPT ON YOUR PC OR MAC!

## Security Vulnerabilities

If you discover a security vulnerability within project, please send an e-mail to Mehmet ÖĞMEN
via [www@mehmetogmen.com.tr](mailto:www@mehmetogmen.com.tr). All security vulnerabilities will be promptly addressed.

## License

Copyright (C) 2022 [Mehmet ÖĞMEN](https://github.com/X-Adam)
This work is licensed under
the [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/)  
Attribution Required: please include my name in any derivative and let me know how you have improved it!
