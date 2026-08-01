--------------------------------------------------
-- ShibUI SavedVars handling
--------------------------------------------------
local SUI = SUI

SUI.SavedVars = SUI.SavedVars or {}
local SavedVars = SUI.SavedVars

--------------------------------------------------
-- Default settings for SavedVars (if none exist)
--------------------------------------------------
SUI.SavedVars.defaults = {
    -- General
    accountWide = true,
    confirmReload = true,
    debug = false,

    -- Attribute Bar
    attributeBar = true,
    attributeBarLayout = "shibui",
    attributeBarSize = "default",

    -- Target Bar
    showHostileOnly = true,

    -- Action Bar
    showWeaponSwap = false,
    showKeybindings = false,
    scaledUltimateButton = true,

    -- Player Progress Bar
    showPlayerProgressBar = false,

    -- Group Unit Frame
    groupUnitFrame = true,

    -- Chat Window
    chatWidth = 800,
    chatHeight = 400,
    chatSide = "Left",
    chatAnchor = "Bottom",
    chatDefaultChannelName = "Say",
    chatDefaultChannel = 1, -- CHAT_CHANNEL_SAY value
}

--------------------------------------------------
-- Initialize SavedVars
--------------------------------------------------
function SavedVars:Initialize()
    -- create both stores
    local accountSaved = ZO_SavedVars:NewAccountWide("suiSavedVars", 1, nil, self.defaults)
    local characterSaved = ZO_SavedVars:New("suiSavedVars", 1, nil, self.defaults)

    -- decide which one to use
    local useAccount = accountSaved.accountWide or false
    local sv = useAccount and accountSaved or characterSaved

    -- expose all handles
    self.accountSaved = accountSaved
    self.characterSaved = characterSaved
    self.saved = sv   -- global reference
end