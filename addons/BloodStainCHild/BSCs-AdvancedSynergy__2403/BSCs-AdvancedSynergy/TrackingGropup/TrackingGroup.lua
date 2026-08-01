BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local BSC_GROUP_SIZE_MAX = 12

local SYNERGYLIST = {}
local TSG_LIST = {}

local GROUP_INFO = {}
local GROUP_UNITID = {}

-- Falls deine Role-Flags noch nicht gesetzt sind: als true behandeln
local function RoleAllowed(role)
    local t = (BSCAS.SV.GROUP_TRACKING_TANK ~= false)
    local h = (BSCAS.SV.GROUP_TRACKING_HEAL ~= false)
    local d = (BSCAS.SV.GROUP_TRACKING_DPS  ~= false)
    if role == LFG_ROLE_TANK then return t
    elseif role == LFG_ROLE_HEAL then return h
    -- LFG_ROLE_INVALID => behandle wie DPS
    else return d end
end

-- =====================================================================
-- Debugtoggle
-- =====================================================================
local debug_mode = false
function BSCAS.TrackGroupDebugMode()
    debug_mode = not debug_mode
    BSCAS:PrintDebug("Debug Mode (Tracking) " .. (debug_mode and "Enabled!" or "Disabled!"))
end

-- =====================================================================
-- Helper
-- =====================================================================
local function GetRoleIcon(role)
    if role == LFG_ROLE_TANK then return "/esoui/art/lfg/lfg_icon_tank.dds"
    elseif role == LFG_ROLE_HEAL then return "/esoui/art/lfg/lfg_icon_healer.dds"
    else return "/esoui/art/lfg/lfg_icon_dps.dds" end
end

local function SetFillColorByPercent(bar, p)
    local r, g
    if p > 0.66 then r, g = 0.2, 1.0
    elseif p > 0.33 then r, g = 1.0, 0.7
    else r, g = 1.0, 0.2 end
    bar:SetGradientColors(r, g, 0, 0.6, r, g, 0, 0.6)
end

local function RoleOrder(role) -- Tank -> Heal -> DPS
    return (role == LFG_ROLE_TANK and 1) or (role == LFG_ROLE_HEAL and 2) or 3
end

local function CanonName(n) return zo_strlower(zo_strformat("<<1>>", n or "")) end

