# Cogs Assistants

ESO PC addon for binding assistants and companions without relying on another addon's update-prone saved associations.

## Settings UI

The in-game **Settings > Addons > Cogs Assistants** panel appears when `LibAddonMenu-2.0` is installed and enabled. Without LibAddonMenu, the addon still works through slash commands and keybinds.

Settings are account-wide by default. In the settings panel, enable **Use character-specific settings** on any character that should keep its own assistant and companion assignments. The first time character-specific settings are enabled for that character, the current account-wide settings are copied over.

## Packaging

The source directory is `cogs-assistants`, but the addon identity and release package are `CogsAssistants`. The lowercase `cogs-assistants.txt` manifest is only for running directly from this source folder; the GitHub Actions workflow stages only `CogsAssistants.txt` into `dist/CogsAssistants/` and creates `CogsAssistants.zip` for ESOUI upload.

For a manual install, download the attached `CogsAssistants.zip` release asset. Do not use GitHub's automatically generated **Source code (zip)** archive: GitHub names its root directory after the repository and tag (for example, `cogs-assistants-0.1.5`), which is not the addon's ESO directory name.

## Keybinds

Open **Controls > Keybindings > Cogs Assistants**.

- Summon Random/Static Merchant
- Summon Random/Static Banker
- Summon Random/Static Deconstructor
- Summon Random/Static Fence
- Summon Random/Static Armorer
- Summon Random/Static Companion
- Companion Slot 1 through Companion Slot 12
- Named companion binds for the current companion roster: Bastian, Mirri, Ember, Isobel, Azandar, Sharp-as-Night, Tanlorin, and Zerith-var.

Type binds default to random unlocked collectibles. Companion slots default to the sorted unlocked companion at that slot number, but can be pinned.

By default, repeatedly using a random type binding dismisses an active assistant of that same type. Disable **Dismiss active random assistant on reuse** to select another unlocked assistant when possible. If only one assistant of a type is unlocked, ESO may dismiss it on reuse because there is no alternative collectible to select.

## Slash Commands

`/cogsassistants` or `/ca`

- `/ca list` shows counts by type.
- `/ca list merchant` shows unlocked merchants that the addon detected.
- `/ca set merchant Fezez` pins merchant to a static assistant.
- `/ca set merchant random` returns merchant to random mode.
- `/ca mode banker random` or `/ca mode banker static` changes mode without changing the saved static choice.
- `/ca slot 1 Isobel` pins Companion Slot 1.
- `/ca slot 1 clear` returns Companion Slot 1 to sorted-list behavior.
- `/ca classify merchant Baron` manually classifies an unlocked assistant if ESO adds one the name detector does not recognize.
- `/ca unclassify Baron` removes that manual assistant classification.
- `/ca scope account` uses account-wide settings.
- `/ca scope character` uses character-specific settings for the current character only.
- `/ca dismiss on` dismisses an active assistant when its random type binding is reused.
- `/ca dismiss off` restores random rotation when another assistant of that type is available.
- `/ca dismiss` reports the current dismiss setting.
- `/ca summon banker` summons without pressing the keybind.
- `/ca status` shows current selections.
- `/ca debug` prints unclassified assistants during collectible refresh.

## Notes

ESO exposes assistants as one collectible category, not as public banker/merchant/fence subtypes. This addon classifies assistant types from collectible names and keeps your pinned selections as collectible IDs in `CogsAssistantsSavedVariables`.

## Changelog

### 0.1.5

- Corrected the release archive name and top-level addon directory to `CogsAssistants` so ESO can load the addon.

### 0.1.4

- Prevented random assistant bindings from selecting crow assistants while the player is in werewolf form.

### 0.1.3

- Added classifications for additional merchants, bankers, deconstructors, fences, and armorers contributed by an ESOUI community member.
- Corrected Jangleplume's classification from merchant to banker.
- Added an optional setting and slash command to dismiss an active random assistant when its type binding is reused.
