-- ================================================================================================
-- BSCASynergy - Blocking Menu (vollständig & optimiert, gleiche Struktur/Funktion wie Vorlage)
-- ================================================================================================
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

-- -----------------------------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------------------------
local function AddDivider(targetOrTab)
    local div = { type = "divider" }
    if type(targetOrTab) == "table" then
        table.insert(targetOrTab, div)
    else
        BSCAS:AddControlToTab(targetOrTab or 1, div)
    end
end

local function AddSpacer(targetOrTab)
	local spacer = { 
		type = "custom",
		minHeight = 15,
	}
    if type(targetOrTab) == "table" then
        table.insert(targetOrTab, spacer)
    else
        BSCAS:AddControlToTab(targetOrTab or 1, spacer)
    end
end

local function AddTexture(controlList, icon, desc)
    table.insert(controlList, {
        type = "texture",
        image = icon,
        tooltip = desc,
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
    })
end

local function GetSetting(key)
    return BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET][key]
end

local function SetSetting(key, value, skipUpdate)
    BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET][key] = value
    if not skipUpdate then BSCAS.UpdateSetting() end
end

local function MakeGetSet(key, skipUpdate)
    return function() return GetSetting(key) end,
           function(v) SetSetting(key, v, skipUpdate) end
end

local _zoneCache = {}
local function Z(id)
    if not _zoneCache[id] then
        _zoneCache[id] = zo_strformat("<<1>>", GetZoneNameById(id))
    end
    return _zoneCache[id]
end

-- Universeller Synergy-Block (Texture + Aktivieren + Ignorieren + optional Hotbar-Dropdown)
local function AddSynergyControl(list, icon, descString, nameString, baseKey, hasDropdown, bOnyOutCombat, bAddDivider)
    AddTexture(list, icon, descString)

    -- Aktivieren
    table.insert(list, {
        type = "checkbox",
        name = GetString(nameString),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting(baseKey) end,
        setFunc = function(v) SetSetting(baseKey, v) end,
        width = "half",
    })

    -- Ignorieren
    table.insert(list, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting(baseKey .. "_IGCHK") end,
        setFunc = function(v) SetSetting(baseKey .. "_IGCHK", v) end,
        width = "full",
    })

    -- Optionales Hotbar-Dropdown
    if hasDropdown then
        table.insert(list, {
            type = "dropdown",
            name = GetString(SI_SYNERGY_NAME_HOTBAR),
            tooltip = GetString(SI_SYNERGY_MI_HOTBAR_INFO),
            disabled = function() return GetSetting(baseKey .. "_IGCHK") end,
            choices = {"ALL", "PRIMARY", "BACKUP"},
            getFunc = function()
                local hb = GetSetting(baseKey .. "_HBCHK")
                if hb == HOTBAR_CATEGORY_PRIMARY then return "PRIMARY"
                elseif hb == HOTBAR_CATEGORY_BACKUP then return "BACKUP"
                else return "ALL" end
            end,
            setFunc = function(v)
                local val = -1
                if v == "PRIMARY" then val = HOTBAR_CATEGORY_PRIMARY
                elseif v == "BACKUP" then val = HOTBAR_CATEGORY_BACKUP end
                SetSetting(baseKey .. "_HBCHK", val)
            end,
            width = "full",
        })
    end
	
	if bOnyOutCombat then
		table.insert(list, {
			type = "checkbox",
			name = GetString(SI_SYNERGY_NAME_ONLY_OUT_COMBAT),
			tooltip = GetString(SI_SYNERGY_INFO_ONLY_OUT_COMBAT),
			getFunc = function() return GetSetting(baseKey .. "_OOCB") end,
			setFunc = function(v) SetSetting(baseKey .. "_OOCB", v) end,
			width = "full",
		})
	end
	
	if bAddDivider then
		AddDivider(list)
	else 
		AddSpacer(list)
	end
end

-- -----------------------------------------------------------------------------------------------
-- Base Settings (oben)
-- -----------------------------------------------------------------------------------------------
local function AddBaseSetting()
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_SETTING_ACC),
        getFunc = function() return BSCAS.SV.BLOCKING_USE_ACCOUNT end,
        setFunc = function(v) 
			BSCAS.SetUseAccount("BLOCKING", v)
		end,
    })
	
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_CHAT_PRESET_INFO),
        getFunc = function() return BSCAS.SV.PRINT_BLOCKING_PRESET_LOADED end,
        setFunc = function(v) 
			BSCAS.SV.PRINT_BLOCKING_PRESET_LOADED = v
		end,
    })
	
    AddDivider(1)
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_USEPVP),
        getFunc = function() return BSCAS.SV.PVP_AREA_ENABLED end,
        setFunc = function(v) BSCAS.SV.PVP_AREA_ENABLED = v BSCAS.UpdateSetting() end,
    })
    AddDivider(1)

    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_UI_NAME_WWPLUGIN),
        tooltip = function() 
			if LibBSCWizardBridge then
				return GetString(SI_SYNERGY_UI_DESC_WWPLUGIN)
			else
				return "LibBSCWizardBridge missing/not enabled"
			end
		end,
		disabled = function() return not LibBSCWizardBridge end,
        getFunc = function() return BSCAS.SV.ADD_WW_PLUGIN end,
        setFunc = function(v) BSCAS.SV.ADD_WW_PLUGIN = v zo_callLater(function() ReloadUI() end, 300) end,
        warning = GetString(SI_SYNERGY_INFO_RELOAD),
    })
