# Findings

What the client's own source says about the player's attribute bars, and why the add-on is built
the way it is. Everything here is **from source** (`esoui/esoui`, tag 12.0.8, API 101050) unless
it says it was measured; the list at the end is what still has to be looked at on a PS5.

## 1. Three controls in one top-level

`ZO_PlayerAttribute` (`playerattributebars.xml`) is the top-level, 64 high and hidden until the
HUD shows it. Inside it are six controls: the three the player knows —

| | anchor in the XML |
| --- | --- |
| `ZO_PlayerAttributeHealth` | `CENTER` of the group |
| `ZO_PlayerAttributeMagicka` | `RIGHT` on the group's `LEFT`, +237 |
| `ZO_PlayerAttributeStamina` | `LEFT` on the group's `RIGHT`, -237 |

— and three small companions, each anchored to the bar it belongs to: `Werewolf` under magicka,
`MountStamina` under stamina, `SiegeHealth` under health. All six are `ZO_PlayerAttributeContainer`
(237 × 23) or `...ContainerSmall` (228 × 12), and everything visible — background, frame, the
status bars, the warner, the resource numbers — is anchored inside its container. So a container's
anchor and scale are the whole bar's position and size.

The group itself is placed by `ZO_PlayerAttribute_Gamepad_Template`: `BOTTOM` of `GuiRoot`,
105 up. Its width comes from `ResizeToFitScreen`:

```lua
local barAreaWidth = screenWidth - BAR_OFFSET_FROM_SCREEN_EDGE * 2   -- 502
barAreaWidth = zo_clamp(barAreaWidth, MIN_BAR_AREA_WIDTH, MAX_BAR_AREA_WIDTH)  -- 1014, 1600
```

At 1920 wide that is 1014 — the minimum, not the screen — which is why the bars sit where they do
regardless of the TV. The middles work out at 137 up from the bottom, and 0 / -388 / +389 from the
middle of the screen. The add-on measures all six numbers off the controls anyway; those are only
the fallback.

## 2. What the client writes to these controls, and when

- `ResizeToFitScreen`, on `EVENT_SCREEN_RESIZED` and once at startup: the **group's width**. With
  the three containers anchored to the group, that moves magicka and stamina. Once they are
  anchored to `GuiRoot` instead, it does not reach them.
- `ZO_PlayerAttributeBars:ApplyStyle`, on `EVENT_GAMEPAD_PREFERRED_MODE_CHANGED`: templates for
  the group, the textures and the sub-bars. It re-anchors the **sub-bars inside** each container
  and the **group**, but never a container itself.
- `ZO_UnitVisualizer_ShrinkExpandModule`: the **container's width**, and its background's, as
  buffs and debuffs move a maximum:

```lua
ATTRIBUTE_BAR_STATE_EXPANDED -> 323
ATTRIBUTE_BAR_STATE_SHRUNK   -> 141
ATTRIBUTE_BAR_STATE_NORMAL   -> 237
```

  instantly on `EVENT_PLAYER_ACTIVATED`, and through a 750 ms `SizeAnimation` the rest of the time.

Nothing in the client writes a container's **anchor** or its **scale** after the UI is built.

## 3. Why scale, and not `SetDimensions`

§2 is the whole argument. A width written by an add-on survives until the player eats a meal,
takes a debuff, or zones — and then the visualiser animates the bar to 141, 237 or 323 and leaves
it there. Fighting that would mean rewriting the width on every one of those changes, which is a
loop with the client's own animation. Scale is never touched by the client, needs no upkeep, and
takes the frame textures, the background, the status bar and the resource numbers with it in
proportion — a stretched-width bar keeps its 64-pixel arrow ends and looks wrong.

The cost is that size is one number rather than two. For a HUD bar that reads as the right trade:
nobody wants a health bar three times as tall as it is wide.

## 4. Why the middle, and `GuiRoot`

Each container is anchored `CENTER` → `GuiRoot` `BOTTOM`, at (x, -y). Two reasons for the middle
rather than a corner: the width is not ours (§2), so a bar held by an edge would slide as buffs
come and go; and whatever ESO's scaling pivot turns out to be, a control whose anchor point is its
own centre stays put when it is scaled.

`GuiRoot` rather than the group, because three bars anchored to a 1014-wide group cannot be placed
apart from each other, and because the group's width moves on `EVENT_SCREEN_RESIZED`. The
containers stay **children** of `ZO_PlayerAttribute` — only the anchor changes — so
`PLAYER_ATTRIBUTE_BARS_FRAGMENT` (a `ZO_HUDFadeSceneFragment` over the group) still fades and
hides them exactly as before, and the game's own "fade out of combat" setting still works.

The companions keep their own anchors, which are relative to their partner, so they follow it.
They are given the same scale, or the pair no longer meets.

## 5. Measuring the game's own position

Taken once per session per bar, before anything is written, off `GetLeft` / `GetTop` /
`GetDimensions` — and **only while the container is its normal 237 wide**. The middle of a
stretched bar is not where the middle of a normal one is: the game holds magicka by its right edge
and stamina by its left, so at 323 the middle has moved 43 in. A bar that is not at its normal
width is left for the next HUD show to measure, and the worked-out fallback stands in meanwhile.
The two agree exactly at 1920 × 1080, which the tests check.

## 6. Why nothing is hooked

The rule from PB's MailerExtension (measured on PS5): a client closure created while an add-on
frame is on the stack is permanently untrusted, and fails the moment it reaches a private
function. These controls run combat code — `EVENT_POWER_UPDATE` several times a second in a fight,
the attribute visualiser's modules, the warners, the fade timeline — so a tainted closure here
would surface in the middle of a fight.

So the add-on never wraps an attribute bar method and never calls one. Everything is a write to a
control:

| | written | the game's own equivalent |
| --- | --- | --- |
| position | `ClearAnchors` / `SetAnchor` on each container | the XML anchors |
| size | `SetScale` on each container and its companion | (nothing — the client never scales them) |

The one registration is a `"StateChange"` callback on `HUD_FRAGMENT`: our function is stored
beside the client's, nothing of theirs is wrapped. The preview is built entirely from controls of
the add-on's own — showing the real bars in a menu would mean driving the group's fragment from
add-on code.

## 7. When the settings panel is actually open

Carried over from PB's ChatWindowCustomizer 1.0.1, found on PS5 and confirmed in the library's
source (`votan73/ESO`, `LibHarvensAddonSettings/Console/Settings.lua`): the console add-on list
opens a panel in two steps —

```lua
addon:Select()                                      -- fires AddonSelected, then sets .selected
SCENE_MANAGER:Push("LibHarvensAddonSettingsScene")  -- and only then shows the panel
```

