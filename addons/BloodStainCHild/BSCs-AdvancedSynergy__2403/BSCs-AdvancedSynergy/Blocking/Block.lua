BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local debug_mode = false
function BSCAS.BlockDebugMode()
	if debug_mode then
		debug_mode = false
		BSCAS:PrintDebug("Debug Mode (Block Synergie) Disabled!")
	else
		debug_mode = true
		BSCAS:PrintDebug("Debug Mode (Block Synergie) Enabled!")
	end
end
local function PrintDebug(FormatedText)
	if debug_mode then
		BSCAS:PrintDebug(FormatedText)
	end
end

local PRIO_BLOCKED = 666
local API_GE_101048 = GetAPIVersion() >= 101048

------------------------------------------------------------------------------
-- Basic stuff
------------------------------------------------------------------------------
local default_setting = 
{
	LOKKECHECK = false,
	ALKOSHCHECK = false,
	ONLYINCOMBAT = false,
	NEW_BARCHECK = -1,
	BERSERK_CHECK = false,
	-- Resource Settings
	RESOURCES_CHECK_SETS = false,
	RESOURCES_CHECK = false,
	RESOURCES_VALUE_S = 80,
	RESOURCES_VALUE_M = 80,

	-- UNDAUNTED
	UNDAUNTED_ALTAR = true,
	UNDAUNTED_WEBS = true,
	UNDAUNTED_FIRE = true,
	UNDAUNTED_BONE = true,
	UNDAUNTED_ORB = true,
	UNDAUNTED_ORB_HEALING = true,	
	
	UNDAUNTED_ALTAR_IGCHK = false,
	UNDAUNTED_WEBS_IGCHK = false,
	UNDAUNTED_FIRE_IGCHK = false,
	UNDAUNTED_BONE_IGCHK = false,
	UNDAUNTED_ORB_IGCHK = false,
	UNDAUNTED_ORB_HEALING_IGCHK = false,
	-- Templar
	TEMPLAR_SHARDS = true,
	TEMPLAR_SHARDS_DMG = true,	
	TEMPLAR_PURGE = true,
	TEMPLAR_NOVA = true,	
	
	TEMPLAR_SHARDS_IGCHK = false,	
	TEMPLAR_SHARDS_DMG_IGCHK = false,	
	TEMPLAR_PURGE_IGCHK = false,
	TEMPLAR_NOVA_IGCHK = false,
	-- Sorc
	SORC_ATRO = true,
	SORC_CONDUIT = true,	
	SORC_ATRO_IGCHK = false,
	SORC_CONDUIT_IGCHK = false,
	-- DK
	DK_IMPALE = true,
	DK_STANDARTE = true,	
	DK_IMPALE_IGCHK = false,
	DK_STANDARTE_IGCHK = false,
	-- NB
	NB_DARK = true,
	NB_SOUL = true,		
	NB_DARK_IGCHK = false,
	NB_SOUL_IGCHK = false,
	-- wardn
	WARDEN_HARVEST = true,	
	WARDEN_ICYESC = true,	
	WARDEN_HARVEST_IGCHK = false,
	WARDEN_ICYESC_IGCHK = false,
	-- Necro
	NECRO_BONEYARD = true,
	NECRO_TOTEM = true,	
	NECRO_BONEYARD_IGCHK = false,
	NECRO_TOTEM_IGCHK = false,
	-- Arcanist
	ARCANIST_RUNE  = true,
	ARCANIST_PORTAL = true,
	ARCANIST_RUNE_IGCHK = false,
	ARCANIST_PORTAL_IGCHK = false,
	-- WW
	WW_HUNT = true,	
	WW_HUNT_IGCHK = false,
	WW_DEVOUR = true,
	WW_DEVOUR_IGCHK = false,	
	WW_DEVOUR_OOCB = false,
	-- Vamp
	VAMP_EAT = true,	
	VAMP_EAT_IGCHK = false,
	-- BH
	HOOD_BLADE = true,	
	HOOD_BLADE_IGCHK = false,
	
	-- Trail
	CR_PORTAL = true,
	CR_PORTAL_BLOCK_DB = false,
	HRC_CONFIRM = false,
	SS_PORTAL = true,
	KA_PORTAL = true,
	KA_EXECRATION = true,
	DSR_SURGING_WATERS = true,
	DSR_SURGING_WATERS_BLOCK_DB = false,
	DSR_SURGING_WATERS_CD = 20,
	
		
	CR_PORTAL_IGCHK = true,
	HRC_CONFIRM_IGCHK = true,
	SS_PORTAL_IGCHK = true,
	KA_PORTAL_IGCHK = true,
	KA_EXECRATION_IGCHK = true,	
	DSR_SURGING_WATERS_IGCHK = true,
	
	RG_PURGE_BLOCK = true,
	RG_PURGE_BLOCK_CD = 2000,
	RG_PURGE_BLOCK_ALERT = true,
	RG_PURGE_BLOCK_IGCHK = true,
	
	SE_VANTONS_CLARITY = true,
	SE_VANTONS_CLARITY_IGCHK = true,
	
	SE_ATTUNEMENT = true,
	SE_ATTUNEMENT_IGCHK = true,
	
	LC_MIRROR = true,
	LC_MIRROR_IGCHK = true,
	LC_MIRROR_BLOCK_DB = false,
	-- OC Raid
	OC_CARRIONSHIELD = true,
	OC_CARRIONSHIELD_BLOCK_DB = false,
	OC_CARRIONSHIELD_CD = 4,
	OC_CARRIONSHIELD_IGCHK = true,	
	-- OC Raid Portal
	OC_DREADFUL_PORTAL = true, -- Block in combat
	OC_DREADFUL_PORTAL_IGCHK = true,
	OC_DREADFUL_PORTAL_OOCB = true, -- Enable out of combat and block in combat
	
	-- Arena
	ARENA_RESURRECTION = true,
	ARENA_DEFENSE = true,
	ARENA_HEALING = true,
	ARENA_SUSTAIN = true,
	ARENA_POWER = true,
	ARENA_HASTE = true,
	
	ARENA_RESURRECTION_IGCHK = true,
	ARENA_DEFENSE_IGCHK = true,
	ARENA_HEALING_IGCHK = true,
	ARENA_SUSTAIN_IGCHK = true,
	ARENA_POWER_IGCHK = true,
	ARENA_HASTE_IGCHK = true,
	
	-- item sets
	ITEM_URSUS = true,
	ITEM_KRAGLEN = true,
	ITEM_SANGUINE = true,
	ITEM_GPREPRISAL = true,
	
	ITEM_URSUS_IGCHK = true,
	ITEM_KRAGLEN_IGCHK = true,
	ITEM_SANGUINE_IGCHK = true,
	ITEM_GPREPRISAL_IGCHK = true,	
}

local function deepcopy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k,v in pairs(t) do r[k] = deepcopy(v) end
  return r
end

------------------------------------------------------------------------------
-- Checking functions 
------------------------------------------------------------------------------
local CHECK_RESOURCES = false
local function isLowStamina()
  local cur, max = GetUnitPower("player", POWERTYPE_STAMINA)
  if max == 0 then return false end
  return (cur * 100 / max) <= BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RESOURCES_VALUE_S
end
local function isLowMagica()
  local cur, max = GetUnitPower("player", POWERTYPE_MAGICKA)
  if max == 0 then return false end
  return (cur * 100 / max) <= BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RESOURCES_VALUE_M
