libGarfield 1.0.0
=============

[![Esoui libGarfield page](https://img.shields.io/badge/esoui.com-libGarfield-green.svg)](#notset)

libGarfield monitors and ensures that [libChat3][1] remains active while loading after login or `/reloadui`.

Some AddOns can overwrite between them and overwrite libChat.
If libChat is overwrite no AddOns which use libChat will run, this addOn prevent that.

-----------

If any AddOns use libChat3 but libChat2 you will get chat Message after login :

> "INFO : Compatibility mode enabled to keep {ADDON_NAME} & `libChat2 (02/2016)` enabled. Please use `libChat3`."

If libChat is rewrited by an another AddOns :

> "WARNING : `{ADDON_NAME}` is outdated! Ask the author to use a chat library like `libChat3`".

## Player :

The addon does not need to be configured it is full automated.
You can directly install libChat3 because your AddOns which use libChat2 will automaticly use [libChat3][1]. :)

## AddOn author :

Add the file in your ".txt".

[1]: https://github.com/GuimDev/libChat3