end

-- -----------------------------------------------------------------------------------------------
-- Auto-Load Preset je Rolle
-- -----------------------------------------------------------------------------------------------
local function AddAutoLoadPreset()
    BSCAS:AddControlToTab(1, {
        type = "header",
        name = GetString(SI_SYNERGY_NAME_PRE).." - ".. GetString(SI_GROUP_LIST_PANEL_PREFERRED_ROLES_LABEL).." (Default = no change)",
    })

    -- Tank
    BSCAS:AddControlToTab(1, {
        type = 'dropdown',
        name = "|t23:23:EsoUI/Art/LFG/LFG_tank_up_64.dds|t|r"..GetString("SI_LFGROLE", LFG_ROLE_TANK),
        choices = BSCAS:GetListNames(),
        getFunc = function() return BSCAS.SV.SELECTED_PRESET_TANK end,
        setFunc = function(value)
            BSCAS.SV.SELECTED_PRESET_TANK = value
            if GetSelectedLFGRole() == LFG_ROLE_TANK then
                CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_TANK).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", value))
                BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
                BSCAS.SV.SELECTED_PRESET = value
                BSCAS.UpdateSetting()
            end
        end,
        scrollable = 12,
        reference = "BSCAS_PresetDropdownTank",
    })

    -- Heal
    BSCAS:AddControlToTab(1, {
        type = 'dropdown',
        name = "|t23:23:EsoUI/Art/LFG/LFG_healer_up_64.dds|t|r"..GetString("SI_LFGROLE", LFG_ROLE_HEAL),
        choices = BSCAS:GetListNames(),
        getFunc = function() return BSCAS.SV.SELECTED_PRESET_HEAL end,
        setFunc = function(value)
            BSCAS.SV.SELECTED_PRESET_HEAL = value
            if GetSelectedLFGRole() == LFG_ROLE_HEAL then
                CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_HEAL).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", value))
                BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
                BSCAS.SV.SELECTED_PRESET = value
                BSCAS.UpdateSetting()
            end
        end,
        scrollable = 12,
        reference = "BSCAS_PresetDropdownHeal",
    })

    -- DPS
    BSCAS:AddControlToTab(1, {
        type = 'dropdown',
        name = "|t23:23:EsoUI/Art/LFG/LFG_dps_up_64.dds|t|r"..GetString("SI_LFGROLE", LFG_ROLE_DPS),
        choices = BSCAS:GetListNames(),
        getFunc = function() return BSCAS.SV.SELECTED_PRESET_DPS end,
        setFunc = function(value)
            BSCAS.SV.SELECTED_PRESET_DPS = value
            if GetSelectedLFGRole() == LFG_ROLE_DPS then
                CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading Blocking "..GetString("SI_LFGROLE", LFG_ROLE_DPS).." "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", value))
                BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
                BSCAS.SV.SELECTED_PRESET = value
                BSCAS.UpdateSetting()
            end
        end,
        scrollable = 12,
        reference = "BSCAS_PresetDropdownDps",
    })
end

-- -----------------------------------------------------------------------------------------------
-- Preset-Auswahl/Speichern/Import-Export
-- -----------------------------------------------------------------------------------------------
local function AddPresetSetting()
    BSCAS:AddControlToTab(1, {
        type = "header",
        name = GetString(SI_SYNERGY_NAME_PRE_H),
    })

    BSCAS:AddControlToTab(1, {
        type = "editbox",
        name = GetString(SI_SYNERGY_NAME_PRE_N),
        getFunc = function() return BSCAS.SV.SELECTED_PRESET end,
        setFunc = function(_) end,
        reference = "BSCAS_PresetEditbox",
    })
    BSCAS:AddControlToTab(1, {
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_B_S),
        func = BSCAS.AddSetting,
    })

    BSCAS:AddControlToTab(1, {
        type = 'dropdown',
        name = GetString(SI_SYNERGY_NAME_PRE_S),
        choices = BSCAS:GetListNames(),
        getFunc = function() return BSCAS.SV.SELECTED_PRESET end,
        setFunc = function(value)
            CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading "..GetString(SI_SYNERGY_NAME_PRE)..": <<1>>|r", value))
            BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
            BSCAS.LoadSetting(value)
        end,
        scrollable = 12,
        reference = "BSCAS_PresetDropdown",
    })
    BSCAS:AddControlToTab(1, {
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_B_D),
        func = BSCAS.DeleteSelected,
        isDangerous = true,
        warning = GetString(SI_SYNERGY_NAME_PRE_B_D).."?",
    })

    AddDivider(1)

    BSCAS:AddControlToTab(1, {
        type = "editbox",
        name = GetString(SI_SYNERGY_NAME_PRE_EB),
        tooltip = GetString(SI_SYNERGY_NAME_PRE_EB_I),
        isMultiline = true,
        isExtraWide = true,
        maxChars = 6000,
        default = BSCAS:ExportBlocked(),
        getFunc = function() return BSCAS:ExportBlocked() end,
        setFunc = function(value) end,
        reference = "BSCAS_PresetBlockAddEditBox",
    })
    BSCAS:AddControlToTab(1, {
        type = "button",
        name = GetString(SI_SYNERGY_NAME_PRE_IMP),
        func = function()
			BSCAS:ImportBlocked(BSCAS_PresetBlockAddEditBox.editbox:GetText())
        end,
        isDangerous = true,
        warning = GetString(SI_SYNERGY_NAME_PRE_W),
    })
