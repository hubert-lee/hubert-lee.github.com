#!/bin/sh

COMMAND=$1

function print_useage() {
	echo "Useage:"
	echo "  ./serve.sh [start|stop]"
	exit 
}

if [ -z ${COMMAND} ]; then
	print_useage
fi

if [ ${COMMAND} == "start" ]; then
	echo "run jekyll.."
	docker run --rm -v=${PWD}:/srv/jekyll \
		   --name hubert_blog \
		   -p 4000:4000 -d jekyll/jekyll jekyll serve --draft
	docker container ls
elif [ ${COMMAND} == "stop" ]; then
	echo "stop jekyll.."
	docker container kill hubert_blog
	docker container ls
else
	print_useage
fi



