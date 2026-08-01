GuardStatus = {}
local GuardStatus = GuardStatus

local GUARD_STATUS_NONE    = 0
local GUARD_STATUS_DROPPED = 1
local GUARD_STATUS_LOST    = 2
local GUARD_STATUS_UP      = 3
local GUARD_STATUS_GUARDED = 4

local TIME_TO_RESET = 10000
local BLINK_FREQUENCY = 250

GuardStatus.name = "GuardStatus"
GuardStatus.version = "1.2.1"

GuardStatus.accountWideDefaults = {
    accountWide = true,
}

GuardStatus.defaults = {
    offsetX = 200,
    offsetY = 200,
    showIcon = true,
    bothBarsRequired = false,
    useAccountName = false,
	blinking = true,
}


local guardAbilityIds = {
	-- Activation skills
    [61511] = "Guard", 						  -- Guard
    [61529] = "Stalwart Guard", 			  -- Stalwart Guard
    [61536] = "Mystic Guard", 				  -- Mystic Guard
	
	-- Cancel skills (player)
    [78338] = "Cancel Guard, Guard", 		  -- Cancel Guard, Guard
    [81415] = "Cancel Guard, Mythic Guard",   -- Cancel Guard, Mythic Guard
    [81420] = "Cancel Guard, Stalwart Guard", -- Cancel Guard, Stalwart Guard
	
	-- Cancel skills (game)
	[80923] = "Guard ",				  		  -- Cancel Guard, Guard			Autocast, game internal
	[80947] = "Stalwart Guard",				  -- Cancel Guard, Mythic Guard		Autocast, game internal
	[80983] = "Mystic Guard",				  -- Cancel Guard, Stalwart Guard   Autocast, game internal
}

local function IsGuardAbility(abilityId)
	return guardAbilityIds[abilityId] ~= nil, guardAbilityIds[abilityId]
end

local function HasGuardSkillEquipped(bothBarsRequired)
    local hasGuardFrontbar = false
    local hasGuardBackbar = false
    for hotbarSlot = 2, 7 do
        if IsGuardAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
            hasGuardFrontbar = true
        end 
        if IsGuardAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
            hasGuardBackbar = true
        end
    end
    
    if bothBarsRequired then
        return hasGuardFrontbar and hasGuardBackbar
    else
        return hasGuardFrontbar or hasGuardBackbar
    end
end

local function TryGetDisplayName(rawName)
    local name = rawName
    -- Group members
    for i = 1, GetGroupSize() do
        if GetRawUnitName("group"..i) == rawName then
            name = GetUnitDisplayName("group"..i)
        end
    end
    
    -- Reticle target
    if GetRawUnitName("reticleover") == rawName then
        name = GetUnitDisplayName("reticleover")
    end
    return name, name ~= rawName
end

-- Addon menu
local function InitializeAddonMenu()
    local panelData = {
		type = "panel",
		name = "Guard Status",
		displayName = "Guard Status",
		author = "MrPikPik",
		version = GuardStatus.version,
		website = 'https://www.esoui.com/downloads/info3024-GuardStatus.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Guard Status'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForRefresh = true,
		registerForDefaults = true
	}

	
	local optionsData = {}

    
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(GS_OPTIONS_DESCRIPTION),
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(GS_OPTIONS_HEADER),
	})
    
    -- Account wide setting
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(GS_OPTIONS_ACCOUNTWIDE_SETTINGS),
		requiresReload = true,
		default = GuardStatus.accountWideDefaults.accountWide,
		getFunc = function() return GuardStatus.DS.accountWide end,
		setFunc = function(newValue) GuardStatus.DS.accountWide = newValue end,
	}) 

    -- Divider
    table.insert(optionsData, {
		type = "divider",
	})
    
    -- Require both bars
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(GS_BOTH_BARS_REQUIRED),
		tooltip = GetString(GS_BOTH_BARS_REQUIRED_TT),
		default = GuardStatus.defaults.bothBarsRequired,
		getFunc = function() return GuardStatus.SV.bothBarsRequired end,
		setFunc = function(newValue)
            GuardStatus.SV.bothBarsRequired = newValue
        end,
	})
    
    -- Try to use account name
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(GS_USE_ACCOUNT_NAME),
		tooltip = GetString(GS_USE_ACCOUNT_NAME_TT),
		default = GuardStatus.defaults.useAccountName,
		getFunc = function() return GuardStatus.SV.useAccountName end,
		setFunc = function(newValue)
            GuardStatus.SV.useAccountName = newValue
        end,
	})
	
	-- Blinking loss
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(GS_BLINKING_LOSS),
		tooltip = GetString(GS_BLINKING_LOSS_TT),
		default = GuardStatus.defaults.blinking,
		getFunc = function() return GuardStatus.SV.blinking end,
		setFunc = function(newValue)
            GuardStatus.SV.blinking = newValue
        end,
	})
    
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(GuardStatus.name .. "SettingsMenu", panelData)
	LibAddonMenu2:RegisterOptionControls(GuardStatus.name .. "SettingsMenu", optionsData)
