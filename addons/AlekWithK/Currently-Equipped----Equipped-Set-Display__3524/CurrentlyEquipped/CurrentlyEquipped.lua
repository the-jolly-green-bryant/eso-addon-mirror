CurrentlyEquipped = CurrentlyEquipped or {}
local CE = CurrentlyEquipped
local LSD = LibSetDetection
CE.name = "CurrentlyEquipped"
CE.author = "|c1cf9e4A|r|c39f3cal|r|c55eeb1e|r|c71e897k|r|c8ee27dW|r|caadc63i|r|cc6d74at|r|ce3d130h|r|cffcb16K|r"
CE.version = "1.3.1"

----------------------------
------### DEFAULTS ###------
----------------------------
CE.lockedUI = true
CE.hideInCombat = true
CE.hideInMenu = true
CE.show_in_zone = false
CE.hide_delay = 0
CE.show_UI = false
CE.x_offset = 1000
CE.y_offset = 500
CE.max_rows = 14
CE.rows = {}

CE.head_color = {0.8353, 0.7922, 0.8039, 1} --white
CE.comp_color = {0.4941, 1, 0.5098, 1} --green
CE.incomp_color = {1, 0.3490, 0.2706, 1} --red
CE.warn_color = {1, 0.8118, 0.2549, 1} --yellow

local in_combat = false
local ui_is_hidden = false
--local layer_pushed = false

local TRIAL_ZONE_IDS = {
    [636] = true, -- Hel Ra Citadel
    [638] = true, -- Aetherian Archive
    [639] = true, -- Sanctum Ophidia
    [725] = true, -- Maw of Lorkhaj
    [975] = true, -- Halls of Fabrication
    [1000] = true, -- Asylum Sanctorium
    [1051] = true, -- Cloudrest
    [1121] = true, -- Sunspire
    [1196] = true, -- Kyne's Aegis
    [1344] = true, -- Dreadsail Reef
    [1263] = true, -- Rockgrove
    [1427] = true, -- Sanity's Edge
    [1478] = true
}

local ARENA_ZONE_IDS = {
    [635] = true, -- Dragonstar Arena
    [677] = true, -- Maelstrom Arena
    [1082] = true, -- Blackrose Prison
    [1227] = true -- Vateshran Hollows
}

----------------------------
---### INITIALIZATION ###---
----------------------------
function CE.Init()
    CE.savedVariables = ZO_SavedVars:NewAccountWide("CurrentlyEquippedSavedVariables", 1, nil, {})

    CE.AddonMenu() 
    CE.RestoreDefaults()
    CE.InitUI()
    CE.RestorePos() 
    --CE.DEBUG()
end

--Restore defaults (must use IF if boolean)
function CE.RestoreDefaults()
    if CE.savedVariables.hideInCombat ~= nil then CE.hideInCombat = CE.savedVariables.hideInCombat end
    if CE.savedVariables.hideInMenu ~= nil then CE.hideInMenu = CE.savedVariables.hideInMenu end
    if CE.savedVariables.show_in_zone ~= nil then CE.show_in_zone = CE.savedVariables.show_in_zone end
    CE.hide_delay = CE.savedVariables.hide_delay or CE.hide_delay
    CE.head_color = CE.savedVariables.head_color or CE.head_color
    CE.comp_color = CE.savedVariables.comp_color or CE.comp_color
    CE.incomp_color = CE.savedVariables.incomp_color or CE.incomp_color
    CE.warn_color = CE.savedVariables.warn_color or CE.warn_color
end

function CE.InitUI()
    for i=1, CE.max_rows, 1 do
        CE.rows[i] = CEFrame:GetNamedChild("Row" .. i)
        CE.rows[i].nums = CE.rows[i]:GetNamedChild("Nums")
        CE.rows[i].names = CE.rows[i]:GetNamedChild("Names")

        CE.rows[i].enabled = false;
    end
    CEFrameTitle:SetColor(unpack(CE.head_color))
    CEFrameTitle:SetText(CE_DISPLAY_NAME)
end