end
local function lokkeCheck()	
	if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LOKKECHECK then return true end	
	local PLokke, NLokke = 0
	_,_,_,PLokke = GetItemLinkSetInfo(BSCAS.LOKKE_ITEM[1], true)
	_,_,_,NLokke = GetItemLinkSetInfo(BSCAS.LOKKE_ITEM[2], true)		
	PrintDebug(zo_strformat("Wearing Set info (Normal)[<<1>>] (Perfekt)[<<2>>]", NLokke, PLokke)) -- Debug check
	if (NLokke == 0) and (PLokke == 0) then return true end		-- if No lokke equiped and check is still on	
	if (NLokke >= 1 and NLokke <= 2) or (PLokke >= 1 and PLokke <= 2) then 
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Check your Lokke gear setup!!!") -- check if only one or 2 equpid and send warning!
	end
	if (NLokke >= 5) then return true end	
	if (PLokke >= 5) then return true end	
	return false
end
local function HasAlkosh()
	if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].ALKOSHCHECK then return true end
	if BSCAS.AlkoshBuffActive then return false end	
	local alkosh = 0
	_,_,_,alkosh = GetItemLinkSetInfo(BSCAS.ALKOSH_ITEM, true)
	PrintDebug(zo_strformat("Wearing Set info [<<1>>]", alkosh))	
	if (alkosh == 0) then return true end	
	if (alkosh >= 1 and alkosh <= 2) then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Check your Alkosh gear setup!!!")
	end	
	if (alkosh >= 5) then return true end	
	return false
end
function BSCAS:CheckEquipment()
	local setItemCount_B = 0
	local setItemCount_C = 0
	local setItemCount_MK = 0
	local setItemCount_Alkosh = 0
	local setItemCount_Pearls = 0
	for equipSlot = EQUIP_SLOT_ITERATION_BEGIN, EQUIP_SLOT_ITERATION_END do		
		if HasItemInSlot(BAG_WORN, equipSlot) then		
			local itemtype = GetItemType(BAG_WORN, equipSlot)			
			if itemtype == ITEMTYPE_ARMOR or itemtype == ITEMTYPE_WEAPON then
				local count = 1
				if itemtype == ITEMTYPE_WEAPON then 					
					if select(6, GetItemInfo(BAG_WORN, equipSlot)) == EQUIP_TYPE_TWO_HAND then
						count = 2 
					end
				end	
				local setId = select(6, GetItemLinkSetInfo(GetItemLink(BAG_WORN, equipSlot)))
				--
				if setId == BSCAS.B_SETID_N or setId == BSCAS.B_SETID_P then
					setItemCount_B = setItemCount_B + count
				end	
				--
				if setId == BSCAS.C_SETID_N or setId == BSCAS.C_SETID_P then
					setItemCount_C = setItemCount_C + count
				end	
				--
				if setId == BSCAS.MAKNO then
					setItemCount_MK = setItemCount_MK + count
				end	
				-- Alkosh
				if setId == BSCAS.ALKOSH_ITEM_SETID then
					setItemCount_Alkosh = setItemCount_Alkosh + count					
				end
				-- pearls mythic
				if setId == BSCAS.PEARLSOE then
					setItemCount_Pearls = setItemCount_Pearls + count	
				end
			end
		end
	end	
	-- Auto Enable Alkosh UI
	if setItemCount_Alkosh >= 5 then
		if BSCAS.SV.ALKOSH_CHECK_AUTO and not BSCAS.SV.ALKOSH_CHECK then
			BSCAS.SV.ALKOSH_CHECK = true
			BSCAS.AlkoshEnable()
		end
	else
		if BSCAS.SV.ALKOSH_CHECK_AUTO and BSCAS.SV.ALKOSH_CHECK then
			BSCAS.SV.ALKOSH_CHECK = false
			BSCAS.AlkoshDisable()
		end
	end
	-- Item set for resource check	
	if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RESOURCES_CHECK_SETS then 
		CHECK_RESOURCES = false 
		return
	end	
	if setItemCount_B >= 5 then
		CHECK_RESOURCES = true	
	elseif setItemCount_C >= 5 then
		CHECK_RESOURCES = true
	elseif setItemCount_MK >= 5 then
		CHECK_RESOURCES = true
	elseif setItemCount_Pearls >= 1 then
		CHECK_RESOURCES = true
	else 
		CHECK_RESOURCES = false
	end		
end
------------------------------------------------------------------------------
-- Check Synergies
------------------------------------------------------------------------------
local function mergeDefaults(into, defaults)
  for k, def in pairs(defaults) do
    if into[k] == nil then
      into[k] = deepcopy(def)    -- s.o.
    elseif type(def) == "table" and type(into[k]) == "table" then
      mergeDefaults(into[k], def)
    end
  end
end

local function ensurePreset(name)
  local p = BSCAS.SV_acc.SETTING[name]
  if not p then
    p = deepcopy(default_setting)
    BSCAS.SV_acc.SETTING[name] = p
  else
    mergeDefaults(p, default_setting) -- nur fehlende Keys ergänzen
  end
end

local function CheckPresets()
  for name in pairs(BSCAS.SV_acc.SETTING) do
    ensurePreset(name)
  end
end

local function PrintPortalInfo(name, bEnabeld)
	local pstatus = zo_strformat("<<1>>[<<2>><<3>><<4>>]", "|cb3b6b7", (bEnabeld and BSCAS.color_green or BSCAS.color_red), (bEnabeld and 'Enabled' or 'Disabled'), "|cb3b6b7")
	CHAT_ROUTER:AddSystemMessage(zo_strformat("BSCs-AS |cb3b6b7<<1>> <<2>>", name, pstatus))
end

------------------------------------------------------------------------------
-- Update data
------------------------------------------------------------------------------
local enabled_synergie = { }
local ignor_check = { }
local check_hotbar = { }	-- (-1 = ALL, 0 = Primary, 1 = Backup)
local out_of_combat = { } 

-- Cache für GetString, damit wir nicht zigmal aufrufen
local S = setmetatable({}, {
  __index = function(t, k)
    local v = GetString(_G[k]); rawset(t, k, v); return v
  end
})

-- Helfer: Tabelle "leeren", ohne Referenz zu verlieren
local function wipe(t) for k in pairs(t) do t[k] = nil end end

