ARG BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0
# FROM $BASE_IMAGE AS build
# ARG CORECLR_BRANCH=v7.0.8
# RUN apt update && \
#     apt install -y locales locales-all cmake lsb-release wget software-properties-common gnupg && \
#     bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" && \
#    	apt-get install -y \
# 		libunwind8 \
# 		libunwind8-dev \
# 		gettext \
# 		libicu-dev \
# 		liblttng-ust-dev \
# 		libcurl4-openssl-dev \
# 		libssl-dev \
# 		uuid-dev \
# 		libnuma-dev \
# 		libkrb5-dev \
#         zlib1g-dev \
# 		git && \
#     locale-gen en_US.UTF-8 && \
# 	git clone https://github.com/dotnet/runtime.git /coreclr
# WORKDIR /coreclr
# RUN git checkout $CORECLR_BRANCH
# COPY patches /patches
# RUN if [ -f /patches/$CORECLR_BRANCH.patch ] ; then git apply /patches/$CORECLR_BRANCH.patch ; fi
# RUN ./build.sh

FROM $BASE_IMAGE
Run apt update && apt -y install lldb
Run dotnet tool install -g dotnet-sos
RUN /root/.dotnet/tools/dotnet-sos install
RUN	ln -s /usr/share/dotnet/shared/Microsoft.NETCore.App/7.0.5/createdump /usr/bin/createdump

ENV COREDUMP_PATH /tmp/coredump
CMD /usr/bin/lldb-11 /usr/bin/dotnet --core $COREDUMP_PATH -o 'plugin load libsosplugin.so' -o 'sos PrintException -lines'
