# Use a Docker Container as a PyCharm Remote Interpreter 

## What
This project updates a technique and set of scripts originally posted by
[Gabe Rives-Corbett](https://insights.untapt.com/integrating-pycharm-and-docker-with-debugging-support-7a53f9f48f38#.9c429pn1v).

A simple set of scripts and Dockerfiles, the project allows you to use a Docker container as a 
remote Python interpreter in the [PyCharm](https://www.jetbrains.com/pycharm/) integrated development 
environment (IDE). 

**Note:** While you can probably use this project with other IDEs that support remote Python interpreters, we have only verified it with PyCharm. 

This project was developed using Mac OS with [Docker for Mac](https://docs.docker.com/docker-for-mac/) installed.

## Why
A Python project should fully isolate its compilers and dependencies from those of other projects, to avoid confusion and mistakes. 

What we can avoid by using a Docker container as a PyCharm remote interpreter:

* Any individual project's dependencies interfering with other projects' dependencies.
* Installation of multiple versions of Python in a project's development environment.
* Installation of Python compilers or packages that could interfere with the Host OS Python version.

## Other Choices
There are other ways to isolate dependencies and compilers. The simpliest is to make 
sure the Python path in your project's development environment contains the desired compiler. 
The python utility [virtualenv](https://virtualenv.pypa.io/en/stable/) is a good choice, but it uses Python compilers 
installed on the Host OS. [ValGrind](http://valgrind.org/) can also be used to create remote Python interpreters.

## Prerequisites 

### Set up SSH access
Pycharm will use ssh to connect to the Docker container, via `sshd`. The setup script and Dockerfile look for
an ssh key file in your /.ssh directory named `docker-dev`. 

- Create the `docker_dev` key:

```
ssh-keygen -t rsa -f ~/.ssh/docker_dev -N ""
```

- Configure your .ssh/config to use the `docker_dev` key:

```
Host localhost
    Hostname localhost
    User root
    IdentityFile ~/.ssh/docker_dev
```

## Create a container
The [Dockerfile](/Dockerfiles/Dockerfile) in this repo uses the Python 3.6 [DockerHub](https://hub.docker.com/_/python/) image as its base. You can edit the Dockerfile to use the base image that best suits your needs.

To create a container, run the [make-python-dev.sh](/make-python-dev.sh) script. 
Pass in arguments to name the Docker image (e.g., `proj-one`) and the port for the ssh connection (e.g., `5822`). 

The example command below creates a Docker container named `proj-one-5822`. 

```
make-python-dev.sh proj-one 5822 Dockerfiles/Dockerfile
```

You can now use your `docker_dev` key to ssh into the container:

```
ssh localhost -p 5822
```

**Note:** If the above command doesn't work, there may be issues with the ssh configuration; if this is the case, try the command below:

```
ssh -i ~/.ssh/docker_dev root@localhost -p 5822
```

## Configure PyCharm
To add this container as the project interpreter:
1. Open the Preferences window.
1. Click on the Project settings.
1. Select Project Interpreter.
1. One the far right side of the project Interpreter line, click the "..." button to open the menu.
1. Click "add remote".

In the next window that pops up:
1. Select "SSH credentials".
1. Enter "localhost" for the hostname.
1. Use the port number you assigned to the Docker container (5822 in the example above).
1. The username is "root".
1. Auth Type is "private key".
1. Set the private key file to `~/.ssh/docker-dev`.
1. Leave the passphrass blank.
1. Set the path to the python interpreter to `/usr/local/bin/python`.

That should be it! PyCharm will upload some support scripts after you save the new configuration. 
To test your configuration, open the Python Console in PyCharm (bottom Left tab); it should display the Python
version used in the Docker container. Now, when you run or debug scripts in PyCharm, it will use your Docker container.

## Notes
- The remote interpreter script mounts the path to the home directory of the host OS in the Docker container. The assumption is that your Python project is somewhere in the home directory. 
- You'll need to install your project's dependencies in the container using `pip` or a setup.py script.
- The base docker image for python 3 actually has two versions of python:
  - `/usr/bin/python` is version 2.7 of Python.
  - `/usr/local/bin/python` is version 3 of Python.
- The install scripts use `apt-get` to install sshd. If you change the base docker image, be sure to update the install commands in the script accordingly.
