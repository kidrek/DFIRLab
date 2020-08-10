#!/bin/bash

< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-64};echo;
