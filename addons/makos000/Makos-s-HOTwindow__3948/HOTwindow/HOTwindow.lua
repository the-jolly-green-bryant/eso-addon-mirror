HOTwindow = {}
local HOTwindow = HOTwindow

HOTwindow.name = "HOTwindow"
HOTwindow.version = "1.2.2"
HOTwindow.author = "@makos000"

--shows offline
--shows role color
--shows class
--pillager fix attempt


local vigor = 61506
local regen = 40079
local warding_burst = 217460
local warding_cont = 217608
local combat_prayer = 61693
local minor_berserk = 61744
local powerful_assault = 61771
local major_courage = 109966
local major_resolve = 61694
local pillager = 172055
local pillager3 = 172054
local pillager2 = 172056
local major_slayer = 172056

HOTwindow.tanks = {}
HOTwindow.healers = {}

Group = WINDOW_MANAGER:CreateTopLevelWindow("Group")
GroupPVP = WINDOW_MANAGER:CreateTopLevelWindow("GroupPVP")
GroupPVPdebuff = WINDOW_MANAGER:CreateTopLevelWindow("GroupPVPdebuff")


---------------------------------------------------
---------------------------------------------------
----------- GUI creation
---------------------------------------------------
---------------------------------------------------



function HOTwindow.createGuiPVP()
    --d("HOTwindow: Creating UI")
	local offsetTex = 100

    -- Create the top-level Group control
    GroupPVP:SetMouseEnabled(true)
    GroupPVP:SetMovable(true)
    GroupPVP:SetClampedToScreen(true)
    GroupPVP:SetDimensions(152, 152)
    GroupPVP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 10)
    GroupPVP:SetHandler("OnMoveStop", function() HOTwindowOnPVPUIMove() end)

    -- Create labels
    local titleLabel = WINDOW_MANAGER:CreateControl("$(parent)Title", GroupPVP, CT_LABEL)
    titleLabel:SetDimensions(800, 200)
    titleLabel:SetFont("EsoUI/Common/Fonts/Univers57.otf|12|soft-shadow-thick")
    titleLabel:SetColor(1, 1, 1, 1) -- White color in RGBA
    titleLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    titleLabel:SetText("Makos's PvP HOT window:")
    titleLabel:SetAnchor(TOPLEFT, GroupPVP, TOP, 0, -10)

    for i = 1, 12 do
        local label = WINDOW_MANAGER:CreateControl("GroupPVPLabel" .. i, GroupPVP, CT_LABEL)
        label:SetDimensions(800, 200)
        label:SetFont("EsoUI/Common/Fonts/Univers57.otf|16|soft-shadow-thick")
        label:SetColor(1, 1, 1, 1) -- White color in RGBA
        label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText("-")
        label:SetAnchor(TOPLEFT, GroupPVP, TOP, 0, 10 + (i - 1) * 30)
    end

    -- Create textures
    local function addTexture(name, textureFile, offsetX, offsetY)
        local texture = WINDOW_MANAGER:CreateControl(name, GroupPVP, CT_TEXTURE)
        texture:SetTexture(textureFile)
        texture:SetHidden(true)
        texture:SetDimensions(20, 20)
        texture:SetAnchor(TOPLEFT, GroupPVP, TOP, offsetX, offsetY)
    end
	
	if HOTwindow.savedVariables.vigorTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPVigor" .. i, "/esoui/art/icons/ability_ava_echoing_vigor.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.regenTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPRegen" .. i, "/esoui/art/icons/ability_restorationstaff_002b.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.burstTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPBurst" .. i, "/esoui/art/icons/ability_grimoire_soulmagic2.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.wardTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPWard" .. i, "/esoui/art/icons/ability_grimoire_magesguild.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.prayerTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPPrayer" .. i, "/esoui/art/icons/ability_restorationstaff_003_b.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.paTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPPA" .. i, "esoui/art/icons/ability_healer_019.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.mcTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPMC" .. i, "esoui/art/icons/ability_buff_major_courage.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.mrTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPMR" .. i, "esoui/art/icons/ability_buff_major_resolve.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.pilTpvp then
		for i = 1, 12 do
			addTexture("GroupPVPPP" .. i, "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.customT1pvp then
		for i = 1, 12 do
			addTexture("GroupPVPC1" .. i, HOTwindow.savedVariables.custom1iconpvp or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.customT2pvp then
		for i = 1, 12 do
			addTexture("GroupPVPC2" .. i, HOTwindow.savedVariables.custom2iconpvp or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.customT3pvp then
		for i = 1, 12 do
			addTexture("GroupPVPC3" .. i, HOTwindow.savedVariables.custom3iconpvp or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.customT4pvp then
		for i = 1, 12 do
			addTexture("GroupPVPC4" .. i, HOTwindow.savedVariables.custom4iconpvp or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
	
	if HOTwindow.savedVariables.customT5pvp then
		for i = 1, 12 do
			addTexture("GroupPVPC5" .. i, HOTwindow.savedVariables.custom5iconpvp or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end

    -- Function to handle UI movement and save position
    function HOTwindowOnPVPUIMove()
        HOTwindow.savedVariables.primaryLeftPVP = GroupPVP:GetLeft()
        HOTwindow.savedVariables.primaryTopPVP = GroupPVP:GetTop()
    end

    -- Function to restore the position of the GroupPVP control
    function HOTwindow.RestorePositionPVP()
        if HOTwindow.savedVariables.primaryLeftPVP ~= nil and HOTwindow.savedVariables.primaryTopPVP ~= nil then
            GroupPVP:ClearAnchors()
            GroupPVP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                            HOTwindow.savedVariables.primaryLeftPVP,
                            HOTwindow.savedVariables.primaryTopPVP)
        end
    end

    -- Restore position immediately after creation
    HOTwindow.RestorePositionPVP()
end


function HOTwindow.createGuiPVPdebuff()
	local offsetTex = 100

    -- Create the top-level Group control
    GroupPVPdebuff:SetMouseEnabled(true)
    GroupPVPdebuff:SetMovable(true)
    GroupPVPdebuff:SetClampedToScreen(true)
    GroupPVPdebuff:SetDimensions(152, 152)
    GroupPVPdebuff:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 10)
    GroupPVPdebuff:SetHandler("OnMoveStop", function() HOTwindowOnPVPdebuffUIMove() end)

    -- Create labels
    local titleLabel = WINDOW_MANAGER:CreateControl("$(parent)Title", GroupPVPdebuff, CT_LABEL)
    titleLabel:SetDimensions(800, 200)
    titleLabel:SetFont("EsoUI/Common/Fonts/Univers57.otf|12|soft-shadow-thick")
    titleLabel:SetColor(1, 1, 1, 1) -- White color in RGBA
    titleLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    titleLabel:SetText("Makos's PVPdebuff HOT window:")
    titleLabel:SetAnchor(TOPLEFT, GroupPVPdebuff, TOP, 0, -10)

    for i = 1, 12 do
        local label = WINDOW_MANAGER:CreateControl("GroupPVPdebuffLabel" .. i, GroupPVPdebuff, CT_LABEL)
        label:SetDimensions(800, 200)
        label:SetFont("EsoUI/Common/Fonts/Univers57.otf|16|soft-shadow-thick")
        label:SetColor(1, 1, 1, 1) -- White color in RGBA
        label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText("-")
        label:SetAnchor(TOPLEFT, GroupPVPdebuff, TOP, 0, 10 + (i - 1) * 30)
    end

    -- Create textures
    local function addTexture(name, textureFile, offsetX, offsetY)
        local texture = WINDOW_MANAGER:CreateControl(name, GroupPVPdebuff, CT_TEXTURE)
        texture:SetTexture(textureFile)
        texture:SetHidden(true)
        texture:SetDimensions(20, 20)
        texture:SetAnchor(TOPLEFT, GroupPVPdebuff, TOP, offsetX, offsetY)
    end
	for j = 1, 10 do
		for i = 1, 12 do
			addTexture("GroupPVPdebuff".. j .."item".. i, HOTwindow.debuffs[j].icon or "/esoui/art/icons/ability_healer_030.dds", offsetTex, 10 + (i - 1) * 30)
		end
		offsetTex = offsetTex + 25
	end
		

    -- Function to handle UI movement and save position
    function HOTwindowOnPVPdebuffUIMove()
        HOTwindow.savedVariables.primaryLeftPVPdebuff = GroupPVPdebuff:GetLeft()
        HOTwindow.savedVariables.primaryTopPVPdebuff = GroupPVPdebuff:GetTop()
    end

    -- Function to restore the position of the GroupPVPdebuff control
    function HOTwindow.RestorePositionPVPdebuff()
        if HOTwindow.savedVariables.primaryLeftPVPdebuff ~= nil and HOTwindow.savedVariables.primaryTopPVPdebuff ~= nil then
            GroupPVPdebuff:ClearAnchors()
            GroupPVPdebuff:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                            HOTwindow.savedVariables.primaryLeftPVPdebuff,
                            HOTwindow.savedVariables.primaryTopPVPdebuff)
        end
    end

    -- Restore position immediately after creation
    HOTwindow.RestorePositionPVPdebuff()
end

---------------------------------------------------
---------------------------------------------------
----------- Innitialize function
---------------------------------------------------
---------------------------------------------------

function HOTwindow.LongLoop()
	HOTwindow.UpdateUI()
    zo_callLater(function() HOTwindow.LongLoop() end, 2000)
end

function HOTwindow.Initialize()
	--d("init proc")
	
    -- Echoing Vigor (15m)
    if HOTwindow.savedVariables.EVR then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.EVRcount, "/esoui/art/icons/ability_ava_echoing_vigor.dds", HOTwindow.savedVariables.EVRsize, 1500, "iconsEV", HOTwindow.savedVariables.EVRconeangle)
    end

    -- Combat Prayer (20m)
    if HOTwindow.savedVariables.CPR then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.CPRcount, "/esoui/art/icons/ability_restorationstaff_003_b.dds", HOTwindow.savedVariables.CPRsize, 2000, "iconsCP", HOTwindow.savedVariables.CPRconeangle)
    end

    -- Warding Contingency (8m)
    if HOTwindow.savedVariables.WCR then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.WCRcount, "/esoui/art/icons/ability_grimoire_magesguild.dds", HOTwindow.savedVariables.WCRsize, 800, "iconsWC", HOTwindow.savedVariables.WCRconeangle)
    end

    -- Custom Ranges
    if HOTwindow.savedVariables.CM1 then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.CM1count, HOTwindow.savedVariables.CM1tex or "ContentHelper/ic/square_green.dds", HOTwindow.savedVariables.CM1size, HOTwindow.savedVariables.CM1range * 100, "iconsCM1", HOTwindow.savedVariables.CM1coneangle)
    end

    if HOTwindow.savedVariables.CM2 then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.CM2count, HOTwindow.savedVariables.CM2tex or "ContentHelper/ic/square_green.dds", HOTwindow.savedVariables.CM2size, HOTwindow.savedVariables.CM2range * 100, "iconsCM2", HOTwindow.savedVariables.CM2coneangle)
    end

    if HOTwindow.savedVariables.CM3 then
        HOTwindow.PlaceMarker(HOTwindow.savedVariables.CM3count, HOTwindow.savedVariables.CM3tex or "ContentHelper/ic/square_green.dds", HOTwindow.savedVariables.CM3size, HOTwindow.savedVariables.CM3range * 100, "iconsCM3", HOTwindow.savedVariables.CM3coneangle)
    end
	
	if HOTwindow.savedVariables.windowTogglePVP then
		GroupPVP:SetHidden(true)
	end
	
	if (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
		if HOTwindow.savedVariables.windowTogglePVP == false and HOTwindow.savedVariables.toggleInPVP then
			GroupPVP:SetHidden(false)
			if HOTwindow.savedVariables.windowToggle == false then
				Group:SetHidden(true)
			end
		end
	else
		if HOTwindow.savedVariables.toggleInPVP then
			GroupPVP:SetHidden(true)
			if HOTwindow.savedVariables.windowToggle == false then
				Group:SetHidden(false)
			end
		end
	end
	
	
	
	if (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
		if HOTwindow.savedVariables.windowTogglePVPdebuff == false and HOTwindow.savedVariables.toggleInPVPdebuff then
			GroupPVPdebuff:SetHidden(false)
		end
	else
		if HOTwindow.savedVariables.toggleInPVPdebuff then
			GroupPVPdebuff:SetHidden(true)
		end
	end
	
	if HOTwindow.savedVariables.windowTogglePVPdebuff then
		GroupPVPdebuff:SetHidden(true)
	end
	
	zo_callLater(function() HOTwindow.Initialize() end, 10)
end

---------------------------------------------------
---------------------------------------------------
----------- Slash commands
---------------------------------------------------
---------------------------------------------------

SLASH_COMMANDS["/hottoggle"] = function()
	HOTwindow.HideWindow()
end

SLASH_COMMANDS["/hottogglepvp"] = function()
	HOTwindow.HideWindowPVP()
end

SLASH_COMMANDS["/hottoggledebuff"] = function()
	HOTwindow.HideWindowPVPdebuff()
end

---------------------------------------------------
---------------------------------------------------
----------- UI utility
---------------------------------------------------
---------------------------------------------------

function HOTwindow.HideWindow()
	HOTwindow.savedVariables.windowToggle = not Group:IsHidden()
	Group:SetHidden(HOTwindow.savedVariables.windowToggle)
end

function HOTwindow.UpdateWindow()
	Group:SetHidden(HOTwindow.savedVariables.windowToggle)
	Group:SetMouseEnabled(not HOTwindow.savedVariables.locked)
    Group:SetMovable(not HOTwindow.savedVariables.locked)
end

function HOTwindow.HideWindowPVP()
	HOTwindow.savedVariables.windowTogglePVP = not GroupPVP:IsHidden()
	GroupPVP:SetHidden(HOTwindow.savedVariables.windowTogglePVP)
end

function HOTwindow.UpdateWindowPVP()
	GroupPVP:SetHidden(HOTwindow.savedVariables.windowTogglePVP)
	GroupPVP:SetMouseEnabled(not HOTwindow.savedVariables.lockedPVP)
    GroupPVP:SetMovable(not HOTwindow.savedVariables.lockedPVP)
end

function HOTwindow.HideWindowPVPdebuff()
	HOTwindow.savedVariables.windowTogglePVPdebuff = not GroupPVPdebuff:IsHidden()
	GroupPVPdebuff:SetHidden(HOTwindow.savedVariables.windowTogglePVPdebuff)
end

function HOTwindow.UpdateWindowPVPdebuff()
	GroupPVPdebuff:SetHidden(HOTwindow.savedVariables.windowTogglePVPdebuff)
	GroupPVPdebuff:SetMouseEnabled(not HOTwindow.savedVariables.lockedPVPdebuff)
    GroupPVPdebuff:SetMovable(not HOTwindow.savedVariables.lockedPVPdebuff)
end

-- Function to handle combat events
function HOTwindow.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    --HOTwindow.UpdateUI()

    if abilityId == pillager2 or abilityId == pillager or abilityId== pillager3 then
        local index = HOTwindow.GetUnitIndex(HOTwindow.GetUnitTagFromCharacterName(targetName))
        if index then
            local item = _G[GroupPP .. index]
            if item then
                item:SetHidden(false)
                zo_callLater(function() item:SetHidden(true) end, 10000)
            end
        end
    end

    if abilityId == pillager2 or abilityId == pillager or abilityId== pillager3 then
        local index = HOTwindow.GetUnitIndex(HOTwindow.GetUnitTagFromCharacterName(targetName))
        if index then
            local item = _G[GroupPVPPP .. index]
            if item then
                item:SetHidden(false)
                zo_callLater(function() item:SetHidden(true) end, 10000)
            end
        end
    end
end

function HOTwindow.GetUnitTagFromCharacterName(characterName)
    for _, unitTag in ipairs(HOTwindow.SortedUnitIndex) do
        if DoesUnitExist(unitTag) then
            local unitCharName = GetUnitName(unitTag) -- This is the character name
            if unitCharName and unitCharName:lower() == characterName:lower() then
                return unitTag
            end
        end
    end
    return nil -- Not found
end

---------------------------------------------------
---------------------------------------------------
----------- on EffectChanged
---------------------------------------------------
---------------------------------------------------

function HOTwindow.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

	--d(eventCode, result, abilityId)
	--d("target ID: " .. tostring(targetUnitId) .. "  self: " .. tostring(sourceUnitId))
	--d("Ability ID: " .. abilityId)
	--d("unitTag " .. unitTag)
	--d("changeType " .. changeType)
	--d("effectName " .. effectName)

    if abilityId == vigor and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupVigor")
        SetItem(changeType, unitTag, "GroupPVPVigor")
    end

    if abilityId == regen and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupRegen")
        SetItem(changeType, unitTag, "GroupPVPRegen")
    end

    if abilityId == warding_burst and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupBurst")
        SetItem(changeType, unitTag, "GroupPVPBurst")
    end

    if abilityId == warding_cont and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupWard")
        SetItem(changeType, unitTag, "GroupPVPWard")
    end

    if (abilityId == combat_prayer or abilityId == minor_berserk) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPrayer")
        SetItem(changeType, unitTag, "GroupPVPPrayer")
    end
	
	if abilityId == powerful_assault and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPA")
        SetItem(changeType, unitTag, "GroupPVPPA")
    end
	
	if abilityId == major_courage and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupMC")
        SetItem(changeType, unitTag, "GroupPVPMC")
    end
	
	if abilityId == major_resolve then
        SetItem(changeType, unitTag, "GroupMR")
        SetItem(changeType, unitTag, "GroupPVPMR")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom1ID) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupC1")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom2ID) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupC2")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom3ID) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupC3")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom4ID) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupC4")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom5ID) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupC5")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom1IDpvp) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPVPC1")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom2IDpvp) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPVPC2")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom3IDpvp) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPVPC3")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom4IDpvp) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPVPC4")
    end
	
	if abilityId == tonumber(HOTwindow.savedVariables.custom5IDpvp) and sourceType == 1 then
        SetItem(changeType, unitTag, "GroupPVPC5")
    end
	
	for i, debuff in ipairs(HOTwindow.debuffs) do
		if effectName == debuff.name then
			if i <= 10 then
				SetItem(changeType, unitTag, "GroupPVPdebuff".. i .."item")
			else
				
			end
		end
	end
