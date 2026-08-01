WildHuntHelper = {
    name            = "WildHuntHelper",           -- Matches folder and Manifest file names.
    version         = "1.0.3",                -- A nuisance to match to the Manifest.
    author          = "FAR747",
    color           = "DDFFEE",             -- Used in menu titles and so on.
    menuName        = "Wild Hunt Helper",          -- A UNIQUE identifier for menu object.
}

WildHuntHelper.gearslots = {
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
}

-- Settings.
WildHuntHelper.defaultvars = {
    IconPos = {
        x = 940,
        y = 480,
        default = true,
    },
    IconCustomize = {
        IconTransparency = 1,
        BGTransparency = 0.5,
    },
    Lockicon = false,
    RingName = GetString(SI_WHH_RINGNAME),
    enableCuntomRingName = false,
}
WildHuntHelper.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false,                -- Load settings from account savedVars, instead of character.
    IconPos = {
        x = 940,
        y = 480,
        default = true,
    },
    IconCustomize = {
        IconTransparency = 1,
        BGTransparency = 0.5,
    },
    Lockicon = false,
    RingName = GetString(SI_WHH_RINGNAME),
    enableCuntomRingName = false,
    
}

WildHuntHelper.savedVarsChar = {
    RingBagLastSlotID = 0,
    RingBagLastID = 0,
}

WildHuntHelper.Temps = {
    RingEquip = false,
    SlotID = 0,
    RingBagSlotID = 0,
    RingBagLastSlotID = 0,
    maxBagItems = 0,
    indungeon = false,
    isBGRed = false,
}

WildHuntHelper.gearWHRing = {
    Gear = {
        ID = 0,
        Stage = false
    },
    Inventory = {
        ID = 0,
        Stage = false
    },
}

WildHuntHelper.addongui = {
    Main = WildHuntHelperGUI,
}


function WildHuntHelper.initinventory()
    local bagsize = GetNumBagUsedSlots(BAG_BACKPACK)
    local curslot = 1
    local wildhuntringfound = false
    while curslot <= bagsize do
        local itemId = GetItemUniqueId(BAG_BACKPACK, curslot)
        if itemId then
            local iname = GetItemName(BAG_BACKPACK, curslot)
            local iswildhunt = WildHuntHelper.checkRing(iname)
            if iswildhunt then
            WildHuntHelper.Temps.RingBagSlotID = curslot
            wildhuntringfound = true
            break
            end
        end
        curslot = curslot + 1
    end
    if not wildhuntringfound then
        WildHuntHelper.Temps.RingBagSlotID = 0
    end
    return wildhuntringfound
end 

function WildHuntHelper.gearcheck()
    local gear = {}
    local gname = {}
    local wildhuntringfound = false
    for _, gearSlot in ipairs(WildHuntHelper.gearslots) do
        local itemId = GetItemUniqueId(BAG_WORN, gearSlot)
        if itemId then
            gear[Id64ToString(itemId)] = gearSlot
            --local iname = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
            local iname = GetItemName(BAG_WORN, gearSlot)
            gname[#gname+1] = iname
            local iswildhunt = WildHuntHelper.checkRing(iname)
            --local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_WORN, gearSlot)
            --d(icon)
            --d(itemId)
            if iswildhunt then
                WildHuntHelper.Temps.SlotID = gearSlot
                WildHuntHelper.Temps.RingEquip = true
                wildhuntringfound = true
                break
            end
        end
    end

    if not wildhuntringfound then
        WildHuntHelper.Temps.SlotID = 0
        WildHuntHelper.Temps.RingEquip = false
    end
    WildHuntHelper.UPDGUI()
end

function WildHuntHelper.checkRing(name)
    if name == WildHuntHelper.savedVars.RingName and WildHuntHelper.savedVars.enableCuntomRingName then
        --d("OK!")
        return true
    elseif name == GetString(SI_WHH_RINGNAME) then
        --d("OK 2")
        return true
    else
        return false
    end
end

