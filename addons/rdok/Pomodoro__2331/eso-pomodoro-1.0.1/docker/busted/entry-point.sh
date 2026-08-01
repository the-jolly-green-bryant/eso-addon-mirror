#!/bin/sh

#clear
#exec ./modules/bin/busted $@
#exec which busted $@

# Expose modules for IDE usage.
# TODO: lazy execute, or manualy script

rsync --update --recursive /usr/local/ /app/modules

#exec luarocks path

clear

exec busted $@
