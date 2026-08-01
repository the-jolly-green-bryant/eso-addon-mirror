BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

--BSCAS.SV
local defaultSV = {	
	-- Blocking
	PVP_AREA_ENABLED = false,
	ADD_WW_PLUGIN = false,
	SELECTED_PRESET = "Default",
	SELECTED_PRESET_TANK = "Default",
	SELECTED_PRESET_HEAL = "Default",
	SELECTED_PRESET_DPS = "Default",
	-- Alkosh UI
	ALKOSH_CHECK = false,
	ALKOSH_CHECK_AUTO = false,
	ALKOSH_SOUND_PLAY = false,
	ALKOSH_SOUND_INC = 2,
	ALKOSH_SOUND_ID = "Voice_Chat_Alert_Channel_Made_Active",
	ALKOSH_SOUND_LOOP = 1,
	ALKOSH_FONT_SIZE = 16,
	ALKOSH_LIST_COUNT = 10,
	ALKOSH_ENABLE_MARK = true,
	ALKOSH_LOCK_UI = false,
	ALKOSH_PRINT_CHAT = true,
	ALKOSH_REAPPLY = 3, -- moved to presets
	UI_LEFT = 200,
	UI_TOP  = 200,
	UI_WIDTH = 300,
	UI_HIGHT = 30,
	UI_ALPHA = 1,
	-- Slayer UI
	MSLAYER_CHECK = false,
	MSLAYER_SOUND_PLAY = false,
	MSLAYER_SOUND_INC = 2,
	MSLAYER_SOUND_ID = "Duel_Accepted", 
	MSLAYER_SOUND_LOOP = 1,
	MSLAYER_ENABLE_NAME = true,
	MSLAYER_ENABLE_ICON = true,
	MSLAYER_FONT_SIZE = 16,
	MSLAYER_LOCK_UI = false,
	MSLAYER_ENABLE_AUTO_HIDE = false,
	UIMS_LEFT = 200,
	UIMS_TOP  = 100,
	UIMS_WIDTH = 250,
	UIMS_HIGHT = 40,
	UIMS_ALPHA = 1,
	-- Tracking UI
	TRACKING_UI_FONT = "BOLD_FONT",
	TRACKING_UI_FONT_STYLE = "soft-shadow-thick", 
	TRACKING_UI_FONT_COLOR_N = {0, 255, 0, 255},
	TRACKING_UI_FONT_COLOR_C = {255, 0, 0, 255},
	TRACKING_ENABLED = false,
	TRACKING_LOCK_UI = false,
	TRACKING_UI_ORIENT = "Vertical",
	TRACKING_UI_SIZE = 40,
	TRACKING_UI_SIZE_OUTLINE = 3,
	TRACKING_UI_LEFT = 200,
	TRACKING_UI_TOP = 400,
	TRACKING_UI_ALPHA = 1,
	TRACKING_ONLY_ACTIVE = false,
	TRACKING_UI_TSG_LIST = { 
		BLOODALTAR 	= true, -- undaunted
		SPIDERS		= true, -- undaunted
		INNERFIRE	= true, -- undaunted
		BONESHIELD 	= true, -- undaunted
		SHARTSORBS	= true,	-- templar + orbs
		PURIFY		= true,	-- templar
		CONDUIT 	= true, -- sorc
		ATRONACH	= true, -- sorc
		SHACKLE		= true, -- dk
		HARVEST		= true, -- Warden
		GRAVEROBBER = true, -- Necro
		PUREAGONY	= true, -- Necro
		RUNE		= true, -- Arcanist
		PORTAL 		= true, -- Arcanist
		HOWLING		= true, -- Werwolf
		KRAGLEN		= true, -- Kraglen's Howl
		LADYTHORN	= true, -- Sanguine Burst
		URSUS		= true, -- Ursus
		GPREPRISAL 	= true, -- Gryphon's Reprisa		
		CR_PRTAL 	= true, --
		DSR_REEF 	= true, -- 
		SE_PORTAL	= true, --
		OC_SHIELD	= false, --
	},
	-- Group Tracking
	GROUP_TRACKING_ENABLED = false,
	GROUP_TRACKING_UI_TSG_LIST = { 
		BLOODALTAR 	= false, -- undaunted
		SPIDERS		= false, -- undaunted
		INNERFIRE	= false, -- undaunted
		BONESHIELD 	= false, -- undaunted
		SHARTSORBS	= false, -- templar + orbs
		PURIFY		= false, -- templar
		CONDUIT 	= false, -- sorc
		ATRONACH	= false, -- sorc
		SHACKLE		= false, -- dk
		HARVEST		= false, -- Warden
		GRAVEROBBER = false, -- Necro
		PUREAGONY	= false, -- Necro
		RUNE		= false, -- Arcanist
		PORTAL 		= false, -- Arcanist
		HOWLING		= false, -- Werwolf
		KRAGLEN		= false, -- Kraglen's Howl
		LADYTHORN	= false, -- Sanguine Burst
		URSUS		= false, -- Ursus
		GPREPRISAL 	= false, -- Gryphon's Reprisa
		CR_PRTAL 	= false, --
		DSR_REEF 	= false, -- 
		SE_PORTAL	= false, --
		OC_SHIELD	= false, --
	},
	GROUP_TRACKING_UI_POSITION = { },
	GROUP_TRACKING_TANK = true,
	GROUP_TRACKING_HEAL = true,
	GROUP_TRACKING_DPS = true,	
	GROUP_TRACKING_ONLY_ACTIVE = false,
	GROUP_TRACKING_ROW_HEIGHT = 24, -- default not in settings
	GROUP_TRACKING_MAX_WIDTH = 240,
	GROUP_TRACKING_MAX_HEIGHT = 260,
	-- Target Tracking
	TARGET_TRACKING_ENABLED = false,
	TARGET_TRACKING_UI_PLAYER = { },
	TARGET_TRACKING_SELECTED_PLAYER = GetUnitDisplayName('player'),--"@Default",
	TARGET_TRACKING_USEACCNAME = true,
	TARGET_TRACKING_ONLY_ACTIVE = false,
	TARGET_TRACKING_ROW_HEIGHT = 24, -- default not in settings
	TARGET_TRACKING_MAX_WIDTH = 240,
	TARGET_TRACKING_MAX_HEIGHT = 200,	
	-- Prority UI
	PRIO_UI_ENABLE = false,
	PRIO_UI_LEFT = 300,
	PRIO_UI_TOP = 300,
	PRIO_LOCK_UI = false,
	SELECTED_PRIO_PRESET = "Default",
	SELECTED_PRIO_PRESET_TANK = "Default",
	SELECTED_PRIO_PRESET_HEAL = "Default",
	SELECTED_PRIO_PRESET_DPS = "Default",
	
	--------------------------------------------------------
    -- NEU: Modul-Toggles (liegen char-spezifisch!)
    --------------------------------------------------------
	BLOCKING_USE_ACCOUNT = true,
	ALKOSH_USE_ACCOUNT = true,
    MSLAYER_USE_ACCOUNT = true,
    TRACKING_USE_ACCOUNT = true,
    GROUP_TRACKING_USE_ACCOUNT = true,
    TARGET_TRACKING_USE_ACCOUNT = true,
    PRIO_USE_ACCOUNT = true,
	
	PRINT_BLOCKING_PRESET_LOADED = false,
	PRINT_PRIORITY_PRESET_LOADED = false,
}

