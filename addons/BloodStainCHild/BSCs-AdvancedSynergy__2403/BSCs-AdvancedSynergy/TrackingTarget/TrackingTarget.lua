BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local BSC_GROUP_SIZE_MAX = 12
local SYNGERY_COUNT = 13

local SYNERGYLIST = {}
local GROUP_INFO  = {}
local GROUP_UNITID = {}

-- ========= Debugtoggle =========
local debug_mode = false
function BSCAS.TrackTargetDebugMode()
	debug_mode = not debug_mode
	BSCAS:PrintDebug("Debug Mode (TTracking) " .. (debug_mode and "Enabled!" or "Disabled!"))
end

-- ========= Helpers =========
local function CanonName(n) return zo_strlower(zo_strformat("<<1>>", n or "")) end
local function BSCGetUnitName(unitTag)
	if BSCAS.SV.TARGET_TRACKING_USEACCNAME then
		return tostring(zo_strformat("<<1>>", GetUnitDisplayName(unitTag))) -- Account
	else
		return tostring(zo_strformat("<<1>>", GetUnitName(unitTag)))        -- Character
	end
end

-- ========= Synergy-Konfiguration =========
local function CreateSynergylist()
	SYNERGYLIST = {
		[ABILITYID_CD_BLOOD_FUNNEL]       = { id = 1,  cd = GetAbilityDuration(ABILITYID_CD_BLOOD_FUNNEL)        },
		[ABILITYID_CD_FEAST_FUNNEL]       = { id = 1,  cd = GetAbilityDuration(ABILITYID_CD_FEAST_FUNNEL)        },
		[ABILITYID_CD_SPAWNBROODLING]     = { id = 2,  cd = GetAbilityDuration(ABILITYID_CD_SPAWNBROODLING)      },
		[ABILITYID_CD_BLACK_WIDOW]        = { id = 2,  cd = GetAbilityDuration(ABILITYID_CD_BLACK_WIDOW)         },
		[ABILITYID_CD_ARACHNOPHOBIA]      = { id = 2,  cd = GetAbilityDuration(ABILITYID_CD_ARACHNOPHOBIA)       },
		[ABILITYID_CD_BONE_WALL]          = { id = 3,  cd = GetAbilityDuration(ABILITYID_CD_BONE_WALL)           },
		[ABILITYID_CD_SPINALSURGE]        = { id = 3,  cd = GetAbilityDuration(ABILITYID_CD_SPINALSURGE)         },
		[ABILITYID_CD_SHARTBUBLE_1]       = { id = 4,  cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_1)        },
		[ABILITYID_CD_SHARTBUBLE_2]       = { id = 4,  cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_2)        },
		[ABILITYID_CD_SHARTBUBLE_3]       = { id = 4,  cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_3)        },
		[ABILITYID_CD_HEALING_COMBUSTION] = { id = 4,  cd = GetAbilityDuration(ABILITYID_CD_HEALING_COMBUSTION)  },
		[ABILITYID_CD_PURIFY]             = { id = 5,  cd = GetAbilityDuration(ABILITYID_CD_PURIFY)              },
		[ABILITYID_CD_CONDUIT]            = { id = 6,  cd = GetAbilityDuration(ABILITYID_CD_CONDUIT)             },
		[ABILITYID_CD_CHARGED_LIGHTNING]  = { id = 7,  cd = GetAbilityDuration(ABILITYID_CD_CHARGED_LIGHTNING)   },
		[ABILITYID_CD_SHACKLE]            = { id = 8,  cd = GetAbilityDuration(ABILITYID_CD_SHACKLE)             },
		[ABILITYID_CD_IGNITE]             = { id = 8,  cd = GetAbilityDuration(ABILITYID_CD_IGNITE)              },
		[ABILITYID_CD_HARVEST]            = { id = 9,  cd = GetAbilityDuration(ABILITYID_CD_HARVEST)             },
		[ABILITYID_CD_GRAVEROBBER]        = { id = 10, cd = GetAbilityDuration(ABILITYID_CD_GRAVEROBBER)         },
		[ABILITYID_CD_PURE_AGONY]         = { id = 11, cd = GetAbilityDuration(ABILITYID_CD_PURE_AGONY)          },
		[ABILITYID_CD_RUNE]               = { id = 12, cd = GetAbilityDuration(ABILITYID_CD_RUNE)                },
		[ABILITYID_CD_INNERFIRE]          = { id = 13, cd = GetAbilityDuration(ABILITYID_CD_INNERFIRE)           },
	}