— so `AddonSelected` arrives while the *list* is still the current scene, and `Select()` returns
early for the add-on already selected, firing nothing at all on a second visit. The preview
follows the library's own panel scene instead. The test harness opens panels in that same order.

## 8. Cost on console

Moving and scaling a control costs nothing lasting, and no font or texture is built: the preview
uses `ZoFontGamepad22`, which the gamepad UI has already, and plain colour textures. Nothing is
written at all while the settings still equal the game's own, so an installed-but-unset add-on is
indistinguishable from not having it.

## 9. The skill bar is one top-level too

`ZO_ActionBar1` (`actionbar.xml`) is 70 high and, on the gamepad, 606 wide and `BOTTOM` of
`GuiRoot` at -25 (`GAMEPAD_CONSTANTS` in `actionbar.lua`). Every button hangs inside it: the five
abilities and the ultimate are `ActionButton3` to `ActionButton8`, chained off
`ZO_ActionBar1WeaponSwap`, with the quickslot and the companion ultimate anchored to those. So
its anchor and its scale are the whole bar's, and it is placed and sized exactly like the three
attribute bars -- the same `CENTER` → `GuiRoot` `BOTTOM` anchor, the same scale, the same
measurement before the first write.

The one client write to watch is `ApplyStyle`, through `ZO_PlatformStyle`: on
`EVENT_GAMEPAD_PREFERRED_MODE_CHANGED` it does `ZO_ActionBar1:ClearAnchors()`, re-anchors and
sets the width back to 606. That is the same case the attribute bars have, and the same answer:
every HUD show compares and rewrites only what no longer matches.

The buttons are named controls (`CreateControlFromVirtual("ActionButton"..slotNum, ...)`), so
they are reached with a plain `_G` lookup. `ZO_ActionBar_GetButton` is never called -- not
because that function is dangerous in itself, but because a name lookup cannot be.

## 10. The client has a back row, and it is not the one the player wants

`ZO_ActionBarTimer` (`actionbutton.lua`) is a real back row: `ActionBarTimer3` to
`ActionBarTimer8`, anchored `CENTER` on each main button at `backRowSlotOffsetY` = -17, with the
other set's icon and a fill bar. But:

- it is gated on two settings, `UI_SETTING_SHOW_ACTION_BAR_TIMERS` and
  `UI_SETTING_SHOW_ACTION_BAR_BACK_ROW`, and
- `UpdateFillBar` hides a slot the moment it has no running effect
  (`self.slot:SetHidden(true)` whenever `HasValidDuration()` is false).

So it shows a slot while a timer runs on it and nothing the rest of the time -- it is a timer
display, not a second bar. Forcing those controls to stay visible would mean fighting an
`OnUpdate` handler of the client's on every frame, so this add-on draws a row of its own instead
and leaves the client's alone. If the player has the game's own row on, both are drawn; that is
the game's setting to turn off, and status prints what it is set to.

## 11. The countdown is the client's own number

`HandleSlotEffectUpdated` in `actionbar.lua`:

```lua
local timeRemainingMS = GetActionSlotEffectTimeRemaining(slotNum, g_backHotbar)
local durationMS = GetActionSlotEffectDuration(slotNum, g_backHotbar)
...
local stackCount = GetActionSlotEffectStackCount(slotNum, hotbarCategory)
```

Three functions, and the crucial part is the second argument: **they answer for the hotbar you
are not on**. That is the whole countdown for both weapon sets, straight from the client, with no
need to work out which effect came from which cast -- the problem that makes Action Duration
Reminder two thousand lines of heuristics. This add-on reads them for slots 3-8 of both
categories, every 100 ms, and writes the number on the icon.

`MINIMUM_ACTION_BAR_TIMER_DISPLAYED_TIME_MS` is 1000 in the client, and the same floor is used
here: a number that flashes up for half a second as an ability is cast is noise.

## 12. Counting targets is the one part with no API

There is no `GetActionSlotEffectTargetCount`, and nothing else in the client answers it. So it is
counted from `EVENT_EFFECT_CHANGED`, filtered with the client's own
`REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE` / `COMBAT_UNIT_TYPE_PLAYER` so only what the player
applied is seen: one entry per effect name, holding the units under it and when each expires.
Effects on `group*` unit tags are skipped -- a group member's copy of a buff would otherwise turn
a self-buff into "12".

A slot is matched to an entry by **name**, with the ability id as a second chance. That is a
heuristic, and an honest one: an effect usually carries the name of the ability that applied it,
but a morph that applies something under another name will not line up. The countdown does not
depend on it, so the worst case is a missing count, never a wrong time.

The table is bounded: expired units are dropped as they are read and again every 3 s, and at 96
effect names the least recently touched is dropped. On console that cap is the point -- a long
fight in a crowd must not grow a table for ever against the 100 MB pool.

## 13. Where the add-on's own controls live

`Controls.xml` holds two virtual templates -- one back bar slot (52 x 68 with a 44 x 44 icon, the
sizes and texture coordinates of `ZO_ActionBarTimer_BackBarSlot_Gamepad`, drawn in the game's own
back row art) and one pair of labels. They are laid out in XML rather than assembled with
`SetAnchor` from Lua, after PB's MailerExtension ran into anchor limits and zero-height rows
doing the latter on the console gamepad UI.

Only the parent is chosen at runtime, with `CreateControlFromVirtual`, because the controls they
hang on do not exist until the UI has loaded. Each one is parented to the `ActionButton` it
belongs to, which is what makes the action bar's own `ZO_HUDFadeSceneFragment` fade and hide
them with the bar, and what makes them inherit the scale this add-on puts on the bar.

## 14. What the update costs

One `RegisterForUpdate` at 100 ms, reading three numbers for each of twelve slots and writing at
most twenty-four short strings. It runs only while the HUD is up and only while something it
draws is switched on: `SCENE_FRAGMENT_HIDDEN` unregisters it, and so does the master switch. Two
fonts are built, one per text size in use.

## 15. The game's own countdown, and why it is faded rather than left alone

`ActionButton<n>TimerText` is the client's own number on the front bar, written by
`ActionButton:SetTimer` and sized by the platform template (`ZoFontGamepad27` on the gamepad).
Its size is not an add-on's to change, and the setting that turns it on
(`UI_SETTING_SHOW_ACTION_BAR_TIMERS`) is read-only from here. So with that setting on and this
add-on drawing its own number, the icon carries two.

1.1.0 answered that by not drawing ours while the game's was on. That was wrong in the way that
matters: the text size slider then did nothing at all, on the bar the player is looking at, and
the only clue was a tooltip. From 1.1.1 the default is to draw ours and set the client label's
**alpha to 0** instead.

Alpha is the right lever because `SetTimer` and `UpdateTimer` only ever write that label's text
and its hidden state -- alpha is never touched, so there is nothing to fight and nothing to
re-apply per frame. It is restored to 1 the moment ours stops being drawn: the mode is changed,
the master switch goes off, or the loop stops.

