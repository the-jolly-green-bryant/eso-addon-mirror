local GroupBuffTracker = {}
GroupBuffTracker.name = "GroupBuffTracker"
GroupBuffTracker.buffDataByUnit = {}
GroupBuffTracker.sceneFragment = nil
GroupBuffTracker.rootControl = nil

-- Liste des buffs à suivre par défaut
GroupBuffTracker.defaultTrackedBuffs = {
    [61694] = true,
    [61693] = true,
    [61506] = true,
    [147417] = true,
	[61745] = true,
	[151032] = true,
	[172055] = true,
	[163401] = true,
	[109966] = true,
	[93109] = true,
	[61665] = true,
	[217460] = true,
	[217608] = true,
	[61747] = true,
	[61691] = true,
	[252050] = true,
	--[DEBUFF]--
	[162365] = true, --Rattled
	[186561] = true, -- Armor Shred
	[162360] = true, -- Devitalized
	[107082] = true, --BaneFul Mark
	--[BRP]--
	[114558] = true, -- Profanation extreme
	[113164] = true, -- Crachat venimeux
	--[PVP]--
	[61736] = true,
	[61735] = true,
	[61716] = true,
	[61715] = true,
}

GroupBuffTracker.buffsByCategory = {
    [GetString(STUFF)] = {
        { id = 61771, name = GetString(NAME_PA)},
        { id = 93109, name = GetString(NAME_SLAYER)},
		{ id = 109966, name = GetString(NAME_COURAGEM)},
		{ id = 163401, name = GetString(NAME_SPAULDER)},
		{ id = 172055, name = GetString(NAME_PILL)},
		{ id = 151032, name = GetString(NAME_ENCR)},
		{ id = 252050, name = GetString(NAME_MASK)},
    },
    [GetString(SPE)] = {
        { id = 61665, name = GetString(NAME_IW)},
		{ id = 61694, name = GetString(NAME_RM)},
		{ id = 61745, name = GetString(NAME_BM)},
		{ id = 147417, name = GetString(NAME_CM)},
		{ id = 61691, name = GetString(NAME_PM)},
    },
	[GetString(JOB)] = {
		{ id = 61506, name = GetString(NAME_ARDEUR)},
		{ id = 40079, name = GetString(NAME_REGEN)},
		{ id = 217460, name = GetString(NAME_EH)},
		{ id = 217608, name = GetString(NAME_SP)},
		{ id = 61693, name = GetString(NAME_PF)},
		{ id = 61747, name = GetString(NAME_FM)},
	},
	[GetString(BRP)] = {
		{ id = 114558 , name = GetString(NAME_BRP1)},
		{ id = 113164 , name = GetString(NAME_BRP2)},
	},
	[GetString(DEBUFF)] = {
		{ id = 162365 , name = GetString(NAME_WAMA1)},
		{ id = 186561 , name = GetString(NAME_YAS)},
		{ id = 162360 , name = GetString(NAME_WAMA2)},
		{ id = 107082 , name = GetString(NAME_CR)},
	},
	[GetString(PVP)] = {
		{id = 61716 , name = GetString(NAME_EMJ)},
		{id = 61715 , name = GetString(NAME_EM)},
		{id = 61736 , name = GetString(NAME_EXMJ)},
		{id = 61735 , name = GetString(NAME_EXM)},
	}
}

local buggedLongDuration = {
    [147417] = true,
}
    -- Buffs qui doivent toujours s'afficher même sans durée
 local alwaysShowBuffs = {
    [163401] = true,
}

local function CreateBuffIcon(unitFrame)
    local iconSize = GroupBuffTracker.savedVars.iconSize or 24

    -- CONTROL attaché au root (plus de TopLevelWindow indépendant)
    local container = WINDOW_MANAGER:CreateControl(nil, GroupBuffTracker.rootControl, CT_CONTROL)
    container:SetDimensions(iconSize, iconSize)
    container:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(nil, container, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(CENTER, container, CENTER, 0, 0)

    -- TIMER
    local label = WINDOW_MANAGER:CreateControl(nil, icon, CT_LABEL)
    label:SetAnchor(CENTER, icon, CENTER, 0, 0)
    label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",
        GroupBuffTracker.savedVars.timerFontSize or 16))

    local r, g, b, a = unpack(GroupBuffTracker.savedVars.timerFontColor or {1,1,1,1})
    label:SetColor(r, g, b, 1)

    icon.timerLabel = label
    icon.container = container
    icon.expirationTime = nil

    return icon
end

