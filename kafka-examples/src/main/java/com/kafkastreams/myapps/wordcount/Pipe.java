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
package com.kafkastreams.myapps.wordcount;

import java.util.Properties;
import java.util.concurrent.CountDownLatch;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.kstream.KStream;

/**
 * In this example, we implement a simple Pipe program using the high-level
 * Streams DSL that reads from a source topic "streams-plaintext-input", where
 * the values of messages represent lines of text, and writes the messages as-is
 * into a sink topic "streams-pipe-output".
 */
public class Pipe {
    private static final String INPUT_TOPIC = "streams-plaintext-input";
    private static final String OUTPUT_TOPIC = "streams-plaintext-output";

    public static final String THREAD_NAME_HOOK = "streams-shutdown-hook";

    public static void main(String[] args) throws Exception {
        Properties properties = new Properties();
        properties.put(StreamsConfig.APPLICATION_ID_CONFIG, "streams-pipe");
        properties.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        properties.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG,
                Serdes.String().getClass());
        properties.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG,
                Serdes.String().getClass());

        final StreamsBuilder streamsBuilder = new StreamsBuilder();
        KStream<String, String> source = streamsBuilder.stream(INPUT_TOPIC);
        source.to(OUTPUT_TOPIC);
        final Topology topology = streamsBuilder.build();

        System.out.println(topology.describe());

        final KafkaStreams streams = new KafkaStreams(topology, properties);

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
            throw e;
        }
    }
}
