# Conductor v4.4.0-dev1

## Raid Setup simplification

Raid Setup is now a review-and-share workflow rather than a manual configuration sequence.

### New primary flow

1. Select the encounter, difficulty, and objective.
2. Select **Prepare Current Raid**.
3. Review the automatically populated team.
4. Optionally save the team settings.
5. Select **Share Raid Session**.

**Prepare Current Raid** now performs the previous group import, roster analysis, role inference, capability collection, and Raid Session creation steps together.

## Team Review

- Replaced the large manual Player Setup form with a compact Team Review.
- Automatically populates the current 2 Tank, 2 Healer, and 8 Damage Dealer layout.
- Player corrections use a dropdown containing current group members only.
- Class corrections use the existing class dropdown.
- Removed typed player names, typed gear names, custom loadout fields, and manual loadout notes from the normal Raid Setup workflow.
- Current-group dropdowns identify players with verified Conductor data and players whose loadouts are unknown.
- Added direct access to verified Team Coverage from Team Review.

## Verified and unknown capability

- Local and networked Conductor users are treated as verified capability sources.
- Group members without Conductor remain visible in the roster.
- Unknown gear, skills, ultimates, and responsibilities are not guessed.
- Saved-team loadouts are preserved when a returning player is not currently sharing Conductor data, but are explicitly marked as saved and not currently verified.

## Saved teams

- Preserved the ability to save, load, update, compare, and delete team settings.
- Saving a team is optional and is not required before preparing or sharing a raid.
- Team names are optional. Conductor generates a trial-based name or **Saved Raid Team** when no name is entered.
- Saved teams retain roster placement, encounter context, and available verified loadout data.

## Sharing

- Removed the separate **Enable Sharing** step.
- **Share Raid Session** now refreshes and prepares the current group automatically before sending.
- This prevents an older active Raid Session from being shared accidentally.
- Existing accept, decline, cancellation, and synchronization status controls remain available.

## Advanced rotations

- Existing encounter-specific and trash-rotation overrides remain available under **Advanced Rotation Setup**.
- Player assignment fields now use current-group dropdowns instead of typed PlayStation account names.
- Automatically detected gear, skill, ultimate, and support responsibilities remain outside manual assignment controls.

## How to Use Conductor

Updated the in-addon guide to explain the new four-step Raid Setup flow, optional saved teams, verified versus unknown capability, and the value gained as more group members install Conductor.