end

-- -----------------------------------------------------------------------------------------------
-- Special Sets
-- -----------------------------------------------------------------------------------------------
local function AddSpecialSets()
    BSCAS:AddControlToTab(1, { type = "header", name = "Special Settings" })

    -- Lokke
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_LOKKE_CHECK),
        tooltip = GetString(SI_SYNERGY_NAME_LOKKE_INFO),
        getFunc = function() return GetSetting("LOKKECHECK") end,
        setFunc = function(v)
            SetSetting("LOKKECHECK", v, false)
            if v then
                SetSetting("RESOURCES_CHECK", false, true)
                SetSetting("ALKOSHCHECK", false, true)
            end
        end,
    })

    AddDivider(1)

    -- Alkosh
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_ALKOSH_CHECK),
        tooltip = GetString(SI_SYNERGY_NAME_ALKOSH_INFO),
        getFunc = function() return GetSetting("ALKOSHCHECK") end,
        setFunc = function(v)
            SetSetting("ALKOSHCHECK", v, false)
            if v then
                SetSetting("RESOURCES_CHECK", false, true)
                SetSetting("LOKKECHECK", false, true)
            end
        end,
    })
    BSCAS:AddControlToTab(1, {
        type = "slider",
        name = GetString(SI_SYNERGY_NAME_ALKOSH_REAPPLY),
        tooltip = GetString(SI_SYNERGY_NAME_ALKOSH_REAPPLY_TIP),
        disabled = function() return not GetSetting("ALKOSHCHECK") end,
        min = 0, max = 10, step = 1, default = 3,
        getFunc = function() return GetSetting("ALKOSH_REAPPLY") end,
        setFunc = function(v) SetSetting("ALKOSH_REAPPLY", v, true) end,
    })
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
		name = "Check only by Self Applyed",
		tooltip = "Use this Option if More ppl in your group wear Alkosh. Example for use vLC first Boss.",
        getFunc = function() return GetSetting("ALKOSH_BOSS_TARGET") end,
        disabled = function() return not GetSetting("ALKOSHCHECK") end,
		default = false,
        setFunc = function(v)
            SetSetting("ALKOSH_BOSS_TARGET", v, true)
        end,
    })	

    AddDivider(1)

    -- Only in combat
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_ONLY_COMBAT),
        tooltip = GetString(SI_SYNERGY_INFO_ONLY_COMBAT),
        getFunc = function() return GetSetting("ONLYINCOMBAT") end,
        setFunc = function(v) SetSetting("ONLYINCOMBAT", v) end,
    })

    AddDivider(1)

    -- Hotbar (ALL/PRIMARY/BACKUP) global
    BSCAS:AddControlToTab(1, {
        type = "dropdown",
        name = GetString(SI_SYNERGY_NAME_HOTBAR),
        tooltip = GetString(SI_SYNERGY_MI_HOTBAR_INFO),
        choices = {"ALL", "PRIMARY", "BACKUP"},
        getFunc = function()
            if GetSetting("NEW_BARCHECK") == HOTBAR_CATEGORY_PRIMARY then
                return "PRIMARY"
            elseif GetSetting("NEW_BARCHECK") == HOTBAR_CATEGORY_BACKUP then
                return "BACKUP"
            else
                return "ALL"
            end
        end,
        setFunc = function(v)
            if v == "PRIMARY" then
                SetSetting("NEW_BARCHECK", HOTBAR_CATEGORY_PRIMARY, true)
            elseif v == "BACKUP" then
                SetSetting("NEW_BARCHECK", HOTBAR_CATEGORY_BACKUP, true)
            else
                SetSetting("NEW_BARCHECK", -1, true)
            end
            BSCAS.UpdateSetting()
        end,
        width = "full",
    })

    -- Berserk
    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_BERSERK),
        tooltip = GetString(SI_SYNERGY_INFO_BERSERK),
        getFunc = function() return GetSetting("BERSERK_CHECK") end,
        setFunc = function(v) SetSetting("BERSERK_CHECK", v) BSCAS.UpdateSetting() end,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Resource Checking
