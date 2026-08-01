BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local MAX_SLOTS = 6
local DEFAULT_GROUP_NAME = "Default"
	
local debug_mode = false
function BSCAS.ProrityDebugMode()
    debug_mode = not debug_mode
    BSCAS:PrintDebug("Debug Mode (Priority Synergie) " .. (debug_mode and "Enabled!" or "Disabled!"))
end
local function PrintDebug(FormatedText)
	if debug_mode then
		BSCAS:PrintDebug(FormatedText)
	end
end
------------------------------------------------------------------------------
-- Current Synergie UI
------------------------------------------------------------------------------
function BSCAS:PriorityOnMoveStop()
	BSCAS.SV.PRIO_UI_LEFT = BSCASynergyPUI:GetLeft()
	BSCAS.SV.PRIO_UI_TOP = BSCASynergyPUI:GetTop()
end
function BSCAS:PriorityRestorePosition()
	BSCASynergyPUI:ClearAnchors()
	BSCASynergyPUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCAS.SV.PRIO_UI_LEFT, BSCAS.SV.PRIO_UI_TOP)
	BSCASynergyPUI:SetMovable(not BSCAS.SV.PRIO_LOCK_UI)
end
local function CreateControls()
	local WM = GetWindowManager()
	local oldpan = BSCASynergyPUI
	for i=1, MAX_SLOTS do
		local panel = WM:CreateControlFromVirtual("$(parent)Prior", BSCASynergyPUI, "BSCASynergyPUIS", i)
		panel:ClearAnchors()
		panel:SetAnchor(TOP, oldpan, BOTTOM, 0, 0)	
		panel:GetNamedChild("Name"):SetText("Test")	
		panel:SetHidden(false)	
		oldpan = panel
	end	
	BSCASynergyPUI:GetNamedChild("Name"):SetText(GetString(SI_SYNERGY_UI_PRIO_UI_NAME))
end
function BSCAS:UpdatePrioSettings()
	if BSCAS.SV.PRIO_UI_ENABLE then
		SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.PriorFragment)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.PriorFragment)				
	else		
		SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.PriorFragment)
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.PriorFragment)
	end
end
function BSCAS:UpdateAvailableSynergies()
    local totalSynergies = GetNumberOfAvailableSynergies() or 0
    local numToShow = math.min(totalSynergies, MAX_SLOTS)
	for i = 1, MAX_SLOTS do
        local ctrl = BSCASynergyPUI:GetNamedChild("Prior" .. i)
        if ctrl then ctrl:SetHidden(true) end
    end	
	local shownAbilities = {} 
	local controlIndex = 1
    for synergyIndex = 1, numToShow do
		local _synergyName_, _iconFilename_, _prompt_, _priority_, _synergyAbilityId_, _canBeUsed_ = GetSynergyInfoAtIndex(synergyIndex)
		PrintDebug(zo_strformat("Name [<<1>>] Prior[<<2>>] ID[<<3>>]", _synergyName_, _priority_, _synergyAbilityId_))	
		if _synergyAbilityId_ and not shownAbilities[_synergyAbilityId_] then	
			shownAbilities[_synergyAbilityId_] = true	
			BSCAS:AddSynergy(_synergyName_, _iconFilename_, _priority_, _synergyAbilityId_)
			if BSCAS.SV.PRIO_UI_ENABLE then
				if _canBeUsed_ then
					local control = BSCASynergyPUI:GetNamedChild("Prior" .. controlIndex)	
					if control ~= nil then 
						control:GetNamedChild("Icon"):SetTexture(GetAbilityIcon(_synergyAbilityId_))
						control:GetNamedChild("Name"):SetText(zo_strformat("<<1>>", _synergyName_))
						control:GetNamedChild("Prior"):SetText(zo_strformat("<<1>>", _priority_))
						control:SetHidden(false)
						controlIndex = controlIndex + 1
					end
				end
			end
		end
	end