local function GetUnitFrame(unitTag)
    if ALT_GROUP_FRAMES and ALT_GROUP_FRAMES.GetFrame then
			local agfFrame = ALT_GROUP_FRAMES:GetFrame(unitTag)
			if agfFrame then
            return agfFrame:GetControl()
        end
    end
	
	if BUI and BUI.UI and BUI.Frames then
        return BUI.Frames[unitTag] and BUI.Frames[unitTag].control or BUI.Group[unitTag] and BUI.Group[unitTag].frame
    end
    if LUIE and LUIE.UnitFrames then
        local frames = LUIE.UnitFrames.CustomFrames or LUIE.UnitFrames
        if frames[unitTag] then
            return frames[unitTag].frame or frames[unitTag].control or frames[unitTag]
        end
    end
    local baseFrame = ZO_UnitFrames_GetUnitFrame(unitTag)
    return baseFrame and (baseFrame.control or baseFrame.frame or baseFrame)
end

local function ReanchorBuffIcons(unitFrame)
    local keys = {}
    for id in pairs(unitFrame.buffIconsById) do
        table.insert(keys, id)
    end
    table.sort(keys)

    local lastIcon = nil

    for _, id in ipairs(keys) do
        local icon = unitFrame.buffIconsById[id]
        if icon and not icon.container:IsHidden() then

            icon.container:ClearAnchors()

            if lastIcon then
                icon.container:SetAnchor(
                    LEFT,
                    lastIcon.container,
                    RIGHT,
                    GroupBuffTracker.savedVars.iconOffsetX or 5,
                    0
                )
            else
                icon.container:SetAnchor(
                    TOPLEFT,
                    unitFrame,
                    TOPLEFT,
                    GroupBuffTracker.savedVars.startPosX or 75,
                    GroupBuffTracker.savedVars.startPosY or 0
                )
            end

            lastIcon = icon
        end
    end
end

function GroupBuffTracker.OnEffectChanged(eventCode, changeType, effectSlot,
    effectName, unitTag, beginTime, endTime, stackCount,
    iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId)

    -- On ne traite QUE les membres du groupe
    if not string.match(unitTag, "^group%d") then return end
    if not GroupBuffTracker.savedVars.trackedBuffs[abilityId] then return end

    local unitFrame = GetUnitFrame(unitTag)
    if not unitFrame or unitFrame:IsHidden() then return end

    unitFrame.buffIconsById = unitFrame.buffIconsById or {}

    if changeType == EFFECT_RESULT_GAINED
       or changeType == EFFECT_RESULT_UPDATED then

        -- Ignore buffs sans durée sauf exceptions
        if (not endTime or endTime == 0 or endTime == beginTime)
            and not buggedLongDuration[abilityId]
            and not alwaysShowBuffs[abilityId] then
            return
        end

        local icon = unitFrame.buffIconsById[abilityId]
        if not icon then
            icon = CreateBuffIcon(unitFrame)
            unitFrame.buffIconsById[abilityId] = icon
        end

        icon.abilityId = abilityId

        -- Texture custom si besoin
        if abilityId == 252050 then
            icon:SetTexture("/esoui/art/icons/gear_hircinessnarlmask_head_a.dds")
        else
            icon:SetTexture(iconName)
        end

        -- Gestion expiration
        local now = GetGameTimeSeconds()

        if buggedLongDuration[abilityId] then
            icon.expirationTime = math.huge

        elseif alwaysShowBuffs[abilityId] then
            icon.expirationTime = math.huge

        else
            if endTime > 1000000 then
                endTime = endTime / 1000
            end
            icon.expirationTime = now + (endTime - beginTime)
        end

        icon.container:SetHidden(false)
        icon.timerLabel:SetHidden(false)

        ReanchorBuffIcons(unitFrame)

    elseif changeType == EFFECT_RESULT_FADED then

        local icon = unitFrame.buffIconsById[abilityId]
        if icon then
            icon.container:SetHidden(true)
            icon.timerLabel:SetHidden(true)
            unitFrame.buffIconsById[abilityId] = nil
            ReanchorBuffIcons(unitFrame)
        end
    end
end

function GroupBuffTracker.OnUpdate()
    local now = GetGameTimeSeconds()
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local unitFrame = GetUnitFrame(unitTag)
        if unitFrame and unitFrame.buffIconsById then
            for _, icon in pairs(unitFrame.buffIconsById) do
                -- Timer
                if not icon.container:IsHidden() and icon.expirationTime then
                    if icon.expirationTime == math.huge then
                        icon.timerLabel:SetText("∞")
                    else
                        local remaining = icon.expirationTime - now
                        if remaining <= 0 then
                            icon.container:SetHidden(true)
                            icon.timerLabel:SetHidden(true)
                            unitFrame.buffIconsById[icon.abilityId] = nil
							ReanchorBuffIcons(unitFrame)
                        else
                            icon.timerLabel:SetText(string.format("%.0f", remaining))
                        end
                    end
                end
            end
        end
    end
