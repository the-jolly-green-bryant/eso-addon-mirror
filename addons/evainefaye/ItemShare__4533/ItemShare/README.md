ItemShare full solution package

Included files
- ItemShare_solution.lua: ESO addon logic
- ItemShare_solution.txt: ESO addon manifest

Current behavior
- ESO addon is named ItemShare
- Right-click menu shows:
  - Add to Share when item is not already saved
  - Remove from Shared List when item is already saved
- Add and Remove actions both print debug lines with the item name
- Saved vars use ItemShareSavedVars
- Google Sheets importer supports:
  - per-account worksheets
  - Master sheet first and selected
  - item type column
  - RequestedBy sync between source sheets and Master
  - multi-account import from one saved variables file

Recommended Google Sheets triggers
- lockRequestedByOnEdit  (From spreadsheet / On edit)
- rebuildMasterOnChange  (From spreadsheet / On change)

Google Sheets Template File:  https://docs.google.com/spreadsheets/d/1nznYCXFJHmlCn2XqmMlFy1p4UYlOdKCEIdbaCKSYFu4/template/preview