function WildHuntHelper.CustomButtonNameCheckRing()
    local gear = {}
    local gname = {}
    local wildhuntringfound = false
    local localgearslots = {EQUIP_SLOT_RING1}
    for _, gearSlot in ipairs(localgearslots) do
        local itemId = GetItemUniqueId(BAG_WORN, gearSlot)
        if itemId then
            gear[Id64ToString(itemId)] = gearSlot
            --local iname = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
            local iname = GetItemName(BAG_WORN, gearSlot)
            gname[#gname+1] = iname
            WildHuntHelper.savedVars.RingName = iname
            --d(WildHuntHelper.savedVarsChar.RingBagLastID)
        end
    end
end

function WildHuntHelper.switchring()
    --WildHuntHelper.CheckPlayerInDungeon()
    WildHuntHelper.gearcheck()
    if WildHuntHelper.Temps.RingEquip then
        if WildHuntHelper.savedVarsChar.RingBagLastID ~= 0 then
            local isfound = WildHuntHelper.FindItemfromIDinInventory(WildHuntHelper.savedVarsChar.RingBagLastID)
            if isfound ~= -1 then
                WildHuntHelper.savedVarsChar.RingBagLastSlotID = isfound
                EquipItem(BAG_BACKPACK,isfound,EQUIP_SLOT_RING1)
                WildHuntHelper.savedVarsChar.RingBagLastID = 0
            else
                WildHuntHelper.sendmessagetochat(GetString(SI_WHH_MESSAGE_OLDRINGUNNOTFOUND))
            end
        else
            WildHuntHelper.sendmessagetochat(GetString(SI_WHH_MESSAGE_OLDRINGUNKNOWN))
        end
    else
    local wildhuntringfound = WildHuntHelper.initinventory()
        --BAG_BACKPACK, bpSlot, gearSlot, EquipItem
        if wildhuntringfound then
            WildHuntHelper.saveCurRingID()
            EquipItem(BAG_BACKPACK,WildHuntHelper.Temps.RingBagSlotID,EQUIP_SLOT_RING1)
            --d("OK!")
        else
            WildHuntHelper.sendmessagetochat(GetString(SI_WHH_MESSAGE_WILDHUNTRINGNOTFOUNT))
        end
    end
end

function WildHuntHelper.saveCurRingID()
    local gear = {}
    local gname = {}
    local wildhuntringfound = false
    local localgearslots = {EQUIP_SLOT_RING1}
    for _, gearSlot in ipairs(localgearslots) do
        local itemId = GetItemUniqueId(BAG_WORN, gearSlot)
        if itemId then
            gear[Id64ToString(itemId)] = gearSlot
            --local iname = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
            local iname = GetItemName(BAG_WORN, gearSlot)
            gname[#gname+1] = iname
            WildHuntHelper.savedVarsChar.RingBagLastID = GetItemId(BAG_WORN, gearSlot)
            --d(WildHuntHelper.savedVarsChar.RingBagLastID)
        end
    end
end
function WildHuntHelper.FindItemfromIDinInventory(uItemID)
    local bagsize = GetNumBagUsedSlots(BAG_BACKPACK)
    local curslot = 1
    local isfound = false
    local foundslot = -1
    while curslot <= bagsize do
        local itemId = GetItemUniqueId(BAG_BACKPACK, curslot)
        if itemId then
            local iname = GetItemName(BAG_BACKPACK, curslot)
            local iID = GetItemId(BAG_BACKPACK, curslot)
            if iID == uItemID then
                isfound = true
                foundslot = curslot
                --d(iname)
                break
            end
        end
        curslot = curslot + 1
    end
    return foundslot
end

function WildHuntHelper.sendmessagetochat(text)
    d("|cFFAD00WHH:|r "..text.."")
end 

function WildHuntHelper.OnZoneChanged()
    WildHuntHelper.CheckPlayerInDungeon()
    WildHuntHelper.UPDGUI()
    --d("OnZoneChanged")
end

function WildHuntHelper.CheckPlayerInDungeon()
    if IsUnitInDungeon("player") then
        --d("You're in a dungeon! You can get an achievement for blocking a ton of damage while you're here.")
        WildHuntHelper.Temps.indungeon = true
    else
        WildHuntHelper.Temps.indungeon = false
    end
end

function WildHuntHelper.TimerOne()
    WildHuntHelper.GUIedgeAlerts()
end

--GUI ZONE

function WildHuntHelper.GUIINIT()
    local window = WildHuntHelper.addongui.Main
    local ICONBG = window:GetNamedChild("BG")
    local ICONBG_RED = window:GetNamedChild("BGRED")
    if not WildHuntHelper.savedVars.IconPos.default then
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WildHuntHelper.savedVars.IconPos.x, WildHuntHelper.savedVars.IconPos.y)
    end
    window:SetMouseEnabled(not WildHuntHelper.savedVars.Lockicon)
    window:SetAlpha(WildHuntHelper.savedVars.IconCustomize.IconTransparency)
    ICONBG:SetAlpha(WildHuntHelper.savedVars.IconCustomize.BGTransparency)
    ICONBG_RED:SetAlpha(0)
    --scene init
    --local fragment = ZO_HUDFadeSceneFragment:New(window, nil, 0)
    --HUD_SCENE:AddFragment(fragment)
    --HUD_UI_SCENE:AddFragment(fragment)

    --WildHuntHelper.CheckPlayerInDungeon()
    
    local fragment = HUD_FRAGMENT
    fragment:RegisterCallback("StateChange", WildHuntHelper.GUIfragmentChange)
    
    --addtimer
    EVENT_MANAGER:RegisterForUpdate(WildHuntHelper.name .. "CheckTimer", 1000, WildHuntHelper.TimerOne)
    WildHuntHelper.UPDGUI()
end

function WildHuntHelper.UPDGUI()
    local window = WildHuntHelper.addongui.Main
    local ICONBG = window:GetNamedChild("BG")
    local ICONBG_RED = window:GetNamedChild("BGRED")
    ICONBG:SetAlpha(WildHuntHelper.savedVars.IconCustomize.BGTransparency)
    ICONBG_RED:SetAlpha(0)
    if WildHuntHelper.Temps.RingEquip then
        WildHuntHelper.addongui.Main:SetHidden(false)
        --window:SetAlpha(WildHuntHelper.savedVars.IconCustomize.IconTransparency)
    else
        WildHuntHelper.addongui.Main:SetHidden(true)
        --window:SetAlpha(0)
    end
end

function WildHuntHelper.GUIfragmentChange(oldState, newState)
    local window = WildHuntHelper.addongui.Main
    --d("New: ".. newState)
    if (newState == SCENE_FRAGMENT_SHOWN ) then
        WildHuntHelper.UPDGUI()
    elseif (newState == SCENE_FRAGMENT_HIDDEN ) then
        WildHuntHelper.addongui.Main:SetHidden(true)
    end
    
end

function WildHuntHelper.SAVEGUIPOS()
    WildHuntHelper.savedVars.IconPos.x = WildHuntHelper.addongui.Main:GetLeft() -- Save X
    WildHuntHelper.savedVars.IconPos.y = WildHuntHelper.addongui.Main:GetTop() -- Save Y
    WildHuntHelper.savedVars.IconPos.default = false
    --d(WildHuntHelper.savedVars.IconPos.x) --940
    --d(WildHuntHelper.savedVars.IconPos.y) --480
end

function WildHuntHelper.GUILOCKICON(lock)
    WildHuntHelper.savedVars.Lockicon = lock
    WildHuntHelper.addongui.Main:SetMouseEnabled(not lock) 
end

function WildHuntHelper.GUIRESETPOS()
    local window = WildHuntHelper.addongui.Main
    WildHuntHelper.savedVars.IconPos.x = WildHuntHelper.defaultvars.IconPos.x
    WildHuntHelper.savedVars.IconPos.y = WildHuntHelper.defaultvars.IconPos.y
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WildHuntHelper.savedVars.IconPos.x, WildHuntHelper.savedVars.IconPos.y)
end

