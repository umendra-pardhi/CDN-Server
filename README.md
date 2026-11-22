# Simple CDN

A lightweight public static file CDN built using **Nginx and Docker**.
Nginx serves files from the local `static` directory without requiring
an API key.

## Features

-   Local file storage.
-   No database or upload functionality.
-   Direct file access by filename.
-   HTTP Range support for video streaming.
-   Nginx performance optimizations.
-   Request rate limiting.
-   Docker-based deployment.

## Project Structure

``` text
simple-cdn/
├── docker-compose.yml
├── nginx.conf
├── setup.ps1
├── .gitignore
├── README.md
└── static/
    └── your-files-here
```

## Requirements

-   Docker Desktop (Windows) or Docker Engine (Linux).
-   Docker Compose v2.

Verify the installation:

``` bash
docker --version
docker compose version
```

## Setup and Installation

### Windows --- One-Click Setup

Open PowerShell in the project directory and execute:

``` powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

The setup script checks Docker availability, creates the `static`
directory, starts the Nginx container, and displays the CDN URL.

### Linux --- Manual Setup

Create the static directory and start the CDN:

``` bash
mkdir -p static
docker compose up -d --remove-orphans
```

Verify the container:

``` bash
docker compose ps
```

## Accessing Files

Copy the files you want to serve into the `static` directory.

Example:

``` text
static/
├── logo.png
├── banner.webp
├── app.js
└── video.mp4
```

Files are addressed directly by filename:

-   `http://localhost:8080/logo.png`
-   `http://localhost:8080/banner.webp`
-   `http://localhost:8080/video.mp4`

These URLs are public. Anyone who can reach the CDN can access files
stored in `static`; no API key or authentication header is required.

## API Usage

### Download a file

``` bash
curl http://localhost:8080/logo.png -o logo.png
```

### Check file headers

``` bash
curl -I http://localhost:8080/logo.png
```

### Video streaming --- Range request

The following example requests the first 1 MiB of a video:

``` bash
curl -H "Range: bytes=0-1048575" \
  http://localhost:8080/video.mp4 \
  -o video-part.mp4
```

## Docker Commands

  Operation                    Command
  ---------------------------- ---------------------------------------------
  Start                        `docker compose up -d --remove-orphans`
  Build and start              `docker compose up -d --build --remove-orphans`
  Stop and remove containers   `docker compose down`
  Restart services             `docker compose restart`
  Check status                 `docker compose ps`
  View logs                    `docker compose logs -f`
  View Nginx logs              `docker compose logs -f nginx`
  Check Nginx configuration    `docker compose exec nginx nginx -t`
  Reload Nginx                 `docker compose exec nginx nginx -s reload`
  View resource usage          `docker stats`

## Production Deployment

For public deployment:

1.  Deploy the project on a Linux server.
2.  Configure a domain name pointing to the server IP address.
3.  Configure HTTPS using a TLS reverse proxy or Nginx.
4.  Expose only the required public HTTP/HTTPS ports.
5.  Restrict write access to the `static` directory.

**Important:** This CDN is intentionally unauthenticated. Do not place
private or sensitive files in `static`. Use HTTPS in production.

## Notes

-   Files are managed directly through the `static` directory.
-   No Docker rebuild is required when adding or replacing ordinary
    static files, provided the directory is mounted into the container
    as configured.
-   No database or upload API is included.
-   Nginx handles file delivery directly.
-   The current implementation is designed for single-server deployment.

## Security Considerations

-   Files in `static/` are publicly accessible; do not store secrets or
    private content there.
-   Restrict write access to `static/`.
-   Use HTTPS for all public access.
-   Apply appropriate rate limits and monitor access logs.
