# lldb-netcore
Docker image with lldb debugger and SOS plugin, compiled from sources with lldb headers.
By default loads process coredump from /tmp/coredump, loads SOS plugin and prints current exception, leaving lldb shell open.
Image tag matches dotnet runtime version.

## How to use
```bash
docker run --rm -it -v /stripe/upload/coredump:/tmp/coredump giammin/lldb-netcore
```
- /stripe/upload/coredump - Path to coredump of crashed process on docker host machine

## Usecases


1. [Process hang with idle CPU](https://github.com/giammin/lldb-netcore/blob/master/hang_cpu_idle.md)
2. [Process hang with high CPU usage](https://github.com/giammin/lldb-netcore/blob/master/hang_cpu_high.md)
3. [Process crash](https://github.com/giammin/lldb-netcore/blob/master/crash.md)
4. [Excessive memory usage](https://github.com/giammin/lldb-netcore/blob/master/memory.md)


### Container crashed

1. Copy crashed process working directory(coredump is automatically created in crashed process working directory) to temporary directory on host:
```bash
docker cp 79686a7aff63:/app /tmp
```
- 79686a7aff63 - id of container with crashed process
- /app - crashed process working directory inside container filesystem

2. Find crashed process coredump:
```bash
ls /tmp/app/core.*
```
example output:
```
/tmp/app/core.26939
```

3. Open coredump with debugger:
```bash
docker run --rm -it -v /tmp/app/core.26939:/tmp/coredump giammin/lldb-netcore
```
example output:
```
(lldb) target create "/usr/bin/dotnet" --core "/tmp/coredump"
Core file '/tmp/coredump' (x86_64) was loaded.
(lldb) plugin load /coreclr/libsosplugin.so
(lldb) sos PrintException
Exception object: 00007f3fb001ce08
Exception type:   System.NullReferenceException
Message:          Object reference not set to an instance of an object.
InnerException:   <none>
StackTrace (generated):
    SP               IP               Function
    00007FFCE0A312F0 00007F3FD7940481 test.dll!test.Program.Main(System.String[])+0x1
StackTraceString: <none>
HResult: 80004003
(lldb)
```

4. Continue exploring coredump in lldb shell:
```
help
```

### Analyze running container
1. Get id of docker container(docker ps) you need to analyze. In this example it is "b5063ef5787c"

2. Run container with createdump utility(it needs sys_admin and sys_ptrace privileges. If your running container already has these privileges you can attach to running container and run createdump utility from there):
```bash
docker run --rm -it --cap-add sys_admin --cap-add sys_ptrace --net=container:b5063ef5787c --pid=container:b5063ef5787c -v /tmp:/tmp giammin/lldb-netcore /bin/bash
```
- b5063ef5787c - id of container you need to analyze
- /tmp - temporary directory on host, where coredump will be created

3. Find PID of dotnet process you need to analyze:
```bash
ps aux
```
In this example PID is "7"

4. Create coredump of dotnet process and exit from container:
```bash
createdump -u -f /tmp/coredump 7
exit
```
- 7 is dotnet process PID

5. Open coredump with debugger:
```bash
docker run --rm -it -v /tmp/coredump:/tmp/coredump giammin/lldb-netcore
```
example output:
```
(lldb) target create "/usr/bin/dotnet" --core "/tmp/coredump"
Core file '/tmp/coredump' (x86_64) was loaded.
(lldb) plugin load /coreclr/libsosplugin.so
(lldb) sos PrintException
There is no current managed exception on this thread
(lldb)
```

6. Continue exploring coredump in lldb shell:
```
help
```

## How to build
### net 7.0.8:
```
docker build \
	--tag giammin/lldb-netcore:7.0.8 \
	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0 \
	--build-arg CORECLR_BRANCH=v7.0.8 \
	.
```
- BASE_IMAGE - Base image of dotnet sdk. Used both at build time and runtime.
- CORECLR_BRANCH - coreclr repository(https://github.com/dotnet/runtime.git) branch/tag to build SOS plugin from
