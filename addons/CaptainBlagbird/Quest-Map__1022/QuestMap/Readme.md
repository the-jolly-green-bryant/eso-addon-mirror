# Quest Map

An addon for The Elder Scrolls Online that displays locations of available, completed, and hidden quests on the map. Includes filters for daily, repeatable, prologue, Cadwell, skill point, and hidden quests. Supports both keyboard and gamepad UI modes.

---

## Repository

- Original Author: [CaptainBlagbird](https://github.com/CaptainBlagbird)
- Current Maintainer: [Sharlikran / ESOUIMods](https://github.com/ESOUIMods/ESO_QuestMap)

---

## License

Quest Map is distributed under the MIT License (see `LICENSE` file).  
All rights and original authorship remain with CaptainBlagbird unless otherwise noted.

Copyright (c) 2015–2020 CaptainBlagbird  
Copyright (c) 2020–Present Sharlikran

---

## Contributions and Credits

### Original Author
- CaptainBlagbird  
  Initial concept and core development (Started: 2015-04-06)  
  GitHub: [@CaptainBlagbird](https://github.com/CaptainBlagbird)

### Current Maintainer
- Sharlikran  
  Major overhaul, LibQuestData integration, and ongoing updates (Maintainer since: 2020-05-17)  
  GitHub: [@ESOUIMods](https://github.com/ESOUIMods/ESO_QuestMap)

### Library and Data Contributions
- LibQuestInfo / LibQuestData  
  Created by Sharlikran for improved quest tracking and map pin data  
  Integrated into Quest Map on 2020-05-17  
  Renamed to LibQuestData on 2020-06-13 to avoid conflicts with Ravalox' Quest Tracker, which included a file named LibQuestInfo.lua

- LibMapPins, LibMapData  
  Used for accurate pin rendering and map coordinate support

### Localization and Translation
- Xzcy – Chinese translation  
- Telmatoscopus – Portuguese translation  
- apalma200 (asp78) – Helped collect quest data for Wrothgar  
- Multiple community members – Provided translations for German, French, and Spanish

---

## Data Integrity and Attribution Notice

While individual quest data can be gathered using the ESO API, the full dataset provided by Quest Map reflects years of collective effort from multiple contributors. Recreating such a dataset independently would require substantial dedication and time.

Unauthorized use or redistribution of the dataset (in part or whole) without attribution or permission is discouraged. Claiming sole authorship over derivative works containing this data undermines the work of the original contributors.

Please contact the maintainer if you would like to reuse the data or contribute enhancements.

---

## Features

- Quest icons on the map with quest type indicators (daily, hidden, Cadwell, skill point, etc.)
- Customizable icon style, size, and tooltip visibility
- Gamepad and keyboard UI support
- Supports map filters for precise visibility control
- Automatically uses LibQuestData for dynamic and updated quest information

---

## Support and Feedback

- Submit issues or feature requests via GitHub:  
  https://github.com/ESOUIMods/ESO_QuestMap/issues

- Contributions via Pull Request are welcome.
