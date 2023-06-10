-- https://ksqldb.io/examples.html#create-a-stream-over-an-existing-kafka-topic
-- docker container exec -it ksqldb-cli ksql http://ksqldb-server:8088
SET 'auto.offset.reset' = 'earliest';

-- CREATE SOURCE CONNECTOR POSTGRES_SOURCE_CONNECTOR WITH(
--   'connector.class'= 'io.debezium.connector.postgresql.PostgresConnector',
--   'database.hostname'= 'postgres',
--   'database.port'= '5432',
--   'database.user'= 'postgres',
--   'database.password'= 'postgres',
--   'database.dbname' = 'hapi-fhir',
--   'topic.prefix'= 'pg_topic_',
--   -- 'database.server.name'= 'dbserver1',
--   'database.whitelist'= 'device',
--   'database.history.kafka.bootstrap.servers'= 'kafka:9092',
--   'database.history.kafka.topic'= 'schema-changes.kafka_test',
--   'key.converter'= 'org.apache.kafka.connect.storage.StringConverter',
--   'value.converter'= 'io.confluent.connect.avro.AvroConverter',
--   'key.converter.schemas.enable'= 'false',
--   'value.converter.schemas.enable'= 'true',
--   'value.converter.schema.registry.url'= 'http://schema-registry:8081',
--   'transforms'= 'unwrap,addTopicPrefix',
--   'transforms.unwrap.type'= 'io.debezium.transforms.ExtractNewRecordState',
--   'transforms.addTopicPrefix.type'='org.apache.kafka.connect.transforms.RegexRouter',
--   'transforms.addTopicPrefix.regex'='(.*)',
--   'transforms.addTopicPrefix.replacement'='postgres_debezium_$1',
--   'decimal.handling.mode' = 'double'
-- );


-- Create Source Connector
CREATE SOURCE CONNECTOR POSTGRES_SOURCE_CONNECTOR WITH(
  'connector.class'= 'io.confluent.connect.jdbc.JdbcSourceConnector',
  'connection.url'= 'jdbc:postgresql://postgres:5432/hapi-fhir',
  'connection.user'= 'postgres',
  'connection.password'= 'postgres',
  -- 'db.name'= 'hapi-fhir',
  'table.whitelist' = 'device,measure,status,ventilationsettings,alarmssettings',
  'topic.prefix'= 'pg_topic_',
  'poll.interval.ms' = 500,

  -- 'mode'='bulk',
  'mode'='timestamp',
  'timestamp.column.name' = 'created_at',
  'db.timezone' = 'UTC',
  -- 'mode'='incrementing',
  -- 'incrementing.column.name' = 'device_id',


  -- 'key.converter'= 'org.apache.kafka.connect.storage.StringConverter',
  -- 'key.converter.schemas.enable'= 'true',
  -- 'key.converter.schema.registry.url'= 'http://schema-registry:8081',

  -- 'value.converter.schemas.enable'= 'true',
  -- 'value.converter.enhanced.avro.schema.support'= 'true',
  -- 'validate.non.null' = 'false',
  -- 'value.converter'= 'io.confluent.connect.json.JsonSchemaConverter',

  -- 'schemas.enable' = 'false',
  -- 'schema.pattern'= 'hapi-fhir',
  -- 'value.converter'= 'io.confluent.connect.avro.AvroConverter',

  -- 'value.converter.schema.registry.url'= 'http://schema-registry:8081',
  'output.data.format' = 'JSON',
  -- 'scrub.invalid.names' = 'true',
  'transforms'= 'unwrap,addTopicPrefix',

  'transforms.unwrap.type'= 'io.debezium.transforms.ExtractNewRecordState',
  'transforms.addTopicPrefix.type'='org.apache.kafka.connect.transforms.RegexRouter',
  'transforms.addTopicPrefix.regex'='(.*)',
  'transforms.addTopicPrefix.replacement'='postgres_debezium_$1',
  'decimal.handling.mode' = 'double',
  'tasks.max'= 1,
  'dialect.name'='PostgreSqlDatabaseDialect',
  'numeric.mapping'= 'best_fit',
  'errors.tolerance'= 'all',
  'debug' = 'true'
);