-- =====================================================================
-- Tracking-IDs
-- =====================================================================
local function UpdateEnabled()
    SYNERGYLIST = {
        [ABILITYID_CD_BLOOD_FUNNEL]        = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BLOODALTAR,  id = 1,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BLOOD_FUNNEL),     },
        [ABILITYID_CD_FEAST_FUNNEL]        = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BLOODALTAR,  id = 1,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_FEAST_FUNNEL),     },
        [ABILITYID_CD_SPAWNBROODLING]      = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SPAWNBROODLING),   },
        [ABILITYID_CD_BLACK_WIDOW]         = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BLACK_WIDOW),     },
        [ABILITYID_CD_ARACHNOPHOBIA]       = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_ARACHNOPHOBIA),  },
        [ABILITYID_CD_BONE_WALL]           = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BONESHIELD,  id = 3,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BONE_WALL),       },
        [ABILITYID_CD_SPINALSURGE]         = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BONESHIELD,  id = 3,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SPINALSURGE),     },
        [ABILITYID_CD_SHARTBUBLE_1]        = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_1),    },
        [ABILITYID_CD_SHARTBUBLE_2]        = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_2),    },
        [ABILITYID_CD_SHARTBUBLE_3]        = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_3),    },
        [ABILITYID_CD_HEALING_COMBUSTION]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_HEALING_COMBUSTION), },
        [ABILITYID_CD_PURIFY]              = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PURIFY,      id = 5,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PURIFY),        },
        [ABILITYID_CD_CONDUIT]             = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.CONDUIT,     id = 6,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_CONDUIT),       },
        [ABILITYID_CD_CHARGED_LIGHTNING]   = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.ATRONACH,    id = 7,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_CHARGED_LIGHTNING),},
        [ABILITYID_CD_SHACKLE]             = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHACKLE,     id = 8,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHACKLE),      },
        [ABILITYID_CD_IGNITE]              = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHACKLE,     id = 8,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_IGNITE),       },
        [ABILITYID_CD_HARVEST]             = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.HARVEST,     id = 9,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_HARVEST),      },
        [ABILITYID_CD_GRAVEROBBER]         = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.GRAVEROBBER, id = 10, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_GRAVEROBBER),   },
        [ABILITYID_CD_PURE_AGONY]          = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PUREAGONY,   id = 11, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PURE_AGONY),   },
        [ABILITYID_CD_FEEDING_FRENZY]      = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.HOWLING,     id = 12, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_FEEDING_FRENZY),},
        [ABILITYID_CD_RUNE]                = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.RUNE,        id = 17, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_RUNE),        },
        [ABILITYID_CD_PORTAL]              = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PORTAL,      id = 18, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PORTAL),      },
        [ABILITYID_CD_INNERFIRE]           = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.INNERFIRE,   id = 23, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_INNERFIRE),   },
        -- Sets (Quelle ist i.d.R. der Spieler selbst)
        [ABILITYID_CD_URSUS]               = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.URSUS,       id = 13, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_URSUS),       },
        [ABILITYID_URSUS]                  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.URSUS,       id = 13, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_CD_URSUS),       },
        [ABILITYID_CD_KRAGLEN]             = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.KRAGLEN,     id = 14, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_KRAGLEN),     },
        [ABILITYID_KRAGLEN]                = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.KRAGLEN,     id = 14, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_CD_KRAGLEN),     },
        [ABILITYID_CD_SANGUINE]            = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.LADYTHORN,   id = 15, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SANGUINE),    },
        [ABILITYID_SANGUINE]               = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.LADYTHORN,   id = 15, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_SANGUINE),      },
        [ABILITYID_CD_GPREPRISAL]          = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.GPREPRISAL,  id = 16, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_GPREPRISAL),  },
        [ABILITYID_GPREPRISAL]             = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.GPREPRISAL,  id = 16, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_GPREPRISAL),    },
        -- Portale
        [ABILITYID_CD_VCRPORTAL]           = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.CR_PRTAL,    id = 19, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_VCRPORTAL),  },
        [ABILITYID_CD_DSR_REEF]            = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.DSR_REEF,    id = 20, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_DSR_REEF),    },
        [ABILITYID_CD_SE_AGONY]            = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SE_PORTAL,   id = 21, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SE_AGONY),   },
        [ABILITYID_CD_SE_VANTO_CLARITY]    = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SE_PORTAL,   id = 21, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SE_VANTO_CLARITY), },
        [ABILITYID_CD_LC_MIRROR]           = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.LC_MIRROR,   id = 22, bFilterSource = false,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_LC_MIRROR), },
        [ABILITYID_SYNERGY_ACTIVATE]    = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.OC_SHIELD,   id = 24, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_OC_CARRIONSHIELD), },
    }

    TSG_LIST = {
        [1]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BLOODALTAR, icon = ICON_UNDAUNTED_ALTAR_0,     bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [2]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SPIDERS,    icon = ICON_UNDAUNTED_WEBS_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [3]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.BONESHIELD, icon = ICON_UNDAUNTED_BONE_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [4]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHARTSORBS, icon = ICON_UNDAUNTED_ORB_2,       bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [5]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PURIFY,     icon = ICON_TEMPLAR_RITUAL_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [6]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.CONDUIT,    icon = ICON_SORC_CONDUIT_0,        bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [7]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.ATRONACH,   icon = ICON_SORC_ATRO_0,           bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [8]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SHACKLE,    icon = ICON_DK_CLAW_0,             bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [9]  = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.HARVEST,    icon = ICON_WARDEN_HARVEST_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [10] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.GRAVEROBBER,icon = ICON_NECRO_GRAVE_0,         bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [11] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PUREAGONY,  icon = ICON_NECRO_TOTEM_0,         bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [12] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.HOWLING,    icon = ICON_WOLF,                  bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [13] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.URSUS,      icon = ICON_ITEM_URSUS,            bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 },
        [14] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.KRAGLEN,    icon = ICON_ITEM_KRAGLEN,          bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 },
        [15] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.LADYTHORN,  icon = ICON_ITEM_SANGUINE,         bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 },
        [16] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.GPREPRISAL, icon = ICON_ITEM_GPREPRISAL,       bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 },
        [17] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.RUNE,       icon = ICON_ARCANIST_RUNE,         bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [18] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.PORTAL,     icon = ICON_ARCANIST_PORTAL,       bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [19] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.CR_PRTAL,   icon = ICON_VCR_GATE,              bSetCD=false, cdset=0, cdsyn=0, zoneid=1051 },
        [20] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.DSR_REEF,   icon = ICON_DSR_DINFESTATION,      bSetCD=false, cdset=0, cdsyn=0, zoneid=1344 },
        [21] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.SE_PORTAL,  icon = ICON_SE_AGONY,              bSetCD=false, cdset=0, cdsyn=0, zoneid=1427 },
        [22] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.LC_MIRROR,  icon = ICON_LC_MIRROR,             bSetCD=false, cdset=0, cdsyn=0, zoneid=1478 },
        [23] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.INNERFIRE,  icon = ICON_UNDAUNTED_FIRE_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 },
        [24] = { enable = BSCAS.SV.GROUP_TRACKING_UI_TSG_LIST.OC_SHIELD,  icon = ICON_OC_CARRIONSHIELD,      bSetCD=false, cdset=0, cdsyn=0, zoneid=1548 },
    }