end
------------------------------------------------------------------------------
-- Synergie Priority Presets
------------------------------------------------------------------------------
function BSCAS:InitPrioPresets()
    self.SV_acc.PRIO_PRESETS = self.SV_acc.PRIO_PRESETS or {}
    self.SV.SELECTED_PRIO_PRESET = self.SV.SELECTED_PRIO_PRESET or "Default"
	
    -- Falls Default noch nicht existiert, anlegen
    if not self.SV_acc.PRIO_PRESETS["Default"] then
        self.SV_acc.PRIO_PRESETS["Default"] = {}
    end
	
    local preset = self.SV_acc and self.SV_acc.PRIO_PRESETS and self.SV_acc.PRIO_PRESETS[self.SV.SELECTED_PRIO_PRESET]
	if not preset then self.SV.SELECTED_PRIO_PRESET = "Default" end
	
	
	BSCAS:ConvertOldPresets()
	BSCAS:ApplyPrioPreset(self.SV.SELECTED_PRIO_PRESET)
end
function BSCAS:GetActivePrioPreset()
    local presetName = self.SV.SELECTED_PRIO_PRESET
    return self.SV_acc.PRIO_PRESETS[presetName]
end
function BSCAS:CreatePrioPreset(name, copyCurrent)
    if not name or name == "" then return false end
    if self.SV_acc.PRIO_PRESETS[name] then return false end -- existiert schon

    if copyCurrent then
        local current = self:GetActivePrioPreset()
        local copy = {}
        for id, prio in pairs(current) do
            copy[id] = prio
        end
        self.SV_acc.PRIO_PRESETS[name] = copy
    else
        self.SV_acc.PRIO_PRESETS[name] = {}
    end
	BSCAS:PrioUpdateCombobox()
	BSCAS:ApplyPrioPreset(name)
    return true
end
function BSCAS:DeletePrioPreset(name)
    if name == "Default" then return false end
    if self.SV_acc.PRIO_PRESETS[name] then
        self.SV_acc.PRIO_PRESETS[name] = nil
        if self.SV.SELECTED_PRIO_PRESET == name then
            BSCAS.SV.SELECTED_PRIO_PRESET = "Default"
			BSCAS:ApplyPrioPreset("Default")
        end
		BSCAS:PrioUpdateCombobox()
        return true
    end
    return false
end

function BSCAS:ApplyPrioPreset(presetName)
    local preset = self.SV_acc.PRIO_PRESETS[presetName or self.SV.SELECTED_PRIO_PRESET]
    if not preset then return end
    ClearAllSynergyPriorityOverrides()
    -- Neue Struktur: preset.groups = { { name="", synergies={ [idx]=synergyId } }, ... }
    if preset.groups then
        for groupIndex, group in ipairs(preset.groups) do
            local priority = groupIndex
            for idx, synergyId in pairs(group.synergies or {}) do
                if type(synergyId) == "number" then
                    SetSynergyPriorityOverride(synergyId, priority)
                else
                    d(string.format("[BSCAS] Warning: Invalid synergyId '%s' in group '%s'", tostring(synergyId), group.name))
                end
            end
        end
    else
        -- Fallback: alte Struktur ohne groups
        for synergyId, priority in pairs(preset) do
            if type(synergyId) == "number" then
                SetSynergyPriorityOverride(synergyId, priority)
            end
        end
    end

    self.SV.SELECTED_PRIO_PRESET = presetName
	
	if BSCAS.SV.PRINT_PRIORITY_PRESET_LOADED then
		CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Priority Preset: <<1>> applied.|r", BSCAS.SV.SELECTED_PRIO_PRESET))
	end
end

function BSCAS:PrioPresetExists(name)
    if not name or name == "" then return false end
    return self.SV_acc.PRIO_PRESETS and self.SV_acc.PRIO_PRESETS[name] ~= nil
end
function BSCAS:GetListPrioNames()
	local List = {}	
	for name, v in pairs(BSCAS.SV_acc.PRIO_PRESETS) do	
		table.insert(List, name)
	end	
	return List
end
function BSCAS:PrioUpdateCombobox()
	-- Update the dropbox
	BSCAS_PresetPrioDropdown:UpdateChoices(BSCAS:GetListPrioNames())
	BSCAS_PrioPresetDropdownTank:UpdateChoices(BSCAS:GetListPrioNames())
	BSCAS_PrioPresetDropdownHeal:UpdateChoices(BSCAS:GetListPrioNames())
	BSCAS_PrioPresetDropdownDps:UpdateChoices(BSCAS:GetListPrioNames())	
end

