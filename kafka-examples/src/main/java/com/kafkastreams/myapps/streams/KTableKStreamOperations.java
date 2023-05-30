/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kafkastreams.myapps.streams;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.common.utils.Bytes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.kstream.*;
import org.apache.kafka.streams.state.KeyValueStore;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

/**
 * In this example, we implement a simple Pipe program using the high-level
 * Streams DSL that reads from a source topic "streams-plaintext-input", where
 * the values of messages represent lines of text, and writes the messages as-is
 * into a sink topic "streams-pipe-output".
 */
public class KTableKStreamOperations {
    private static final String INPUT_TOPIC = "basic-input-streams";
    private static final String OUTPUT_TOPIC = "basic-output-streams";

    private static final String APPLICATION_ID_CONFIG = "streams-ktable-kstream-operation";

    private static final String URL = "localhost:9092";

    public static final String THREAD_NAME_HOOK = "streams-shutdown-hook";

    public static final String ORDERNUMBERSTART = "orderNumber-";

    public static Properties getStreamsConfig(final String[] args) throws IOException {
        final Properties props = new Properties();
        if (args != null && args.length > 0) {
            try (final FileInputStream fis = new FileInputStream(args[0])) {
                props.load(fis);
            }
            if (args.length > 1) {
                System.out.println("Warning: Some command line arguments were ignored. This demo only accepts an optional configuration file.");
            }
        }
        props.putIfAbsent(StreamsConfig.APPLICATION_ID_CONFIG, APPLICATION_ID_CONFIG);
        props.putIfAbsent(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, URL);
        props.putIfAbsent(StreamsConfig.STATESTORE_CACHE_MAX_BYTES_CONFIG, 0);
        props.putIfAbsent(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        props.putIfAbsent(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());

        // setting offset reset to earliest so that we can re-run the demo code with the same pre-loaded data
        // Note: To re-run the demo, you need to use the offset reset tool:
        // https://cwiki.apache.org/confluence/display/KAFKA/Kafka+Streams+Application+Reset+Tool
        props.putIfAbsent(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        return props;
    }

    public static void createKTable(final StreamsBuilder streamsBuilder) {
        KTable<String, String> kTable = streamsBuilder.table(INPUT_TOPIC, Materialized.<String, String, KeyValueStore<Bytes, byte[]>>as("ktable-store").withKeySerde(Serdes.String()).withValueSerde(Serdes.String()));
        kTable.filter((key, value) -> value.contains(ORDERNUMBERSTART))
                .mapValues(value -> value.substring(value.indexOf("-") + 1))
                .filter((key, value) -> Long.parseLong(value) > 1000)
                .toStream()
                .peek((key, value) -> System.out.println("Outgoing record - key " + key + " value " + value))
                .to(OUTPUT_TOPIC, Produced.with(Serdes.String(), Serdes.String()));
    }

    public static void createKStream(final StreamsBuilder streamsBuilder) {
        KStream<String, String> firstStream = streamsBuilder.stream(INPUT_TOPIC, Consumed.with(Serdes.String(), Serdes.String()));
        firstStream.peek((key, value) -> System.out.println("Incoming record - key " + key + " value " + value))
                .filter((key, value) -> value.contains(ORDERNUMBERSTART))
                .mapValues(value -> value.substring(value.indexOf("-") + 1))
                .filter((key, value) -> Long.parseLong(value) > 1000)
                .peek((key, value) -> System.out.println("Outgoing record - key " + key + " value " + value))
                .to(OUTPUT_TOPIC, Produced.with(Serdes.String(), Serdes.String()));
    }

    public static void main(String[] args) {

        final StreamsBuilder streamsBuilder = new StreamsBuilder();
//        createKTable(streamsBuilder);
        createKStream(streamsBuilder);
        final Topology topology = streamsBuilder.build();

        System.out.println(topology.describe());

        try (KafkaStreams streams = new KafkaStreams(topology, getStreamsConfig(args))) {

            final CountDownLatch latch = new CountDownLatch(1);

            // attach shutdown handler to catch control-c
            Runtime.getRuntime().addShutdownHook(new Thread(THREAD_NAME_HOOK) {
                @Override
                public void run() {
                    latch.countDown();
                    streams.close();
                }
            });

            try {
                streams.start();
                latch.await();

            } catch (Throwable e) {
                System.err.println(e.getMessage());
                System.exit(1);
            }
        } catch (Throwable e) {
            System.err.println(e.getMessage());
        }
    }
}
