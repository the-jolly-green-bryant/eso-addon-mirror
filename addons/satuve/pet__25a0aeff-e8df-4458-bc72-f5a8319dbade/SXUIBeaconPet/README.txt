SXUI Beacon Pet 0.7.5 - Expanded reference-sheet personality animation

The supplied eight-pose image sheets are RGB composites with black backgrounds,
complete Orb fields and grid lines, so they are not safe direct ESO texture frames.
Their pose language and timing are implemented with the existing pet body, face,
hand and flame layers. The established character artwork remains unchanged.

Integrated deterministic states:
  IDLE_DEFAULT   gentle eight-step breathing and flame presence
  IDLE_BLINK     eight-step close/hold/open eye sequence
  IDLE_LOOK      smooth left/right glance and return
  IDLE_HAPPY     closed-eye smile, small lift and hands-in pose
  IDLE_SLEEPY    droop, yawn, stretch and recovery
  WAVE           raised open hand with three restrained oscillations
  HAPPY_BOUNCE   two soft hops, open hands and happy face
  WALK_LEFT      looping eight-step lean/bob/arm cycle facing left
  WALK_RIGHT     mirrored looping eight-step lean/bob/arm cycle facing right

Reference mapping: the neutral/settle sheets informed IDLE_DEFAULT and IDLE_BLINK;
the glance sheet informed IDLE_LOOK; the dedicated wave sheet informed WAVE; the
sleepy sheet informed IDLE_SLEEPY; the celebration and expressive-pose sheets
informed IDLE_HAPPY and HAPPY_BOUNCE; the two directional sheets informed the
left/right walk cycles. Each reference cell maps to one of eight deterministic
pose phases rather than becoming a replacement bitmap.

Blinking remains about 3.5-7 seconds apart. Subtle look/wave/fidget variations
occur about every 15-28 seconds; happy poses about every 45-75 seconds;
sleepy/yawn about every 80-140 seconds after the first occurrence. A private deterministic
random generator selects variations, so the result is gentle rather than chaotic.

The ruby crystal stays at its original draw level and position in every state.
All 32 Orb controls, art, layout, animation and rune-star data behavior are
unchanged. The independent 25-Hz flame renderer is unchanged. No Companion, EXE,
decoder or capture code is included.

Historical 0.7.4 notes follow:
SXUI Beacon Pet 0.7.4 - Blue rune-star data glow

The binary test channel now energizes the rune instead of drawing a small center
point. Logical 0 keeps the normal rune with only a very faint blue energy trace;
logical 1 adds a clean magical-blue overlay made from softly illuminated inner
rune strokes and a broad four-ray star. The star gently breathes between 78% and
100% of its active intensity over 1200 ms, so it never disappears or becomes an
ambiguous data state.

State transitions take 80 ms at a 500-ms interval and 40 ms at 250 ms. At 100 ms
or below they are immediate for reliable data visibility. The logical state is
always applied at the exact interval boundary. All 32 Orbs remain independently
addressable and all existing test patterns and 20-500-ms interval controls remain.

The old DataCore point is no longer created or rendered. The new overlay sits
between the normal rune and unchanged outer ring. It does not recolor or flash the
whole Orb. Stopped mode hides the overlay completely and remains visually identical
to 0.7.3. Pet, flame, movement, personality, Orb positions/colors and other systems
are unchanged. No Companion or EXE is included.

Use SXUIBeaconPet-0.7.4.zip through the usual Xbox addon workflow. For inspection:
  /beacon bits alt
  /beacon bits counter
  /beacon bits interval 500

Historical 0.7.3 notes follow:
SXUI Beacon Pet 0.7.3 - Rune-center visibility fix only

Real ESO testing showed the DataCore clearly on an Orb without a rune, but the
rune covered it. Every one of the four rune styles now has the same fully
transparent circular center window: exactly 22% of rendered Orb diameter. A soft
alpha edge extends to 24.5%; all rune pixels beyond that remain exactly 0.7.2.
The rune stays visible and recognizable around this small opening.

Each Orb is now drawn in explicit order:
  Orb body/background -> DataCore -> Rune -> outer ring/glow

The old Orb texture was losslessly separated into a non-overlapping body and top
ring; together they select every original 0.7.2 pixel exactly once. Position,
size, color and opacity remain. The DataCore stays 34% of Orb diameter and keeps
the same logical alpha 0.12/0.62. Pulse API, patterns, interval 20-500 ms/default
250 ms, timer and slash commands are unchanged.

Use SXUIBeaconPet-0.7.3.zip through the usual Xbox addon workflow. For inspection:
  /beacon bits alt
  /beacon bits interval 500

Every Orb should show a clean dim/bright core through its rune. No Companion or
EXE is included. Local pixel tests confirm similar contrast with visible and
hidden runes; native Xbox confirmation is still required.

Historical 0.7.2 notes follow:
SXUI Beacon Pet 0.7.2 - Addon-only Orb center-light tests

