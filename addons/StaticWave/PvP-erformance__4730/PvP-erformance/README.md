# PvP-erformance

> AI disclosure: this addon was built with AI assistance and is actively reviewed, tested, and maintained by its author.

An ESO addon that records finished duels in account-wide, server-scoped saved variables. It is fully standalone: **no required or optional library dependencies**.

The journal includes a separate **Analytics** module for newly recorded duels. Its Dueling scope provides Damage Done, Damage Taken, Healing Done, Healing Received, a multi-filter timestamped Combat Log, consolidated Buff/Debuff Uptime, and sampled Fight Stats. Combat sources and effects use stable ability IDs where ESO supplies them and display their skill icons.

Analytics reports are session-only by default, so they disappear after logout or `/reloadui`. Use **SAVE DUEL** to permanently retain the selected report with its timestamps, uptime, effects, source summaries, and Fight Stats. **DELETE DUEL** removes only that Analytics report; the Dueling result and rating remain in the permanent journal. Chat confirms either action. Each report is bounded to 6,000 combat events, 3,000 effect applications, and 3,000 narrative system events.

Each record includes the result, real-world time, duration, both players' character and display names, class, race, and any confirmed Werewolf form. The latest 1,000 duels are retained in `PvPerformanceSavedVars`.

Records are kept separately for NA, EU, and PTS, preventing one megaserver's history from overwriting another's.


## Upgrade from DuelLedger

PvP-erformance uses the new `PvPerformanceSavedVars` namespace. Existing `DuelLedgerSavedVars` history, ratings, settings, notes, combat summaries, and window position do **not** transfer. You may remove the old DuelLedger addon folder after installing PvP-erformance. Your old SavedVariables data may remain on disk safely, but PvP-erformance does not read or modify it.
## Install

Copy the `PvP-erformance` folder to:

```
Documents/Elder Scrolls Online/live/AddOns/PvP-erformance
```

Use `liveeu` for the European megaserver or `pts` for the Public Test Server. Enable **PvP-erformance** in the in-game Add-Ons menu, then use `/reloadui`.

## Journal

Open the movable, resizable journal with `/metrics ui` (or `/dl ui`), or assign **Toggle PvP-erformance** under Controls â†’ Keybindings â†’ Addons. Drag its bottom-right edge to resize it; the position and size are remembered. It enforces a 1120-pixel minimum width so its tabs, search field, and Statistics cards cannot overlap. Its fixed left summary rail places Overall Tier, Class Tier, Win Rate, then total duels and unique opponents in a vertical column. A divider separates this rail from the content area. The larger cards are centered in the rail and the Overall Tier aligns with the top of the Statistics cards. Their 51-pixel gap preserves the same compact card-to-gap ratio as the preceding layout, while their captions retain enough width to avoid truncation. Resizing only adds space beneath the final card. The pager follows the last visible duel record. The header identifies the account as `Player: @name`. The journal provides Recent Duels, Opponents, Classes, Statistics, Settings, and Commands tabs, opponent search, W-L-D summaries, win rate, Overall Tier, and Class Tier. The Commands tab is an in-game reference for every public, non-test command. Click the compact selector below the Class Tier card to view its independent placement, rating, rank, and effects for any class or Werewolf. Recent Duel rows use separate **Date**, **Duration**, **Damage Done**, and **Damage Taken** columns. Opponent and Class aggregate rows sort by most wins, then losses, then total duels, with separate **Record** and **WR** columns. The Statistics tab shows long/current streaks, average and longest duel time, top-five hardest/easiest opponents, most-played opponent, best/worst class matchup, and last-ten-duel win rate. Hardest opponents require at least one loss; best/worst class matchups require at least one win/loss respectively, otherwise they show `N/A`. Its leaderboards use the same separate Record/WR columns; statistic cards use larger, more widely spaced supporting text. C-, C, and C+ use increasingly intense expanding pulse rings; B-, B, and B+ use purple sparkles; A-, A, and A+ use comet trails; and S-, S, and S+ use outward-radiating ember glows with a ray burst. Overall, Class, and Win Rate cards use the same tier-coloured visual system. Right-click the Win Rate box to prefill the standard chat input as `Player: @name, Win Rate: 31.8%, Stats: 7W-11L-4D`. Right-click either Tier box to prefill it with your current tier and points to the next tier. `/metrics share` pre-fills a social-chat-ready player card containing player name, Overall Tier, the selected Class Tier, and win rate. Choose a social channel if needed, then press Enter to send. In the Opponents or Classes tab, click an aggregate row to open that opponent's or class's newest-first duel history; use the visible **All Opponents** or **All Classes** control to return.

