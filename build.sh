#!/usr/bin/env bash

docker build \
	--tag giammin/lldb-netcore \
	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0 \
    --build-arg CORECLR_BRANCH=v7.0.8 \
	.
