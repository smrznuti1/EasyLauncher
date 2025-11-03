#!/bin/bash

keytool -genkeypair -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias -storepass thisismycreds -keypass thisismycreds -dname "CN=Your Name, OU=Your Org, O=Your Company, L=Your City, S=Your State, C=Your Country"

docker build --secret id=myssh,src=/home/filip/.ssh/alas -f ./Dockerfile builder
