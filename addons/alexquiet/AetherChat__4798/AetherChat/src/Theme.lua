-- ============================================================================
-- AetherChat : Skyrim & Elder Scrolls Theme Engine (Authentic Tamriel Palette)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.Theme = {}
local Theme = AetherChat.Theme

Theme.Hex = {
    -- Fixed dedicated colors for other players (NEVER change with themes)
    OTHER_GUILD   = '8CD17D', -- Fixed Sage Green for Guild Members
    OTHER_PARTY   = '80C0FF', -- Fixed Celestial Blue for Party Members
    OTHER_WHISPER = 'C084FC', -- Fixed Soft Violet/Lilac for Whisper Contacts
    OTHER_ZONE    = 'C5C29E', -- Fixed Weathered Parchment for Zone/Say

    -- Standard text colors
    NORMAL        = 'E0E0E0', -- Pure Crisp Chat Text
    MUTED         = '888888', -- Timestamp Muted Grey
    GREEN         = '57F287', -- Default Green
}

Theme.Presets = {
    skyrim_nordic = {
        name = "Skyrim Dragonborn (Givre & Souffle de Dragon)",
        accentHex = "38BDF8",
        accentR = 0.22, accentG = 0.74, accentB = 0.97,
        selfHex = "38BDF8", -- Skyrim Ice / Frost Cyan for player's own name
        headerColor = "38BDF8",
        titleText = "|c38BDF8AETHER|r|cFFFFFFCHAT|r",
    },
    gold_dwemer = {
        name = "Dwemer Gold (Machines & Bronze Antique)",
        accentHex = "D4AF37",
        accentR = 0.83, accentG = 0.69, accentB = 0.22,
        selfHex = "FFD700", -- Radiant Dwemer Gold for player's own name
        headerColor = "D4AF37",
        titleText = "|cD4AF37AETHER|r|cFFFFFFCHAT|r",
    },
    emerald_nordic = {
        name = "Nordic Emerald (Forêts de Bordeciel & Jade)",
        accentHex = "57F287",
        accentR = 0.34, accentG = 0.95, accentB = 0.53,
        selfHex = "57F287", -- Spriggan Forest Emerald for player's own name
        headerColor = "57F287",
        titleText = "|c57F287AETHER|r|cFFFFFFCHAT|r",
    },
    ruby_crimson = {
        name = "Crimson Brotherhood (Confrérie Noire & Sanctuaire)",
        accentHex = "F23F43",
        accentR = 0.95, accentG = 0.25, accentB = 0.26,
        selfHex = "F23F43", -- Shadow Blood Ruby for player's own name
        headerColor = "F23F43",
        titleText = "|cF23F43AETHER|r|cFFFFFFCHAT|r",
    },
    dark_glass = {
        name = "Dark Glass (Moderne Épuré)",
        accentHex = "5865F2",
        accentR = 0.35, accentG = 0.40, accentB = 0.95,
        selfHex = "5865F2", -- Electric Discord Indigo for player's own name
        headerColor = "5865F2",
        titleText = "|c5865F2AETHER|r|cFFFFFFCHAT|r",
    },
}

function Theme.GetCurrentTheme()
    local themeKey = AetherChat.Settings.Get('activeTheme', 'skyrim_nordic')
    return Theme.Presets[themeKey] or Theme.Presets.skyrim_nordic
end

function Theme.ApplyTheme(themeKey)
    local theme = Theme.Presets[themeKey] or Theme.Presets.skyrim_nordic
    if not theme then return end

    AetherChat.Settings.Set('activeTheme', themeKey)

    local win = AetherChat_MessengerWindow
    if win then
        local title = win:GetNamedChild('Title')
        if title and theme.titleText then
            title:SetText(theme.titleText)
        end
    end

    if AetherChat.Messenger and AetherChat.Messenger.RefreshChannelList then
        AetherChat.Messenger.RefreshChannelList()
    end
end