end

local function GetInfoForUpdateSettings(playername)
	local SELECTED_NAME = BSCAS.SV.TARGET_TRACKING_UI_PLAYER[playername]
	local INF = {
		[1]  = { enable = SELECTED_NAME.BLOODALTAR,  icon = ICON_UNDAUNTED_ALTAR_0,  name = GetString(SI_SYNERGY_NAME_BLOODALTAR) },
		[2]  = { enable = SELECTED_NAME.SPIDERS,     icon = ICON_UNDAUNTED_WEBS_0,   name = GetString(SI_SYNERGY_NAME_WEBS)       },
		[3]  = { enable = SELECTED_NAME.BONESHIELD,  icon = ICON_UNDAUNTED_BONE_0,   name = GetString(SI_SYNERGY_NAME_BONE)       },
		[4]  = { enable = SELECTED_NAME.SHARTSORBS,  icon = ICON_UNDAUNTED_ORB_2,    name = GetString(SI_SYNERGY_NAME_ORB)        },
		[5]  = { enable = SELECTED_NAME.PURIFY,      icon = ICON_TEMPLAR_RITUAL_0,   name = GetString(SI_SYNERGY_NAME_PURGE)      },
		[6]  = { enable = SELECTED_NAME.CONDUIT,     icon = ICON_SORC_CONDUIT_0,     name = GetString(SI_SYNERGY_NAME_CONDUIT)    },
		[7]  = { enable = SELECTED_NAME.ATRONACH,    icon = ICON_SORC_ATRO_0,        name = GetString(SI_SYNERGY_NAME_ATRO)       },
		[8]  = { enable = SELECTED_NAME.SHACKLE,     icon = ICON_DK_CLAW_0,          name = GetString(SI_SYNERGY_NAME_IMPALE)     },
		[9]  = { enable = SELECTED_NAME.HARVEST,     icon = ICON_WARDEN_HARVEST_0,   name = GetString(SI_SYNERGY_NAME_HARVEST)    },
		[10] = { enable = SELECTED_NAME.GRAVEROBBER, icon = ICON_NECRO_GRAVE_0,      name = GetString(SI_SYNERGY_NAME_BONEYARD)   },
		[11] = { enable = SELECTED_NAME.PUREAGONY,   icon = ICON_NECRO_TOTEM_0,      name = GetString(SI_SYNERGY_NAME_TOTEM)      },
		[12] = { enable = SELECTED_NAME.RUNE,        icon = ICON_ARCANIST_RUNE,      name = GetString(SI_SYNERGY_NAME_RUNE)       },
		[13] = { enable = SELECTED_NAME.INNERFIRE,   icon = ICON_UNDAUNTED_FIRE_0,   name = GetString(SI_SYNERGY_NAME_INNERFIRE)  },
	}
	return INF
end

