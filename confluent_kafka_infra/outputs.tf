output "resource-ids" {
  value = <<-EOT
#=============================== codepipeline Credentials =============================================
 kafka_id        = "${confluent_kafka_cluster.basic.id}"
 kafka_env        = "${confluent_environment.staging.id}"
 kafka_rest_endpoint = "${confluent_kafka_cluster.basic.rest_endpoint}"
 kafka_api_key    = "${confluent_api_key.app-manager-kafka-api-key.id}" 
 kafka_api_secret = "${confluent_api_key.app-manager-kafka-api-key.secret}" 
 github_token = "" # PAT created from the requests repo
 github_repo = "" # The requests repository where PRs would be raised


# =============================== Github Actions Credentials ==========================================
CONFLUENT_CLOUD_API_KEY = ${confluent_api_key.app-manager-kafka-api-key.id}
CONFLUENT_CLOUD_API_SECRET = ${confluent_api_key.app-manager-kafka-api-key.secret}
CONFLUENT_CLOUD_ENV = ${confluent_environment.staging.id}
CONFLUENT_CLOUD_CLUSTER = ${confluent_kafka_cluster.basic.id}


#================================  Metrics  Credentials ===============================================
  Service Account: "${confluent_service_account.prometheus_metrics_importer.display_name}"
  Service Account ID: "${confluent_service_account.prometheus_metrics_importer.id}"
  Kafka API Key: "${confluent_api_key.metrics_importer_api.id}"
  Kafka API Secret: "${confluent_api_key.metrics_importer_api.secret}"


# ======================================= Test Producer Consumer ==============================================================
  kafka_bootstrap_endpoint = "${confluent_kafka_cluster.basic.bootstrap_endpoint}"
  ${confluent_service_account.app-manager.display_name}:                     ${confluent_service_account.app-manager.id}
  ${confluent_service_account.app-manager.display_name}'s Kafka API Key:     "${confluent_api_key.app-manager-kafka-api-key.id}"
  ${confluent_service_account.app-manager.display_name}'s Kafka API Secret:  "${confluent_api_key.app-manager-kafka-api-key.secret}"
2012-10-17
  ${confluent_service_account.app-producer.display_name}:                    ${confluent_service_account.app-producer.id}
  ${confluent_service_account.app-producer.display_name}'s Kafka API Key:    "${confluent_api_key.app-producer-kafka-api-key.id}"
  ${confluent_service_account.app-producer.display_name}'s Kafka API Secret: "${confluent_api_key.app-producer-kafka-api-key.secret}"

  ${confluent_service_account.app-consumer.display_name}:                    ${confluent_service_account.app-consumer.id}
  ${confluent_service_account.app-consumer.display_name}'s Kafka API Key:    "${confluent_api_key.app-consumer-kafka-api-key.id}"
  ${confluent_service_account.app-consumer.display_name}'s Kafka API Secret: "${confluent_api_key.app-consumer-kafka-api-key.secret}"

  In order to use the Confluent CLI v2 to produce and consume messages from topic '${confluent_kafka_topic.orders.topic_name}' using Kafka API Keys
  of ${confluent_service_account.app-producer.display_name} and ${confluent_service_account.app-consumer.display_name} service accounts
  run the following commands:

  # 1. Log in to Confluent Cloud
  $ confluent login

  # 2. Produce key-value records to topic '${confluent_kafka_topic.orders.topic_name}' by using ${confluent_service_account.app-producer.display_name}'s Kafka API Key
  $ confluent kafka topic produce ${confluent_kafka_topic.orders.topic_name} --environment ${confluent_environment.staging.id} --cluster ${confluent_kafka_cluster.basic.id} --api-key "${confluent_api_key.app-producer-kafka-api-key.id}" --api-secret "${confluent_api_key.app-producer-kafka-api-key.secret}"
  # Enter a few records and then press 'Ctrl-C' when you're done.
  # Sample records:
  # {"number":1,"date":18500,"shipping_address":"899 ","cost":15.00}
  # {"number":2,"date":18501,"shipping_address":"176","cost":5.00}
  # {"number":3,"date":18502,"shipping_address":"3437","cost":10.00}

  # 3. Consume records from topic '${confluent_kafka_topic.orders.topic_name}' by using ${confluent_service_account.app-consumer.display_name}'s Kafka API Key
  $ confluent kafka topic consume ${confluent_kafka_topic.orders.topic_name} --from-beginning --environment ${confluent_environment.staging.id} --cluster ${confluent_kafka_cluster.basic.id} --api-key "${confluent_api_key.app-consumer-kafka-api-key.id}" --api-secret "${confluent_api_key.app-consumer-kafka-api-key.secret}"
  # When you are done, press 'Ctrl-C'.

  #=====================================================================================================================================
  EOT

  sensitive = true
}