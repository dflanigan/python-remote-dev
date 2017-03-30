# Using Docker Containers as PyCharm Remote Interpreters 

## What
This is an update to a technique and a set of scripts posted by
[Gabe Rives-Corbett](https://insights.untapt.com/integrating-pycharm-and-docker-with-debugging-support-7a53f9f48f38#.9c429pn1v).
It is a simple set of scripts and Dockerfiles to create and run a docker container
to be used as a remote python interpreter by the PyCharm integrated development 
environment. This technique could probably used by other IDEs 
that support remote python interpreters.

## Why
To avoid confusion and mistakes a python project should fully isolate its compilers 
and dependencies from other project compilers and dependencies. It is also important that 
a project be isolated from the python installed on the host operating system. For example: The Python 
installed on the host OS may be python 2, put your Python project requires Python 3.
What is being avoided:
* A project's dependencies interfering with another project's dependencies
* Installing multiple versions of python in a projects's development environment.
* Installing python compilers or packages that could interfere  with the Host OS.

## Other Choices
There are other ways to isolate dependencies and compilers.  The simpliest is to make 
sure the python path in development environement contains the desired compiler. The python utility virtualenv
is a good choice, but that technique still uses python compilers installed on the Host OS.
ValGrind could be used to create remote python interpreters.

## Prerequisites 
This project was developed using Mac OS with 
[Docker for Mac](https://docs.docker.com/docker-for-mac/) installed. 

Pycharm will use ssh to connect to the docker a container running sshd. The setup script and DockerFile will look for
an ssh key file in your .ssh directory named docker-dev. Here is an example of how
to create the key:
```
ssh-keygen -t rsa -f ~/.ssh/docker-dev -N ""
```
Here is an example of an update to the .ssh/config to use that key:
```
Host localhost
    Hostname localhost
    User root
    IdentityFile ~/.ssh/docker_dev
```

## Create a container
The base image that the Dockerfile in the Dockerfiles directory uses is the latest version of 
python (3.6 as of March 2017) from DockerHub. DockerHub has a many 
other [versions of python](https://hub.docker.com/_/python/) that can be use as well.

To create a container run the script make-python-dev.sh in the top directory 
of cloned copy of this project. The script takes some arguments; here is an example:
```
make-python-dev.sh proj-one 5822 Dockerfiles/Dockerfile
```

The first argument will be the name of the docker image.  The second argument will be
the port that ssh will use. The last argument is the Dockerfile.  In this case the script 
will create a docker container named proj-one-5822.  If the python-dev key has been created
and configured then the container can be ssh'ed to using this command:
```
ssh localhost -p 5822
```
If there are issues with ssh configuration, this command could be used as well:
```
ssh -i ~/.ssh/docker_dev root@localhost -p 5822
```

## Configure PyCharm
To add this container as the project interpreter:
1. Open the Preferences window using the Preferences menu item under PyCharm menu.
1. Open the Project settings on the left side of this window.
1. Select Project Interpreter.
1. One the far right side of the project Interpreter line open a menu using the "..." button.
1. In this menu select "add remote"

In the next window that pops up:
1. Select "SSH credentials"
1. Use localhost for the hostname
1. Use the port number used to configure the docker container.  In the above example that was 5822
1. The username is root
1. Auth Type is private key
1. Set the private key file to ~/.ssh/docker-dev
1. Leave the passphrass blank.
1. Set the path to the python interpreter to "/usr/local/bin/python"

That should be it.  PyCharm will upload some support scripts after configuration.  To test your configuration open 
up the Python Console in PyCharm (bottom Left tab) and it should display the the python
version of the python running in the docker container.  Now scripts run or debugged from PyCharm will run in the container.

## Notes
* The docker container used for the remote interpreter has mounted the path to the home directory of the host OS in the 
docker container. The assumption is that the python project is somewhere in the home directory.
* Dependencies will have to be installed in the container using pip or a setup.py script.
* The base docker image for python 3 actually has two versions of python:
  * ```/usr/bin/python``` is version 2.7 of python.
  * ```/usr/local/bin/python``` is version 3 of python
* The install scripts use apt-get to install sshd. If the base docker image changes, yum may be needed to install sshd instead.
