local DEBUG = 
function() end
-- d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local PE = IM.UI.ProfileEdit

PE.profileList = { }
PE.reverseProfileList = { }
PE.selectedProfile = 0
PE.selectedName = ""

function PE:GetControls()
	return {
		{
			type = "dropdown",
			name = GetString(IM_PE_PROFILES),
			width = "half",
			choices = {  },
			getFunc = function() return PE:GetSelectedProfile() end,
			setFunc = function(value) PE:SetSelectedProfile(value) end,
			reference = "IWONTSAY_IM_CHO_PROFILES",
		},
		{
			type = "button",
			name = GetString(IM_PE_LOADPROFILE),
			width = "half",
			disabled = function() return PE:GetBtnLoadDisabled() end,
			func = function() return PE:BtnLoadClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_PE_DELETEPROFILE),
			width = "half",
			disabled = function() return PE:GetBtnDeleteDisabled() end,
			func = function() return PE:BtnDeleteClicked() end,
		},
		{
			type = "description",
			text = "",
			width = "half",
		},
		{
			type = "editbox",
			name = GetString(IM_PE_EDITPRNAME),
			tooltip = GetString(IM_PM_PROFILENAME_TOOLTIP),
			getFunc = function() return PE:GetProfileName() end,
			setFunc = function(text) PE:SetProfileName(text) end,
			isMultiline = false,
			width = "half",
		},
		{
			type = "button",
			name = GetString(IM_PE_SAVEPROFILE),
			width = "half",
			disabled = function() return PE:GetBtnSaveDisabled() end,
			func = function() return PE:BtnSaveClicked() end,
		},
	}
end

function PE:GetSelectedProfile()
	DEBUG("--- ProfileList:GetSelectedProfile()")
	return PE.selectedName
end

function PE:SetSelectedProfile(value)
	DEBUG("--- ProfileList:SetSelectedProfile()")
	local profiles = IM.Profiles
	PE.selectedProfile = PE.reverseProfileList[value]
	PE.selectedName = (PE.selectedProfile and PE.selectedProfile > 0 and value) or ""
end

function PE:GetBtnLoadDisabled()
	return #PE.profileList < 1 or (not PE.selectedProfile or PE.selectedProfile == 0)
end

function PE:GetBtnDeleteDisabled()
	return #PE.profileList < 1 or (not PE.selectedProfile or PE.selectedProfile < 1)
end

function PE:BtnDeleteClicked()
	local profiles = IM.Profiles
	table.remove(profiles, PE.selectedProfile)
	if PE.selectedProfile > #profiles then
		PE.selectedProfile = #profiles
	end
	PE:UpdateProfileList(PE.selectedProfile)
	IM:Save()
end

function PE:BtnLoadClicked()
	local selProfile
	
	if PE.selectedProfile > 0 then
		selProfile = IM.Profiles[PE.selectedProfile]
	else
		selProfile = IM.presetProfiles[-PE.selectedProfile]
	end
	
	IM.currentRuleset = selProfile:Clone()
  IM.currentRuleset.name = nil
  IM.currentRuleset.settings = nil
	
	IM.settings = { }
	for k,v in pairs(IM.charDefaults["settings"]) do
		IM.settings[k] = v
	end
	for k,v in pairs(selProfile["settings"] or { }) do
		IM.settings[k] = v
	end
	
	IM.UI.RuleEdit:UpdateRuleList()
	IM:Save()
end

function PE:GetBtnSaveDisabled()
	return PE.selectedName == ""
end

function PE:BtnSaveClicked()
	local profiles = IM.Profiles
	PE.selectedProfile = PE.reverseProfileList[PE.selectedName]
	if not PE.selectedProfile then
		PE.selectedProfile = #profiles + 1
	end
	
	local selProfile = IM.currentRuleset:Clone();
	selProfile.name = PE.selectedName
	selProfile.settings = { }
	for k,v in pairs(IM.settings or { }) do
		selProfile.settings[k] = v
	end
	profiles[PE.selectedProfile] = selProfile
	
	PE:UpdateProfileList(PE.selectedProfile)
	IM:Save()
end

function PE:GetProfileName()
	return PE.selectedName or ""
end

function PE:SetProfileName(text)
	PE.selectedName = text
end

function PE:UpdateProfileList(preselection)
	DEBUG("--- UpdateProfileList()", preselection)
	
	PE.profileList = { }
	PE.reverseProfileList = { }

	local _preselection = nil
	local profiles
	profiles = IM.presetProfiles
	
	PE.profileList[1] = GetString(IM_RM_PRESETRULES)
	
	if #profiles then
		for i = 1, #profiles, 1 do
			local tgt = #PE.profileList + 1
			PE.profileList[tgt] = profiles[i]["name"]
			PE.reverseProfileList[profiles[i]["name"]] = -i
		end
	end

	PE.profileList[#PE.profileList + 1] = GetString(IM_RM_CUSTOMRULES)
	
	profiles = IM.Profiles
	if #profiles then
		for i = 1, #profiles, 1 do
			local tgt = #PE.profileList + 1
			if preselection == i then _preselection = tgt end
			PE.profileList[tgt] = profiles[i]["name"]
			PE.reverseProfileList[profiles[i]["name"]] = i
		end
	end
	
	IWONTSAY_IM_CHO_PROFILES:UpdateChoices(PE.profileList)

	if #PE.profileList > 0 then
		local seltxt = PE.profileList[_preselection or 1]
		IWONTSAY_IM_CHO_PROFILES:UpdateValue(false, seltxt)
		PE:SetSelectedProfile(seltxt)
	end
end


-- Called whenever the panel is first created. 
function PE:PopulateUI()
	DEBUG("--- PE:PopulateUI")

	-- fired because of someone else?
	if not IWONTSAY_IM_CHO_PROFILES then return end
	
	PE:UpdateProfileList()
end

