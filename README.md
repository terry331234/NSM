# NSM
## Networking Security Monitoring Solution For Visualization Network Intrusions
### Include Suricata, Zeek, FileBeat, ElasticSearch and Kibana

### Prerequisite
- Docker Engine
- Docker Compose version 1.10.0 or newer

### Usage
#### Setting Up
Create a .env file which contains:
```
INTERFACE=interface
NSM_LOG_DIR=/path/to/logdir/
ELASTICSEARCH_USERNAME=username
ELASTICSEARCH_PASSWORD=password
```
Set the value to suit your usecase\
*default username:elastic, password: changeme
*The log dir need to be owned by UID 1000 or set to allow read and write for Others


Clone this repository and start services locally using Docker Compose:

```console
$ docker-compose up
```

Run the solution in the background by adding the `-d` flag to the above command.

The Kibana HTTP web interface can be accessed at port 5601


#### Cleanup

Elasticsearch data is stored inside a volume.

To entirely shutdown the solution remove all persisted data, run:

```console
$ docker-compose down -v
```

### Useful Commands

#### Update Suricata rules
```console
$ docker-compose exec --user suricata suricata suricata-update -f
```