end



local GuardStatusWidget = ZO_Object:Subclass()

function GuardStatusWidget:New(control)
	local obj = ZO_Object.New(self)
	obj:Initialize(control)
	return obj
end

function GuardStatusWidget:Initialize(control)
	self.control = control
	self.icon = control:GetNamedChild("Icon")
    self.desc = control:GetNamedChild("Desc")
	self.text = control:GetNamedChild("Text")
 
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GuardStatus.SV.offsetX, GuardStatus.SV.offsetY)

	self.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("GuardStatusAnimation", control)
	self.fadeOutDelay = 0
	

    self.target = ""
    self.ability = 0
    self.dropped = false
    self.status = GUARD_STATUS_NONE
	self.lastTarget = ""


	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_COMBAT_EVENT, function(_, result, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, _, _, abilityId)
		self:CombatEvent(result, sourceName, targetName, abilityId)
	end)	
	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_ABILITY_LIST_CHANGED, function() self:UpdateContextualFading() end)
    EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_SKILL_RESPEC_RESULT,  function() self:UpdateContextualFading() end)
	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:UpdateContextualFading() end)
	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_ACTION_SLOT_ABILITY_USED, function(event, slotIndex) self:OnSkillCast(slotIndex) end)
	
	-- Blinking update
	local switch = true
	local function Blink()
		if self.status == GUARD_STATUS_LOST and GuardStatus.SV.blinking then
			switch = not switch
			self.icon:SetTexture(switch and "EsoUI/Art/ActionBar/abilityInset.dds" or GetAbilityIcon(81415)) -- 81415 = Cancel Guard Skill Icon
		end
	end
	EVENT_MANAGER:RegisterForUpdate(control:GetName() .. "FadeUpdate", BLINK_FREQUENCY, Blink)
	
	self:Update()
	self:UpdateContextualFading()
end

function GuardStatusWidget:CombatEvent(result, sourceName, targetName, abilityId) 
    if not (targetName == GetRawUnitName("player") or sourceName == GetRawUnitName("player")) then return end

    if result == ACTION_RESULT_EFFECT_GAINED then
        if abilityId == 61511 or abilityId == 61529 or abilityId == 61536 then
            self.dropped = false
            self.ability = abilityId
            
            if targetName == GetRawUnitName("player") then
                self.target = sourceName
				self.lastTarget = sourceName
                self.status = GUARD_STATUS_GUARDED
                self:UpdateContextualFading()
            else
                self.target = targetName
				self.lastTarget = targetName
                self.status = GUARD_STATUS_UP
				self:UpdateContextualFading()
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if abilityId == 80923 or abilityId == 80947 or abilityId == 80983 then
            self.target = ""
            self.ability = 0
            
            if self.dropped then
                self.status = GUARD_STATUS_DROPPED
            elseif targetName == GetRawUnitName("player") then
				-- Since U35, the "guard loss" is a skill cast by the game on the player, regardless the cause of loss
                self.status = GUARD_STATUS_LOST
				zo_callLater(function() self:ResetLostGuard() end, TIME_TO_RESET)
            end
        end
    end
	
	self:Update()
end

function GuardStatusWidget:OnSkillCast(slotIndex)  
    if IsGuardAbility(GetSlotBoundId(slotIndex)) then
        if self.target ~= "" then
            self.dropped = true -- Manually dropped guard by casting the cancel skill
        end
    end
end

