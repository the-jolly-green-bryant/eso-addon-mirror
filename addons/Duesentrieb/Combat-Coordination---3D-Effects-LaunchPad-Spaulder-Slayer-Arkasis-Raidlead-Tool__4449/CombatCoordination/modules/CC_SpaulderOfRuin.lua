local CC = CombatCoordination
local LUT = CC.LUT.SPAULDER_OF_RUIN

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SpaulderOfRuin",
    menuName  = "SPAULDER OF RUIN",
    iconPath  = "/esoui/art/icons/gear_razorhorndaedric_shoulder_a.dds",
    menuLayer = 0,

    KickedPlayers = {},

    Broadcast = {
        LUT.SPAULDER_REQUEST,
    },

    Skills = {
        ["Aura of Pride"] = { 163359 },
    },

    isEquipped = false,
    isActive = false,
    isWarningActive = false,

    originalLeaderName = nil,
    crownReturnTime = 0,
    kickRequestTimeout = 0,
    pendingKick = false,

    Default = {
        enableWarning = true,
        warningOnlyInstance = false,
        SavedPlayers = {},
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- SPAULDER WARNING
----------------------------------------------------------------------------------------------------
function Module:GetWarningState()
    if not self.SV.enableWarning then
        self:SetWarningActive(false)
        return
    end

    if self.SV.warningOnlyInstance and not IsUnitInDungeon("player") then
        self:SetWarningActive(false)
        return
    end

    local shouldWarn = (self.isEquipped and not self.isActive)
    self:SetWarningActive(shouldWarn)
end

function Module:SetWarningActive(state)
    if self.isWarningActive == state then return end
    self.isWarningActive = state

    if state then
        EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "DisplayNotification_UpdateLoop", 100, function() CC.DisplayNotification:UpdateTick() end)
    end
    CC.DisplayNotification:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- CHECK GEAR
----------------------------------------------------------------------------------------------------
function Module:CheckGear()
    self.isEquipped = CC.GetPlayerSetStatus("SPAULDER") == 1
    if not self.isEquipped then self.isActive = false end

    self:GetWarningState()
end

----------------------------------------------------------------------------------------------------
-- DEATH STATE CHANGED
----------------------------------------------------------------------------------------------------
function Module:OnDeathStateChanged(eventCode, unitTag, isDead)
    if isDead and AreUnitsEqual(unitTag, "player") then
        self.isActive = false
        self:GetWarningState()
    end
end

----------------------------------------------------------------------------------------------------
-- COMBAT EVENT
----------------------------------------------------------------------------------------------------
function Module:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_EFFECT_GAINED then
        self.isActive = true
    elseif result == ACTION_RESULT_EFFECT_FADED then
        self.isActive = false
    end
    self:GetWarningState()
end

----------------------------------------------------------------------------------------------------
-- BUFF?
----------------------------------------------------------------------------------------------------
function Module:HasAuraOfPride(unitTag)
    if AreUnitsEqual(unitTag, "player") and self.isActive then
        return true
    end

    local numBuffs = GetNumBuffs(unitTag)
    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        if abilityId == 163359 or abilityId == 163401 then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------------------------------
-- KICK AND REINVITE REQUEST
----------------------------------------------------------------------------------------------------
function Module:KickAndReinvite()
    local playerName = GetUnitDisplayName("player")

    if not self.SV.SavedPlayers[playerName] then
        self.SV.SavedPlayers[playerName] = true
        d(string.format("%s Auto-added yourself to the [SOR] list.", CC.CHAT))

        if CC.DisplayPanel.SV.isVisible then
            CC.DisplayPanel:UpdateData()
        end
    end

    local counterSave = 0
    for _ in pairs(self.SV.SavedPlayers) do counterSave = counterSave + 1 end

    if counterSave <= 1 then
        d(string.format("%s You are the only [SOR] player.", CC.CHAT))
        return
    end

    if IsUnitGroupLeader("player") then
        self:ExecuteKick()
    else
        local currentLeaderTag = GetGroupLeaderUnitTag()
        if currentLeaderTag and currentLeaderTag ~= "" then
            self.originalLeaderName = GetUnitDisplayName(currentLeaderTag)
            self.kickRequestTimeout = GetGameTimeSeconds() + 5
        self.crownReturnTime = GetGameTimeSeconds() + 30
            self.pendingKick = true

            EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "SpaulderOfRuin_GroupLeader_Loop", 1000, function() self:GroupLeaderLoop() end)

            local Data = { ID = LUT.SPAULDER_REQUEST, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 1 }
            CC.Broadcast:Send(Data)

            local playerLink = CC.GetPlayerLinkFromDisplayName(self.originalLeaderName) or self.originalLeaderName
            d(string.format("%s Requesting crown from: %s", CC.CHAT, playerLink))
        else
            d(string.format("%s %s", CC.CHAT, CC.ColorString("You are not grouped.", "RD")))
        end
    end
