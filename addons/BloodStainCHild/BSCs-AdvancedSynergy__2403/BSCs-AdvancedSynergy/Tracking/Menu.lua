---------------------------------------------------------------------------------------------------
-- BSCASynergy – Tracking Menu (Tab 4)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper Functions
---------------------------------------------------------------------------------------------------
local function AddControl(data)
	BSCAS:AddControlToTab(4, data)
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

local function TrackUpdate()
	BSCAS.TrackUpdateUI()
end

-- 🔹 universelle Helferfunktion für Icon + Checkbox
local function AddSynergy(icon, nameString, key, desc)
	AddTexture(icon, desc)
	AddControl({
		type = "checkbox",
		name = GetString(nameString),
		width = "half",
		disabled = function() return not BSCAS.SV.TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TRACKING_UI_TSG_LIST[key] end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_TSG_LIST[key] = v
			TrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Basic UI Settings
---------------------------------------------------------------------------------------------------
local function AddBasicSettings()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV_Char.TRACKING_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("TRACKING", v)
		end,
	})
	AddControl({ type = "divider", })

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_TRACK_ENABLE),
		getFunc = function() return BSCAS.SV.TRACKING_ENABLED end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_ENABLED = v
			BSCAS.TrackEnable()
		end,
	})
	
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_TRACK_ONLY_ACTIVE),
		getFunc = function() return BSCAS.SV.TRACKING_ONLY_ACTIVE end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_ONLY_ACTIVE = v
			BSCAS.TrackUpdateUI()
		end,
	})

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_LOCK),
		getFunc = function() return BSCAS.SV.TRACKING_LOCK_UI end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_LOCK_UI = v
			BSCASTackingUI:SetMovable(not v)
		end,
	})

	AddControl({
		type = "dropdown",
		name = GetString(SI_SYNERGY_UI_TRACK_ORIENT),
		disabled = function() return not BSCAS.SV.TRACKING_ENABLED end,
		choices = {"Horizontal", "Vertical"},
		getFunc = function() return BSCAS.SV.TRACKING_UI_ORIENT end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_ORIENT = v
			TrackUpdate()
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_TRACK_SIZE),
		min = 0, max = 100, step = 1, default = 40,
		disabled = function() return not BSCAS.SV.TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TRACKING_UI_SIZE end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_SIZE = v
			TrackUpdate()
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_TRACK_SIZE_OUTLINE),
		min = 0, max = 10, step = 1, default = 3,
		disabled = function() return not BSCAS.SV.TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TRACKING_UI_SIZE_OUTLINE end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_SIZE_OUTLINE = v
			TrackUpdate()
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_ALPHA),
		min = 0.1, max = 1, step = 0.1, default = 1,
		disabled = function() return not BSCAS.SV.TRACKING_ENABLED end,
		getFunc = function() return BSCAS.SV.TRACKING_UI_ALPHA end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_ALPHA = v
			TrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- ✏️ Font Settings
---------------------------------------------------------------------------------------------------
local function AddFontSettings()
	AddControl({ type = "header", name = "Font Settings" })

	AddControl({
		type = "dropdown",
		name = "Font",
		width = "full",
		choices = {
			"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT",
			"GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT",
			"ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"
		},
		getFunc = function() return BSCAS.SV.TRACKING_UI_FONT end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_FONT = v
			TrackUpdate()
		end,
	})

	AddControl({
		type = "dropdown",
		name = "Font Style",
		width = "full",
		choices = { "soft-shadow-thick", "soft-shadow-thin", "thick-outline", "shadow" },
		getFunc = function() return BSCAS.SV.TRACKING_UI_FONT_STYLE end,
		setFunc = function(v)
			BSCAS.SV.TRACKING_UI_FONT_STYLE = v
			TrackUpdate()
		end,
	})

	AddControl({
		type = "colorpicker",
		name = "Color Cooldown Ready",
		width = "full",
		getFunc = function() return unpack(BSCAS.SV.TRACKING_UI_FONT_COLOR_N) end,
		setFunc = function(r, g, b, a)
			BSCAS.SV.TRACKING_UI_FONT_COLOR_N = {r, g, b, a}
			TrackUpdate()
		end,
	})

	AddControl({
		type = "colorpicker",
		name = "Color Cooldown Running",
		width = "full",
		getFunc = function() return unpack(BSCAS.SV.TRACKING_UI_FONT_COLOR_C) end,
		setFunc = function(r, g, b, a)
			BSCAS.SV.TRACKING_UI_FONT_COLOR_C = {r, g, b, a}
			TrackUpdate()
		end,
	})
