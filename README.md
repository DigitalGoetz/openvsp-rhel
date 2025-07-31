# OpenVSP Builder

## Prerequisites

- docker
- wget


## Scripts

### Download Sources

The download sources script simply downloads from github the specific versions of OpenVSP and SWIG needed to build the OpenVSP RPM file

```bash
bash scripts/download-sources.sh
```

### Build RPM

The Build RPM script creates a docker image and all required items needed to build an OpenVSP RPM for RHEL 8.  It then places the built RPM file into the final image for easy export, where the build RPM script will copy and store than in this repository's root directory.

```bash
bash scripts/build-rpm.sh
```


