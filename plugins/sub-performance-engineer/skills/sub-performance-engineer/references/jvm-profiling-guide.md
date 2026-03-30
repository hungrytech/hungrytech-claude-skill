# JVM 프로파일링 가이드

---

## Java Flight Recorder (JFR)

```bash
# 시작
jcmd <pid> JFR.start duration=60s filename=profile.jfr

# 분석
jfr print --events jdk.GCPausePhase profile.jfr
```

주요 이벤트: `jdk.CPULoad`, `jdk.GarbageCollection`, `jdk.ThreadSleep`, `jdk.ObjectAllocationSample`

## async-profiler

```bash
# CPU 프로파일
./profiler.sh -d 30 -f flame.html <pid>

# 할당 프로파일
./profiler.sh -e alloc -d 30 -f alloc.html <pid>
```

## GC 튜닝

### G1GC (기본)
```
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
```

### ZGC (초저지연)
```
-XX:+UseZGC
-XX:+ZGenerational  # JDK 21+
```

| GC | 적합 조건 |
|----|----------|
| G1GC | 일반적인 서버 (기본값) |
| ZGC | P99 < 10ms 요구, 대형 힙 |
| Shenandoah | 낮은 레이턴시, OpenJDK |

## 힙 분석

```bash
jmap -dump:live,format=b,file=heap.hprof <pid>
```

Eclipse MAT로 분석: Leak Suspects Report, Top Consumers
