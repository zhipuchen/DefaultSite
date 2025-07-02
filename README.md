# DefaultSite
默认站点 +6

```shell

docker rm -f default_site
docker rmi default_site:latest
docker build -t default_site .
docker run -d -p 12345:80 --name default_site default_site

```