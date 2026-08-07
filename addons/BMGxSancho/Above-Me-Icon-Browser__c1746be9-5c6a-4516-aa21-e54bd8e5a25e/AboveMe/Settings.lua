AboveMe = AboveMe or {}
local AM = AboveMe
local LHA
local CREDIT_YELLOW = "|cE5C100"
local COLOR_END = "|r"

function AM:CreateSettings()
    if not LibHarvensAddonSettings then return end
    LHA = LibHarvensAddonSettings

    local panel = LHA:AddAddon("Above Me", { allowDefaults = true, allowRefresh = true })
    if not panel then return end

    panel:AddSetting({
        type = LHA.ST_LABEL,
        label = CREDIT_YELLOW .. "A BMG ADDON\nCreated and maintained by @BMGXSANCHO\nVersion 0.7.6-dev5" .. COLOR_END,
    })

    panel:AddSetting({ type = LHA.ST_SECTION, label = "My Icon" })
    panel:AddSetting({
        type = LHA.ST_LABEL,
        label = function()
            local icon = AM:GetIcon(AM.saved.iconId)
            return "CURRENT ICON\n" .. icon.name
        end,
    })
    panel:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Choose My Icon",
        tooltip = "Open the full-screen icon browser with categories, previews, and favorites.",
        buttonText = "OPEN BROWSER",
        clickHandler = function() AM:OpenIconBrowser() end,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Favorite Current Icon",
        getFunction = function() return AM:IsFavorite(AM.saved.iconId) end,
        setFunction = function(value) AM:SetFavorite(AM.saved.iconId, value) end,
        default = false,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Random Favorite on Login",
        getFunction = function() return AM.saved.randomFavoriteOnLogin end,
        setFunction = function(value) AM.saved.randomFavoriteOnLogin = value end,
        default = false,
    })
    panel:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Random Favorite Now",
        buttonText = "CHOOSE",
        clickHandler = function() AM:ChooseRandomFavorite() end,
    })

    panel:AddSetting({ type = LHA.ST_SECTION, label = "Visibility" })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Enable Above Me",
        getFunction = function() return AM.saved.enabled end,
        setFunction = function(value) AM.saved.enabled = value end,
        default = true,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Show My Own Icon",
        getFunction = function() return AM.saved.showOwnIcon end,
        setFunction = function(value) AM.saved.showOwnIcon = value end,
        default = true,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Show Group Icons",
        getFunction = function() return AM.saved.showGroupIcons end,
        setFunction = function(value) AM.saved.showGroupIcons = value end,
        default = true,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Only Show During Combat",
        getFunction = function() return AM.saved.combatOnly end,
        setFunction = function(value) AM.saved.combatOnly = value end,
        default = false,
    })

    panel:AddSetting({ type = LHA.ST_SECTION, label = "Appearance" })
    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Icon Size",
        min = 24,
        max = 96,
        step = 2,
        getFunction = function() return AM.saved.size end,
        setFunction = function(value) AM.saved.size = value end,
        default = 48,
    })
    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Adjust My Icon Height",
        tooltip = "Move your icon lower or higher until it sits just above your name. This setting is saved separately for each character and shared with other Above Me users.",
        min = -0.75,
        max = 0.50,
        step = 0.05,
        getFunction = function() return AM:GetPlacementOffset() end,
        setFunction = function(value) AM:SetPlacementOffset(value) end,
        default = 0,
    })
    panel:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Reset My Icon Height",
        buttonText = "RESET",
        clickHandler = function() AM:SetPlacementOffset(0) end,
    })
    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Opacity",
        min = 0.2,
        max = 1,
        step = 0.05,
        getFunction = function() return AM.saved.opacity end,
        setFunction = function(value) AM.saved.opacity = value end,
        default = 1,
    })
    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Icon Visibility Distance",
        tooltip = "Maximum distance at which another player's icon remains visible.",
        min = 10,
        max = 100,
        step = 5,
        getFunction = function() return AM.saved.maxDistance end,
        setFunction = function(value) AM.saved.maxDistance = value end,
        default = 55,
    })
    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Fade Near Visibility Limit",
        getFunction = function() return AM.saved.fadeWithDistance end,
        setFunction = function(value) AM.saved.fadeWithDistance = value end,
        default = false,
    })

    self.settingsPanel = panel
end
