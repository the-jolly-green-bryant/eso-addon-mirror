---------------------------------------------------------------------------------------------------
-- BSCASynergy – Group Tracking Menu (Tab 5)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper Functions
---------------------------------------------------------------------------------------------------
local function AddControl(data)
	BSCAS:AddControlToTab(5, data)
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

local function GTrackUpdate()
	BSCAS:GTrackUpdateSetting()
end

local function AddSynergy(icon, nameString, key, desc)
	AddTexture(icon, desc)
	AddControl({
		type = "checkbox",
		name = GetString(nameString),
		width = "half",
		disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST[key] end,
		setFunc = function(v)
			BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST[key] = v
			GTrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Basic Group Tracking Settings
---------------------------------------------------------------------------------------------------
local function AddBasicSettings()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV_Char.GROUP_TRACKING_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("GROUP_TRACKING", v)
		end,
	})
	AddControl({ type = "divider", })

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_TRACK_ENABLE),
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_ENABLED end,
		setFunc = function(v)
			BSCAS.SV.GROUP_TRACKING_ENABLED = v
			BSCAS.GroupTrackEnable()
			GTrackUpdate()
		end,
	})
	AddControl({ type = "divider" })
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_TRACK_ONLY_ACTIVE),
		disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE end,
		setFunc = function(v)
			BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE = v
			GTrackUpdate()
		end,
	})
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_WIDTH),
		disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
		min = 100, max = 400, step = 1, default = 240,
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_MAX_WIDTH end,
		setFunc = function(v) 
			BSCAS.SV.GROUP_TRACKING_MAX_WIDTH = v 
			GTrackUpdate() 
		end,
	})
	--[[
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_HIGHT),
		disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
		min = 16, max = 60, step = 1, default = 24,
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT end,
		setFunc = function(v) 
			BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT = v 
			GTrackUpdate() 
		end,
	})--]]
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_HIGHT),
		disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
		min = 16, max = 600, step = 1, default = 260,
		getFunc = function() return BSCAS.SV.GROUP_TRACKING_MAX_HEIGHT end,
		setFunc = function(v) 
			BSCAS.SV.GROUP_TRACKING_MAX_HEIGHT = v 
			GTrackUpdate() 
		end,
	})
	
	AddControl({ type = "divider" })
	
	local roles = {
		{ icon = "EsoUI/Art/LFG/LFG_tank_up_64.dds", role = LFG_ROLE_TANK },
		{ icon = "EsoUI/Art/LFG/LFG_healer_up_64.dds", role = LFG_ROLE_HEAL },
		{ icon = "EsoUI/Art/LFG/LFG_dps_up_64.dds", role = LFG_ROLE_DPS },
	}

	for _, roleData in ipairs(roles) do
		local key = ({ [LFG_ROLE_TANK] = "TANK", [LFG_ROLE_HEAL] = "HEAL", [LFG_ROLE_DPS] = "DPS" })[roleData.role]
		AddControl({
			type = "checkbox",
			name = GetString(SI_SYNERGY_UI_TRACK_ENABLE)
				.. "|t23:23:" .. roleData.icon .. "|t|r"
				.. GetString("SI_LFGROLE", roleData.role),
			disabled = function() return not BSCAS.SV.GROUP_TRACKING_ENABLED end,
			getFunc = function() return BSCAS.SV["GROUP_TRACKING_" .. key] end,
			setFunc = function(v)
				BSCAS.SV["GROUP_TRACKING_" .. key] = v
				GTrackUpdate()
			end,
		})
	end
end

