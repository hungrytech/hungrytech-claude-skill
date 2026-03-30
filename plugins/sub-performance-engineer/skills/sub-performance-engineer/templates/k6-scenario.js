import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const orderDuration = new Trend('order_duration');

export const options = {
  stages: [
    { duration: '{RAMP_UP}', target: {TARGET_VUS} },
    { duration: '{STEADY}', target: {TARGET_VUS} },
    { duration: '{RAMP_DOWN}', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(99)<{P99_THRESHOLD}'],
    http_req_failed: ['rate<0.01'],
    errors: ['rate<0.05'],
  },
};

const BASE_URL = '{BASE_URL}';
const HEADERS = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer {AUTH_TOKEN}',
};

export default function () {
  group('{SCENARIO_NAME}', () => {
    // GET list
    const listRes = http.get(`${BASE_URL}/{RESOURCE}`, { headers: HEADERS });
    check(listRes, {
      'list status 200': (r) => r.status === 200,
      'list has data': (r) => JSON.parse(r.body).data.length > 0,
    }) || errorRate.add(1);

    sleep(1);

    // POST create
    const payload = JSON.stringify({SAMPLE_PAYLOAD});
    const createRes = http.post(`${BASE_URL}/{RESOURCE}`, payload, { headers: HEADERS });
    check(createRes, {
      'create status 201': (r) => r.status === 201,
    }) || errorRate.add(1);

    orderDuration.add(createRes.timings.duration);
    sleep(1);
  });
}
