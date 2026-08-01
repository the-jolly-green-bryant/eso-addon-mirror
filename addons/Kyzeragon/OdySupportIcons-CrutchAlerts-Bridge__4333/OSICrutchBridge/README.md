OdySupportIcons-CrutchAlerts Bridge is a "stub" addon to bridge the gap for trial-specific addons to be able to draw icons for mechanics, without using [OdySupportIcons](https://www.esoui.com/downloads/info2834-OdySupportIcons-GroupRoleIconsMore.html) (OSI).
Essentially, it implements the APIs those addons expect from OSI, but actually redirects the functions to [CrutchAlerts](https://www.esoui.com/downloads/info3137-CrutchAlerts.html)' icon drawing system.
## But why?
Primarily: performance. OdySupportIcons is a brilliant addon that laid a lot of groundwork for other addons built on top of it, but it runs a ton of math every 10ms (by default) on the scripting side, in order to calculate positions to make icons appear as if they are in the 3D world. U47 allowed addons to use ZOS' native RenderSpace and Space APIs inside instances, meaning you gain FPS by using the new methods instead of the old intensive OSI math.
## Caveats
OSI-Crutch Bridge does not pretend to be OSI in the manifest. This means addons that *require* OSI as a dependency will not be fooled by it. For example, if you want to continue to use [Elm's Markers](https://www.esoui.com/downloads/info3395-ElmsMarkers.html), then you should just use the real OdySupportIcons. However, there is now a more modern and performant alternative, [More Markers](https://www.esoui.com/downloads/info4266-MoreMarkers.html), that I would recommend switching to.

Some addons use the textures packaged with OdySupportIcons. I decided not to include them, so some icons will be swapped for reasonable substitutes. If you find unexpected poop emojis, let me know where so I can redirect them to a more reasonable texture, as the poop emoji is currently the fallback. Not to be confused with intentional poop, such as on Ansuul and Cavot Agnan ;D
## Compatibility
This is only intended and tested for certain trial-specific addons. Use at your own risk!
* [Sanity's Edge Helper](https://www.esoui.com/downloads/info3657-SanitysEdgeHelper.html) - tested ✅
* [Qcell's Dreadsail Reef Helper](https://www.esoui.com/downloads/info3354-QcellsDreadsailReefHelper.html) - partially tested ☑️; is probably fine
* [Ossein Cage Helper](https://www.esoui.com/downloads/info4127-OsseinCageHelper.html) (wondernuts) - partially tested ☑️; is probably fine
* [Qcell's Rockgrove Helper](https://www.esoui.com/downloads/info3060-QcellsRockgroveHelper.html) - not supported ⚠️; you can have Bridge enabled, but you still won't get icons
* [Elm's Markers](https://www.esoui.com/downloads/info3395-ElmsMarkers.html) - not supported ❌; you should use [More Markers](https://www.esoui.com/downloads/info4266-MoreMarkers.html) instead, or the real OSI
* [ExoYs Support Icon Extention](https://www.esoui.com/downloads/info2913-ExoYsSupportIconExtention.html) - not supported ❌; you should use the icons in CrutchAlerts instead, or the real OSI
* Others - TBD: There are myriad addons that depend on OSI. If OSI is a required dependency, Bridge does not support it ❌. If OSI is an optional dependency, it _may_ be supported, but I have not personally tested it.

There is no support for Qcell's Rockgrove Helper and ExoYs Support Icon Extention. OSI-Crutch Bridge will disable its functions inside Rockgrove, while ExoYs Support Icon Extention requires the real OSI. These addons create text labels attached to the icons and do it for mechanics that Crutch or Code's Combat Alerts already cover too (besides cleanse pool cooldown and Defiling Blast), and OSI-Crutch Bridge is meant to be a stopgap until a fancier lib arrives, so I don't feel it's worth it to support/work around the text labels.

*Required dependencies: [CrutchAlerts](https://www.esoui.com/downloads/info3137-CrutchAlerts.html), [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)*


If you encounter any errors, please post the full error in the ESOUI comments section if possible, so I can either support or exclude problematic functions.