function WildHuntHelper.SetGUIIconTransparency(value)
    local window = WildHuntHelper.addongui.Main
    --GetNamedChild("DetailPanel")
    WildHuntHelper.savedVars.IconCustomize.IconTransparency = value
    window:SetAlpha(value)
end

function WildHuntHelper.SetGUIBGIconTransparency(value)
    local window = WildHuntHelper.addongui.Main
    local ICONBG = window:GetNamedChild("BG")
    --GetNamedChild("DetailPanel")
    WildHuntHelper.savedVars.IconCustomize.BGTransparency = value
    ICONBG:SetAlpha(value)
end

function WildHuntHelper.GameUIHiddenUpdate()
    WildHuntHelper.UPDGUI()
end

function WildHuntHelper.GUIedgeAlerts()
    local window = WildHuntHelper.addongui.Main
    local ICONBG = window:GetNamedChild("BG")
    local ICONBG_RED = window:GetNamedChild("BGRED")
    --ICONBG_RED:SetAlpha(WildHuntHelper.savedVars.IconCustomize.BGTransparency)
    if not WildHuntHelper.Temps.RingEquip then
        --WildHuntHelper.UPDGUI()
        --return
    end
    if WildHuntHelper.Temps.indungeon then
        if WildHuntHelper.Temps.isBGRed then
            ICONBG_RED:SetAlpha(0)
            ICONBG:SetAlpha(WildHuntHelper.savedVars.IconCustomize.BGTransparency)
            WildHuntHelper.Temps.isBGRed = false
        else
            ICONBG_RED:SetAlpha(1)
            ICONBG:SetAlpha(0)
            WildHuntHelper.Temps.isBGRed = true
        end
    else
        ICONBG_RED:SetAlpha(0)
        ICONBG:SetAlpha(WildHuntHelper.savedVars.IconCustomize.BGTransparency)
    end