end

---------------------------------------------------
---------------------------------------------------
----------- UI update functions
---------------------------------------------------
---------------------------------------------------

function HOTwindow.UpdateHealth(unitTag, health, maxHealth)
    local index = HOTwindow.GetUnitIndex(unitTag)
    local role = GetGroupMemberSelectedRole(unitTag)
    if not index then return end

    local healthBar = _G["GroupHealthBar" .. index]
    if not healthBar then return end
	
	local healthBarLabel = _G["HealthBarLabel" .. index]
	healthBarLabel:SetText(tostring(math.floor(health/1000)) .. "k" .."/".. tostring(math.floor(maxHealth/1000)) .."k")
	
	--d(maxHealth)

    if maxHealth > 0 then
        local healthPercent = (health / maxHealth) * 100
        ZO_StatusBar_SmoothTransition(healthBar, healthPercent, 100) -- Smooth transition like the addon

        -- Change color dynamically
        if healthPercent > 70 then
            if role == LFG_ROLE_TANK then
                healthBar:SetColor(1, 0.6, 0.6, 1)
            elseif role == LFG_ROLE_HEAL then
                healthBar:SetColor(0.6, 1, 0.6, 1)
            else
                healthBar:SetColor(1, 1, 1, 1)
            end
            healthBarLabel:SetColor(0, 0, 0, 1)
        elseif healthPercent > 25 then
            healthBar:SetColor(1, 1, 0, 1) -- Yellow (medium)
            healthBarLabel:SetColor(1, 1, 0, 1) -- Yellow (medium)
        else
            healthBar:SetColor(1, 0, 0, 1) -- Red (low)
            healthBarLabel:SetColor(1, 0, 0, 1) -- Red (low)
        end
    end
