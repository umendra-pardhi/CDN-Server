# Simple CDN

A lightweight, API-key-protected static file CDN built using **Nginx,
Python, and Docker**.

Nginx handles high-performance file delivery, while Python validates API
keys before allowing access.

## Features

-   Local file storage.
-   Single API key authentication.
-   No database or upload functionality.
-   Direct file access by filename.
-   HTTP Range support for video streaming.
-   Nginx performance optimizations.
-   Request rate limiting.
-   Docker-based deployment.

## Project Structure

``` text
simple-cdn/
├── auth.py
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
├── setup.ps1
├── .env
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

The setup script automatically:

1.  Checks Docker availability.
2.  Creates the `static` directory.
3.  Generates a secure API key.
4.  Creates the `.env` file.
5.  Builds the Docker images.
6.  Starts Nginx and Python authentication services.
7.  Displays the CDN URL and API key.

### Linux --- Manual Setup

#### 1. Create the static directory

``` bash
mkdir -p static
```

#### 2. Generate an API key

``` bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Copy the generated key for the next step.

#### 3. Create the `.env` file

Create a file named `.env` in the project root:

``` env
CDN_API_KEY=YOUR_GENERATED_SECRET_KEY
```

Replace `YOUR_GENERATED_SECRET_KEY` with the key generated in the
previous step.

#### 4. Start the CDN

``` bash
docker compose up -d --build
```

#### 5. Verify the containers

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

**Every request requires a valid API key.** Opening these URLs directly
in a browser without sending the required header will not authenticate
the request.

## API Usage

Set your API key in the examples below by replacing `YOUR_API_KEY`.

### Download a file

``` bash
curl -H "X-API-Key: YOUR_API_KEY" \
  http://localhost:8080/logo.png \
  -o logo.png
```

### Check file headers

``` bash
curl -I -H "X-API-Key: YOUR_API_KEY" \
  http://localhost:8080/logo.png
```

### Video streaming --- Range request

The following example requests the first 1 MiB of a video:

``` bash
curl -H "X-API-Key: YOUR_API_KEY" \
  -H "Range: bytes=0-1048575" \
  http://localhost:8080/video.mp4 \
  -o video-part.mp4
```

## Configuration

The `.env` file contains the shared API key:

``` env
CDN_API_KEY=YOUR_SECRET_KEY
```

To change the API key:

1.  Update `CDN_API_KEY` in `.env`.
2.  Restart the authentication service:

``` bash
docker compose restart auth
```

Ensure that the authentication service reads the updated environment
variable when it restarts.

## Docker Commands

  Operation                         Command
  --------------------------------- ---------------------------------------------
  Start                             `docker compose up -d`
  Build and start                   `docker compose up -d --build`
  Stop and remove containers        `docker compose down`
  Restart services                  `docker compose restart`
  Check status                      `docker compose ps`
  View all logs                     `docker compose logs -f`
  View Nginx logs                   `docker compose logs -f nginx`
  View Python authentication logs   `docker compose logs -f auth`
  Check Nginx configuration         `docker compose exec nginx nginx -t`
  Reload Nginx                      `docker compose exec nginx nginx -s reload`
  View resource usage               `docker stats`

## Production Deployment

For public deployment:

1.  Deploy the project on a Linux server.
2.  Configure a domain name pointing to the server IP address.
3.  Configure HTTPS using a TLS reverse proxy or Nginx.
4.  Keep the Python authentication service private; do not expose its
    port publicly.
5.  Expose only the required public HTTP/HTTPS ports.
6.  Protect `.env` and restrict access to the `static` directory.

**Important:** Do not send the shared API key over public HTTP. Use
HTTPS in production.

## Notes

-   Files are managed directly through the `static` directory.
-   No Docker rebuild is required when adding or replacing ordinary
    static files, provided the directory is mounted into the container
    as configured.
-   No database or upload API is included.
-   Python handles authentication only; Nginx handles file delivery.
-   The current implementation is designed for single-server deployment.

## Security Considerations

-   Keep `.env` out of version control. Add it to `.gitignore`.
-   Use a long, randomly generated API key.
-   Restrict filesystem permissions on `.env` and `static/`.
-   Use HTTPS for all public access.
-   Apply appropriate rate limits and monitor access logs.
-   A shared API key grants the same access to every holder. Rotate it
    if it is exposed.
