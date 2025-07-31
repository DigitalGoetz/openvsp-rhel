#!/bin/bash

APP="openvsp-builder"
VERSION="3.44.2"

docker build -t "${APP}:${VERSION}" .
# docker create --name $APP $APP:$VERSION
# docker cp $APP:/OpenVSP_3.44.2-Linux.rpm .
# docker rm $APP
