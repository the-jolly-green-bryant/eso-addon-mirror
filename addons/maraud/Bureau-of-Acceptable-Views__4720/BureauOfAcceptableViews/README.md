# Bureau of Acceptable Views

A lightweight camera addon for *The Elder Scrolls Online*. It gives you back
control over the third-person camera in situations where the game normally
takes it away, and layers a few optional cinematic touches on top. Dynamic FOV
is on out of the box for an eased zoom-aware feel; everything else stays out of
your way until you turn it on.

> **Compatibility:** API: LIVE 101050 / PTS 101050 · Optional: LibAddonMenu-2.0
> (>= 43) for the settings panel.

---

## What it does

The core feature is **free zoom in restricted states**. ESO locks the camera
to a fixed distance (or forces first person) in certain situations. This addon
lets you zoom freely between maximum zoom and first person in those states,
with optional persistence so your framing survives zone changes and relogs.

On top of that, several **optional** systems can shape the camera further:

- **Dynamic FOV** *(on by default)* - field of view follows your zoom distance.
- **Context presets** *(off by default)* - cinematic framing per gameplay state.
- **Over-the-shoulder swap** *(off by default)* - swing the camera to one side.

Every optional system is fully inert until it is on, and Dynamic FOV does
nothing on clients where the FOV property is unsupported.

---

## Features

### Free zoom in restricted states
- Zoom anywhere between max zoom and first person while the game would normally
  lock the camera.
- Configurable persistence: keep your zoom across zone changes and logins, or
  let it reset - your choice.
- Controller input safely falls back to the game's default camera handling, so
  nothing breaks if you play on a gamepad.

### Dynamic FOV *(optional, on by default)*
- Ties your third-person field of view to the current zoom distance: tighter
  when zoomed in, wider when zoomed out, smoothly interpolated in between.
- Only recalculates when the zoom distance actually changes - there is no
  per-frame work - so the framing stays consistent without ever touching a hot
  path.
- When disabled, your manual FOV is left exactly as the game set it.

### Over-the-shoulder swap *(optional, off by default)*
- Swings the third-person camera over one shoulder for a focused, cinematic
  frame, and returns it to centre when it should.
- One **mode** selector chooses how it triggers:
  - **Auto** - swings automatically while you are in any state you pick (combat,
    stealth, mounted, swimming, sprint) and recentres when you leave them.
  - **Manual** - swings on demand via the `/bav shoulder` command
    (`left`/`right`/`center`, or no argument to toggle); the automatic behaviour
    is off in this mode.
- A **shoulder offset** slider sets how far the camera swings.
- While shoulder swap is on it takes over the shoulder from the stealth context
  preset, so the two never fight over the same setting - exactly one owns it.
- Your pre-swing shoulder is snapshotted and **persisted**, so a `/reloadui`,
  logout, or crash mid-swing hands your real framing back next session.

### Context presets *(optional, off by default)*
- Applies a fixed cinematic camera bundle for the state you are in - combat,
  werewolf, stealth, interaction (dialogue), mounted, swimming, or sprinting -
  and restores your own framing when you leave it.
- Entering a state is instant, but leaving one is briefly damped: a rapid
  out-and-back (combat ending and restarting a moment later) keeps the cinematic
  framing instead of snapping the camera around, so the view never jitters.
- The interaction state is the exception: entering it is briefly delayed, so
  flicking through a merchant or quick quest turn-in never pecks the camera -
  only a conversation you actually stay in reframes the shot.
- Exactly one state is active at a time, resolved by priority
  (werewolf → combat → stealth → interaction → mounted → swimming → sprint), so
  states never fight each other.
- A single global **intensity** slider scales every bundle, and each state has
  its own style choice plus an individual **intensity** slider that scales that
  state on top of the global value (0% = no effect, 100% = full style strength).
- Your pre-preset camera is snapshotted the first time a preset takes over and
  **persisted**, so a `/reloadui`, logout, or crash while a preset is active
  hands your real camera back next session instead of baking the preset's
  offsets into your settings.
- Open the game's settings while a preset is active and your camera quietly
  reverts to your real values for editing, then the preset re-applies on top of
  your changes when you close it - so tweaking FOV or distance never fights the
  active preset or gets baked into your saved framing.
- An **emergency restore** button in the settings panel instantly returns the
  camera to your control if anything ever feels stuck.

### Conflict resilience *(automatic safety net)*
- Because BAV hooks the game's own first-person toggle, another addon that
  drives that toggle can, in rare cases, fight it and make the view flicker
  between first and third person. BAV watches for that: if the view flips back
  and forth at a rate no human could produce, it **steps its own handling
  aside** (passes the toggle straight to the game) to break the loop.
- The backoff is fully **reversible** and touches none of your saved settings -
  it clears the moment you relog or use `/bav reset`.