end

----------------------------------------------------------------------------------------------------
-- EXECUTE KICK
----------------------------------------------------------------------------------------------------
function Module:ExecuteKick()
    ZO_ClearTable(self.KickedPlayers)

    local counterGroupKick = 0
    for i = 1, GetGroupSize() do
        local unitTag = "group" .. i
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" and not self.SV.SavedPlayers[displayName] and IsUnitOnline(unitTag) then
            table.insert(self.KickedPlayers, displayName)
            GroupKickByName(displayName)
            counterGroupKick = counterGroupKick + 1
        end
    end

    if counterGroupKick > 0 then
        d(string.format("%s Kicked %d members.", CC.CHAT, counterGroupKick))
        zo_callLater(function() self:Reinvite() end, 1000)
    else
        d(string.format("%s Nobody to kick based on saved list.", CC.CHAT))
    end
end

----------------------------------------------------------------------------------------------------
-- MANUAL REINVITE
----------------------------------------------------------------------------------------------------
function Module:Reinvite()
    if not IsUnitGroupLeader("player") then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Group leader status required.", "RD")))
        return
    end

    if self.originalLeaderName then
        self.crownReturnTime = GetGameTimeSeconds() + 15
    end

    if #self.KickedPlayers == 0 then
        d(string.format("%s No members in kick-list to reinvite.", CC.CHAT))
        return
    end

    for _, displayName in ipairs(self.KickedPlayers) do
        GroupInviteByName(displayName)
    end
    d(string.format("%s Reinvite sent to %d members.", CC.CHAT, #self.KickedPlayers))
end

----------------------------------------------------------------------------------------------------
-- LOOP: RETURN CROWN & TIMEOUT
----------------------------------------------------------------------------------------------------
function Module:GroupLeaderLoop()
    if not IsUnitGrouped("player") then
        self.originalLeaderName = nil
        self.pendingKick = false
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "SpaulderOfRuin_GroupLeader_Loop")
        return
    end

    local currentTime = GetGameTimeSeconds()

    -- NOT YET LEADER? WAIT (OR TIMEOUT.. :/)
    if not IsUnitGroupLeader("player") then
        if self.pendingKick and currentTime > self.kickRequestTimeout then
            d(string.format("%s %s", CC.CHAT, CC.ColorString("Crown request timed out.", "RD")))
            self.originalLeaderName = nil
            self.pendingKick = false
            EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "SpaulderOfRuin_GroupLeader_Loop")
        end
        return
    end

    -- JUST GOT LEADER AND (!) PENDING KICK?
    if self.pendingKick then
        self.pendingKick = false
        self:ExecuteKick()
        return
    end

    -- I'M LEADER. SHOULD RETURN IT?
    local isTimeToReturn = false

    if currentTime > self.crownReturnTime then
        isTimeToReturn = true
    elseif #self.KickedPlayers > 0 then
        -- CHECK IF ALL KICKED PLAYERS ARE BACK
        local allGroupMemberBack = true
        for _, displayName in ipairs(self.KickedPlayers) do
            local foundGroupMember = false
            for i = 1, GetGroupSize() do
                if GetUnitDisplayName("group" .. i) == displayName then
                    foundGroupMember = true
                    break
                end
            end
            if not foundGroupMember then
                allGroupMemberBack = false
                break
            end
        end
        if allGroupMemberBack then isTimeToReturn = true end
    end

    if isTimeToReturn then
        local targetTag = nil
        for i = 1, GetGroupSize() do
            local tag = "group" .. i
            if GetUnitDisplayName(tag) == self.originalLeaderName then
                targetTag = tag
                break
            end
        end

        if targetTag and IsUnitOnline(targetTag) then
            GroupPromote(targetTag)
            local playerLink = CC.GetPlayerLinkFromDisplayName(self.originalLeaderName) or self.originalLeaderName
            d(string.format("%s Returned crown to %s.", CC.CHAT, playerLink))
        else
            d(string.format("%s Original leader offline or left.", CC.CHAT))
        end

        self.originalLeaderName = nil
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "SpaulderOfRuin_GroupLeader_Loop")
    end
end