---------------------------------------------------------------------------------------------------
-- 🧭 Tracking Synergy Categories
---------------------------------------------------------------------------------------------------
local function AddTrackingSettings()

	---------------------------------------------------------------------------------------------------
	-- Undaunted
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_UNDAUNTED) })
	AddSynergy(ICON_UNDAUNTED_ALTAR_0, SI_SYNERGY_NAME_BLOODALTAR, "BLOODALTAR")
	AddSynergy(ICON_UNDAUNTED_WEBS_0, SI_SYNERGY_NAME_WEBS, "SPIDERS")
	AddSynergy(ICON_UNDAUNTED_FIRE_0, SI_SYNERGY_NAME_INNERFIRE, "INNERFIRE", GetString(SI_SYNERGY_DESC_INNERFIRE))
	AddSynergy(ICON_UNDAUNTED_BONE_0, SI_SYNERGY_NAME_BONE, "BONESHIELD")
	AddSynergy(ICON_UNDAUNTED_ORB_2, SI_SYNERGY_NAME_ORB2, "SHARTSORBS")

	---------------------------------------------------------------------------------------------------
	-- Templar
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_TEMPLAR) })
	AddSynergy(ICON_TEMPLAR_RITUAL_0, SI_SYNERGY_NAME_PURGE, "PURIFY")

	---------------------------------------------------------------------------------------------------
	-- Sorcerer
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_SORC) })
	AddSynergy(ICON_SORC_CONDUIT_0, SI_SYNERGY_NAME_CONDUIT, "CONDUIT")
	AddSynergy(ICON_SORC_ATRO_0, SI_SYNERGY_NAME_ATRO, "ATRONACH")

	---------------------------------------------------------------------------------------------------
	-- Dragonknight
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_DK) })
	AddSynergy(ICON_DK_CLAW_0, SI_SYNERGY_NAME_IMPALE, "SHACKLE")

	---------------------------------------------------------------------------------------------------
	-- Warden
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WARDN) })
	AddSynergy(ICON_WARDEN_HARVEST_0, SI_SYNERGY_NAME_HARVEST, "HARVEST")

	---------------------------------------------------------------------------------------------------
	-- Necromancer
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_NECRO) })
	AddSynergy(ICON_NECRO_GRAVE_0, SI_SYNERGY_NAME_BONEYARD, "GRAVEROBBER")
	AddSynergy(ICON_NECRO_TOTEM_0, SI_SYNERGY_NAME_TOTEM, "PUREAGONY")

	---------------------------------------------------------------------------------------------------
	-- Arcanist
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_ARCANIST) })
	AddSynergy(ICON_ARCANIST_RUNE, SI_SYNERGY_NAME_RUNE, "RUNE")
	AddSynergy(ICON_ARCANIST_PORTAL, SI_SYNERGY_NAME_PORTAL, "PORTAL")

	---------------------------------------------------------------------------------------------------
	-- Werewolf
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WOLF) })
	AddSynergy(ICON_WOLF, SI_SYNERGY_NAME_HUNT, "HOWLING")

	---------------------------------------------------------------------------------------------------
	-- Item Sets
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_ITEMS) })
	AddSynergy(ICON_ITEM_URSUS, SI_SYNERGY_ITEM_NAME_URSUS, "URSUS", GetString(SI_SYNERGY_ITEM_DESC_URSUS))
	AddSynergy(ICON_ITEM_KRAGLEN, SI_SYNERGY_ITEM_NAME_KRAGLEN, "KRAGLEN", GetString(SI_SYNERGY_ITEM_DESC_KRAGLEN))
	AddSynergy(ICON_ITEM_SANGUINE, SI_SYNERGY_ITEM_NAME_SANGUINE, "LADYTHORN", GetString(SI_SYNERGY_ITEM_DESC_SANGUINE))
	AddSynergy(ICON_ITEM_GPREPRISAL, SI_SYNERGY_ITEM_NAME_GPREPRISAL, "GPREPRISAL", GetString(SI_SYNERGY_ITEM_DESC_GPREPRISAL))

	---------------------------------------------------------------------------------------------------
	-- Trials / Raids
	---------------------------------------------------------------------------------------------------
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_RAID) })
	
	AddControl({ type = "header", name = zo_strformat("<<1>>", GetZoneNameById(1051)) })
	AddSynergy(ICON_VCR_GATE, SI_SYNERGY_ABILITY_GATEWAY, "CR_PRTAL")
	
	AddControl({ type = "header", name = zo_strformat("<<1>>", GetZoneNameById(1344)) })
	AddSynergy(ICON_DSR_DINFESTATION, SI_SYNERGY_ABILITY_DSR_SURGING_WATERS, "DSR_REEF", GetString(SI_SYNERGY_DESC_DSR_SURGING_WATERS))
	
	AddControl({ type = "header", name = zo_strformat("<<1>>", GetZoneNameById(1427)) })
	AddSynergy(ICON_SE_AGONY, SI_SYNERGY_ABILITY_SE_VANTONS_CLARITY, "SE_PORTAL", GetString(SI_SYNERGY_DESC_SE_VANTONS_CLARITY))
	
	AddControl({ type = "header", name = zo_strformat("<<1>>", GetZoneNameById(1478)) })
	AddSynergy(ICON_LC_MIRROR, SI_SYNERGY_ABILITY_LC_MIRROR, "LC_MIRROR")
	
	AddControl({ type = "header", name = zo_strformat("<<1>>", GetZoneNameById(1548)) })
	AddSynergy(ICON_OC_CARRIONSHIELD, SI_SYNERGY_ABILITY_OC_CARRIONSHIELD, "OC_SHIELD")
end

---------------------------------------------------------------------------------------------------
-- 🚀 Init Menu
---------------------------------------------------------------------------------------------------
function BSCAS:InitGroupTrackingMenu()
	AddBasicSettings()
	AddTrackingSettings()
end