@echo off

echo Building docker image...
docker build -t glennswest/winpacman:latest .
docker push glennswest/winpacman:latest

echo Done.
