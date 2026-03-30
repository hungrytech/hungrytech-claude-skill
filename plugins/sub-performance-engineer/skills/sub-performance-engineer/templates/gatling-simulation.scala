package {PACKAGE}

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class {SIMULATION_NAME}Simulation extends Simulation {

  val httpProtocol = http
    .baseUrl("{BASE_URL}")
    .header("Content-Type", "application/json")
    .header("Authorization", "Bearer {AUTH_TOKEN}")

  val scn = scenario("{SCENARIO_NAME}")
    .exec(
      http("List {RESOURCE}")
        .get("/{RESOURCE}")
        .check(status.is(200))
    )
    .pause(1)
    .exec(
      http("Create {RESOURCE}")
        .post("/{RESOURCE}")
        .body(StringBody("""{SAMPLE_PAYLOAD}""")).asJson
        .check(status.is(201))
    )
    .pause(1)

  setUp(
    scn.inject(
      rampUsersPerSec(1).to({TARGET_RPS}).during({RAMP_UP_DURATION}.seconds),
      constantUsersPerSec({TARGET_RPS}).during({STEADY_DURATION}.seconds),
      rampUsersPerSec({TARGET_RPS}).to(0).during({RAMP_DOWN_DURATION}.seconds)
    )
  ).protocols(httpProtocol)
    .assertions(
      global.responseTime.percentile3.lt({P99_THRESHOLD}),
      global.successfulRequests.percent.gt(99.0)
    )
}