-- Deklaratives Mapping: welche Synergy-Strings gehören zu welchem Basis-Key?
-- base = "KEY" => verwendet KEY, KEY_IGCHK, KEY_HBCHK (falls vorhanden)
-- base = {"K1","K2"} => pro Eintrag der sids eigener Basis-Key (z.B. ORB1/ORB2)
-- has_ooc = true => liest zusätzlich KEY_OOCB in out_of_combat ein
local SPEC = {
  -- UNDAUNTED
  { sids = {"SI_SYNERGY_ABILITY_BLOODALTAR1","SI_SYNERGY_ABILITY_BLOODALTAR2"}, base="UNDAUNTED_ALTAR" },
  { sids = {"SI_SYNERGY_ABILITY_BLACK_WIDOWS1","SI_SYNERGY_ABILITY_BLACK_WIDOWS2"}, base="UNDAUNTED_WEBS" },
  { sids = {"SI_SYNERGY_ABILITY_INNERFIRE"},                                   base="UNDAUNTED_FIRE" },
  { sids = {"SI_SYNERGY_ABILITY_BONE1","SI_SYNERGY_ABILITY_BONE2"},            base="UNDAUNTED_BONE" },
  { sids = {"SI_SYNERGY_ABILITY_ORB1","SI_SYNERGY_ABILITY_ORB2"},              base={"UNDAUNTED_ORB","UNDAUNTED_ORB_HEALING"} },

  -- TEMPLAR
  { sids = {"SI_SYNERGY_ABILITY_SHARDS1"},                                     base="TEMPLAR_SHARDS" },
  { sids = {"SI_SYNERGY_ABILITY_SHARDS2"},                                     base="TEMPLAR_SHARDS_DMG" },
  { sids = {"SI_SYNERGY_ABILITY_PURGE"},                                       base="TEMPLAR_PURGE" },
  { sids = {"SI_SYNERGY_ABILITY_NOVA1","SI_SYNERGY_ABILITY_NOVA2"},            base="TEMPLAR_NOVA" },

  -- SORC
  { sids = {"SI_SYNERGY_ABILITY_ATRO"},                                        base="SORC_ATRO" },
  { sids = {"SI_SYNERGY_ABILITY_CONDUIT"},                                     base="SORC_CONDUIT" },

  -- DK
  { sids = {"SI_SYNERGY_ABILITY_IMPALE"},                                      base="DK_IMPALE" },
  { sids = {"SI_SYNERGY_ABILITY_STANDARTE"},                                   base="DK_STANDARTE" },

  -- NB
  { sids = {"SI_SYNERGY_ABILITY_DARK"},                                        base="NB_DARK" },
  { sids = {"SI_SYNERGY_ABILITY_SOUL"},                                        base="NB_SOUL" },

  -- WARDEN
  { sids = {"SI_SYNERGY_ABILITY_HARVEST"},                                     base="WARDEN_HARVEST" },
  { sids = {"SI_SYNERGY_ABILITY_ICYESC"},                                      base="WARDEN_ICYESC" },

  -- NECRO
  { sids = {"SI_SYNERGY_ABILITY_BONEYARD"},                                    base="NECRO_BONEYARD" },
  { sids = {"SI_SYNERGY_ABILITY_TOTEM"},                                       base="NECRO_TOTEM" },

  -- ARCANIST
  { sids = {"SI_SYNERGY_ABILITY_RUNE"},                                        base="ARCANIST_RUNE" },
  { sids = {"SI_SYNERGY_ABILITY_PORTAL"},                                      base="ARCANIST_PORTAL" },

  -- WW
  { sids = {"SI_SYNERGY_ABILITY_HUNT"},                                        base="WW_HUNT" },
  { sids = {"SI_SYNERGY_ABILITY_DEVOUR"},                                      base="WW_DEVOUR", has_ooc=true },

  -- VAMP
  { sids = {"SI_SYNERGY_ABILITY_EAT"},                                         base="VAMP_EAT" },

  -- BH
  { sids = {"SI_SYNERGY_ABILITY_BH"},                                          base="HOOD_BLADE" },

  -- Trials
  { sids = {"SI_SYNERGY_ABILITY_GATEWAY"},                                     base="CR_PORTAL" },
  { sids = {"SI_SYNERGY_ABILITY_TIME_BREACH"},                                 base="SS_PORTAL" },
  { sids = {"SI_SYNERGY_ABILITY_KA_PORTAL"},                                   base="KA_PORTAL" },
  { sids = {"SI_SYNERGY_ABILITY_KA_EXECRATION"},                               base="KA_EXECRATION" },
  { sids = {"SI_SYNERGY_ABILITY_DSR_SURGING_WATERS"},                           base="DSR_SURGING_WATERS" },
  { sids = {"SI_SYNERGY_ABILITY_RG_BLOP"},                                     base="RG_PURGE_BLOCK" },
  { sids = {"SI_SYNERGY_ABILITY_SE_VANTONS_CLARITY"},                           base="SE_VANTONS_CLARITY" },
  { sids = {"SI_SYNERGY_ABILITY_SE_ATTUNEMENT"},                                base="SE_ATTUNEMENT" },
  { sids = {"SI_SYNERGY_ABILITY_LC_MIRROR"},                                   base="LC_MIRROR" },
  { sids = {"SI_SYNERGY_ABILITY_OC_CARRIONSHIELD"},                             base="OC_CARRIONSHIELD" },
  { sids = {"SI_SYNERGY_ABILITY_OC_DREADFUL_PORTAL"},                           base="OC_DREADFUL_PORTAL", has_ooc=true },

  -- Arena
  { sids = {"SI_SYNERGY_SIGIL_RESURRECTION"},                                   base="ARENA_RESURRECTION" },
  { sids = {"SI_SYNERGY_SIGIL_DEFENSE"},                                        base="ARENA_DEFENSE" },
  { sids = {"SI_SYNERGY_SIGIL_HEALING"},                                        base="ARENA_HEALING" },
  { sids = {"SI_SYNERGY_SIGIL_SUSTAIN"},                                        base="ARENA_SUSTAIN" },
  { sids = {"SI_SYNERGY_SIGIL_POWER"},                                          base="ARENA_POWER" },
  { sids = {"SI_SYNERGY_SIGIL_HASTE"},                                          base="ARENA_HASTE" },

  -- Items
  { sids = {"SI_SYNERGY_ABILITY_URSUS"},                                        base="ITEM_URSUS" },
  { sids = {"SI_SYNERGY_ABILITY_KRAGLEN"},                                      base="ITEM_KRAGLEN" },
  { sids = {"SI_SYNERGY_ABILITY_SANGUINE"},                                     base="ITEM_SANGUINE" },
  { sids = {"SI_SYNERGY_ABILITY_GPREPRISAL"},                                   base="ITEM_GPREPRISAL" },
}

-- Kern: befüllt die Tabellen aus einem Preset
local function applyPresetToTables(preset)
  wipe(enabled_synergie); wipe(ignor_check); wipe(check_hotbar); wipe(out_of_combat)
  for _, e in ipairs(SPEC) do
    for i, sidK in ipairs(e.sids) do
      local name = S[sidK]
      local base = e.base
      if type(base) == "table" then base = base[i] end

      -- enabled
      enabled_synergie[name] = preset[base]

      -- optional: _IGCHK / _HBCHK / _OOCB (falls vorhanden)
      local ig = preset[base .. "_IGCHK"];     if ig ~= nil then ignor_check[name]   = ig end
      local hb = preset[base .. "_HBCHK"];     if hb ~= nil then check_hotbar[name]  = hb end
      if e.has_ooc then
        local ooc = preset[base .. "_OOCB"];   if ooc ~= nil then out_of_combat[name] = ooc end
      end
    end
  end
end

-- Deine neue UpdateSetting:
function BSCAS.UpdateSetting()
	if not BSCAS:PresetExist(BSCAS.SV.SELECTED_PRESET) then
		BSCAS.SV.SELECTED_PRESET = "Default"
	end
	ensurePreset(BSCAS.SV.SELECTED_PRESET) -- füllt fehlende Keys aus default_setting
	applyPresetToTables(BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET])
  
	if BSCAS.SV.PRINT_BLOCKING_PRESET_LOADED then
		CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Blocking Preset: <<1>> applied.|r", BSCAS.SV.SELECTED_PRESET))
	end
end

