# Diagram using Structurizr Lite
## Run diagram
- Install docker and run it
```sh
docker pull structurizr/lite
docker run -it --rm -p 8080:8080 -v PATH:/usr/local/structurizr structurizr/lite
#example: 
docker run -it --rm -p 8080:8080 -v /home/luat/c4model:/usr/local/structurizr structurizr/lite
if PATH is /home/luat/c4model
```
