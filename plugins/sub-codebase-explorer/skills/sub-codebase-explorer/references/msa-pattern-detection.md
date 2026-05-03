# MSA 패턴 감지 카탈로그

## HTTP 클라이언트

| 언어 | 라이브러리 | 시그너처 패턴 | 동기/비동기 |
|------|-----------|--------------|-------------|
| Kotlin/Java | RestTemplate | `restTemplate.{exchange,getForObject,postForEntity,...}` | sync |
| Kotlin/Java | WebClient | `webClient.{get,post,...}.uri(...)` | async (Mono/Flux) |
| Kotlin/Java | OpenFeign | `@FeignClient(name="...")` | sync |
| Kotlin (Ktor) | HttpClient | `client.{get,post}` | async (suspend) |
| TypeScript | axios | `axios.{get,post,...}` | async (Promise) |
| TypeScript | fetch | `fetch(url, {method, ...})` | async |
| TypeScript | got, ky | `got.get(...)`, `ky.post(...)` | async |
| Python | requests | `requests.{get,post,...}` | sync |
| Python | httpx | `httpx.{get,...}`, `httpx.AsyncClient` | sync/async |
| Python | aiohttp | `aiohttp.ClientSession()` | async |
| Go | net/http | `http.NewRequest`, `client.Do` | sync (goroutine) |
| Go | resty | `resty.R().Get(...)` | sync |

## gRPC

| 언어 | 패턴 |
|------|------|
| Kotlin/Java | `*BlockingStub`, `*FutureStub`, `*Stub` (생성된 클래스) |
| Python | `grpc.insecure_channel(...) + stub = ServiceStub(channel)` |
| Go | `pb.NewServiceClient(conn)` |
| TypeScript | `@grpc/grpc-js` 또는 `nice-grpc` |

`*.proto` 파일 존재 여부도 강한 시그널.

## 메시지 브로커

### Kafka
| 언어 | 발행 | 구독 |
|------|------|------|
| Kotlin/Java | `kafkaTemplate.send(...)` | `@KafkaListener(topics=...)` |
| Python | `KafkaProducer().send(topic, ...)`, `aiokafka` | `KafkaConsumer(topic, ...)` |
| TypeScript (kafkajs) | `producer.send({topic, messages})` | `consumer.subscribe({topic})` |
| Go (kafka-go) | `kafka.NewWriter(...)` + `WriteMessages` | `kafka.NewReader(...)` + `ReadMessage` |

### RabbitMQ
| 언어 | 발행 | 구독 |
|------|------|------|
| Kotlin/Java | `rabbitTemplate.convertAndSend(...)` | `@RabbitListener(queues=...)` |
| Python | `pika.BasicPublish` | `channel.basic_consume(...)` |
| TypeScript (amqplib) | `channel.publish(exchange, key, ...)` | `channel.consume(queue, ...)` |

### AWS
| 서비스 | 발행 | 구독 |
|--------|------|------|
| SNS | `sns.publish(...)` | (다른 SQS 큐가 구독) |
| SQS | `sqs.sendMessage(...)` | `@SqsListener` (Spring Cloud AWS) |
| EventBridge | `eventBridge.putEvents(...)` | (Lambda 트리거) |

### Spring ApplicationEvent (in-process)
| 발행 | 구독 |
|------|------|
| `applicationEventPublisher.publishEvent(MyEvent(...))` | `@EventListener fun on(e: MyEvent)` |

## API Gateway / Service Mesh

탐지 키워드 (의존성 파일):
- kong, traefik, envoy, ambassador, krakend, zuul, spring-cloud-gateway

탐지 파일:
- `kong.yml`, `envoy.yaml`, `traefik.yml`
- `istio/*.yaml`, `linkerd/*.yaml`
