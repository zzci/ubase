# ubase

Base Docker image built on Ubuntu 22.04, layered on top of [zzci/init](https://hub.docker.com/r/zzci/init) (busybox + tini + supervisord).

## Docker Hub

https://hub.docker.com/r/zzci/ubase

## Image Stack

```
ubuntu:22.04
   + zzci/init           (busybox / tini / supervisord at /build/bin/)
   + apt packages        (see below)
   + just                (1.47.1)
   + locale en_US.UTF-8
   + rootfs              (helper scripts under /build/bin/)
```

`PATH` is extended with `/build/bin:/build/bin/busybox:/work/bin`, so busybox applets (vi, ping, unxz, gzip, tar, less, tree, wget, …) are always available as fallback.

## Included Packages

### Apt packages (Ubuntu 22.04)

| Category | Packages |
|---|---|
| System | `apt-utils` `ca-certificates` `uuid-runtime` `psmisc` `procps` `file` `iptables` `iproute2` `locales` `sudo` |
| Network / Download | `curl` `wget` `dnsutils` `openssh-client` `gnupg` |
| Dev / Editor | `git` `less` `tree` `jq` `tmux` `unzip` |

### Pre-built binaries

| Tool | Path | Source |
|---|---|---|
| `just` | `/usr/local/bin/just` | [casey/just](https://github.com/casey/just) v1.47.1 |
| `tini` | `/build/bin/tini` | from `zzci/init` |
| `supervisord` | `/build/bin/supervisord` | from `zzci/init` |
| `busybox` | `/build/bin/busybox/busybox` | from `zzci/init` (Alpine static) |

### Helper scripts (`/build/bin/`)

| Script | Purpose |
|---|---|
| `create_user` | Create a system user with fixed UID/GID and passwordless sudo |

## Helper: `create_user`

Create a regular user (default UID/GID = 1000) with home dir, bash shell, and passwordless sudo via `/etc/sudoers.d/`.

```bash
# Usage
create_user [user] [group] [uid] [gid]

# Or via env vars
USER_NAME=app GROUP_NAME=app USER_ID=1000 GROUP_ID=1000 create_user
```

Defaults:
- `user` = `tom`
- `group` = same as user
- `uid` = `1000`
- `gid` = `1000`

Behavior:
- Idempotent: re-running with the same name is a no-op.
- Conflict detection: errors out clearly if the requested UID/GID is already taken by a different user/group.
- Writes sudoers file to `/etc/sudoers.d/<user>` (mode 0440), never touches `/etc/sudoers`.

```bash
# Example: pin a runtime user matching host UID 1000 for volume mounts
RUN /build/bin/create_user app app 1000 1000
```

## Environment

| Variable | Value |
|---|---|
| `PATH` | `$PATH:/build/bin:/build/bin/busybox:/work/bin` |
| `LANG` / `LC_ALL` | `en_US.UTF-8` |
| `DEBIAN_FRONTEND` | `noninteractive` (build time) |
| `WORKDIR` | `/work` |

## Build args

| Arg | Default | Purpose |
|---|---|---|
| `JUST_VERSION` | `1.47.1` | Pin `just` release |
| `TARGETARCH` | (auto) | Used to pick `aarch64` vs `x86_64` for `just` |

## Usage

Requires [just](https://github.com/casey/just) installed locally.

```bash
just build      # build the image
just run        # start a container with /work mounted
just run bash   # run and exec into it
just exec       # exec into running container
just rm         # remove container
just pack       # export image as ubase.gz
```

Or directly with the `aa` helper script:

```bash
./aa build
./aa run
./aa exec bash
./aa rm
./aa pack
```