--BSCAS.SV_acc
local defaultSavedVarsAccount = { 
	VERSION_ALERT = 1,
	DEBUG_LIST = {},
	SETTING = {}, -- Blocking Presets
	UIALERT_TOP = 0,
	UIALERT_LEFT = 0,
	UIALERT_COLOR = { 0, 0.8, 0, 0.4 },
	SHOW_USED_MEMPRY = false,
	SYNERGY_LIST = { },
	PRIO_PRESETS = { },
	
	ACCOUNT_SETTINGS = {}, -- füllen wir unten mit deepCopy(defaultSV)
}

-- =====================================================================
-- Modul-Key-Mapping (für per-Key Routing)
-- =====================================================================
local MODULE_KEYS = {
	BLOCKING = {
		"PVP_AREA_ENABLED", "ADD_WW_PLUGIN", 
		"SELECTED_PRESET", "SELECTED_PRESET_TANK", "SELECTED_PRESET_HEAL", "SELECTED_PRESET_DPS",
	},
    ALKOSH = {
        "ALKOSH_CHECK","ALKOSH_CHECK_AUTO","ALKOSH_SOUND_PLAY","ALKOSH_SOUND_INC",
        "ALKOSH_SOUND_ID","ALKOSH_SOUND_LOOP","ALKOSH_FONT_SIZE","ALKOSH_LIST_COUNT",
        "ALKOSH_ENABLE_MARK","ALKOSH_LOCK_UI","ALKOSH_PRINT_CHAT","ALKOSH_REAPPLY",
        "UI_LEFT","UI_TOP","UI_WIDTH","UI_HIGHT","UI_ALPHA",
    },
    MSLAYER = {
        "MSLAYER_CHECK","MSLAYER_SOUND_PLAY","MSLAYER_SOUND_INC","MSLAYER_SOUND_ID",
        "MSLAYER_SOUND_LOOP","MSLAYER_ENABLE_NAME","MSLAYER_ENABLE_ICON","MSLAYER_FONT_SIZE",
        "MSLAYER_LOCK_UI","MSLAYER_ENABLE_AUTO_HIDE","UIMS_LEFT","UIMS_TOP","UIMS_WIDTH","UIMS_HIGHT","UIMS_ALPHA",
    },
    TRACKING = {
        "TRACKING_UI_FONT","TRACKING_UI_FONT_STYLE","TRACKING_UI_FONT_COLOR_N","TRACKING_UI_FONT_COLOR_C",
        "TRACKING_ENABLED","TRACKING_LOCK_UI","TRACKING_UI_ORIENT","TRACKING_UI_SIZE","TRACKING_UI_SIZE_OUTLINE",
        "TRACKING_UI_LEFT","TRACKING_UI_TOP","TRACKING_UI_ALPHA","TRACKING_ONLY_ACTIVE","TRACKING_UI_TSG_LIST",
    },
    GROUP_TRACKING = {
        "GROUP_TRACKING_ENABLED","GROUP_TRACKING_UI_TSG_LIST","GROUP_TRACKING_UI_POSITION",
        "GROUP_TRACKING_TANK","GROUP_TRACKING_HEAL","GROUP_TRACKING_DPS",
        "GROUP_TRACKING_ONLY_ACTIVE","GROUP_TRACKING_ROW_HEIGHT","GROUP_TRACKING_MAX_WIDTH","GROUP_TRACKING_MAX_HEIGHT",
    },
    TARGET_TRACKING = {
        "TARGET_TRACKING_ENABLED","TARGET_TRACKING_UI_PLAYER","TARGET_TRACKING_SELECTED_PLAYER","TARGET_TRACKING_USEACCNAME",
        "TARGET_TRACKING_ONLY_ACTIVE","TARGET_TRACKING_ROW_HEIGHT","TARGET_TRACKING_MAX_WIDTH","TARGET_TRACKING_MAX_HEIGHT",
    },
    PRIO = {
        "PRIO_UI_ENABLE","PRIO_UI_LEFT","PRIO_UI_TOP","PRIO_LOCK_UI",
        "SELECTED_PRIO_PRESET","SELECTED_PRIO_PRESET_TANK","SELECTED_PRIO_PRESET_HEAL","SELECTED_PRIO_PRESET_DPS",
    },
}