end

---------------------------------------------------------------------------------------------------
-- 🧭 Tracking Categories (Synergies)
---------------------------------------------------------------------------------------------------
local function AddTrackingSettings()
	-- Undaunted
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_UNDAUNTED) })
	AddSynergy(ICON_UNDAUNTED_ALTAR_0, SI_SYNERGY_NAME_BLOODALTAR, "BLOODALTAR")
	AddSynergy(ICON_UNDAUNTED_WEBS_0, SI_SYNERGY_NAME_WEBS, "SPIDERS")
	AddSynergy(ICON_UNDAUNTED_FIRE_0, SI_SYNERGY_NAME_INNERFIRE, "INNERFIRE", GetString(SI_SYNERGY_DESC_INNERFIRE))
	AddSynergy(ICON_UNDAUNTED_BONE_0, SI_SYNERGY_NAME_BONE, "BONESHIELD")
	AddSynergy(ICON_UNDAUNTED_ORB_2, SI_SYNERGY_NAME_ORB2, "SHARTSORBS")

	-- Templar
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_TEMPLAR) })
	AddSynergy(ICON_TEMPLAR_RITUAL_0, SI_SYNERGY_NAME_PURGE, "PURIFY")

	-- Sorc
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_SORC) })
	AddSynergy(ICON_SORC_CONDUIT_0, SI_SYNERGY_NAME_CONDUIT, "CONDUIT")
	AddSynergy(ICON_SORC_ATRO_0, SI_SYNERGY_NAME_ATRO, "ATRONACH")

	-- DK
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_DK) })
	AddSynergy(ICON_DK_CLAW_0, SI_SYNERGY_NAME_IMPALE, "SHACKLE")

	-- Warden
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WARDN) })
	AddSynergy(ICON_WARDEN_HARVEST_0, SI_SYNERGY_NAME_HARVEST, "HARVEST")

	-- Necro
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_NECRO) })
	AddSynergy(ICON_NECRO_GRAVE_0, SI_SYNERGY_NAME_BONEYARD, "GRAVEROBBER")
	AddSynergy(ICON_NECRO_TOTEM_0, SI_SYNERGY_NAME_TOTEM, "PUREAGONY")

	-- Arcanist
	if GetAPIVersion() > 101037 then
		AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_ARCANIST) })
		AddSynergy(ICON_ARCANIST_RUNE, SI_SYNERGY_NAME_RUNE, "RUNE")
		AddSynergy(ICON_ARCANIST_PORTAL, SI_SYNERGY_NAME_PORTAL, "PORTAL")
	end

	-- Werewolf
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WOLF) })
	AddSynergy(ICON_WOLF, SI_SYNERGY_NAME_HUNT, "HOWLING")

	-- Items
	AddControl({ type = "header", name = GetString(SI_SYNERGY_NAME_ITEMS) })
	AddSynergy(ICON_ITEM_URSUS, SI_SYNERGY_ITEM_NAME_URSUS, "URSUS", GetString(SI_SYNERGY_ITEM_DESC_URSUS))
	AddSynergy(ICON_ITEM_KRAGLEN, SI_SYNERGY_ITEM_NAME_KRAGLEN, "KRAGLEN", GetString(SI_SYNERGY_ITEM_DESC_KRAGLEN))
	AddSynergy(ICON_ITEM_SANGUINE, SI_SYNERGY_ITEM_NAME_SANGUINE, "LADYTHORN", GetString(SI_SYNERGY_ITEM_DESC_SANGUINE))
	AddSynergy(ICON_ITEM_GPREPRISAL, SI_SYNERGY_ITEM_NAME_GPREPRISAL, "GPREPRISAL", GetString(SI_SYNERGY_ITEM_DESC_GPREPRISAL))

	-- Trials / Raids
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
function BSCAS:InitTrackingMenu()
	AddBasicSettings()
	AddFontSettings()
	AddTrackingSettings()
end