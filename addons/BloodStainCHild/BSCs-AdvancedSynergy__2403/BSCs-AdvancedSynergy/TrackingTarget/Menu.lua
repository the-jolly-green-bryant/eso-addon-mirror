---------------------------------------------------------------------------------------------------
-- BSCASynergy – Target Tracking Menu (Tab 6)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper Functions
---------------------------------------------------------------------------------------------------
local function AddControl(data)
	BSCAS:AddControlToTab(6, data)
end

local function AddTexture(icon, desc)
	AddControl({
		type = "texture",
		image = icon,
		tooltip = desc or "",
		imageWidth = 32,
		imageHeight = 32,
		width = "half",
	})
end

local function AddDivider()
	AddControl({ type = "divider" })
end

local function TTrackUpdate()
	BSCAS:TTrackUpdateSetting()
end

local function AddSynergy(icon, nameString, key, desc)
	AddTexture(icon, desc)
	AddControl({
		type = "checkbox",
		width = "half",
		name = GetString(nameString),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		getFunc = function()
			local selected = BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER
			return BSCAS.SV.TARGET_TRACKING_UI_PLAYER[selected][key]
		end,
		setFunc = function(v)
			local selected = BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER
			BSCAS.SV.TARGET_TRACKING_UI_PLAYER[selected][key] = v
			TTrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- 📋 Player List Management
---------------------------------------------------------------------------------------------------
local default_setting = {
	ENABLED = false,
	BLOODALTAR = false, INNERFIRE = false, SPIDERS = false, BONESHIELD = false,
	SHARTSORBS = true, PURIFY = false, CONDUIT = true, ATRONACH = true,
	SHACKLE = false, HARVEST = true, GRAVEROBBER = true, PUREAGONY = false, RUNE = true,
	UI_LEFT = 200, UI_TOP = 200,
}

local function GetListNames()
	local list = {}
	for name in pairs(BSCAS.SV.TARGET_TRACKING_UI_PLAYER) do
		table.insert(list, name)
	end
	return list
end

local function CreateTestSetting()
	local playerName = GetUnitDisplayName("player")
	if not BSCAS.SV.TARGET_TRACKING_UI_PLAYER[playerName] then
		BSCAS.SV.TARGET_TRACKING_UI_PLAYER[playerName] = default_setting
	end
end

local SelectedDDG = ""

local function AddPlayerToTracking()
	local name = zo_strformat("<<1>>", BSCAS_TTrackingDropdownG.data.getFunc())
	if not name or name == "" or BSCAS.SV.TARGET_TRACKING_UI_PLAYER[name] then return end
	BSCAS.SV.TARGET_TRACKING_UI_PLAYER[name] = default_setting
	BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER = name
	BSCAS_TTrackingDropdown:UpdateChoices(GetListNames())
	TTrackUpdate()
end

local function RemovePlayerToTracking()
	local name = BSCAS_TTrackingDropdown.data.getFunc()
	if not name or name == "" or name == GetUnitDisplayName("player") then return end
	local newList = {}
	for k, v in pairs(BSCAS.SV.TARGET_TRACKING_UI_PLAYER) do
		if k ~= name then newList[k] = v end
	end
	BSCAS.SV.TARGET_TRACKING_UI_PLAYER = newList
	BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER = GetUnitDisplayName("player")
	BSCAS_TTrackingDropdown:UpdateChoices(GetListNames())
	TTrackUpdate()
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Basic Settings
---------------------------------------------------------------------------------------------------
local function AddBasicSettings()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV_Char.TARGET_TRACKING_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("TARGET_TRACKING", v)
		end,
	})
	AddDivider()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_TARGET_ENABLE),
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_ENABLED end,
		setFunc = function(v)
			BSCAS.SV.TARGET_TRACKING_ENABLED = v
			BSCAS.TargetTrackEnable()
			TTrackUpdate()
		end,
	})
	AddDivider()
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_TRACK_ONLY_ACTIVE),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_ONLY_ACTIVE end,
		setFunc = function(v)
			BSCAS.SV.TARGET_TRACKING_ONLY_ACTIVE = v
			TTrackUpdate()
		end,
	})
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_WIDTH),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		min = 100, max = 400, step = 1, default = 240,
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_MAX_WIDTH end,
		setFunc = function(v) 
			BSCAS.SV.TARGET_TRACKING_MAX_WIDTH = v 
			TTrackUpdate() 
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_HIGHT),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		min = 16, max = 600, step = 1, default = 260,
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_MAX_HEIGHT end,
		setFunc = function(v) 
			BSCAS.SV.TARGET_TRACKING_MAX_HEIGHT = v 
			TTrackUpdate() 
		end,
	})
	
	AddDivider()
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_TARGET_ACCOUNT),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_USEACCNAME end,
		setFunc = function(v)
			BSCAS.SV.TARGET_TRACKING_USEACCNAME = v
			BSCAS_TTrackingDropdownG:UpdateChoices(BSCAS:GetGroupListNames())
			BSCAS_TTrackingDropdown:UpdateChoices(GetListNames())
			TTrackUpdate()
		end,
	})


	-- Group Dropdown
	AddControl({
		type = "dropdown",
		name = GetString(SI_SYNERGY_TARGET_PGROUP),
		width = "half",
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		choices = BSCAS:GetGroupListNames(),
		getFunc = function() return SelectedDDG end,
		setFunc = function(v) SelectedDDG = v end,
		scrollable = 12,
		reference = "BSCAS_TTrackingDropdownG",
	})

	AddControl({
		type = "button",
		name = GetString(SI_SYNERGY_TARGET_BUTTON_ADD),
		width = "half",
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		func = AddPlayerToTracking,
	})

	AddDivider()

	-- Player Dropdown
	AddControl({
		type = "dropdown",
		width = "half",
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		choices = GetListNames(),
		getFunc = function() return BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER end,
		setFunc = function(v)
			if BSCAS.SV.TARGET_TRACKING_UI_PLAYER[v] then
				BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER = v
			end
		end,
		scrollable = 12,
		reference = "BSCAS_TTrackingDropdown",
	})

	AddControl({
		type = "button",
		name = GetString(SI_SYNERGY_TARGET_BUTTON_REMOVE),
		width = "half",
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		func = RemovePlayerToTracking,
	})

	AddDivider()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_TARGET_ENABLE_CHAR),
		disabled = function() return not BSCAS.SV.TARGET_TRACKING_ENABLED end,
		getFunc = function()
			local selected = BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER
			return BSCAS.SV.TARGET_TRACKING_UI_PLAYER[selected].ENABLED
		end,
		setFunc = function(v)
			local selected = BSCAS.SV.TARGET_TRACKING_SELECTED_PLAYER
			BSCAS.SV.TARGET_TRACKING_UI_PLAYER[selected].ENABLED = v
			TTrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- 🧭 Synergy Tracking Categories
