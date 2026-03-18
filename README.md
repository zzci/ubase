# ubase

Base Docker image built on Ubuntu 22.04 with common utilities pre-installed.

## Docker Hub

https://hub.docker.com/r/zzci/ubase

## Included Tools

- Common utilities: curl, jq, tree, tmux, unzip, less, file, sudo, gnupg
- Network tools: dnsutils, iptables
- [just](https://github.com/casey/just) command runner

## Usage

Requires [just](https://github.com/casey/just) installed locally.

```bash
# build the image
just build

# run a container
just run

# run and exec into it
just run bash

# exec into running container
just exec

# remove container
just rm

# export image
just pack
```