end

function HOTwindow.UpdateShield(unitTag, shieldValue)
    local index = HOTwindow.GetUnitIndex(unitTag)
    if not index then 
        --d("No index found for shield update: " .. tostring(unitTag))
        return 
    end

    local shieldBar = _G["GroupShieldBar" .. index]
    if not shieldBar then 
        --d("No shield bar found for index: " .. tostring(index))
        return 
    end
	
	local shieldLabel = _G["ShieldLabel" .. index]

    -- Get max health for proper scaling
    local maxHealth = select(2, GetUnitPower(unitTag, POWERTYPE_HEALTH))
    if not maxHealth or maxHealth <= 0 then
        --d("Invalid max health for: " .. tostring(unitTag))
        return
    end

    -- Debugging
    --d("Updating shield for: " .. unitTag .. " | Shield: " .. tostring(shieldValue) .. " / Max Health: " .. tostring(maxHealth))

    -- Calculate shield percentage relative to max health
    local shieldPercent = (shieldValue / maxHealth) * 100

    -- Ensure it doesn’t exceed 100% of the max bar width
    if shieldPercent > 100 then
        shieldPercent = 100
    end

    ZO_StatusBar_SmoothTransition(shieldBar, shieldPercent, 100)

    -- Show or hide shield bar based on shield presence
    if shieldValue > 0 then
        shieldBar:SetHidden(false)
		shieldLabel:SetHidden(false)
		shieldLabel:SetText("[".. tostring(math.floor(shieldValue/1000)).."k]")
    else
        shieldBar:SetHidden(true)
		shieldLabel:SetHidden(true)
    end
