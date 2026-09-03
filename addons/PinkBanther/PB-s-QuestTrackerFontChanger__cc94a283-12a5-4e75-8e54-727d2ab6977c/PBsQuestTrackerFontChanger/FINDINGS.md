# Findings

What was checked before writing the add-on, and where the answers came from. The source is
the client's own Lua, cloned from `esoui/esoui` (branch `live`) — the same repository that
ships `ESOUIDocumentation.txt`, which marks functions `private` / `protected`.

Anything marked **measured** was observed on a real client. Anything marked **from source** is
read out of the client's own Lua and has not been contradicted, but has not been seen on a
PS5 either. The distinction matters: on console a wrong guess costs a whole test round.

---

## 1. Both trackers are Lua UI, not engine-drawn

**From source.** `esoui/ingame/zo_quest/questtracker.lua` builds the focused quest tracker out
of three `ZO_ControlPool`s of `LabelControl`s:

```lua
self.headerPool          = ZO_ControlPool:New("ZO_TrackedHeader", trackerControl, "TrackedHeader")
self.conditionPool       = ZO_ControlPool:New("ZO_QuestCondition", trackerControl, "QuestCondition")
self.stepDescriptionPool = ZO_ControlPool:New("ZO_QuestStepDescription", trackerControl, "QuestStepDescription")
```

`ZO_TrackedHeader`, `ZO_QuestCondition` and `ZO_QuestStepDescription` are `<Label>` virtuals in
`questtracker.xml`, and `LabelControl:SetFont(fontDescriptor)` is public in
`ESOUIDocumentation.txt`.

`esoui/ingame/housingeditor/houseinformationtracker.lua` is the panel under it — the one that
appears in a house, yours or someone else's on a home tour. `ZO_HouseInformationTracker` is a
`ZO_HUDTracker_Base` subclass, and its four labels are `<Label>`s in
`houseinformationtracker.xml` and `hudtracker_base.xml`:

```lua
self.populationLabel = control:GetNamedChild("ContainerPopulation")
self.tagsLabel       = control:GetNamedChild("ContainerTags")
-- and from ZO_HUDTracker_Base:Initialize
self.headerLabel     = self.container:GetNamedChild("Header")
self.subLabel        = self.container:GetNamedChild("SubLabel")
```

Same conclusion for both, and it is the whole difference from PB's NamePlateChanger.

This is the whole difference from PB's NamePlateChanger. There the nameplate is drawn by the
engine and the only surface is `SetNameplateGamepadFont`, a *client setting* — it outlives the
session, it is re-read after every loading screen, and changing the face reloads the UI. Here
there is no setting at all: the font lives on a control, for as long as that control is alive.

Consequences, all of them things the nameplate add-on needed and this one does not:

- no UI reload on a face change,
- no captured "original" to protect, and no repair path for a capture that went wrong,
- no write budget or reload-loop defence,
- uninstalling is a complete undo.

## 2. There are five fonts across the two, not one

**From source.** Each file keeps a constants table per platform:

| section | role | control | gamepad | keyboard |
| --- | --- | --- | --- | --- |
| quest | `questName` | `ZO_TrackedHeader` | `ZoFontGamepadBold27` | `ZoFontGameShadow` |
| quest | `questStep` | `ZO_QuestStepDescription` | `ZoFontGamepadBold22` | `ZoFontGameShadow` |
| quest | `questGoal` | `ZO_QuestCondition` | `ZoFontGamepad34` | `ZoFontGameShadow` |
| house | `houseName` | `...ContainerHeader` | `ZoFontGamepadBold27` | `ZoFontGameShadow` |
| house | `houseDetail` | `...SubLabel` / `...Population` / `...Tags` | `ZoFontGamepad34` | `ZoFontGameShadow` |

Note the gamepad objective lines are **34**, larger than the 27 quest name. That is
deliberate, and it is why the quest size is three settings rather than one.

