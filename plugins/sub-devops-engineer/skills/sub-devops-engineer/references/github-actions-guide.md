# GitHub Actions 가이드

> 워크플로우 구문, 재사용, 캐싱, 시크릿 관리.

---

## 기본 구조

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21
      - uses: gradle/actions/setup-gradle@v4
      - run: ./gradlew build
```

## 캐싱

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

## 시크릿

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## 재사용 워크플로우

```yaml
jobs:
  call-workflow:
    uses: ./.github/workflows/reusable-build.yml
    with:
      java-version: 21
    secrets: inherit
```

## Matrix 빌드

```yaml
strategy:
  matrix:
    java-version: [17, 21]
    os: [ubuntu-latest, macos-latest]
```
