#
# @ITORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for PARUS ERP WEB2 
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) extra.zip
#     from ftp Parus SERVCIE disk
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t parusweb2:8.561:${EDITION} . 
#
# Unpack artifacts
FROM busybox:latest AS unpack
WORKDIR /tmp
ADD http://nexus-nexus-repository-manager.nexus:8081/repository/parus/service/8.561-0823/extra.zip .
RUN unzip extra.zip -d /
COPY . /extra

# Pull base image
# ---------------
FROM mcr.microsoft.com/dotnet/aspnet:3.1

COPY --from=unpack /extra /

# Labels
# ------
LABEL "provider"="@itoracle"                                               \
      "issues"="https://github.com/itoracl/parus/issues"

EXPOSE 5121

# Environment variables default values
ENV SVC_NAME="EmbWebProxy"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV SVC_BASE=/extra \
    RUN_FILE="runSvc.sh"

USER dotnet
WORKDIR /extra


CMD $SVC_BASE/$RUN_FILE