end

local function OnGroupSizeChanged()

    for i = 1, 12 do
        local unitTag = "group"..i
        local unitFrame = GetUnitFrame(unitTag)

        if unitFrame and unitFrame.buffIconsById then
            for _, icon in pairs(unitFrame.buffIconsById) do
                if icon.container then
                    icon.container:SetHidden(true)
                end
            end
            unitFrame.buffIconsById = {}
        end
    end

    zo_callLater(function()
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            local unitFrame = GetUnitFrame(unitTag)
            if unitFrame then
                unitFrame.buffIconsById = {}
            end
        end
    end, 100)
end

-- Création du menu des options
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("LibAddonMenu2 non trouvé, menu indisponible.")
        return
    end

    local panelData = {
        type = "panel",
        name = "GroupBuffTracker",
        displayName = "Group Buff Tracker",
        author = "|c530effT|r|c4a1dffe|r|c422bffn|r|c3a39ffs|r|c3248ffh|r|c2956ffi|r|c2165ffr|r|c1973ffa|r|c1181ffi|r|c0890fft|r|c009effo|r",
        version = "2.8",
        slashCommand = "/gbt",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("GroupBuffTrackerPanel", panelData)

		local optionsTable = {}

		for categoryName, buffs in pairs(GroupBuffTracker.buffsByCategory) do
			local submenuControls = {}

			for _, buffData in ipairs(buffs) do
				local buffId = buffData.id
				local icon 
					if buffId == 252050 then
						icon = "/esoui/art/icons/gear_hircinessnarlmask_head_a.dds"
					else
						icon = GetAbilityIcon(buffId) or "/esoui/art/icons/default.dds"
					end
				local buffNameWithIcon = ("|t24:24:%s|t %s"):format(icon, buffData.name or ("Buff " .. buffId))

				table.insert(submenuControls, {
					type = "checkbox",
					name = buffNameWithIcon,
					getFunc = function()
						return GroupBuffTracker.savedVars.trackedBuffs[buffId]
					end,
					setFunc = function(value)
						GroupBuffTracker.savedVars.trackedBuffs[buffId] = value
					end,
					width = "full",
				})
			end

			table.insert(optionsTable, {
				type = "submenu",
				name = categoryName,
				controls = submenuControls,
			})
		end
	
    table.insert(optionsTable, {
        type = "slider",
        name = GetString(GBT_SPACE), --"Décalage horizontal entre les icônes",
        min = 0,
        max = 50,
        step = 1,
        getFunc = function() return GroupBuffTracker.savedVars.iconOffsetX end,
        setFunc = function(value)
            GroupBuffTracker.savedVars.iconOffsetX = value
        end,
        width = "full",
    })

	table.insert(optionsTable, {
		type = "slider",
		name = GetString(GBT_DECALX), --"Position de départ X",
		min = 0,
		max = 450,
		step = 1,
		getFunc = function() return GroupBuffTracker.savedVars.startPosX end,
		setFunc = function(value)
			GroupBuffTracker.savedVars.startPosX = value
		end,
		width = "full",
	})

	table.insert(optionsTable, {
		type = "slider",
		name = GetString(GBT_DECALY), --"Position de départ Y",
		min = -100,
		max = 100,
		step = 1,
		getFunc = function() return GroupBuffTracker.savedVars.startPosY end,
		setFunc = function(value)
			GroupBuffTracker.savedVars.startPosY = value
		end,
		width = "full",
	})
		table.insert(optionsTable, {
		type = "slider",
		name = GetString(GBT_SIZEI), --"Taille des icônes",
		min = 16,
		max = 64,
		step = 1,
		getFunc = function() return GroupBuffTracker.savedVars.iconSize end,
		setFunc = function(value) GroupBuffTracker.savedVars.iconSize = value end,
		width = "full",
	})

	table.insert(optionsTable, {
		type = "slider",
		name = GetString(GBT_SIZET), --"Taille du texte du timer",
		min = 8,
		max = 32,
		step = 1,
		getFunc = function() return GroupBuffTracker.savedVars.timerFontSize end,
		setFunc = function(value) GroupBuffTracker.savedVars.timerFontSize = value end,
		width = "full",
	})

	table.insert(optionsTable, {
		type = "colorpicker",
		name = GetString(GBT_COLOR), --"Couleur du texte du timer",
		getFunc = function()
			local c = GroupBuffTracker.savedVars.timerFontColor
			return unpack(c or {1, 1, 1, 1})
		end,
		setFunc = function(r, g, b, a)
			GroupBuffTracker.savedVars.timerFontColor = {r, g, b, a}
		end,
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "description",
		text = "                                                     " .. GetString(Trad) .. GetString(Tradby), -- ajout d'espaces
		width = "full",
	})
	
    LAM:RegisterOptionControls("GroupBuffTrackerPanel", optionsTable)
end

-- Détecte la région
local function GetRegion()
    local worldName = GetWorldName()
    if string.find(worldName, "EU") then
        return "EU"
    elseif string.find(worldName, "NA") then
        return "NA"
    elseif string.find(worldName, "PTS") then
        return "PTS"
    else
        return "UNKNOWN"
    end
end

-- Affiche un vrai message dans le chat
local function GroupBuffTrackerMessage(region)
    CHAT_SYSTEM:AddMessage("GroupBuffTracker: " .. GetString(GBT_MESS) .. " -> " .. region)
end

-- Chargement de l'addon
function GroupBuffTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= GroupBuffTracker.name then return end

    local region = GetRegion()

    -- Appel avec un petit délai si nécessaire
    zo_callLater(function() GroupBuffTrackerMessage(region) end, 500)

	local defaultVars = {
		trackedBuffs = {},
		iconOffsetX = 5,
		startPosX = 75,
		startPosY = 0,
		iconSize = 24,
		timerFontSize = 16,
		timerFontColor = {1, 1, 1, 1},
	}

	-- Charger les anciennes variables "globales" ou d'une autre région pour migration
	local oldSavedVars = ZO_SavedVars:NewAccountWide(
		"GroupBuffTrackerSavedVariables",
		1,
		nil,  -- nil = profil global avant séparation par région
		defaultVars
	)

	-- Charger les nouvelles variables séparées par région
	GroupBuffTracker.savedVars = ZO_SavedVars:NewAccountWide(
		"GroupBuffTrackerSavedVariables",
		1,
		region,
		defaultVars
	)
	
	-- ROOT CONTROL PRINCIPAL
	GroupBuffTracker.rootControl = WINDOW_MANAGER:CreateTopLevelWindow("GroupBuffTrackerRoot")
	GroupBuffTracker.rootControl:SetDrawLayer(DL_OVERLAY)
	GroupBuffTracker.rootControl:SetDrawTier(DT_TOOLTIP)
	GroupBuffTracker.rootControl:SetDrawLevel(1)
	GroupBuffTracker.rootControl:SetMouseEnabled(false)
	GroupBuffTracker.rootControl:SetMovable(false)
	GroupBuffTracker.rootControl:SetClampedToScreen(true)
	GroupBuffTracker.rootControl:SetHidden(false)

	-- FRAGMENT HUD
	GroupBuffTracker.sceneFragment = ZO_HUDFadeSceneFragment:New(GroupBuffTracker.rootControl)
	HUD_SCENE:AddFragment(GroupBuffTracker.sceneFragment)
	HUD_UI_SCENE:AddFragment(GroupBuffTracker.sceneFragment)

    -- Initialiser les buffs par défaut
    for buffId, _ in pairs(GroupBuffTracker.defaultTrackedBuffs) do
        if GroupBuffTracker.savedVars.trackedBuffs[buffId] == nil then
            GroupBuffTracker.savedVars.trackedBuffs[buffId] = true
        end
    end

	-- Migrer les anciennes valeurs si elles n'existent pas déjà
	for k, v in pairs(oldSavedVars) do
		if GroupBuffTracker.savedVars[k] == nil then
			GroupBuffTracker.savedVars[k] = v
		end
	end
	
    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForUpdate(GroupBuffTracker.name, 1000, GroupBuffTracker.OnUpdate)
    EVENT_MANAGER:RegisterForEvent(GroupBuffTracker.name, EVENT_EFFECT_CHANGED, GroupBuffTracker.OnEffectChanged)
	EVENT_MANAGER:RegisterForEvent(GroupBuffTracker.name, EVENT_GROUP_MEMBER_JOINED, OnGroupSizeChanged)
    EVENT_MANAGER:RegisterForEvent(GroupBuffTracker.name, EVENT_GROUP_MEMBER_LEFT, OnGroupSizeChanged)
	EVENT_MANAGER:RegisterForEvent(GroupBuffTracker.name, EVENT_GROUP_UPDATE, OnGroupSizeChanged)
end

EVENT_MANAGER:RegisterForEvent(GroupBuffTracker.name, EVENT_ADD_ON_LOADED, GroupBuffTracker.OnAddOnLoaded)