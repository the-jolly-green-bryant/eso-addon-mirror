Above Me v0.7.4-dev1

Changes in this build:
- Uses one universal overhead anchor plus a fixed screen-space nameplate clearance.
- Raised the fixed overhead anchor so icons sit above ESO nameplates instead of covering them.
- Fixed icon placement to one native-style overhead position.
- Removed the Height Above Player setting.
- Removed distance-based scaling to prevent visible size pumping.
- Added account-keyed persistent icon controls.
- Added dead-zone filtering and time-based position smoothing.
- Added snap recovery for teleports and camera cuts.
- Removed the per-update hide/recreate behavior that caused flicker and jumping.
- Preserved icon size, opacity, visibility distance, favorites, browser, and networking.

ABOVE ME v0.7.0-dev1

A BMG ADDON
Created and maintained by @BMGXSANCHO

ESO CLASSES & ROLES PACK
- New Classes category: Arcanist, Dragonknight, Nightblade, Sorcerer, Templar, Warden, Necromancer, Vampire, Werewolf
- New Roles category: Tank, Healer, Damage Dealer
- Original ESO-inspired artwork with transparent backgrounds
- Separate BC3/DXT5 compressed 512x512 atlas
- Existing 63-icon first-release pack remains unchanged

Browser controls:
L1/R1: category
L2/R2: icon
X: select
Triangle: favorite
Circle: back


0.6.0-dev2
- Added Meme Legends category: Giga Chad, Pepe, Doge, Shiba, Chad Viking, This Is Fine, and Gigabrain Wizard.
- Added one compressed transparent BC3/DXT5 atlas for the seven new icons.

0.6.0-dev2
- Replaced all seven Meme Legends atlas cells with the originally approved artwork supplied by the project owner.
- Removed the source image's black presentation background and labels.
- Preserved icon IDs, ordering, category integration, favorites, networking, and browser behavior.
- Re-encoded the atlas as BC3/DXT5 with alpha transparency.


0.7.0-dev1
- Added the Custom Icons category.
- Added Cheeze Wheel, Anchor, Piefase, Dead Monkey, Robot, Noblelumpkin, Bad Ass Rock, and Sancho Clause.
- Added one transparent 512x256 BC3/DXT5 atlas for the eight custom icons.
- Preserved existing icon IDs, categories, favorites, recent selections, browser controls, and networking behavior.


Version 0.7.2-dev2
- Added Dachshund, Sunflower, Flamenco Dancer, and Pretty Kitty to Custom Icons.


0.7.2-dev2
- Removed local group icon assignment and player-selection controls.
- Each player now shares only their own selected icon automatically.
- Group members running Above Me display one another's selected icons.
- Added LibGroupBroadcast as a required dependency.


0.7.4-dev2
- Detects the locally active polymorph and uses a polymorph-safe overhead anchor.
- Base race and gender offsets are bypassed while transformed.
- Unknown polymorphs use a conservative shared fallback; known outliers can be tuned by collectible ID.


0.7.5-dev2
- Replaced race, gender, and polymorph placement estimates with one universal 2.80 m world anchor.
- Added an 8-pixel screen-space clearance after projection so the visual gap stays consistent with camera distance.
- Disabled pixel rounding on icon controls for smoother screen movement.
- Preserved smoothing, networking, icon size, browser, favorites, and all icon packs.


Above Me v0.7.5-dev2

- Raised the universal overhead anchor from 2.80 meters to 3.25 meters.
- This conservative placement is intended to clear maximum-height standard characters.
- Preserved the smooth renderer, screen-space clearance, networking, icon browser, favorites, and icon packs.