------------------------------------------------------------------------------
-- Check synergys 
------------------------------------------------------------------------------
-- Einmalige, zentrale Definition: exakt die Keys, die auch in UpdateSetting() verwendet werden.
BSCAS.SI_KEYS_BY_SECTION = {
  UNDAUNTED = {
    "SI_SYNERGY_ABILITY_BLOODALTAR1",
    "SI_SYNERGY_ABILITY_BLOODALTAR2",
    "SI_SYNERGY_ABILITY_BLACK_WIDOWS1",
    "SI_SYNERGY_ABILITY_BLACK_WIDOWS2",
    "SI_SYNERGY_ABILITY_INNERFIRE",
    "SI_SYNERGY_ABILITY_BONE1",
    "SI_SYNERGY_ABILITY_BONE2",
    "SI_SYNERGY_ABILITY_ORB1",
    "SI_SYNERGY_ABILITY_ORB2",
  },
  TEMPLAR = {
    "SI_SYNERGY_ABILITY_SHARDS1",
    "SI_SYNERGY_ABILITY_SHARDS2",
    "SI_SYNERGY_ABILITY_PURGE",
    "SI_SYNERGY_ABILITY_NOVA1",
    "SI_SYNERGY_ABILITY_NOVA2",
  },
  SORCERER = {
    "SI_SYNERGY_ABILITY_ATRO",
    "SI_SYNERGY_ABILITY_CONDUIT",
  },
  DRAGONKNIGHT = {
    "SI_SYNERGY_ABILITY_IMPALE",
    "SI_SYNERGY_ABILITY_STANDARTE",
  },
  NIGHTBLADE = {
    "SI_SYNERGY_ABILITY_DARK",
    "SI_SYNERGY_ABILITY_SOUL",
  },
  WARDEN = {
    "SI_SYNERGY_ABILITY_HARVEST",
    "SI_SYNERGY_ABILITY_ICYESC",
  },
  NECROMANCER = {
    "SI_SYNERGY_ABILITY_BONEYARD",
    "SI_SYNERGY_ABILITY_TOTEM",
  },
  ARCANIST = {
    "SI_SYNERGY_ABILITY_RUNE",
    "SI_SYNERGY_ABILITY_PORTAL",
  },
  WEREWOLF = {
    "SI_SYNERGY_ABILITY_HUNT",
    "SI_SYNERGY_ABILITY_DEVOUR",
  },
  VAMPIRE = {
    "SI_SYNERGY_ABILITY_EAT",
  },
  BROTHERHOOD = {
    "SI_SYNERGY_ABILITY_BH",
  },
  TRIALS = {
    "SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK", -- HRC Confirm
    "SI_SYNERGY_ABILITY_GATEWAY",              -- Cloudrest
    "SI_SYNERGY_ABILITY_TIME_BREACH",          -- Sunspire
    "SI_SYNERGY_ABILITY_KA_PORTAL",            -- Kyne's Aegis
    "SI_SYNERGY_ABILITY_KA_EXECRATION",
    "SI_SYNERGY_ABILITY_DSR_SURGING_WATERS",   -- Dreadsail Reef
    "SI_SYNERGY_ABILITY_RG_BLOP",              -- Rockgrove Purge/Blob
    "SI_SYNERGY_ABILITY_SE_VANTONS_CLARITY",   -- Sanity's Edge
    "SI_SYNERGY_ABILITY_SE_ATTUNEMENT",
    "SI_SYNERGY_ABILITY_LC_MIRROR",            -- Lucent Citadel
    "SI_SYNERGY_ABILITY_OC_CARRIONSHIELD",     -- Ossaorn's Cradle
    "SI_SYNERGY_ABILITY_OC_DREADFUL_PORTAL",
  },
  ARENA = {
    "SI_SYNERGY_SIGIL_RESURRECTION",
    "SI_SYNERGY_SIGIL_DEFENSE",
    "SI_SYNERGY_SIGIL_HEALING",
    "SI_SYNERGY_SIGIL_SUSTAIN",
    "SI_SYNERGY_SIGIL_POWER",
    "SI_SYNERGY_SIGIL_HASTE",
  },
  ITEMS = {
    "SI_SYNERGY_ABILITY_URSUS",
    "SI_SYNERGY_ABILITY_KRAGLEN",
    "SI_SYNERGY_ABILITY_SANGUINE",
    "SI_SYNERGY_ABILITY_GPREPRISAL",
  },
}

function BSCAS.CheckInfo() -- /script BSCASynergy.CheckInfo()
  local empty = {}

  BSCAS:PrintDebug(" ")
  BSCAS:PrintDebug("-- Check SI*-Strings (Quelle: ESO-Stringtabelle) --")

  local function dumpSection(title, keys)
    BSCAS:PrintDebug("- "..title)
    for _, key in ipairs(keys) do
      local sid = _G[key]                -- numerische StringId oder nil
      local val = (type(sid)=="number") and GetString(sid) or ""
      local shown = (val ~= nil and val ~= "") and val or "<leer>"
      BSCAS:PrintDebug(zo_strformat("Name[<<1>>][<<2>>]", key, shown))
      if shown == "<leer>" then
        -- zusätzlich markieren, ob der Key gar nicht existiert
        if sid == nil then
          table.insert(empty, key.." (undefiniert)")
        else
          table.insert(empty, key)
        end
      end
    end
  end

  -- Reihenfolge beibehalten (keine Sortierung):
  dumpSection("UNDAUNTED",      BSCAS.SI_KEYS_BY_SECTION.UNDAUNTED)
  dumpSection("Templar",        BSCAS.SI_KEYS_BY_SECTION.TEMPLAR)
  dumpSection("Sorc",           BSCAS.SI_KEYS_BY_SECTION.SORCERER)
  dumpSection("Dragonknight",   BSCAS.SI_KEYS_BY_SECTION.DRAGONKNIGHT)
  dumpSection("Nightblade",     BSCAS.SI_KEYS_BY_SECTION.NIGHTBLADE)
  dumpSection("Warden",         BSCAS.SI_KEYS_BY_SECTION.WARDEN)
  dumpSection("Necromancer",    BSCAS.SI_KEYS_BY_SECTION.NECROMANCER)
  dumpSection("Arcanist",       BSCAS.SI_KEYS_BY_SECTION.ARCANIST)
  dumpSection("Werewolf",       BSCAS.SI_KEYS_BY_SECTION.WEREWOLF)
  dumpSection("Vampire",        BSCAS.SI_KEYS_BY_SECTION.VAMPIRE)
  dumpSection("Brotherhood",    BSCAS.SI_KEYS_BY_SECTION.BROTHERHOOD)
  dumpSection("Trials",         BSCAS.SI_KEYS_BY_SECTION.TRIALS)
  dumpSection("Arena",          BSCAS.SI_KEYS_BY_SECTION.ARENA)
  dumpSection("Items",          BSCAS.SI_KEYS_BY_SECTION.ITEMS)

  BSCAS:PrintDebug(" ")
  if #empty > 0 then
    BSCAS:PrintDebug("-- Leer / Fehlend --")
    for _, k in ipairs(empty) do
      BSCAS:PrintDebug(k)
    end
  else
    BSCAS:PrintDebug("Keine leeren Einträge gefunden.")
  end
  BSCAS:PrintDebug(" ")
end

------------------------------------------------------------------------------
-- Function to check if can use the Synergy
------------------------------------------------------------------------------
local function IgnoreCheck(synergyName)
	if ignor_check[synergyName] ~= nil and ignor_check[synergyName] then
		PrintDebug(zo_strformat("(IgnoreMode) Can Use Synergie[<<1>>]", synergyName))
		return true
	end
	return false
end

