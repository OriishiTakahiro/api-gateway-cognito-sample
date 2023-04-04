#!/bin/bash

rm -rf ./dist/*
cp *.py ./dist/

pip install -r requirements.txt -t ./dist
