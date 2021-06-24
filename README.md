# Start docker compose 

```bash
docker-compose -p kafkadrop up -d
```

If you want to see the logs you can run 

```bash
 docker-compose -p kafkadrop logs -f
```

This should create the following containers:

| Name             | Ports        | External |
| ---------------- | ------------ | -------  |
| zookeeper        | 2081         | false    |
| kafka            | 29092, 9092  | true     |
| schema-registry  | 8081         | true     |
| kafka-connect    | 8083         | true     |
| kafdrop          | 9000         | true     |
| akhq             | 8088         | true     |
| postgres         | 5432         | true     |
| elasticsearch    | 9200         | true     |

# Use kafcat to produce messages


[kafkacat](https://docs.confluent.io/platform/current/app-development/kafkacat-usage.html) can be executed to produce messages  
```bash
docker run -i --rm \
         --network kafkadrop_default \
         confluentinc/cp-kafkacat \
                kafkacat \
                -b kafka:29092 \
                -t test \
                -K: \
                -P <<EOF

1:{"order_id":1,"order_ts":1534772501276,"total_amount":10.50,"customer_name":"Bob Smith"}
2:{"order_id":2,"order_ts":1534772605276,"total_amount":3.32,"customer_name":"Sarah Black"}
3:{"order_id":3,"order_ts":1534772742276,"total_amount":21.00,"customer_name":"Emma Turner"}
EOF
```

And it can also be used to consume from any topic


```bash
docker run -t --rm \
      --network kafkadrop_default \
      confluentinc/cp-kafkacat \
      kafkacat \ 
      -C -v -b kafka:29092 -t events -s avro -r "http://schema-registry:8081"
```

# Use kafka connect to export data from a postgres database using CDC

Create the Kafka connect source connector using debezium

```bash
 curl -i -X POST -H "Accept:application/json" \ 
 -H "Content-Type:application/json" localhost:8083/connectors/ \
 -d '{"name":"postgres-resources-test","config":{"connector.class":"io.debezium.connector.postgresql.PostgresConnector","tasks.max":"1","offset.flush.timeout.ms":"30000","database.hostname":"postgresql","database.port":"5432","database.user":"root","database.dbname":"bend","database.server.name":"connect","plugin.name":"pgoutput","table.include.list":"public.resources","key.converter":"io.confluent.connect.avro.AvroConverter","value.converter":"io.confluent.connect.avro.AvroConverter","schema.compatibility":"BACKWARD","locale":"en_US","timezone":"UTC","timestamp.field":"updated_at","key.converter.schema.registry.url":"http://schema-registry:8081""value.converter.schema.registry.url":"http://schema-registry:8081", "heartbeat.interval.ms": "60000"}}',
```


Create a sink connector to process all the data 

```bash
 curl -i -X POST -H "Accept:application/json" \ 
 -H "Content-Type:application/json" localhost:8083/connectors/ \
 -d '{"name":"elasticsearch-sink","config":{"connector.class":"io.confluent.connect.elasticsearch.ElasticsearchSinkConnector","connection.url":"http://elasticsearch:9200","key.ignore":"true","topics":"connect.public.resources","key.converter":"io.confluent.connect.avro.AvroConverter","value.converter":"io.confluent.connect.avro.AvroConverter","key.converter.schema.registry.url":"http://schema-registry:8081","value.converter.schema.registry.url":"http://schema-registry:8081","behavior.on.null.values":"DELETE"}}
```

# Cleaning up you docker containers

To stop all the containers you can run 

```bash
docker-compose -p kafkadrop down
```

And to clar them all you can run 
```
 docker-compose -p kafkadrop rm
```




