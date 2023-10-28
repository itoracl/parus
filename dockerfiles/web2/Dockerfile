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
#      $ docker build -t parus8561web2${EDITION} . 
#
# Unpack artifacts
FROM busybox:latest AS unpack
WORKDIR /tmp
COPY extra.zip /tmp
RUN unzip extra.zip /extra

# Pull base image
# ---------------
FROM mcr.microsoft.com/dotnet/aspnet:3.1

COPY --from=unpack /tmp/ /

# Labels
# ------
LABEL "provider"="@itoracle"                                               \
      "issues"="https://github.com/itoracl/parus/issues"


# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV SVC_BASE=/extra \
    RUN_FILE="runSvc.sh"

USER dotnet
WORKDIR /extra


CMD $SVC_BASE/$RUN_FILE