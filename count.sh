#!/bin/sh

ipset list REDSOCKS | grep -c ^[0-9]
