# honeygain-cli

```bash
curl -fsSL https://raw.githubusercontent.com/potados99/honeygain-cli/main/install.sh | bash
```

Honeygain only provides a Docker image for Linux — no standalone CLI. This repo extracts the CLI binary and its dependencies from the Docker image so you can run it directly. arm64 only.

## How it works

`extract.sh` pulls the latest Docker image, copies out the binary and shared libraries, and drops them into `dist/<version>/`. Push to this repo, and `install.sh` picks up the latest version automatically.

## Usage

```
honeygain -email you@example.com -pass yourpass -device my-rpi -tou-accept
```
