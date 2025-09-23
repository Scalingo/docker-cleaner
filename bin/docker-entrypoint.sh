#!/bin/bash

if [[ "$1" = "bundle" || "$1" = "ruby" ]] ; then
	exec $@
fi

exec bundle exec ruby bin/docker-cleaner $@
