# Docker image for ps3netsrv-go

[![Build status](https://github.com/cryptofyre/docker-ps3netsrv-go/actions/workflows/docker.yml/badge.svg?branch=main)](https://github.com/cryptofyre/docker-ps3netsrv-go/actions/workflows/docker.yml)

Image: `ghcr.io/cryptofyre/docker-ps3netsrv-go`

Container image for [xakep666/ps3netsrv-go](https://github.com/xakep666/ps3netsrv-go), a Go reimplementation of ps3netsrv used by WebMAN/IrisMAN to serve PS3 content over the network.

This fork builds the upstream Go binary directly (no s6 overlay, no legacy C code) and publishes multi-arch images to GHCR.

## What’s inside
- Built from upstream `ps3netsrv-go` (default ref: `master`; tag builds use the tag).
- Static binary (`CGO_ENABLED=0`) with defaults tuned for container use.
- Runs as non-root user `ps3netsrv` (uid/gid 1000) by default.
- Multi-arch: `linux/amd64`, `linux/arm64`, `linux/arm/v7`.

## Tags
- `latest` – default branch build
- `edge` – same as `latest` (kept for parity)
- `v*` – published from matching git tags in this repo

Images are published to `ghcr.io/cryptofyre/docker-ps3netsrv-go`.

## Quick start
```bash
docker run -d \
  --name=ps3netsrv-go \
  -p 38008:38008 \
  -v /path/to/games:/srv/ps3data \
  ghcr.io/cryptofyre/docker-ps3netsrv-go:latest
```

## Configuration
The container entrypoint is `ps3netsrv-go server`. Common settings (all are passed through to upstream and also work via env or flags):

| Env var | Description | Default |
| --- | --- | --- |
| `PS3NETSRV_ROOT` | Root directory served to clients | `/srv/ps3data` |
| `PS3NETSRV_LISTEN_ADDR` | Listen address/port | `0.0.0.0:38008` |
| `PS3NETSRV_ALLOW_WRITE` | Enable write operations | `true` |
| `PS3NETSRV_STRICT_ROOT` | Protect against path traversal/symlinks | `true` |
| `PS3NETSRV_CLIENT_WHITELIST` | Optional IP whitelist | *(empty)* |
| `PS3NETSRV_MAX_CLIENTS` | Limit concurrent clients (0 = no limit) | `0` |
| `PS3NETSRV_READ_TIMEOUT` | Command timeout (e.g. `30s`, `0` to disable) | `0` |
| `PS3NETSRV_DEBUG` / `PS3NETSRV_JSON_LOG` | Verbose / JSON logging | `false` |

The upstream also supports a config file (`config.ini`) discovered as described in the upstream README.

## Volumes and ports
- Volume: `/srv/ps3data` (map your games here; include `PS3ISO`/`GAMES` folders, etc.).
- Port: `38008/TCP` (map with `-p 38008:38008` or change `PS3NETSRV_LISTEN_ADDR`).

## Docker Compose example
```yaml
services:
  ps3netsrv-go:
    image: ghcr.io/cryptofyre/docker-ps3netsrv-go:latest
    restart: unless-stopped
    ports:
      - "38008:38008"
    volumes:
      - /path/to/games:/srv/ps3data
    environment:
      PS3NETSRV_ALLOW_WRITE: "true"
      PS3NETSRV_STRICT_ROOT: "true"
```

## User / permissions
The container runs as `ps3netsrv` (uid/gid 1000). If your host data is owned by a different user, either:
- run with `--user <uid>:<gid>`, or
- adjust ownership/ACLs on the host path.

## Troubleshooting
- Ensure your games directory includes `PS3ISO` and/or `GAMES`.
- If clients cannot connect, verify port mapping and any `PS3NETSRV_CLIENT_WHITELIST` value.
- For performance: use wired LAN and SSD/NVMe storage; decrypted ISOs reduce CPU load.

## Support
Issues and PRs: https://github.com/cryptofyre/docker-ps3netsrv-go
