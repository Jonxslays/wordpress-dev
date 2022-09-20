# Wordpress-dev

A skeleton repo for WordPress development with Docker.

## Requirements

- Docker
- Docker-compose

## Note

All scripts in the `scripts` dir were written with unix like systems in mind.

## Getting started

- Clone the repo
- Change directory into the downloaded folder
- Copy the .env.example to .env
- Fill in the .env values
- Download wordpress (scripts/get_wordpress.sh)
- Run docker-compose

```bash
git clone https://github.com/Jonxslays/wordpress-dev.git

cd wordpress-dev

cp .env.example .env
# Fill in your values to the .env

./scripts/get_wordpress.sh
# Follow the prompts to download WordPress

sudo echo "127.0.0.1 wp.local www.wp.local" >> /etc/hosts
# Add wp.local to your hosts file

docker-compose up
# or `docker-compose up -d` to run in the background
```

The nginx config is set to proxy requests from `http://wp.local`, which is where
you should visit in your browser after running docker-compose to complete
the WordPress installation.

When filling the Database credentials, use the same username/password combo
you used in the `.env`, and use `wp-mysql` as the host. This connects to the
`wp-mysql` docker container.

## License

This repository is licensed under the
[MIT license](https://github.com/Jonxslays/wordpress-dev/blob/master/LICENSE).
