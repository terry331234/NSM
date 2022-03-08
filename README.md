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
INTERFACE=interface           #required
NSM_LOG_DIR=/path/to/logdir/  #required
PASSWORD=password             #optional, default changeme
KIBANA_PORT=port              #optional, default 5601
TRUSTED_NET=CIDR1,CIDR2       #optional, default 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
UID=uid                       #optional, default 1000
GID=gid                       #optional, default 1000
```
Set the value to suit your usecase\
- Username for kibana web: elastic
- `UID/GID` set the owner of files in `NSM_LOG_DIR`, and user/group running zeek & suricata
- `TRUSTED_NET` set the trusted subnet for zeek & suricata

Clone this repository and start services locally using Docker Compose:

```console
$ docker-compose up
#Run in background
$ docker-compose up -d
```

#### Cleanup

Elasticsearch data is stored inside a volume.

To entirely shutdown the solution remove all persisted data, run:

```console
$ docker-compose down -v
```