end



-- Global table to store sorted unit indexes
HOTwindow.SortedUnitIndex = {}

-- Function to update the UI with sorted group members
function HOTwindow.UpdateUI()
    if not IsUnitGrouped("player") then
        -- If the player is not grouped, only show themselves and clear the rest
        local atName = GetUnitDisplayName("player") or ""
        local classId = GetUnitClassId("player")
        local role = GetGroupMemberSelectedRole("player")

        local classIcon = _G["ClassIcon" .. 1]
        classIcon:SetHidden(false)
        classIcon:SetTexture(HOTwindow.getClassTexture(classId))

        if role == LFG_ROLE_TANK then
            classIcon:SetColor(1, 0.6, 0.6, 1)
        elseif role == LFG_ROLE_HEAL then
            classIcon:SetColor(0.6, 1, 0.6, 1)
        else
            classIcon:SetColor(1, 1, 1, 1)
        end

        SetName(1, atName)
        SetNamePVP(1, atName)
        SetNamePVPdebuff(1, atName)
		
		-- Update shield for player
        local shield, maxShield = GetUnitPower("player", POWERTYPE_SHIELDING)
        --HOTwindow.UpdateShield("player", shield)
        
        -- Clear unused labels
        for i = 2, 12 do
            SetName(i, "")
            SetNamePVP(i, "")
            SetNamePVPdebuff(i, "")
			
			local healthBar = _G["GroupHealthBar" .. i]
			healthBar:SetHidden(true)
			
			local healthBarLabel = _G["HealthBarLabel" .. i]
			healthBarLabel:SetHidden(true)
			
			local shieldLabel = _G["ShieldLabel" .. i]
			shieldLabel:SetHidden(true)

            local classIcon = _G["ClassIcon" .. i]
            classIcon:SetHidden(true)
        end

        HOTwindow.SortedUnitIndex = { ["player"] = 1 }
        return
    end

    -- Tables for sorted roles
    HOTwindow.tanks = {}
    HOTwindow.healers = {}

    local tanks = {}
    local healers = {}
    local dds = {}
    HOTwindow.SortedUnitIndex = {}

    local groupSize = GetGroupSize()

    -- Iterate through group members and categorize them by role
    for i = 1, groupSize do
        local unitTag = "group" .. i
        local role = GetGroupMemberSelectedRole(unitTag)
        local atName = GetUnitDisplayName(unitTag) or ""
		
		local healthBar = _G["GroupHealthBar" .. i]
		healthBar:SetHidden(false)
		
		local healthBarLabel = _G["HealthBarLabel" .. i]
		healthBarLabel:SetHidden(false)
		
		local shieldLabel = _G["ShieldLabel" .. i]
		shieldLabel:SetHidden(false)

        if role == LFG_ROLE_TANK then
            table.insert(tanks, { name = atName, tag = unitTag })
            table.insert(HOTwindow.tanks, unitTag)
        elseif role == LFG_ROLE_HEAL then
            table.insert(healers, { name = atName, tag = unitTag })
            table.insert(HOTwindow.healers, unitTag)
        else
            table.insert(dds, { name = atName, tag = unitTag })
        end
    end

    -- Merge sorted lists
    local sortedGroup = {}
    for _, member in ipairs(tanks) do table.insert(sortedGroup, member) end
    for _, member in ipairs(healers) do table.insert(sortedGroup, member) end
    for _, member in ipairs(dds) do table.insert(sortedGroup, member) end

    -- Store sorted index mapping
    for i, member in ipairs(sortedGroup) do
        HOTwindow.SortedUnitIndex[member.tag] = i
    end

    -- Apply sorted list to UI
    for i = 1, #sortedGroup do
        SetName(i, sortedGroup[i].name)
        SetNamePVP(i, sortedGroup[i].name)
        SetNamePVPdebuff(i, sortedGroup[i].name)

        local classId = GetUnitClassId(sortedGroup[i].tag)
        local isOnline = IsUnitOnline(sortedGroup[i].tag)

        local label = _G["GroupLabel" .. i]

        local classIcon = _G["ClassIcon" .. i]
        classIcon:SetHidden(false)
        classIcon:SetTexture(HOTwindow.getClassTexture(classId))

        if isOnline == false then
            label:SetColor(1, 0.3, 0.3, 1)
        else
            label:SetColor(0, 0, 0, 1)
		end

        if HOTwindow.IsValueInTable(HOTwindow.tanks, sortedGroup[i].tag) then
            classIcon:SetColor(1, 0.6, 0.6, 1)
        elseif HOTwindow.IsValueInTable(HOTwindow.healers, sortedGroup[i].tag) then
            classIcon:SetColor(0.6, 1, 0.6, 1)
        elseif isOnline == false then
            classIcon:SetColor(1, 0.3, 0.3, 1)
		else
            classIcon:SetColor(1, 1, 1, 1)
		end
		-- Update shields for each unit
        local shield, maxShield = GetUnitPower(sortedGroup[i].tag, POWERTYPE_SHIELDING)
    end

    -- Clear unused labels
    for i = #sortedGroup + 1, 12 do
        SetName(i, "")
        SetNamePVP(i, "")
        SetNamePVPdebuff(i, "")
		
		local healthBar = _G["GroupHealthBar" .. i]
		healthBar:SetHidden(true)
		
		local healthBarLabel = _G["HealthBarLabel" .. i]
		healthBarLabel:SetHidden(true)
		
		local shieldLabel = _G["ShieldLabel" .. i]
		shieldLabel:SetHidden(true)

        local classIcon = _G["ClassIcon" .. i]
        classIcon:SetHidden(true)
    end