S-, S, and S+ now also layer a softly rotating, rank-coloured ray burst and a restrained tier-letter shimmer over their existing ember effects. The effect remains confined to each card so it does not interfere with the Class Tier selector or adjacent controls.

The current lower-tier mapping is C-, C, and C+ expanding pulse rings; B-, B, and B+ sparkles; and A-, A, and A+ comet trails. Each effect grows in intensity from minus through plus, and uses the card's rank colour.

## V1 polish controls

Each new Recent Duel row includes its replayed **Overall** and **Class** rating change (including placement status) below the matchup. The matchup line sits above the enlarged, divider-separated rating footer so both remain readable. The Recent Duels tab also reserves enough width for its full title. `/metrics debug [count]` prints the stored modifier audit for up to five recent duels: base result, repeat-opponent, win-streak, damage, CC, S-tier, Class expected-matchup, and final change. After a live duel, chat also gives a compact explanation for any modifier that changed the result. This makes the rating system auditable without saving a combat log.

The **Settings** tab provides low/normal/high tier-effect intensity and an optional upset-victory adjustment. An eligible post-placement win earns one flat 15% bonus when its damage-taken gap reaches the time-scaled equivalent of 150,000 damage per 20 seconds, or when at least five prior decisive duels establish a personal win rate of 33% or lower against that opponent. The conditions do not stack, and a three-second burst representing more than 60% of outgoing damage prevents the bonus. Changing the adjustment safely rebuilds Overall and Class ratings from the saved journal so the displayed results remain consistent. **Build Testing** can pause duel tracking: it immediately discards temporary tracking for an in-progress duel and ignores all new duel records, Overall/Class rating changes, and win-rate changes until re-enabled. Existing journal data remains visible and unchanged.

Settings also includes **Copy Summary**, which pre-fills chat with a concise recent-duel summary for copying or social sharing. ESO addons cannot write arbitrary files or submit data online, so this is intentionally a compact share summary rather than a claim of a full backup/import system.

Use `/metrics note @name <note>` to attach a short note to an opponent; it appears on that opponent's aggregate row. Remove it with `/metrics note clear @name`. Public builds do not expose a record-reset control or slash command.

## Tier-card interactions

Click the small `i` in either Tier card for a coloured tier-progression guide with every rating range and a highlight on the active Overall or selected Class Tier. The Class guide also explains its independent placement, the shared diminishing and streak rules, and expected-matchup scoring. Overall Tier hover messages now appear only at **S** and **S+**. Class Tier hover messages also appear only at **S** and **S+**; S+ names the currently selected class. Right-click either Tier card or the Win Rate card to choose whether to prefill chat with that tier, the W-L-D/win-rate record, or the full player profile. The Class Tier selector below the Class Tier card uses enlarged, centred text and opens the independent ratings for every class and Werewolf.

Opponents and Classes have a `Sort` control beside the search area. Numeric choices (Duels, Win Rate, Wins, and Losses) always sort high to low; Name sorts A-Z. Recent Duels and the history opened from an aggregate row remain newest-first. Opening an opponent adds a saved-history performance card with record, win rate, colour-coded Overall/Class rating changes, last-five form, current repeat value, and a cumulative Overall-rating-change line graph. Click any individual duel from Recent Duels, an opponent history, or a class history to open the shared **Duel Summary**. It presents four equal cards for Damage Done, Damage Taken, Healing, and Shield Absorption, followed by compact Top-15 outgoing and incoming source tables. Use the contextual Back control to return to the same Recent, Opponent, or Class history and page. New duels store only final source totals (up to 15 per direction), never raw combat events; older records remain viewable but display an unavailable-summary message. The Statistics tab includes an on-demand trend graph with **Rating** and **Win Rate** (last ten decisive duels) options.

## Rating and placement

Rating starts hidden at **50**. The two-stage **Provisional Phase** first needs **20 decisive results against at least 15 different opponents**, with no more than two counted results against one opponent. Those results seed a bounded rating: `50 + 2 Ã— (wins - losses)`, clamped to **40â€“84** (D through A-). Draws and forfeits remain neutral and do not advance either phase. This prevents a short run of friendly results from placing a player directly into an elite tier.