end

-- =====================================================================
-- Combat Events (Fix: Source/Target korrekt + Fallback via Name)
-- =====================================================================
local function TryFindUnitTagByName(whoName)
    if not whoName or whoName == "" then return nil end
    local needle = CanonName(whoName)
    for i=1, GetGroupSize() do
        local ut = GetGroupUnitTagByIndex(i)
        if ut and IsUnitPlayer(ut) then
            if CanonName(GetUnitName(ut)) == needle or CanonName(GetUnitDisplayName(ut)) == needle then
                return ut
            end
        end
    end
end

local function OnCombatEvent(_, result, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if result ~= ACTION_RESULT_EFFECT_GAINED and not (result == ACTION_RESULT_BEGIN and abilityId == 237744) then
        return
    end
    local cfg = SYNERGYLIST[abilityId]
    if not (cfg and cfg.enable) then return end

    local unitId  = cfg.bFilterSource and sourceUnitId or targetUnitId
    local nameStr = cfg.bFilterSource and sourceName   or targetName
    local unitTag = GROUP_UNITID[unitId]

    if not unitTag then
        unitTag = TryFindUnitTagByName(nameStr)
    end
    if not unitTag then return end

    local gi = GROUP_INFO[unitTag]
    if not gi then return end

    local listId = cfg.id
    local now = GetGameTimeMilliseconds()/1000
    local dur = (cfg.cd or 0)/1000
    gi.cdList[listId].start    = now
    gi.cdList[listId].cd       = now + dur
    gi.cdList[listId].duration = dur
    gi.cdList[listId].endsAt   = now + dur
end

-- =====================================================================
-- ScrollList
-- =====================================================================
BSCAS.scrollLists = BSCAS.scrollLists or {}
BSCAS.scrollData  = BSCAS.scrollData or {}

-- ===== ScrollList: Setup der Row ==================================
local function SetupRow(control, data)
    local RH = BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT
    control:SetHeight(RH)

    local bg   = control:GetNamedChild("Backdrop")
    local role = control:GetNamedChild("Role")
    local name = control:GetNamedChild("Name")
    local fill = control:GetNamedChild("Fill")
    local cd   = control:GetNamedChild("Cooldown")

    -- Alternierende Zeilen + Rahmen subtil
    local shade = data.alt and 0.22 or 0.14
    bg:SetCenterColor(0, 0, 0, shade)
    bg:SetEdgeColor(1, 1, 1, 0.35)

    role:SetTexture(data.roleTexture or "/esoui/art/lfg/lfg_icon_dps.dds")
    name:SetText(data.displayName or "?")

    -- Bar
    local maxDur = (data.durationMax or 0)
    local remain = (data.remaining  or 0)
    if maxDur < 0.001 then maxDur = 1 end
    if remain < 0 then remain = 0 end

    fill:SetMinMax(0, maxDur)
    fill:SetValue(remain)

    -- Farbverlauf (grün -> gelb -> rot) je nach Prozent
    local p = remain / maxDur
    local r, g = 1, 0
    if p > 0.5 then
        r = (1 - p) * 2
        g = 1
    else
        r = 1
        g = p * 2
    end
    fill:SetGradientColors(r, g, 0, 0.6, r, g, 0, 0.6)

    -- Cooldown rechts
    cd:SetText(remain > 0 and string.format("%.1f", remain) or "0.0")
end

-- ===== Daten für eine Liste aufbauen ==============================
local function BuildRowDataForList(listId)
    local data = {}
    local groupSize = GetGroupSize()
    local idx = 0

    if groupSize > 1 then
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and unitTag ~= GetLocalPlayerGroupUnitTag() and IsUnitPlayer(unitTag) and IsUnitOnline(unitTag) then
                local role = GetGroupMemberSelectedRole(unitTag)
                if RoleAllowed(role) then
                    local cdRec = GROUP_INFO[unitTag] and GROUP_INFO[unitTag].cdList[listId]
                    local remain, maxDur = 0, 0
                    if cdRec then
                        remain = (cdRec.cd - (GetGameTimeMilliseconds() / 1000))
                        maxDur = (cdRec.cd - cdRec.start)
                        if remain < 0 then remain = 0 end
                        if maxDur < 0.001 then maxDur = 0 end
                    end

                    if (not BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE) or (remain > 0) then
                        idx = idx + 1
                        local tex = "/esoui/art/lfg/lfg_icon_dps.dds"
                        if role == LFG_ROLE_TANK then
                            tex = "/esoui/art/lfg/lfg_icon_tank.dds"
                        elseif role == LFG_ROLE_HEAL then
                            tex = "/esoui/art/lfg/lfg_icon_healer.dds"
                        end

                        data[#data+1] = {
                            displayName = GetUnitDisplayName(unitTag),
                            roleTexture = tex,
                            remaining   = remain,
                            durationMax = (maxDur > 0) and maxDur or 1,
                            alt         = (idx % 2 == 0),
                        }
                    end
                end
            end
        end
    end

    return data
end

-- Dynamische Höhe der GroupTracking-Liste (min(rows*RH, MAX_HEIGHT))
local function UpdateGTListDynamicHeight(listId)
    local pack = BSCAS.frames[listId]
    if not pack or not pack.list then return end

    local list   = pack.list
    local RH     = BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT or 24
    local MAX_H  = BSCAS.SV.GROUP_TRACKING_MAX_HEIGHT or 260
    local data   = ZO_ScrollList_GetDataList(list) or {}
    local rows   = #data

    local desired = math.min(MAX_H, math.max(0, rows * RH))
    list:SetHeight(desired)
end

-- ===== Liste neu füllen (pro Synergie-Liste) ======================
local function RebuildList(listCtrl, listId)
    local scrollData = ZO_ScrollList_GetDataList(listCtrl)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local rows = BuildRowDataForList(listId)
    for _, row in ipairs(rows) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, row))
    end
    ZO_ScrollList_Commit(listCtrl)

    -- dynamische Höhe anwenden
    UpdateGTListDynamicHeight(listId)
