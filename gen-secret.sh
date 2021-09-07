#!/usr/bin/env bash

if [ -z $1 ]; then
	echo "Source file not set!"
	exit 128
fi

SRC_FILE=$1

echo "Initializing secrets with file : $SRC_FILE"

if [ ! -f $SRC_FILE ]; then
	echo "File not found!"
	exit 128
fi

if [ -z $2 ]; then
	echo "Namespace not specified, secret will be set to default namespace!"
fi

kubectl create secret generic regcred --from-file=.dockerconfigjson=$SRC_FILE --type=kubernetes.io/dockerconfigjson ${2:+--namespace=$2}
