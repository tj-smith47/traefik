### INITIAL SETUP
 - Copy this folder to /etc so that you have the following layout:
 ```
 /etc/traefik 
    |- bootstrap/
        |- dc-template.yml
        |- new.sh
        |- .env
    |- config/
        |- docker-compose.yml 
        |- dynamic/
            |- dynamic.yml
        |- traefik.yml
        |- .env
```
- Next, you will want your certs available inside the dynamic directory (changes made to files in this directory are updated on save).

----

### TRAEFIK 
- To be able to start from `/etc/traefik`, link the 3 files inside `/etc/traefik/config/` one directory up.
- Your dynamic directory should not watch `/etc/traefik/` (configured in `traefik.yml` under `providers.file.directory`) or else you will duplicate all of your container volumes.
- Only Traefik should have the additional port declaration or (depending on how you decide to lay it out) the additional subdirectory `/config`
## Start Traefik
- Set your ENV's in `/etc/traefik/config/.env`
- Ensure the path / name of your certs in `/etc/traefik/config/dynamic/` are listed correctly inside `/etc/traefik/config/dynamic/dynamic.yml`
- Create the traefik network: `docker network create traefik`.
- Start Traefik with:
```
cd /etc/traefik
docker compose up -d
docker logs traefik
```
- Doulbe check for any config errors.
- Try visiting `http://service.domain.name` - it should redirect you to https and show trusted certs
## Start a New Proxied Service
- You can read the script in `bootstrap/new.sh` or get the TL;DR with:
```
./etc/traefik/bootstrap/new.sh --help
```
- I personally linked this as a binary, so I can run the script as `traefik`
```
ln -s /etc/bootstrap/new.sh /usr/local/bin/traefik
```
- Example:
```
traefik -s 'homebridge' -i 'onzu/homebridge:latest' -p '8581' -h 'hb' -r 'home' -d 'domain.name'
```
- Only `-s`, `-i`, and `-p` are required. `-h` is interpreted, and `-d` can be set in `/etc/traefik/bootstrap/.env`.
- New services will get their own directory in `/etc/traefik/<service>/`
- You will have to manually configure / customize the `docker-compose.yml` for any additional ports / mounts / volumes you need.

----
## Poxy an existing service on the host machine
See `/etc/traefik/config/dynamic/dynamic.yml` for an example of this configuration. There you can define hhtp routers, middlewares, and services to proxy local ports through traefik. Make sure your hosts file / DNS server includes the records you want proxied.

## Example Directory Structure
```
/etc/traefik 
    |- bootstrap/
        |- dc-template.yml
        |- new.sh
        |- .env
    |- homebridge/
        |- docker-compose.yml
        |- .env
    |- plex/
        |- config/
        |- media/
        |- transcode/
        |- docker-compose.yml
        |- .env
    |- config/
        |- docker-compose.yml 
        |- dynamic/
            |- fullchain.pem
            |- privkey.pem
            |- dynamic.yml
        |- traefik.yml
        |- .env
    |- docker-compose.yml => config/docker-compose.yml
    |- traefik.yml => config/traefik.yml
    |- .env => config/.env
```
# Useful aliases
```
echo "alias dcud='docker compose up -d'" >> ~/.bashrc
echo "alias dcd='docker compose down'" >> ~/.bashrc
echo "alias dcr='dcd && dcud'" >> ~/.bashrc
echo "alias dlt='docker logs traefik'" >> ~/.bashrc
```