DROP CONNECTOR POSTGRES_SOURCE_CONNECTOR;
PRINT postgres_debezium_pg_topic_status FROM BEGINNING;
DESCRIBE CONNECTOR POSTGRES_SOURCE_CONNECTOR;

-- Create Sink Connector
CREATE SINK CONNECTOR ELASTICSEARCH_SINK_CONNECTOR 
WITH (
  'connector.class' = 'io.confluent.connect.elasticsearch.ElasticsearchSinkConnector',
  'topics' = 'postgres_debezium_pg_topic_device, postgres_debezium_pg_topic_measure, postgres_debezium_pg_topic_status, postgres_debezium_pg_topic_alarmssettings, postgres_debezium_pg_topic_ventilationsettings',
  'connection.url' = 'http://elasticsearch:9200',
  -- 'key.converter'= 'org.apache.kafka.connect.storage.StringConverter',
  -- 'key.converter.schemas.enable'= 'true',
  -- 'key.converter.schema.registry.url'= 'http://schema-registry:8081',
  -- 'input.data.format'= 'AVRO',
  'value.converter.schemas.enable'= 'false',
  'value.converter'= 'org.apache.kafka.connect.json.JsonConverter',
  'errors.tolerance'= 'all',
  'key.ignore' = 'true',
  'schema.ignore'='true',
  'tasks.max'= '2'
);

DROP CONNECTOR ELASTICSEARCH_SINK_CONNECTOR ;
DESCRIBE CONNECTOR ELASTICSEARCH_SINK_CONNECTOR;

-- Create Stream


-- CREATE STREAM IF NOT EXISTS MEASURE_STREAM (
--   Measure_id INT,
--   Ppeak DOUBLE,
--   VTe DOUBLE,
--   RR DOUBLE,
--   MVe DOUBLE,
--   FiO2 DOUBLE,
--   Pmean DOUBLE,
--   Pplat DOUBLE,
--   PEEP DOUBLE,
--   VTi DOUBLE,
--   MVi DOUBLE,
--   TI_Ttot DOUBLE,
--   FinCO2 DOUBLE,
--   etCO2 DOUBLE,
--   Created_at TIMESTAMP
-- ) WITH (
--   KAFKA_TOPIC='measure_topic',
--   VALUE_FORMAT='JSON',
--   PARTITIONS=2
-- );

-- CREATE STREAM IF NOT EXISTS STATUS_STREAM (
--   Status_id INT,
--   PatientType INT,
--   VentilatorMode INT,
--   O2_100 INT,
--   ExpiPause INT,
--   ExpiFlowSensor INT,
--   VentilatorState INT,
--   InspiPause INT,
--   NIV INT,
--   CO2Sensor INT,
--   Created_at TIMESTAMP
-- ) WITH (
--   KAFKA_TOPIC='status_topic',
--   VALUE_FORMAT='JSON',
--   PARTITIONS=2
-- );

-- CREATE STREAM IF NOT EXISTS VENTILATION_SETTINGS_STREAM (
--   Ventilation_settings_id INT,
--   VT DOUBLE,
--   RR DOUBLE,
--   RR_mini DOUBLE,
--   RR_VSIMV DOUBLE,
--   PI DOUBLE,
--   PS DOUBLE,
--   PEEP DOUBLE,
--   I_E DOUBLE,
--   TI_Ttot DOUBLE,
--   Timax DOUBLE,
--   TrigI DOUBLE,
--   TrigE DOUBLE,
--   Pressure_slope DOUBLE,
--   PI_sigh DOUBLE,
--   Sigh_period DOUBLE,
--   Vt_target DOUBLE,
--   FiO2 DOUBLE,
--   Flow_shape DOUBLE,
--   Tplat DOUBLE,
--   Vtapnea DOUBLE,
--   F_apnea DOUBLE,
--   T_apnea DOUBLE,
--   Tins DOUBLE,
--   Pimax DOUBLE,
--   F_ent DOUBLE,
--   PS_PVACI DOUBLE,
--   FiO2_CPV DOUBLE,
--   RR_CPV DOUBLE,
--   PI_CPV DOUBLE,
--   Thigh_CPV DOUBLE,
--   Heigh DOUBLE,
--   Gender DOUBLE,
--   Coeff DOUBLE,
--   O2_low_pressure DOUBLE,
--   Peak_flow DOUBLE,
--   Created_at TIMESTAMP
-- ) WITH (
--   KAFKA_TOPIC='ventilation_settings_topic',
--   VALUE_FORMAT='JSON',
--   PARTITIONS=2
-- );