`houseDetail` is one setting for three labels because the game gives all three the same font —
`FONT_SUBLABEL`, `FONT_POPULATION` and `FONT_TAGS` are all `ZoFontGamepad34` in
`ZO_HouseInformationTracker:InitializeStyles`. One slider per font the game actually uses, no
more and no fewer.

Resolved in `esoui/fontdefs/`:

```xml
<Font name="ZoFontGamepadBold27" font="$(GAMEPAD_BOLD_FONT)|$(GP_27)|soft-shadow-thick"/>
<Font name="ZoFontGamepadBold22" font="$(GAMEPAD_BOLD_FONT)|$(GP_22)|soft-shadow-thick"/>
<Font name="ZoFontGamepad34"     font="$(GAMEPAD_MEDIUM_FONT)|$(GP_34)|soft-shadow-thick"/>
<Font name="ZoFontGameShadow"    font="$(BOLD_FONT)|$(KB_18)|soft-shadow-thin"/>
```

So the descriptor form to write back is `face|size|style` — the same form PB's NamePlateChanger
discovered it had to smuggle the size through, here as the client's own documented syntax.

## 3. The quest tracker: the platform style functions cannot be hooked — but the pools can

**From source.** `ApplyPlatformStyleToHeader`, `ApplyPlatformStyleToCondition` and
`ApplyPlatformStyleToStepDescription` are `local function`s in `questtracker.lua`. Nothing
exports them, so `ZO_PreHook` has nothing to attach to.

They are, however, installed on the pools:

```lua
self.headerPool:SetCustomAcquireBehavior(ApplyPlatformStyleToHeader)
```

and `ZO_ObjectPool:SetCustomAcquireBehavior` just assigns `self.customAcquireBehavior`
(`esoui/libraries/utility/zo_objectpool.lua`), which `AcquireObject` calls. The field is
readable, so the local can be captured through it and wrapped even though its name is not in
scope.

That wrapper is the whole integration:

- it runs on **every** acquire, so the labels the tracker rebuilds by itself — a step advancing,
  a condition counter changing — are styled without any polling,
- the game's own call has just run, so the label is pristine and safe to measure,
- the tracker's own `UpdateTreeView()` still runs after the rebuild, so the new text heights
  are laid out by the game rather than by us.

The two paths that bypass acquire are `ZO_Tracker:ApplyPlatformStyle()` (a gamepad/keyboard
mode change) and any label already on screen when the add-on loads. Both are handled by
walking `pool:GetActiveObjects()`.

`ApplyPlatformStyle` is also the restore path: it is the tracker's own public method for
putting the platform's named fonts back on every active label. "Off" is that call, and so is
the first half of every settings change — without it, a label would keep the larger font it was
just given and nothing would ever shrink.

## 3b. The house tracker: one public method, and it is the only writer

**From source.** Nothing in `houseinformationtracker.lua` is pooled. Four labels are created
once with the control and live for the session, and exactly one thing ever sets their fonts:

```lua
function ZO_HouseInformationTracker:ApplyPlatformStyle(style)
    ZO_HUDTracker_Base.ApplyPlatformStyle(self, style)   -- headerLabel, subLabel
    self.populationLabel:SetFont(style.FONT_POPULATION)
    self.tagsLabel:SetFont(style.FONT_TAGS)
    ...
end
```

`Refresh()` and `RefreshListingTags()` call `SetText`, never `SetFont`. So a font written here
stays written until `ApplyPlatformStyle` runs again, which happens on a platform change and
whenever we ask for it — nothing like the quest tracker's constant rebuilding.

That makes the hook a straight wrapper on the instance's method. It is public, so unlike the
quest tracker's file-locals there is no trick to it; assigning on the instance rather than the
class leaves anything else deriving from `ZO_HUDTracker_Base` alone, and `ZO_PlatformStyle`
calls it through `self:` so the instance field is what it finds.

The same call is the restore path, for the same reason as the quest tracker: going back
through `ApplyPlatformStyle` re-applies the game's named fonts first, and since our wrapper is
on that method, one call does both halves.

