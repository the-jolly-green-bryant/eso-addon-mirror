# Findings

What was checked before writing the add-on, and where the answers came from. The source is the
client's own Lua, cloned from `esoui/esoui` — the same repository that ships
`ESOUIDocumentation.txt`.

Anything marked **from source** is read out of the client's own Lua and has not been
contradicted, but has not been seen on a PS5 either. Anything marked **to measure** is a
question this laptop cannot answer. The distinction matters: on console a wrong guess costs a
whole test round.

---

## 1. There is no `GetDate()`

**From source.** `grep -rn "GetDate()" --include="*.lua"` over the whole client returns
nothing, at any API version in the repository. It is worth stating plainly because it is the
first thing anybody writing a daily add-on reaches for, and because several third-party wikis
list it.

What does exist:

```
GetTimeStamp()             -> a UNIX timestamp, the server's clock
GetSecondsSinceMidnight()  -> seconds since midnight, the machine's clock, local
GetDiffBetweenTimeStamps(a, b)
```

`GetSecondsSinceMidnight` is local rather than server time, and that is not inferred — it is
what `ZO_FormatClockTime` in `esoui/libraries/globals/time.lua` is built on, and that function
draws the in-game clock. The local variable there is even called `localTimeSinceMidnight`.

So "what is today's date" has to be computed, and the two inputs are a UTC-ish instant and a
local wall clock. See §2.

## 2. The two clocks cannot always agree on which day it is

**From source, and it is a genuine limitation rather than a missing call.** There is no
timezone function anywhere in the client: `grep -rn "TimeZone\|UtcOffset\|GetUTC"` over the
whole source returns nothing.

Given only a UTC timestamp and a local wall-clock reading, the local date is recoverable
because the implied timezone offset has to be one somebody lives in — but candidate offsets are
exactly 24 hours apart, so a reading is ambiguous between UTC-11 and UTC+13, and between
UTC-10 and UTC+14. Nothing in those two numbers separates them.

`Draw.lua` resolves the band to `(-11h, +13h]`, which is right for New Zealand and Tonga in
summer and wrong for American Samoa, Niue, the Chatham DST offset and the Line Islands. Those
zones are a whole day out, not an hour: the ambiguity is total. `test/run.lua` asserts both the
zones that work and the zones that do not, so the trade is visible to whoever moves the band.

The clock disagreement between the two calls is a separate and smaller problem, solved by
snapping the implied offset to the nearest quarter hour — every real zone offset is a whole
quarter hour, including the 45-minute ones (Nepal, Chatham).

## 3. `EVENT_PLAYER_ACTIVATED` is not a login event

**From source.** It fires on every loading screen. The client itself uses it for zone changes
(`esoui/ingame/scenes/ingamescenemanager.lua` calls it `OnLoadingScreenDropped`).

The event's second argument is widely documented by add-on authors as an "initial" flag, but
the client's own Lua never reads it — every handler in the source ignores it — so it is not
something this add-on relies on.

It does not need to. The Lua state is torn down and rebuilt on every login and every
`/reloadui`, so a file-local `firstActivationDone = false` is true-once-per-UI-session by
construction. That is exactly "the login", it needs no argument to be trusted, and it is what
`Main.lua` uses.

**To measure:** nothing here. The behaviour is asserted in `test/run.lua` §9 against the
harness's event dispatch, and the underlying claim — one Lua state per login — is how add-ons
are loaded at all.

## 4. Chat output

**From source.** `CHAT_ROUTER:AddSystemMessage(text)` is what the client itself uses
(`esoui/ingame/slashcommands/slashcommands_shared.lua`), and
`esoui/ingame/addoncompatibilityaliases/pc/addoncompatibilityaliases_pc.lua` shows the old
`CHAT_SYSTEM:AddMessage` aliased onto it. `Main.lua` tries the router first, the old call
second, and `d()` last.

## 5. Identity

**From source.** `ZO_SavedVars` itself is keyed on `GetDisplayName()`,
`GetUnitName("player")` and `GetCurrentCharacterId()`
(`esoui/libraries/utility/zo_savedvars.lua`), so all three exist and are available wherever
saved variables can be created.

The character **id** is what seeds the draw, not the name: a rename would otherwise hand
somebody a different fortune for a day they had already seen.

## 6. Lua 5.1, and what that costs the hash

**Known, but it decides the implementation.** The client is Lua 5.1: no integers, no bitwise
operators, and `unpack` is a global. A hash written the ordinary 32-bit way silently starts
rounding once a product passes 2^53 and stops being reproducible — which for this add-on means
the fortune changes when it must not.

`Draw.lua` therefore runs a 24-bit LCG with a sub-2^16 multiplier, so every product stays
exact, and reads the index off the *top* of the state rather than with `% 365`. In a
power-of-two LCG bit k repeats every 2^(k+1) steps, so the low bits are near-worthless and a
modulo reads exactly those — whatever the divisor factorises into. `test/run.lua` §8 asserts
that all 365 slips are reachable and that none is starved or hogging over 20,000 draws.

## 7. What is left to measure on a PS5

- That Japanese renders at all. The console client has no Japanese font of its own; this is
  the one thing on this list a laptop genuinely cannot answer, and it decides whether the
  add-on is usable as written.
- That `GetSecondsSinceMidnight()` on a console returns the console's clock and not the
  server's. If it returned server time the implied offset would come out as zero and the
  fortune would roll over at UTC midnight — the add-on would still work, it would just roll
  over at the wrong hour. `/omikuji` prints the date it computed, so one login at a known
  local time answers this.