end

-- ===== Periodisches Update (CD runterzählen) ======================
local function GTrackUpdateCooldown_Scroll()
    for listId, pack in pairs(BSCAS.frames) do
        if pack.list and not pack.frame:IsHidden() then
            RebuildList(pack.list, listId)
        end
    end
end

local function BuildMasterListFor(listId)
    local data, now = {}, GetGameTimeMilliseconds()/1000
    local onlyActive = BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE

    for gri = 1, GetGroupSize() do
        local ut = GetGroupUnitTagByIndex(gri)
        if ut and ut ~= GetLocalPlayerGroupUnitTag() and IsUnitPlayer(ut) and IsUnitOnline(ut) then
            local role = GetGroupMemberSelectedRole(ut)
            if RoleAllowed(role) then
                local gi = GROUP_INFO[ut]
                if gi then
                    local cd = gi.cdList[listId]
                    local dur = (cd and cd.duration) or 0
                    local endt = (cd and cd.endsAt) or 0
                    local remain = math.max(0, endt - now)
                    if (not onlyActive) or (dur > 0 and remain > 0) then
                        table.insert(data, {
                            unitTag     = ut,
                            displayName = GetUnitDisplayName(ut),
                            role        = (role ~= LFG_ROLE_INVALID) and role or LFG_ROLE_DPS,
                            inRange     = IsUnitInGroupSupportRange(ut),
                            duration    = dur,
                            endsAt      = endt,
                            remain      = remain,
                            sortKeyRole = RoleOrder(role),
                        })
                    end
                end
            end
        end
    end

    table.sort(data, function(a, b)
        if a.sortKeyRole ~= b.sortKeyRole then return a.sortKeyRole < b.sortKeyRole end
        return a.remain < b.remain
    end)

    BSCAS.scrollData[listId] = data
