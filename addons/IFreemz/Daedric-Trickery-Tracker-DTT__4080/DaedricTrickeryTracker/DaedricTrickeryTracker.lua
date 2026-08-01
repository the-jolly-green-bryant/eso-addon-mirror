DTT = DTT or {}
--  ---------------------------
--  Daedric Trickery Tracker
--  ---------------------------
--
--  Tracks the buffs and internal cooldown (ICD) of the Daedric Trickery set.
--  Provides a visual display for active buffs and the remaining cooldown.
--
--  (c) 2025 by @IFreemz954
--
--  Author: @IFreemz954
--  File: DaedricTrickeryTracker.lua
--  Last Update: 05.04.2025

local DTT = DTT

DTT.name = "DaedricTrickeryTracker"; DTT.version = "1.0"; DTT.author = "@IFreemz954"; DTT.savedVarVersion = 15;

DTT.isDebug = false

DTT.DAEDRIC_TRICKERY_SET_ID = 324
DTT.DAEDRIC_TRICKERY_ICD_MS = 9000
DTT.DAEDRIC_TRICKERY_BUFF_DURATION_MS = 21000
DTT.DAMAGE_DETECTION_WINDOW_MS = 350
DTT.PROC_CHECK_DELAY_MS = 150
DTT.MAX_DISPLAY_BUFFS = 5
DTT.DURATION_TOLERANCE_MS = 500

DTT.BUFF_IDS = {
    [61736] = true,
    [61713] = true,
    [61711] = true,
    [61722] = true,
    [61709] = true,
}
DTT.BUFF_DATA = {}

DTT.activeBuffs = {}
DTT.currentIcdEndTime = 0
DTT.equippedPieceCount = 0
DTT.lastPlayerDamageTime = 0

DTT.hasInitialized = false
DTT.settingsPanel = nil
DTT.trackerWindow = nil
DTT.trackerWindowFragment = nil
DTT.isFragmentAdded = false
DTT.savedVariables = nil

local OnAddOnLoaded, OnPlayerActivated, SafeInitialize

local equipSlotList = { EQUIP_SLOT_HEAD, EQUIP_SLOT_NECK, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }
local twoHanderList = { WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_BOW, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD }

