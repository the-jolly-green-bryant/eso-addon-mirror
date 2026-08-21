# Credits and External Dependencies

## Fancy Action Bar+

Ultivite 1.0.71 no longer contains or redistributes Fancy Action Bar+ source code.

Fancy Action Bar+ is a separate required addon and remains fully owned and maintained by its authors. Ultivite only talks to the installed FAB+ addon at runtime and mirrors supported settings into the Ultivite menu.

Fancy Action Bar+ authors listed in the 2.19.6 manifest: Incanus, dack_janiels, nogetrandom and andy.s.

ESOUI project:
https://www.esoui.com/downloads/info3938-FancyActionBar.html

Source repository:
https://github.com/DakJaniels/FancyActionBarPlus

## LibAddonMenu-2.0

Ultivite uses LibAddonMenu-2.0 for its settings interface.
## Enemy Ultimate alert research

Ultivite's Corrosive Armor and Onslaught enemy warnings are an independent implementation. No DKcorrosiveAlert source file is bundled or copied.

Behavioral reference: DKcorrosiveAlert by lebiez on ESOUI. Ultivite follows its public incoming-damage warning model for Corrosive Armor and the same player-target combat-event approach, without bundling or copying the addon source.

ESOUI community discussion by ArtOfShred documented incoming Onslaught hit IDs 83229 and 126497. Baertram's public DKcorrosiveAlert feedback informed the use of engine-side player/result/ability filters instead of processing unrelated combat events in Lua. Ultivite adds only its own mouseover source icon presentation on top of that warning behavior.


## Bandits User Interface

Bandits User Interface is optional and is not distributed with, required by, or declared as a dependency of Ultivite.

When Bandits is already installed, Ultivite can call the installed Bandits minimap module and listen for its published minimap visibility callback so the Quick Menu can expose an ON/OFF control. Ultivite does not include Bandits code or a replacement minimap.