local function CanUseSynergy(synergyName, iconFilename)
	PrintDebug(zo_strformat("Can Use Start [<<1>>]", synergyName))
	-- debug area, logg unknown names
	if debug_mode then
		if BSCAS.SV_acc.DEBUG_LIST[synergyName] == nil then
			BSCAS.SV_acc.DEBUG_LIST[synergyName] = iconFilename
			PrintDebug(zo_strformat("1 Unknown synergy added to Debug List[<<1>>]", synergyName))
			return true
		end
	end
	-- HRC Confirm
	if synergyName == GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK) and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].HRC_CONFIRM then
		if BSCAS.SHOW_DIALOG then
			ZO_Dialogs_ShowPlatformDialog("BSC_ADVANCED_SYNERGY_CONFIRM")
			return false			
		end
	end
	-- unknown synergy always allowed
	if enabled_synergie[synergyName] == nil then
		BSCAS.SV_acc.DEBUG_LIST[synergyName] = iconFilename
		PrintDebug(zo_strformat("2 Unknown synergy added to Debug List[<<1>>]", synergyName))	
		return true 
	end
	-- only in combat
	if not IsUnitInCombat('player') then
		if BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].ONLYINCOMBAT then
			PrintDebug(zo_strformat("(CombatMode) Can't used Synergie[<<1>>]", synergyName))
			if IgnoreCheck(synergyName) then return true end
			return false
		end
	else
		-- only out of combat
		if out_of_combat[synergyName] ~= nil and out_of_combat[synergyName] then 			
			PrintDebug(zo_strformat("(CombatMode) Can't used Synergie[<<1>>]", synergyName))
			return false 
		end
	end	
	-- check if enabled
	if not enabled_synergie[synergyName] then
		PrintDebug(zo_strformat("(EnableMode) Can't used Synergie[<<1>>]", synergyName))
		return false							
	end
	-- Ignore every check below
	if IgnoreCheck(synergyName) then return true end
	-- check lokke
	if not lokkeCheck() then
		PrintDebug(zo_strformat("(LokkeMode) Can't use Synergie[<<1>>]", synergyName))	
		return false
	end		
	-- check Alkosh
	if not HasAlkosh() then
		PrintDebug(zo_strformat("(AlkoshMode) Can't used Synergie[<<1>>]", synergyName))	
		return false
	end			
	-- check_hotbar = { }	-- (-1 = ALL, 0 = Primary, 1 = Backup)
	local ActiveHotbar = GetActiveHotbarCategory()
	if ActiveHotbar < 2 and check_hotbar[synergyName] ~= nil and check_hotbar[synergyName] ~= -1 and check_hotbar[synergyName] ~= ActiveHotbar then
		PrintDebug(zo_strformat("(HotbarMode) Can't used Synergie [<<1>>] Hotbar[<<2>>]", synergyName, ActiveHotbar))
		return false				
	end			
	-- check hotbar new			
	if ActiveHotbar < 2 and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].NEW_BARCHECK ~= nil and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].NEW_BARCHECK ~= -1 and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].NEW_BARCHECK ~= ActiveHotbar then
		PrintDebug(zo_strformat("(GHotbarMode) Can't used Synergie [<<1>>] Hotbar[<<2>>]", synergyName, ActiveHotbar))
		return false				
	end
	-- Resources check
	if BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RESOURCES_CHECK or CHECK_RESOURCES then
		if not isLowStamina() and not isLowMagica() then
			return false
		end
	end	
	PrintDebug(zo_strformat("Can Use End [<<1>>]", synergyName))	
	return true
end

------------------------------------------------------------------------------
-- New synergy blocking
------------------------------------------------------------------------------
local function OnSynergyAbilityChanged_Base()
	local hasSynergy, synergyName, iconFilename, prompt = GetCurrentSynergyInfo()
	-- New toy from ESO devs
	if API_GE_101048 then
		BSCAS:UpdateAvailableSynergies()
	end
	if hasSynergy then
		synergyName = zo_strformat("<<1>>", synergyName)
		if CanUseSynergy(synergyName, iconFilename) then
			if SYNERGY.lastSynergyName ~= synergyName then
				PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
				if prompt == "" then
					prompt = zo_strformat(SI_USE_SYNERGY, synergyName)
				end
				SYNERGY.action:SetText(prompt)
				SYNERGY.lastSynergyName = synergyName
			end
			SYNERGY.icon:SetTexture(iconFilename)
			SHARED_INFORMATION_AREA:SetHidden(SYNERGY, false)
		else
			SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
			SYNERGY.lastSynergyName = nil -- is for playing sound..
			-- Smart system to set blocked synergys to Prio 666 and change it again after 2 seconds so other synergies can be taken			
			if API_GE_101048 then
				local numSynergies = GetNumberOfAvailableSynergies()				
				for synergyIndex = 1, numSynergies do
					local _synergyName_, _iconFilename_, _prompt_, _priority_, _synergyAbilityId_, _canBeUsed_ = GetSynergyInfoAtIndex(synergyIndex)
					if _canBeUsed_ and zo_strformat("<<1>>", _synergyName_) == synergyName then						
						if GetSynergyPriorityOverride(_synergyAbilityId_) ~= PRIO_BLOCKED then
							SetSynergyPriorityOverride(_synergyAbilityId_, PRIO_BLOCKED)
							zo_callLater(function() 
								SetSynergyPriorityOverride(_synergyAbilityId_, _priority_) 
								PrintDebug(zo_strformat("Seet synergy Prio back to <<1>> <<2>>", _synergyAbilityId_, _priority_))
								end, 
							2000)	
						end
					end
				end
			end
		end
	else
		SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
		SYNERGY.lastSynergyName = nil -- is for playing sound..
	end
end

local pending_refresh = false
local function OnSynergyAbilityChanged()
  if pending_refresh then return end
  pending_refresh = true
  zo_callLater(function()
    pending_refresh = false
    OnSynergyAbilityChanged_Base()
  end, 10) -- 10ms reicht i.d.R.
end
------------------------------------------------------------------------------
-- Synergie stuff for Preset / Menu Options
------------------------------------------------------------------------------
function BSCAS:GetListNames()
	local List = {}	
	for name, v in pairs(BSCAS.SV_acc.SETTING) do	
		table.insert(List, name)
	end	
	return List
end
function BSCAS.AddSetting()
	local name = BSCAS_PresetEditbox.editbox:GetText()
	PrintDebug(zo_strformat("AddNewSetting[<<1>>]", name))
		
	if name == "Default" then return end	
	if BSCAS.SV_acc.SETTING[name] ~= nil then
		PrintDebug("Preset ["..name.."] Already Exist!") 
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Preset ["..name.."] Already Exist!")
		return 
	end	
	if (name ~= "") then		
		--BSCAS.SV_acc.SETTING[name] = default_setting
		BSCAS.SV_acc.SETTING[name] = deepcopy(default_setting)
		BSCAS.SV.SELECTED_PRESET = name
		-- Update the dropbox
		BSCAS_PresetDropdown:UpdateChoices(BSCAS:GetListNames())
		BSCAS_PresetDropdownTank:UpdateChoices(BSCAS:GetListNames())
		BSCAS_PresetDropdownHeal:UpdateChoices(BSCAS:GetListNames())
		BSCAS_PresetDropdownDps:UpdateChoices(BSCAS:GetListNames())		
		BSCAS.LoadSetting(name)	
	else
		d("BSCAS - Add Setting failed!")
	end
end
function BSCAS.DeleteSelected()
	local name = BSCAS_PresetDropdown.data.getFunc()
	PrintDebug(zo_strformat("DeleteSelected[<<1>>]", name))
	
	-- cannot delete default
	if name == "Default" then 
		PrintDebug("Preset [Default] cannot deleted!") 
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_SYNERGY_ERROR_NOTDELETE))
		return 
	end
	
	-- remake the list
	local new_list = { }
	for k, v in pairs(BSCAS.SV_acc.SETTING) do		
		if name ~= k then
			new_list[k] = v
		end
	end	
	BSCAS.SV_acc.SETTING = new_list
	
	-- set back to default
	BSCAS.LoadSetting("Default")
	-- Update the dropbox
	BSCAS_PresetDropdown:UpdateChoices(BSCAS:GetListNames())
	
	if BSCAS.SV.SELECTED_PRESET_TANK == name then BSCAS.SV.SELECTED_PRESET_TANK = "Default" end
	BSCAS_PresetDropdownTank:UpdateChoices(BSCAS:GetListNames())
	if BSCAS.SV.SELECTED_PRESET_HEAL == name then BSCAS.SV.SELECTED_PRESET_HEAL = "Default" end
	BSCAS_PresetDropdownHeal:UpdateChoices(BSCAS:GetListNames())
	if BSCAS.SV.SELECTED_PRESET_DPS == name then BSCAS.SV.SELECTED_PRESET_DPS = "Default" end
	BSCAS_PresetDropdownDps:UpdateChoices(BSCAS:GetListNames())
	
