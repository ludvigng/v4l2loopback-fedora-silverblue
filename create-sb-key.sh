#!/bin/bash

if [[ -f build/v4l2loopback.priv || -f build/v4l2loopback.cer ]]; then
  echo "Error: Certificate and/or unencrypted key already present in build directory";
elif [[ ! -f /usr/bin/efikeygen || ! -f /usr/bin/certutil || ! -f /usr/bin/pk12util || ! -f /usr/bin/openssl || ! -f /usr/bin/mokutil ]]; then
  echo "Missing dependencies, needs the following packages: pesign, mokutil, openssl";
else
  echo "Generating new key for signing module"
  efikeygen --dbdir /etc/pki/pesign --self-sign --module --common-name 'CN=v4l2loopback' --nickname 'v4l2loopback signing key'
  echo "Exporting certificate"
  certutil -d /etc/pki/pesign -n 'v4l2loopback signing key' -Lr > v4l2loopback.cer
  echo "Extracting key, choose a password"
  pk12util -o v4l2loopback.p12 -n 'v4l2loopback signing key' -d /etc/pki/pesign
  echo "Exporting unencrypted key, repeat password"
  openssl pkcs12 -in v4l2loopback.p12 -out v4l2loopback.priv -nocerts -nodes
  echo "Copying certificate and unencrypted key to build dir"
  cp v4l2loopback.cer v4l2loopback.priv build/
  echo "Importing certificate to MOK, choose a PIN"
  mokutil --import v4l2loopback.cer
  echo "Reboot to import the key to MOK, use same PIN";
fi
