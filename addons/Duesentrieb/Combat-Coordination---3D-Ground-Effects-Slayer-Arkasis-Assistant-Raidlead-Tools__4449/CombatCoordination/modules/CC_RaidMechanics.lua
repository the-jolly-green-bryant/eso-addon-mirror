local CC = CombatCoordination
--local LUT = CC.LUT.VESTMENT_OF_OLORIME

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "RaidMechanics",
    menuName  = "RAID MECHANICS",
    iconPath  = "/esoui/art/icons/ability_sorcerer_065.dds",
    menuLayer = 0,

    Default = {
        enableDebug = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- LAM2 MENU
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s", menuIcon, CC.ColorString(self.menuName, "tier2")),
        controls = {
            {
                type = "description",
                text = "Currently disabled. Back soon!",
                width = "full",
            },
            {
                type = "divider",
            },
            {
                type = "checkbox",
                name = "Enable Debug",
                getFunc = function() return self.SV.enableDebug end,
                setFunc = function(value) self.SV.enableDebug = value end,
                default = self.Default.enableDebug,
                disabled = function() return not CC.SV.enableAddon end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)