end
function BSCAS.LoadSetting(name)
	PrintDebug(zo_strformat("LoadSelected[<<1>>]", name))	
	if BSCAS.SV_acc.SETTING[name] == nil then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_SYNERGY_ERROR_DELETE))
		return
	end		
	BSCAS.SV.SELECTED_PRESET = name		
	BSCAS.UpdateSetting()
end
function BSCAS:PresetExist(Preset)
	for name, v in pairs(BSCAS.SV_acc.SETTING) do
		if name == Preset then return true end
	end
	return false
end
------------------------------------------------------------------------------
-- Enable all portals!
------------------------------------------------------------------------------
function BSCAS.TogglePortals() 
	local zoneId  = GetUnitWorldPosition('player') 
	if not BSCAS:PresetExist(BSCAS.SV.SELECTED_PRESET) then BSCAS.SV.SELECTED_PRESET = "Default" end	
	-- CloudRest
	if zoneId == 1051 then	
		BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].CR_PORTAL = not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].CR_PORTAL
		PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_GATEWAY), BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].CR_PORTAL)
	end
	-- Sunspire
	if zoneId == 1121 then
		BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].SS_PORTAL = not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].SS_PORTAL
		PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_TIME_BREACH), BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].SS_PORTAL)
	end
	-- kynes aegis
	if zoneId == 1196 then	
		BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].KA_PORTAL = not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].KA_PORTAL
		PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_KA_PORTAL), BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].KA_PORTAL)
	end	
	-- DSR
	if zoneId == 1344 then	
		BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS = not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS
		PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS), BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS)		
	end
	-- LC
	if zoneId == 1478 then	
		BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LC_MIRROR = not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LC_MIRROR
		PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_LC_MIRROR), BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LC_MIRROR)		
	end
	BSCAS.UpdateSetting()
end
------------------------------------------------------------------------------
--  Role Change LFG_ROLE_DPS, LFG_ROLE_HEAL, LFG_ROLE_INVALID,LFG_ROLE_TANK
------------------------------------------------------------------------------
local function HookRoleChange()
	ZO_PreHook("UpdateSelectedLFGRole", 	
	function(role)  
		--BSCAS:PrintDebug(zo_strformat("role[<<1>>]", role))
		if role == LFG_ROLE_TANK then
			if BSCAS.SV.SELECTED_PRESET_TANK ~= "Default" then
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_TANK
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_TANK).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_TANK))
				BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
			end
		elseif role == LFG_ROLE_HEAL then	
			if BSCAS.SV.SELECTED_PRESET_HEAL ~= "Default" then	
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_HEAL
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_HEAL).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_HEAL))
				BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
			end
		else			
			if BSCAS.SV.SELECTED_PRESET_DPS ~= "Default" then
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_DPS
				CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFFBSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_DPS).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", BSCAS.SV.SELECTED_PRESET_DPS))
				BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
			end
		end	
		BSCAS.UpdateSetting()
	end)
end
------------------------------------------------------------------------------
-- HotbarTest
------------------------------------------------------------------------------
local function ActionSlotsFullUpdate(eventCode,  isHotbarSwap)
	if isHotbarSwap then
		OnSynergyAbilityChanged()
	end
end
------------------------------------------------------------------------------
-- Blocking OC Portal Synergie 
------------------------------------------------------------------------------
local function OnEffectChanged_OC( _, changeType, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, unitName, unitId, abilityId, _)	
	-- OC Autoblock/enable
	if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].OC_CARRIONSHIELD_BLOCK_DB then return end	
	if abilityId == BSCAS.OC_CAUSTIC_CARRION_1
	or abilityId == BSCAS.OC_CAUSTIC_CARRION_2 then
		if changeType == EFFECT_RESULT_FADED then
			if enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] ~= false then
				enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] = false
				PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD), false)
				OnSynergyAbilityChanged()
			end
		elseif changeType == EFFECT_RESULT_GAINED then
			if enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] ~= false then	
				enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] = false	
				PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD), false)
				OnSynergyAbilityChanged()
			end
		elseif changeType == EFFECT_RESULT_UPDATED then		
			if stackCount >= BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].OC_CARRIONSHIELD_CD then
				if enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] ~= true then
					enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] = true
					PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD), true)
					OnSynergyAbilityChanged()
				end
			end
		end
	end
	PrintDebug(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>] stackCount[<<4>>]", abilityId, GetAbilityName(abilityId), changeType, stackCount))
end
------------------------------------------------------------------------------
-- COMBAT_EVENT for Blocking Portals
------------------------------------------------------------------------------
local RG_BLOP = false
local function CombatEvent(_, result, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId, _)
	-- COMBAT_EVENT for CR Blocking
	--if register_vcr then
	if abilityId == BSCAS.VCR_PORT_DBUFF_ID then
		if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].CR_PORTAL_BLOCK_DB then return end
		if result == ACTION_RESULT_EFFECT_GAINED then		
			PrintDebug(zo_strformat("GAINED ID[<<1>>] Name[<<2>>] Duration[<<3>>] TargedNanme[<<4>>]", abilityId, GetAbilityName(abilityId), GetAbilityDuration(abilityId), targetName))
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_GATEWAY)] = false	
			PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_GATEWAY), false)
		elseif result == ACTION_RESULT_EFFECT_FADED then		
			PrintDebug(zo_strformat("FADED ID[<<1>>] Name[<<2>>] TargedNanme[<<3>>]", abilityId, GetAbilityName(abilityId), targetName)) 		
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_GATEWAY)] = true			
			OnSynergyAbilityChanged()
			PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_GATEWAY), true)
		end	
	end 	
	-- COMBAT_EVENT for HRC outbreak
	--if register_hrc then
	if abilityId == BSCAS.HRC_OUTBREAK_DBUFF_ID then
		if result == ACTION_RESULT_EFFECT_FADED then			
			PrintDebug(zo_strformat("FADED ID[<<1>>] Name[<<2>>]", abilityId, GetAbilityName(abilityId))) -- enable dialog again
			BSCAS.SHOW_DIALOG = true
		end
	end
	-- COMBAT_EVENT for DSR 	
	--if register_dsr then
	if abilityId == BSCAS.DSR_INFESTATION then
		if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS_BLOCK_DB then return end		
		if result == ACTION_RESULT_EFFECT_GAINED then
			PrintDebug(zo_strformat("FADED ID[<<1>>] Name[<<2>>] Duration[<<3>>] TargedNanme[<<4>>]", abilityId, GetAbilityName(abilityId), GetAbilityDuration(abilityId), targetName))	
			-- Block 
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS)] = false				
			PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS), false)
			-- Unblock again in xx seconds			
			zo_callLater(
			function() 
				enabled_synergie[GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS)] = true		
				OnSynergyAbilityChanged()		
				PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS), true)
			end, 
			(BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS_CD*1000))
		end
	end
	-- Rockgrove Blob
	if abilityId == ABILITYID_RGBLOP then
		if BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RG_PURGE_BLOCK then return end	-- can use Synergie? then return..
		if result == ACTION_RESULT_EFFECT_FADED then	
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_RG_BLOP)] = true		
			OnSynergyAbilityChanged()
			RG_BLOP = false
		elseif result == ACTION_RESULT_EFFECT_GAINED then		
			if RG_BLOP then
				BSCAS.PlaySound(2, SOUNDS.DUEL_WON) 
				return
			end	
			RG_BLOP = true		
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_RG_BLOP)] = false
			local timeBlop = BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RG_PURGE_BLOCK_CD
			if BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].RG_PURGE_BLOCK_ALERT then
				if CombatAlerts ~= nil then
					CombatAlerts.CastAlertsStart(153034, GetFormattedAbilityName(153034), timeBlop, timeBlop, { 1, 0.7, 0, 0.5 }, { timeBlop, "Drop Blop Behind!!", 0.8, 0, 0, 0.9, SOUNDS.DUEL_WON} )
				else
					BSCASUIAlert:SetHidden(false)
					BSCAS.PlaySound(2, SOUNDS.DUEL_WON) 
				end	
			end
			zo_callLater(
				function() 					
					RG_BLOP = false
					BSCASUIAlert:SetHidden(true)
					enabled_synergie[GetString(SI_SYNERGY_ABILITY_RG_BLOP)] = true	
					OnSynergyAbilityChanged()
					if CombatAlerts ~= nil then
						BSCASUIAlert:SetHidden(true)
					end
				end, 
			timeBlop)
		end
		PrintDebug(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), result))
	end
	-- LC
	if abilityId == ABILITYID_CD_LC_MIRROR then
		if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LC_MIRROR_BLOCK_DB then return end	
		if result == ACTION_RESULT_EFFECT_FADED then	
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_LC_MIRROR)] = true	
			PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_LC_MIRROR), true)	
			OnSynergyAbilityChanged()
		elseif result == ACTION_RESULT_EFFECT_GAINED then
			enabled_synergie[GetString(SI_SYNERGY_ABILITY_LC_MIRROR)] = false	
			PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_LC_MIRROR), false)	
			OnSynergyAbilityChanged()		
		end
		PrintDebug(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), result))
	end				
	-- OC Portals
	if abilityId == BSCAS.OC_CARRION_PORTAL -- Portal end 
	or abilityId == BSCAS.OC_CARRION_PORTAL_2 then
		if result == ACTION_RESULT_EFFECT_FADED then
			if enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] ~= true then
				enabled_synergie[GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD)] = true
				PrintPortalInfo(GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD), true)
				OnSynergyAbilityChanged()
			end
			PrintDebug("Portal End")
		end
	end