- A related case: some game states (notably ZOS's reworked **werewolf**) take
  over the camera distance and **reject** BAV's writes. Combined with another
  addon measuring the camera by toggling first person twice in one frame, this
  used to leave the view stuck in first person - re-forced on every manual
  zoom-out. BAV no longer tries to recognize and unwind such toggle pairs by
  timing. Instead, in the states it manages, a toggle only records **where the
  camera should end up** and a single write on the next frame moves it there
  (see *Convergent toggle handling* below). A measurement addon's toggle-and-back
  pair cancels out to no net change on its own, with no dependence on frame
  timing, and a rejected write is retried a bounded number of times rather than
  leaving the view half-moved. A sustained run of rejected camera-distance
  writes are recorded in the debug log for troubleshooting.
- **Known interaction: camera-probing addons.** Some addons (notably *Miat's
  PvP* / PvpAlerts) measure the camera by toggling first person several times in
  a single frame. With older BAV builds this could briefly force or stick the
  view in first person. The convergent toggle handling above neutralizes it on
  BAV's side - the probe cancels out to no net change - so the two run together
  with no special configuration. If a view ever feels stuck, `/bav reset`
  returns control immediately. A proper upstream fix (the probe only firing when
  its result is actually needed) would remove the interaction at the source.

---

## Why it's built well

- **No surprises.** Context presets and over-the-shoulder swap stay off until you
  enable them, and any disabled module is fully inert - it registers no events,
  runs no polling, and never writes to the camera. Dynamic FOV ships on, but its
  toggle returns the camera to exactly what the game set.
- **One source of truth for engine I/O.** All camera reads and writes go
  through a single `CameraSettings` layer that handles the engine's value
  formatting and verifies every write by reading it back. A future client
  change needs fixing in exactly one place.
- **No FOV tug-of-war.** A dedicated `FovArbiter` makes field-of-view
  precedence explicit, so dynamic FOV and context presets can never overwrite
  each other depending on load order or timing - a preset hold cleanly overrides
  dynamic FOV.
- **One owner per contested setting.** Just as `FovArbiter` owns the FOV, shoulder
  swap takes sole ownership of the shoulder offset while it is on, so it and the
  stealth preset never write the same value out of turn.
- **One implementation per repeated pattern.** Where several modules grew the same
  mechanism, it lives in one place: `Ease` owns the self-tearing glide lifecycle for
  every animated value (FOV smoothing and preset transitions),
  `OptionsWatch` owns the single settings-window subscription every feature suspends
  on, and `SprintWatch` owns the event-driven sprint detector every feature that
  cares about sprinting subscribes to. Each caller supplies only its payload, so
  a fix or a client change lands once, not in four near-identical copies.
- **Convergent toggle handling.** In the states BAV manages, a first-person
  toggle does not write the camera on the spot. A dedicated `ZoomReconciler`
  records *where the camera should settle* and performs a single write on the
  next frame. This is correct by construction: another addon's toggle-and-back
  measurement pair cancels out to the same intent it started from, so the view
  never desyncs - and it does not matter whether those two toggles land in the
  same frame or not. There is no frame-timing guesswork to break in edge cases
  like the world map or a transformed state.
- **Nothing on the per-frame path.** Work happens only in response to real
  events - a zoom change, a state transition - or a coarse 150 ms sample for the
  things ESO exposes no event for (sprint state, movement speed); never every
  frame. The transient FOV/shoulder glides tear their own updater down the moment
  they land.
- **Recovers gracefully.** The pre-preset camera snapshot and the pre-swing
  shoulder are persisted, so an interrupted session never leaves cinematic
  offsets or a one-sided camera baked into your settings.
- **Catches its own regressions.** A pull-based self-check validates internal
  invariants and watches the footprint of its own tables at quiet moments,
  turning silent bugs into a single readable warning - without adding any
  per-frame cost.
- **Plays nicely with others.** BAV shares the game's first-person toggle with
  any addon that uses it. The convergent handling above means the rapid
  toggle-and-back pairs other addons use to measure the camera cancel out
  cleanly, and if it ever detects a runaway view flicker it steps its own
  handling aside - a reversible safety net that needs no configuration and never
  blames another addon.
- **Localized** with English and Russian strings, and a clean LibAddonMenu
  settings panel.

---

## Architecture at a glance

The addon is split into layers with **one-way dependencies**: upper layers know
about lower ones, never the reverse. Two rules anchor the whole design - *only*
`CameraSettings` talks to the engine, and *only* `FovArbiter` decides who owns
the field of view. Everything else is a consumer of those two contracts.

```
            Settings.lua            UI + SavedVariables - wires everything
                 │ Configure(...)
  ┌──────────┬──────────────┬─────────────────┬──────────────┐
  ▼          ▼              ▼                 ▼              ▼
DynamicFov ContextPresets ShoulderControl   Free-zoom core
  │          │              │ (owns shoulder)  (BureauOf…Views.lua)
  └────┬──────┘             │
   FovArbiter            │  single owner of FOV precedence
        │                │
        ▼                ▼
    CameraSettings          the only verified engine I/O
        │
        ▼
   GetSetting / SetSetting  raw engine API
```

`DynamicFov` flows through `FovArbiter`, which lets a context-preset hold
override it cleanly. `ShoulderControl` is the single owner of the shoulder offset
whenever it is on, so `ContextPresets` cedes that one setting to it.

`Ease`, `OptionsWatch`, and `SprintWatch` sit *below* everything as shared leaf
primitives: the consumers call into them, they call back through payload
callbacks, and none depends on another feature module. `Ease` owns the
self-tearing updater behind every glide; `OptionsWatch` owns the one
settings-window subscription and the canonical open/closed state features
suspend on; `SprintWatch` owns the one event-driven sprint detector and the
canonical is-sprinting sample. Factoring the repeated mechanism into one place
is what keeps a fix or a client change a single edit.

---

## Module overview

| Module | Responsibility |
| --- | --- |
| `BureauOfAcceptableViews.lua` | Core: free-zoom logic, event wiring, saved-variable lifecycle, slash commands. |
| `CameraSettings.lua` | The single, verified access layer for every engine camera setting. |
| `ZoomReconciler.lua` | Single owner of where the camera settles after a BAV-handled first-person toggle; defers one coalesced write so probe pairs canc
| `SprintWatch.lua` | Shared event-driven sprint detector and the canonical is-sprinting sample every feature that needs sprinting subscribes to. |el out. |
| `Ease.lua` | Shared time-based easing primitive: one self-tearing updater lifecycle behind every glide (FOV smoothing and preset transition). |
| `OptionsWatch.lua` | Shared watcher for the settings window: one fragment subscription and the canonical open/closed state every feature suspends on. |
| `DynamicFov.lua` | Optional zoom-dependent field of view. |
| `FovArbiter.lua` | Single owner of third-person FOV precedence (dynamic FOV vs. preset holds). |
| `ContextPresets.lua` | State-driven cinematic bundles with snapshot/restore and persistence. |
| `ShoulderControl.lua` | Optional over-the-shoulder swap (auto-by-state or manual); single owner of the shoulder offset. |
| `Settings.lua` | SavedVariables, defaults, and the LibAddonMenu panel. |

---

## How it works

A few small maps of the moving parts. None of this is required reading to *use*
the addon - it is here for the curious and for anyone reading the source.

### State priority - only one preset wins

Context presets never fight each other. At most **one** state is active at a
time, resolved top-down by priority and gated by each state's style choice:
the first state that is both physically active *and* set to a style other than
Off wins.

```
   physical state(s) active ──▶  resolve by priority  ──▶  one winner
                                 ┌───────────────────┐
   highest  │  werewolf    ─────▶│ first active state │
            │  combat      ─────▶│ with a non-Off     │
            │  stealth     ─────▶│ style wins; rest   │──▶ apply bundle
            │  interaction ─────▶│ are ignored        │
            │  mounted     ─────▶│                    │
            │  swimming    ─────▶│                    │──▶ none? → restore
   lowest   │  sprint      ─────▶│                    │      your framing
                                 └───────────────────┘
```

Werewolf deliberately outranks combat - a transformation should win even mid-fight.

### Dynamic FOV - zoom drives the lens

Dynamic FOV maps the current zoom distance to a field of view through
`FovArbiter`. A context-preset hold overrides it while active.

```
  zoom distance ─▶ DynamicFov ─▶ FovArbiter ─▶ FOV
                          │
                          └─ unless a preset hold owns FOV
```

### Over-the-shoulder - one owner for the shoulder

When shoulder swap is on it owns the shoulder offset outright. In **auto** mode it
swings while any chosen state is active and recentres when you leave them all; in
**manual** mode `/bav shoulder` drives it. Either way, `ContextPresets` cedes the
shoulder so the two never write it out of turn.

```
   mode = auto                              mode = manual
   ┌───────────────────────┐               ┌───────────────────────┐
   │ in a chosen state? ───▶│ swing to side │ /bav shoulder ───────▶│ swing / toggle
   │ left them all?    ───▶│ recentre      │ (left/right/center)    │
   └───────────────────────┘               └───────────────────────┘
        │ first swing: snapshot + persist your real shoulder ──▶ restored on
        │                                                        recentre / crash
        └─ ContextPresets.OwnsShoulder()? → stealth preset skips shoulder
```

### Snapshot & restore - surviving a crash

The first time a preset takes over, your real camera is snapshotted **and
persisted** to SavedVariables. So even a `/reloadui`, logout, or crash mid-preset
hands your genuine framing back next session - never the preset's offsets.

```
  preset takes over          session ends abruptly         next login
  ┌──────────────┐           ┌──────────────────┐          ┌──────────────┐
  │ snapshot live│           │ /reloadui · crash│          │ recover from │
  │ camera  ─────┼──persist──▶│ logout while a   │──saved──▶│ persisted    │
  │ to SavedVars │           │ preset is active │          │ snapshot,    │
  └──────────────┘           └──────────────────┘          │ then clear it│
        │                                                   └──────────────┘
        └─ back to default in-session ──▶ restore + clear ─────────┘
```

This breaks the drift cycle where a dirty (offset) camera would otherwise be
saved as the new baseline.

