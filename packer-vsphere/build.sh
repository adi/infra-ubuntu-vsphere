#!/bin/bash

packer build -force -var-file ./variables.pkr.hcl ./ubuntu-22.04-live-server-packer.pkr.hcl
