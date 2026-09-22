local CC = CombatCoordination
--local LUT = CC.LUT.VESTMENT_OF_OLORIME

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "RaidMechanics",
    menuName  = "RAID MECHANICS",
    iconPath  = "/esoui/art/icons/ability_sorcerer_065.dds",
    menuLayer = 2,

    Default = {
        enableModule = true,
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
        name = function()
            local stringEnable = self.SV.enableModule and "" or CC.ColorString("[OFF] ", "RD")
            return string.format("%s %s%s", menuIcon, stringEnable, CC.ColorString(self.menuName, "tier2"))
        end,
        controls = {
            -- ENABLE / DISABLE MODULE
            { type = "header", name = CC.ColorString("ENABLE / DISABLE MODULE", "tier3") },
            {
                type = "checkbox",
                name = CC.ColorString("Enable Module", "GN"),
                getFunc = function() return self.SV.enableModule end,
                setFunc = function(value)
                    self.SV.enableModule = value
                    if value then
                        if self.CustomEnable then self:CustomEnable() end
                    else
                        if self.CustomDisable then self:CustomDisable() end
                    end
                end,
                default = self.Default.enableModule,
                disabled = function() return not CC.SV.enableAddon end,
                requiresReload = true,
            },
            { type = "divider" },

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
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)