end
------------------------------------------------------------------------------
-- Blocking Slayer
------------------------------------------------------------------------------
local function OnEffectChanged( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, _)
	if not BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].BERSERK_CHECK then return end
	if changeType == EFFECT_RESULT_FADED then			
		enabled_synergie[GetString(SI_SYNERGY_ABILITY_ATRO)] = true		
		OnSynergyAbilityChanged()
	elseif changeType == EFFECT_RESULT_UPDATED then	
		enabled_synergie[GetString(SI_SYNERGY_ABILITY_ATRO)] = false	
		OnSynergyAbilityChanged()
	end	
	if debug_mode then
		BSCAS:PrintDebug(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), changeType))
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- on Zone Load
------------------------------------------------------------------------------
-- =========================
-- Zone-Dispatch (Register/Unregister an einer Stelle)
-- =========================
local ZONE = {
  -- Cloudrest
  [1051] = function(on)
    if on then
		d("cr load")
      EVENT_MANAGER:RegisterForEvent("BSCAS_CECloudrest", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CECloudrest", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCAS.VCR_PORT_DBUFF_ID)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CECloudrest", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      PrintPortalInfo(S.SI_SYNERGY_ABILITY_GATEWAY, BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].CR_PORTAL)
    else
		d("cr unload")
      EVENT_MANAGER:UnregisterForEvent("BSCAS_CECloudrest", EVENT_COMBAT_EVENT)
    end
  end,

  -- Hel Ra Citadel
  [636] = function(on)
    if on then
      EVENT_MANAGER:RegisterForEvent("BSCAS_CEHelrar", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CEHelrar", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCAS.HRC_OUTBREAK_DBUFF_ID)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CEHelrar", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      -- optional: kein Portalstatus hier
    else
      EVENT_MANAGER:UnregisterForEvent("BSCAS_CEHelrar", EVENT_COMBAT_EVENT)
    end
  end,

  -- Sunspire
  [1121] = function(on)
    if on then
      PrintPortalInfo(S.SI_SYNERGY_ABILITY_TIME_BREACH, BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].SS_PORTAL)
    else
      -- nichts zu deregistrieren
    end
  end,

  -- Kyne's Aegis
  [1196] = function(on)
    if on then
      PrintPortalInfo(S.SI_SYNERGY_ABILITY_KA_PORTAL, BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].KA_PORTAL)
    else
      -- nichts zu deregistrieren
    end
  end,

  -- Dreadsail Reef
  [1344] = function(on)
    if on then
      EVENT_MANAGER:RegisterForEvent("BSCAS_CECDreadsail", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CECDreadsail", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCAS.DSR_INFESTATION)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_CECDreadsail", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      PrintPortalInfo(S.SI_SYNERGY_ABILITY_DSR_SURGING_WATERS, BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].DSR_SURGING_WATERS)
    else
      EVENT_MANAGER:UnregisterForEvent("BSCAS_CECDreadsail", EVENT_COMBAT_EVENT)
    end
  end,

  -- Rockgrove
  [1263] = function(on)
    if on then
      RG_BLOP = false
      EVENT_MANAGER:RegisterForEvent("BSCAS_BlockSRG", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockSRG", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ABILITYID_RGBLOP)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockSRG", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    else
      EVENT_MANAGER:UnregisterForEvent("BSCAS_BlockSRG", EVENT_COMBAT_EVENT)
    end
  end,

  -- Lucent Citadel
  [1478] = function(on)
    if on then
      EVENT_MANAGER:RegisterForEvent("BSCAS_LCMIRROR", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_LCMIRROR", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ABILITYID_CD_LC_MIRROR)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_LCMIRROR", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      PrintPortalInfo(S.SI_SYNERGY_ABILITY_LC_MIRROR, BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET].LC_MIRROR)
    else
      EVENT_MANAGER:UnregisterForEvent("BSCAS_LCMIRROR", EVENT_COMBAT_EVENT)
    end
  end,

  -- Ossaorn's Cradle
  [1548] = function(on)
    if on then
      -- Schilde (Group-Effects)
      EVENT_MANAGER:RegisterForEvent("BSCAS_OCSHIELD_1", EVENT_EFFECT_CHANGED, OnEffectChanged_OC)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BSCAS.OC_CAUSTIC_CARRION_1)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')

      EVENT_MANAGER:RegisterForEvent("BSCAS_OCSHIELD_2", EVENT_EFFECT_CHANGED, OnEffectChanged_OC)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BSCAS.OC_CAUSTIC_CARRION_2)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')

      -- Portale (Player-targeted)
      EVENT_MANAGER:RegisterForEvent("BSCAS_OCSHIELD_PORTAL_1", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_PORTAL_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCAS.OC_CARRION_PORTAL)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_PORTAL_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

      EVENT_MANAGER:RegisterForEvent("BSCAS_OCSHIELD_PORTAL_2", EVENT_COMBAT_EVENT, CombatEvent)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_PORTAL_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCAS.OC_CARRION_PORTAL_2)
      EVENT_MANAGER:AddFilterForEvent("BSCAS_OCSHIELD_PORTAL_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    else
      EVENT_MANAGER:UnregisterForEvent("BSCAS_OCSHIELD_1", EVENT_EFFECT_CHANGED)
      EVENT_MANAGER:UnregisterForEvent("BSCAS_OCSHIELD_2", EVENT_EFFECT_CHANGED)
      EVENT_MANAGER:UnregisterForEvent("BSCAS_OCSHIELD_PORTAL_1", EVENT_COMBAT_EVENT)
      EVENT_MANAGER:UnregisterForEvent("BSCAS_OCSHIELD_PORTAL_2", EVENT_COMBAT_EVENT)
    end
  end,
}