end

local function CommitScroll(listId)
    local list = BSCAS.scrollLists[listId]
    if not list then return end
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)
    for _, item in ipairs(BSCAS.scrollData[listId]) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, item))
    end
    ZO_ScrollList_Commit(list)
end

-- =====================================================================
-- Periodisches Update (unused path kept)
-- =====================================================================
local function GTrackUpdateCooldown()
    local now = GetGameTimeMilliseconds()/1000
    for listId, spec in pairs(TSG_LIST) do
        if spec.enable and BSCAS.frames[listId] and not BSCAS.frames[listId].frame:IsHidden() then
            local needRebuild, changedAny = false, false

            for _, item in ipairs(BSCAS.scrollData[listId] or {}) do
                local gi = GROUP_INFO[item.unitTag]
                if gi then
                    local cd = gi.cdList[listId]
                    item.duration = (cd and cd.duration) or 0
                    item.endsAt   = (cd and cd.endsAt) or 0
                    item.remain   = math.max(0, item.endsAt - now)

                    if BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE then
                        if (item.remain == 0 and item._wasActive) or (item.remain > 0 and not item._wasActive) then
                            needRebuild = true
                        end
                        item._wasActive = (item.remain > 0)
                    end

                    local tenths = math.floor(item.remain * 10 + 0.5)
                    if tenths ~= item._lastTenths then
                        item._lastTenths = tenths
                        changedAny = true
                    end
                end
            end

            if needRebuild then
                BuildMasterListFor(listId)
                CommitScroll(listId)
            elseif changedAny then
                ZO_ScrollList_RefreshVisible(BSCAS.scrollLists[listId])
            end
        end
    end
end

-- =====================================================================
-- Sichtbarkeit / Enable
-- =====================================================================
function BSCAS:GTrackUpdateSetting()
    UpdateEnabled()
    local groupS = GetGroupSize()
    local zoneId = GetUnitWorldPosition("player")

    -- SV-Defaults absichern
    BSCAS.SV.GROUP_TRACKING_MAX_WIDTH  = BSCAS.SV.GROUP_TRACKING_MAX_WIDTH  or 260
    BSCAS.SV.GROUP_TRACKING_MAX_HEIGHT = BSCAS.SV.GROUP_TRACKING_MAX_HEIGHT or 260
    BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT = BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT or 24
    if BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE == nil then
        BSCAS.SV.GROUP_TRACKING_ONLY_ACTIVE = false
    end

    local W  = BSCAS.SV.GROUP_TRACKING_MAX_WIDTH
    local RH = BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT

    for listId, cfg in pairs(TSG_LIST) do
        local frame = BSCAS.frames[listId].frame
        local list  = BSCAS.frames[listId].list

        -- Nur Breite setzen (Höhe wird dynamisch berechnet)
        list:SetWidth(W)

        -- Rowhöhe am DataType aktualisieren (kein erneutes AddDataType nötig!)
        local dt = ZO_ScrollList_GetDataTypeTable(list, 1)
        if dt then dt.height = RH end

        local enabled = cfg.enable
        if cfg.zoneid ~= -1 and cfg.zoneid ~= zoneId then
            enabled = false
        end

        if enabled and groupS > 1 and BSCAS.SV.GROUP_TRACKING_ENABLED then
            frame:SetHidden(false)
            RebuildList(list, listId)  -- Commit + dynamische Höhe
            SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.fragments[listId])
            SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.fragments[listId])
        else
            frame:SetHidden(true)
            SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.fragments[listId])
            SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.fragments[listId])
        end
    end
end

function BSCAS:GTrackSetHidden(enable)
    for listId, _ in pairs(TSG_LIST) do
        local frame = BSCAS.frames[listId].frame
        local list  = BSCAS.frames[listId].list

        if not enable then
            frame:SetHidden(false)
            RebuildList(list, listId) -- setzt dynamische Höhe
        else
            frame:SetHidden(true)
        end
    end
end