---------------------------------------------------------------------------------------------------
local function AddTrackingSettings()
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_UNDAUNTED) })
	AddSynergy(ICON_UNDAUNTED_ALTAR_0, SI_SYNERGY_NAME_BLOODALTAR, "BLOODALTAR")
	AddSynergy(ICON_UNDAUNTED_WEBS_0, SI_SYNERGY_NAME_WEBS, "SPIDERS")
	AddSynergy(ICON_UNDAUNTED_FIRE_0, SI_SYNERGY_NAME_INNERFIRE, "INNERFIRE", GetString(SI_SYNERGY_DESC_INNERFIRE))
	AddSynergy(ICON_UNDAUNTED_BONE_0, SI_SYNERGY_NAME_BONE, "BONESHIELD")
	AddSynergy(ICON_UNDAUNTED_ORB_2, SI_SYNERGY_NAME_ORB2, "SHARTSORBS")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_TEMPLAR) })
	AddSynergy(ICON_TEMPLAR_RITUAL_0, SI_SYNERGY_NAME_PURGE, "PURIFY")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_SORC) })
	AddSynergy(ICON_SORC_CONDUIT_0, SI_SYNERGY_NAME_CONDUIT, "CONDUIT")
	AddSynergy(ICON_SORC_ATRO_0, SI_SYNERGY_NAME_ATRO, "ATRONACH")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_DK) })
	AddSynergy(ICON_DK_CLAW_0, SI_SYNERGY_NAME_IMPALE, "SHACKLE")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WARDN) })
	AddSynergy(ICON_WARDEN_HARVEST_0, SI_SYNERGY_NAME_HARVEST, "HARVEST")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_NECRO) })
	AddSynergy(ICON_NECRO_GRAVE_0, SI_SYNERGY_NAME_BONEYARD, "GRAVEROBBER")
	AddSynergy(ICON_NECRO_TOTEM_0, SI_SYNERGY_NAME_TOTEM, "PUREAGONY")

	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_ARCANIST) })
	AddSynergy(ICON_ARCANIST_RUNE, SI_SYNERGY_NAME_RUNE, "RUNE")
end

---------------------------------------------------------------------------------------------------
-- 🚀 Init
---------------------------------------------------------------------------------------------------
function BSCAS:InitTargetTrackingMenu()
	CreateTestSetting()
	AddBasicSettings()
	AddTrackingSettings()
end