function GuardStatusWidget:IsBeingGuarded()
    return self.status == GUARD_STATUS_GUARDED
end

function GuardStatusWidget:ResetLostGuard()
	if self.status == GUARD_STATUS_LOST then
		self.status = GUARD_STATUS_NONE
		self:Update()
		self:UpdateContextualFading()
	end
end


function GuardStatusWidget:ShouldContextuallyShow()
	if HasGuardSkillEquipped(GuardStatus.SV.bothBarsRequired) then
		return true
	end
	
	if self:IsBeingGuarded() then
		return true
	end
	
	if self.status == GUARD_STATUS_LOST then
		return true
	end
	
	return false
end

function GuardStatusWidget:UpdateContextualFading()
    local shouldContextuallyShow = self:ShouldContextuallyShow()	
    if shouldContextuallyShow ~= self.isContextuallyShown then
        if shouldContextuallyShow then
            self.timeline:PlayForward()
        else
            self.timeline:PlayBackward()
        end
        self.isContextuallyShown = shouldContextuallyShow
    end
end

function GuardStatusWidget:Update()   
    local name = zo_strformat("<<1>>", self.target)
    local texture = "EsoUI/Art/ActionBar/abilityInset.dds"
	local description = GetString(GS_NO_GUARD)
	
	local targetDisplayName = TryGetDisplayName(self.target)
	
    if self.status == GUARD_STATUS_UP then
        if GuardStatus.SV.useAccountName then
            name = zo_strformat("<<1>>", targetDisplayName)
        end
        texture = GetAbilityIcon(self.ability)
        description = GetString(GS_GUARDING)
    elseif self.status == GUARD_STATUS_GUARDED then
        if GuardStatus.SV.useAccountName then
            name = zo_strformat("<<1>>", targetDisplayName)
        end
        texture = GetAbilityIcon(self.ability)
        description = GetString(GS_GUARDED)
    elseif self.status == GUARD_STATUS_LOST then
        texture = GetAbilityIcon(81415) -- Cancel Guard Skill Icon
		description = GetString(GS_GUARD_LOST)
    end


	--if OSI then
	--	local lastTargetDisplayName, hasDisplayName = TryGetDisplayName(self.lastTarget)
	--
	--	if self.status == GUARD_STATUS_UP or self.status == GUARD_STATUS_GUARDED and hasDisplayName then
	--		OSI.SetCustomIconForUnit(lastTargetDisplayName, texture, {1, 1, 1})
	--	elseif lastTargetDisplayName ~= targetDisplayName then
	--		OSI.RemoveCustomIconFromUnit(lastTargetDisplayName)
	--	else
	--		OSI.RemoveCustomIconFromUnit(targetDisplayName)
	--	end
	--end

	self.text:SetText(name)
    self.icon:SetTexture(texture)
	self.desc:SetText(description)
end

-- XML Handlers
function GuardStatus_OnInitialized(control)
	GUARD_STATUS = GuardStatusWidget:New(control)
	GuardStatus.widget = GUARD_STATUS
end

function GuardStatus_OnMoveStop(control)
	GuardStatus.SV.offsetX = control:GetLeft()
	GuardStatus.SV.offsetY = control:GetTop()
end

-- Addon Initialize
local function OnAddonLoaded(event, addonName)
    if addonName ~= GuardStatus.name then return end  
    EVENT_MANAGER:UnregisterForEvent(GuardStatus.name, EVENT_ADD_ON_LOADED) 

	-- Creating savedvars
    GuardStatus.DS = ZO_SavedVars:NewAccountWide("GuardStatusSavedVariables", 1.0, nil, GuardStatus.accountWideDefaults)
    
    if GuardStatus.DS.accountWide then
		GuardStatus.SV = ZO_SavedVars:NewAccountWide("GuardStatusSavedVariables", 1.0, nil, GuardStatus.defaults)
	else
		GuardStatus.SV = ZO_SavedVars:New("GuardStatusSavedVariables", 1.0, nil, GuardStatus.defaults)
	end

	-- Addon Menu
    if LibAddonMenu2 then
        InitializeAddonMenu(self)
    end

	GuardStatus_OnInitialized(GuardStatusWindow)
end
EVENT_MANAGER:RegisterForEvent(GuardStatus.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)