-- CREATE STREAM IF NOT EXISTS ALARMS_SETTINGS_STREAM (
--   Alarm_settings_id INT,
--   Ppeak DOUBLE,
--   VTiMin DOUBLE,
--   VTiMax DOUBLE,
--   VTeMin DOUBLE,
--   VTeMax DOUBLE,
--   MViMin DOUBLE,
--   MViMax DOUBLE,
--   MVeMin DOUBLE,
--   MVeMax DOUBLE,
--   RR_min DOUBLE,
--   RR_max DOUBLE,
--   Fio2Min DOUBLE,
--   Fio2Max DOUBLE,
--   Etco2Min DOUBLE,
--   Etco2Max DOUBLE,
--   Fico2Max DOUBLE,
--   Pmin DOUBLE,
--   PplatMax DOUBLE,
--   FreqCTMin DOUBLE,
--   FreqCTMax DOUBLE,
--   Created_at TIMESTAMP
-- ) WITH (
--   KAFKA_TOPIC='alarms_settings_topic',
--   VALUE_FORMAT='JSON',
--   PARTITIONS=2
-- );


CREATE STREAM IF NOT EXISTS DEVICE_STREAM(
  device_id INT,
  device_name VARCHAR,
  created_at TIMESTAMP
  ) WITH (
  KAFKA_TOPIC='postgres_debezium_pg_topic_device',
  VALUE_FORMAT='JSON',
  PARTITIONS=1
);

CREATE STREAM IF NOT EXISTS MEASURE_STREAM WITH (
  KAFKA_TOPIC='postgres_debezium_pg_topic_measure',
  VALUE_FORMAT='JSON',
  PARTITIONS=1
);

CREATE STREAM IF NOT EXISTS STATUS_STREAM WITH (
  KAFKA_TOPIC='postgres_debezium_pg_topic_status',
  VALUE_FORMAT='JSON',
  PARTITIONS=1
);

CREATE STREAM IF NOT EXISTS ALARMS_SETTINGS_STREAM WITH (
  KAFKA_TOPIC='postgres_debezium_pg_topic_alarmssettings',
  VALUE_FORMAT='JSON',
  PARTITIONS=1
);

CREATE STREAM IF NOT EXISTS VENTILATION_SETTINGS_STREAM WITH (
  KAFKA_TOPIC='postgres_debezium_pg_topic_ventilationsettings',
  VALUE_FORMAT='JSON',
  PARTITIONS=1
);

DROP STREAM IF EXISTS DEVICE_STREAM;
DROP STREAM IF EXISTS MEASURE_STREAM;
DROP STREAM IF EXISTS STATUS_STREAM;
DROP STREAM IF EXISTS ALARMS_SETTINGS_STREAM;
DROP STREAM IF EXISTS VENTILATION_SETTINGS_STREAM;

-- CREATE STREAM DEVICE_JOIN_MEASURE WITH (
--     VALUE_FORMAT = 'AVRO'
--   ) AS 
-- SELECT D.DEVICE_ID, D.DEVICE_NAME, D.MEASURE_ID, M.*
-- FROM DEVICE_STREAM D 
--   LEFT JOIN MEASURE_STREAM M
--   WITHIN 1 HOURS GRACE PERIOD 15 MINUTES
--   ON D.MEASURE_ID = M.MEASURE_ID
--  EMIT CHANGES;
