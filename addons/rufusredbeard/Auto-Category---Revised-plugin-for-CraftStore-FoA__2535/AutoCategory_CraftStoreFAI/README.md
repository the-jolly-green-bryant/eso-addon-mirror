# Plugin for Auto Category - Revised AddOn that adds support for CraftStore Greymoor AddOn

*Depends on the following (separately installed) AddOns: [Auto Category - Revised](https://www.esoui.com/downloads/info2300-AutoCategory-Revised.html), [CraftStore FoA](https://www.esoui.com/downloads/info1590-CraftStoreFoa.html).*

The `keepresearch()` function provided by Auto Category is somewhat basic. It assumes you will want to research any item that is researchable by any of the characters on your account.

CraftStore has a much more sophisticated model of keeping track of which items you are saving for research.

This small plugin to Auto Category provides a single function you may use in rules that looks up items in CraftStore.

For example, you may wish to update the Gears > Researchable category to use the `issavedforcraftstore()` function provided by this AddOn.