--Restore UI position
function CE.RestorePos()
    local left = CE.savedVariables.left or CE.x_offset
    local top = CE.savedVariables.top or CE.y_offset

    CEFrame:ClearAnchors()
    CEFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--Register events
function CE.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_COMBAT_STATE, CE.HideUICombat)
    EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_ACTIVATED, CE.PlayerActivate)
    EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_RETICLE_HIDDEN_UPDATE, CE.LayerChange)
    
    LSD.RegisterEvent(LSD_EVENT_DATA_UPDATE, "CurrentlyEquipped", CE.OnSetUpdate, LSD_UNIT_TYPE_PLAYER)

end

function CE.PlayerActivate(_, initial)
    local curr_zone_id = GetZoneId(GetUnitZoneIndex("player"))
    --Only show display in Trial/Arenas, don't update data either
    if CE.show_in_zone and not (TRIAL_ZONE_IDS[curr_zone_id] or ARENA_ZONE_IDS[curr_zone_id]) then
        CE.show_UI = false
        CEFrame:SetHidden(true)
        return
    else
        CE.show_UI = true
    end
    CE.OnSetUpdate()
end

-------------------------------
---### UI SHOW/HIDE FUNC ###---
-------------------------------
function CE.MoveUI()
    if CE.lockedUI then CEFrame:SetMovable(true)
    else CEFrame:SetMovable(false) end
end

function CE.HideUICombat()
    in_combat = IsUnitInCombat("player")

    if in_combat and CE.hideInCombat then 
        zo_callLater(function() CE.HideUI() end, (0 + (1000 * CE.hide_delay)))
    else
        CEFrame:SetHidden(false)
        ui_is_hidden = false
    end
end

--Hide display when menuing
function CE.LayerChange(event, hidden)
    if CE.hideInMenu then
        if hidden and not ui_is_hidden then
            CE.HideUI()
        elseif not hidden then
            CE.HideUICombat()
        end
    end        
end

function CE.HideUI()
    if not ui_is_hidden and CE.lockedUI then
        CEFrame:SetHidden(true)
        ui_is_hidden = true
    end
end

--Need to resetUI when a set is removed so that extra row is removed
function CE.ResetUI()
    for i=1, CE.max_rows, 1 do
        CE.rows[i]:SetHidden(true)
    end 
end

----------------------------
---### SAVE VARIABLES ###---
----------------------------
function CE.SavePos()
    CE.savedVariables.left = CEFrame:GetLeft()
    CE.savedVariables.top = CEFrame:GetTop()
end

function CE.SaveHideInCombat(bool)
    CE.savedVariables.hideInCombat = bool end

function CE.SaveHideInMenu(bool)
    CE.savedVariables.hideInMenu = bool 
    if not bool then
        CEFrame:SetHidden(false)
        ui_is_hidden = false
    end
end

function CE.SaveShowInZone(bool)
    CE.savedVariables.show_in_zone = bool end

function CE.SaveHideDelay(value)
    CE.savedVariables.hide_delay = value end

function CE.SaveHeadColor(r, g, b, a)
    CE.savedVariables.head_color = {r, g, b, a}
    CE.head_color = {r, g, b, a}
    CE.UpdateUI()
end

function CE.SaveCompColor(r, g, b, a)
    CE.savedVariables.comp_color = {r, g, b, a}
    CE.comp_color = {r, g, b, a}
    CE.UpdateUI()
end

function CE.SaveIncompColor(r, g, b, a)
    CE.savedVariables.incomp_color = {r, g, b, a}
    CE.incomp_color = {r, g, b, a}
    CE.UpdateUI()
end

function CE.SaveWarnColor(r, g, b, a)
    CE.savedVariables.warn_color = {r, g, b, a}
    CE.warn_color = {r, g, b, a}
    CE.UpdateUI()
end

----------------------------
---### ADDON STARTUP ###----
----------------------------
function CE.OnAddOnLoaded(_, addonName)
    if addonName ~= CE.name then return end

    EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/cereset"] = CE.OnSetUpdate

    CE.RegisterEvents()
    CE.Init()
end 

EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_ADD_ON_LOADED, CE.OnAddOnLoaded)