end

function HOTwindow.IsValueInTable(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Function to get the new index of a unit
function HOTwindow.GetUnitIndex(unitTag)
    return HOTwindow.SortedUnitIndex[unitTag] or nil
end

-- Function to set the label text for group members
function SetName(i, atName)
    local label = _G["GroupLabel" .. i]
    if label then
        label:SetText(atName)
    end
end

function SetNamePVP(i, atName)
    local label = _G["GroupPVPLabel" .. i]
    if label then
        label:SetText(atName)
    end
end

function SetNamePVPdebuff(i, atName)
    local label = _G["GroupPVPdebuffLabel" .. i]
    if label then
        label:SetText(atName)
    end
end

-- Function to update item visibility based on ability status
function SetItem(changeType, unitTag, itemName)
    local index = HOTwindow.GetUnitIndex(unitTag)
    if index then
        local item = _G[itemName .. index]
        if item then
            item:SetHidden(changeType ~= EFFECT_RESULT_UPDATED)
        end
    end
end

---------------------------------------------------
---------------------------------------------------
----------- Addon LOADED
---------------------------------------------------
---------------------------------------------------


function HOTwindow.OnAddOnLoaded(event, addonName)
    if addonName ~= HOTwindow.name then return end

    HOTwindow.savedVariables = ZO_SavedVars:NewCharacterNameSettings("HOTwindowSavedVariables", 1, nil, {})
	HOTwindow.savedVariablesAccount = ZO_SavedVars:NewAccountWide("HOTwindowSavedVariablesGlobal", 1, nil, {})


	
    EVENT_MANAGER:RegisterForEvent(HOTwindow.name, EVENT_COMBAT_EVENT, HOTwindow.CombatEvent)
    EVENT_MANAGER:RegisterForEvent(HOTwindow.name, EVENT_EFFECT_CHANGED, HOTwindow.EffectChanged)
	
	EVENT_MANAGER:RegisterForEvent("HOTwindow_HealthUpdate", EVENT_POWER_UPDATE, function(eventCode, unitTag, powerIndex, powerType, health, maxHealth)
		if powerType == POWERTYPE_HEALTH then
			HOTwindow.UpdateHealth(unitTag, health, maxHealth)
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent("HOTwindow_ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
		if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			--d("Shield added for: " .. tostring(unitTag) .. " | Shield Value: " .. tostring(value))
			HOTwindow.UpdateShield(unitTag, value)
		end
	end)

	EVENT_MANAGER:RegisterForEvent("HOTwindow_ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue)
		if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			--d("Shield updated for: " .. tostring(unitTag) .. " | New Shield Value: " .. tostring(newValue))
			HOTwindow.UpdateShield(unitTag, newValue)
		end
	end)

	EVENT_MANAGER:RegisterForEvent("HOTwindow_ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
		if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			--d("Shield removed for: " .. tostring(unitTag))
			HOTwindow.UpdateShield(unitTag, 0)
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent("HOTwindow_GroupUpdate", EVENT_GROUP_UPDATE, function()
		HOTwindow.UpdateUI()
	end)
	
	-- Register our function with LibCustomMenu
    if LibCustomMenu then
        LibCustomMenu:RegisterContextMenu(function(inventorySlot)
            --d("Right-click detected! Triggering AddContextMenu...")
            HOTwindow.AddContextMenu(inventorySlot)
        end)
    else
        d("ERROR: LibCustomMenu not found! Ensure it is installed.")
    end
	
	EVENT_MANAGER:RegisterForEvent("HOTwindow_BankOpened", EVENT_OPEN_BANK, function(eventCode, bankBag)
		HOTwindow.OnBankOpened(eventCode, bankBag)
	end)
	EVENT_MANAGER:RegisterForEvent("HOTwindow_BankClose", EVENT_CLOSE_BANK, HOTwindow.HideBankButtons)
	
	HOTwindow.HookInventories()
		
	zo_callLater(function() HOTwindow.LoadedMessage() end, 7000)
	
	-- ZO_CreateStringId("SI_BINDING_NAME_DEPOSIT_MARKED_ITEMS", "Deposit Marked Items")
	-- ZO_CreateKeybindButtonGroup({
		-- {
			-- name = "Deposit Marked Items",
			-- keybind = "SI_BINDING_NAME_DEPOSIT_MARKED_ITEMS",
			-- callback = DepositMarkedItems,
		-- }
	-- })
	
	HOTwindow.createGui()
	HOTwindow.createGuiPVP()
	HOTwindow.createGuiPVPdebuff()
	HOTwindow.AddonMenu()
	HOTwindow.AddonMenuRange()
	HOTwindow.AddonMenuExtra()
	HOTwindow.SavedVars()
	zo_callLater(function() HOTwindow.Initialize() end, 500)
	zo_callLater(function() HOTwindow.LongLoop() end, 500)
	zo_callLater(function() HOTwindow.UpdateUI() end, 500)
	
	Group:SetHidden(HOTwindow.savedVariables.windowToggle)
	GroupPVP:SetHidden(HOTwindow.savedVariables.windowTogglePVP)
	GroupPVPdebuff:SetHidden(HOTwindow.savedVariables.windowTogglePVPdebuff)
	Group:SetMouseEnabled(not HOTwindow.savedVariables.locked)
	GroupPVP:SetMouseEnabled(not HOTwindow.savedVariables.lockedPVP)
	GroupPVPdebuff:SetMouseEnabled(not HOTwindow.savedVariables.lockedPVPdebuff)
    Group:SetMovable(not HOTwindow.savedVariables.locked)
    GroupPVP:SetMovable(not HOTwindow.savedVariables.lockedPVP)
    GroupPVPdebuff:SetMovable(not HOTwindow.savedVariables.lockedPVPdebuff)
	
    EVENT_MANAGER:UnregisterForEvent(HOTwindow.name, EVENT_ADD_ON_LOADED)
end

-- Function to display a loaded message
function HOTwindow.LoadedMessage()
    d("Makos's HOTwindow loaded")
end

-- Register the addon loaded event
EVENT_MANAGER:RegisterForEvent(HOTwindow.name, EVENT_ADD_ON_LOADED, HOTwindow.OnAddOnLoaded)





---------------------------------------------------
---------------------------------------------------
----------- Place marker functions
---------------------------------------------------
---------------------------------------------------


function HOTwindow.PlaceMarker(count, texture, size, range, iconTable, coneAngleDegrees)
    -- Default count to 1 if not provided
    count = count or 1
    coneAngleDegrees = coneAngleDegrees or 360  -- Default to full circle (360°)
    
    -- Convert degrees to radians
    local coneAngle = math.rad(coneAngleDegrees)

    -- Get the player's position (X, Y, Z)
    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")

    -- Get camera yaw (rotation left/right)
    local yaw = GetPlayerCameraHeading()
    if not yaw then return end  -- Ensure we have a valid yaw value

    -- Set distance (e.g., 15 meters = 1500 units)
    local distance = range

    -- Initialize icon table if not existing
    if not HOTwindow[iconTable] then
        HOTwindow[iconTable] = {}
    end

    -- **Remove excess icons (prevents old icons from staying)**
    while #HOTwindow[iconTable] > count do
        local icon = table.remove(HOTwindow[iconTable])
        OSI.DiscardPositionIcon(icon)
    end

    -- **Calculate angle placement**
    local startAngle, angleStep

    if count == 1 then
        -- Special case: Only one icon → Place it directly in front of the player
        startAngle = yaw
        angleStep = 0  -- No need to step since there's only one icon
    else
        -- Normal case: Spread icons within the given angle range
        startAngle = yaw - (coneAngle / 2)  -- Left boundary
        angleStep = coneAngle / (count - 1)  -- Step size for icon placement
    end

    -- Place `count` icons
    for i = 1, count do
        -- Calculate the angle for this icon
        local angle = startAngle + (i - 1) * angleStep

        -- Compute the position for this icon
        local targetX = playerX - distance * math.sin(angle)
        local targetZ = playerZ - distance * math.cos(angle)
        local targetY = playerY  -- Keep the same height

        -- **Remove and re-create the icon instead of updating**
        if HOTwindow[iconTable][i] then
            OSI.DiscardPositionIcon(HOTwindow[iconTable][i])  -- Remove old icon
        end

        -- Create a new icon
        HOTwindow[iconTable][i] = OSI.CreatePositionIcon(targetX, targetY, targetZ, texture, size)
    end
end