-- -----------------------------------------------------------------------------------------------
local function AddResourceSetting()
    BSCAS:AddControlToTab(1, { type = "header", name = GetString(SI_SYNERGY_NAME_RESOURCE) })

    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = "Set Check",
        tooltip = GetString(SI_SYNERGY_NAME_RESOURCE_TIP_SET),
        getFunc = function() return GetSetting("RESOURCES_CHECK_SETS") end,
        setFunc = function(v) SetSetting("RESOURCES_CHECK_SETS", v) BSCAS:CheckEquipment() end,
    })

    BSCAS:AddControlToTab(1, {
        type = "description",
        text = zo_strformat(
            "Set's are Checked: <<1>>, <<2>>, <<3>>, <<4>>",
            select(2, GetItemLinkSetInfo("|H0:item:186565:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:130:0:0:0:10000:0|h|h")),
            select(2, GetItemLinkSetInfo("|H0:item:173609:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:122:0:0:0:10000:0|h|h")),
            select(2, GetItemLinkSetInfo("|H1:item:95453:364:50:45883:370:50:31:0:0:0:0:0:0:0:1:35:0:1:0:0:0|h|h")),
            select(2, GetItemLinkSetInfo("|H1:item:171437:364:50:45875:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"))
        ),
        width = "full",
    })

    AddDivider(1)

    BSCAS:AddControlToTab(1, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_RESOURCE_ENABLE),
        getFunc = function() return GetSetting("RESOURCES_CHECK") end,
        setFunc = function(v)
            SetSetting("RESOURCES_CHECK", v, true)
            if v then
                SetSetting("LOKKECHECK", false, true)
                SetSetting("ALKOSHCHECK", false, true)
            end
        end,
    })
    BSCAS:AddControlToTab(1, {
        type = "slider",
        name = GetString(SI_SYNERGY_NAME_RESOURCE_SLIDER_S),
        tooltip = GetString(SI_SYNERGY_NAME_RESOURCE_TIP),
        disabled = function() return not (GetSetting("RESOURCES_CHECK") or GetSetting("RESOURCES_CHECK_SETS")) end,
        min = 0, max = 100, step = 5, default = 80,
        getFunc = function() return GetSetting("RESOURCES_VALUE_S") end,
        setFunc = function(v) SetSetting("RESOURCES_VALUE_S", v, true) end,
    })
    BSCAS:AddControlToTab(1, {
        type = "slider",
        name = GetString(SI_SYNERGY_NAME_RESOURCE_SLIDER_M),
        tooltip = GetString(SI_SYNERGY_NAME_RESOURCE_TIP),
        disabled = function() return not (GetSetting("RESOURCES_CHECK") or GetSetting("RESOURCES_CHECK_SETS")) end,
        min = 0, max = 100, step = 5, default = 80,
        getFunc = function() return GetSetting("RESOURCES_VALUE_M") end,
        setFunc = function(v) SetSetting("RESOURCES_VALUE_M", v, true) end,
    })

    AddDivider(1)
end

-- -----------------------------------------------------------------------------------------------
-- Undaunted (Submenu)
-- -----------------------------------------------------------------------------------------------
local function AddUndauntedSetting()
    local control = {}
    AddSynergyControl(control, ICON_UNDAUNTED_ALTAR_0, GetString(SI_SYNERGY_DESC_BLOODALTAR),  SI_SYNERGY_NAME_BLOODALTAR, "UNDAUNTED_ALTAR", true, false, true)
    AddSynergyControl(control, ICON_UNDAUNTED_WEBS_0,  GetString(SI_SYNERGY_DESC_WEBS),       SI_SYNERGY_NAME_WEBS,      "UNDAUNTED_WEBS",  true, false, true)
    AddSynergyControl(control, ICON_UNDAUNTED_FIRE_0,  GetString(SI_SYNERGY_DESC_INNERFIRE),  SI_SYNERGY_NAME_INNERFIRE, "UNDAUNTED_FIRE",  true, false, true)
    AddSynergyControl(control, ICON_UNDAUNTED_BONE_0,  GetString(SI_SYNERGY_DESC_BONE),       SI_SYNERGY_NAME_BONE,      "UNDAUNTED_BONE",  true, false, true)
    AddSynergyControl(control, ICON_UNDAUNTED_ORB_0,   GetString(SI_SYNERGY_DESC_ORB),        SI_SYNERGY_NAME_ORB,       "UNDAUNTED_ORB",   true, false, true)
    AddSynergyControl(control, ICON_UNDAUNTED_ORB_2,   GetString(SI_SYNERGY_DESC_ORB2),       SI_SYNERGY_NAME_ORB2,      "UNDAUNTED_ORB_HEALING", true, false, false)

    BSCAS:AddControlToTab(1, {
        type = "submenu",
        name = GetString(SI_SYNERGY_NAME_TREE_UNDAUNTED), --zo_strformat("<<1>>", GetUndauntedSkillLineName()),
        controls = control,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Klassen (Submenu)
-- -----------------------------------------------------------------------------------------------
local function Class_Templar(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_TEMPLAR) })
    AddSynergyControl(list, ICON_TEMPLAR_SPEAR_2, GetString(SI_SYNERGY_DESC_SHARDS1), SI_SYNERGY_NAME_SHARDS,   "TEMPLAR_SHARDS",     true, false, true)
    AddSynergyControl(list, ICON_TEMPLAR_SPEAR_1, GetString(SI_SYNERGY_DESC_SHARDS),  SI_SYNERGY_NAME_SHARDS1,  "TEMPLAR_SHARDS_DMG", true, false, true)
    AddSynergyControl(list, ICON_TEMPLAR_RITUAL_0,GetString(SI_SYNERGY_DESC_PURGE),   SI_SYNERGY_NAME_PURGE,    "TEMPLAR_PURGE",      true, false, true)
    AddSynergyControl(list, ICON_TEMPLAR_NOVA_0,  GetString(SI_SYNERGY_DESC_NOVA),    SI_SYNERGY_NAME_NOVA,     "TEMPLAR_NOVA",       true, false, false)
