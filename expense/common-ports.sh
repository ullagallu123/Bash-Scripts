jenkins 8080
prometheus 9090
node_exporter 9100
sonarqube 9000
grafana 3000


- job_name: 'Jenkins-Master'
    scrape_interval: 5s
    static_configs:
      - targets: ['jm.test.ullagallu.cloud:9100']

- job_name: 'Jenkins-Agent'
    scrape_interval: 5s
    static_configs:
      - targets: ['jn1.test.ullagallu.cloud:9100']
- job_name: 'Local'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']