-- =========================
-- Neues OnPlayerActivated (nutzt den Dispatch)
-- =========================
local current_zone = -1
local bCheckLFGRole = true
local function OnPlayerActivated()
	local zoneId = GetUnitWorldPosition("player")

	-- PvP-Guard: Tabellen wipen statt neu binden
	if BSCAS.SV.PVP_AREA_ENABLED == false and (IsInCampaign() or IsActiveWorldBattleground()) then
		wipe(enabled_synergie); wipe(ignor_check); wipe(check_hotbar); wipe(out_of_combat)
		if zoneId ~= current_zone then
		  CHAT_ROUTER:AddSystemMessage(BSCAS.Name.." Now Disabled! (PvP)")
		  current_zone = zoneId
		end
		return
	end
	
	-- first check LFG Role on Login
	if bCheckLFGRole then
		bCheckLFGRole = false
		local LFGR = GetSelectedLFGRole() 
		if LFGR == LFG_ROLE_TANK then
			if BSCAS.SV.SELECTED_PRESET_TANK ~= "Default" then
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_TANK
			end
		elseif LFGR == LFG_ROLE_HEAL then	
			if BSCAS.SV.SELECTED_PRESET_HEAL ~= "Default" then	
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_HEAL
			end
		else			
			if BSCAS.SV.SELECTED_PRESET_DPS ~= "Default" then
				BSCAS.SV.SELECTED_PRESET = BSCAS.SV.SELECTED_PRESET_DPS
			end
		end	
	end
	
	-- Settings aktualisieren
	BSCAS.UpdateSetting()

	-- Alte Zonen-Hooks deaktivieren, neue aktivieren
	if ZONE[current_zone] and current_zone ~= zoneId then
		ZONE[current_zone](false)
	end
	if ZONE[zoneId] then
		ZONE[zoneId](true)
	end

	current_zone = zoneId
	BSCAS:CheckEquipment()
	OnSynergyAbilityChanged()
end
------------------------------------------------------------------------------
-- Get Players In Range for explosion
------------------------------------------------------------------------------
local function GetDistance( unitTag1, unitTag2, useHeight )
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unitTag2)

	if (zone1 == 0 or zone1 ~= zone2) then
		return(-1)
	elseif (useHeight) then
		return(zo_sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2) / 100)
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end
local function CheckUnit(unitTag)
	if not IsUnitPlayer(unitTag) then 
		return false
	elseif not IsUnitOnline(unitTag) then
		return false
	elseif not IsUnitInGroupSupportRange(unitTag) then
		return false
	elseif IsUnitDead(unitTag) then 
		return false
	elseif IsUnitBeingResurrected(unitTag) then  
		return false
	elseif DoesUnitHaveResurrectPending(unitTag) then 
		return false
	elseif IsUnitReincarnating(unitTag) then 
		return false
	elseif IsUnitResurrectableByPlayer(unitTag) then
		return false
	else
		return true
	end
	return true
end
local function GetPlayersInRange()
  if not IsUnitGrouped('player') then return 0 end
  local range, count = 15, 0
  local myIndex = GetGroupIndexByUnitTag('player')
  local _, px, _, pz = GetUnitWorldPosition('player')
  local pZone = select(1, GetUnitWorldPosition('player'))

  for i = 1, GetGroupSize() do
    if i ~= myIndex then
      local unitTag = GetGroupUnitTagByIndex(i)
      if unitTag and CheckUnit(unitTag) then
        local z, x, _, z2 = GetUnitWorldPosition(unitTag)
        if z == pZone then
          local dx, dz = px - x, pz - z2
          if (dx*dx + dz*dz) <= (range*range*100*100) then
            count = count + 1
          end
        end
      end
    end
  end
  return count
end
local function UpdatePlayerInRange()
	if BSCAS.SHOW_DIALOG then
		BSCAS_ConfirmationDialog:GetNamedChild("Text2"):SetText(zo_strformat("Players In Range: <<1>>", GetPlayersInRange()))
	end
end
------------------------------------------------------------------------------
-- Dialog functions for HRC outbreak check
------------------------------------------------------------------------------
BSCAS.SHOW_DIALOG = true
local function SetupConfirmDialog()
  local customControl = BSCAS_ConfirmationDialog
  ZO_Dialogs_RegisterCustomDialog("BSC_ADVANCED_SYNERGY_CONFIRM", {
    gamepadInfo = { dialogType = GAMEPAD_DIALOGS.STATIC_LIST },
    customControl = customControl,
    canQueue = false,
    title = { text = GetString(SI_SYNERGY_NAME_DESTRUCTIVE_OUTBREAK) },
    mainText = { text = GetString(SI_SYNERGY_ALERT_HRC) },
    setup = function(dialog)
      customControl:GetNamedChild("Text2"):SetText(
        zo_strformat("Players In Range: <<1>>", GetPlayersInRange())
      )
    end,
    buttons = {
      {
        control = customControl:GetNamedChild("Confirm"),
        text = SI_DIALOG_CONFIRM,
        callback = function()
          BSCAS.SHOW_DIALOG = false
          zo_callLater(function() BSCAS.SHOW_DIALOG = true end, 5000)
          OnSynergyAbilityChanged()
        end,
      },
    },
  })
end

function BSCAS:OSAC()
	OnSynergyAbilityChanged()
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCAS.BlockInit()		
	-- generate the default setting	
	-- set default if not exist
	if BSCAS.SV.SELECTED_PRESET == nil or BSCAS.SV.SELECTED_PRESET == "" then		
		BSCAS.SV.SELECTED_PRESET = "Default"
	end
	-- Check if Current Exist
	if not BSCAS:PresetExist(BSCAS.SV.SELECTED_PRESET) then BSCAS.SV.SELECTED_PRESET = "Default" end	
	-- check if already exist, if not add it
	if BSCAS.SV_acc.SETTING["Default"] == nil then
		BSCAS.SV_acc.SETTING["Default"] = deepcopy(default_setting)
	end
	-- Check if all synergies are known
	CheckPresets()
	-- New synergy blocking functions
	SYNERGY.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	SYNERGY.control:UnregisterForEvent(EVENT_SYNERGY_ABILITY_CHANGED)	
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_SYNERGY_ABILITY_CHANGED, OnSynergyAbilityChanged)
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_PLAYER_COMBAT_STATE, function() OnSynergyAbilityChanged() end)	
	--
	SetupConfirmDialog()
	--	
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_ACTION_SLOTS_FULL_UPDATE, ActionSlotsFullUpdate)	
	HookRoleChange()		
	-- 
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_INVENTORY_FULL_UPDATE, function() BSCAS:CheckEquipment() end )
	EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockS", EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockS", EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	--
	EVENT_MANAGER:RegisterForEvent("BSCAS_BlockS", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()  BSCAS:CheckEquipment() end )	
	EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockS", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent("BSCAS_BlockS", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)	
	--
	for abilityId in pairs(BSCAS.BERSERK_IDS) do
		local eventName = 'BSCAS_BlockS'..abilityId
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
	end
	--
	EVENT_MANAGER:RegisterForUpdate('BSCAS_BlockS', 1000, UpdatePlayerInRange)
end