local RELEVANT_DAMAGE_RESULTS = {
    [ACTION_RESULT_DAMAGE] = true, [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true, [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
}

local function GetSV(addonTable, key1, key2, key3, default) if not addonTable or type(addonTable) ~= "table" then return default end; local sv=addonTable.savedVariables; local v=sv; if v and key1 then v=v[key1] end; if v and key2 then v=v[key2] end; if v and key3 then v=v[key3] end; if v==nil then local d=addonTable.DefaultSettings and addonTable:DefaultSettings(); local dv=d; if dv and key1 then dv=dv[key1] end; if dv and key2 then dv=dv[key2] end; if dv and key3 then dv=dv[key3] end; return dv~=nil and dv or default end; return v end
function DTT:PrintDebug(message) local msgStr = "[" .. (DTT.name or "DTT") .. " v" .. (DTT.version or "?") .. "] " .. tostring(message); if LibDebugLogger and type(LibDebugLogger.AddMessage) == "function" then pcall(LibDebugLogger.AddMessage, LibDebugLogger, DTT.name .. " v" .. DTT.version, msgStr, LDL_SEVERITY_DEBUG); elseif DTT and DTT.isDebug then if type(d) == "function" then pcall(d, msgStr); end end end
function DTT:DefaultSettings()
    return {
        enabled = true,
        position = { left = 300, top = 300 },
        locked = true,
        design = {
            iconSize = 76,
            borderThickness = 8,
            buffBorderThickness = 3,
            colors = {
                active = { 0, 1, 0, 1 },
                cooldown = { 1, 0, 0, 0.8 },
                standby = { 0.5, 0.5, 0.5, 0.6 }
            },
            standbyOpacity = 100,
            showTimerText = true,
            timerFontSizeScale = 0.5,
            showDecimal = true,
            buffIconScale = 0.7,
            buffTimerScale = 0.5,
        },
        visibility = {
            hideOOC = false,
            requireMinPieces = true,
            minPiecesToShow = 5,
        }
    }
end
function DTT:GetActiveBuffCount() local count = 0; if self.activeBuffs then for _, endTime in pairs(self.activeBuffs) do if type(endTime) == "number" and endTime > GetGameTimeMilliseconds() then count = count + 1 end end end; return count end
function DTT:ApplyLockState() if self.trackerWindow and self.savedVariables then local isMovable = not GetSV(DTT,"locked",nil,nil,true); if _G["DTT_GUI_SetMovable"] then pcall(DTT_GUI_SetMovable, self, isMovable) else DTT:PrintDebug("ERR: DTT_GUI_SetMovable not found.") end; end end
function DTT:IsTwoHandedWeapon(slotId) local itemLink = GetItemLink(BAG_WORN, slotId); if not itemLink or itemLink == "" then return false end; local weaponType = GetItemLinkWeaponType(itemLink); for _, typeId in ipairs(twoHanderList) do if weaponType == typeId then return true end end; return false end
function DTT:UpdateDaedricTrickeryPieceCount() local count = 0; local equipped = {}; for _, slotId in pairs(equipSlotList) do local itemLink = GetItemLink(BAG_WORN, slotId); if itemLink and itemLink ~= "" then local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink); if setId == DTT.DAEDRIC_TRICKERY_SET_ID then if not equipped[slotId] then count = count + 1; equipped[slotId] = true; if (slotId == EQUIP_SLOT_MAIN_HAND or slotId == EQUIP_SLOT_BACKUP_MAIN) and self:IsTwoHandedWeapon(slotId) then count = count + 1; if slotId == EQUIP_SLOT_MAIN_HAND then equipped[EQUIP_SLOT_OFF_HAND] = true end; if slotId == EQUIP_SLOT_BACKUP_MAIN then equipped[EQUIP_SLOT_BACKUP_OFF] = true end end end end end end; local previousCount = DTT.equippedPieceCount; DTT.equippedPieceCount = count; if previousCount ~= count then DTT:PrintDebug("Updated Daedric Trickery piece count: " .. count); end; return previousCount ~= count end
function DTT:UpdateFragmentVisibility() if not DTT.hasInitialized or not DTT.trackerWindow or not DTT.trackerWindowFragment or not DTT.savedVariables then return end; local shouldBeVisible = true; if not GetSV(DTT, "enabled", nil, nil, true) then shouldBeVisible = false; end; local requireMinPieces = GetSV(DTT, "visibility", "requireMinPieces", nil, true); local minPiecesToShow = GetSV(DTT, "visibility", "minPiecesToShow", nil, 5); if shouldBeVisible and requireMinPieces then if DTT.equippedPieceCount < minPiecesToShow then shouldBeVisible = false; end end; local hideOOC = GetSV(DTT, "visibility", "hideOOC", nil, false); if shouldBeVisible and hideOOC then local inCombat = IsUnitInCombat("player"); local now = GetGameTimeMilliseconds(); local isIcdActive = (DTT.currentIcdEndTime > now); local numActiveBuffs = DTT:GetActiveBuffCount(); if not inCombat and numActiveBuffs == 0 and not isIcdActive then shouldBeVisible = false; end end; if shouldBeVisible and not DTT.isFragmentAdded then
HUD_UI_SCENE:AddFragment(DTT.trackerWindowFragment); HUD_SCENE:AddFragment(DTT.trackerWindowFragment); DTT.isFragmentAdded = true; zo_callLater(function() if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end; if DTT.ApplyLockState then pcall(DTT.ApplyLockState, DTT) end end, 0) elseif not shouldBeVisible and DTT.isFragmentAdded then
HUD_UI_SCENE:RemoveFragment(DTT.trackerWindowFragment); HUD_SCENE:RemoveFragment(DTT.trackerWindowFragment); DTT.isFragmentAdded = false end end

function DTT.OnPlayerDamageDealt(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow) if RELEVANT_DAMAGE_RESULTS[result] then DTT.lastPlayerDamageTime = GetGameTimeMilliseconds(); end end

function DTT.DelayedProcCheck(abilityId, endTimeFromEventInMS)
    local now = GetGameTimeMilliseconds();
    local needsGuiUpdate = false;
    local existingEndTime = DTT.activeBuffs[abilityId] or 0;

    local incomingDuration = endTimeFromEventInMS - now

    local isSetEquipped = (DTT.equippedPieceCount >= 5);
    local didPlayerDealDamage = (now - DTT.lastPlayerDamageTime <= DTT.DAMAGE_DETECTION_WINDOW_MS);

    local isCorrectDuration = math.abs(incomingDuration - DTT.DAEDRIC_TRICKERY_BUFF_DURATION_MS) <= DTT.DURATION_TOLERANCE_MS

    if isSetEquipped and didPlayerDealDamage and isCorrectDuration then
        DTT:PrintDebug(string.format("  -> Conditions met (Equipped:%s, Damage:%s, Duration:%s (~%dms)). Starting ICD.", tostring(isSetEquipped), tostring(didPlayerDealDamage), tostring(isCorrectDuration), incomingDuration))
        DTT.currentIcdEndTime = now + DTT.DAEDRIC_TRICKERY_ICD_MS;
        DTT.activeBuffs[abilityId] = endTimeFromEventInMS;
        needsGuiUpdate = true;
    else
        if endTimeFromEventInMS > existingEndTime then
            DTT.activeBuffs[abilityId] = endTimeFromEventInMS;
            needsGuiUpdate = true;
            DTT:PrintDebug(string.format("  -> Conditions NOT met for ICD (Equipped:%s, Damage:%s, Duration:%s (~%dms)). Updating buff time only.", tostring(isSetEquipped), tostring(didPlayerDealDamage), tostring(isCorrectDuration), incomingDuration))
        end
    end

    if needsGuiUpdate and DTT.isFragmentAdded then
        if _G["DTT_GUI_UpdateGUIDisplay"] then
            pcall(DTT_GUI_UpdateGUIDisplay)
        else
            DTT:PrintDebug("  ERROR: DTT_GUI_UpdateGUIDisplay not found!")
        end
    end
end

function DTT.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTimeSec, endTimeSec, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not DTT.hasInitialized then return end; if not DTT.savedVariables or not GetSV(DTT,"enabled",nil,nil,true) then return end;
    if DTT.BUFF_IDS[abilityId] then
        local now = GetGameTimeMilliseconds();
        local endTimeFromEventInMS = (endTimeSec or 0) * 1000;
        local needsGuiUpdate = false;

        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            if endTimeFromEventInMS > now then
                zo_callLater(function() DTT.DelayedProcCheck(abilityId, endTimeFromEventInMS) end, DTT.PROC_CHECK_DELAY_MS)
            end
        elseif changeType == EFFECT_RESULT_FADED then
             if DTT.activeBuffs[abilityId] then
                 DTT.activeBuffs[abilityId] = nil;
                 needsGuiUpdate = true;
                 DTT:PrintDebug("  -> Buff " .. abilityId .. " FADED, removed from tracking.");
             end
        end

        if needsGuiUpdate and DTT.isFragmentAdded then
            if _G["DTT_GUI_UpdateGUIDisplay"] then
                 pcall(DTT_GUI_UpdateGUIDisplay)
            else DTT:PrintDebug("  ERROR: DTT_GUI_UpdateGUIDisplay not found!") end
        end
    end
end

function DTT.OnCombatStateChanged(event, inCombat) if not DTT.hasInitialized or not DTT.savedVariables then return end; if inCombat then EVENT_MANAGER:UnregisterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE); else EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DTT.OnEquipChange); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON , INVENTORY_UPDATE_REASON_DEFAULT); zo_callLater(function() if DTT:UpdateDaedricTrickeryPieceCount() then DTT:UpdateFragmentVisibility() end end, 100) end; DTT:UpdateFragmentVisibility() end
function DTT.OnEquipChange(event, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) if not DTT.hasInitialized then return end; zo_callLater(function() if DTT:UpdateDaedricTrickeryPieceCount() then DTT:UpdateFragmentVisibility() end end, 500) end

