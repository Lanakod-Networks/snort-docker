# Snort-docker

![GitHub](https://img.shields.io/github/license/lanakod/snort-docker)

## How to deploy

```shell
git clone https://github.com/Lanakod/snort-docker.git
cd snort-docker
cp .env.example .env
# Edit ".env" file via "nano .env" or "vi .env"
docker compose up -d
# Grafana will be hosted on port 3000 and ELK on 5601
```

## Configuration

```
configs
 ┣ snort-conf
 ┃ ┣ balanced.lua
 ┃ ┣ connectivity.lua
 ┃ ┣ file_magic.rules
 ┃ ┣ inline.lua
 ┃ ┣ max_detect.lua
 ┃ ┣ security.lua
 ┃ ┣ sensitive_data.rules
 ┃ ┣ snort.lua
 ┃ ┣ snort_defaults.lua
 ┃ ┗ talos.lua
 ┣ filebeat.yml
 ┣ logstash.conf
 ┣ promtail.yml
 ┣ snort.rules
 ┗ supervisord.conf
```

- `snort.rules` - your custom written rules for snort
- `filebeat.yml` - config file for filebeat | needed for ELK
- `logstash.yml` - config file for logstash | needed for ELK
- `promtail.yml` - config file for promtail | needed for Grafana
- `supervisord.conf` - config file that runs snort in supervisor
- `snorf-conf` - folder with all snort config files written in lua

```
grafana
 ┗ provisioning
 ┃ ┗ datasources
 ┃ ┃ ┗ loki.yml
```

- In grafana folder can be found `loki.yml` file

## Contact

- For any security issues, please do not create a public issue on GitHub, instead please write to security@lanakod.ru

## License

snort-docker is [MIT licensed](https://github.com/lanakod/snort-docker/blob/master/LICENSE).