The approved 0.7.1 pet and 32-Orb layout remain. Every Orb now owns one small,
fixed center-light layer. It is invisible when tests are stopped. During a test,
logical 0 uses alpha 0.12 and logical 1 uses alpha 0.62 on the same 34%-diameter
warm radial texture. Shell, rune, color, movement and position remain unchanged.

Commands:
  /beacon bits off       all 32 logical bits = 0
  /beacon bits on        all 32 logical bits = 1
  /beacon bits alt       101010... from Orb01
  /beacon bits inverse   010101... from Orb01
  /beacon bits wave      one ON center moves Orb01 -> Orb32
  /beacon bits random    new independent random pattern each interval
  /beacon bits counter   big-endian unsigned 32-bit counter; Orb01 is bit 31
  /beacon bits stop      hide all center-light layers; approved look returns
  /beacon bits interval 250

The interval accepts 20-500 ms and rounds to 10-ms steps; default 250 ms. The
logical pattern changes directly at each boundary so 20-50 ms modes do not spend
most of their state in a fade. LibAddonMenu offers Off, Alternate, Wave, Random,
Counter and the interval slider. SetOrbBit(index,value) is available for future
addon code. No gameplay data is connected and no Companion is included.

Use SXUIBeaconPet-0.7.2.zip through the usual Xbox addon workflow. This package
has not been run in native Xbox ESO here; local Lua and pixel tests are not a live
console confirmation.

Historical 0.7.1 notes follow:
SXUI Beacon Pet 0.7.1 - Expanded cosmetic orb aura

This release is purely cosmetic. The four approved magical orbs remain unchanged.
28 similar orbs join them: 32 cosmetic orbs total. They reuse the same shell/rune
art with gentle gold, blue, green and violet shades and softly drift and pulse.
The added orbs occupy an irregular upper semicircle around the pet. The body,
flame artwork, personality, walking and existing four orb movements are unchanged.
The ruby is decorative only. No HP, position, map, zone or other game data is
read or encoded into any visual. The Companion is unchanged and receives no
data from this pet. Transport/calibration commands and settings are retired.

INSTALL
Use the new SXUIBeaconPet-0.7.1.zip through your usual Xbox addon installation
workflow. The only ZIP root is SXUIBeaconPet/ with SXUIBeaconPet.txt.
Keep your saved variables. Existing saved base position, scale and enable/lock
preferences remain. Previous releases are separate and unchanged.

WALKING
The saved position is the base of a short horizontal HUD track. The pet can
travel up to 80 UI units left/right from that base (scaled with the pet); near
screen edges the available travel is shortened. It never wanders vertically.
Typical decisions follow a random 3-12 second idle interval; only some decisions
start a 24-85 unit walk, shortened when less room is available. Normal frequency
uses a 35% chance per eligible decision. Most time is spent idle.
Turns last 0.20 seconds. The face turns and the original arm layers provide a
small walking sway; the flame and orbs are never mirrored.
Walking changes an unsaved local offset, never the saved base position.
On UI reload the pet starts at its saved base.

The flame keeps its original 16 frames, ping-pong sequence and 40 ms timer.
Rare blue/green events use the unchanged cosmetic timing and return to normal.
Menus pause personality, walking and flame. Resume continues from the stored
local state, without catching up the time spent hidden.

CONTROLS
/beacon                  existing settings panel
/beacon move             existing controller/mouse placement
/beacon unlock           enable existing mouse drag; auto-walking pauses
/beacon lock             finish mouse positioning; auto-walking may resume
/beacon walk on          enable walking (default)
/beacon walk off         pause walking at the current local offset
/beacon walk low         less frequent walks
/beacon walk normal      default frequency
/beacon walk high        more frequent walks
/beacon scale 0.95       set pet size
/beacon demo off         pause personality/walking; flame continues
/beacon demo on          resume personality
/beacon on / off         enable or hide the pet
/beacon status           show cosmetic settings

LibAddonMenu (optional) includes Pet Walking and Walk Frequency. Useful size,
position, enable and animation settings remain. Controller bindings and the
existing move panel are unchanged. Automatic walking also pauses while the
move panel is active; saving/cancelling it preserves the normal base semantics.

XBOX CHECK
After /reloadui expect 32 cosmetic orbs, including the unchanged original four.
The larger aura needs room above and beside the pet. The saved position, scale
and walking bounds have NOT been changed to fit it. Close to a screen edge some
new orbs can extend outside the screen; use the existing move controls if needed.
Watch several minutes for
blinks, a double blink, looking/yawning, short walks and natural idle intervals.
Check left/right travel, turns and edge bounds. The flame must stay animated.
Open Inventory/Map and return, then move and resize the pet. The whole visible
pet and all 32 orbs must follow together.

Local Lua and archive checks are not live ESO/Xbox verification. This release
has not been run on your console here.
