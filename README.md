# Security Monitoring Platform
This is the network sensor management platform designed to facilitate the use of Zeek and Suricata in a multi-client environment.

## Manager and Worker
The Manager consists of a dashboard that you can use to manage sensors and their groups. You can create, delete, and edit them. The sensor keys must be generated from the Manager dashboard. The sensors' status is also displayed on the Manager dashboard.
The Worker is used to receive logs from the sensors and then authenticate these sensors with the keys provided from the dashboard. It also enhances the logs with data from MISP before sending them to the database, such as OpenSearch.

### Prerequisite
- OpenSearch, ElasticSearch or Wazuh
- MySQL 8 [(the schama of the database)](https://github.com/SMC-Security-Team/sec-monitoring-platform-installation/blob/main/schema.sql)
- MISP

### Manager and Worker Architecture
![manager_worker](https://github.com/SMC-Security-Team/sec-monitoring-platform-installation/blob/main/manager_worker.png)

### Database Setup
```
mysql -u username -p your_database < schema.sql
```

### Starting Manager
1. Create a `.env` file with the following variables
```env
MYSQL_CONNECTION_STRING=root:root@tcp(10.0.0.2)/db_name?parseTime=true
DASHBOARD_PASSWORD=password
DASHBOARD_USERNAME=admin
OPENSEARCH_ADDRESS=https://10.0.0.1:9200
OPENSEARCH_USERNAME=admin
OPENSEARCH_PASSWORD=!Passw0rd#1234
OPENSEARCH_DASHBOARD_URL=http://10.0.0.1:5601
PORT=9091 # Running Port
```

2. Start the container
```bash
docker run -d -p 9091:9091 --env-file ./.env smcsec/security-monitoring-manager
```

### Starting Worker

```env
PORT=8080
RUN_MODE=release
MYSQL_CONNECTION_STRING=root:root@tcp(10.0.0.1)/db_name?parseTime=true
OPENSEARCH_ADDRESS=http://opensearch:9200
OPENSEARCH_USERNAME=admin
OPENSEARCH_PASSWORD=!Passw0rd#1234
MISP_ADDRESS=https://10.0.0.2
MISP_AUTHKEY=misp_api_key
```

2. Start the container
```yaml
docker run -d -p 9090:9090 --env-file ./.env smcsec/security-monitoring-worker
```

## Sensor

The sensor is used to forward the Suricata and Zeek logs to the worker. It will first structure the logs, then send them to the worker with an authentication key. It also reports the status of the sensor to the system, such as CPU usage and memory.

### Sensor Architecture
![sensor](https://github.com/SMC-Security-Team/sec-monitoring-platform-installation/blob/main/sensor.png)

### Prerequisite
- Zeek
- Suricata

### Zeek Configuration
This is the suggested Zeek configuration to add to /opt/zeek/share/zeek/site/local.zeek to make Zeek logs compatible with the platform.

```
redef ignore_checksums = T;
redef LogAscii::use_json=T;
redef LogAscii::json_timestamps=JSON::TS_ISO8601;
redef LogAscii::json_include_unset_fields=T;

@load policy/protocols/conn/mac-logging
@load policy/protocols/conn/community-id-logging
@load policy/frameworks/notice/community-id
```

### Docker Compose Example
```yaml
version: "3"
services:
  security-monitoring-sensor:
    image: "smcsec/security-monitoring-sensor:latest"
    environment:
      - SERVER_URL=http://10.0.0.1/api/v1
      - AUTH_KEY=yyy:xxxxxxxx
      - ZEEK_LOG_PATH=/zeek-logs/zeek
      - SURICATA_LOG_PATH=/suricata-logs
    volumes:
      - /opt/zeek/spool:/zeek-logs
      - /var/log/suricata:/suricata-logs
```

- Set SERVER_URL to match your worker's API endpoint
- Set AUTH_KEY to the authentication key obtained from your dashboard

Volume Mounts

- Zeek logs: Mount your Zeek spool directory to /zeek-logs in the container
- Suricata logs: Mount your Suricata log directory to /suricata-logs in the container
