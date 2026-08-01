# SiegeReminder v1.1.0
**Author:** SugaComa (Rik Sprint) + Grok Fixes  
**Game:** Elder Scrolls Online  
**Type:** Stand-alone Addon (no dependencies)

---

## 🎯 What It Does
SiegeReminder helps you keep your siege stock healthy without chat spam or unnecessary reminders.

### Key Features
- **Tracks siege usage:** Every time you deploy a siege engine, it logs your pre-deploy stock.
- **Detects losses:** When a siege is destroyed and not recovered, it's marked as “lost.”
- **Merchant-only alerts:** You’ll only be reminded to restock when you’re near a siege merchant (e.g., at a keep or outpost).
- **Quiet during combat:** No alerts or chat spam mid-battle.
- **Automatic restock detection:** Buys or bag updates clear pending low-siege warnings.
- **Configurable reminder style:** Choose between Chat, Alert, or Full Screen notifications.

---

## ⚙️ Installation
1. Download or copy the folder **SiegeReminder** into:


Documents\Elder Scrolls Online\live\AddOns\

2. Inside that folder, you should have:


SiegeReminder.lua
SiegeReminder.txt
README.md

3. Restart ESO or reload your UI (`/reloadui`).

---

## 🧭 How It Works
1. When you deploy a siege (Ballista, Catapult, Trebuchet, etc.), the addon saves your current stock.
2. When the siege ends (packed up, destroyed, or control lost), it checks whether that item type decreased.
3. If stock is lower, it flags it as “lost.”
4. When you next approach a merchant (keep, resource, or outpost), it reminds you:


Low on Ballista (1/3) – Restock here!

5. When you buy new siege, the reminder clears automatically.

---

## 🧰 Saved Variables
Saved in `SavedVariables/SiegeReminder_SV.lua` (account-wide):
```lua
{
 ["siege"] = {
     ["Ballista"] = { min = 3, remind = true },
     ["Catapult"] = { min = 3, remind = true },
     ["Trebuchet"] = { min = 3, remind = true },
     ["Forward Camp"] = { min = 1, remind = true },
     ["Repair Kit"] = { min = 50, remind = true },
 },
 ["reminderType"] = "Chat", -- "Chat", "Alert", or "Full Screen"
}

🧩 Optional Ideas (Future Updates)

Add sound cue when merchant alert fires.

/siegedebug command to print tracked siege info.

Expand merchant detection to include vendors in towns and IC bases.

💬 Credits

Written by Rik Sprint (SugaComa)
Additional logic & bug fixes by Grok

Built on tea, toast, and ADHD — tested live on PS5. Why wouldn’t you?


---

Would you like me to bump the manifest’s `APIVersion` to match **ESO: Gold Road / Update 44 (March 2025)** (currently `101045`) so it won’t show as “outdated” in your AddOns list?