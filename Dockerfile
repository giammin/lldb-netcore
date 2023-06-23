ARG BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0
FROM $BASE_IMAGE AS build
ARG CORECLR_BRANCH=v7.0.8
RUN apt update && \
    apt install -y cmake lsb-release wget software-properties-common gnupg && \
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" && \
   	apt-get install -y \
		cmake \
		libunwind8 \
		libunwind8-dev \
		gettext \
		libicu-dev \
		liblttng-ust-dev \
		libcurl4-openssl-dev \
		libssl-dev \
		uuid-dev \
		libnuma-dev \
		libkrb5-dev \
		git && \
	git clone https://github.com/dotnet/runtime.git /coreclr
WORKDIR /coreclr
RUN git checkout $CORECLR_BRANCH
COPY patches /patches
RUN if [ -f /patches/$CORECLR_BRANCH.patch ] ; then git apply /patches/$CORECLR_BRANCH.patch ; fi
RUN ./build.sh clang16.0 

FROM $BASE_IMAGE
RUN apt-get update && \
	apt-get install -y \
		lldb-16 && \
	rm -rf /var/lib/apt/lists/* && \
	ln -s /coreclr/createdump /usr/bin/createdump
COPY --from=build /coreclr/bin/Product/Linux.x64.Debug /coreclr

ENV COREDUMP_PATH /tmp/coredump
CMD /usr/bin/lldb-16 /usr/bin/dotnet --core $COREDUMP_PATH -o 'plugin load /coreclr/libsosplugin.so' -o 'sos PrintException -lines'
