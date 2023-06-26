# lldb-netcore
Docker image with lldb debugger and SOS plugin, compiled from sources with lldb headers.
By default loads process coredump from /tmp/coredump, loads SOS plugin and prints current exception, leaving lldb shell open.
Image tag matches dotnet runtime version.

## How to use
```bash
docker run --rm -it -v /stripe/upload/coredump:/tmp/coredump giammin/lldb-netcore
```
- /stripe/upload/coredump - Path to coredump of crashed process on docker host machine

## Use cases


1. [Process hang with idle CPU](hang_cpu_idle.md)
2. [Process hang with high CPU usage](hang_cpu_high.md)
3. [Process crash](crash.md)
4. [Excessive memory usage](memory.md)