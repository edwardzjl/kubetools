#!/usr/bin/env bash

while getopts ":n:l:" opt; do
	case $opt in
	n)
		NAMESPACE="$OPTARG"
		;;
	l)
		if [[ $OPTARG == *"="* ]]; then
			LABEL_KEY="$(cut -d'=' -f1 <<<$OPTARG)"
			LABEL_VALUE="$(cut -d'=' -f2 <<<$OPTARG)"
		else
			LABEL_KEY="$OPTARG"
		fi
		;;
	\?)
		echo "Invalid option -$OPTARG" >&2
		;;
	esac
done

if [[ -n "$NAMESPACE" ]]; then
	NAMESPACE_QUERY="-n $NAMESPACE"
fi

if [[ -n "$LABEL_KEY" ]] && [[ -n "$LABEL_VALUE" ]]; then
	LABEL_QUERY="-l $LABEL_KEY=$LABEL_VALUE"
elif [[ -n "$LABEL_KEY" ]]; then
	LABEL_QUERY="-l $LABEL_KEY"
fi

kubectl api-resources --verbs=list --namespaced -o name |
	xargs -n 1 kubectl get --show-kind --ignore-not-found $LABEL_QUERY $NAMESPACE_QUERY
