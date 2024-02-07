#!/bin/sh
apk update
apk add apache2
rc-update add apache2
service apache2 start