-- Keys, die IMMER char-spezifisch bleiben sollen
local ALWAYS_CHAR_KEYS = {
	SELECTED_PRESET        = true,
	SELECTED_PRIO_PRESET        = true,
}
local function isAlwaysCharKey(k)
    return ALWAYS_CHAR_KEYS[k] == true
end

-- Build reverse map: KEY -> MODULE
local KEY_TO_MODULE = {}
for mod, keys in pairs(MODULE_KEYS) do
    for _,k in ipairs(keys) do KEY_TO_MODULE[k] = mod end
end

-- =====================================================================
-- Helpers
-- =====================================================================
local function deepCopy(v)
    if type(v) ~= "table" then return v end
    local t = {}
    for k,val in pairs(v) do t[k] = deepCopy(val) end
    return t
end

local function isUseAccountKey(k)
    return type(k) == "string" and k:sub(-12) == "_USE_ACCOUNT"
end

-- Aktive Storage-Tabelle für ein Modul
local function storeForModule(mod)
    if not BSCAS.SV_Char then return nil end
    local flag = mod .. "_USE_ACCOUNT"
    if BSCAS.SV_Char[flag] == true then
        return BSCAS.SV_acc.ACCOUNT_SETTINGS
    else
        return BSCAS.SV_Char
    end