local function HookRoleChange()
	ZO_PreHook("UpdateSelectedLFGRole", 	
	function(role)  
		if role == LFG_ROLE_TANK then
			if BSCAS.SV.SELECTED_PRIO_PRESET_TANK ~= "Default" then
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_TANK
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Priority "..GetString("SI_LFGROLE", LFG_ROLE_TANK).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_TANK))
				BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
			end
		elseif role == LFG_ROLE_HEAL then	
			if BSCAS.SV.SELECTED_PRIO_PRESET_HEAL ~= "Default" then	
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_HEAL
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Priority "..GetString("SI_LFGROLE", LFG_ROLE_HEAL).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_HEAL))
				BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
			end
		else			
			if BSCAS.SV.SELECTED_PRIO_PRESET_DPS ~= "Default" then
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_DPS
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Priority "..GetString("SI_LFGROLE", LFG_ROLE_DPS).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_DPS))
				BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
			end
		end
		BSCAS:ApplyPrioPreset(BSCAS.SV.SELECTED_PRIO_PRESET)
	end)
end
------------------------------------------------------------------------------
-- Synergie Priority Init
------------------------------------------------------------------------------
local bCheckLFGRole = true
local function OnPlayerActivated()	
	-- first check LFG Role on Login
	if bCheckLFGRole then
		bCheckLFGRole = false
		local LFGR = GetSelectedLFGRole() 
		if LFGR == LFG_ROLE_TANK then
			if BSCAS.SV.SELECTED_PRIO_PRESET_TANK ~= "Default" then
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_TANK
			end
		elseif LFGR == LFG_ROLE_HEAL then	
			if BSCAS.SV.SELECTED_PRIO_PRESET_HEAL ~= "Default" then	
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_HEAL
			end
		else			
			if BSCAS.SV.SELECTED_PRIO_PRESET_DPS ~= "Default" then
				BSCAS.SV.SELECTED_PRIO_PRESET = BSCAS.SV.SELECTED_PRIO_PRESET_DPS
			end
		end	
	end
	
	BSCAS:ApplyPrioPreset(BSCAS.SV.SELECTED_PRIO_PRESET)
