# Battle Scrolls - Build Viewer

This is an unofficial lightweight fork of **Battle Scrolls**, originally
created by **Semigroup1329 (Vladislav Sheludchenkov)**.

Original project:
https://github.com/vladislavsheludchenkov/BattleScrolls

The fork retains the Character-screen build viewer and its original visual
presentation. It does not load combat recording, DPS tracking, encounter
history, effect reconciliation, death recap, weaving analysis, group sharing,
the combat journal, or the DPS meter.

Tea & Toast Software maintains only the lightweight fork. Full credit for the
original project, build capture, build renderer and interface belongs to the
upstream author and contributors.

The upstream project is licensed under the MIT License. The original licence
and copyright notice are included unchanged.

## Compatibility

Install this instead of the full Battle Scrolls addon. Do not enable both
packages simultaneously because the fork intentionally retains the upstream
folder and Lua namespace required by the original Character-screen code.

## Runtime behaviour

The addon registers only its one-time addon-load callback and the hooks needed
to add the build page to the Gamepad Character screen. Current equipment,
skills, Champion stars, Mundus and food are inspected only when the page opens.
