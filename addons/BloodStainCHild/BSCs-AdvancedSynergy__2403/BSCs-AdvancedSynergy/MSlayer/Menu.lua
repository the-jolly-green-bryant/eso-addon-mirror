---------------------------------------------------------------------------------------------------
-- BSCASynergy – MSlayer Menu (Tab 3)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper
---------------------------------------------------------------------------------------------------
local s_choices = {}
local s_sounds  = {}

local function PopulateSounds()
	if #s_choices == 0 then
		for k, v in pairs(BSCAS.SOUNDLIST) do
			table.insert(s_choices, v)
			table.insert(s_sounds, k)
		end
	end
end

local function AddControl(data)
	BSCAS:AddControlToTab(3, data)
end

local function UpdateUI()
	BSCAS.MSlayerUpdateUI()
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Main Function
---------------------------------------------------------------------------------------------------
function BSCAS:AddMSlayerSetting()
	PopulateSounds()

	---------------------------------------------------------------------------------------------------
	-- 🧩 UI Grundfunktionen
	---------------------------------------------------------------------------------------------------	
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV_Char.MSLAYER_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("MSLAYER", v)
		end,
	})
	AddControl({ type = "divider", })
	
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_MSLAYERUI),
		getFunc = function() return BSCAS.SV.MSLAYER_CHECK end,
		setFunc = function(value)
			BSCAS.SV.MSLAYER_CHECK = value
			UpdateUI()
			BSCAS.MSlayerEnable()
		end,
	})

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_LOCK),
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_LOCK_UI end,
		setFunc = function(v)
			BSCAS.SV.MSLAYER_LOCK_UI = v
			BSCASMSlayerUI:SetMovable(not v)
		end,
	})

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SLAYER_HIDE),
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE end,
		setFunc = function(v)
			BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE = v
			BSCAS.MSlayerEnable()
		end,
	})

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SLAYER_DNAME),
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_ENABLE_NAME end,
		setFunc = function(v)
			BSCAS.SV.MSLAYER_ENABLE_NAME = v
			UpdateUI()
		end,
	})

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SLAYER_DICON),
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_ENABLE_ICON end,
		setFunc = function(v)
			BSCAS.SV.MSLAYER_ENABLE_ICON = v
			UpdateUI()
		end,
	})

	---------------------------------------------------------------------------------------------------
	-- 📐 UI Größe / Transparenz
	---------------------------------------------------------------------------------------------------
	local function SizeUpdate()
		UpdateUI()
	end

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_WIDTH),
		min = 100, max = 600, step = 1, default = 250,
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.UIMS_WIDTH end,
		setFunc = function(v)
			BSCAS.SV.UIMS_WIDTH = v
			SizeUpdate()
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_HIGHT),
		min = 20, max = 250, step = 1, default = 40,
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.UIMS_HIGHT end,
		setFunc = function(v)
			BSCAS.SV.UIMS_HIGHT = v
			SizeUpdate()
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_ALPHA),
		min = 0.1, max = 1, step = 0.1, default = 1,
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.UIMS_ALPHA end,
		setFunc = function(v)
			BSCAS.SV.UIMS_ALPHA = v
			SizeUpdate()
		end,
	})

	---------------------------------------------------------------------------------------------------
	-- 🔊 Sound Settings
	---------------------------------------------------------------------------------------------------
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_NAME_SOUND_ON_OFF),
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_SOUND_PLAY end,
		setFunc = function(value)
			BSCAS.SV.MSLAYER_SOUND_PLAY = value
			UpdateUI()
		end,
	})

	AddControl({
		type = "dropdown",
		name = GetString(SI_SYNERGY_NAME_SOUND_CHOOSE),
		choices = s_choices,
		scrollable = 12,
		default = "Duel_Accepted",
		disabled = function()
			return not BSCAS.SV.MSLAYER_CHECK or not BSCAS.SV.MSLAYER_SOUND_PLAY
		end,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCAS.SV.MSLAYER_SOUND_ID then
					return s_choices[i]
				end
			end
			return "Duel_Accepted"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCAS.SV.MSLAYER_SOUND_ID = s_sounds[i]
					BSCAS.PlaySound(BSCAS.SV.MSLAYER_SOUND_LOOP, BSCAS.SV.MSLAYER_SOUND_ID)
					return
				end
			end
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_SOUND_VOLL),
		min = 1, max = 10, step = 1, default = 1,
		disabled = function()
			return not BSCAS.SV.MSLAYER_CHECK or not BSCAS.SV.MSLAYER_SOUND_PLAY
		end,
		getFunc = function() return BSCAS.SV.MSLAYER_SOUND_LOOP end,
		setFunc = function(v) BSCAS.SV.MSLAYER_SOUND_LOOP = v end,
	})

	AddControl({
		type = "button",
		name = GetString(SI_SYNERGY_SOUND_TEST),
		disabled = function()
			return not BSCAS.SV.MSLAYER_CHECK or not BSCAS.SV.MSLAYER_SOUND_PLAY
		end,
		func = function()
			BSCAS.PlaySound(BSCAS.SV.MSLAYER_SOUND_LOOP, BSCAS.SV.MSLAYER_SOUND_ID)
		end,
	})
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_NAME_SOUND_TIME),
		min = 0, max = 5, step = 1, default = 1,
		disabled = function() return not BSCAS.SV.MSLAYER_CHECK end,
		getFunc = function() return BSCAS.SV.MSLAYER_SOUND_INC end,
		setFunc = function(v) BSCAS.SV.MSLAYER_SOUND_INC = v end,
	})
end