-- ========= Combat Events =========
local function OnCombatEvent(_, result, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
	if result ~= ACTION_RESULT_EFFECT_GAINED then return end
	local cfg = SYNERGYLIST[abilityId]
	if not cfg then return end

	-- wir tracken TARGET (Quelle: REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE)
	local unitTag = GROUP_UNITID[targetUnitId]
	if not unitTag then
		-- Fallback per Name
		local needle = CanonName(targetName)
		for i=1, GetGroupSize() do
			local ut = GetGroupUnitTagByIndex(i)
			if ut and IsUnitPlayer(ut) then
				if CanonName(GetUnitName(ut)) == needle or CanonName(GetUnitDisplayName(ut)) == needle then
					unitTag = ut
					break
				end
			end
		end
	end
	if not unitTag then return end

	local gi = GROUP_INFO[unitTag]
	if not gi then return end

	local now = GetGameTimeMilliseconds()/1000
	local dur = (cfg.cd or 0)/1000
	local rec = gi.cdList[cfg.id]
	rec.start    = now
	rec.cd       = now + dur
	rec.duration = dur
	rec.endsAt   = now + dur
end

-- ========= ScrollList: Daten/Setup =========
BSCAS.TTframes     = BSCAS.TTframes or {}
BSCAS.TTfragments  = BSCAS.TTfragments or {}
BSCAS.ttScroll     = BSCAS.ttScroll or {}      -- [GRI] -> list control
BSCAS.ttData       = BSCAS.ttData or {}        -- [GRI] -> array of rows

local function SetupRowTT(control, data)
	-- Höhe erzwingen (Row-Height live aus SV)
	local RH = BSCAS.SV.TARGET_TRACKING_ROW_HEIGHT or 34
	control:SetHeight(RH)

	local bg   = control:GetNamedChild("Backdrop")
	local icon = control:GetNamedChild("Icon")
	local name = control:GetNamedChild("Name")
	local fill = control:GetNamedChild("Fill")
	local cd   = control:GetNamedChild("Cooldown")

	-- Look
	local shade = data.alt and 0.22 or 0.14
	bg:SetCenterColor(0, 0, 0, shade)
	bg:SetEdgeColor(1, 1, 1, 0.35)

	icon:SetTexture(data.icon or "/esoui/art/icons/icon_missing.dds")
	name:SetText(data.displayName or "?")

	-- Progress (wir nutzen Min=0, Max=duration, Value=remain)
	local maxDur = (data.duration or 0)
	local remain = (data.remain or 0)
	if maxDur < 0.001 then maxDur = 1 end
	if remain < 0 then remain = 0 end

	fill:SetMinMax(0, maxDur)
	fill:SetValue(remain)

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

	cd:SetText(remain > 0 and string.format("%.1f", remain) or "0.0")

	-- Reichweiten-Fade
	control:SetAlpha(data.inRange and 1 or 0.6)
end

local function BuildRowsForTarget(GRI, TTName)
	local rows = {}
	local info = GetInfoForUpdateSettings(TTName)
	local ut   = "group"..GRI
	local gi   = GROUP_INFO[ut]

	local onlyActive = BSCAS.SV.TARGET_TRACKING_ONLY_ACTIVE
	local idx = 0
	for sid = 1, SYNGERY_COUNT do
		if info[sid] and info[sid].enable then
			local rec = gi and gi.cdList[sid]
			local dur  = (rec and rec.duration) or 0
			local ends = (rec and rec.endsAt) or 0
			local now  = GetGameTimeMilliseconds()/1000
			local remain = math.max(0, ends - now)

			if (not onlyActive) or (dur > 0 and remain > 0) then
				idx = idx + 1
				rows[#rows+1] = {
					icon        = info[sid].icon,
					displayName = info[sid].name,
					duration    = (dur > 0) and dur or 1,
					remain      = remain,
					inRange     = IsUnitInGroupSupportRange(ut),
					alt         = (idx % 2 == 0),
					sid         = sid,
				}
			end
		end
	end
	return rows
end

local function UpdateTTListDynamicHeight(GRI, rowCount)
    local list = BSCAS.ttScroll[GRI]
    if not list then return end
    local RH   = BSCAS.SV.TARGET_TRACKING_ROW_HEIGHT
    local MAXH = BSCAS.SV.TARGET_TRACKING_MAX_HEIGHT

    local desired = math.min(MAXH, math.max(0, (rowCount or 0) * RH))
    list:SetHeight(desired)
end

local function CommitTTList(GRI, rows)
	local list = BSCAS.ttScroll[GRI]
	if not list then return end
	ZO_ScrollList_Clear(list)
	local dataList = ZO_ScrollList_GetDataList(list)
	for _, row in ipairs(rows) do
		table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, row))
	end
	ZO_ScrollList_Commit(list)
	
    UpdateTTListDynamicHeight(GRI, #rows)
end

local function ApplyTTMetrics(GRI)
	local list = BSCAS.ttScroll[GRI]
    if not list then return end

    local RH   = BSCAS.SV.TARGET_TRACKING_ROW_HEIGHT or 34
    local W    = BSCAS.SV.TARGET_TRACKING_MAX_WIDTH or 260

    -- 1) Breite setzen
    list:SetWidth(W)

    -- 2) Rowhöhe zentral am DataType anpassen
    --    (dadurch brauchen wir keine Schleife über die sichtbaren Controls)
    local dt = ZO_ScrollList_GetDataTypeTable(list, 1)
    if dt then
        dt.height = RH
    end

    -- 3) Headerbreite anpassen (falls du einen Header oben hast)
    local frame = BSCAS.TTframes[GRI].frame
    local bg    = frame:GetNamedChild("BG")
    local name  = frame:GetNamedChild("Name")
    if bg then bg:SetDimensions(W, 24) end
    if name then name:SetDimensions(W - 20, 24) end

    -- 4) Liste neu committen (re-layout mit neuer Höhe)
    ZO_ScrollList_Commit(list)
	
	UpdateTTListDynamicHeight(GRI, #(BSCAS.ttData[GRI] or {}))
end

-- ========= Periodisches Update =========
local function TTrackUpdateCooldown_Scroll()
	for GRI = 1, GetGroupSize() do
		local ut = "group"..GRI
		local TTName = BSCGetUnitName(ut)
		local pack = BSCAS.TTframes[GRI]
		if pack and not pack.frame:IsHidden() and TTName and BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName] then
			local newRows = BuildRowsForTarget(GRI, TTName)

			-- Wenn ONLY_ACTIVE aktiv ist, kann die Zeilenanzahl schwanken -> daher Liste komplett neu committen
			if BSCAS.SV.TARGET_TRACKING_ONLY_ACTIVE then
				BSCAS.ttData[GRI] = newRows
				CommitTTList(GRI, newRows)
			else
				-- sonst nur Werte refreshen
				BSCAS.ttData[GRI] = newRows
				CommitTTList(GRI, newRows)
			end
		end
	end
