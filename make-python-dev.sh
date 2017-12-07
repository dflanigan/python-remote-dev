#!/bin/bash

set -x

docker_name_prefix='python-dev'
if [ -n "$1" ] ; then
    docker_name_prefix=$1
fi

ssh_port='5122'
if [ -n "$2" ] ; then
    ssh_port=$2
fi

docker_name="$docker_name_prefix-$ssh_port"


docker_file='Dockerfiles/Dockerfile'
if [ -n "$3" ] ; then
    docker_file=$3
fi

echo "Creating $docker_name from Dockerfile $docker_file"

if [ ! -f ~/.ssh/docker_dev ] ; then
    echo "Please generate docker_dev ssh key"
fi


sed "s/CONTAINER_NAME/$docker_name/g" Install-Files/bash_profile_template > Install-Files/bash_profile

#docker build -t your-base-image . # optional if you want this in here

docker build -f "$docker_file" \
     --build-arg AUTH_KEY="$(cat ~/.ssh/docker_dev.pub)" \
     -t "$docker_name_prefix:latest" .
     
# -V $(pwd):$(pwd) will align our pycharm project's directory structure with docker's
docker run -d -p "127.0.0.1:$ssh_port:5022" \
           --name $docker_name \
           -v $HOME:$HOME "$docker_name_prefix:latest" /usr/sbin/sshd -D # run sshd without detach

 