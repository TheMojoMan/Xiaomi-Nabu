#!/bin/bash
dpkg-scanpackages . /dev/null |gzip > Packages.gz
