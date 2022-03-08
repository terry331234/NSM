# NSM
## Networking Security Monitoring Solution For Visualization Network Intrusions
### Include Suricata, Zeek, FileBeat, ElasticSearch and Kibana

### Prerequisite
- Docker Engine
- Docker Compose version 1.10.0 or newer

### Usage
#### Setting Up
Create a .env file for setup:
```
INTERFACE=interface
NSM_LOG_DIR=/path/to/logdir/
PASSWORD=password             #optional, default changeme
KIBANA_PORT=port              #optional, default 5601
TRUSTED_NET=CIDR1,CIDR2       #optional, default 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
```
Set the value to suit your usecase\
*default username for kibana web: elastic
*The log dir need to be owned by UID 1000 or set to allow read and write for Others

Clone this repository and start services locally using Docker Compose:

```console
$ docker-compose up
```

Run the solution in the background by adding the `-d` flag to the above command.


#### Cleanup

Elasticsearch data is stored inside a volume.

To entirely shutdown the solution remove all persisted data, run:

```console
$ docker-compose down -v
```


