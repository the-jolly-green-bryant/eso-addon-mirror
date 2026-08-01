local CT = ControllerTweaks

local Loot = CT_Plugin:Subclass()

local offsetSettingKey = "LootPanelOffset"
Loot.options = {
    {
        settingKey = offsetSettingKey,
        type = "slider",
        name = "Loot Panel Offset",
        tooltip = "Vertical offset of the recent loot panel.",
        min = -400,
        max = 400,
        step = 5,
        setFunc = function(var) 
            CT.Settings[offsetSettingKey] = var
            CT.Loot:UpdatePanel()
        end,
        width = "full",
        default = 100
    },
}

function Loot:Init()
    self:UpdatePanel()
end

function Loot:UpdatePanel()
    local anchor = ZO_Anchor:New(LEFT, GuiRoot, LEFT, 0, CT.Settings[offsetSettingKey])
    LOOT_HISTORY_GAMEPAD.lootStream.control:GetParent():ClearAnchors()
    anchor:Set(LOOT_HISTORY_GAMEPAD.lootStream.control:GetParent())
end

CT.Loot = Loot;