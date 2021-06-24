FROM confluentinc/cp-kafka-connect:6.2.0

RUN  confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:11.0.6 && \
  confluent-hub install --no-prompt debezium/debezium-connector-postgresql:1.5.0