end

-- ========= Sichtbarkeit / Settings anwenden =========
function BSCAS:TTrackUpdateSetting() -- /script BSCASynergy:TTrackUpdateSetting()
	local groupSize = GetGroupSize()
	for GRI = 1, BSC_GROUP_SIZE_MAX do
		local frame = BSCAS.TTframes[GRI].frame
		frame:SetHidden(true)

		if BSCAS.SV.TARGET_TRACKING_ENABLED and groupSize >= GRI then
			local ut = "group"..GRI
			local TTName = BSCGetUnitName(ut)
			if TTName and TTName ~= "" then
				local cfg = BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName]
				if cfg and cfg.ENABLED then
					-- Titel
					frame:GetNamedChild("Name"):SetText(TTName)

					-- Position
					frame:ClearAnchors()
					frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cfg.UI_LEFT or 200, cfg.UI_TOP or 200)

					-- Maße/RowHeight anwenden
					ApplyTTMetrics(GRI)

					-- Daten füllen
					local rows = BuildRowsForTarget(GRI, TTName)
					BSCAS.ttData[GRI] = rows
					CommitTTList(GRI, rows)

					-- Sichtbar machen + Fragments
					frame:SetHidden(false)
					SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.TTfragments[GRI])
					SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.TTfragments[GRI])
				else
					SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.TTfragments[GRI])
					SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.TTfragments[GRI])
				end
			end
		end
	end
end

function BSCAS:TTrackSetHidden(enable)
	local groupSize = GetGroupSize()
	for GRI = 1, BSC_GROUP_SIZE_MAX do
		local frame = BSCAS.TTframes[GRI].frame
		frame:SetHidden(true)

		if BSCAS.SV.TARGET_TRACKING_ENABLED and groupSize >= GRI then
			local ut = "group"..GRI
			local TTName = BSCGetUnitName(ut)
			if TTName and TTName ~= "" then
				local cfg = BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName]
				if cfg and cfg.ENABLED then
					frame:SetHidden(enable)
				end
			end
		end
	end
end

function BSCAS.OnMoveStopTT(GRI, frame)
	local ut = "group"..GRI
	local TTName = BSCGetUnitName(ut)
	if not TTName or TTName == "" then return end
	BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName] = BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName] or {}
	BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName].UI_LEFT = frame:GetLeft()
	BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName].UI_TOP  = frame:GetTop()
