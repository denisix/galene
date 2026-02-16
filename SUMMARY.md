# Galene Videoconferencing System

Lightweight WebRTC videoconferencing server with moderate resource requirements.

## Quick Start

```sh
# Build
CGO_ENABLED=0 go build -ldflags='-s -w'

# Run
mkdir groups data
./galene &
```

## Architecture

- **Language**: Go (backend), JavaScript (frontend)
- **Protocol**: WebRTC + WebSocket signaling
- **Port**: 8443 (HTTPS/WebSocket), 1194 (TURN)
- **Components**:
  - `galene` - main server binary
  - `galenectl` - admin CLI tool
  - `static/` - web frontend

## Configuration

### Global (`data/config.json`)
```json
{
  "users": {"admin": {"password":"...", "permissions":"admin"}},
  "writableGroups": true,
  "allowOrigin": ["*"],
  "canonicalHost": "galene.example.org"
}
```

### Group (`groups/<name>.json`)
```json
{
  "users": {"user": {"password":"...", "permissions": "present"}},
  "public": true,
  "max-clients": 100,
  "codecs": ["vp8", "opus"]
}
```

### Permissions
- `op` - operator (moderation)
- `present` - publish audio/video, chat
- `message` - chat only
- `observe` - read-only
- `admin` - group administration

## Key Features

- Built-in TURN server
- Simulcast & SVC (VP8/VP9)
- P2P file transfer
- Background blur (MediaPipe, optional)
- WHIP protocol
- Screen sharing
- Recording to disk
- Token-based auth (JWT/stateful)

## Authentication Methods

1. **Password**: Username/password in group config
2. **Stateful Tokens**: Stored in `data/var/tokens.jsonl`
3. **Cryptographic Tokens**: JWT signed by external auth server

## Network Ports

- TCP 8443 - HTTPS/WebSocket
- TCP/UDP 1194 - TURN server
- UDP high ports - media (restrict with `-udp-range`)

## Admin API

**Base**: `/galene-api/v0/`

- `GET /.groups/` - list groups
- `GET/PUT/DELETE /.groups/<name>` - group definition
- `GET /.groups/<name>/.users/` - list users
- `PUT/POST/DELETE /.groups/<name>/.users/<user>/.password` - password management

## galenectl Commands

```sh
galenectl initial-setup                    # create admin
galenectl create-group -group <name>        # new group
galenectl create-user -group <name> -user <user> -permissions op
galenectl set-password -group <name> -user <user>
galenectl create-token -group <name>        # generate invite link
```

## Client Protocol

1. GET `<group-url>/.status` → JSON with endpoint
2. WebSocket connect
3. Send `handshake`, then `join` with credentials
4. Exchange `offer`/`answer`/`ice` for WebRTC

## Message Types

| Type | Purpose |
|------|---------|
| `handshake` | Version negotiation |
| `join`/`joined` | Group membership |
| `offer`/`answer`/`ice` | WebRTC setup |
| `chat` | Chat messages |
| `useraction` | Kick, op, mute, etc. |
| `groupaction` | Lock, record, etc. |

## Common Issues

- **Connection fails**: Check firewall (8443, 1194, UDP high ports)
- **Poor quality**: Use TURN relay, check bandwidth
- **Safari**: Known screenshare issues
- **Can't join**: Group locked or bad credentials

## Build Options

```sh
# Cross-compile for ARM64
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags='-s -w'

# Enable background blur
make release  # installs MediaPipe library
```