end

-- =====================================================================
-- Öffentliche API
-- =====================================================================
-- Umschalten Char <-> Account inkl. Kopieren der aktuellen Werte
local function copyKeys(src, dst, keys)
    for _, k in ipairs(keys) do
        if not isAlwaysCharKey(k) then
            dst[k] = deepCopy(src[k])
        end
    end
end

-- Ruft nach einem Umschalten die passenden UI-Refreshes auf
function BSCAS.ApplyModuleUI(module)
    if module == "ALKOSH" then
		BSCAS.AlkoshApplyMetrics()
		BSCAS.AlkoshRefreshLayout()
    elseif module == "MSLAYER" then
        BSCAS:MSlayerRestorePosition()
    elseif module == "TRACKING" then
        BSCAS:TrackRestorePosition()
		BSCAS.TrackUpdateUI()
    elseif module == "GROUP_TRACKING" then
        BSCAS:GroupTrackApplyUI()
    elseif module == "TARGET_TRACKING" then
		BSCAS.TargetTrackApplyUI()
    elseif module == "PRIO" then
        BSCAS:PriorityRestorePosition()		
		BSCAS:InitPrioPresets()
		BSCAS:UpdatePrioSettings()
    end
end

function BSCAS.SetUseAccount(module, value, opts)
    local flag = module .. "_USE_ACCOUNT"
    if not BSCAS.SV_Char then return end
    if BSCAS.SV_Char[flag] == value then return end

    -- Optional: nur beim ERSTEN Aktivieren fehlende Account-Keys mit Char-Werten vorbefüllen
    if value and opts and opts.prefillIfNil and MODULE_KEYS[module] then
        for _, k in ipairs(MODULE_KEYS[module]) do
            if BSCAS.SV_acc.ACCOUNT_SETTINGS[k] == nil then
                BSCAS.SV_acc.ACCOUNT_SETTINGS[k] = deepCopy(BSCAS.SV_Char[k])
            end
        end
    end

    -- Umschalten – KEIN Kopieren in den anderen Store!
    BSCAS.SV_Char[flag] = value

    -- UI der betroffenen Sektion neu anwenden
	BSCAS.ApplyModuleUI(module)
end

-- Optionaler Helfer für Module (falls du ihn weiter nutzen willst)
function BSCAS:GetSV(module)
    return storeForModule(module) or BSCAS.SV_Char
end