end

-- ========= UI erstellen =========
local function CreateUI()
	local WM = GetWindowManager()
	BSCAS.TTframes    = {}
	BSCAS.TTfragments = {}
	BSCAS.ttScroll    = {}
	BSCAS.ttData      = {}

	for GRI = 1, BSC_GROUP_SIZE_MAX do
		local frame = WM:CreateControlFromVirtual("BSCASynergyTTUIF" .. GRI, nil, "BSCASynergyTTUIF")
		frame:SetHandler("OnMoveStop", function() BSCASynergy.OnMoveStopTT(GRI, frame) end)

		-- ScrollList direkt unter BG
		local list = WM:CreateControlFromVirtual("BSCASynergyTTList" .. GRI, frame, "ZO_ScrollList")
		list:ClearAnchors()
		list:SetAnchor(TOPLEFT, frame:GetNamedChild("BG"), BOTTOMLEFT, 0, 4)
		list:SetDimensions(BSCAS.SV.TARGET_TRACKING_MAX_WIDTH, BSCAS.SV.TARGET_TRACKING_MAX_HEIGHT)

		ZO_ScrollList_AddDataType(list, 1, "BSCASynergyTT_Row", BSCAS.SV.TARGET_TRACKING_ROW_HEIGHT, SetupRowTT)
		ZO_ScrollList_EnableHighlight(list, "ZO_ThinListHighlight")

		-- Startpos (wird später pro Spieler überschrieben)
		frame:ClearAnchors()
		frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200 + (GRI-1)*10, 200 + (GRI-1)*10)

		BSCAS.TTframes[GRI]    = { frame = frame }
		BSCAS.ttScroll[GRI]    = list
		BSCAS.ttData[GRI]      = {}
		BSCAS.TTfragments[GRI] = ZO_SimpleSceneFragment:New(frame)
	end
end

-- ========= Group / Events =========
function BSCAS:GetGroupListNames() -- /script d(BSCASynergy:GetGroupListNames())
	local List = {}
	for i = 1, BSC_GROUP_SIZE_MAX do
		local n = BSCGetUnitName("group"..i)
		if n and n ~= "" then table.insert(List, n) end
	end
	return List
end

local bUpdateGroupAfterCombat = false
local function GroupUpdate()
	if IsUnitInCombat("player") then
		bUpdateGroupAfterCombat = true
		return
	end
	BSCAS:TTrackUpdateSetting()
	bUpdateGroupAfterCombat = false
	if BSCAS_TTrackingDropdownG then
		BSCAS_TTrackingDropdownG:UpdateChoices(BSCAS:GetGroupListNames())
	end
end
function BSCAS:CallUpdateAfterCombatTT()
	if bUpdateGroupAfterCombat then GroupUpdate() end
end

local function GroupRangeUpdate(unitTag, status)
	if not IsUnitPlayer(unitTag) then return end
	-- wir zeichnen Reichweite in SetupRowTT (data.inRange). Beim nächsten Refresh sichtbar.
	zo_callLater(function() BSCAS:TTrackUpdateSetting() end, 100)
end

local function OnEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
	if not IsUnitPlayer(unitTag) then return end
	if GROUP_INFO[unitTag] then
		GROUP_INFO[unitTag].unitId = unitId
		GROUP_UNITID[unitId] = unitTag
	end
end

local function GroupInit()
	GROUP_UNITID = {}
	GROUP_INFO = {}
	for i = 1, BSC_GROUP_SIZE_MAX do
		local ut = "group"..i
		GROUP_INFO[ut] = { unitId = -1, cdList = {} }
		for sid = 1, SYNGERY_COUNT do
			GROUP_INFO[ut].cdList[sid] = { cd = 0, start = 0, duration = 0, endsAt = 0 }
		end
	end
end

