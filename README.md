# HomeBox + brother_ql_next Container Image

[![Build and Push Docker Image](https://github.com/llewy/homebox-brother-ql/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/llewy/homebox-brother-ql/actions/workflows/build-and-push.yml)
[![Update Homebox Version](https://github.com/llewy/homebox-brother-ql/actions/workflows/update-homebox-version.yml/badge.svg)](https://github.com/llewy/homebox-brother-ql/actions/workflows/update-homebox-version.yml)

This is a combined container image allowing you to use a Brother QL series label printer as the "print on server" printer for HomeBox.

## Features

- 🏠 **HomeBox**: Full-featured home inventory management system  
- 🖨️ **Brother QL Support**: Direct integration with Brother QL series label printers
- 🐳 **Containerized**: Easy deployment with Docker/Podman
- 🔄 **Auto-Updates**: Automated workflow to keep HomeBox version current
- 📦 **GitHub Container Registry**: Images hosted reliably on GitHub's registry

## Usage
The image is available as:
```
ghcr.io/llewy/homebox-brother-ql:latest
```

Minimal configuration example to work with a Brother QL-580N printer (assuming local DNS name `label-printer.home.arpa`) using endless 62mm tape over the network:
```bash
podman run -it --rm -p 7745:7745 \
  --env 'HBOX_LABEL_MAKER_WIDTH=696' \
  --env 'HBOX_LABEL_MAKER_HEIGHT=256' \
  --env 'HBOX_LABEL_MAKER_DYNAMIC_LENGTH=false' \
  --env 'HBOX_LABEL_MAKER_PRINT_COMMAND=brother_ql --backend network --model QL-580N --printer tcp://label-printer.home.arpa:9100 print --label 62 --rotate 0 {{.FileName}}' \
  ghcr.io/llewy/homebox-brother-ql:latest
```

You can find the required pixel width/height for your specific labels by running:
```bash
podman run --rm -it --entrypoint /usr/bin/env ghcr.io/llewy/homebox-brother-ql:latest brother_ql info labels
```
Which will look like this:
```
 Name      Printable px   Description
 12         106           12mm endless
 18         234           18mm endless
 29         306           29mm endless
 38         413           38mm endless
 50         554           50mm endless
 54         590           54mm endless
 62         696           62mm endless
 62red      696           62mm endless (black/red/white)
 102       1164           102mm endless
 103       1200           104mm endless
 17x54      165 x  566    17mm x 54mm die-cut
 17x87      165 x  956    17mm x 87mm die-cut
 23x23      202 x  202    23mm x 23mm die-cut
 29x42      306 x  425    29mm x 42mm die-cut
 29x90      306 x  991    29mm x 90mm die-cut
 39x90      413 x  991    38mm x 90mm die-cut
 39x48      425 x  495    39mm x 48mm die-cut
 52x29      578 x  271    52mm x 29mm die-cut
 54x29      598 x  271    54mm x 29mm die-cut
 60x86      672 x  954    60mm x 87mm die-cut
 62x29      696 x  271    62mm x 29mm die-cut
 62x100     696 x 1109    62mm x 100mm die-cut
 102x51    1164 x  526    102mm x 51mm die-cut
 102x152   1164 x 1660    102mm x 153mm die-cut
 103x164   1200 x 1822    104mm x 164mm die-cut
 d12         94 x   94    12mm round die-cut
 d24        236 x  236    24mm round die-cut
 d58        618 x  618    58mm round die-cut
```

## Example Podman Quadlet File
You can use this image with [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) as follows:

```ini
[Unit]
Description=HomeBox Inventory Management System

[Container]
Image=ghcr.io/llewy/homebox-brother-ql:latest
# Note: %h is replaced with the home directory of the user running the quadlet
Volume=%h/homebox-data:/data
PublishPort=7745:7745
Environment=HBOX_LABEL_MAKER_WIDTH=696
Environment=HBOX_LABEL_MAKER_HEIGHT=256
Environment=HBOX_LABEL_MAKER_DYNAMIC_LENGTH=false
Environment=HBOX_LABEL_MAKER_PRINT_COMMAND="brother_ql --backend network --model QL-580N --printer tcp://label-printer.home.arpa:9100 print --label 62 --rotate 0 {{.FileName}}"

[Service]
Restart=always

[Install]
WantedBy=multi-user.target
```

## Example Compose File
You can use this image with [Compose](https://compose-spec.github.io/compose-spec/spec.html) as follows:
```yaml
services:
  homebox:
    image: "ghcr.io/llewy/homebox-brother-ql:latest"
    container_name: "homebox"
    ports:
      - "7745:7745"
    environment:
      HBOX_LABEL_MAKER_WIDTH: "696"
      HBOX_LABEL_MAKER_HEIGHT: "256"
      HBOX_LABEL_MAKER_DYNAMIC_LENGTH: "false"
      HBOX_LABEL_MAKER_PRINT_COMMAND: "brother_ql --backend network --model QL-580N --printer tcp://label-printer.home.arpa:9100 print --label 62 --rotate 0 {{.FileName}}"
    volumes:
      - "./homebox-data:/data"
```

## Automated Updates

This repository includes GitHub Actions workflows that:

- 🔄 **Daily Version Checks**: Automatically checks for new HomeBox releases every day at 6:00 AM UTC
- 📝 **Pull Request Creation**: Creates PRs when new versions are available with full changelog information  
- 🏗️ **Automated Builds**: Builds and pushes new container images when tags are created
- 🚀 **GitHub Container Registry**: Publishes images to `ghcr.io` for reliable access

To manually trigger an update check, go to the Actions tab and run the "Update Homebox Version" workflow.

## Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test them locally
4. Submit a pull request with a clear description

## License
Files directly in this repo are available under the MIT license (except the container images as those are bound by various upstream licenses).

Notably [HomeBox uses AGPL-3.0](https://github.com/sysadminsmedia/homebox/blob/main/LICENSE),
so you have to ensure you release the source code if you run a modified version.