function DTT.OnUpdate(elapsedTime)
    if not DTT.hasInitialized then return end
    local now = GetGameTimeMilliseconds()

    if not DTT.isFragmentAdded or not DTT.savedVariables or not GetSV(DTT,"enabled",nil,nil,true) or not DTT.trackerWindow then return end

    local dataChanged = false

    if DTT.currentIcdEndTime > 0 and now >= DTT.currentIcdEndTime then
        DTT.currentIcdEndTime = 0;
        dataChanged = true
    end

    if DTT.activeBuffs then
        local buffsToProcess = {}
        local buffExpiredThisFrame = false
        for id, endTime in pairs(DTT.activeBuffs) do
            if type(endTime) == "number" and now < endTime then
                buffsToProcess[id] = endTime
            else
                if DTT.activeBuffs[id] ~= nil then
                  buffExpiredThisFrame = true
                end
                 if type(endTime) ~= "number" then
                     DTT:PrintDebug("ERR OnUpdate Invalid endTime "..tostring(endTime).." for "..id)
                 end
            end
        end
        if buffExpiredThisFrame then
            DTT.activeBuffs = buffsToProcess
            dataChanged = true
        end
    end

    if DTT.isFragmentAdded then
         if _G["DTT_GUI_UpdateGUIDisplay"] then
             local success, err = pcall(DTT_GUI_UpdateGUIDisplay)
             if not success then DTT:PrintDebug("ERROR in DTT_GUI_UpdateGUIDisplay: " .. tostring(err)) end
        else DTT:PrintDebug("ERROR: DTT_GUI_UpdateGUIDisplay function not found!") end
    end
