# Gold House Finder

Gold House Finder helps players browse ESO houses known to be purchasable with in-game gold.

Supported client languages: English and French. House display names are read from the ESO API in the current client language when available; internal data is used for gold prices, prerequisite names, and search aliases.

## Features

- Browse gold-purchasable homes from `Settings > Add-ons > Gold House Finder`.
- Filter by budget range.
- Filter by native ESO house zone.
- Filter by environment: city, seaside, river/lake, countryside/isolated.
- Filter by terrain size and dwelling size.
- Show native ESO house preview images when available.
- Show official ESO house category and traditional furnishing limit when available.
- Mark homes in red when ESO exposes a linked achievement that is not completed by the current character, or after the native house store reports a missing gold-purchase prerequisite for that character.
- Search and open the required achievement from prerequisite text when available.
- Uses localized search aliases for known required achievements, such as Malabal Tor Adventurer on French clients.
- Preview unowned homes.
- Teleport inside or outside owned homes.

## Commands

- `/ghf` opens the Gold House Finder settings panel.
- `/goldhouses` and `/maisonsor` are aliases.
- `/ghfdump` scans house data visible to the current client and saves it to SavedVariables.

## Dependencies

- Optional but recommended: LibAddonMenu-2.0

Without LibAddonMenu-2.0, the add-on still loads and the fallback window can be opened with `/ghf`.

## Notes

House zones are read dynamically from the ESO client. Environment, terrain size, and dwelling size are qualitative classifications maintained in the add-on data table. ESO exposes official house category and furnishing limits, but not exact plot or building surface measurements. Some exact gold-purchase prerequisite results are only available after the native house purchase data has been opened in preview.

SavedVariables are stored under a server-specific profile to avoid mixing NA/EU data.

AI disclosure: this add-on was developed with AI coding assistance, then reviewed and maintained by Metakraos.
