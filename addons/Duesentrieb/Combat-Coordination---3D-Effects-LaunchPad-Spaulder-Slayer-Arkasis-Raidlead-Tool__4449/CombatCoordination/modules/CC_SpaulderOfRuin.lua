local CC = CombatCoordination
local LUT = CC.LUT.SPAULDER_OF_RUIN

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SpaulderOfRuin",
    menuName  = "SPAULDER OF RUIN",
    iconPath  = "/esoui/art/icons/gear_razorhorndaedric_shoulder_a.dds",
    menuLayer = 1,

    KickedPlayers = {},

    GroupChoices = { GetUnitDisplayName("player") },
    GroupValues = { "player" },
    menuTargetUnitTag = "player",
    menuTargetAction = true,

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

    newProfileName = "",

    Default = {
        enableModule = true,
        enableWarning = true,
        warningOnlyInstance = false,
        activeProfile = "Default",
        Profiles = {
            ["Default"] = {},
        },
        hasAutoCreatedProfile = false,
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
-- GET PROFILE LIST
----------------------------------------------------------------------------------------------------
function Module:GetProfileList()
    if not self.SV.hasAutoCreatedProfile then
        local displayName, groupName = GetUnitDisplayName("player"), nil

        if displayName == "@Duesentrieb" then
            groupName = "Worst Group Ever"
        elseif displayName == "@NeuronixX" or displayName == "@Kwiebe-Kwibus" then
            groupName = "Core Coordination"
        elseif displayName == "@Isiiimode" then
            groupName = "Unlucky"
        end

        if groupName then
            if not self.SV.Profiles[groupName] then
                self.SV.Profiles[groupName] = {}
            end
            self.SV.activeProfile = groupName
            zo_callLater(function()
                d(string.format("%s |c00FF00Welcome %s! Spaulder Profile: [%s]|r", CC.CHAT, displayName, groupName))
            end, 5000)
        end

        self.SV.hasAutoCreatedProfile = true
    end

    local ProfileList = {}
    for profileName, _ in pairs(self.SV.Profiles) do
        table.insert(ProfileList, profileName)
    end
    table.sort(ProfileList)
    return ProfileList
end

----------------------------------------------------------------------------------------------------
-- CYCLE PROFILES (PANEL LEFT RIGHT BUTTONS)
----------------------------------------------------------------------------------------------------
function Module:CycleProfile(action)
    local Profiles = self:GetProfileList()
    local currentIndex = 1

    for i, profileName in ipairs(Profiles) do
        if profileName == self.SV.activeProfile then
            currentIndex = i
            break
        end
    end

    if action == "FIRST" then
        currentIndex = 1
    elseif action == "LAST" then
        currentIndex = #Profiles
    else
        currentIndex = currentIndex + action
        if currentIndex > #Profiles then currentIndex = 1 end
        if currentIndex < 1 then currentIndex = #Profiles end
    end

    self.SV.activeProfile = Profiles[currentIndex]

    if CC_SpaulderOfRuin_ProfileDropdown then
        CC_SpaulderOfRuin_ProfileDropdown:UpdateValue()
    end
    if CC.DisplayPanel.SV.isVisible then
        CC.DisplayPanel:UpdateData()
    end
end

----------------------------------------------------------------------------------------------------
-- SAVE / UNSAVE
----------------------------------------------------------------------------------------------------
function Module:TogglePlayerInProfile(playerName, selectedRole)
    local Profile = self.SV.Profiles[self.SV.activeProfile]
    if Profile[playerName] == selectedRole then
        Profile[playerName] = nil
    else
        Profile[playerName] = selectedRole
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
    local Profile = self.SV.Profiles[self.SV.activeProfile]

    local playerRole = GetSelectedLFGRole()
    if not playerRole or playerRole == 0 then playerRole = LFG_ROLE_DPS end

    -- ROLE CHECK
    if not Profile[playerName] or Profile[playerName] ~= playerRole then
        Profile[playerName] = playerRole
        d(string.format("%s Auto-added yourself to [SOR] profile: %s.", CC.CHAT, self.SV.activeProfile))

        if CC.DisplayPanel.SV.isVisible then
            CC.DisplayPanel:UpdateData()
        end
    end

    local counterSave = 0
    for _ in pairs(Profile) do counterSave = counterSave + 1 end

    if counterSave <= 1 then
        d(string.format("%s You are the only [SOR] player in this profile.", CC.CHAT))
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
    local Profile = self.SV.Profiles[self.SV.activeProfile]

    local counterGroupKick = 0
    for i = 1, GetGroupSize() do
        local unitTag = "group" .. i
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" and IsUnitOnline(unitTag) then
            local currentRole = GetGroupMemberSelectedRole(unitTag) or LFG_ROLE_DPS
            local savedRole = Profile[displayName]

            -- KICK IF NOT SAVED OR SAVED AS DIFF ROLE
            if not savedRole or savedRole ~= currentRole then
                table.insert(self.KickedPlayers, displayName)
                GroupKickByName(displayName)
                counterGroupKick = counterGroupKick + 1
            end
        end
    end

    if counterGroupKick > 0 then
        d(string.format("%s Kicked %d members.", CC.CHAT, counterGroupKick))
        zo_callLater(function() self:Reinvite() end, 1000)
    else
        d(string.format("%s Nobody to kick based on active profile.", CC.CHAT))
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
            local groupTag = "group" .. i
            if GetUnitDisplayName(groupTag) == self.originalLeaderName then
                targetTag = groupTag
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
    if not LibCustomMenu then return end
    if not Data or not Data.displayName then return end

    local unitTag = nil
    local targetName = Data.displayName

    for i = 1, GetGroupSize() do
        local groupTag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(groupTag) == targetName or GetRawUnitName(groupTag) == targetName then
            unitTag = groupTag
            break
        end
    end

    if not unitTag and (GetUnitDisplayName("player") == targetName or GetRawUnitName("player") == targetName) then
        unitTag = "player"
    end

    if not unitTag then return end

    local selectedRole = AreUnitsEqual(unitTag, "player") and GetSelectedLFGRole() or GetGroupMemberSelectedRole(unitTag)
    if not selectedRole or selectedRole == 0 then selectedRole = LFG_ROLE_DPS end

    local Profile = self.SV.Profiles[self.SV.activeProfile]
    local menuIcon = string.format("|t%d:%d:%s|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM, self.iconPath)

    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] Spaulder Of Ruin", "tier2"), {
        {
            label = "Add to Stack [SOR]",
            callback = function()
                Profile[targetName] = selectedRole
                local playerLink = CC.GetPlayerLinkFromDisplayName(targetName) or targetName
                d(string.format("%s Added %s to Spaulder stack (%s).", CC.CHAT, playerLink, self.SV.activeProfile))
                if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            end,
        },
        {
            label = "Remove from Stack",
            callback = function()
                Profile[targetName] = nil
                local playerLink = CC.GetPlayerLinkFromDisplayName(targetName) or targetName
                d(string.format("%s Removed %s from Spaulder stack (%s).", CC.CHAT, playerLink, self.SV.activeProfile))
                if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            end,
        }
    })
