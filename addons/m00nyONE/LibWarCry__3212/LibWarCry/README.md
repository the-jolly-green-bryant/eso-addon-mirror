# LibWarCry

LibWarCry enables addon authors to create their own group syncronized warcrys by playing back collectibles via a chat listener.
It is used as a base for the WarCry addon.

You can find this library on ESOUI here https://www.esoui.com/downloads/info3212-LibWarCry.html

# Functions

```
LibWarCry:CreateWarCry("$NAME", {ID,ID,ID,...})


LibWarCry:PlayWarCry("$NAME")
```

# Usage
```
/p $NAME -> "plays the warcry when you are the leader of the group"
/wc $NAME -> "plays the warcry for yourself"
/wc -> "list all warcrys"
```

Example: https://github.com/m00nyONE/WarCry

Further details can be found in the source code. Everything there is documented and explained.