----------------------------------------------------------------------------------------------------
-- BROADCAST INCOMING (CROWN REQUEST)
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if Data.ID == LUT.SPAULDER_REQUEST then
        if IsUnitGroupLeader("player") and not AreUnitsEqual(unitTag, "player") then
            local senderName = GetUnitDisplayName(unitTag)
            if not senderName or senderName == "" then senderName = GetRawUnitName(unitTag) end
            GroupPromote(unitTag)
            local playerLink = CC.GetPlayerLinkFromDisplayName(senderName) or senderName
            d(string.format("%s Passed crown to %s for Spaulder Kick.", CC.CHAT, playerLink))
        end
    end
end

----------------------------------------------------------------------------------------------------
-- CONTEXT MENU (LIBCUSTOMMENU)
----------------------------------------------------------------------------------------------------
function Module:OnContextMenu(Data)
    if not LibCustomMenu or not Data or not Data.displayName then return end
    if not CC.IsRaidlead() and IsUnitGrouped("player") then return end

    local unitTag = nil
    local targetName = Data.displayName

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(tag) == targetName or GetRawUnitName(tag) == targetName then
            unitTag = tag
            break
        end
    end

    if not unitTag and (GetUnitDisplayName("player") == targetName or GetRawUnitName("player") == targetName) then
        unitTag = "player"
    end

    if not unitTag then return end

    local menuIcon = string.format("|t%d:%d:%s|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM, self.iconPath)

    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] Spaulder Of Ruin", "tier2"), {
        {
            label = "Add to Stack [SOR]",
            callback = function()
                self.SV.SavedPlayers[targetName] = true
                local playerLink = CC.GetPlayerLinkFromDisplayName(targetName) or targetName
                d(string.format("%s Added %s to Spaulder stack.", CC.CHAT, playerLink))
                if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            end,
        },
        {
            label = "Remove from Stack",
            callback = function()
                self.SV.SavedPlayers[targetName] = nil
                local playerLink = CC.GetPlayerLinkFromDisplayName(targetName) or targetName
                d(string.format("%s Removed %s from Spaulder stack.", CC.CHAT, playerLink))
                if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            end,
        }
    })
end

----------------------------------------------------------------------------------------------------
-- ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    for abilityName, AbilityIds in pairs(self.Skills) do
        for _, abilityId in ipairs(AbilityIds) do
            EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_COMBAT_EVENT" .. tostring(abilityId), EVENT_COMBAT_EVENT)

            local eventName = CC.NAME .. "SpaulderOfRuin" .. "EVENT_COMBAT_EVENT" .. tostring(abilityId)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) self:HandleCombatEvent(...) end)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
    end

    -- YEAH YEAH I KNOW.. LIBCUSTOMMENU IS IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if LibCustomMenu then
        LibCustomMenu:RegisterGroupListContextMenu(function(Data) self:OnContextMenu(Data) end, LibCustomMenu.CATEGORY_LATE)
    end

    -- MANUAL SYNC ON LOAD
    zo_callLater(function() self:CheckGear() end, 2500)
end

function Module:CustomDisable()
    for abilityName, AbilityIds in pairs(self.Skills) do
        for _, abilityId in ipairs(AbilityIds) do
            local eventName = CC.NAME .. "SpaulderOfRuin" .. "EVENT_COMBAT_EVENT" .. tostring(abilityId)
            EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
        end
    end
    self:SetWarningActive(false)
end

----------------------------------------------------------------------------------------------------
-- LAM2 MENU
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s %s", menuIcon, CC.ColorString(self.menuName, "tier2"), CC.ColorString("[LGB]", "GN")),
        controls = {
            { type = "header", name = CC.ColorString("SPAULDER WARNING", "tier3") },
            {
                type = "checkbox",
                name = "Enable Inactive Warning",
                tooltip = "Displays a persistent warning if you are wearing Spaulder of Ruin but have forgotten to activate the aura.",
                getFunc = function() return self.SV.enableWarning end,
                setFunc = function(value)
                    self.SV.enableWarning = value
                    self:GetWarningState()
                end,
                default = self.Default.enableWarning,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "checkbox",
                name = "Only Warning in Instances",
                tooltip = "Suppresses the inactive warning in overland zones.",
                getFunc = function() return self.SV.warningOnlyInstance end,
                setFunc = function(value)
                    self.SV.warningOnlyInstance = value
                    self:GetWarningState()
                end,
                default = self.Default.warningOnlyInstance,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableWarning end,
            },
            { type = "header", name = CC.ColorString("MANUAL CONTROLS", "tier3") },
            {
                type = "button",
                name = "KICK & INVITE",
                func = function() self:KickAndReinvite() end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "REINVITE",
                func = function() self:Reinvite() end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)