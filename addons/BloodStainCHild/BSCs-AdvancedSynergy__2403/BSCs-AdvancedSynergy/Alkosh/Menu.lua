---------------------------------------------------------------------------------------------------
-- BSCASynergy – Alkosh Menu (Tab 2)
---------------------------------------------------------------------------------------------------
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

---------------------------------------------------------------------------------------------------
-- 🔧 Helper
---------------------------------------------------------------------------------------------------
local s_choices, s_sounds = {}, {}

local function PopulateSounds()
	if #s_choices == 0 then
		for k, v in pairs(BSCAS.SOUNDLIST) do
			table.insert(s_choices, v)
			table.insert(s_sounds, k)
		end
	end
end

local function AddControl(data)
	BSCAS:AddControlToTab(2, data)
end

---------------------------------------------------------------------------------------------------
-- ⚙️ Main Alkosh UI Settings
---------------------------------------------------------------------------------------------------
function BSCAS:AddAlkoshSetting()
	PopulateSounds()

	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV_Char.ALKOSH_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("ALKOSH", v)
		end,
	})
	AddControl({ type = "divider", })
	-- 🔹 Automatische Erkennung
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_ALKOSHUI_AUTO),
		tooltip = GetString(SI_SYNERGY_ALKOSHUI_AUTO_DESC),
		getFunc = function() return BSCAS.SV.ALKOSH_CHECK_AUTO end,
		setFunc = function(value)
			BSCAS.SV.ALKOSH_CHECK_AUTO = value
			BSCAS:CheckEquipment()
		end,
	})

	-- 🔹 Anzeige aktivieren
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_ALKOSHUI),
		getFunc = function() return BSCAS.SV.ALKOSH_CHECK end,
		setFunc = function(value)
			BSCAS.SV.ALKOSH_CHECK = value
			if value then
				BSCAS.AlkoshEnable()
			else
				BSCAS.AlkoshDisable()
			end
		end,
	})

	-- 🔹 UI sperren
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_LOCK),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		getFunc = function() return BSCAS.SV.ALKOSH_LOCK_UI end,
		setFunc = function(v)
			BSCAS.SV.ALKOSH_LOCK_UI = v
			BSCASAlkoshUI:SetMovable(not v)
		end,
	})

	-- 🔹 Breite / Höhe / Transparenz
	local function SizeUpdate()
		BSCAS.AlkoshRefreshLayout()
		BSCAS.AlkoshDummyList()
	end

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_WIDTH),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		min = 100, max = 600, step = 1, default = 250,
		getFunc = function() return BSCAS.SV.UI_WIDTH end,
		setFunc = function(v) BSCAS.SV.UI_WIDTH = v SizeUpdate() end,
	})
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_HIGHT),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		min = 20, max = 250, step = 1, default = 40,
		getFunc = function() return BSCAS.SV.UI_HIGHT end,
		setFunc = function(v) BSCAS.SV.UI_HIGHT = v SizeUpdate() end,
	})
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_UI_ALPHA),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		min = 0.1, max = 1, step = 0.1, default = 1,
		getFunc = function() return BSCAS.SV.UI_ALPHA end,
		setFunc = function(v) BSCAS.SV.UI_ALPHA = v SizeUpdate() end,
	})

	-- 🔹 Listengröße
	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_ALKOSH_LIST),
		tooltip = GetString(SI_SYNERGY_ALKOSH_COUNT),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		min = (MAX_BOSSES - 1), max = 25, step = 1, default = 10,
		getFunc = function() return BSCAS.SV.ALKOSH_LIST_COUNT end,
		setFunc = function(v)
			BSCAS.SV.ALKOSH_LIST_COUNT = v
			SizeUpdate()
		end,
	})

	---------------------------------------------------------------------------------------------------
	-- 🔊 Sound Settings
	---------------------------------------------------------------------------------------------------
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_NAME_SOUND_ON_OFF),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		getFunc = function() return BSCAS.SV.ALKOSH_SOUND_PLAY end,
		setFunc = function(value)
			BSCAS.SV.ALKOSH_SOUND_PLAY = value
			-- Schließt MSlayer ab, wenn beide aktiv
			if BSCAS.SV.MSLAYER_SOUND_PLAY and value then
				BSCAS.SV.MSLAYER_SOUND_PLAY = false
			end
		end,
	})

	AddControl({
		type = "dropdown",
		name = GetString(SI_SYNERGY_NAME_SOUND_CHOOSE),
		choices = s_choices,
		scrollable = 12,
		default = "Voice_Chat_Alert_Channel_Made_Active",
		disabled = function()
			return not BSCAS.SV.ALKOSH_CHECK or not BSCAS.SV.ALKOSH_SOUND_PLAY
		end,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCAS.SV.ALKOSH_SOUND_ID then
					return s_choices[i]
				end
			end
			return "Voice_Chat_Alert_Channel_Made_Active"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCAS.SV.ALKOSH_SOUND_ID = s_sounds[i]
					BSCAS.PlaySound(BSCAS.SV.ALKOSH_SOUND_LOOP, BSCAS.SV.ALKOSH_SOUND_ID)
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
			return not BSCAS.SV.ALKOSH_CHECK or not BSCAS.SV.ALKOSH_SOUND_PLAY
		end,
		getFunc = function() return BSCAS.SV.ALKOSH_SOUND_LOOP end,
		setFunc = function(v) BSCAS.SV.ALKOSH_SOUND_LOOP = v end,
	})

	AddControl({
		type = "button",
		name = GetString(SI_SYNERGY_SOUND_TEST),
		disabled = function()
			return not BSCAS.SV.ALKOSH_CHECK or not BSCAS.SV.ALKOSH_SOUND_PLAY
		end,
		func = function()
			BSCAS.PlaySound(BSCAS.SV.ALKOSH_SOUND_LOOP, BSCAS.SV.ALKOSH_SOUND_ID)
		end,
	})

	AddControl({
		type = "slider",
		name = GetString(SI_SYNERGY_NAME_SOUND_TIME),
		min = 0, max = 4, step = 1, default = 1,
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		getFunc = function() return BSCAS.SV.ALKOSH_SOUND_INC end,
		setFunc = function(v) BSCAS.SV.ALKOSH_SOUND_INC = v end,
	})

	---------------------------------------------------------------------------------------------------
	-- 🧭 Boss Marker
	---------------------------------------------------------------------------------------------------
	AddControl({
		type = "checkbox",
		name = GetString(SI_SYNERGY_UI_MARK) .. GetString(SI_SYNERGY_UI_MARK_BOSS),
		tooltip = GetString(SI_SYNERGY_UI_MARK_DESC),
		disabled = function() return not BSCAS.SV.ALKOSH_CHECK end,
		getFunc = function() return BSCAS.SV.ALKOSH_ENABLE_MARK end,
		setFunc = function(value)
			BSCAS.SV.ALKOSH_ENABLE_MARK = value
			SizeUpdate()
		end,
	})
end