-- =====================================================================
-- Proxy/Overlay: BSCAS.SV
--   - __index  / __newindex routen Key-basiert in richtigen Store
--   - __pairs iteriert Union der Keys (Char + Account), Werte aus aktivem Store
-- =====================================================================
local function makeOverlay()
    local overlay = {}

    local function index(_, k)
        -- 1) Flags bleiben in SV_Char
        if isUseAccountKey(k) then
            return BSCAS.SV_Char[k]
        end
        -- 2) Always-char keys: IMMER aus SV_Char lesen
        if isAlwaysCharKey(k) then
            return BSCAS.SV_Char and BSCAS.SV_Char[k] or nil
        end
        -- 3) Modulrouting
        local mod = KEY_TO_MODULE[k]
        if mod then
            local s = storeForModule(mod)
            return s and s[k] or nil
        end
        -- 4) Fallback
        return (BSCAS.SV_Char and BSCAS.SV_Char[k]) or (BSCAS.SV_acc.ACCOUNT_SETTINGS and BSCAS.SV_acc.ACCOUNT_SETTINGS[k])
    end

    local function newindex(_, k, v)
        -- 1) Flags in SV_Char
        if isUseAccountKey(k) then
            BSCAS.SV_Char[k] = v
            return
        end
        -- 2) Always-char keys: IMMER in SV_Char schreiben
        if isAlwaysCharKey(k) then
            if BSCAS.SV_Char then BSCAS.SV_Char[k] = deepCopy(v) end
            return
        end
        -- 3) Modulrouting
        local mod = KEY_TO_MODULE[k]
        if mod then
            local s = storeForModule(mod)
            if s then s[k] = deepCopy(v) else
                if BSCAS.SV_Char then BSCAS.SV_Char[k] = deepCopy(v) end
            end
            return
        end
        -- 4) Fallback: unbekannte Keys in SV_Char
        if BSCAS.SV_Char then BSCAS.SV_Char[k] = deepCopy(v) end
    end

    local function pairs_iter(_, last_key)
        -- unverändert: deine bisherige Union-Logik ist ok,
        -- Werte werden beim Iterieren ohnehin über `index` geholt.
        local seen = {}
        local keys = {}

        if BSCAS.SV_Char then
            for k in pairs(BSCAS.SV_Char) do
                seen[k] = true
                keys[#keys+1] = k
            end
        end
        if BSCAS.SV_acc and BSCAS.SV_acc.ACCOUNT_SETTINGS then
            for k in pairs(BSCAS.SV_acc.ACCOUNT_SETTINGS) do
                if not seen[k] then
                    keys[#keys+1] = k
                end
            end
        end

        table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)

        local i = 0
        return function()
            i = i + 1
            local k = keys[i]
            if k == nil then return nil end
            return k, index(nil, k)
        end
    end

    return setmetatable(overlay, {
        __index    = index,
        __newindex = newindex,
        __pairs    = function(t) return pairs_iter, t, nil end,
        __ipairs   = function() return function() return nil end end,
    })
end


-- =========================
-- Load/Init
-- =========================
function BSCAS.LoadSavedData()
	-- Saved vars are needed
	BSCAS.SV_Char	= ZO_SavedVars:NewCharacterNameSettings(BSCAS.SavedVar, BSCAS.Version, nil, defaultSV)
	BSCAS.SV_acc 	= ZO_SavedVars:NewAccountWide(BSCAS.SavedVar, BSCAS.Version, nil, defaultSavedVarsAccount)	

    -- 2) AccountSettings-Default einmalig befüllen (nur wenn leer)
    if not BSCAS.SV_acc.ACCOUNT_SETTINGS or next(BSCAS.SV_acc.ACCOUNT_SETTINGS) == nil then
        BSCAS.SV_acc.ACCOUNT_SETTINGS = deepCopy(defaultSV)
    end

    -- 3) (Optional) *_USE_ACCOUNT-Flags NICHT im Account-Store halten
    for k,_ in pairs(BSCAS.SV_acc.ACCOUNT_SETTINGS) do
        if isUseAccountKey(k) then
            BSCAS.SV_acc.ACCOUNT_SETTINGS[k] = nil
        end
    end

    -- 4) Overlay zuweisen – ab hier überall weiter BSCAS.SV benutzen
    BSCAS.SV = makeOverlay() 
end