## 16. Controls.xml not loading is survivable

`CreateControlFromVirtual` raises if the template is not there -- a manifest that missed the XML,
or a client that would not parse it. On a console that is a whole session lost for nothing on
screen and nothing to read, so the failure is recorded (status prints it) and the same controls
are built from plain `CreateControl` calls instead, with the anchors and sizes the XML would have
given them. `/pbhud slots` says which of the two was used.

## 17. The gaps along the bar, and the control nobody sees

`ActionButton:ApplyAnchor` is the whole layout:

```lua
function ActionButton:ApplyAnchor(target, offsetX, isAnchoredLeft)
    if not isAnchoredLeft then
        self.slot:SetAnchor(LEFT, target, RIGHT, offsetX, 0)
    else
        self.slot:SetAnchor(RIGHT, target, LEFT, -offsetX, 0)
    end
end
```

and `ApplyStyle` chains the row with it, off `GAMEPAD_CONSTANTS`: `abilitySlotOffsetX` 10 between
the five abilities, `ultimateSlotOffsetX` 65 before the ultimate, `weaponSwapOffsetX` 61 for the
weapon swap marker inside the bar, and `quickslotOffsetXFromFirstSlot` 5 for the quickslot on the
far side of that marker.

The marker is the catch. On the gamepad `showWeaponSwapButton` is false and
`ZO_WeaponSwap_SetPermanentlyHidden` hides it -- but it is still a control with a width, and the
quickslot is anchored to its other side. So the gap the player sees between the item and the
first ability is `5 + the marker's width + 10`, and no single number in the client is that gap.

This add-on writes the same anchors with its own offsets, and anchors the quickslot to the
**first ability** instead of the marker, so the number in the settings panel is the distance on
screen. `ActionButton3` is left exactly where the client puts it, because it is what the rest of
the row hangs off; everything else closes up towards it. The three gaps are measured off the
controls first (`GetLeft` / `GetRight`, at the bar's own scale, before anything of ours is
written), so an untouched install still writes nothing.

The original anchor of each control is remembered the moment before the first write **to that
control**, never in one pass up front: the row can grow. `SetCompanionAnchors` puts a companion's
ultimate between the item and the abilities when one is summoned, and re-anchors the quickslot
past it -- a button the client has only just laid out, whose own anchor has to be read then, not
before. Reading them all again later would record our own offsets as the game's, which is the
mistake PB's NamePlateChanger had to grow a repair path for.

## 18. Whether the weapon sets can be swapped at all

Two client answers, and neither is a guess at an item:

```lua
local activeWeaponPair, locked = GetActiveWeaponPairInfo()          -- the Oakensoul Ring, etc.
local unearned = GetUnitLevel("player") < GetWeaponSwapUnlockedLevel()
```

Both are what the client's own weapon swap button reads
(`ZO_WeaponSwap_OnInitialized`, `buttontemplates.lua`), with `EVENT_WEAPON_PAIR_LOCK_CHANGED` and
`EVENT_ACTIVE_WEAPON_PAIR_CHANGED` behind the first and `EVENT_LEVEL_UPDATE` behind the second.
Action Duration Reminder looks for `oakensoul` in the icon of each worn ring instead
(`Bar.lua`, `barShowShiftFully`); that misses everything else that locks a bar, and breaks on a
renamed icon.

While either says no, there is no second set to show, so the back bar hides itself -- the
setting is left alone, and it comes back when the ring comes off. The update loop already
re-reads this every tick, so nothing has to be registered for it.

## 19. The shade over a skill is the client's own cooldown control

ESO has a `Cooldown` control type, and two of its sweep shapes are in the client's own Lua:
`CD_TYPE_RADIAL`, which the action bar uses for ability cooldowns, and
`CD_TYPE_VERTICAL_REVEAL`, which the utility wheel uses:

```lua
control.cooldown:SetTexture(GetSlotTexture(slotNum, hotbarCategory))
control.cooldown:SetFillColor(ZO_SELECTED_TEXT:UnpackRGBA())
control.cooldown:SetVerticalCooldownLeadingEdgeHeight(4)
control.cooldown:StartCooldown(remaining, duration, CD_TYPE_VERTICAL_REVEAL, CD_TIME_TYPE_TIME_UNTIL, USE_LEADING_EDGE)
```

That is the whole feature: a `Cooldown` of the add-on's own, over the button's icon, given the
ability's icon and started when an effect starts. **The engine runs the sweep**, so there is no
work per frame here and it cannot drift from the effect -- the length it is given is
`GetActionSlotEffectDuration`, the client's own number, on either weapon set.

It is only ever started again when something changes: a different duration, a different ability
in the slot, or the time left jumping back up, which is a re-cast. Ticking down is left alone.

Which way the sweep runs is `CD_TIME_TYPE_TIME_UNTIL` against `CD_TIME_TYPE_TIME_REMAINING` --
one counts towards the end and the other away from it. The setting is a **direction** rather than
a time type for that reason: nothing in the source says which way round the reveal is drawn, so
if it comes out upside down on a PS5 the player flips it, and a client that ever changes it costs
nobody a release.

## 20. Liquid without any new art (removed in 1.5.0)

The liquid style is drawn **over** the client's own fill, not instead of it. That is the design
decision the rest follows from: the damage shield overlays, the armour, possession and unwavering
modules and the warners are all controls the attribute visualiser hangs on those same bar
controls (`ZO_PlayerAttributeHealthBarLeft`, `...Magicka Bar`, `...StaminaBar`), and a style that
hid the client's bars would take all of that with it. One child per bar control instead: it
inherits the bar's alpha -- the game's own fade out of combat -- its hidden state, and any scale
this add-on has put on the attribute bars.

The look is three things over the fill: a darker bottom for depth, two bands of light drifting
across at different speeds, and a bright line at the surface where the fill ends. Every texture
is one those bars already load (`attributeBar_dynamic_fill_gloss`,
`attributeBar_dynamic_leadingEdge_gloss`) or one the generic progress bars use, so the style adds
**nothing** to the 100 MB pool console add-ons share. There is no art file in this add-on.

Two things have to be worked out rather than read:

- **How full the bar is.** `GetUnitPower("player", COMBAT_MECHANIC_FLAGS_*)` each tick, rather
  than following `EVENT_POWER_UPDATE`: one call per bar is cheaper than keeping a copy of the
  client's bookkeeping in step, and it cannot drift out of it. The two halves of the health bar
  each hold half the value, so the fraction is the same for both.
- **Where the fill ends.** A bar with `barAlignment="REVERSE"` (magicka, and the left half of
  health) fills towards its left, so the overlay hangs off the right edge and the surface is on
  the left; a normal one is the mirror. ESO does not clip a child to its parent, so each band is
  given the width of its overlap with the filled part and the texture coordinates to match.

