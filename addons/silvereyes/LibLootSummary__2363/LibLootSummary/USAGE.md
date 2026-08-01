# LibLootSummary Usage Guide

## Usage Example

```lua
local lls = LibLootSummary()

-- combineDuplicates
-- If set to false, then successive calls to the Add*() methods for the same item id will
-- be listed separately in the summary.  The default (true) causes the quantities to be
-- summed and listed once in the summary.
lls:SetCombineDuplicates(false)

-- Accepts a singular noun describing the increment displayed when lls:SetShowCounter() 
-- is set to true.
lls:SetCounterText("message")

-- delimiter
-- Use comma delimiters between items in the summary, instead of the default single space
lls:SetDelimiter(", ")

-- endText
-- Text that gets appended once at the end of the entire summary if the summary is not empty.

-- hideSingularQuantities
-- Only print quantity multiplier text (e.g. x20) greater than one to chat
lls:SetHideSingularQuantities(true)

-- icons
-- Display icons next to items in the summary (not recommended without LibChatMessage)
lls:SetShowIcon(true)

-- minQuality
-- Only include items of the specified quality and above in the summary
lls:SetMinQuality(ITEM_QUALITY_MAGIC_ITEMS_MAGIC)

-- prefex
-- Prefix to prepend to every line of the summary
lls:SetPrefix("|cFFFFFF") -- white text

-- showCounter
-- Display the counter value in the summary when it is > 0
lls:SetShowCounter(true)

-- showTrait
-- Display item traits in the summary
lls:SetShowTrait(true)

-- linkStyle
-- Controls the chat link style for all items in the summary
lls:SetLinkStyle(LINK_STYLE_BRACKETS)

-- sorted
-- Sort the loot summary alphabetically
lls:SetSorted(true)

-- sortedByQuality
-- Sort by quality first (the higher quality items are listed first)
-- then by name. This disables the sorted setting described above.
lls:SetSortedByQuality(true) -- This overrides lls:SetSorted()

-- suffix
-- Suffix to get appended to the end of every line of the summary
lls:SetSuffix("|r") -- reset color to default

-- Remove all items from the pending summary.
-- LibLootSummary:Print() calls this by default.
lls:Reset()

-- Add item from bag
-- If quantity is nil, then the max stack size possible will be used
lls:AddItem(bagId, slotIndex, quantity)

-- Add 200x Ancestor Silk
lls:AddItemLink("|H1:item:64504:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 200)

-- Mark that both of the above items were added during a single loot event.
lls:IncrementCounter()

-- Add 1x Aetherial Dust
lls:AddItemId(115026, 1)

-- Mark that the Aetherial Dust was looted in a separate loot event
lls:IncrementCounter()

-- Output the entire summary to chat
lls:Print()
```

## LibChatMessage Integration

I recommend that you use [LibChatMessage](https://www.esoui.com/downloads/info2382-LibChatMessage.html) if you plan to enable icons in your summaries.  It doesn't have the 350 character limit that normal chat messages have and which icon code can eat up quickly.

```lua
local chatProxy = LibChatMessage("MyAddon", "MA")
local colorHex = "FF6666"
chatProxy:SetTagColor(colorHex)

local lls = LibLootSummary( {
    chat = chatProxy,
    prefix = "|c" .. colorHex,
    suffix = "|r"
} )

-- OR --
lls = LibLootSummary()
lls:UseLibChatMessage(chatProxy)

-- You can still set the default chat color
lls:SetPrefix("|c" .. colorHex)
lls:SetSuffix("|r") -- reset color to default
```

### What it Looks Like

As you can see below, instead of 2-3 items per line with icons enabled, LibChatMessage enables printing a good 10 items per line.

*LibChatMessage output, sorted by quality, with icons and traits, no quality minimum, singular quantities hidden*

![](https://i.imgur.com/oPK0jpt.png)

*LibChatMessage output, sorted by quality, with icons, traits and non-collected set items icons.  Quality minimum = Fair/green.  Delimiter = new line / "\n".*

![](https://i.imgur.com/tFznij7.png)

## LibAddonMenu Integration

You can generate automatically bound [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html) option controls for the most common configurable LibLootSummary settings.

![](https://i.imgur.com/qB0b3vP.png)

```lua
local addon = {
    name = "MyAddon",
    title = "My Addon",
    author = "Me",
    version = "1.0.0",
    defaults = 
    {
        chatSummary = {
            enabled = true,
            minQuality = ITEM_QUALITY_MIN_VALUE,
            showIcon = true,
            showTrait = true,
            showNotCollected = true,
            sortedByQuality = true,
            hideSingularQuantities = true,
            combineDuplicates = true,
            delimiter = " ",
            linkStyle = LINK_STYLE_DEFAULT,
        },
    },
}

addon.savedVars = ZO_SavedVars:NewAccountWide(addon.name .. "SV", 1, GetWorldName(), addon.defaults)

addon.summary = LibLootSummary()

local addonPanel = {
    type = "panel",
    name = addon.title,
    displayName = addon.title,
    author = addon.author,
    version = addon.version,
    slashCommand = "/myaddonopts",
    registerForRefresh = true,
    registerForDefaults = true,
}

local optionControls = {
    --[[ 'chatSummary' is the name of the saved var setting that holds all chat options
         Note: the following automatically calls 
         summary:SetOptions(addon.savedVars, addon.defaults, 'chatSummary') ]]
    addon.summary:GenerateLam2LootOptions(addon.title, addon.savedVars, addon.defaults, 'chatSummary'),
}

-- Alternatively, you can use GenerateLam2ItemOptions() instead.
-- This just uses the term "Item" instead of "Loot" in the text.

LibAddonMenu2:RegisterAddonPanel(addon.name.."Options", addonPanel)
LibAddonMenu2:RegisterOptionControls(addon.name.."Options", optionControls)
```
