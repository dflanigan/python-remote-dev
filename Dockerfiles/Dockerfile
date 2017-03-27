FROM python:latest

COPY Install-Files/sshd_config Install-Files/ssh-install.sh /root/
COPY Install-Files/pip.conf /root/.config/pip/pip.conf

ARG AUTH_KEY

RUN /root/ssh-install.sh