The seed is followed by **20 normal-rated calibration results**. The card shows the resulting tier but labels the progress bar `PROV x/20` until calibration ends. During calibration, normal repeat-match, class-matchup, pressure/burst, suspected-CC, global-streak, and S-tier rules all apply. A standard Overall Tier win gains **0.5** points and a standard loss removes **0.5** points. W-L-D and total-duel displays retain draws, but win rate uses decisive duels only (`wins / (wins + losses)`), so a forfeit cannot lower it.

Wins against the same opponent award 100%, 75%, 50%, 25%, then 2% of the normal win value. At the standard half-point win value, an exhausted win is worth 0.01 rating before other modifiers. A loss lowers fatigue by one step before exhaustion; draws do not restore value. An exhausted matchup resets after **48 real-world hours**, or after **10 decisive duels against other opponents that include at least 5 different players**. Draws, forfeits, and duels against the exhausted opponent do not advance activity-based recovery. If five matchups are exhausted together, a sixth different opponent is required because each lock can see only four of the other exhausted players. A loss after one prior win costs 5% more, and a loss after two or more prior wins costs 10% more. S- uses 65% win gains and 95% losses; S uses 50% gains and 90% losses; S+ uses 35% gains and 85% losses.

## Suspected CC-lock protection

While a duel is active, the addon watches the player stun-state event. The API does not prove a failed Break Free, so a qualifying loss receives one of three explicit confidence levels rather than being treated as certain. The player must begin the stun with at least 5,000 stamina, the stun must last at least one second, and the loss must occur in or shortly after that lock. **Strong CC lock** reduces a loss by 25% when the stun began at 70%+ health and the death was during the lock or within 0.5 seconds. **Likely CC lock** reduces it by 20% when it began at 35â€“69% health and the death was during the lock or within two seconds. **Possible CC lock** reduces it by 10% for a 15â€“34% in-lock death, or a viable-health recovery followed by death within five seconds. A stun beginning below 15% health is never protected. The entry remains a normal loss in W-L-D, placement, and statistics. This protection never adjusts a Provisional-Phase result.

This is intentionally a conservative indicator rather than proof that Break Free failed: ESO does not expose a verified successful/failed Break Free result for the addon to inspect. Only the final flag is stored in the duel journal; no continuous stamina or combat-event history is saved.

## Suspected latency-spike flag

During a duel, the addon samples ESO's current latency reading every 250 ms and keeps only temporary rolling values. A loss is flagged **MODERATE LAG** after a sustained one-second spike that is at least **150 ms above baseline and 1.5Ã— baseline**. It is flagged **SEVERE LAG** after a sustained one-second spike that is at least **300 ms above baseline or 2Ã— baseline**. The loss must occur within two seconds of the sustained spike. The final journal entry stores only the rounded baseline, peak milliseconds, and confidence labelâ€”never the individual latency samples.

This is diagnostic-only. It does not change W-L-D, placement, Overall Tier, or Class Tier because the API cannot prove packet loss, a server desync, or causation. The flag gives you evidence to review before any future tuning decision.

Ranks use a 0-100 scale: D 0-50, C- 51-55, C 56-60, C+ 61-65, B- 66-70, B 71-75, B+ 76-80, A- 81-84, A 85-88, A+ 89-92, S- 93-95, S 96-98, and S+ 99-100. Rating cannot exceed 100. B-, B, and B+ use increasingly bright purple card and sparkle effects.

## Class Tier expected-matchup rating

Every class has an independent Class Tier rating and placement record. It uses the same placement, diminishing-return recovery, and win-streak loss rules, but only considers duels played on that class. **Overall Tier measures raw duel results; Class Tier adjusts those results for the current expected class matchup.**

Class Tier uses `1 x (result - expected win chance)`. The current ladder is **Werewolf > Dragonknight > Sorcerer > Warden > Necromancer = Templar > Nightblade > Arcanist**. Werewolf is a form rather than a base class, so confirmed Werewolf matches receive their own Class Tier rating.

Equal-strength and mirror matches are 50% expected and award `+0.5 / -0.5`. The reworked curve remains symmetric:

- DK vs Sorcerer: 72.5% expected.
- Werewolf vs DK: 65% expected.
- Werewolf vs Sorcerer: 80% expected.
- DK and Werewolf gain further expected advantage against every lower ladder position.
- Every reverse matchup is exactly `100% - expected win chance`.

This keeps each matchup zero-sum in expectation and prevents gradual rating inflation.

## Damage tracking, combat summaries, and pressure adjustment