end
function BSCAS:InitPrority()
	CreateControls()
	BSCAS:PriorityRestorePosition()
	BSCAS:InitPrioPresets()
	
	BSCAS.PriorFragment = ZO_SimpleSceneFragment:New(BSCASynergyPUI)
	BSCAS:UpdatePrioSettings()
	BSCAS:MergeSynergyLists() -- Known synergys
	
	HookRoleChange()
	
	EVENT_MANAGER:RegisterForEvent("BSCAS_Priority", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
end

function BSCAS:MergeSynergyLists()
    if not self.SV_acc.SYNERGY_LIST then
        self.SV_acc.SYNERGY_LIST = {}
    end

    for abilityId, synergyData in pairs(self.SYNERGY_LIST) do
        if not self.SV_acc.SYNERGY_LIST[abilityId] then
            self.SV_acc.SYNERGY_LIST[abilityId] = {
                priority = synergyData.priority or 0,
                zoneid   = synergyData.zoneid or -1,
            }
        end
    end
end
-- Adding seen synergies to list
function BSCAS:AddSynergy(synergyName, iconFilename, priority, synergyAbilityId)
    BSCAS.SV_acc.SYNERGY_LIST = BSCAS.SV_acc.SYNERGY_LIST or {}
	local zoneId = GetUnitWorldPosition('player') 
	
	if not BSCAS.SV_acc.SYNERGY_LIST[synergyAbilityId] then
		BSCAS.SV_acc.SYNERGY_LIST[synergyAbilityId] = {
			priority = priority,
			zoneid = zoneId, 
		}
	end
end
--  New Group System
function BSCAS:ConvertOldPresets()
    for name, preset in pairs(self.SV_acc.PRIO_PRESETS or {}) do
        if not preset.groups then
            local newPreset = { groups = {} }
            local group = { name = "Default", synergies = {} }

            for id, prio in pairs(preset) do
                table.insert(group.synergies, abilityId)					
            end

            table.insert(newPreset.groups, group)
            self.SV_acc.PRIO_PRESETS[name] = newPreset
            PrintDebug(string.format("[BSCAS] Converted old preset '%s' to group-based format.", name))
        end
    end
end
-- Add a new empty group to a preset
function BSCAS:AddGroup(presetName, groupName)
    if not presetName or not groupName or groupName == "" then return false end
    if not self.SV_acc.PRIO_PRESETS then self.SV_acc.PRIO_PRESETS = {} end
    if not self.SV_acc.PRIO_PRESETS[presetName] then self.SV_acc.PRIO_PRESETS[presetName] = {} end

    local preset = self.SV_acc.PRIO_PRESETS[presetName]
    if not preset.groups then preset.groups = {} end

    -- Check for duplicate names
    for _, group in ipairs(preset.groups) do
        if zo_strlower(group.name or "") == zo_strlower(groupName) then
            d(string.format("[BSCAS] Group '%s' already exists in preset '%s'.", groupName, presetName))
            return false
        end
    end

    -- Respect the 25 group limit
    local MAX_GROUPS = 25
    if #preset.groups >= MAX_GROUPS then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, string.format("Maximum of %d groups reached!", MAX_GROUPS))
        return false
    end

    -- Create new group structure
    local newGroup = {
        name = groupName,
        synergies = {},
    }

    table.insert(preset.groups, newGroup)
    d(string.format("[BSCAS] Added new group '%s' to preset '%s'.", groupName, presetName))

    -- Optional: automatically apply the preset after adding
    self:ApplyPrioPreset(presetName)
    return true
end
-- Hilfsfunktion: Synergy-Liste für eine Gruppe auf Array-Normalform bringen
function BSCAS:NormalizeSynergyList(group)
    group.synergies = group.synergies or {}
    local sy = group.synergies

    -- Bereits eine Liste? (hat Index 1)
    if sy[1] ~= nil then
        -- Duplikate/Holes entfernen
        local seen, arr = {}, {}
        for _, id in ipairs(sy) do
            id = tonumber(id) or id
            if type(id) == "number" and not seen[id] then
                table.insert(arr, id)
                seen[id] = true
            end
        end
        group.synergies = arr
        return arr
    end

    -- War ein Set/Map? -> in Liste konvertieren
    local arr = {}
    for id, v in pairs(sy) do
        if v then
            id = tonumber(id) or id
            if type(id) == "number" then
                table.insert(arr, id)
            end
        end
    end
    table.sort(arr) -- optional
    group.synergies = arr
    return arr
end

local function SynergyListContains(list, abilityId)
    abilityId = tonumber(abilityId) or abilityId
    for _, id in ipairs(list) do
        if id == abilityId then return true end
    end
    return false
end

-- Hinzufügen: als Array (für #count)
function BSCAS:AddSynergyToGroup(presetName, groupIndex, abilityId)
    local preset = self.SV_acc.PRIO_PRESETS[presetName]
    if not preset or not preset.groups or not preset.groups[groupIndex] then return false end
    local group = preset.groups[groupIndex]
    local list  = self:NormalizeSynergyList(group)
    abilityId   = tonumber(abilityId) or abilityId
    if type(abilityId) ~= "number" then return false end

    if SynergyListContains(list, abilityId) then return false end
    table.insert(list, abilityId)
	SetSynergyPriorityOverride(abilityId, groupIndex)
    PrintDebug(string.format("[BSCAS] Added synergy %d to group '%s' (#=%d)", abilityId, group.name or tostring(groupIndex), #list))
    return true
end

-- Entfernen: aus Array löschen, damit #count korrekt bleibt
function BSCAS:RemoveSynergyFromGroup(presetName, groupIndex, abilityId)
    local preset = self.SV_acc.PRIO_PRESETS[presetName]
    if not preset or not preset.groups or not preset.groups[groupIndex] then return false end
    local group = preset.groups[groupIndex]
    local list  = self:NormalizeSynergyList(group)
    abilityId   = tonumber(abilityId) or abilityId
    if type(abilityId) ~= "number" then return false end

    for i = #list, 1, -1 do
        if list[i] == abilityId then
            table.remove(list, i)
            ClearSynergyPriorityOverride(abilityId)
            PrintDebug(string.format("[BSCAS] Removed synergy %d from group '%s' (#=%d)", abilityId, group.name or tostring(groupIndex), #list))
            return true
        end
    end
    return false
end