end


OnAddOnLoaded = function(event, addonName) if addonName == DTT.name then EVENT_MANAGER:UnregisterForEvent(DTT.name, EVENT_ADD_ON_LOADED); EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated) end end
OnPlayerActivated = function(event, initial) if DTT.hasInitialized then return end; SafeInitialize() end

SafeInitialize = function()
    DTT.DAEDRIC_TRICKERY_BUFF_DURATION_MS = 21000

    local defaults=DTT:DefaultSettings(); DTT.savedVariables=ZO_SavedVars:NewAccountWide("DaedricTrickeryTracker",DTT.savedVarVersion,nil,defaults,GetDisplayName()); local function EnsureDefaults(cS,dL) if type(dL)~="table" or type(cS)~="table" then return end; for k,dV in pairs(dL) do if cS[k]==nil then if type(dV)=="table" then cS[k]=ZO_DeepTableCopy(dV) else cS[k]=dV end; elseif type(dV)=="table" and type(cS[k])=="table" then EnsureDefaults(cS[k],dV) end end end; EnsureDefaults(DTT.savedVariables,defaults);
    DTT.BUFF_DATA = {}; if DTT.BUFF_IDS and type(DTT.BUFF_IDS) == "table" then for id, _ in pairs(DTT.BUFF_IDS) do local abilityName = GetAbilityName(id); local abilityIcon = GetAbilityIcon(id); if not abilityName or abilityName == "" then abilityName = "Unknown Buff "..tostring(id) end; if not abilityIcon or abilityIcon == "" then abilityIcon = "EsoUI/Art/icons/icon_missing.dds" end; DTT.BUFF_DATA[id] = { name = abilityName, icon = abilityIcon }; end else DTT:PrintDebug("Error: DTT.BUFF_IDS is nil or not a table.") end;
    if _G["DTT_GUI_CreateTrackerWindow"] then local s,e=pcall(DTT_GUI_CreateTrackerWindow); if not(s and DTT.trackerWindow) then DTT:PrintDebug("!!! GUI Fail: "..tostring(e)); DTT.trackerWindow=nil end else DTT:PrintDebug("!!! ERR: DTT_GUI_CreateTrackerWindow not found!") end;
    if DTT.trackerWindow then DTT.trackerWindowFragment = ZO_HUDFadeSceneFragment:New(DTT.trackerWindow); DTT.isFragmentAdded = false; else DTT.trackerWindowFragment = nil; DTT:PrintDebug("!!! Fragment creation skipped - window missing.") end
    if _G["DTT_CreateSettingsMenu"] then local s,e=pcall(DTT_CreateSettingsMenu); if not(s and DTT.settingsPanel) then DTT:PrintDebug("!!! Settings Fail: "..tostring(e)); DTT.settingsPanel=nil end else DTT:PrintDebug("!!! ERR: DTT_CreateSettingsMenu not found!") end;
    EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_EFFECT_CHANGED, DTT.OnEffectChanged); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG,"player");
    EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_PLAYER_COMBAT_STATE, DTT.OnCombatStateChanged);
    if not IsUnitInCombat("player") then EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DTT.OnEquipChange); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false); EVENT_MANAGER:AddFilterForEvent(DTT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON , INVENTORY_UPDATE_REASON_DEFAULT); end;
    EVENT_MANAGER:RegisterForEvent(DTT.name .. "_PlayerDamage", EVENT_COMBAT_EVENT, DTT.OnPlayerDamageDealt); EVENT_MANAGER:AddFilterForEvent(DTT.name .. "_PlayerDamage", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER);
    EVENT_MANAGER:RegisterForUpdate(DTT.name.."Update", 100, DTT.OnUpdate);

    DTT.hasInitialized=true;
    DTT:UpdateDaedricTrickeryPieceCount();
    if DTT.trackerWindowFragment then DTT:UpdateFragmentVisibility() else DTT:PrintDebug("!!! Skipping initial visibility - fragment missing.") end
    DTT:PrintDebug("DaedricTrickeryTracker Initialized.")
end

function DTT_SlashCommand(args) if LibAddonMenu2 and DTT.settingsPanel then LibAddonMenu2:OpenToPanel(DTT.settingsPanel); else d("Error opening settings: LAM2/Panel not loaded.") end end
SLASH_COMMANDS["/dtt"] = DTT_SlashCommand
EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)