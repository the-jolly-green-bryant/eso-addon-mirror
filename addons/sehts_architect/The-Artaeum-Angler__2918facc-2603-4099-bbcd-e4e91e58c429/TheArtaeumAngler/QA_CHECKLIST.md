# The Artaeum Angler In-Game Validation Checklist

Use this checklist before publishing a release or claiming a feature is complete.

## Smoke Checks

- Install [TheArtaeumAngler](/home/seana/eso-console-add-ons/dist/TheArtaeumAngler) in the ESO AddOns directory
- Launch the game in console-style UI mode if desktop validation is being used
- Confirm the add-on loads without immediate Lua/UI errors
- Confirm logging in, zoning, and reloading the UI do not immediately break the add-on
- If behavior is unclear, confirm the debug telemetry overlay is enabled and reporting reticle, fishing logic, and UI state

## Reticle and Prompt Behavior

- Look at a non-fishing target and confirm no bait prompt appears
- Sweep the reticle rapidly across fishing and non-fishing targets for at least 5 seconds
- Confirm the prompt settles only on the final fishing hole target after debounce
- Confirm the prompt hides cleanly when the reticle leaves the fishing hole

## Interaction Safety

- While targeting a fishing hole, confirm `A/Cross` still performs the native fishing interaction
- Confirm the add-on does not trap the player in a prompt-open loop
- Confirm the secondary bait action only appears while a fishing hole is targeted
- Confirm opening and closing the selector does not block normal interaction after closing

## Reel-Ready Feedback

- Cast into a fishing hole and wait for the reel-in state
- Confirm the prompt visibly changes when the action becomes `Reel In`
- Confirm the prompt hint changes to the reel-in instruction instead of bait selection
- Confirm the reel-ready cue sound plays once when the reel-in state begins
- Confirm the bait selector closes or stays inaccessible while the reel-in state is active

## Bait Selector

- Confirm the secondary bait action opens the native fishing bait wheel while targeting a fishing hole
- Confirm the wheel shows the currently available bait counts
- Confirm selecting the currently equipped bait performs no unnecessary bait change
- Confirm selecting a different available bait updates the equipped lure and prompt state
- Confirm closing the wheel returns cleanly to normal fishing interaction

## Water Type and Recommendation Logic

- River water recommends Insect Parts first, then Shad
- Lake water recommends Guts first, then Minnows
- Ocean water recommends Worms first, then Chub
- Foul water recommends Crawlers first, then Fish Roe
- Unknown water recommends Simple Bait first
- If preferred bait is unavailable, confirm the next fallback is recommended
- If all relevant bait is unavailable, confirm the prompt enters the empty state

## Unknown-State Recovery

- Target a fresh fishing hole that initially reports unknown water type
- Confirm the prompt starts in the unknown state with Simple Bait guidance
- Confirm the recommendation refreshes after the fishing lure state resolves
- Confirm the prompt does not remain permanently stuck in the unknown state when the game resolves water type

## Regression and Stability

- Reload the UI while near a fishing hole and confirm the add-on recovers cleanly
- Zone or wayshrine travel and confirm the prompt does not get stuck visible
- Confirm no obvious frame hitching or repeated UI churn occurs while moving the reticle repeatedly
- Confirm no repeated bait-change requests occur from a single manual selection

## Release Gate

- Re-run `npm run lint`
- Re-run `npm test`
- Re-run `npm run upload:addon -- TheArtaeumAngler --dry-run`
- Confirm [TheArtaeumAngler.addon](/home/seana/eso-console-add-ons/dist/TheArtaeumAngler/TheArtaeumAngler.addon) matches the intended release contents
- Disable or remove dev-only debug telemetry before public release
- Update this checklist whenever feature scope or expected runtime behavior changes
- Do not treat a release as fully validated unless the relevant items above were executed or explicitly deferred