end

local function Class_Sorcerer(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_SORC) })
    AddSynergyControl(list, ICON_SORC_CONDUIT_0, GetString(SI_SYNERGY_DESC_CONDUIT), SI_SYNERGY_NAME_CONDUIT, "SORC_CONDUIT", true, false, true)
    AddSynergyControl(list, ICON_SORC_ATRO_0,    GetString(SI_SYNERGY_DESC_ATRO),    SI_SYNERGY_NAME_ATRO,    "SORC_ATRO",    true, false, false)
end

local function Class_Dragonknight(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_DK) })
    AddSynergyControl(list, ICON_DK_CLAW_0,     GetString(SI_SYNERGY_DESC_IMPALE),   SI_SYNERGY_NAME_IMPALE,   "DK_IMPALE",    true, false, true)
    AddSynergyControl(list, ICON_DK_STANDARTE_0,GetString(SI_SYNERGY_DESC_STANDARTE),SI_SYNERGY_NAME_STANDARTE,"DK_STANDARTE", true, false, false)
end

local function Class_Nightblade(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_NB) })
    AddSynergyControl(list, ICON_NB_HIDE_0, GetString(SI_SYNERGY_DESC_DARK), SI_SYNERGY_NAME_DARK, "NB_DARK", true, false, true)
    AddSynergyControl(list, ICON_NB_SOUL_0, GetString(SI_SYNERGY_DESC_SOUL), SI_SYNERGY_NAME_SOUL, "NB_SOUL", true, false, false)
end

local function Class_Warden(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WARDN) })
    AddSynergyControl(list, ICON_WARDEN_HARVEST_0, GetString(SI_SYNERGY_DESC_HARVEST), SI_SYNERGY_NAME_HARVEST, "WARDEN_HARVEST", true, false, true)
    AddSynergyControl(list, ICON_WARDEN_ICE_0,     GetString(SI_SYNERGY_DESC_ICYESC),  SI_SYNERGY_NAME_ICYESC,  "WARDEN_ICYESC",  true, false, false)
end

local function Class_Necromancer(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_NECRO) })
    AddSynergyControl(list, ICON_NECRO_GRAVE_0, GetString(SI_SYNERGY_DESC_BONEYARD), SI_SYNERGY_NAME_BONEYARD, "NECRO_BONEYARD", true, false, true)
    AddSynergyControl(list, ICON_NECRO_TOTEM_0, GetString(SI_SYNERGY_DESC_TOTEM),    SI_SYNERGY_NAME_TOTEM,    "NECRO_TOTEM",   true, false, false)
end

local function Class_Arcanist(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_ARCANIST) })
    AddSynergyControl(list, ICON_ARCANIST_RUNE,   GetString(SI_SYNERGY_DESC_RUNE),   SI_SYNERGY_NAME_RUNE,   "ARCANIST_RUNE",   true, false, true)
    AddSynergyControl(list, ICON_ARCANIST_PORTAL, GetString(SI_SYNERGY_DESC_PORTAL), SI_SYNERGY_NAME_PORTAL, "ARCANIST_PORTAL", true, false, false)
end

local function AddClassesSetting()
    local control = {}
    Class_Templar(control)
    Class_Sorcerer(control)
    Class_Dragonknight(control)
    Class_Nightblade(control)
    Class_Warden(control)
    Class_Necromancer(control)
    if GetAPIVersion() > 101037 then
        Class_Arcanist(control)
    end
    BSCAS:AddControlToTab(1, {
        type = "submenu",
        name = GetString(SI_SYNERGY_NAME_CLASSES),
        controls = control,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Transformationen (Werwolf / Vampir / Gilde)
-- -----------------------------------------------------------------------------------------------
local function Werwolf(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_WOLF) })
    AddSynergyControl(list, ICON_WOLF,         GetString(SI_SYNERGY_DESC_FEEDING_FRENZY),  SI_SYNERGY_NAME_FEEDING_FRENZY, "WW_HUNT", false, false, true)
    AddSynergyControl(list, ICON_WOLF_DEVOUR,  GetString(SI_SYNERGY_DESC_DEVOUR),SI_SYNERGY_NAME_DEVOUR, "WW_DEVOUR", false, true, false)
end

local function Vampir(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_VAMP) })
    AddSynergyControl(list, ICON_VAMP, GetString(SI_SYNERGY_DESC_EAT), SI_SYNERGY_ABILITY_EAT, "VAMP_EAT", true, false, false)
end

local function Guild(list)
    table.insert(list, { type = "header", name = GetString(SI_SYNERGY_NAME_TREE_BH) })
    AddSynergyControl(list, ICON_BROTHERHOOD, "", SI_SYNERGY_ABILITY_BH, "HOOD_BLADE", true, false, false)
end

