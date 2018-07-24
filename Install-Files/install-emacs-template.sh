#!/usr/bin/env bash

cp HOME/.emacs /root
cp -R HOME/.emacs.d /root

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install emacs-nox




