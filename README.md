# DefaultSite
默认站点 +11

```shell

docker rm -f default_site
docker rmi default_site

#docker build -t default_site:v1.0 .
#docker build -t default_site:latest .
docker build -t default_site .

docker tag default_site:latest 127.0.0.1:5000/default_site:20250702
docker push 127.0.0.1:5000/default_site:20250702

#docker run -d -p 12345:80 --name default_site default_site
docker run -d -p 12345:80 --name default_site 127.0.0.1:5000/default_site:20250702

```