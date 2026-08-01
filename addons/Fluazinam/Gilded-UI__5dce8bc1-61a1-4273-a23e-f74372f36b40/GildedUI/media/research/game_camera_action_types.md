# Game Camera Interact Action Types

Source: `esoui/lang/en_client.lua` (`SI_GAMECAMERAACTIONTYPE*`).

Used by Stay Mounted via `GetGameCameraInteractableActionInfo()` compared to `GetString(SI_…)`.

| ID | Label | Stay Mounted value |
|----|--------|--------------------|
| `SI_GAMECAMERAACTIONTYPE1` | Search | — |
| `SI_GAMECAMERAACTIONTYPE2` | Talk | `talk` |
| `SI_GAMECAMERAACTIONTYPE3` | Harvest | — |
| `SI_GAMECAMERAACTIONTYPE4` | Disarm | — |
| `SI_GAMECAMERAACTIONTYPE5` | Use | `use` |
| `SI_GAMECAMERAACTIONTYPE6` | Read | — |
| `SI_GAMECAMERAACTIONTYPE7` | Take | — |
| `SI_GAMECAMERAACTIONTYPE8` | Destroy | — |
| `SI_GAMECAMERAACTIONTYPE9` | Repair | — |
| `SI_GAMECAMERAACTIONTYPE10` | Inspect | — |
| `SI_GAMECAMERAACTIONTYPE11` | Repair | — |
| `SI_GAMECAMERAACTIONTYPE12` | Unlock | — |
| `SI_GAMECAMERAACTIONTYPE13` | Open | `open` |
| `SI_GAMECAMERAACTIONTYPE15` | Examine | — |
| `SI_GAMECAMERAACTIONTYPE16` | Fish | `fish` |
| `SI_GAMECAMERAACTIONTYPE17` | Reel In | — |
| `SI_GAMECAMERAACTIONTYPE18` | Pack Up | — |
| `SI_GAMECAMERAACTIONTYPE19` | Steal | — |
| `SI_GAMECAMERAACTIONTYPE20` | Steal From | — |
| `SI_GAMECAMERAACTIONTYPE21` | Pickpocket | — |
| `SI_GAMECAMERAACTIONTYPE23` | Trespass | — |
| `SI_GAMECAMERAACTIONTYPE24` | Hide | — |
| `SI_GAMECAMERAACTIONTYPE25` | Preview | — |
| `SI_GAMECAMERAACTIONTYPE26` | Exit | — |
| `SI_GAMECAMERAACTIONTYPE27` | Excavate | — |

Notes:

- No string entries for types `14` or `22` in the English client table.
- Types `9` and `11` both localize to “Repair”.
- Stay Mounted checklist currently exposes: Use, Open, Talk, Fish.