end

----------------------------------------------------------------------------------------------------
-- ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    -- MIGRATE OLD DATA
    if self.SV.SavedPlayers then
        for playerName, _ in pairs(self.SV.SavedPlayers) do
            self.SV.Profiles["Default"][playerName] = LFG_ROLE_DPS
        end
        self.SV.SavedPlayers = nil
    end

--     -- NEURONIXX
--     if not self.SV.hasAutoCreatedProfile then
--         local displayName, groupName = GetUnitDisplayName("player"), nil

--         if displayName == "@Duesentrieb" then
--             groupName = "Worst Group Ever"
--             if not self.SV.Profiles[groupName] then
--                 self.SV.Profiles[groupName] = {}
--                 self.SV.activeProfile = groupName
--             end
--         end
--         if displayName == "@NeuronixX" then
--             groupName = "Core Coordination"
--             if not self.SV.Profiles[groupName] then
--                 self.SV.Profiles[groupName] = {}
--                 self.SV.activeProfile = groupName
--             end
--         end
--         if displayName == "@Kwiebe-Kwibus" then
--             groupName = "Core Coordination"
--             if not self.SV.Profiles[groupName] then
--                 self.SV.Profiles[groupName] = {}
--                 self.SV.activeProfile = groupName
--             end
--         end
--         if displayName == "@Isiiimode" then
--             groupName = "Unlucky"
--             if not self.SV.Profiles[groupName] then
--                 self.SV.Profiles[groupName] = {}
--                 self.SV.activeProfile = groupName
--             end
--         end