end
--END GUI ZONE
function WildHuntHelper.onInventoryChanged(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    local link = GetItemLink(bagId, slotIndex)
    if bagId == BAG_WORN then
    --d("Picked up a " .. link .. ".")
    WildHuntHelper.gearcheck()
    end
end

-- Only show the loading message on first load ever.
function WildHuntHelper.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(WildHuntHelper.name, EVENT_PLAYER_ACTIVATED)
    if WildHuntHelper.savedVars.firstLoad then
        WildHuntHelper.savedVars.firstLoad = false
    end
    --WildHuntHelper.initinventory()
    WildHuntHelper.gearcheck()
    WildHuntHelper.GUIINIT()

    
end


function WildHuntHelper.OnAddOnLoaded(event, addonName)
    if addonName ~= WildHuntHelper.name then return end
    EVENT_MANAGER:UnregisterForEvent(WildHuntHelper.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    WildHuntHelper.characterSavedVars = ZO_SavedVars:NewCharacterIdSettings("WildHuntHelperSavedVariables", 1, nil, WildHuntHelper.savedVars)
    WildHuntHelper.accountSavedVars = ZO_SavedVars:NewAccountWide("WildHuntHelperSavedVariables", 1, nil, WildHuntHelper.savedVars)
    WildHuntHelper.savedVarsChar = ZO_SavedVars:NewCharacterIdSettings("WildHuntHelperSavedVariablesChar", 1, nil, WildHuntHelper.savedVarsChar)
    if not WildHuntHelper.characterSavedVars.accountWide then
        WildHuntHelper.savedVars = WildHuntHelper.characterSavedVars
    else
        WildHuntHelper.savedVars = WildHuntHelper.accountSavedVars
    end
    -- When player is ready, after everything has been loaded.
    EVENT_MANAGER:RegisterForEvent(WildHuntHelper.name, EVENT_PLAYER_ACTIVATED, WildHuntHelper.Activated)
    EVENT_MANAGER:RegisterForEvent(WildHuntHelper.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WildHuntHelper.onInventoryChanged)
    --EVENT_MANAGER:RegisterForEvent(WildHuntHelper.name, EVENT_RETICLE_HIDDEN_UPDATE, WildHuntHelper.GameUIHiddenUpdate)
    -- Settings menu in Settings.lua.
    WildHuntHelper.LoadSettings()
    --Callback
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", WildHuntHelper.OnZoneChanged)
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(WildHuntHelper.name, EVENT_ADD_ON_LOADED, WildHuntHelper.OnAddOnLoaded)

--SetAnchor(CENTER, nil, CENTER, self.account.x or sv.x, self.account.y or sv.y)
--