At 20 updates a second, and only while the HUD is up and the style is chosen: on Standard, the
default, nothing is built and no update is registered.

## 21. Every control needs the fallback, not most of them

1.3.0 shipped the liquid overlay as the only control without a plain-Lua fallback for a template
that did not build, and the shape of that bug is exactly what came back from the PS5: everything
else working, the liquid doing nothing, and nothing to read anywhere. The fallback list now
covers every template this add-on has, and `/pbhud liquid` prints the whole chain -- style, loop,
each bar control, each overlay, the fraction, and the alpha the game has the bar at.

The last of those is worth knowing on its own: the attribute bars fade themselves out while they
are full and the player is out of combat, and anything parented to them fades with them. A liquid
effect checked at full health outside a fight is invisible for a reason that has nothing to do
with the liquid.

## 22. A measurement must never be able to stop a write

Reported from a PS5: the attribute bars' position setting sometimes did not take effect. Nothing
in the client was moving them -- the attribute visualiser's modules (armour, possession,
unwavering, power shield, arrow regeneration) all anchor overlay controls **to** a bar and never
re-anchor the bar itself, and `ApplyStyle` only touches the group, the sub-bars and the textures.
It was this add-on's own doing.

`CaptureGame` did two jobs: remember the anchor the bar had (which has to succeed, or there would
be nothing to put back) and measure where the game draws it (which is only ever a nicety, because
the fallback is worked out from the client's own constants). It returned one answer for both, and
`ApplyBar` refused to write unless that answer was true:

```lua
local left, top, width, height = self:ScreenRect(control)
if not left then
    return false        -- and ApplyBar then wrote nothing at all
end
```

`ScreenRect` returns nothing while a control has no size on screen, which depends on how far the
UI has got when the first apply runs -- so the position applied on one login and not on the next.
The two are separate calls from 1.3.2: `CaptureAnchors` gates the write, `MeasureGame` is best
effort and is tried again on every HUD show.

## 23. Putting it back, and counting

Everything written is now checked once a second while the HUD is up, and written again if it is
no longer there -- the same watch PB's MiniMap has had since its first release. An anchor and a
scale read per control, nothing written while they match.

It counts what it had to put back, and `/pbhud status` prints that count. That is the measurement
that answers the next report of this kind: a count that climbs means something really is moving
the bars and the watch is fighting it; a count that stays at zero while the bars are wrong means
the write never landed at all, which is a different bug in a different place.

## 24. Where the countdown goes, and the number that would not go away

Reported from a PS5: this add-on's countdown sat off the middle of the icon, next to the game's
own.

The client's is `ActionButton<n>TimerText`, anchored `CENTER` on `CENTER` with
`ACTION_BUTTON_TIMER_TEXT_OFFSET_Y_DEFAULT_GAMEPAD`, which is **4**, in `ZoFontGamepad27` at
`DCD822`. Ours was anchored to the **bottom** of the button, deliberately, from 1.1.0 -- when the
two could be on screen together and had to keep out of each other's way. From 1.1.1 the default
mode fades the client's out instead, so the place ours should stand is exactly where the client's
was. It now uses the client's own anchor, and steps down to the bottom only in "Both", which is a
choice to have two numbers.

Two more things came out of the same report:

- **The labels are anchored to the icon, not the button.** On the gamepad the icon is
  `ZO_GAMEPAD_ACTION_BUTTON_SIZE` = 61 inside a 64 button (67 in 70 for the ultimate), so "the
  middle" and "the corner" now mean the icon's, which is what the player is looking at.
- **The target count moved to the top left.** The client's stack count is at `CENTER` +23, -20 --
  the top right of the icon -- and two numbers in one corner cannot be read.

The duplicate number was a second bug. Fading the client's was conditional on
`GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)` coming back true; a reading
that comes back wrong puts two numbers on one icon, which is the thing it was there to prevent.
Fading a label the game is not drawing on costs nothing, so the condition is gone: in "This
add-on" the client's label is faded, full stop. The setting is still read, for `/pbhud status` to
print.

And the fade remembered *that a slot* was faded rather than *which label* was, so a slot whose
button had been rebuilt was taken for done and left with the game's number on top of ours. It
remembers the control now, and hands back anything it faded earlier.

## 25. One size per bar, without resetting anybody's

The two rows are not the same size on screen: the gamepad action button's icon is 61, and the
other weapon set's row is drawn in the client's back row frame, whose icon is 44. One text size
for both was always going to be a compromise, so each row has its own.

The row's keys (`backTimerSize`, `backCountSize`) are **unset by default**, and an unset one means
"whatever the bar you are on uses" -- the same shape as a position that has not been moved yet.
So an install upgrading from a build with one size for both sees no change at all, moving the
bar's slider still moves both until the row is given a size of its own, and a button in the panel
puts the row back to following. `/pbhud status` prints both, and says which is following.

## 26. Centred means centred, and a label must be as tall as its text

The client puts its own countdown 4 pixels below the middle
(`ACTION_BUTTON_TIMER_TEXT_OFFSET_Y_DEFAULT_GAMEPAD`), and 1.3.3 copied that to keep the two in
the same place. On a PS5 it reads as sitting low, so ours is now on the middle exactly, offset 0.

The second half of that was the label's box. The client's is `<Dimensions x="0" y="25"/>`: width 0
so it sizes to the text, height fixed at 25 for its fixed 27 font. This add-on's size goes to 48,
and text centred in a box shorter than itself does not sit where the middle of the box is. The
height is set from `GetFontHeight()` whenever the font is applied, so the label is always exactly
as tall as what is in it.

## 27. Three chances to match an effect to a slot

There is no API for how many targets an effect is on, so the effects the player applies are
matched to a slot. By name alone, a morph whose effect is called something else is never counted.
The icon is the better key -- the art is nearly always the ability's own even when the name is not
-- so the match is now name, then ability id, then icon, and `/pbhud slots` prints which of the
three caught it, or that nothing did.

## 28. A default thought better of does not reach an install that already ran

`ZO_SavedVars:NewAccountWide` copies the defaults into the saved table on first run. So
`countFromOne`, which started `false` in 1.1.0 and was changed to `true` in 1.1.1 because "nothing
is showing" is worse than a 1, stayed `false` for ever on every install that had run 1.1.0 --
which is the whole of the target count doing nothing for a single-target ability.

Repairing a nil key, which is all `Account()` did, cannot see this: the key is not missing, it
holds an old default. The text settings carry a `version` now, and a change of mind moves the
value on once and stamps it, so a player who then chooses the old value keeps it.

## 29. The liquid style is gone, and what replaced it

The liquid style never drew anything on a PS5, and nothing found from here explained it: the
style was on, the loop ran, the controls were built. 1.5.0 replaces it with a plain one rather
than carrying on guessing, and deliberately changes the two things about the old one that could
each have been the reason:

- **Where it hung.** The liquid overlay was a child of the client's **status bar** controls, and
  nothing in the client does that -- the client's own gloss is a child StatusBar, but every other
  thing drawn on a bar (the frame, the background, the numbers, every attribute visualiser
  overlay) is a child of the **container**. The plain rectangles are children of the container
  too, anchored over the bar.
- **What it was made of.** Textures, blend modes and texture coordinates, any of which can come to
  nothing without an error. A backdrop is a centre colour: `SetCenterColor` and a width, no art to
  fail to load.

What it does not change is the part that was right: the client's own bars are left alone and
still doing their work, so the shield, armour and possession overlays and the low-health warning
all still draw. The frame and background are hidden by their own flag while the style is on, and
put back the moment it is not.

`/pbhud plain` prints the same chain the liquid one did.

## 30. One switch that really does hand the bar back

Another add-on laying out the skill bar has to be able to have it. "Off" here cannot mean "stop
writing": this add-on re-anchors the bar and its buttons, fades a client label, builds controls
parented to the buttons, and has a watch that puts all of that back once a second. Any one of
those left running is a fight.

So `SkillBarAllowed()` is asked by all of them, and the existing paths do the rest without a
special case:

| | asks it through | what happens when it says no |
| --- | --- | --- |
| position, size | `BarDiffers` | `ApplyBar` restores the anchor and the scale |
| the gaps | `SpacingDiffers` | `skillbar:Apply` restores every button's anchor |
| the row, the text, the shade | `Wanted`, `ShowsTimerOn`, `ShowsCount`, `BackBarEnabled`, `ShadeEnabled` | the loop hides its controls, hands the client's countdown back its alpha, and unregisters |
| the watch | `AnythingDiffers` | nothing differs, so it writes nothing |
| the preview | drawn per element | the skill bar's outline is not drawn |

`BarsReady()` stops asking for `ZO_ActionBar1` as well: a bar this add-on has been told to leave
alone is not a reason to hold up the three attribute bars.

## 31. Three from one PS5 round

**The target count appeared and vanished again.** Re-applying a damage-over-time on a target that
already has it sends `EFFECT_RESULT_GAINED` for the new application and `EFFECT_RESULT_FADED` for
the old one **after** it. Taking that fade at face value drops the unit that was just added. The
fade carries the end time of the instance that faded, so the two are told apart: a fade whose
instance was due to end well before what is on record (250 ms of tolerance) is for something
already replaced, and is ignored. `/pbhud slots` counts the ones it ignored.

The same line has a second guard: an effect that arrives with an end time already gone by is the
two clocks disagreeing, not an effect that is over, and taking it at face value would drop it the
moment it is looked at. It is kept as one that does not expire, ended by its own fade, and
counted.

**The game's own countdown came back from behind ours.** `ActionButton:ApplyStyle` calls
`ApplyTemplateToControl` on the button, which re-applies the platform template to its children --
and a template carries an alpha. It runs from `HandleSlotChanged`, which is every weapon swap,
every zone load and every change to what is in a slot. So "we faded it once" is wrong within a
minute of play. The fade is now decided by reading the label's alpha each time rather than by
remembering, and status prints how often it had to put it back.

**The resource numbers were behind the plain rectangle.** `ZO_PlayerAttributeBarText`, which the
numbers inherit, sets no tier at all, and the rectangles are `tier="HIGH"`. The numbers are lifted
to `DT_HIGH` at a level above the rectangle while the style is on, and put back at the client's own
tier and level when it is not -- re-asserted every update, because the client re-applies its
templates to those labels too. The low-health warner needs no such help: `ZO_PlayerAttributeWarner`
is layer `OVERLAY`, tier `HIGH`, level 500.

## 32. The target count is held by the client's own timer

The count still blinked out after §31, so the answer is no longer to find the event that does it.
The number's lifetime is tied to the thing that is already right and already on the same icon:
`GetActionSlotEffectTimeRemaining` for that slot. While the client says the slot's effect is
running, the last count worked out stays on the icon; when that timer reaches zero, or another
ability is in the slot, it goes. The countdown and the count now end together by construction.

A count worked out again always replaces what is held -- targets dying is a real change and
should show. Only a drop to **nothing** is held, because that is the failure mode: the
bookkeeping losing the effect while the effect is plainly still running.

The cost is that a damage-over-time whose targets all die before it expires keeps its last number
until the slot's timer runs out. That is the right way round: a number a few seconds stale beats a
number that is never there.

The two event-level guards stay, because they are still correct:

- a fade whose instance was due to end well before what is on record is for something already
  replaced (§31);
- and, for a client that sends the old instance's fade carrying the **new** times, where comparing
  the two says nothing: a fade arriving within 400 ms of an application for the same effect on the
  same unit is the one being replaced.

`/pbhud effects` prints the last twenty effect events with what the add-on did with each -- gain,
fade, or ignored -- so a third round of this can be answered from the console.

## 33. One slot, two effects

From a PS5: Blue Betty's countdown ran 22, 21, ... and then, a few seconds from the end, started
again at 5.

The number was the client's own. `GetActionSlotEffectTimeRemaining` answers with **one** number
for a slot that can have more than one of the player's effects running at once: the netch grants
its buff for 22 seconds and does something of its own every 5, and a few seconds from the end the
longer of the two is the five-second one. Read straight -- which is what this add-on and the
game's own action bar timers both do -- the countdown hands over to it.

What a player wants is the ability's own effect counted to its end, so from 1.6.3 a reading whose
duration is less than three quarters of the one already running is not taken while that one still
has time on it. A re-cast of the same ability has the same duration, so it is taken and starts
again. A short effect with nothing longer running is shown as it is. And a client that says
nothing is running is believed: an effect purged, or its target dead, is over.

The countdown, the shade and the target count's hold all read through the same call, so the three
cannot disagree about which effect a slot is showing. `/pbhud slots` prints the client's raw
number next to the one on the icon whenever they differ, and counts the readings it did not take.

## 34. The per-slot timer is the wrong source, and always was

Blue Betty came back a second time, with the sentence that settles it: **other add-ons show it
correctly**. So the information is there and reliable, and the source being used was not.

`GetActionSlotEffectTimeRemaining` answers with one number for a slot that can have several of
the player's effects running, and hands over between them -- the netch's 22-second buff giving way
to the five-second thing it does. Guards on top of that reading (1.6.3) could not tell which of
the two the player meant, because the reading does not say.

Action Duration Reminder, which gets this right, **does not call that API at all**. It watches for
the cast: `EVENT_ACTION_SLOT_ABILITY_USED` says which slot was pressed, and the effects that
arrive in the moment after it belong to it. From 1.7.0 this add-on does the same:

- a cast records the slot, the hotbar it was on, and the time;
- an effect arriving within 1.5 s of a cast, lasting at least 0.9 s, is that slot's; the longest
  of one cast's effects wins, which for Blue Betty is the 22-second buff and not the netch's five
  seconds;
- while that effect runs, the client's reading is not asked at all;
- when it ends, a client reading whose duration is under three quarters of it is refused too, so
  the little effect the same ability keeps up alongside cannot step in at the end;
- the slot's own icon, remembered at cast time, says when the slot holds another ability and the
  association is dropped.

The target count now counts the units under **that same effect**, so the number and the countdown
cannot be looking at different things -- and it is why the count kept vanishing: it was matched by
the ability's name, which is not what the effect is called.

The clock the add-on compares effect times against is the client's own as well:
`GetFrameTimeMilliseconds`, which is what the client uses (`zo_stats_gamepad.lua`:
`local timeLeft = (endTime * 1000.0) - GetFrameTimeMilliseconds()`). `/pbhud effects` prints both
clocks, and `/pbhud slots` says for each slot whether the countdown came from the cast, from the
client, or from a reading that was refused.

## 35. One ability, two slots, one countdown

The netch on both weapon sets counted down to two different numbers.

A cast was on record against the slot **and the hotbar** it was made on, so only that bar had it;
the other fell back to the client's per-slot reading, which is the reading that hands over to
something else (§34). But it is one effect however many slots the ability sits in, so a cast is
now also on record against the **slot's own art** -- the ability's icon -- and a slot with no cast
of its own looks there before it falls back to the client.

That is also what makes a weapon swap invisible to the countdown: the bar coming into hand finds
the same record. A different ability in the slot has different art, so it is not given somebody
else's time.

## 36. A great many effects are not applied by the player

The target count still did nothing for some abilities, and one registration is the reason:

```lua
EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED,
    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
```

Filtered to the player as the source, **nothing a pet applies is ever seen**. The netch of Blue
Betty is a pet; so are the sorcerer's familiar and twilight, the warden's bear, the nightblade's
shade. For every one of those the effect never arrives, so there is no effect to tie to the cast
and nothing to count. Action Duration Reminder registers the same event twice for exactly this
reason (`Core.lua`: `addon.name` and `addon.name..'_pet'`), and a third time unfiltered for two
named abilities the client reports with no source at all.

Both registrations are made now: `COMBAT_UNIT_TYPE_PLAYER` and `COMBAT_UNIT_TYPE_PLAYER_PET`.
`/pbhud effects` says how many are in place.

## 37. The cap threw out the wrong entries

The table of tracked effects is capped, and what went to make room was the least recently
**added**. A damage-over-time ticking quietly on three targets is never added again while it
runs, so it was exactly the shape of entry the cap threw out -- the target count disappearing
mid-fight for no reason the player can see. Reading an entry now counts as using it, what goes is
the least recently used entry with **nothing live in it**, and only if every entry is live does a
live one go. The cap is 128 rather than 96, and `/pbhud effects` counts what has been dropped.

## 38. The ability's own length, from the game

From a PS5: Templar's Power of the Light lasts 6 seconds and the countdown read 20.

One cast puts more than one effect on the world -- the ability's own, and Major Breach for twenty
seconds -- and 1.7.0's rule, "the longest effect of that cast", picks the wrong one of the two.
Blue Betty needed the longest; Power of the Light needs the shorter. Nothing about the effects
themselves says which.

FancyActionBar+, which the add-on was given to read, does not guess: it reads
**`GetAbilityDuration`** for the ability in the slot (`main.lua`,
`FancyActionBar.GetAbilityDuration`) and works from there, with a curated table for the ids where
that is not enough. The general half of that is free, and it is what this add-on now does: a cast
records what the game says its ability lasts, and the effect that is followed is the one whose
length is closest to it. With no duration to compare against -- an ability the game gives none for
-- the longest is still the best guess, which is where this started.

## 39. A target without a unit id

Some area effects report `unitId` 0. Keyed by the unit tag alone, as this did, every target of
such an effect collapses onto one key: a count of 1 however many were hit, and one fade clearing
the lot -- another way the target count came to nothing.

The effect's own `effectSlot` tells two instances apart, and is what FancyActionBar+ keys on
(`ResolveUnitKey`). The key is the unit id where there is one, the effect slot where there is not,
and the unit tag only as a last resort.

## 40. A size, for the one style that can have one

Every other style **scales**: the bar keeps the shape the game drew and is made bigger or smaller
whole. That is not a preference, it is §3 -- the width of those controls belongs to the attribute
visualiser, which writes 141 / 237 / 323 onto them as buffs come and go, so a width written here
would last until the player's next meal.

MURA-HIGE Style draws the bar itself, so there is nothing to fight: it takes a width and a height
in pixels and is exactly that. The overlay stands on the edge the bar fills from and level with
the bar the game has, so the position sliders still say where it is; the health bar's two halves
each take half of the width and meet in the middle.

The one thing it needs that the scaling styles do not is the game's own fill **out of the way** --
a bar narrower or shorter than the game's leaves the game's showing round it. The bar control
cannot be hidden for that: `powershield.lua` parents the damage shield overlays to it
(`CreateControlFromVirtual("$(parent)PowerShieldLeftOverlay", attributeBar, ...)`) and they would
go with it. So its gradient is taken to nothing and its gloss, which has no children, is hidden;
putting it back is the client's own line, `ZO_POWER_BAR_GRADIENT_COLORS` for that power, which is
what `ZO_PlayerAttributeBar:RefreshColor` uses.

The sliders were nearly shipped with the same labels as the position ones -- "Stamina: height"
twice in one panel, the second unreachable. They are "bar width" and "bar height" now.

## 41. The preview's row was the width of the whole bar

From a PS5: the other weapon set's outline in the settings panel looked far too wide.

It was drawn at the skill bar's full width, and the bar's control is 606 wide while the six slots
of the row stand over `ActionButton3` to `ActionButton8` and nothing else -- the quickslot and, on
the gamepad, the invisible weapon swap marker hold the left-hand end and have no row above them.
Measured in the harness, the buttons begin a fifth of the way into the bar (61 for the marker's
place, 45 for its width, 10 for the gap, of 606), so the outline promised a row a quarter again
as wide as the one that appears.

Where the buttons sit is now measured off the real controls and given back as **fractions of the
bar's width**. Fractions rather than distances because they are free of scale -- both numbers are
scaled the same and it cancels -- so the outline holds whatever size the bar is set to, and moves
in when the gaps are closed.

## 42. A rounded bar is three pieces, not one texture (withdrawn in 1.10.0)

MURA-HIGE Style came out with square corners. It was drawn as one stretched copy of
`gp_dynamicBar_medium_fill.dds`, and that file is the **fill** -- a plain block, which a status
bar stretches across its length. The round ends are not in it.

Every rounded bar the gamepad interface draws is three textures from
`gp_dynamicBar_medium_frame_white.dds`: a left cap, a right cap, and a middle stretched between
them, each with its own texture coordinates out of the sheet
(`statusbartemplates_gamepad.xml`, `ZO_GamepadWhiteFrameLeftMedium` / `RightMedium` /
`CenterMedium`). `ZO_GamepadSlider` is the plainest example: its whole track is exactly those
three. So is this style's track, and so is its fill.

The caps are 7 wide for the 22-high bar the art was drawn for, and are scaled with the height so
that a thin bar does not end up with caps fatter than it is tall. The height is passed to that
sum rather than read off the container: a control sized by its anchors answers 0 until it has
been laid out, and the caps would come out at their smallest.

## 43. The rounded shape is gone

Built out of the client's own three-piece bar art (§42) it still did not look right on a PS5, and
a shape nobody can see the point of is not worth a third attempt. MURA-HIGE Style is the same flat
rectangle as Square from 1.10.0, and what makes it its own style is the thing that was wanted:
a **width and a height of the player's choosing** rather than a multiple of the game's.

The saved key is still `rounded`, because that is what is in people's saved variables.

## 44. An outline instead of the game's frame

"Keep the game's frame" is gone: a flat rectangle inside an arrow-shaped frame is neither one
thing nor the other, and nobody wanted it. The frame on offer is this add-on's own -- four thin
rectangles round the bar, on or off.

Four rectangles rather than a backdrop's own edge, because an edge needs an edge **texture** and
no art ships with this add-on. Each side is held by two corners so it stretches with the bar,
which also means the outline is right whatever size MURA-HIGE Style is set to.

## 45. Choosing the style is the setting

MURA-HIGE Style appeared to do nothing until a size slider was moved. Whether a bar was drawn at
a size or scaled was decided by whether a size had been **saved**, so a fresh install of the style
fell through to "follow the game's bar" -- which is what Square does -- and the sizes looked as
though they only took on the second attempt.

Choosing the style is the setting. An unset width or height is the game's own size, drawn at that
size by us, which looks the same and behaves the same as every size after it.

The panel now also takes turns: the pixel rows are live only in MURA-HIGE Style and the
percentage only outside it, through `disable` functions on the rows (which
LibHarvensAddonSettings takes as a function, as Votan's Minimap does). The style dropdown calls
`UpdateControls` so the change shows at once. The skill bar is scaled whatever the attribute bars
are doing, so its own percentage stays live.

## 46. The target count against FancyActionBar+'s

Asked whether the number in the icon's corner works the way FancyActionBar+'s does. The idea is
the same -- count the units an effect is on and drop them as they expire -- and three rules were
not.

| | FancyActionBar+ | here |
| --- | --- | --- |
| on yourself | not recorded (`GetAbilityTargetDescription(id, nil, unitTag) == "Self"`) | **now** not counted |
| on your pets | not recorded (`IsPlayerPet`) | **now** not counted |
| area effects | not recorded at all, unless a cast is running with a real unit id | counted |
| the key for a target | the unit id, and only when it is above zero | unit id, else the effect's slot, else the tag |
| shown from | 2 targets, or 1 for a debuff with the option on | 1 by default, 2 by setting |
| a count that comes back empty | recomputed, so it goes | held while the client still times the effect |

The first two are worth having and are taken: a buff on yourself is not a target count -- the
countdown beside it already says it is up -- and neither is one on something of yours. They were
the whole of the "1" that appeared on every self-buff.

The rest are deliberate differences. FancyActionBar+ can leave area effects out because it
carries a table of hand-tuned ability ids to fall back on; this add-on has no such table, so it
keys a target by the effect's own slot where there is no unit id and counts the area effects that
way (§39). The hold (§32) is ours because the bookkeeping under it is simpler than theirs. And
"from 1" is a better default once a buff on yourself no longer produces one.

One thing worth noting about the reference: `GetAbilityTargetDescription(...) == "Self"` compares
against an English string, so on a Japanese client that test never matches. The check here is
`unitTag == "player"`, which holds in any language.

## 47. The countdown against FancyActionBar+'s

Asked the same question of the duration. Both start from `GetAbilityDuration` for the ability in
the slot (§38); what differs is everything around it.

| | FancyActionBar+ | here |
| --- | --- | --- |
| which effect is the slot's | its ability id, through a curated map of effect id to slotted id (`config.lua`, 1700 lines) | the effects that arrive within 1.5 s of the cast, the one whose length is nearest the ability's |
| when the countdown starts | at the cast for the abilities its list names (`onAbilityUsed`: `effect.endTime = duration + t`) | **now** at the cast for any ability that declares a length, with the first effect of that cast taking over |
| several targets | `effect.endTime = maxEnd`: carried out to whichever ends last, never pulled in | **now** the same |
| toggles, ground effects, channels, banners | a handler each | none |
| the client's per-slot timer | never called | the fallback where no cast is on record |

The two marked "now" are taken in this release, and both are the reference's behaviour without
its table: any ability that declares a length starts counting the moment it is cast, so an
ability whose effect the client never reports still shows something, and a later target carries
the countdown out rather than leaving it on the first one's end.

What is deliberately not taken is the table. FancyActionBar+ can key an effect straight to a slot
because it carries a hand-tuned map of ability ids, and a handler for each awkward family --
toggles, grounds, channels, the banner. Seventeen hundred lines of it, maintained release by
release. This add-on has the cast to work from instead: less exact for the families that need a
handler, and nothing to keep up to date.

## 48. The tooltip's length is the reference, not the longest effect that turns up

From a PS5: Templar's Blinding Flashes lasts 10 seconds and the bar read 6.

One cast, more than one effect, for the third time -- and this one the other way round from Power
of the Light. There the ability's own effect was the short one and a 20-second Major Breach came
with it; here the ability's own is what the client does not report at all, and the six-second
effect that comes with it was the only candidate there was. "The candidate closest to the
ability's length" then picks it, because it is the only thing to pick.

So a candidate is now only followed if it is **about as long as the game says the ability is** --
within a quarter, and never less than a second and a half, which leaves room for the passives and
sets that stretch a duration a little. Nothing matching means the length from the tooltip stands,
counted from the cast (§47), and that is the number the player is comparing against anyway.

The three cases together, and what each needs:

| | the game says | effects seen | followed |
| --- | --- | --- | --- |
| Power of the Light | 6 s | 6 s, and 20 s of Major Breach | the 6 s effect |
| Blue Betty | 22 s | 22 s of Major Sorcery, 5 s of netch | the 22 s effect |
| Blinding Flashes | 10 s | 6 s only | the tooltip's 10 s |

FancyActionBar+ gets all three from its table of ability ids. This gets them from
`GetAbilityDuration` and one rule, which is the trade named in §47: no table to keep up to date,
and less exact where an ability's real duration is not what the game declares.

## 49. Ground targeting: tried twice, withdrawn

A ground-targeted ability is pressed once to start aiming and again to place it, and counting
from the press has the countdown running while the circle is still on the floor. 1.12.0 held such
a press until the aiming ended, the way FancyActionBar+ holds its slot updates
(`main.lua`, `groundTargetMode`, across `EVENT_ENTER_GROUND_TARGET_MODE` and its `LEAVE`).

On a PS5 it took **every** countdown in the add-on with it. 1.12.1 answered the three ways that
could happen -- the gate also asked `IsPlayerGroundTargeting()`, a held press had nothing but the
`LEAVE` event to release it, and an ended cast was remembered for ever, which silences the client
for that slot (§34) -- and it still showed nothing. So the cause is something else, and the code
is out: 1.13.0 is 1.11.1's implementation exactly, which is the last one known to display.

What a third attempt would need first, rather than another guess:

- whether `EVENT_ENTER_GROUND_TARGET_MODE` arrives at all on console, and whether its `LEAVE`
  follows. `/pbhud effects` printed "aiming now", presses held, and holds that timed out; a
  screenshot of that line while the countdowns were missing would have said which of the three it
  was, or that it was none of them.
- whether `EVENT_ACTION_SLOT_ABILITY_USED` fires at the press or at the placement for those
  abilities. If it fires at the placement there is nothing to fix in the first place.

Two rounds of a PS5's time went on this, and the feature is worth less than the countdown it
broke.

---

## Still to measure on a PS5

1. **Does writing the anchor work?** `SetAnchor` and `ClearAnchors` are marked
   `protected-attributes` in the API dump. PC add-ons re-anchor client controls routinely, and PB's
   ChatWindowCustomizer re-anchors a client top-level, but this is the first PB's add-on to
   re-anchor a client control *away from its own parent*. Move one slider, go back to the HUD and
   run `/pbhud status`: the bar's `anchor:` line must read `CENTER -> GuiRoot BOTTOM` with the new
   offsets, its `middle=` must match the settings, and there must be no `refused` line. If there
   is one, it names what was refused and why.
2. **Where does `SetScale` scale from?** `status` prints each bar's on-screen rectangle and the
   middle worked back out of it. At 150% the `middle=` must still equal the settings; if it has
   drifted by a quarter of the bar, the pivot is the control's top left and the anchor needs an
   offset of `(scale - 1) * size / 2`.
3. **Is the size really the whole bar?** At 200%, the frame arrows, the background and the
   resource numbers must all grow with the bar — nothing left at its old size, nothing clipped.
4. **Does the fade still work?** With "fade out of combat" on in Settings > Interface, a moved bar
   must still fade out with the other two, and still come back on damage. That is the check that
   re-anchoring did not take the container out of the HUD fragment's reach.
5. **Do the companions still line up?** Mount up (mount stamina under stamina), and at a scale
   other than 100%: the small bar must sit against its partner, not overlap it or float away.
6. **Does a buff still look right?** Eat a meal that raises maximum health. The bar must grow
   evenly both ways from where it was put and stay there, and `status` must still show the
   settings' `middle=`.
7. **Does the measurement come out right?** On a fresh install, before touching anything,
   `status` must show `game's: x=0 y=137 (measured)` for health and ±388/389 for the other two,
   and `differs=false written=false` on all three.
8. **Is the preview drawn above the settings panel?** It is `DL_OVERLAY` / `DT_HIGH`. If it is
   hidden behind the panel, that is the only thing to change.
9. **Does the skill bar move and scale?** Same two questions as 1 and 2, for `ZO_ActionBar1`:
   `/pbhud status` must show `CENTER -> GuiRoot BOTTOM` with the new offsets and no `refused`
   line, and at 80% the ultimate, the quickslot and the weapon swap marker must all come with it.
10. **Does the back row line up?** It is anchored `BOTTOM` on each button's `TOP`. Check the
    ultimate (slot 8, a taller button) sits level with the other five, that the row follows the
    bar when the bar is moved and scaled, and that swapping weapons swaps what it shows.
11. **Are the countdowns the same number the game shows?** Turn the game's own action bar timers
    on, set this add-on's countdown to Always, and cast a damage-over-time ability: the two
    numbers on the front bar must agree. Then swap weapons -- the number must carry on counting
    down on the row, which is the half the game does not draw.
12. **Is the target count right?** Hit three enemies with one damage-over-time ability: the icon
    must read 3, and fall to 2 as the first one dies or the effect drops. A self-buff must read 1
    and not the size of the group. If nothing is written at all, `/pbhud slots` says whether the
    effect is being tracked and under what name -- the name on the left of each slot has to
    appear in the tracked list, and on a Japanese client both are Japanese, so a mismatch there
    is the answer.
13. **Do the gaps come out right?** `/pbhud status` prints the three measured gaps next to the
    three in use. On a PS5 the measured ones should read 10 / 65 / (5 + the marker's width + 10);
    if the item one comes out at 5, the quickslot is not where this add-on thinks it is. Then
    pull all three in and check the row still reads left to right with no overlap, that the
    ultimate and the item are still hittable, and that the back bar row follows.
14. **And with a companion out?** Summon one: its ultimate appears between the item and the
    abilities, and both gaps on that side must take the item setting without the row jumping.
15. **Does the row go away with the Oakensoul Ring on?** Equip it: the back bar must disappear
    on its own and the setting must still say it is on. Take it off and it must come back.
    `/pbhud slots` prints `weapon swap available=false (locked)` while it is on.
16. **Does the text size actually bite?** `/pbhud slots` prints `h=` for each front label, the
    font height the client made of our descriptor. Move the countdown size slider and run it
    again: if `h=` does not move, `$(GAMEPAD_BOLD_FONT)|<n>|thick-outline` is not being
    understood and the face has to change. With the game's own action bar timers on, the default
    mode must also leave exactly one number on the icon, ours.
17. **Is the text legible over the icons?** The labels are `thick-outline` at the chosen size,
    the countdown gold and the count white, over the game's own icon art.
18. **Does the whole lot still fade out of combat?** The labels and the row are children of the
    action bar's buttons, so they should fade with it. If they stay solid over a faded bar, the
    parenting is wrong.
19. **Does the preview come and go with the panel?** Open the panel (the three outlines must
   appear straight away), back out to the list and open it again (they must appear again), open
   another add-on's panel (they must not), and leave with the menu button straight to the HUD
   (they must go). `/pbhud preview` on the HUD draws them over the real bars, which is the
   quickest way to see that the two agree.