--         if groupName then
--             self.SV.Profiles[groupName] = {}
--             self.SV.activeProfile = groupName

--             zo_callLater(function()

-- d("REFRESH CC_SpaulderOfRuin_ProfileDropdown")

--                 if CC_SpaulderOfRuin_ProfileDropdown then
-- d("CC_SpaulderOfRuin_ProfileDropdown:UpdateChoices(self:GetProfileList())")
--                     CC_SpaulderOfRuin_ProfileDropdown:UpdateChoices(self:GetProfileList())
--                     CC_SpaulderOfRuin_ProfileDropdown:UpdateValue()
--                 end
--             end, 5000)

--             zo_callLater(function()
--                 d(string.format("%s |c00FF00Welcome %s! Spaulder Profile: [%s]|r", CC.CHAT, displayName, groupName))
--             end, 5000)
--         end

--         -- /script CombatCoordination.SpaulderOfRuin.SV.hasAutoCreatedProfile = false
--         self.SV.hasAutoCreatedProfile = true
--     end

    if LibCustomMenu then
        LibCustomMenu:RegisterGroupListContextMenu(function(Data) self:OnContextMenu(Data) end, LibCustomMenu.CATEGORY_LATE)
    end

    for abilityName, AbilityIds in pairs(self.Skills) do
        for _, abilityId in ipairs(AbilityIds) do
            EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_COMBAT_EVENT" .. tostring(abilityId), EVENT_COMBAT_EVENT)

            local eventName = CC.NAME .. "SpaulderOfRuin" .. "EVENT_COMBAT_EVENT" .. tostring(abilityId)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) self:HandleCombatEvent(...) end)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
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
        name = function()
            local stringEnable = self.SV.enableModule and "" or CC.ColorString("[OFF] ", "RD")
            return string.format("%s %s%s %s", menuIcon, stringEnable, CC.ColorString(self.menuName, "tier2"), CC.ColorString("[LGB]", "GN"))
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
                text = CC.ColorString("How to use the Spaulder Kick:", "tier2") .. "\n" ..
                       "1. Click on names in the panel to add them to your " .. CC.ColorString("[SOR]", "tier3") .. " list.\n" ..
                       "2. Alternatively, use the right-click context menu in the group window.\n" ..
                       "3. Your " .. CC.ColorString("[SOR]", "tier3") .. " list is saved permanently.\n" ..
                       "4. Press " .. CC.ColorString("[KICK & INVITE]", "tier3") .. " to kick unsaved members and auto-reinvite them.\n" ..
                       "5. The addon automatically requests the crown to execute the kick.\n" ..
                       "6. If the leader uses CC, the crown is passed and returned automatically.\n" ..
                       "7. Use " .. CC.ColorString("[REINVITE]", "tier3") .. " only as a manual fallback if auto-invites fail.",
                width = "full",
            },

            { type = "header", name = CC.ColorString("MANUAL CONTROLS", "tier3") },
            {
                type = "button",
                name = "KICK & INVITE",
                func = function() self:KickAndReinvite() end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "button",
                name = "REINVITE",
                func = function() self:Reinvite() end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },

            { type = "header", name = CC.ColorString("PROFILES", "tier3") },
            {
                type = "dropdown",
                name = "Active Profile",
                choices = self:GetProfileList(),
                getFunc = function() return self.SV.activeProfile end,
                setFunc = function(value)
                    self.SV.activeProfile = value
                    if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
                end,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
                reference = "CC_SpaulderOfRuin_ProfileDropdown",
            },
            {
                type = "editbox",
                name = "New Profile Name",
                getFunc = function() return self.newProfileName end,
                setFunc = function(value) self.newProfileName = value end,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "button",
                name = CC.ColorString("DELETE CURRENT", "RD"),
                func = function()
                    if self.SV.activeProfile ~= "Default" then
                        self.SV.Profiles[self.SV.activeProfile] = nil
                        self.SV.activeProfile = "Default"
                        if CC_SpaulderOfRuin_ProfileDropdown then
                            CC_SpaulderOfRuin_ProfileDropdown:UpdateChoices(self:GetProfileList())
                            CC_SpaulderOfRuin_ProfileDropdown:UpdateValue()
                        end
                        if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
                    else
                        d(string.format("%s Cannot delete Default profile.", CC.CHAT))
                    end
                end,
                width = "half",
                disabled = function() return self.SV.activeProfile == "Default" or not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "button",
                name = CC.ColorString("SAVE NEW PROFILE", "GN"),
                func = function()
                    local pName = self.newProfileName
                    if pName and pName ~= "" then
                        if not self.SV.Profiles[pName] then
                            self.SV.Profiles[pName] = {}
                        end
                        self.SV.activeProfile = pName
                        self.newProfileName = ""
                        if CC_SpaulderOfRuin_ProfileDropdown then
                            CC_SpaulderOfRuin_ProfileDropdown:UpdateChoices(self:GetProfileList())
                            CC_SpaulderOfRuin_ProfileDropdown:UpdateValue()
                        end
                        if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },

            ----------------------------------------------------------------------------------------------------
            -- TARGETED ASSIGNMENT
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("SPAULDER ASSIGNMENT", "tier3") },
            {
                type = "description",
                text = CC.ColorString("Tip:", "tier2") .. " Assign group members via CC panel or context menu.",
                width = "full",
            },
            {
                type = "dropdown",
                name = "Choose Group Member",
                choices = self.GroupChoices,
                choicesValues = self.GroupValues,
                getFunc = function() return self.menuTargetUnitTag end,
                setFunc = function(value) self.menuTargetUnitTag = value end,
                reference = "CC_SpaulderOfRuin_Dropdown_GroupMember",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "dropdown",
                name = "Choose Action",
                choices = { "Add to Profile", "Remove from Profile" },
                choicesValues = { true, false },
                getFunc = function() return self.menuTargetAction end,
                setFunc = function(value) self.menuTargetAction = value end,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "button",
                name = "REFRESH LIST",
                func = function()
                    ZO_ClearTable(self.GroupChoices)
                    ZO_ClearTable(self.GroupValues)

                    table.insert(self.GroupChoices, GetUnitDisplayName("player"))
                    table.insert(self.GroupValues, "player")

                    if GetGroupSize() > 0 then
                        for i = 1, GetGroupSize() do
                            local unitTag = "group" .. i
                            if not AreUnitsEqual("player", unitTag) then
                                local displayName = GetUnitDisplayName(unitTag)
                                if displayName and displayName ~= "" then
                                    table.insert(self.GroupChoices, displayName)
                                    table.insert(self.GroupValues, unitTag)
                                end
                            end
                        end
                    end

                    self.menuTargetUnitTag = "player"

                    if CC_SpaulderOfRuin_Dropdown_GroupMember then
                        CC_SpaulderOfRuin_Dropdown_GroupMember:UpdateChoices(self.GroupChoices, self.GroupValues)
                        CC_SpaulderOfRuin_Dropdown_GroupMember:UpdateValue()
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "button",
                name = "SAVE ACTION",
                func = function()
                    if self.menuTargetUnitTag then
                        local displayName = GetUnitDisplayName(self.menuTargetUnitTag)
                        if not displayName or displayName == "" then return end

                        local Profile = self.SV.Profiles[self.SV.activeProfile]

                        if self.menuTargetAction then
                            local selectedRole = AreUnitsEqual(self.menuTargetUnitTag, "player") and GetSelectedLFGRole() or GetGroupMemberSelectedRole(self.menuTargetUnitTag)
                            if not selectedRole or selectedRole == 0 then selectedRole = LFG_ROLE_DPS end

                            Profile[displayName] = selectedRole
                            d(string.format("%s Added %s to Spaulder stack (%s).", CC.CHAT, displayName, self.SV.activeProfile))
                        else
                            Profile[displayName] = nil
                            d(string.format("%s Removed %s from Spaulder stack (%s).", CC.CHAT, displayName, self.SV.activeProfile))
                        end

                        if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },

            { type = "header", name = CC.ColorString("SPAULDER WARNING", "tier3") },
            {
                type = "description",
                text = "Displays a warning when wearing Spaulder without active aura.",
                width = "full",
            },
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
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
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
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or not self.SV.enableWarning end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)