-- =====================================================================
-- Move/Position
-- =====================================================================
function BSCAS.OnMoveStopGT(listId, frame)
    BSCAS.SV.GROUP_TRACKING_UI_POSITION = BSCAS.SV.GROUP_TRACKING_UI_POSITION or {}
    BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId] = BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId] or {}
    BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId].left = frame:GetLeft()
    BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId].top  = frame:GetTop()
end

-- =====================================================================
-- UI erstellen
-- =====================================================================
local function CreateUI()
    local WM = GetWindowManager()
    BSCAS.frames    = {}
    BSCAS.fragments = {}

    for listId in pairs(TSG_LIST) do
        local frame = WM:CreateControlFromVirtual("BSCASynergyGTUIF" .. listId, nil, "BSCASynergyGTUIF")
        frame:SetHandler("OnMoveStop", function() BSCASynergy.OnMoveStopGT(listId, frame) end)

        -- Icon setzen (aus dem Template)
        local icon = frame:GetNamedChild("Icon")
        icon:SetTexture(TSG_LIST[listId].icon)

        -- ScrollList direkt unter dem Icon
        local list = WM:CreateControlFromVirtual("BSCASynergyGTList" .. listId, frame, "ZO_ScrollList")
        list:ClearAnchors()
        list:SetAnchor(TOP, icon, BOTTOM, 0, 4)
        -- Start: Breite setzen, Höhe 0 -> erste RebuildList setzt dynamisch
        list:SetDimensions(BSCAS.SV.GROUP_TRACKING_MAX_WIDTH or 260, 0)

        ZO_ScrollList_AddDataType(list, 1, "BSCASynergyGT_Row", BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT or 24, SetupRow)
        ZO_ScrollList_EnableHighlight(list, "ZO_ThinListHighlight")

        -- Startposition des Frames
        frame:ClearAnchors()
        local pos = BSCAS.SV.GROUP_TRACKING_UI_POSITION and BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId]
        if pos then
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
        else
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200 + (listId-1)*20, 200 + (listId-1)*20)
        end

        BSCAS.frames[listId]    = { frame = frame, list = list }
        BSCAS.fragments[listId] = ZO_SimpleSceneFragment:New(frame)
    end
end

-- =====================================================================
-- Group / Events
-- =====================================================================
local bUpdateGroupAfterCombat = false

local function GroupUpdate()
    if IsUnitInCombat("player") then
        bUpdateGroupAfterCombat = true
        return
    end
    BSCAS:GTrackUpdateSetting()
    bUpdateGroupAfterCombat = false
end

local function GroupRoleChange(unitTag, assignedRole)
    BSCAS:GTrackUpdateSetting()
end

function BSCAS:CallUpdateAfterCombatTG()
    if bUpdateGroupAfterCombat then GroupUpdate() end
end

local function GroupRangeUpdate(unitTag, status)
    if not IsUnitPlayer(unitTag) then return end
    for listId, spec in pairs(TSG_LIST) do
        if spec.enable and BSCAS.scrollData[listId] then
            local changed = false
            for _, item in ipairs(BSCAS.scrollData[listId]) do
                if item.unitTag == unitTag then
                    item.inRange = IsUnitInGroupSupportRange(unitTag)
                    changed = true
                end
            end
            if changed and BSCAS.scrollLists[listId] then
                ZO_ScrollList_RefreshVisible(BSCAS.scrollLists[listId])
            end
        end
    end
end

local function OnEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
    if not IsUnitPlayer(unitTag) then return end
    if GROUP_INFO[unitTag] ~= nil then
        GROUP_INFO[unitTag].unitId = unitId
        GROUP_UNITID[unitId] = unitTag
    end
end

local function GroupInit()
    GROUP_UNITID = {}
    GROUP_INFO = {}
    for i = 1, BSC_GROUP_SIZE_MAX do
        local unitTag = "group"..i
        GROUP_INFO[unitTag] = { unitId = -1, cdList = {} }
        for listId in pairs(TSG_LIST) do
            GROUP_INFO[unitTag].cdList[listId] = { cd=0, start=0, duration=0, endsAt=0 }
        end
    end
end