-- ========= Enable/Disable + Timer =========
function BSCAS.TargetTrackEnable()
	if BSCAS.SV.TARGET_TRACKING_ENABLED then
		-- Combat Events
		for abilityId in pairs(SYNERGYLIST) do
			local tag = 'BSCAS_TRTROEC'..abilityId
			EVENT_MANAGER:RegisterForEvent(tag, EVENT_COMBAT_EVENT, OnCombatEvent)
			EVENT_MANAGER:AddFilterForEvent(tag, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
			EVENT_MANAGER:AddFilterForEvent(tag, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
		end
		EVENT_MANAGER:RegisterForUpdate('BSCAS_TargetTrackUpdate', BSCAS.UPDATE_INTERVAL, TTrackUpdateCooldown_Scroll)

		local tag = 'BSCAS_TRTROEC'
		EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_MEMBER_JOINED,        function() zo_callLater(function() GroupUpdate() end, 1500) end)
		EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_MEMBER_LEFT,          function() zo_callLater(function() GroupUpdate() end, 1500) end)
		EVENT_MANAGER:RegisterForEvent(tag, EVENT_GROUP_SUPPORT_RANGE_UPDATE, function(_, unitTag) GroupRangeUpdate(unitTag) end)
		EVENT_MANAGER:RegisterForEvent(tag, EVENT_EFFECT_CHANGED, OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent(tag, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		EVENT_MANAGER:RegisterForEvent(tag, EVENT_PLAYER_ACTIVATED,           function() zo_callLater(function() GroupUpdate() end, 1500) end)

	else
		for abilityId in pairs(SYNERGYLIST) do
			EVENT_MANAGER:UnregisterForEvent('BSCAS_TRTROEC'..abilityId, EVENT_COMBAT_EVENT)
		end
		EVENT_MANAGER:UnregisterForUpdate('BSCAS_TargetTrackUpdate')

		local tag = 'BSCAS_TRTROEC'
		EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_MEMBER_LEFT)
		EVENT_MANAGER:UnregisterForEvent(tag, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(tag, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(tag, EVENT_PLAYER_ACTIVATED)
	end
end

-- ========= Layout/Position & Apply aus SavedData =========

-- 1) Breiten/Rowhöhen neu anwenden und Listen neu committen
function BSCAS.TargetTrackRefreshLayout()
    for GRI = 1, BSC_GROUP_SIZE_MAX do
        if BSCAS.ttScroll[GRI] then
            -- Maße (Breite, Rowhöhe, Header) neu setzen
            ApplyTTMetrics(GRI)

            -- Falls wir schon einen gültigen Spieler für dieses GRI haben: Rows neu aufbauen
            local ut     = "group"..GRI
            local TTName = BSCGetUnitName(ut)
            if TTName and BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName] then
                local rows = BuildRowsForTarget(GRI, TTName)
                BSCAS.ttData[GRI] = rows
                CommitTTList(GRI, rows)
            end
        end
    end
end

-- 2) Frames gemäß (account-/char-) Settings positionieren
function BSCAS.TargetTrackRestorePosition()
    for GRI = 1, BSC_GROUP_SIZE_MAX do
        local pack  = BSCAS.TTframes[GRI]
        local frame = pack and pack.frame
        if frame then
            local ut     = "group"..GRI
            local TTName = BSCGetUnitName(ut)
            if TTName and TTName ~= "" then
                local cfg = BSCAS.SV.TARGET_TRACKING_UI_PLAYER[TTName]
                if cfg then
                    frame:ClearAnchors()
                    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cfg.UI_LEFT or 200, cfg.UI_TOP or 200)
                end
            end
        end
    end
end

-- 3) Ein-Knopf-Apply: Events (de)aktivieren, Position & Layout anwenden, Sichtbarkeit refreshen
function BSCAS.TargetTrackApplyUI()
    -- (Re)enable/disable Combat-Listener & Timer je nach Setting
    BSCAS.TargetTrackEnable()

    -- Position und Maße anwenden
    BSCAS.TargetTrackRestorePosition()
    BSCAS.TargetTrackRefreshLayout()

    -- Sichtbarkeit & Daten je Spieler/Gruppen-Slot aktualisieren
    BSCAS:TTrackUpdateSetting()
end

-- ========= Init =========
function BSCAS.TargetTrackInit()
	CreateSynergylist()
	GroupInit()
	CreateUI()
	BSCAS.TargetTrackEnable()
end