**Timing.** `ZO_HUDTracker_Base:Initialize` defers the rest to `ZO_Ingame`'s
`EVENT_ADD_ON_LOADED`, and `InitializeStyles` ends by constructing a `ZO_PlatformStyle`, which
applies immediately. `ZO_Ingame` is the game's own add-on and loads before ours, so by the time
this add-on is loaded the labels are already styled — present, pristine, and ready to measure
as the hook attaches. If a client ever ordered it the other way round, the labels would have no
font yet, `GetFontSize()` would report nothing, and the measurement is simply not taken (and
not marked as taken) until the platform style runs through our wrapper.

## 4. `$(GP_27)` is not 27

**From source, and the reason for the measurement.** The gamepad font sizes are written as
`$(GP_27)`, `$(GP_34)` and so on. Those substitutions are resolved by the engine, not in the
Lua — `GP_34` appears nowhere in `esoui` outside the font definitions and the tooltip styles
that quote it. There is no API to evaluate one.

So an add-on that read the *name* `ZoFontGamepadBold27` and wrote `...|27|...` back would not
be leaving the size alone; it would be setting a size that happens to share a number with the
one the game asked for, before scaling.

`LabelControl` has `GetFontSize()`, and inside the acquire wrapper it is being read off a label
the game has just styled. That is the client's real, scaled number, and it is what the sliders
start from. Recorded once per part per session and persisted, so the settings panel knows it
before any quest is tracked.

Reading it only off a pristine label is the lesson PB's NamePlateChanger learned the hard way:
it captured its own output as "the original" during a rename and needed a repair path to
recover. Here the label is pristine because the game's own styling call is what runs
immediately before ours — but that is an assumption about the client's load order, so the label
is checked as well.

The check is a fact about the string rather than about the ordering. The game always styles
with a **named font object**, `ZoFontGamepadBold27`; this add-on always writes a **descriptor**,
which by construction contains a `|`. A label whose font has a pipe in it is one of ours and is
refused — and not marked as measured either, so a later pristine label still counts. That is
the same `LooksLikeStock` test PB's NamePlateChanger applies to the nameplate descriptor, and it
is what makes the corruption unrepresentable rather than merely unlikely.

## 5. Style tokens are not the enum names

**From source.** The nameplate API took a numeric `FONT_STYLE_*`. A font descriptor takes a
token, and the two do not correspond by name — `FONT_STYLE_OUTLINE_THICK` is written
`thick-outline`, reversed.

Grepping every font descriptor in the client turns up exactly four tokens:

```
shadow  soft-shadow-thin  soft-shadow-thick  thick-outline
```

`FONT_STYLE_NORMAL`, `FONT_STYLE_OUTLINE`, `FONT_STYLE_OUTLINE_SHADOW` and
`FONT_STYLE_OUTLINE_SHADOW_THICK` exist in the enum with no corresponding token anywhere in
the client source. Guessing `outline` and `outline-shadow` would probably work, and "probably"
is not a good basis for a font build on console, so they are left out until one is measured.
"None" is offered as its own entry and is not a token at all — it writes `face|size` with no
third component.

## 6. What the quest header's fixed height does to a larger quest name

**From source.** `ApplyPlatformStyleToHeader` sizes the header control explicitly:

```lua
control:SetDimensions(constants.QUEST_LINE_HEADER_WIDTH, constants.QUEST_HEADER_BASE_HEIGHT)
```

`QUEST_HEADER_BASE_HEIGHT` is 28 in `GAMEPAD_CONSTANTS` and absent from `KEYBOARD_CONSTANTS`.
The conditions and step descriptions are given `UNCONSTRAINED_HEIGHT` (0) and size themselves
to their text.

`ZO_TreeControl:Update` stacks nodes by anchoring each control's top to the previous control's
bottom (`esoui/libraries/utility/zo_treecontrol.lua`), so the header's 28 is what separates the
quest name from the step description under it. A 40-point name in a 28-tall box would be
clipped and overlapped.