-- ===== Enable/Disable inkl. Timer für Updates =====================
function BSCAS.GroupTrackEnable()
    if BSCAS.SV.GROUP_TRACKING_ENABLED then
        -- Combat Events registrieren
        for abilityId in pairs(SYNERGYLIST) do
            local eventName = 'BSCAS_GRTROEC'..abilityId
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            if SYNERGYLIST[abilityId].bFilterSource then
                EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
            else
                EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
            end
        end

        EVENT_MANAGER:RegisterForUpdate('BSCAS_GroupTrackUpdate', BSCAS.UPDATE_INTERVAL, GTrackUpdateCooldown_Scroll)

        local tag = 'BSCAS_GRTROEC'
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_MEMBER_JOINED,  function() zo_callLater(function() BSCAS:GTrackUpdateSetting() end, 1500) end)
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_MEMBER_LEFT,    function() zo_callLater(function() BSCAS:GTrackUpdateSetting() end, 1500) end)
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_MEMBER_ROLE_CHANGED, function(_, unitTag) BSCAS:GTrackUpdateSetting() end)
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_SUPPORT_RANGE_UPDATE, function(_, unitTag) BSCAS:GTrackUpdateSetting() end)
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_EFFECT_CHANGED, OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(tag, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:RegisterForEvent(tag, EVENT_PLAYER_ACTIVATED, function() GroupInit(); zo_callLater(function() BSCAS:GTrackUpdateSetting() end, 1500) end)		
    else
        for abilityId in pairs(SYNERGYLIST) do
            EVENT_MANAGER:UnregisterForEvent('BSCAS_GRTROEC'..abilityId, EVENT_COMBAT_EVENT)
        end
        EVENT_MANAGER:UnregisterForUpdate('BSCAS_GroupTrackUpdate')

        local tag = 'BSCAS_GRTROEC'
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_MEMBER_JOINED)
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_MEMBER_LEFT)
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_MEMBER_ROLE_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(tag, EVENT_PLAYER_ACTIVATED)
    end
end

-- =========================
-- Group Tracking: Restore & Refresh
-- =========================

-- Setzt alle Frames auf die gespeicherten Positionen (Fallback: versetztes Raster)
function BSCAS:GTrackRestorePosition()
    if not BSCAS.frames then return end
    BSCAS.SV.GROUP_TRACKING_UI_POSITION = BSCAS.SV.GROUP_TRACKING_UI_POSITION or {}

    for listId, pack in pairs(BSCAS.frames) do
        local frame = pack and pack.frame
        if frame then
            frame:ClearAnchors()
            local pos = BSCAS.SV.GROUP_TRACKING_UI_POSITION[listId]
            local L = (pos and pos.left) or (200 + (listId - 1) * 20)
            local T = (pos and pos.top)  or (200 + (listId - 1) * 20)
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L, T)
        end
    end
end

-- Trägt Breite & Row-Höhe in die ScrollLists ein und commitet neu (inkl. dynamischer Höhe)
function BSCAS:GTrackRefreshLayout()
    if not BSCAS.frames then return end

    local W  = BSCAS.SV.GROUP_TRACKING_MAX_WIDTH  or 260
    local RH = BSCAS.SV.GROUP_TRACKING_ROW_HEIGHT or 24

    for listId, pack in pairs(BSCAS.frames) do
        local frame = pack and pack.frame
        local list  = pack and pack.list
        if frame and list then
            -- Breite setzen
            list:SetWidth(W)

            -- Rowhöhe am Datentyp aktualisieren
            local dt = ZO_ScrollList_GetDataTypeTable(list, 1)
            if dt then dt.height = RH end

            -- Neu befüllen (setzt dabei auch die dynamische Höhe)
            RebuildList(list, listId)
        end
    end
end

-- Optionaler Komfort-Wrapper, falls du alles in einem Rutsch anwenden willst
function BSCAS:GroupTrackApplyUI()
    -- Events/Timer gemäß aktuellem Toggle registrieren/abmelden
    BSCAS.GroupTrackEnable()

    -- Positionen setzen, Layout anwenden, Sichtbarkeit/Filter neu evaluieren
    BSCAS:GTrackRestorePosition()
    BSCAS:GTrackRefreshLayout()
    BSCAS:GTrackUpdateSetting()
end

-- =====================================================================
-- Init
-- =====================================================================
function BSCAS.GroupTrackInit()
    UpdateEnabled()
    GroupInit()
    CreateUI()
    BSCAS.GroupTrackEnable()
end