During an active duel, the addon registers filtered combat listeners only while the duel is being tracked. It keeps temporary in-memory totals grouped by combat actor and stable ability ID. At the finish, it matches those groups to the opponent reported by the duel event, saves one compact final record, and clears all temporary combat tables. The saved record contains final damage totals, API-reported self healing, and at most 15 aggregated sources for damage done and 15 for damage taken. It never saves the raw sequence of combat events.

The Recent Duels row presents **Date**, **Duration**, **Damage Done**, and **Damage Taken** as a separate right-side statistics grid. In an opponent history, click an individual duel to review its total damage and rates plus Top 15 damage-done/taken sources. Percentages and DPS are calculated only when the detail view is opened, keeping SavedVariables compact. Older records remain visible and display `N/A` for combat detail that did not exist when they were recorded.

ESO's public combat events do not provide a dependable, separate shield-absorption amount or a universal effective-healing/overheal split. The detail panel therefore labels healing as **API reported**, treats incoming damage as combat-event damage, and shows shield absorption as `N/A` instead of inventing or double-counting a value.

An eligible post-placement victory must last at least 20 seconds, include at least 150,000 combined damage, and pass the burst safeguard. It earns one flat 15% upset bonus when `damage taken - damage done` reaches the time-scaled equivalent of 150,000 damage per 20 seconds. A victory can also qualify after at least five previous decisive duels establish a personal win rate of 33% or lower against that opponent. The two conditions do not stack, higher damage gaps do not increase the bonus, and losses and draws receive no damage adjustment. The same adjustment applies to both Overall and Class Tier gains after their normal repeat-opponent and tier modifiers.

To reduce deliberate stalemate-then-one-shot farming, the upset bonus is denied when more than 60% of the winner's total outgoing damage occurs within any three-second burst window. Only the final eligibility reason and multiplier are saved; the temporary burst samples are cleared with the rest of the live duel state.

## Werewolf detection

The addon directly records your own form using `IsPlayerInWerewolfForm()`. An opponent is marked **Werewolf** only after confirmation from either a visible Werewolf-form buff on the reticle target during the duel countdown, or a known Werewolf-only combat ability that hits you during the duel. If neither is seen, the opponent remains their normal base class; the addon never guesses that they were not Werewolf.

The built-in list covers transformation/form effects, Pounce, Hircine skill variants, Werewolf Berserker Bleed (`89147`), Bloodclaws (`58880`), Feral Carnage (`137164`), and Brutal Carnage (`137184`). Use the local diagnostic when a patch changes an ability or you find an unlisted signature.

## Commands

| Command | Result |
| --- | --- |
| `/metrics` or `/dl` | Overall W-L-D, win rate, and tier progress |
| `/metrics ui` or `/dl ui` | Open or close the journal |
| `/metrics share` | Prefill chat with player name, Overall Tier, selected Class Tier, and win rate |
| `/metrics history [count]` | Latest duel records (default: 10) |
| `/metrics debug [count]` | Print the stored rating-modifier audit for up to five latest duels |
| `/metrics export [1-5]` | Prefill a copyable compact history summary in chat |
| `/metrics note @name <note>` | Add or update an opponent note |
| `/metrics note clear @name` | Remove an opponent note |
| `/metrics help` | List commands |
| `/metrics ww scan` | Scan the reticle target for a visible Werewolf form effect during a duel countdown |
| `/metrics ww debug on` | Print incoming opponent ability IDs during the current duel |
| `/metrics ww debug off` | Disable the local Werewolf diagnostic |
| `/metrics ww add <abilityId>` | Persist a confirmed Werewolf-only ability ID for future detection |

## Creator preview commands

These commands are session-only previews and simulations; they never change saved duels or rating. Repeating a test `@name` lets you inspect diminishing returns.

| Command | Result |
| --- | --- |
| `/metrics test placement [0-19]` | Preview Overall provisional-result progress, default 0/20 |
| `/metrics test rating [points]` | Preview Overall Tier, default 50 (D) |
| `/metrics test classplacement [0-19]` | Preview Class Tier provisional-result progress, default 0/20 |
| `/metrics test class [points]` | Preview Class Tier, default 50 (D) |
| `/metrics test simulate <win|loss|draw> <class> [@name]` | Simulate exact Overall/Class changes; class may be `ww`, `dk`, `sorc`, `nb`, `warden`, `necro`, `templar`, or `arc` |
| `/metrics test off` | Return to live data |
