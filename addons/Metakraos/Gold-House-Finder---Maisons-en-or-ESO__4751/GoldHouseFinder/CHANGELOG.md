# Changelog

## 1.7.5

- Added localized search aliases for required achievements, including `Malabal Tor Adventurer` -> `Aventurier de Malabal Tor` / `Malabal Tor`.
- Improved achievement search scoring so zone searches prefer Adventurer/Aventurier achievements.
- Replaced remaining preview-verification wording with required-achievement wording.

## 1.7.4

- Replaced the two achievement buttons with one `Succes requis` action.
- Added achievement-name search for prerequisite text, including names extracted from native house-store errors.
- Retried native house-store reads shortly after preview opens so prerequisite text is captured reliably.
- Changed unresolved prerequisite wording from preview verification to required achievement resolution.

## 1.7.3

- Added linked achievement display in the house details.
- Added buttons to open the linked achievement or insert its chat link.

## 1.7.2

- Changed linked achievement checks to require completion by the current character.
- Stored native house-store prerequisite results per character instead of account-wide per house.

## 1.7.1

- Replaced the broad collectible validity check with ESO's native house-store requirement result.
- Added immediate checks through ESO's linked collectible achievement when available.
- Houses without a linked achievement now stay neutral until the gold purchase requirement has been verified in house preview.
- Red status is applied only when the native house store reports a missing requirement.

## 1.7.0

- Added red prerequisite status for houses blocked for the current character.
- Added prerequisite state to the settings preview details.
- Updated the visible LibAddonMenu author/version metadata.

## 1.6.0

- Added filters for environment, terrain size, and dwelling size.
- Added native ESO house preview images when available.
- Added ESO category and traditional furnishing limit display when available.
- Moved the main interface into Settings > Add-ons through LibAddonMenu-2.0.
- Fixed budget filters to use real ranges.

## 1.0.0 - 1.5.0

- Initial gold-house list.
- Search, budget filters, owned/unowned filter.
- Preview and teleport actions.
- EU-compatible install path support.
