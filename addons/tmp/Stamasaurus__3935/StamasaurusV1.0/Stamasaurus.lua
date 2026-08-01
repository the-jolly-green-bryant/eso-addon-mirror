STNS = {
    name = "Stamasaurus", -- dinosaurs are cool
    version = "1.0",
    author = "TheMrPancake",
    coral_equipped = false,
}

local function showUI()
    StamasaurusXML:SetHidden(false)
    StamasaurusXMLLabel:SetHidden(false)
end

local function hideUI()
    StamasaurusXML:SetHidden(true)
    StamasaurusXMLLabel:SetHidden(true)
end

local function updateUI()
    StamasaurusXML:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    StamasaurusXMLLabel:SetText("You have too much stamina!")
    StamasaurusXMLLabel:SetAnchor(CENTER, StamasaurusXML, CENTER, 0, (GuiRoot:GetHeight() / 10))
    --d("UI updated")
end

local function createUI()
    StamasaurusXML:ClearAnchors()
    StamasaurusXML:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    updateUI()
    --https://youtu.be/JkcbeMnLc40
    local alphaFragment = ZO_HUDFadeSceneFragment:New(StamasaurusXML, 250, 0)
    HUD_SCENE:AddFragment(alphaFragment)
    HUD_UI_SCENE:AddFragment(alphaFragment)
    hideUI()
    --d("UI created")
end

-- EVENT_POWER_UPDATE (*string* _unitTag_, *luaindex* _powerIndex_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *integer* _powerValue_, *integer* _powerMax_, *integer* _powerEffectiveMax_)

function STNS.PowerUpdate(event, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local in_combat = IsUnitInCombat("player")
    local dead = IsUnitDead("player")
    if dead or not in_combat then hideUI() return end
    if (powerType == POWERTYPE_STAMINA) then
        local stamina_percentage = powerValue / powerMax
        if (stamina_percentage > 0.4) then 
            -- stamina too high
            showUI()
            if (stamina_percentage > 0.7) then STNS.CheckCoral() end
        else 
            hideUI()
        end
    end
end

function STNS.CheckCoral()
    if not CurrentlyEquipped.set_names then STNS.DelayUpdate() return end
    for i=1, table.getn(CurrentlyEquipped.set_names), 1 do
        local format_name = zo_strformat(SI_ABILITY_NAME, CurrentlyEquipped.set_names[i])
        --d(format_name)
        if (format_name == "Coral Riptide") then
            EVENT_MANAGER:RegisterForEvent(STNS.name, EVENT_POWER_UPDATE, STNS.PowerUpdate)
            STNS.coral_equipped = true
            return
        end
    end
    STNS.coral_equipped = false
    EVENT_MANAGER:UnregisterForEvent(STNS.name, EVENT_POWER_UPDATE)
    --d("Coral Riptide not equipped, unregistering for power updates")
end

function STNS.DelayUpdate()
    if IsUnitInCombat("player") then return end
    zo_callLater(function() STNS.CheckCoral() end, GetLatency() + 1000)
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(STNS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, STNS.DelayUpdate)
    EVENT_MANAGER:AddFilterForEvent(STNS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(STNS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
    EVENT_MANAGER:AddFilterForEvent(STNS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON , INVENTORY_UPDATE_REASON_DEFAULT)
end

local function Init(event, name)
    if name ~= STNS.name then return end

    EVENT_MANAGER:UnregisterForEvent(STNS.name, EVENT_ADD_ON_LOADED)

    RegisterEvents()
    createUI()
    STNS.CheckCoral()
end

EVENT_MANAGER:RegisterForEvent(STNS.name, EVENT_ADD_ON_LOADED, Init)