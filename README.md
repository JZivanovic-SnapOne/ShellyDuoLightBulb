# Template driver

## About this repo

This repo contains the template for creating Control4 drivers.

### Creating a new driver from this template

To create a new driver repository, click **Use this template** on the main page of the repository. For detailed instruction, see [here](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

To create a new driver, but not initialize a new repository, download repository's ZIP file.

## About the driver

This section will provide basic information about the driver.

## Requirements

This section will provide setup information for all neccessary requirements to build the driver.

### Driver Packager

The driver can be built using the [Driver Packager](https://github.com/control4/drivers-driverpackager). Install the Driver Packager's [Requirements](https://github.com/control4/drivers-driverpackager#requirements).

## Building this driver

This section will provide instructions on how to build the driver.

```sh
<path to driverpackager/dp3/driverpackager.py> -v . release driver.c4zproj
```

Production-ready version of this driver can be found in the [release](./release) directory.
