#!/usr/bin/env bash

cd patches || exit 1

find -- * -type f -exec cp "{}" "../node_modules/{}" \;