local function AddTransformSetting()
    local control = {}
    Werwolf(control)
    Vampir(control)
    Guild(control)
    BSCAS:AddControlToTab(1, {
        type = "submenu",
        name = GetString(SI_SYNERGY_NAME_TRANSFORM),
        controls = control,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Raids (CR, HRC, SS, KA, RG, DSR, SE, LC, OC)
-- -----------------------------------------------------------------------------------------------
local function AddRaidSetting()
    local control = {}

    -- CR (Cloudrest)
    table.insert(control, { type = "header", name = Z(1051) })
    AddTexture(control, ICON_VCR_GATE, GetString(SI_SYNERGY_DESC_GATEWAY))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_GATEWAY),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("CR_PORTAL") end,
        setFunc = function(v) SetSetting("CR_PORTAL", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        disabled = function() return not GetSetting("CR_PORTAL") end,
        name = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR),
        tooltip = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR_DESC),
        getFunc = function() return GetSetting("CR_PORTAL_BLOCK_DB") end,
        setFunc = function(v) SetSetting("CR_PORTAL_BLOCK_DB", v, true) end,
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("CR_PORTAL_IGCHK") end,
        setFunc = function(v) SetSetting("CR_PORTAL_IGCHK", v) end,
        width = "full",
    })

    -- HRC (Hel Ra Citadel)
    table.insert(control, { type = "header", name = Z(636) })
    AddTexture(control, ICON_HRC_BREAKOUT, GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_DESTRUCTIVE_OUTBREAK),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("HRC_CONFIRM") end,
        setFunc = function(v) SetSetting("HRC_CONFIRM", v) end,
        width = "half",
    })

    -- SS (Sunspire)
    table.insert(control, { type = "header", name = Z(1121) })
    AddTexture(control, ICON_VSS_TIMESHIFT, GetString(SI_SYNERGY_DESC_TIME_BREACH))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_TIME_BREACH),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("SS_PORTAL") end,
        setFunc = function(v) SetSetting("SS_PORTAL", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("SS_PORTAL_IGCHK") end,
        setFunc = function(v) SetSetting("SS_PORTAL_IGCHK", v) end,
        width = "full",
    })

    -- KA (Kyne’s Aegis)
    table.insert(control, { type = "header", name = Z(1196) })
    AddTexture(control, ICON_VKA_PORTAL, GetString(SI_SYNERGY_DESC_KA_PORTAL))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_KA_PORTAL),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("KA_PORTAL") end,
        setFunc = function(v) SetSetting("KA_PORTAL", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("KA_PORTAL_IGCHK") end,
        setFunc = function(v) SetSetting("KA_PORTAL_IGCHK", v) end,
        width = "full",
    })

    AddDivider(control)

    AddTexture(control, ICON_VKA_EXECRATION, GetString(SI_SYNERGY_DESC_KA_EXECRATION))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_KA_EXECRATION),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("KA_EXECRATION") end,
        setFunc = function(v) SetSetting("KA_EXECRATION", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("KA_EXECRATION_IGCHK") end,
        setFunc = function(v) SetSetting("KA_EXECRATION_IGCHK", v) end,
        width = "full",
    })

    -- RG (Rockgrove)
    table.insert(control, { type = "header", name = Z(1263) })
    AddTexture(control, ICON_RG_BLOP, "")
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_RG_BLOP),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("RG_PURGE_BLOCK") end,
        setFunc = function(v) SetSetting("RG_PURGE_BLOCK", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "slider",
        name = GetString(SI_SYNERGY_CB_ENABLE_MS),
        tooltip = GetString(SI_SYNERGY_CB_ENABLE_TT_MS),
        disabled = function() return GetSetting("RG_PURGE_BLOCK") end,
        min = 0, max = 4000, step = 100, default = 2000,
        getFunc = function() return GetSetting("RG_PURGE_BLOCK_CD") end,
        setFunc = function(v) SetSetting("RG_PURGE_BLOCK_CD", v, true) end,
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_CB_ALERT_BLOP),
        tooltip = GetString(SI_SYNERGY_CB_ALERT_BLOP_TT),
        getFunc = function() return GetSetting("RG_PURGE_BLOCK_ALERT") end,
        setFunc = function(v) SetSetting("RG_PURGE_BLOCK_ALERT", v) end,
        width = "full",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("RG_PURGE_BLOCK_IGCHK") end,
        setFunc = function(v) SetSetting("RG_PURGE_BLOCK_IGCHK", v) end,
        width = "full",
    })

    -- DSR (Dreadsail Reef)
    table.insert(control, { type = "header", name = Z(1344) })
    AddTexture(control, ICON_DSR_SURGING_WATERS, GetString(SI_SYNERGY_DESC_DSR_SURGING_WATERS))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_DSR_SURGING_WATERS),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("DSR_SURGING_WATERS") end,
        setFunc = function(v)
            SetSetting("DSR_SURGING_WATERS", v, true)
            if GetSetting("DSR_SURGING_WATERS_BLOCK_DB") then
                SetSetting("DSR_SURGING_WATERS_BLOCK_DB", false, true)
            end
            BSCAS.UpdateSetting()
        end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        disabled = function() return not GetSetting("DSR_SURGING_WATERS") end,
        name = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR),
        tooltip = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR_DESC),
        getFunc = function() return GetSetting("DSR_SURGING_WATERS_BLOCK_DB") end,
        setFunc = function(v) SetSetting("DSR_SURGING_WATERS_BLOCK_DB", v, true) end,
    })
    table.insert(control, {
        type = "slider",
        name = GetString(SI_SYNERGY_CB_ENABLE_S),
        tooltip = GetString(SI_SYNERGY_CB_ENABLE_TT_S),
        disabled = function() return not GetSetting("DSR_SURGING_WATERS_BLOCK_DB") end,
        min = 0, max = 60, step = 1, default = 20,
        getFunc = function() return GetSetting("DSR_SURGING_WATERS_CD") end,
        setFunc = function(v) SetSetting("DSR_SURGING_WATERS_CD", v, true) end,
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("DSR_SURGING_WATERS_IGCHK") end,
        setFunc = function(v) SetSetting("DSR_SURGING_WATERS_IGCHK", v) end,
        width = "full",
    })

    -- SE (Sanity’s Edge)
    table.insert(control, { type = "header", name = Z(1427) })
    AddTexture(control, ICON_SE_VANTONS_CLARITY, GetString(SI_SYNERGY_DESC_SE_VANTONS_CLARITY))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_SE_VANTONS_CLARITY),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("SE_VANTONS_CLARITY") end,
        setFunc = function(v) SetSetting("SE_VANTONS_CLARITY", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("SE_VANTONS_CLARITY_IGCHK") end,
        setFunc = function(v) SetSetting("SE_VANTONS_CLARITY_IGCHK", v) end,
        width = "full",
    })

    AddDivider(control)

    AddTexture(control, ICON_SE_ATTUNEMENT, GetString(SI_SYNERGY_DESC_SE_ATTUNEMENT))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_SE_ATTUNEMENT),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("SE_ATTUNEMENT") end,
        setFunc = function(v) SetSetting("SE_ATTUNEMENT", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("SE_ATTUNEMENT_IGCHK") end,
        setFunc = function(v) SetSetting("SE_ATTUNEMENT_IGCHK", v) end,
        width = "full",
    })

    -- LC (Lords of the Clockwork? – Zone-ID lt. Vorlage)
    table.insert(control, { type = "header", name = Z(1478) })
    AddTexture(control, ICON_LC_MIRROR, GetString(SI_SYNERGY_DESC_LC_MIRROR))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_LC_MIRROR),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("LC_MIRROR") end,
        setFunc = function(v)
            SetSetting("LC_MIRROR", v, true)
            if GetSetting("LC_MIRROR_BLOCK_DB") then
                SetSetting("LC_MIRROR_BLOCK_DB", false, true)
            end
            BSCAS.UpdateSetting()
        end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        disabled = function() return not GetSetting("LC_MIRROR") end,
        name = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR),
        tooltip = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR_DESC),
        getFunc = function() return GetSetting("LC_MIRROR_BLOCK_DB") end,
        setFunc = function(v) SetSetting("LC_MIRROR_BLOCK_DB", v, true) end,
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("LC_MIRROR_IGCHK") end,
        setFunc = function(v) SetSetting("LC_MIRROR_IGCHK", v) end,
        width = "full",
    })

    -- OC (Ophidian’s Chasm? – gemäß deiner Konstanten)
    table.insert(control, { type = "header", name = Z(1548) })
    AddTexture(control, ICON_OC_CARRIONSHIELD, GetString(SI_SYNERGY_DESC_OC_CARRIONSHIELD))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_OC_CARRIONSHIELD),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("OC_CARRIONSHIELD") end,
        setFunc = function(v)
            SetSetting("OC_CARRIONSHIELD", v, true)
            if GetSetting("OC_CARRIONSHIELD_BLOCK_DB") then
                SetSetting("OC_CARRIONSHIELD_BLOCK_DB", false, true)
            end
            BSCAS.UpdateSetting()
        end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        disabled = function() return not GetSetting("OC_CARRIONSHIELD") end,
        name = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR),
        tooltip = GetString(SI_SYNERGY_DEBUFF_TRAIL_CR_DESC),
        getFunc = function() return GetSetting("OC_CARRIONSHIELD_BLOCK_DB") end,
        setFunc = function(v) SetSetting("OC_CARRIONSHIELD_BLOCK_DB", v, true) end,
    })
    table.insert(control, {
        type = "slider",
        name = GetString(SI_SYNERGY_CB_ENABLE_STACKS),
        tooltip = GetString(SI_SYNERGY_CB_ENABLE_TT_STACKS),
        disabled = function() return not GetSetting("OC_CARRIONSHIELD_BLOCK_DB") end,
        min = 0, max = 6, step = 1, default = 3,
        getFunc = function() return GetSetting("OC_CARRIONSHIELD_CD") end,
        setFunc = function(v) SetSetting("OC_CARRIONSHIELD_CD", v, true) end,
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("OC_CARRIONSHIELD_IGCHK") end,
        setFunc = function(v) SetSetting("OC_CARRIONSHIELD_IGCHK", v) end,
        width = "full",
    })

    AddDivider(control)

    AddTexture(control, ICON_OC_DREADFUL_PORTAL, GetString(SI_SYNERGY_DESC_OC_DREADFUL_PORTAL))
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_ABILITY_OC_DREADFUL_PORTAL),
        tooltip = GetString(SI_SYNERGY_TOOLTIP),
        getFunc = function() return GetSetting("OC_DREADFUL_PORTAL") end,
        setFunc = function(v) SetSetting("OC_DREADFUL_PORTAL", v) end,
        width = "half",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_IGNORE),
        tooltip = GetString(SI_SYNERGY_IGNORE_TT),
        getFunc = function() return GetSetting("OC_DREADFUL_PORTAL_IGCHK") end,
        setFunc = function(v) SetSetting("OC_DREADFUL_PORTAL_IGCHK", v) end,
        width = "full",
    })
    table.insert(control, {
        type = "checkbox",
        name = GetString(SI_SYNERGY_NAME_ONLY_OUT_COMBAT),
        tooltip = GetString(SI_SYNERGY_INFO_ONLY_OUT_COMBAT),
        getFunc = function() return GetSetting("OC_DREADFUL_PORTAL_OOCB") end,
        setFunc = function(v) SetSetting("OC_DREADFUL_PORTAL_OOCB", v) end,
        width = "full",
    })
    AddDivider(control)

    BSCAS:AddControlToTab(1, {
        type  = "submenu",
        name  = GetString(SI_SYNERGY_NAME_RAID),
        controls = control,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Arenen (Submenu)
-- -----------------------------------------------------------------------------------------------
local function AddArenaSetting()
    local control = {}
    AddSynergyControl(control, ICON_ARENA_RESURRECTION, GetString(SI_SYNERGY_DESC_RESURRECTION), SI_SYNERGY_NAME_RESURRECTION, "ARENA_RESURRECTION", false, false, true)
    AddSynergyControl(control, ICON_ARENA_DEFENSE,      GetString(SI_SYNERGY_DESC_DEFENSE),      SI_SYNERGY_NAME_DEFENSE,      "ARENA_DEFENSE",      false, false, true)
    AddSynergyControl(control, ICON_ARENA_HEALING,      GetString(SI_SYNERGY_DESC_HEALING),      SI_SYNERGY_NAME_HEALING,      "ARENA_HEALING",      false, false, true)
    AddSynergyControl(control, ICON_ARENA_SUSTAIN,      GetString(SI_SYNERGY_DESC_SUSTAIN),      SI_SYNERGY_NAME_SUSTAIN,      "ARENA_SUSTAIN",      false, false, true)
    AddSynergyControl(control, ICON_ARENA_POWER,        GetString(SI_SYNERGY_DESC_POWER),        SI_SYNERGY_NAME_POWER,        "ARENA_POWER",        false, false, true)
    AddSynergyControl(control, ICON_ARENA_SPEED,        GetString(SI_SYNERGY_DESC_HASTE),        SI_SYNERGY_NAME_HASTE,        "ARENA_HASTE",        false, false, false)

    BSCAS:AddControlToTab(1, {
        type = "submenu",
        name = GetString(SI_SYNERGY_NAME_ARENA),
        controls = control,
    })
end

-- -----------------------------------------------------------------------------------------------
-- Items (Submenu)
-- -----------------------------------------------------------------------------------------------
local function AddItemSetting()
    local control = {}
    AddSynergyControl(control, ICON_ITEM_URSUS,   GetString(SI_SYNERGY_ITEM_DESC_URSUS),     SI_SYNERGY_ITEM_NAME_URSUS,     "ITEM_URSUS",     false, false, true)
    AddSynergyControl(control, ICON_ITEM_KRAGLEN, GetString(SI_SYNERGY_ITEM_DESC_KRAGLEN),   SI_SYNERGY_ITEM_NAME_KRAGLEN,   "ITEM_KRAGLEN",   false, false, true)
    AddSynergyControl(control, ICON_ITEM_SANGUINE,GetString(SI_SYNERGY_ITEM_DESC_SANGUINE),  SI_SYNERGY_ITEM_NAME_SANGUINE,  "ITEM_SANGUINE",  false, false, true)
    AddSynergyControl(control, ICON_ITEM_SANGUINE,GetString(SI_SYNERGY_ITEM_DESC_GPREPRISAL),SI_SYNERGY_ITEM_NAME_GPREPRISAL,"ITEM_GPREPRISAL",false, false, false)

    BSCAS:AddControlToTab(1, {
        type = "submenu",
        name = GetString(SI_SYNERGY_NAME_ITEMS),
        controls = control,
        expanded = false, -- wie in deiner Vorlage
    })
end

-- -----------------------------------------------------------------------------------------------
-- PUBLIC API
-- -----------------------------------------------------------------------------------------------
function BSCAS:InitBlockMenu()
    -- Reihenfolge beibehalten wie in deiner Version	
	AddBaseSetting()
    AddAutoLoadPreset()

    AddPresetSetting()
    AddSpecialSets()
    AddResourceSetting()

    AddUndauntedSetting()
    AddClassesSetting()
    AddTransformSetting()

    AddRaidSetting()
    AddArenaSetting()
    AddItemSetting()
end