The box is therefore grown in the same proportion as the font. Proportion rather than
measurement, because at acquire time the label has no text yet and `GetTextDimensions()` would
be meaningless. Only grown, never shrunk: 28 is already generous for the game's own size, and
shrinking it would pull the whole tracker up into it.

The house panel needs none of this. `ZO_HUDTracker_Base_Template` and its `Container` are both
`resizeToFitDescendents="true"`, no label in `houseinformationtracker.xml` or
`hudtracker_base.xml` carries a `<Dimensions>`, and every one is anchored to the bottom of the
one above it. A larger font grows the panel. `RefreshAnchors()` is called after a restyle
anyway, because it is also what the tracker uses to re-place the population line when the owner
line is hidden.

## 7. Cost on console

The rule inherited from PB's NamePlateChanger, measured there on PS5: **size is free, face is
expensive, outline is very expensive.** ESO's fonts are `.slug` — GPU vector text, resolution
independent — so a size change has no atlas to build. A face the client has not loaded has to
be built. An outline style has to have its glyphs generated, which the game's own source puts
at about 100 MB for a CJK font, against the 100 MB pool every console add-on shares.

What is different here is that the cost is bounded and one-off. `SetFont` on a control is not
a client setting, so there is nothing to re-apply after a loading screen, no reload to pay for
twice, and no "keep the typeface after loading screens" trade-off to expose — the font is
rebuilt from the same descriptor the client already has built.

Two things keep it bounded:

- **Nothing is written while the settings match the game.** `RoleDiffers` is false for a part
  whose size still equals the measured default with the face and outline on Default, and the
  add-on then never calls `SetFont` for it at all. An untouched install builds nothing.
- **At most five descriptors** are ever in play, one per part across both trackers, and they
  only differ from each other by size unless a face or outline is chosen. Two of the five are
  identical to two others whenever the house panel and the quest tracker are left on the same
  settings, because the game's own house name and quest name fonts are the same object.

## 8. Not touched

- **The quest timer.** `questtimer.xml` has its own labels with fonts baked into the XML
  (`ZoFontGamepadBold27`, `ZoFontGamepad42`). It only appears on timed quests and is a separate
  piece of UI; changing it is not what "the quest tracker font" means.
- **The other HUD trackers.** `ZO_HUDTracker_Base` also has an endless dungeon tracker, an
  adventure zone tracker and a promotional event tracker, all in the same column. They would
  each hook the same way as the house panel, and none of them is what was asked for.
- **The text and its order.** Built from journal data by the tracker.
- **Whether the tracker is shown.** `GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER)`
  is readable, but `SetSetting` is private — and per the nameplate work, a private function is
  not something to call to find out: it raises a UI error and kills the running chunk, and
  `pcall` does not protect against it.

---

## Still to measure on a PS5

Everything above marked **from source** holds together, but the following would each be a
visible bug rather than a subtle one, so they are the things to look at first on a real client:

1. **Does the objective text really draw larger than the quest name?** If `/pbquest status`
   reports the three measured sizes in the ratio 27 : 22 : 34 after scaling, the constants
   table was read correctly.
2. **Does `GetFontSize()` return the scaled size?** `status` prints the measured default next
   to what is on screen; with everything on Default they must be equal, and the measured value
   should *not* be exactly 27 unless the client happens to scale by 1.
3. **Does the header box growth land correctly?** Set the quest name to 45 and check the step
   description under it is not overlapped and the name is not clipped.
4. **Is `thick-outline` survivable on the Japanese client?** This is the one setting with a
   measured precedent for crashing on console, from the nameplate work.
5. **Does the house panel measure at all?** `status` reports `houseName` and `houseDetail`
   defaults from anywhere, not just inside a house. If they are still the fallback 27 and 34
   after a login, the hook attached before the client styled the labels and the measurement is
   waiting for the platform style to run — visit a house and check again.
6. **Does the house panel grow cleanly?** Set the house details to 45 on a home tour and check
   the visitor count and the tags are not overlapping the owner line.
