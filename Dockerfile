ARG BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0

FROM $BASE_IMAGE
RUN apt update && apt -y install lldb
RUN dotnet tool install -g dotnet-sos
RUN /root/.dotnet/tools/dotnet-sos install
RUN	ln -s /usr/share/dotnet/shared/Microsoft.NETCore.App/7.0.5/createdump /usr/bin/createdump

ENV COREDUMP_PATH /tmp/coredump
CMD /usr/bin/lldb-11 /usr/bin/dotnet --core $COREDUMP_PATH -o 'plugin load libsosplugin.so' -o 'sos PrintException -lines'
