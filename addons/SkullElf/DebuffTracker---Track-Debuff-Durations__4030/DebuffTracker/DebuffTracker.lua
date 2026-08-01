local DebuffTracker = DebuffTracker

local trackedUptimeAbilities = {}

local trialZones = {
    [ 636] = true,  -- Hel Ra Citadel
    [ 638] = true,  -- Aetherian Archive
    [ 639] = true,  -- Sanctum Ophidia
    [ 725] = true,  -- Maw of Lorkhaj
    [ 975] = true,  -- Halls of Fabrication
    [1000] = true, -- Asylum Sanctorium
    [1051] = true, -- Cloudrest
    [1121] = true, -- Sunspire
    [1196] = true, -- Kyne's Aegis
    [1263] = true, -- Rockgrove
    [1344] = true, -- Dreadsail Reef
    [1427] = true, -- Sanity's Edge
    [1478] = true, -- Lucent Citadel
	[1548] = true, -- Ossein Cage
}

local DebuffTrackerUI = {}
local barChoices = {
    [1] = "|t160:20:DebuffTracker/icons/gradientProgressBar.dds|t",
    [2] = "|t160:20:DebuffTracker/icons/gradientProgressBarFlipped.dds|t",
    [3] = "|t160:20:DebuffTracker/icons/gradientProgressBar2.dds|t",
    [4] = "|t160:20:DebuffTracker/icons/gradientProgressBar2Flipped.dds|t",
    [5] = "|t160:20:DebuffTracker/icons/progressBar.dds|t",
}

function DebuffTracker.GetCommonDebuffs()
    return {
        trackedAbilities = {
            { id = 38541, name = "Taunt", enabled = false },
            { id = 52788, name = "Taunt Immunity", enabled = false },
            { id = 17906, name = "Crusher", enabled = false },
--            { id = 68588, name = "Minor Breach (PotL)", enabled = false },
            { id = 62787, name = "Major Breach", enabled = false },
--            { id = 80020, name = "Minor Lifesteal", enabled = false },
--            { id = 39100, name = "Minor Magickasteal", enabled = false },
			{ id = 145975, name = "Minor Brittle", enabled = false },
            { id = 81519, name = "Minor Vulnerability", enabled = false },
            { id = 122389, name = "Major Vulnerability", enabled = false },
            { id = 62988, name = "Off Balance", enabled = false },
            { id = 134599, name = "Off Balance Immunity", enabled = false },
            { id = 127070, name = "Way of Martial Knowledge", enabled = false },
            { id = 126597, name = "Touch of Z'en", enabled = false },
			{ id = 75753, name = "Line-Breaker (Alkosh)", enabled = false},
			{ id = 142610, name = "Elemental Catalyst (Fire)", enabled = false},
			{ id = 142653, name = "Elemental Catalyst (Shock)", enabled = false},
			{ id = 142652, name = "Elemental Catalyst (Frost)", enabled = false},
			{ id = 134336, name = "Stagger", enabled = false},
			
        },

        customAbilities = {},

        abilityCopies = {
            [81519] = { 51434, 61782, 68359, 79715, 79717, 79720, 79723, 79726, 79843, 79844, 79845, 79846, 117025, 118613, 120030, 124803, 124804, 124806, 130155, 130168, 130173, 130809 }, -- Minor Vulnerability
            [80020] = { 86304, 86305, 86307, 88565, 88575, 88606, 92653, 121634, 148043 }, -- Minor Lifesteal
            [68588] = { 38688, 61742, 83031, 84358, 108825, 120019, 126685, 146908 }, -- Minor Breach
            [62988] = { 62968, 39077, 130145, 130129, 130139, 45902, 25256, 34733, 34737, 23808, 20806, 34117, 125750, 131562, 45834, 137257, 137312, 120014 }, -- Off Balance
            [62787] = { 28307, 33363, 34386, 36972, 36980, 40254, 48946, 53881, 61743, 62474, 62485, 62775, 78609, 85362, 91175, 91200, 100988, 108951, 111788, 117818, 118438, 120010 }, -- Major Breach
            [122389] = { 106754, 106755, 106758, 106760, 106762, 122177, 122397 }, -- Major Vulnerability
            [39100] = { 26220, 26809, 88401, 88402, 88576, 125316, 148044 }, -- Minor Magickasteal
            [38541] = { 38254 }, -- Taunt
			[145975] = { 145975, 146697, 148977, 154272, 20183267, 30183267, 40183267, 184986, 219247, 221492, 221725, 235871, 235890 } -- minor brittle

        },
    }
end

function DebuffTracker.IsAbilityTracked(abilityId)
    return DebuffTracker.savedVars
        and DebuffTracker.savedVars.trackedAbilities
        and DebuffTracker.savedVars.trackedAbilities[abilityId] == true
end

local function SetMarker(size) -- disabled because zos is fun and this makes the game crash...
	return
end

function DebuffTracker.ToggleMarkerSize()
    local newSize = (DebuffTracker.savedVars.markerSizeToggleEnabled and 2.5 or 1) * DebuffTracker.savedVars.markerSize
    SetMarker(newSize)
end

function DebuffTracker.GetSetting(abilityId, key)

    local mapSettings = {
        reminderEnabled = true,
        trackedAbilities = true,
    }

    if mapSettings[key] then
        local map = DebuffTracker.savedVars[key]
        if map and map[abilityId] ~= nil then
            return map[abilityId]
        end
    end

    local abilitySettings = DebuffTracker.savedVars.abilitySettings
    if abilitySettings and abilitySettings[abilityId] and abilitySettings[abilityId][key] ~= nil then
        return abilitySettings[abilityId][key]
    end

    return DebuffTracker.savedVars[key]
end

function DebuffTracker.SetSetting(abilityId, key, value)
    local global = DebuffTracker.savedVars[key]
    DebuffTracker.savedVars.abilitySettings = DebuffTracker.savedVars.abilitySettings or {}

    if value == global then
        if DebuffTracker.savedVars.abilitySettings[abilityId] then
            DebuffTracker.savedVars.abilitySettings[abilityId][key] = nil
        end
    else
        DebuffTracker.savedVars.abilitySettings[abilityId] = DebuffTracker.savedVars.abilitySettings[abilityId] or {}
        DebuffTracker.savedVars.abilitySettings[abilityId][key] = value
    end
end



function DebuffTracker.FormatNumber(abilityId, value, suffix)
    value = tonumber(value)

    if not value then return "" end 

    local showDecimal = DebuffTracker.GetSetting(abilityId, "decimalNum") ~= 0
    local formatted = showDecimal and string.format("%.1f", value) or string.format("%d", math.floor(value))
    
    return suffix and (formatted .. suffix) or formatted
end

function DebuffTracker.GetAbilityUIConfig(abilityId)
    
	
	if DebuffTracker.savedVars.ui == {} then
		DebuffTracker.savedVars.ui = {
			groupWidth = 220,
			headerHeight = 30,
			rowWidth = 215,
			rowHeight = 25,
			iconSize = 24,
			barWidth = 165,
			barHeight = 20,
			rowSpacing = 25,
			stackLabelWidth = 20,
			timerLabelWidth = 20,
			windowAlpha = 1,
			barAlpha = 1,

		}
	end
	local global = DebuffTracker.savedVars.ui

    local barHeight         = DebuffTracker.GetSetting(abilityId, "barHeight") or global.barHeight or 20
    local barWidth          = DebuffTracker.GetSetting(abilityId, "barWidth") or global.barWidth or 215
    local stackLabelWidth   = DebuffTracker.GetSetting(abilityId, "stackLabelWidth") or global.stackLabelWidth or 30
    local timerLabelWidth   = DebuffTracker.GetSetting(abilityId, "timerLabelWidth") or global.timerLabelWidth or 30
    local headerHeight      = DebuffTracker.GetSetting(abilityId, "headerHeight") or global.headerHeight or 30
    local iconSize          = DebuffTracker.GetSetting(abilityId, "iconSize") or global.iconSize or 24
    local rowPaddingX       = DebuffTracker.GetSetting(abilityId, "rowPaddingX") or global.rowPaddingX or 5
	local alpha             = DebuffTracker.GetSetting(abilityId, "windowAlpha") or (global.windowAlpha or 1)
	local barAlpha          = DebuffTracker.GetSetting(abilityId, "barAlpha") or (global.barAlpha or 1)


    return {
		alpha            = alpha,
		barAlpha         = barAlpha,
        barHeight        = barHeight,
        barWidth         = barWidth,
        rowSpacing       = barHeight + 2,
        groupWidth       = barWidth + 10,
        rowPaddingX      = rowPaddingX,
        headerHeight     = headerHeight,
        stackLabelWidth  = stackLabelWidth,
        timerLabelWidth  = timerLabelWidth,
        iconSize         = iconSize,
        rowWidth         = barWidth + 10,
    }
end

local function GetOrCreateDebuffGroup(abilityId)
    local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)
	local customTitle = DebuffTracker.savedVars.customTitles and DebuffTracker.savedVars.customTitles[abilityId]
	local title = customTitle or GetAbilityName(abilityId)
	local abilityName = title
    local abilityIcon = GetAbilityIcon(abilityId)

    if not DebuffTrackerUI[abilityId] then
        local uiName = "DebuffTracker_UI_" .. abilityId

        local window = WINDOW_MANAGER:CreateTopLevelWindow(uiName)
        window:SetMovable(true)
        window:SetMouseEnabled(true)

        local fragment = ZO_HUDFadeSceneFragment:New(window)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)

        local savedPos = DebuffTracker.savedVars.positions[abilityId]
        if savedPos then
            window:ClearAnchors()
            window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
        else
            window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)
        end

        local background = WINDOW_MANAGER:CreateControl(uiName .. "_Background", window, CT_BACKDROP)
        background:SetCenterColor(0, 0, 0, 0.8)
        background:SetEdgeColor(0, 0, 0, 1)
        background:SetAnchor(LEFT, window, LEFT)

        local headerContainer = WINDOW_MANAGER:CreateControl(uiName .. "_HeaderContainer", window, CT_CONTROL)
        headerContainer:SetAnchor(TOPLEFT, background, TOPLEFT, 0, 0)


        local icon = WINDOW_MANAGER:CreateControl(uiName .. "_Icon", headerContainer, CT_TEXTURE)
        icon:SetAnchor(LEFT, headerContainer, LEFT, 5, 0)
        icon:SetTexture(abilityIcon)
        icon:SetDimensions(cfg.iconSize, cfg.iconSize)

        local titleLabel = WINDOW_MANAGER:CreateControl(uiName .. "_Title", headerContainer, CT_LABEL)
        titleLabel:SetFont("ZoFontGameSmall")
        titleLabel:SetColor(1, 1, 1, 1)
        titleLabel:SetText(abilityName)
        titleLabel:SetAnchor(LEFT, icon, RIGHT, 5, 0)
        titleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        titleLabel:SetMaxLineCount(1)
        titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        titleLabel:SetDimensions(cfg.groupWidth - cfg.iconSize - 8, cfg.headerHeight)

        window:SetDimensions(cfg.groupWidth, cfg.headerHeight)
        background:SetDimensions(cfg.groupWidth, cfg.headerHeight)
        headerContainer:SetDimensions(cfg.groupWidth, cfg.headerHeight)

        window:SetHidden(false)
        window:SetHandler("OnMoveStop", function()
            local left, top = window:GetLeft(), window:GetTop()
            DebuffTracker.savedVars.positions[abilityId] = { x = left, y = top }
        end)

        DebuffTrackerUI[abilityId] = {
            window = window,
            background = background,
            icon = icon,
            title = titleLabel,
            bars = {},
            headerContainer = headerContainer,
            fragment = fragment
        }

    else
        local group = DebuffTrackerUI[abilityId]
        group.window:SetHidden(false)
        group.window:SetDimensions(cfg.groupWidth, cfg.headerHeight)
        group.background:SetDimensions(cfg.groupWidth, cfg.headerHeight)
    end

    return DebuffTrackerUI[abilityId]
end

local function GetOrCreateUnitRow(abilityId, unitId, duration, stackCount, unitName, createIfMissing, onCreate)
    local debuffGroup = createIfMissing and GetOrCreateDebuffGroup(abilityId) or DebuffTrackerUI[abilityId]
    if not debuffGroup or not debuffGroup.background then return nil end

    debuffGroup.unitOrder = debuffGroup.unitOrder or {}

    local barData = debuffGroup.bars[unitId]
    if barData then return barData end

    table.insert(debuffGroup.unitOrder, unitId)

    local row, key = DebuffTracker.rowPool:AcquireObject()
    if onCreate then onCreate() end
    row:SetParent(debuffGroup.window)

    local cfg = DebuffTracker.savedVars.ui
    row:SetDimensions(cfg.rowWidth - 15, cfg.barHeight)

    local timerBarControl = row:GetNamedChild("TimerBar")
    local timerBar = ZO_TimerBar:New(timerBarControl)
    timerBar:SetDirection(TIMER_BAR_COUNTS_DOWN)
    timerBar:SetTimeFormatParameters(
        TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS,
        TIME_FORMAT_PRECISION_TENTHS
    )
	
    local status = timerBar.status
    local text = timerBarControl:GetNamedChild("Label")
    local timeText = timerBarControl:GetNamedChild("Time")
    local stackText = row:GetNamedChild("Stack")
    local background = row:GetNamedChild("Bg")

    local showStacks = DebuffTracker.GetSetting(abilityId, "showStacks") and ShouldAbilityShowStacks(abilityId)
    local showTimer = DebuffTracker.GetSetting(abilityId, "showTimer")

    status:SetColor(0, 1, 0, 1)
    status:SetTexture(DebuffTracker.savedVars.barTexture)
    status:SetMinMax(0, duration)
    status:SetValue(duration)
    status:SetAlpha(DebuffTracker.GetAbilityUIConfig(abilityId).barAlpha or 1)

    -- Stack Text
    stackText:SetHidden(not showStacks)
    stackText:SetFont("ZoFontGameSmall")
    stackText:SetText(showStacks and (stackCount > 1 and "x" .. stackCount or "") or "")
    stackText:SetDimensions(cfg.stackLabelWidth, cfg.barHeight)

    -- Timer Text
    timeText:SetHidden(not showTimer)
    timeText:SetFont("ZoFontGameSmall")
    timeText:SetText(showTimer and DebuffTracker.FormatNumber(abilityId, duration, "s") or "")
    timeText:SetDimensions(cfg.timerLabelWidth, cfg.barHeight)

    
    if showTimer then
		timeText:ClearAnchors()
        if showStacks then
            timeText:SetAnchor(RIGHT, stackText, LEFT, -5, 0)
        else
            timeText:SetAnchor(RIGHT, background, RIGHT, -5, 0)
        end
    end

    -- Unit Name
    text:SetFont("ZoFontGameSmall")
    text:SetText(unitName)

    debuffGroup.bars[unitId] = {
        row = row,
        timerBar = timerBar,
        status = status,
        text = text,
        stackText = stackText,
        timeText = timeText,
        poolKey = key
    }

    return debuffGroup.bars[unitId]
end


local function SortDebuffUnitOrder(abilityId)
    local debuffGroup = DebuffTrackerUI[abilityId]
    if not debuffGroup or not debuffGroup.unitOrder or not debuffGroup.bars then return end

    local mode = DebuffTracker.savedVars.sortMode or "Order of debuff application"

    table.sort(debuffGroup.unitOrder, function(a, b)
        local barA = debuffGroup.bars[a]
        local barB = debuffGroup.bars[b]
        if not barA or not barB then return false end

        if mode == "Enemy name (A-Z)" then
            local nameA = barA.text:GetText() or ""
            local nameB = barB.text:GetText() or ""
            return nameA < nameB

        elseif mode == "Order of debuff application" then
            return (barA.applyOrder or 0) < (barB.applyOrder or 0)

		elseif mode == "Time remaining (ascending)" then
			local valueA = barA.bar:GetValue() or 0
			local valueB = barB.bar:GetValue() or 0
			if valueA == valueB then
				return (barA.applyOrder or 0) < (barB.applyOrder or 0)
			end
			return valueA < valueB

		elseif mode == "Time remaining (descending)" then
			local valueA = barA.bar:GetValue() or 0
			local valueB = barB.bar:GetValue() or 0
			if valueA == valueB then
				return (barA.applyOrder or 0) < (barB.applyOrder or 0)
			end
			return valueA > valueB


        else
            return tostring(a) < tostring(b)
        end
    end)
end



function DebuffTracker.ShouldHideGroup(abilityId, hasBars)
    local alwaysShow = DebuffTracker.GetSetting(abilityId, "alwaysShow")
    local onlyInCombat = DebuffTracker.GetSetting(abilityId, "onlyInCombat")
    local reminderEnabled = DebuffTracker.GetSetting(abilityId, "reminderEnabled")

    local shouldRemind = reminderEnabled
        and DebuffTracker.ReminderNeeded
        and DebuffTracker.ReminderNeeded[abilityId]
        and (not onlyInCombat or DebuffTracker.inCombat)

    if alwaysShow or DebuffTracker.isPreviewing or hasBars or shouldRemind then
        return false
    end

    return (onlyInCombat and not DebuffTracker.inCombat) or true
end

local function ArrangeDebuffGroup(abilityId)
    local debuffGroup = DebuffTrackerUI[abilityId]
    if not debuffGroup or not debuffGroup.bars then return end

    local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)

    local unitOrder = debuffGroup.unitOrder or {}
    local seen = {}
    local uniqueOrder = {}

    for _, unitId in ipairs(unitOrder) do
        if not seen[unitId] and debuffGroup.bars[unitId] then
            table.insert(uniqueOrder, unitId)
            seen[unitId] = true
        end
    end
    debuffGroup.unitOrder = uniqueOrder

    if DebuffTracker.needsSort[abilityId] then
        SortDebuffUnitOrder(abilityId)
        DebuffTracker.needsSort[abilityId] = false
    end

    local rowSpacing = cfg.rowSpacing
    local headerHeight = cfg.headerHeight
    local groupWidth = cfg.groupWidth
    local barHeight = cfg.barHeight
    local rowWidth = cfg.rowWidth or cfg.groupWidth
	local barAlpha = cfg.barAlpha or 1

    local showAbove = DebuffTracker.savedVars.showBarsAboveHeader
    local xOffset = cfg.rowPaddingX or 5
    local index = 0

    if debuffGroup.headerContainer then
        debuffGroup.headerContainer:ClearAnchors()
        debuffGroup.headerContainer:SetDimensions(groupWidth, headerHeight)
        debuffGroup.headerContainer:SetAnchor(
            showAbove and BOTTOMLEFT or TOPLEFT,
            debuffGroup.background,
            showAbove and BOTTOMLEFT or TOPLEFT,
            0, 0
        )
    end

    for _, unitId in ipairs(uniqueOrder) do
        local unitBar = debuffGroup.bars[unitId]
        if unitBar and unitBar.row and not unitBar.row:IsHidden() then
            unitBar.row:ClearAnchors()
            unitBar.row:SetDimensions(rowWidth - 5, barHeight)

            local showStacks = DebuffTracker.GetSetting(abilityId, "showStacks")
            local stacksVisible = showStacks and ShouldAbilityShowStacks(abilityId)
			
			local showTimer = DebuffTracker.GetSetting(abilityId, "showTimer")

            if unitBar.stackText then
                unitBar.stackText:SetHidden(not stacksVisible)
            end

            if showTimer then
                unitBar.timeText:SetHidden(false)
			else
				unitBar.timeText:SetHidden(true)
            end

            if unitBar.text then
				unitBar.text:SetFont("ZoFontGameSmall")
				unitBar.text:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				unitBar.text:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				
				
			end


            local y = showAbove
                and -(headerHeight + index * rowSpacing)
                or (headerHeight + index * rowSpacing)

            unitBar.row:SetAnchor(
                showAbove and BOTTOMLEFT or TOPLEFT,
                debuffGroup.window,
                showAbove and BOTTOMLEFT or TOPLEFT,
                xOffset,
                y
            )

            index = index + 1
        end
    end
	

	local totalBarHeight = index * rowSpacing
	local totalHeight = headerHeight + totalBarHeight

	debuffGroup.background:SetDimensions(groupWidth, totalHeight)
	debuffGroup.window:SetDimensions(groupWidth, totalHeight)
	debuffGroup.title:SetDimensions(groupWidth - cfg.iconSize - 8, headerHeight)
	debuffGroup.background:SetAlpha(cfg.alpha)

	local hasBars = #debuffGroup.unitOrder > 0
	local reminderEnabled = DebuffTracker.GetSetting(abilityId, "reminderEnabled")
	local onlyInCombat = DebuffTracker.GetSetting(abilityId, "onlyInCombat")
	local alpha = cfg.alpha or 1

	local shouldRemind = reminderEnabled
		and DebuffTracker.ReminderNeeded
		and DebuffTracker.ReminderNeeded[abilityId]
		and (not onlyInCombat or DebuffTracker.inCombat)

	local shouldHide = not (DebuffTracker.isPreviewing or hasBars or shouldRemind)
		and DebuffTracker.ShouldHideGroup(abilityId, hasBars)

	if DebuffTracker.isPreviewing or hasBars then
		debuffGroup.window:SetHidden(false)
		debuffGroup.background:SetAlpha(alpha)
	--[[elseif shouldRemind then
		local flicker = math.floor(GetGameTimeMilliseconds() / 500) % 2
		debuffGroup.window:SetHidden(false)
		debuffGroup.background:SetAlpha(flicker == 0 and alpha or alpha * 0.2)]]--
	else
		debuffGroup.window:SetHidden(shouldHide)
		debuffGroup.background:SetAlpha(alpha)
	end

	if debuffGroup.fragment then
		debuffGroup.fragment:SetHiddenForReason("logic", shouldHide)
	end

end

local function DebuffTracker_ClearPreviewBars()
    DebuffTracker.isPreviewing = false

    for abilityId, debuffGroup in pairs(DebuffTrackerUI) do
        if debuffGroup.fragment then
            HUD_SCENE:AddFragment(debuffGroup.fragment)
            HUD_UI_SCENE:AddFragment(debuffGroup.fragment)
			debuffGroup.window:SetHidden(true)
        end

        local removedSomething = false
        for unitId, barData in pairs(debuffGroup.bars or {}) do
            if barData.isPreview then
                barData.row:SetHidden(true)
                debuffGroup.bars[unitId] = nil
                removedSomething = true
            end
        end

        local newOrder = {}
        for unitId, barData in pairs(debuffGroup.bars or {}) do
            table.insert(newOrder, unitId)
        end
        debuffGroup.unitOrder = newOrder

        local alwaysShow = DebuffTracker.GetSetting(abilityId, "alwaysShow")
        if #newOrder == 0 and not alwaysShow then
            debuffGroup.window:SetHidden(true)
        end

        ArrangeDebuffGroup(abilityId)

    end
end

local function DebuffTracker_GeneratePreviewBars()
    DebuffTracker.isPreviewing = true

    for abilityId, debuffGroup in pairs(DebuffTrackerUI) do
        if DebuffTracker.savedVars.trackedAbilities[abilityId] then
            if debuffGroup.window then
                debuffGroup.window:SetHidden(false)
            end

            local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)
            debuffGroup.background:SetAlpha(cfg.alpha or 1)

            for unitId, barData in pairs(debuffGroup.bars or {}) do
                if barData.isPreview and barData.row then
                    barData.row:SetHidden(true)
                    barData.row:SetHandler("OnUpdate", nil)
                    debuffGroup.bars[unitId] = nil
                end
            end

            debuffGroup.unitOrder = {}
            debuffGroup.bars = debuffGroup.bars or {}

            local maxRows = DebuffTracker.GetSetting(abilityId, "maxRows") or 5
            local showStacks = DebuffTracker.GetSetting(abilityId, "showStacks") and ShouldAbilityShowStacks(abilityId)

            for i = 1, math.max(maxRows, 1) do
                local fakeUnitId = "Preview_" .. i
                local fakeUnitName = "Preview Unit " .. i
                local fakeDuration = 10
                local fakeStacks = showStacks and math.random(2, 5) or 0

                table.insert(debuffGroup.unitOrder, fakeUnitId)

                local previewRow = GetOrCreateUnitRow(
                    abilityId,
                    fakeUnitId,
                    fakeDuration,
                    fakeStacks,
                    fakeUnitName,
                    true
                )

                if previewRow then
                    previewRow.isPreview = true
                    previewRow.row:SetHidden(false)

                    if previewRow.timerBar then
                        previewRow.timerBar:SetDirection(TIMER_BAR_COUNTS_DOWN)
                        previewRow.timerBar:SetTimeFormatParameters(
                            TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS,
                            TIME_FORMAT_PRECISION_TENTHS
                        )

                        local now = GetGameTimeSeconds()
						local duration = fakeDuration
						local endTime = now + duration

						previewRow.timerBar.endsAt = endTime
						previewRow.timerBar:Start(now, endTime)
						previewRow.timerBar.control:SetHidden(false)
						previewRow.status:SetHidden(false)

						previewRow.row:SetHandler("OnUpdate", function()
							local now = GetGameTimeSeconds()
							local endsAt = previewRow.timerBar.endsAt
							if endsAt and now >= endsAt then
								local newNow = GetGameTimeSeconds()
								local newEnd = newNow + duration
								previewRow.timerBar.endsAt = newEnd
								previewRow.timerBar:Start(newNow, newEnd)
							end
						end)

                    end
                end
            end

            ArrangeDebuffGroup(abilityId)
        end
    end
end



local function RemoveUnitRowFromGroup(abilityId, unitId)
    local debuffGroup = DebuffTrackerUI[abilityId]
    if not debuffGroup or not debuffGroup.bars[unitId] then return end

    local barData = debuffGroup.bars[unitId]

    if barData.row and barData.poolKey then
        DebuffTracker.rowPool:ReleaseObject(barData.poolKey)
    end

    debuffGroup.bars[unitId] = nil
    DebuffTracker.needsSort[abilityId] = true

    for i, id in ipairs(debuffGroup.unitOrder or {}) do
        if id == unitId then
            table.remove(debuffGroup.unitOrder, i)
            break
        end
    end

    ArrangeDebuffGroup(abilityId)
end

function DebuffTracker.GetCurrentlyTrackedAbilities()
    local output = {}
    if not DebuffTracker.savedVars then return output end

    local settings = DebuffTracker.savedVars.accountWide and DebuffTracker.savedVars or 
                     DebuffTracker.savedVars[GetUnitName("player")]

    if not settings then return output end

    if settings.trackedAbilities then
		for abilityId, isTracked in pairs(settings.trackedAbilities) do
			if isTracked then
				output[abilityId] = true
			end
		end
	end

	--[[if settings.customAbilities then
		for _, customId in ipairs(settings.customAbilities) do
			output[customId] = true
		end
	end]]--


    return output
end

function DebuffTracker.GetNormalizedAbilityId(abilityId)
	local commonDebuffs = DebuffTracker.GetCommonDebuffs()
	local mergedCopies = ZO_ShallowTableCopy(commonDebuffs.abilityCopies)

	for originalId, customList in pairs(DebuffTracker.savedVars.customAbilityCopies or {}) do
		mergedCopies[originalId] = mergedCopies[originalId] or {}
		for _, customCopyId in ipairs(customList) do
			table.insert(mergedCopies[originalId], customCopyId)
		end
	end

	for originalId, copies in pairs(mergedCopies) do
		for _, copyId in ipairs(copies) do
			if abilityId == copyId then
				return originalId
			end
		end
	end

	return abilityId
end


function DebuffTracker.ShouldTrackAbility(abilityId)
    if not DebuffTracker.savedVars then return false end

    local settings = DebuffTracker.savedVars.accountWide and DebuffTracker.savedVars or 
                     DebuffTracker.savedVars[GetUnitName("player")]

    if not settings or not settings.trackedAbilities then return false end

    if settings.trackedAbilities[abilityId] then
        return true
    end

    local normalizedId = DebuffTracker.GetNormalizedAbilityId(abilityId)
    if settings.trackedAbilities[normalizedId] then
        return true
    end

    if settings.customAbilities then
        for _, customId in ipairs(settings.customAbilities) do
            if tonumber(customId) == tonumber(abilityId) and settings.trackedAbilities[abilityId] then
                return true
            end
        end
    end

    return false
end




function DebuffTracker.CleanupUnitDebuffs(unitId)
    if not DebuffTracker.debuffData[unitId] then return end

    for abilityId, _ in pairs(DebuffTracker.debuffData[unitId]) do
        RemoveUnitRowFromGroup(abilityId, unitId)
        ArrangeDebuffGroup(abilityId)
    end
    DebuffTracker.debuffData[unitId] = nil
    DebuffTracker.affectedUnits[unitId] = nil
end






function DebuffTracker.OnUnitDeath(_, result, _, _, _, _, _, _, targetName, targetType, _, _, _, _, _, targetUnitId, _)
    if not DebuffTracker.affectedUnits[targetUnitId] then return end

    DebuffTracker.CleanupUnitDebuffs(targetUnitId)
end

local activeTargetRows = {}

local function SetRowHighlight(row, isHighlighted)
    if not row then return end

    local rowName = row:GetName()
    local bg = row:GetNamedChild("Bg")
    if not bg or not bg.SetEdgeColor then return end

    local alreadyHighlighted = DebuffTracker.highlightedRows[rowName] or false

    if isHighlighted and not alreadyHighlighted then
        bg:SetEdgeColor(1, 1, 0, 1)
        DebuffTracker.highlightedRows[rowName] = true
    elseif not isHighlighted and alreadyHighlighted then
        bg:SetEdgeColor(0, 0, 0, 0)
        DebuffTracker.highlightedRows[rowName] = false
    end
end

local function OnTargetChanged()
    for _, row in ipairs(activeTargetRows) do
        SetRowHighlight(row, false)
    end
    activeTargetRows = {}

    if not DoesUnitExist("reticleover") then return end

    local unitTag = "reticleover"
    local reaction = GetUnitReaction(unitTag)
    if reaction ~= UNIT_REACTION_HOSTILE then return end

    local difficulty = GetUnitDifficulty(unitTag)
    local unitName = zo_strformat("<<!aC:1>>", GetUnitName(unitTag))
    local zoneId = DebuffTracker.currentZoneId

    if trialZones[zoneId] then
        DebuffTracker.dynamicDifficultyData[zoneId] = DebuffTracker.dynamicDifficultyData[zoneId] or {}
        if not DebuffTracker.dynamicDifficultyData[zoneId][unitName] then
            DebuffTracker.dynamicDifficultyData[zoneId][unitName] = difficulty
            DebuffTracker.needsSave = true
        end
    end

    if not next(DebuffTracker.debuffData) then return end

	for i = 1, GetNumBuffs(unitTag) do
		local _, beginTime, endTime, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
		local normalizedAbilityId = DebuffTracker.GetNormalizedAbilityId(abilityId)

		local fingerprintKey = string.format("%d|%.3f|%.3f|%d", normalizedAbilityId, beginTime, endTime, stackCount)
		local matchedUnitId = DebuffTracker.effectFingerprintLookup and DebuffTracker.effectFingerprintLookup[fingerprintKey]

		if matchedUnitId then
			local debuffGroup = DebuffTrackerUI[normalizedAbilityId]
			local barData = debuffGroup and debuffGroup.bars and debuffGroup.bars[matchedUnitId]

			if DebuffTracker.GetSetting(normalizedAbilityId, "HighlightTarget") and barData and barData.row then
				SetRowHighlight(barData.row, true)
				table.insert(activeTargetRows, barData.row)
			end
		end
	end

end

function DebuffTracker.GetEnemyDifficulty(unitName)
    local formattedName = zo_strformat("<<!aC:1>>", unitName)
    local zoneId = DebuffTracker.currentZoneId or 0
    local data = DebuffTracker.dynamicDifficultyData[zoneId]
    if data then
        return data[formattedName] or 0
    end
    return 0
end

local uptimeData = {}

function DebuffTracker.Uptime.RestoreFromDebuffData()
    local now = GetGameTimeSeconds()
    local combatStart = DebuffTracker.Uptime.combatStart or now
    for unitId, abilityMap in pairs(DebuffTracker.debuffData) do
        for abilityId, data in pairs(abilityMap) do
            if uptimeData[abilityId] and data.endTime > now then
                local buffWasActiveAtCombatStart = data.startTime <= combatStart and data.endTime > combatStart
                if buffWasActiveAtCombatStart then
                    local uptime = uptimeData[abilityId]
                    if uptime.activeUnits[unitId] ~= true then
                        uptime.activeUnits[unitId] = true
                        uptime.activeUnitCount = uptime.activeUnitCount + 1
                        if uptime.activeUnitCount == 1 then
                            uptime.lastStartTime = combatStart
                        end
                    end
                end
            end
        end
    end
end

function DebuffTracker.Uptime.BeginCombat()
    DebuffTracker.Uptime.combatStart = GetGameTimeSeconds()

    for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
        if isTracked and not uptimeData[abilityId] then
            DebuffTracker.Uptime.TrackAbility(abilityId)
        end
    end

    DebuffTracker.Uptime.RestoreFromDebuffData()
end

function DebuffTracker.Uptime.GetLiveUptimePercent(abilityId)
    if not DebuffTracker.Uptime.combatStart then return 0 end

    local now = GetGameTimeSeconds()
    local data = uptimeData[abilityId]
    if not data then return 0 end

    local combatDuration = now - DebuffTracker.Uptime.combatStart
    if combatDuration <= 0 then return 0 end

    local activeUptime = data.totalUptime

    if data.activeUnitCount > 0 and data.lastStartTime then
        local buffStart = math.max(data.lastStartTime, DebuffTracker.Uptime.combatStart)
        activeUptime = activeUptime + (now - buffStart)
    end

    local percent = (activeUptime / combatDuration) * 100
    return percent
end

function DebuffTracker.Uptime.EndCombat()
    local combatEnd = GetGameTimeSeconds()

    for abilityId, data in pairs(uptimeData) do
        if data.activeUnitCount > 0 and data.lastStartTime then
            data.totalUptime = data.totalUptime + (combatEnd - math.max(data.lastStartTime, DebuffTracker.Uptime.combatStart or combatEnd))
        end
    end

    uptimeData = {}

    DebuffTracker.effectFingerprintLookup = {}
    DebuffTracker.endTimeLookup = {}

    DebuffTracker.Uptime.combatStart = nil
end

function DebuffTracker.Uptime.TrackAbility(abilityId)
    if uptimeData[abilityId] then return end
    uptimeData[abilityId] = {
        totalUptime = 0,
        activeUnits = {},
        activeUnitCount = 0,
        lastStartTime = nil,
    }
end

function DebuffTracker.Uptime.OnEffectGained(abilityId, unitId)
    local data = uptimeData[abilityId]
    if not data or data.activeUnits[unitId] then return end

    data.activeUnits[unitId] = true
    data.activeUnitCount = data.activeUnitCount + 1

    if data.activeUnitCount == 1 then
        data.lastStartTime = GetGameTimeSeconds()
    end
end

function DebuffTracker.Uptime.OnEffectUpdated(abilityId, unitId)
    local data = uptimeData[abilityId]
    if not data then return end

    if not data.activeUnits[unitId] then
        DebuffTracker.Uptime.OnEffectGained(abilityId, unitId)
    end
end

function DebuffTracker.Uptime.GetTrackedAbilities()
    local tracked = {}
    for abilityId in pairs(uptimeData) do
        tracked[abilityId] = true
    end
    return tracked
end

function DebuffTracker.Uptime.OnEffectFaded(abilityId, unitId)
    local data = uptimeData[abilityId]
    if not data or not data.activeUnits[unitId] then return end

    data.activeUnits[unitId] = nil
    data.activeUnitCount = data.activeUnitCount - 1

    if data.activeUnitCount == 0 and data.lastStartTime then
        local now = GetGameTimeSeconds()
        data.totalUptime = data.totalUptime + (now - data.lastStartTime)
        data.lastStartTime = nil
    end
end

local function ShouldTrackEffect(normalizedId, unitTag, sourceType, effectType)
    if not DebuffTracker.ShouldTrackAbility(normalizedId) then return false end
    if DebuffTracker.GetSetting(normalizedId, "trackEffectsCastByYouOnly") and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return false end
    if DebuffTracker.GetSetting(normalizedId, "trackEffectsCastToYouOnly") and unitTag ~= "player" then return false end
    if DebuffTracker.GetSetting(normalizedId, "trackDebuffsOnly") and effectType ~= BUFF_EFFECT_TYPE_DEBUFF then return false end
    return true
end

local function StoreEffectData(normalizedId, unitId, beginTime, endTime, stackCount, unitName)
    DebuffTracker.debuffData[unitId] = DebuffTracker.debuffData[unitId] or {}
    DebuffTracker.applyCounter = (DebuffTracker.applyCounter or 0) + 1

    DebuffTracker.debuffData[unitId][normalizedId] = {
        startTime = beginTime,
        endTime = endTime,
        stacks = stackCount,
        unitName = unitName,
        applyOrder = DebuffTracker.applyCounter,
    }

    DebuffTracker.affectedUnits[unitId] = true
    DebuffTracker.needsSort[normalizedId] = true
end

local function CleanupEffectData(normalizedId, unitId)
    if DebuffTracker.debuffData[unitId] then
        DebuffTracker.debuffData[unitId][normalizedId] = nil
        if next(DebuffTracker.debuffData[unitId]) == nil then
            DebuffTracker.debuffData[unitId] = nil
        end
    end
end

local function ShouldDisplayNow(normalizedId)
    return not DebuffTracker.GetSetting(normalizedId, "onlyInCombat") or DebuffTracker.inCombat
end

local function ShouldBlinkReminder(normalizedId)
    if not DebuffTracker.GetSetting(normalizedId, "reminderEnabled") then return false end
    if DebuffTracker.GetSetting(normalizedId, "onlyInCombat") then
        return DebuffTracker.inCombat
    end
    return true
end

function DebuffTracker.Uptime.HasTracked(abilityId)
    return uptimeData[abilityId] ~= nil
end

function DebuffTracker.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local normalizedId = DebuffTracker.GetNormalizedAbilityId(abilityId)
    if not DebuffTracker.IsAbilityTracked(normalizedId) then return end
    if not ShouldTrackEffect(normalizedId, unitTag, sourceType, effectType) then return end

    unitName = (unitTag and (unitTag == "player" or string.sub(unitTag, 1, 5) == "group"))
        and GetUnitDisplayName(unitTag)
        or zo_strformat("<<!aC:1>>", unitName)

    local isFriendly = unitTag == "player"
        or (unitTag and (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 3) == "pet"))
        or (unitTag and GetUnitReaction(unitTag) == UNIT_REACTION_FRIENDLY)

    if not isFriendly and trialZones[DebuffTracker.currentZoneId] then
        if not unitTag or GetUnitReaction(unitTag) ~= UNIT_REACTION_HOSTILE
            or DebuffTracker.GetEnemyDifficulty(unitName) < (DebuffTracker.savedVars.minimumDifficulty or 0) then
            return
        end
    end

    local fingerprintKey = string.format("%d|%.3f|%.3f|%d", normalizedId, beginTime, endTime, stackCount)
    DebuffTracker.effectFingerprintLookup[fingerprintKey] = unitId

    --------------------------------------------------
    --  GAINED / REFRESH
    --------------------------------------------------
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FULL_REFRESH then
		if DebuffTracker.GetSetting(normalizedId, "trackEffectsCastByYouOnly") and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
			DebuffTracker.debuffData[unitId] = DebuffTracker.debuffData[unitId] or {}
			DebuffTracker.debuffData[unitId][normalizedId] = nil
			RemoveUnitRowFromGroup(normalizedId, unitId)
			ArrangeDebuffGroup(normalizedId)
			return
		end

		if not DebuffTracker.Uptime.HasTracked(normalizedId) then
			DebuffTracker.Uptime.TrackAbility(normalizedId)
		end

		if DebuffTracker.inCombat then
			DebuffTracker.Uptime.OnEffectGained(normalizedId, unitId)
		end


		DebuffTracker.pendingRemove = DebuffTracker.pendingRemove or {}
		if DebuffTracker.pendingRemove[unitId] then
			DebuffTracker.pendingRemove[unitId][normalizedId] = nil
			if next(DebuffTracker.pendingRemove[unitId]) == nil then
				DebuffTracker.pendingRemove[unitId] = nil
			end
		end

		StoreEffectData(normalizedId, unitId, beginTime, endTime, stackCount, unitName)

		if DebuffTracker.pendingFade and DebuffTracker.pendingFade[unitId] then
			DebuffTracker.pendingFade[unitId][normalizedId] = nil
		end

		DebuffTracker.endTimeLookup[endTime] = unitId


    --------------------------------------------------
    --  UPDATED
    --------------------------------------------------
    elseif changeType == EFFECT_RESULT_UPDATED then
        local entry = DebuffTracker.debuffData[unitId] and DebuffTracker.debuffData[unitId][normalizedId]
        if entry then
            entry.startTime = beginTime
            entry.endTime = endTime
            entry.stacks = stackCount
            entry.unitName = unitName
            DebuffTracker.Uptime.OnEffectUpdated(normalizedId, unitId)
        end

        DebuffTracker.effectFingerprintLookup[fingerprintKey] = unitId
        DebuffTracker.endTimeLookup[endTime] = unitId

        DebuffTracker.pendingRemove = DebuffTracker.pendingRemove or {}
        if DebuffTracker.pendingRemove[unitId] then
            DebuffTracker.pendingRemove[unitId][normalizedId] = nil
            if next(DebuffTracker.pendingRemove[unitId]) == nil then
                DebuffTracker.pendingRemove[unitId] = nil
            end
        end

    --------------------------------------------------
    --  FADED
    --------------------------------------------------
    elseif changeType == EFFECT_RESULT_FADED then
        DebuffTracker.pendingFade = DebuffTracker.pendingFade or {}
        DebuffTracker.pendingFade[unitId] = DebuffTracker.pendingFade[unitId] or {}
        DebuffTracker.pendingFade[unitId][normalizedId] = true
        DebuffTracker.Uptime.OnEffectFaded(normalizedId, unitId)

        DebuffTracker.endTimeLookup[endTime] = nil

        DebuffTracker.pendingRemove = DebuffTracker.pendingRemove or {}
        DebuffTracker.pendingRemove[unitId] = DebuffTracker.pendingRemove[unitId] or {}
        DebuffTracker.pendingRemove[unitId][normalizedId] = true

        zo_callLater(function()
            if DebuffTracker.pendingRemove
                and DebuffTracker.pendingRemove[unitId]
                and DebuffTracker.pendingRemove[unitId][normalizedId] then

                RemoveUnitRowFromGroup(normalizedId, unitId)
                CleanupEffectData(normalizedId, unitId)

                DebuffTracker.pendingRemove[unitId][normalizedId] = nil
                if next(DebuffTracker.pendingRemove[unitId]) == nil then
                    DebuffTracker.pendingRemove[unitId] = nil
                end

                if not DebuffTracker.isCombatFading then
					ArrangeDebuffGroup(normalizedId)
				end

            end
        end, 250)
    end
end


function DebuffTracker.ShouldContinueTrackingAfterCombat(abilityId)
    return not DebuffTracker.GetSetting(abilityId, "onlyInCombat")
end

local function HasActiveDebuffs()
    for unitId, effects in pairs(DebuffTracker.debuffData) do
        for abilityId, data in pairs(effects) do
            if DebuffTracker.IsAbilityTracked(abilityId) and (data.endTime - GetGameTimeSeconds()) > 0 then
                return true
            end
        end
    end
    return false
end

local function CollectActiveDebuffs()
    local currentTime = GetGameTimeSeconds()
    local debuffGroups = {}

    for unitId, debuffs in pairs(DebuffTracker.debuffData) do
        for abilityId, data in pairs(debuffs) do
            local shouldTrack = DebuffTracker.inCombat or DebuffTracker.ShouldContinueTrackingAfterCombat(abilityId)
            if shouldTrack then
                local timeRemaining = data.endTime - currentTime
                if timeRemaining > 0 then
                    debuffGroups[abilityId] = debuffGroups[abilityId] or {}
                    table.insert(debuffGroups[abilityId], {
                        unitId = unitId,
                        timeRemaining = timeRemaining,
                        totalDuration = data.endTime - (data.startTime or 0),
                        stacks = data.stacks,
                        unitName = data.unitName,
                        applyOrder = data.applyOrder
                    })
                elseif not DebuffTracker.pendingFade or not DebuffTracker.pendingFade[unitId] or not DebuffTracker.pendingFade[unitId][abilityId] then
                    RemoveUnitRowFromGroup(abilityId, unitId)
                end
            end
        end
    end

    return debuffGroups
end

local function RenderDebuffRows(debuffGroups)
    for abilityId, units in pairs(debuffGroups) do
        local maxRows = DebuffTracker.GetSetting(abilityId, "maxRows") or 10
        local useGradient = DebuffTracker.GetSetting(abilityId, "useGradientBarColor") ~= false
        local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)
        local barAlpha = cfg.barAlpha or 1

        local decimalNum = tonumber(DebuffTracker.GetSetting(abilityId, "decimalNum")) or 0

        table.sort(units, function(a, b)
            if a.timeRemaining == b.timeRemaining then
                return (a.applyOrder or 0) < (b.applyOrder or 0)
            end
            return a.timeRemaining < b.timeRemaining
        end)

        for i, unitData in ipairs(units) do
            if unitData.timeRemaining <= 0.11 or unitData.endTime <= GetGameTimeSeconds() then
                RemoveUnitRowFromGroup(abilityId, unitData.unitId)

            elseif i <= maxRows then
                local wasNew = false
                local bar = GetOrCreateUnitRow(
                    abilityId,
                    unitData.unitId,
                    unitData.totalDuration,
                    unitData.stacks,
                    unitData.unitName,
                    true,
                    function() wasNew = true end
                )
                if wasNew then
                    DebuffTracker.needsSort[abilityId] = true
                end

                local alpha = 1
                if DebuffTracker.savedVars.BarBlink and unitData.timeRemaining <= 2 then
                    local flicker = math.floor(GetGameTimeMilliseconds() / 200) % 2
                    alpha = (flicker == 0) and 1 or 0
                end

                local timerBar = bar.timerBar
                if timerBar then
                    local existingEnd = timerBar.ends or 0
                    local newEnd = unitData.endTime
                    local needsRestart = not timerBar:IsStarted() or math.abs(existingEnd - newEnd) > 0.05

                    if needsRestart then
                        timerBar:Stop()
                        timerBar:SetDirection(TIMER_BAR_COUNTS_DOWN)
                        timerBar:SetTimeFormatParameters(
                            TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS,
                            TIME_FORMAT_PRECISION_TENTHS
                        )
                        timerBar:Start(GetGameTimeSeconds(), newEnd)
                    end

                    timerBar.barUpdateInterval = 0
                    timerBar.nextLabelUpdate = 0
                    timerBar.control:SetAlpha(alpha)
                    timerBar.control:SetHidden(false)

                    local overrideTime = math.max(0, unitData.endTime - GetGameTimeSeconds())
                    local timerText = bar.timeText
                    if timerText then
                        if decimalNum == 0 then
                            timerText:SetText(string.format("%d", math.floor(overrideTime)))
                        else
                            timerText:SetText(string.format("%." .. decimalNum .. "f", overrideTime))
                        end
                    end
                end

                if bar.bar then
                    bar.bar:SetHidden(true)
                end

                if bar.stackText then
                    bar.stackText:SetText(
                        DebuffTracker.GetSetting(abilityId, "showStacks") and
                        (unitData.stacks > 1 and "x" .. unitData.stacks or "") or ""
                    )
                end

                if timerBar then
                    local timeLeft = unitData.endTime - GetGameTimeSeconds()
                    local progress = timeLeft / unitData.totalDuration
                    local r, g, b = 1, 0, 0
                    if useGradient then
                        r = 1 - progress
                        g = progress
                        b = 0
                    elseif progress > 0.66 then
                        r, g, b = 0, 1, 0
                    elseif progress > 0.33 then
                        r, g, b = 1, 0.65, 0
                    end
                    timerBar.status:SetColor(r, g, b, 1)
                end
            else
                RemoveUnitRowFromGroup(abilityId, unitData.unitId)
            end
        end
    end
end

local function UpdateGroupVisibility(debuffGroups)
    for abilityId, groupUI in pairs(DebuffTrackerUI) do
        
		ArrangeDebuffGroup(abilityId)

		local reminderEnabled = DebuffTracker.GetSetting(abilityId, "reminderEnabled")
		local alwaysShow = DebuffTracker.GetSetting(abilityId, "alwaysShow")
		local onlyInCombat = DebuffTracker.GetSetting(abilityId, "onlyInCombat")
		local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)
		local alpha = cfg.alpha or 1
		local inPreview = DebuffTracker.isPreviewing

		local hasBars = groupUI.unitOrder and #groupUI.unitOrder > 0
		local shouldRemind = reminderEnabled
			and DebuffTracker.ReminderNeeded
			and DebuffTracker.ReminderNeeded[abilityId]
			and (not onlyInCombat or DebuffTracker.inCombat)

		if hasBars or inPreview then
			groupUI.window:SetHidden(false)
			groupUI.background:SetAlpha(alpha)
			if groupUI.fragment then
				groupUI.fragment:SetHiddenForReason("logic", false)
			end

		elseif shouldRemind then
			local flicker = math.floor(GetGameTimeMilliseconds() / 500) % 2
			local flickerAlpha = (flicker == 0 and alpha or alpha * 0.2)
			groupUI.window:SetHidden(false)
			groupUI.background:SetAlpha(flickerAlpha)
			if groupUI.fragment then
				groupUI.fragment:SetHiddenForReason("logic", false)
			end

		else
			local shouldHide = DebuffTracker.ShouldHideGroup(abilityId, hasBars)



			groupUI.window:SetHidden(shouldHide)
			groupUI.background:SetAlpha(alpha)
			if groupUI.fragment then
				groupUI.fragment:SetHiddenForReason("logic", shouldHide)
			end
		end
        
    end
end

local function DebuffTracker_ToggleUI()
    toggled = not toggled
    DebuffTracker.uiUnlocked = toggled

    for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
        if isTracked and not DebuffTrackerUI[abilityId] then
            GetOrCreateDebuffGroup(abilityId)
        end
    end

    if DebuffTracker.isPreviewing then
        DebuffTracker_ClearPreviewBars()
    end

    if toggled then
        DebuffTracker_GeneratePreviewBars()
    end

    local activeDebuffs = DebuffTracker.isPreviewing and {} or CollectActiveDebuffs()
	UpdateGroupVisibility(activeDebuffs)

end

local function UpdatePrimaryTargetStacks()
    for _, group in pairs(DebuffTrackerUI) do
        if group.headerStackLabel then group.headerStackLabel:SetHidden(true) end
    end

    if not DoesUnitExist("reticleover") then return end

    for i = 1, GetNumBuffs("reticleover") do
        local _, beginTime, endTime, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
        local normalizedId = DebuffTracker.GetNormalizedAbilityId(abilityId)

        if DebuffTracker.GetSetting(normalizedId, "showStacksOnPrimaryOnly") and stackCount > 1 then
            local groupUI = DebuffTrackerUI[normalizedId]
            if groupUI then
                if not groupUI.headerStackLabel then
                    groupUI.headerStackLabel = WINDOW_MANAGER:CreateControl(nil, groupUI.headerContainer, CT_LABEL)
                    groupUI.headerStackLabel:SetFont("ZoFontGameSmall")
                    groupUI.headerStackLabel:SetAnchor(RIGHT, groupUI.headerContainer, RIGHT, -4, 2)
                    groupUI.headerStackLabel:SetColor(1, 1, 1, 1)
                end
                groupUI.headerStackLabel:SetText(string.format("x%d", stackCount))
                groupUI.headerStackLabel:SetHidden(false)
            end
        end
    end
end

local function FinalBarCleanup(debuffGroups)
    for abilityId, group in pairs(DebuffTrackerUI) do
        local validUnits = {}
        if debuffGroups[abilityId] then
            for _, unitData in ipairs(debuffGroups[abilityId]) do
                validUnits[unitData.unitId] = true
            end
        end

        for unitId, _ in pairs(group.bars) do
            if not validUnits[unitId] then
                RemoveUnitRowFromGroup(abilityId, unitId)
            end
        end

        ArrangeDebuffGroup(abilityId)
    end
end

function DebuffTracker.TrackBuffs()
    local hasReminders = next(DebuffTracker.ReminderNeeded) ~= nil
	


    if not SCENE_MANAGER:IsShowingBaseScene() then return end

    DebuffTracker.ReminderNeeded = DebuffTracker.ReminderNeeded or {}
    local currentTime = GetGameTimeSeconds()
    local debuffGroups = {}

    for unitId, effects in pairs(DebuffTracker.debuffData) do
        for abilityId, data in pairs(effects) do
            if DebuffTracker.IsAbilityTracked(abilityId) then
                local shouldTrack = DebuffTracker.inCombat or DebuffTracker.ShouldContinueTrackingAfterCombat(abilityId) or DebuffTracker.GetSetting(abilityId, "alwaysShow")
                local timeRemaining = data.endTime - currentTime

                if shouldTrack and timeRemaining > 0 then
                    debuffGroups[abilityId] = debuffGroups[abilityId] or {}
                    table.insert(debuffGroups[abilityId], {
						unitId = unitId,
						timeRemaining = timeRemaining,
						totalDuration = data.endTime - (data.startTime or 0),
						stacks = data.stacks,
						unitName = data.unitName,
						applyOrder = data.applyOrder,
						endTime = data.endTime,
					})
                elseif not DebuffTracker.pendingFade or not DebuffTracker.pendingFade[unitId] or not DebuffTracker.pendingFade[unitId][abilityId] then
					local bar = DebuffTrackerUI[abilityId] and DebuffTrackerUI[abilityId].bars[unitId]
					if bar and bar.timerBar then
						bar.timerBar:Stop()
					end
					RemoveUnitRowFromGroup(abilityId, unitId)
				end

            end
        end
    end

    RenderDebuffRows(debuffGroups)

	for abilityId in pairs(DebuffTracker.Uptime.GetTrackedAbilities()) do
		if DebuffTrackerUI[abilityId] and DebuffTracker.GetSetting(abilityId, "ShowUptime") then
			local uptime = DebuffTracker.Uptime.GetLiveUptimePercent(abilityId)
			if uptime > 100 then uptime = 100 end

			local customTitle = DebuffTracker.savedVars.customTitles and DebuffTracker.savedVars.customTitles[abilityId]
			local title = customTitle or GetAbilityName(abilityId)
			local uptimeValue = DebuffTracker.FormatNumber(abilityId, uptime)

			local label = title
			if uptimeValue and uptimeValue ~= "" then
				label = string.format("%s - %s%%", title, uptimeValue)
			end

			DebuffTrackerUI[abilityId].title:SetText(label)
		end
	end
    UpdatePrimaryTargetStacks()
    FinalBarCleanup(debuffGroups)
    UpdateGroupVisibility(debuffGroups)
end



local toggled = false

function DebuffTracker.ShouldTrackOnlyInCombat()
    for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
        if isTracked and not DebuffTracker.GetSetting(abilityId, "onlyInCombat") then
            return false
        end
    end
    return true
end


local function BuildReminderNeeds()
    local reminderNeeded = {}
	return reminderNeeded

    --[[for abilityId in pairs(DebuffTracker.savedVars.trackedAbilities) do
        if DebuffTracker.ShouldTrackAbility(abilityId) and DebuffTracker.GetSetting(abilityId, "reminderEnabled") then
            local setIds = SetAbilityTracker.GetSetIdsForAbility(abilityId)
            local needsReminder = false

            if setIds and #setIds > 0 then
                for _, setId in ipairs(setIds) do
                    if SetAbilityTracker.IsSetEquipped(setId) then
                        needsReminder = true
                        break
                    end
                end
            else
                local isActive = false
                for _, debuffs in pairs(DebuffTracker.debuffData) do
                    if debuffs[abilityId] then
                        isActive = true
                        break
                    end
                end
                needsReminder = not isActive
            end

            if needsReminder then
				reminderNeeded[abilityId] = true
				if not DebuffTrackerUI[abilityId] then
					GetOrCreateDebuffGroup(abilityId)
					ArrangeDebuffGroup(abilityId)
				end
			end

        end
    end

    return reminderNeeded ]]--
end

function DebuffTracker.OnCombatStateChanged(_, inCombat)
    DebuffTracker.inCombat = inCombat

    if inCombat then
        DebuffTracker.isCombatFading = false
        DebuffTracker.Uptime.BeginCombat()

        -- Restore saved labels from last combat
        if DebuffTracker.lastLabels then
            for abilityId, group in pairs(DebuffTrackerUI) do
                if DebuffTracker.IsAbilityTracked(abilityId) and group.title then
                    local savedLabel = DebuffTracker.lastLabels[abilityId]
                    if savedLabel then
                        group.title:SetText(savedLabel)
                    end
                end
            end
        end

        for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
            if isTracked and not DebuffTracker.Uptime.HasTracked(abilityId) then
                DebuffTracker.Uptime.TrackAbility(abilityId)
            end
        end

        if DebuffTracker.uiUnlocked then
            DebuffTracker_ToggleUI()
            d("[DebuffTracker] UI locked automatically on combat start.")
        end

        DebuffTracker.ReminderNeeded = BuildReminderNeeds()

        if DebuffTracker.ShouldTrackOnlyInCombat() or not DebuffTracker.isTracking then
            DebuffTracker.isTracking = true
            EVENT_MANAGER:RegisterForUpdate(DebuffTracker.name .. "_BuffTracker", 100, DebuffTracker.TrackBuffs)
        end

        if DebuffTracker.ShouldTrackOnlyInCombat() then
            DebuffTracker.rowPool:ReleaseAllObjects()
        end

    else
        DebuffTracker.isCombatFading = true

        DebuffTracker.lastLabels = {}
        for abilityId, group in pairs(DebuffTrackerUI) do
            if group.title then
                DebuffTracker.lastLabels[abilityId] = group.title:GetText()
            end
        end

        DebuffTracker.Uptime.EndCombat()

        DebuffTracker.needsSort = {}
        DebuffTracker.enemyDifficultyCache = {}

        zo_callLater(function()
            local now = GetGameTimeMilliseconds()
            local validIds = {}

            for _, item in pairs(DebuffTracker.rowPool:GetActiveObjects()) do
                local unitId = item.unitId or (item.data and item.data.unitId) or item.id
                local endTime = item.endTime or (item.data and item.data.endTime) or 0
                if endTime - now > -5000 then
                    validIds[unitId] = true
                end
            end

            for abilityId, group in pairs(DebuffTrackerUI) do
                if DebuffTracker.IsAbilityTracked(abilityId) then
                    local shouldTrackOutOfCombat = DebuffTracker.ShouldContinueTrackingAfterCombat(abilityId)
                    for unitId in pairs(group.bars) do
                        if not validIds[unitId] or not shouldTrackOutOfCombat then
                            RemoveUnitRowFromGroup(abilityId, unitId)
                        end
                    end
                end
            end

            for abilityId in pairs(DebuffTrackerUI) do
                if DebuffTracker.IsAbilityTracked(abilityId) then
                    ArrangeDebuffGroup(abilityId)
                end
            end

            if DebuffTracker.ShouldTrackOnlyInCombat() then
                EVENT_MANAGER:UnregisterForUpdate(DebuffTracker.name .. "_BuffTracker")
                DebuffTracker.isTracking = false
                DebuffTracker.affectedUnits = {}
                DebuffTracker.debuffData = {}
                DebuffTracker.rowPool:ReleaseAllObjects()
                DebuffTracker.ReminderNeeded = {}
            end

            DebuffTracker.isCombatFading = false
        end, 500)
    end
end


function DebuffTracker.SaveProfile(name)
	if not name or name == "" then
		d("[DebuffTracker] Error: Cannot save profile with empty name.")
		return
	end

	DebuffTracker.savedVars.profiles = DebuffTracker.savedVars.profiles or {}

	local folder = "Uncategorized"
	if DebuffTracker.savedVars.profiles[name] and DebuffTracker.savedVars.profiles[name].folder then
		folder = DebuffTracker.savedVars.profiles[name].folder
	end

	local profileData = {
		folder                   = folder,
		timestamp                = GetTimeStamp(),
		version                  = DebuffTracker.PROFILE_VERSION or 1,
		trackedAbilities         = ZO_DeepTableCopy(DebuffTracker.savedVars.trackedAbilities or {}),
		--customAbilities          = ZO_DeepTableCopy(DebuffTracker.savedVars.customAbilities or {}),
		customTitles             = ZO_DeepTableCopy(DebuffTracker.savedVars.customTitles or {}),
		customAbilityCopies      = ZO_DeepTableCopy(DebuffTracker.savedVars.customAbilityCopies or {}),
		reminderEnabled          = ZO_DeepTableCopy(DebuffTracker.savedVars.reminderEnabled or {}),
		abilitySettings          = ZO_DeepTableCopy(DebuffTracker.savedVars.abilitySettings or {}),
		positions                = ZO_DeepTableCopy(DebuffTracker.savedVars.positions or {}),

		-- General settings
		accountWide              = DebuffTracker.savedVars.accountWide,
		trackDebuffsOnly         = DebuffTracker.savedVars.trackDebuffsOnly,
		trackEffectsCastByYouOnly= DebuffTracker.savedVars.trackEffectsCastByYouOnly,
		trackEffectsCastToYouOnly= DebuffTracker.savedVars.trackEffectsCastToYouOnly,
		HighlightTarget          = DebuffTracker.savedVars.HighlightTarget,
		ShowUptime               = DebuffTracker.savedVars.ShowUptime,
		BarBlink                 = DebuffTracker.savedVars.BarBlink,
		useGradientBarColor      = DebuffTracker.savedVars.useGradientBarColor,
		alwaysShow               = DebuffTracker.savedVars.alwaysShow,
		decimalNum               = DebuffTracker.savedVars.decimalNum,
		barTexture               = DebuffTracker.savedVars.barTexture,
		sortMode                 = DebuffTracker.savedVars.sortMode,
		minimumDifficulty        = DebuffTracker.savedVars.minimumDifficulty,
		maxRows                  = DebuffTracker.savedVars.maxRows,
		showBarsAboveHeader      = DebuffTracker.savedVars.showBarsAboveHeader,

		-- Marker
		showMarker               = DebuffTracker.savedVars.showMarker,
		markerSize               = DebuffTracker.savedVars.markerSize,
		markerSizeToggleEnabled  = DebuffTracker.savedVars.markerSizeToggleEnabled,

		-- UI settings
		ui                       = ZO_DeepTableCopy(DebuffTracker.savedVars.ui or {}),
	}

	DebuffTracker.savedVars.profiles[name] = profileData
	DebuffTracker.savedVars.currentProfile = name
	d(string.format("[DebuffTracker] Profile '%s' saved successfully at %s.", name, os.date("%Y-%m-%d %H:%M:%S", profileData.timestamp)))
end

function DebuffTracker.DeleteProfile(name)
    if not DebuffTracker.savedVars.profiles or not DebuffTracker.savedVars.profiles[name] then
        d("[DebuffTracker] ERROR: Profile '" .. name .. "' not found!")
        return
    end

    DebuffTracker.savedVars.profiles[name] = nil

    if DebuffTracker.savedVars.currentProfile == name then
        DebuffTracker.savedVars.currentProfile = nil
    end

    if DebuffTrackerProfilesDropdown then
        local choices, choicesValues, choicesTooltips = DebuffTracker.GetProfileNames()
        DebuffTrackerProfilesDropdown:UpdateChoices(choices, choicesValues, choicesTooltips, nil)
    end

    d("[DebuffTracker] Profile '" .. name .. "' deleted. Settings remain unchanged.")
end

function DebuffTracker.CreateSaveProfileDialog()
    if DebuffTracker.saveProfileDialog then return end

    local dialog = WINDOW_MANAGER:CreateTopLevelWindow("DebuffTracker_SaveProfileDialog")
    dialog:SetDimensions(350, 200)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetMovable(true)
    dialog:SetMouseEnabled(true)
    dialog:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeColor(0, 0, 0, 1)

    local title = WINDOW_MANAGER:CreateControl(nil, dialog, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetText("Enter Profile Name")
    title:SetAnchor(TOP, dialog, TOP, 0, 10)

    local editBackdrop = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
    editBackdrop:SetDimensions(260, 35)
    editBackdrop:SetAnchor(TOP, title, BOTTOM, 0, 10)
    editBackdrop:SetCenterColor(0, 0, 0, 1)
    editBackdrop:SetEdgeColor(1, 1, 1, 1)

    if not dialog.editBox then
        dialog.editBox = WINDOW_MANAGER:CreateControlFromVirtual("DebuffTracker_ProfileEditBox", editBackdrop, "ZO_DefaultEditForBackdrop")
        dialog.editBox:SetDimensions(250, 30)
        dialog.editBox:SetHidden(false)
        dialog.editBox:SetMouseEnabled(true)
        dialog.editBox:SetKeyboardEnabled(true)
    end

    local saveButton = CreateControlFromVirtual("DebuffTracker_SaveButton", dialog, "ZO_DefaultButton")
    saveButton:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 20, -20)
    saveButton:SetText("Save")
    saveButton:SetHandler("OnClicked", function()
        local profileName = dialog.editBox:GetText()
        if profileName and profileName ~= "" then
            DebuffTracker.SaveProfile(profileName)
            d("[DebuffTracker] Profile '" .. profileName .. "' saved.")
            dialog:SetHidden(true)
        else
            d("[DebuffTracker] Please enter a valid profile name.")
        end
    end)

    local cancelButton = CreateControlFromVirtual("DebuffTracker_CancelButton", dialog, "ZO_DefaultButton")
    cancelButton:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -20, -20)
    cancelButton:SetText("Cancel")
    cancelButton:SetHandler("OnClicked", function() dialog:SetHidden(true) end)

    DebuffTracker.saveProfileDialog = dialog
end

ZO_Dialogs_RegisterCustomDialog("DEBUFFTRACKER_DELETE_PROFILE", {
    gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
    title = { text = "Delete Profile" },
    mainText = { text = "Are you sure you want to delete the selected profile?" },
    buttons = {
        {
            text = SI_DIALOG_YES,
            callback = function()
                if DebuffTracker.savedVars.currentProfile then
                    DebuffTracker.DeleteProfile(DebuffTracker.savedVars.currentProfile)
                    d("[DebuffTracker] Profile deleted.")
                end
            end,
        },
        { text = SI_DIALOG_NO },
    },
})

local function CreateDebuffCheckboxes(abilityId, displayName)
    local controls = {}

    table.insert(controls, {
        type = "checkbox",
        name = displayName,
        getFunc = function()
            return DebuffTracker.savedVars.trackedAbilities[abilityId] or false
        end,
        setFunc = function(value)
            DebuffTracker.savedVars.trackedAbilities[abilityId] = value

            local debuffGroup = GetOrCreateDebuffGroup(abilityId)
            if debuffGroup then
                debuffGroup.window:SetHidden(not value)
            end
        end,
        width = "half"
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Reminder",
        getFunc = function()
            return DebuffTracker.savedVars.reminderEnabled[abilityId] or false
        end,
        setFunc = function(value)
            DebuffTracker.savedVars.reminderEnabled[abilityId] = value
        end,
        width = "half"
    })

    return controls
end

local function GetAllNonBuiltInTrackedAbilities()
	local allCustom = {}
	local customSet = {}
	local trackedAbilities = DebuffTracker.savedVars.trackedAbilities or {}

	for _, id in ipairs(DebuffTracker.savedVars.customAbilities or {}) do
		customSet[id] = true
		table.insert(allCustom, id)
	end

	local setAbilities = {}
	for _, data in pairs(DebuffTracker.SetAbilities or {}) do
		setAbilities[data.abilityId] = true
	end

	local commonAbilities = {}
	for _, entry in ipairs(DebuffTracker.GetCommonDebuffs().trackedAbilities or {}) do
		commonAbilities[entry.id] = true
	end

	for id, isTracked in pairs(trackedAbilities) do
		if isTracked and not customSet[id] and not setAbilities[id] and not commonAbilities[id] then
			customSet[id] = true
			table.insert(allCustom, id)
		end
	end

	table.sort(allCustom)
	return allCustom
end

function DebuffTracker.RefreshAllGroups()
    for abilityId, debuffGroup in pairs(DebuffTrackerUI) do
        local cfg = DebuffTracker.GetAbilityUIConfig(abilityId)
        debuffGroup.background:SetAlpha(cfg.alpha)
        ArrangeDebuffGroup(abilityId)
    end
end

function DebuffTracker.GetProfileNames()
    local choices = {}
    local choicesValues = {}
    local choicesTooltips = {}

    if DebuffTracker.savedVars.profiles then
        for name, _ in pairs(DebuffTracker.savedVars.profiles) do
            table.insert(choices, name)
            table.insert(choicesValues, name)
            table.insert(choicesTooltips, "Profile: " .. name)
        end
    end

    if #choices == 0 then
        table.insert(choices, "No Profiles Saved")
        table.insert(choicesValues, "No Profiles Saved")
        table.insert(choicesTooltips, "No profiles have been saved yet.")
    end

    return choices, choicesValues, choicesTooltips
end


function DebuffTracker.RefreshDebuffsPanel()
	if DebuffTrackerSettingsPanel and LibAddonMenu2 and LibAddonMenu2.util then
		LibAddonMenu2.util.RequestRefreshIfNeeded(DebuffTrackerSettingsPanel)
	end
end
local function CreatePerAbilitySettings(abilityId, abilityName)
	local submenuRef = "DebuffTracker_Submenu_" .. abilityId

	local function SafeGet(key, fallback)
		local ok, result = pcall(DebuffTracker.GetSetting, abilityId, key)
		return (ok and result ~= nil) and result or fallback
	end
	
	if SafeGet("alwaysShow", false) and SafeGet("onlyInCombat", false) then
		DebuffTracker.SetSetting(abilityId, "onlyInCombat", false)
	end

	local function MakeCheckbox(name, key, extraDisabledCheck, onSetCallback)
		return {
			type = "checkbox",
			name = name,
			getFunc = function() return SafeGet(key, false) end,
			setFunc = function(value)
				pcall(DebuffTracker.SetSetting, abilityId, key, value)
				if onSetCallback then onSetCallback(value) end
			end,
			width = "full",
			disabled = function()
				local isTracked = DebuffTracker.savedVars.trackedAbilities[abilityId]
				if not isTracked then return true end
				return extraDisabledCheck and extraDisabledCheck()
			end
		}
	end


	local function MakeSlider(name, key, min, max, step, fallback, onChange)
		return {
			type = "slider",
			name = name,
			min = min,
			max = max,
			step = step,
			getFunc = function() return SafeGet(key, fallback) end,
			setFunc = function(value)
				pcall(DebuffTracker.SetSetting, abilityId, key, value)
				if onChange then onChange(value) end
			end,
			width = "full",
			disabled = function()
				return not DebuffTracker.savedVars.trackedAbilities[abilityId]
			end

		}
	end

	local function GetSubmenuTitle()
		local isTracked = DebuffTracker.savedVars.trackedAbilities[abilityId]
		local statusText = isTracked and "|c00FF00[ON]|r" or "|c999999[OFF]|r"
		return string.format("%s %s", abilityName, statusText)
	end

	return {
		{
			type = "submenu",
			name = GetSubmenuTitle,
			reference = submenuRef,
			controls = {
				{
					type = "checkbox",
					name = "Track this ability",
					getFunc = function()
						return DebuffTracker.savedVars.trackedAbilities[abilityId] or false
					end,
					setFunc = function(value)
						DebuffTracker.savedVars.trackedAbilities[abilityId] = value
						
						

						local debuffGroup = GetOrCreateDebuffGroup(abilityId)
						if debuffGroup then
							debuffGroup.window:SetHidden(not value)
						end

						if DebuffTrackerSettingsPanel and LibAddonMenu2 and LibAddonMenu2.util then
							LibAddonMenu2.util.RequestRefreshIfNeeded(DebuffTrackerSettingsPanel)
						end
						DebuffTrackerProfileManager:RefreshMonitorPanel()
					end,
					width = "full",
				},

				{
					type = "checkbox",
					name = "Reminder",
					getFunc = function()
						return DebuffTracker.savedVars.reminderEnabled[abilityId] or false
					end,
					setFunc = function(value)
						DebuffTracker.savedVars.reminderEnabled[abilityId] = value
						local currentDebuffGroups = CollectActiveDebuffs()
						UpdateGroupVisibility(currentDebuffGroups)
					end,
					width = "full",
					disabled = function()
						return not DebuffTracker.savedVars.trackedAbilities[abilityId]
					end,
				},
				{
					type = "editbox",
					name = "Custom Window Title",
					tooltip = "Set a custom name to appear at the top of this ability's window. Leave empty to use the ability name.",
					getFunc = function()
						return DebuffTracker.savedVars.customTitles and DebuffTracker.savedVars.customTitles[abilityId] or GetAbilityName(abilityId)
					end,
					setFunc = function(value)
						DebuffTracker.savedVars.customTitles = DebuffTracker.savedVars.customTitles or {}
						local trimmed = zo_strtrim(value)
						if trimmed == "" then
							DebuffTracker.savedVars.customTitles[abilityId] = nil
						else
							DebuffTracker.savedVars.customTitles[abilityId] = trimmed
						end
						local group = DebuffTrackerUI[abilityId]
						if group and group.title then
							local newTitle = trimmed ~= "" and trimmed or GetAbilityName(abilityId)
							group.title:SetText(newTitle)
						end
					end,
					width = "full",
					disabled = function()
						return not DebuffTracker.savedVars.trackedAbilities[abilityId]
					end,
				},

				
				MakeSlider("Window Transparency", "windowAlpha", 0, 1, 0.05, 1, function()
					ArrangeDebuffGroup(abilityId)
				end),
				MakeSlider("Bar Transparency", "barAlpha", 0, 1, 0.05, 1, function()
					ArrangeDebuffGroup(abilityId)
				end),

				MakeCheckbox("Track only by you", "trackEffectsCastByYouOnly"),
				MakeCheckbox("Track only to you", "trackEffectsCastToYouOnly"),
				MakeSlider("Decimal number", "decimalNum", 0, 1, 1, 1, nil),

				
				MakeCheckbox("Show stacks (all)", "showStacks", function()
					return SafeGet("showStacksOnPrimaryOnly", false)
				end),

				MakeCheckbox("Show stacks (primary only)", "showStacksOnPrimaryOnly", function()
					return SafeGet("showStacks", false)
				end),

				MakeCheckbox("Show uptime", "ShowUptime"),
				MakeCheckbox("Highlight primary target", "HighlightTarget"),
				MakeCheckbox("Show timer", "showTimer"),
				MakeCheckbox("Always show window (even when empty)", "alwaysShow", function()
					return SafeGet("onlyInCombat", false)
				end, function(value)
					if value then
						DebuffTracker.SetSetting(abilityId, "onlyInCombat", false)
					end
					DebuffTracker.SetSetting(abilityId, "alwaysShow", value)
					local currentDebuffGroups = CollectActiveDebuffs()
					UpdateGroupVisibility(currentDebuffGroups)
				end),

				MakeCheckbox("Only show in combat", "onlyInCombat", function()
					return SafeGet("alwaysShow", false)
				end, function(value)
					if value then
						DebuffTracker.SetSetting(abilityId, "alwaysShow", false)
					end
					DebuffTracker.SetSetting(abilityId, "onlyInCombat", value)
					local currentDebuffGroups = CollectActiveDebuffs()
					UpdateGroupVisibility(currentDebuffGroups)
				end),


				MakeSlider("Max Rows", "maxRows", 1, 15, 1, 3, nil),
				MakeSlider("Bar Height", "barHeight", 10, 40, 1, 20, function() ArrangeDebuffGroup(abilityId) end),
				

				MakeSlider("Window Width", "barWidth", 100, 500, 10, 220, function() ArrangeDebuffGroup(abilityId) end),
				{
					type = "button",
					name = "Restore Settings",
					tooltip = "Clear all custom settings for this ability and use the global defaults instead.",
					func = function()
						DebuffTracker.savedVars.abilitySettings = DebuffTracker.savedVars.abilitySettings or {}
						DebuffTracker.savedVars.abilitySettings[abilityId] = nil

						local debuffGroup = GetOrCreateDebuffGroup(abilityId)
						if debuffGroup then
							ArrangeDebuffGroup(abilityId)
							local currentDebuffGroups = CollectActiveDebuffs()
							UpdateGroupVisibility(currentDebuffGroups)
						end

						if DebuffTrackerSettingsPanel and LibAddonMenu2 and LibAddonMenu2.util then
							LibAddonMenu2.util.RequestRefreshIfNeeded(DebuffTrackerSettingsPanel)
						end
					end,
					width = "full",
					warning = "This will discard all custom settings for this ability and revert to using global defaults.",
					disabled = function()
						return DebuffTracker.savedVars.abilitySettings == nil or DebuffTracker.savedVars.abilitySettings[abilityId] == nil
					end,

				},
				{
					type = "description",
					text = "\nSome abilities in the game have multiple ability IDs. For example, Major Breach has different IDs for Elemental Susceptibility, another for Elemental Drain, a different one for Puncture and so on.\nThe following edit-box allows you to add or modify the IDs associated with this ability.\n|cFF0000Modifying this list incorrectly may break tracking for this ability. Only include valid numeric ability IDs, separated by commas.|r",
					width = "full",
				},
				{
					type = "editbox",
					name = "Additional Ability Copies",
					tooltip = "Enter additional ability IDs that should be treated as copies of this ability (comma separated).",
					getFunc = function()
						local ids = {}
						local seen = {}

						table.insert(ids, abilityId)
						seen[abilityId] = true

						local customList = DebuffTracker.savedVars.customAbilityCopies and DebuffTracker.savedVars.customAbilityCopies[abilityId]
						if customList then
							for _, id in ipairs(customList) do
								if not seen[id] then
									table.insert(ids, id)
									seen[id] = true
								end
							end
						end

						local default = DebuffTracker.GetCommonDebuffs().abilityCopies[abilityId]
						if default then
							for _, id in ipairs(default) do
								if not seen[id] then
									table.insert(ids, id)
									seen[id] = true
								end
							end
						end

						return table.concat(ids, ", ")
					end,

					setFunc = function(input)
						DebuffTracker.savedVars.customAbilityCopies = DebuffTracker.savedVars.customAbilityCopies or {}

						local parsed = {}
						local seen = {}
						for id in string.gmatch(input, "%d+") do
							local num = tonumber(id)
							if num and not seen[num] then
								seen[num] = true
								table.insert(parsed, num)
							end
						end

						if #parsed > 0 then
							DebuffTracker.savedVars.customAbilityCopies[abilityId] = parsed
						else
							DebuffTracker.savedVars.customAbilityCopies[abilityId] = nil
						end
					end,
					width = "full",
					isMultiline = true
				}
			}
		}
	}
end


local function DebuffTracker_LoadSettings()
    if not LibAddonMenu2 then return end
    local panelData = {
        type = "panel",
        name = "Debuff Tracker",
        displayName = "Debuff Tracker",
        author = "SkullElf",
        version = "1.0",
        website = "https://www.esoui.com/downloads/author-82099.html",
        slashCommand = "/dt",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    if not DebuffTrackerSettingsPanel then
        DebuffTrackerSettingsPanel = LibAddonMenu2:RegisterAddonPanel("DebuffTrackerSettings", panelData)
    end

    local optionsTable = {}

    local generalCategory = {
        type = "submenu",
        name = "General Settings",
        controls = {
            {
                type = "button",
                name = "Show/Hide UI",
                func = function() DebuffTracker_ToggleUI() end,
                width = "half"
            },
			{
                type = "checkbox",
                name = "Track Debuffs only",
                getFunc = function() return DebuffTracker.savedVars.trackDebuffsOnly end,
                setFunc = function(value) DebuffTracker.savedVars.trackDebuffsOnly = value end,
                width = "full",
            },
			{
                type = "checkbox",
                name = "Track Effects applied by you only",
                getFunc = function() return DebuffTracker.savedVars.trackEffectsCastByYouOnly end,
                setFunc = function(value) DebuffTracker.savedVars.trackEffectsCastByYouOnly = value end,
                width = "full",
            },
			{
                type = "checkbox",
                name = "Track Effects applied to you only",
                getFunc = function() return DebuffTracker.savedVars.trackEffectsCastToYouOnly end,
                setFunc = function(value) DebuffTracker.savedVars.trackEffectsCastToYouOnly = value end,
                width = "full",
            },
			{
                type = "checkbox",
                name = "Highlight current target",
                getFunc = function() return DebuffTracker.savedVars.HighlightTarget end,
                setFunc = function(value) DebuffTracker.savedVars.HighlightTarget = value end,
                width = "full",
            },
			{
                type = "checkbox",
                name = "Show uptime of debuffs",
                getFunc = function() return DebuffTracker.savedVars.ShowUptime end,
                setFunc = function(value) DebuffTracker.savedVars.ShowUptime = value end,
                width = "full",
            },
			{
                type = "checkbox",
                name = "Bar blinking on last 2 seconds",
                getFunc = function() return DebuffTracker.savedVars.BarBlink end,
                setFunc = function(value) DebuffTracker.savedVars.BarBlink = value end,
                width = "full",
            },
			{
				type = "checkbox",
				name = "Use Gradient Bar Colors",
				tooltip = "If enabled, the debuff bars will use a red-to-green gradient based on remaining duration. Otherwise, fixed colors are used.",
				getFunc = function() return DebuffTracker.savedVars.useGradientBarColor ~= false end,
				setFunc = function(value)
					DebuffTracker.savedVars.useGradientBarColor = value
					DebuffTracker.RefreshAllGroups()
				end,
				width = "full",
			},
			{
                type = "checkbox",
                name = "Always Show",
                getFunc = function() return DebuffTracker.savedVars.alwaysShow end,
                setFunc = function(value) DebuffTracker.savedVars.alwaysShow = value end,
                width = "full",
            },
			{
				type = "slider",
				name = "Decimal number",
				tooltip = "Number of digits to show after the decimal point in timers and uptime labels.",
				min = 0,
				max = 1,
				step = 1,
				getFunc = function() return DebuffTracker.savedVars.decimalNum or 1 end,
				setFunc = function(value) DebuffTracker.savedVars.decimalNum = value end,
				default = 1,
			},
            {
                type = "dropdown",
                name = "Bar Texture",
                choices = barChoices,
                getFunc = function() return DebuffTracker.savedVars.barTexture end,
                setFunc = function(var) 
                    DebuffTracker.savedVars.barTexture = string.gsub(string.gsub(var, "|t", ""), "160:20:", "")
                    for _, debuffGroup in pairs(DebuffTrackerUI) do
                        for _, barData in pairs(debuffGroup.bars) do
                            barData.bar:SetTexture(DebuffTracker.savedVars.barTexture)
                        end
                    end
                end,
                width = "half",
            },
			{
				type = "dropdown",
				name = "Sort duration bars by:",
				tooltip = "Choose how to sort the rows in each debuff group.",
				choices = {
					"Enemy name (A-Z)",
					"Order of debuff application",
					"Time remaining (ascending)",
					"Time remaining (descending)",
				},
				getFunc = function() return DebuffTracker.savedVars.sortMode end,
				setFunc = function(value) DebuffTracker.savedVars.sortMode = value end,
				default = "Order of debuff application",
			},
			{
				type = "slider",
				name = "Minimum Enemy Difficulty",
				tooltip = "[Works only in trials] Only show debuff bars for enemies with difficulty at or above this level (1 = normal, 4 = deadly).",
				min = 0,
				max = 4,
				step = 1,
				getFunc = function() return DebuffTracker.savedVars.minimumDifficulty or 0 end,
				setFunc = function(value) DebuffTracker.savedVars.minimumDifficulty = value end,
				default = 0,
			},
			{
				type = "slider",
				name = "Maximum Rows",
				tooltip = "Set the maximum number of debuff rows displayed at a time.",
				min = 1,
				max = 50,
				step = 1,
				getFunc = function() return DebuffTracker.savedVars.maxRows end,
				setFunc = function(value) 
					DebuffTracker.savedVars.maxRows = value 
				end,
				default = 10,
			},
			{
				type = "checkbox",
				name = "Display Bars Above Header",
				tooltip = "Shows unit bars above the debuff name header instead of below.",
				getFunc = function() return DebuffTracker.savedVars.showBarsAboveHeader end,
				setFunc = function(value)
					DebuffTracker.savedVars.showBarsAboveHeader = value

					if DebuffTracker.uiUnlocked then
						DebuffTracker_ToggleUI()
						DebuffTracker_ToggleUI()
					end
				end,
				width = "full"
			},
			{
				type = "checkbox",
				name = "Show Marker",
				tooltip = "Toggle the visibility of the floating marker.",
				getFunc = function() return DebuffTracker.savedVars.showMarker end,
				setFunc = function(value)
					DebuffTracker.savedVars.showMarker = value
					if value then
						SetMarker(DebuffTracker.savedVars.markerSizeToggleEnabled and (2.5 * DebuffTracker.savedVars.markerSize) or DebuffTracker.savedVars.markerSize)
					else
						SetMarker(0)
					end
				end,
				default = true,
			},
			{
				type = "slider",
				name = "Marker Size",
				tooltip = "Adjust the size of the floating marker.",
				min = 16,
				max = 60,
				step = 2,
				getFunc = function() return DebuffTracker.savedVars.markerSize end,
				setFunc = function(value)
					DebuffTracker.savedVars.markerSize = value
					SetMarker(DebuffTracker.savedVars.markerSizeToggleEnabled and (2.5 * value) or value)
				end,
				default = 32,
				disabled = function() return not DebuffTracker.savedVars.showMarker end
			}
        }
    }
	
	local uiCategory = {
		type = "submenu",
		name = "UI Settings",
		controls = {
			{
				type = "slider",
				name = "Window Transparency",
				tooltip = "Transparency of the debuff's window.",
				min = 0,
				max = 1,
				step = 0.05,
				getFunc = function() return DebuffTracker.savedVars.ui.windowAlpha end,
				setFunc = function(value)
					local ui = DebuffTracker.savedVars.ui
					ui.windowAlpha = value
					DebuffTracker.RefreshAllGroups()
					if DebuffTracker.uiUnlocked then
						DebuffTracker_GeneratePreviewBars()
					end
				end,

				width = "full",
			},
			{
				type = "slider",
				name = "Bars Transparency",
				tooltip = "Transparency of the debuff bars.",
				min = 0,
				max = 1,
				step = 0.05,
				getFunc = function() return DebuffTracker.savedVars.ui.barAlpha end,
				setFunc = function(value)
					local ui = DebuffTracker.savedVars.ui
					ui.barAlpha = value
					DebuffTracker.RefreshAllGroups()
					if DebuffTracker.uiUnlocked then
						DebuffTracker_GeneratePreviewBars()
					end
				end,

				width = "full",
			},
			{
				type = "slider",
				name = "Bar Width",
				tooltip = "Width of each debuff bar.",
				min = 100,
				max = 400,
				step = 5,
				getFunc = function() return DebuffTracker.savedVars.ui.barWidth end,
				setFunc = function(value)
					local ui = DebuffTracker.savedVars.ui
					ui.barWidth = value

					ui.groupWidth = value + 10
					ui.rowWidth = value + 10

					DebuffTracker.RefreshAllGroups()
				end,
				width = "full",
			},
			{
				type = "slider",
				name = "Bar Height",
				tooltip = "Height of each debuff bar.",
				min = 12,
				max = 40,
				step = 1,
				getFunc = function() return DebuffTracker.savedVars.ui.barHeight end,
				setFunc = function(value)
					local ui = DebuffTracker.savedVars.ui
					ui.barHeight = value

					ui.rowHeight = value
					ui.rowSpacing = value + 2

					DebuffTracker.RefreshAllGroups()
				end,
				width = "full",
			}


		}
	}

	local debuffCategory = {
		type = "submenu",
		name = "Debuff Settings",
		tooltip = "Customize settings for each ability you're tracking.",
		controls = {}
	}

	table.insert(debuffCategory.controls, {
		type = "description",
		text = "This section lets you configure the trackers you'd like to use. You can enable or disable tracking for common debuffs like Major Breach, Minor Brittle, and more. For each enabled ability, you'll be able to see which enemies are affected during combat without needing to target them for it.\nBy modifying ability-specific settings, you override the addon's global settings, which apply by default to all abilities. To sync the ability-specific settings with the global settings, use the button at the end of each ability menu.\n\nTIP: You may add custom abilities by specifying their IDs (comma-seperated) at the bottom of this menu.",
		width = "full",
	})


	local addedAbilities = {}

	local function AddAbilitySettingsSubmenu(abilityId, displayName)
		local perAbilityControls = CreatePerAbilitySettings(abilityId, displayName .. " Settings")
		for _, control in ipairs(perAbilityControls) do
			table.insert(debuffCategory.controls, control)
		end
	end

	for _, ability in ipairs(DebuffTracker.GetCommonDebuffs().trackedAbilities) do
		if not addedAbilities[ability.id] then
			addedAbilities[ability.id] = true
			AddAbilitySettingsSubmenu(ability.id, ability.name)
		end
	end

	for setId, data in pairs(DebuffTracker.SetAbilities) do
		if not addedAbilities[data.abilityId] then
			addedAbilities[data.abilityId] = true
			AddAbilitySettingsSubmenu(data.abilityId, data.setName)
		end
	end

	for _, abilityId in ipairs(DebuffTracker.savedVars.customAbilities or {}) do
		if not addedAbilities[abilityId] then
			addedAbilities[abilityId] = true
			local displayName = GetAbilityName(abilityId) .. " (" .. tostring(abilityId) .. ")"
			AddAbilitySettingsSubmenu(abilityId, displayName)
		end
	end
	
	
	table.insert(debuffCategory.controls, {
		type = "editbox",
		name = "Custom Abilities (Comma Separated)",
		tooltip = "Enter custom ability IDs separated by commas. Example: 12345, 67890",
		getFunc = function()
			return table.concat(DebuffTracker.savedVars.customAbilities or {}, ", ")
		end,
		setFunc = function(input)
			local newCustomAbilities = {}
			local seen = {}

			for id in string.gmatch(input, "%d+") do
				local numId = tonumber(id)
				if numId and not seen[numId] then
					seen[numId] = true
					table.insert(newCustomAbilities, numId)
				end
			end

			local oldCustom = DebuffTracker.savedVars.customAbilities or {}
			local oldCustomLookup = {}
			for _, oldId in ipairs(oldCustom) do
				oldCustomLookup[oldId] = true
			end

			for _, oldId in ipairs(oldCustom) do
				if not seen[oldId] then
					DebuffTracker.savedVars.trackedAbilities[oldId] = nil
				end
			end

			for _, id in ipairs(newCustomAbilities) do
				if DebuffTracker.savedVars.trackedAbilities[id] == nil and not oldCustomLookup[id] then
					DebuffTracker.savedVars.trackedAbilities[id] = true
				end
			end

			table.sort(newCustomAbilities)
			DebuffTracker.savedVars.customAbilities = newCustomAbilities
		end,

		width = "full",
		requiresReload = true,
	})




	
	local choices, choicesValues, choicesTooltips = DebuffTracker.GetProfileNames()

    local profileCategory = {
        type = "submenu",
        name = "Profiles",
        controls = {
			--[[{
				type = "dropdown",
				name = "Saved Profiles",
				choices = choices,
				choicesValues = choicesValues,
				choicesTooltips = choicesTooltips,
				getFunc = function() return DebuffTracker.savedVars.currentProfile end,
				setFunc = function(value) 
					if value and value ~= "No Profiles Saved" then
						DebuffTracker.ApplyProfile(value)
					end
				end,
				width = "full",
				reference = "DebuffTrackerProfilesDropdown",
			},]]--
            {
				type = "button",
				name = "Open Profiles Manager",
				func = function()
					DebuffTrackerProfileManager:Show()
				end,
				width = "full",
			},

        }
    }
    table.insert(optionsTable, generalCategory)
	table.insert(optionsTable, uiCategory)
    table.insert(optionsTable, debuffCategory)
	table.insert(optionsTable, setAbilityCategory)
    table.insert(optionsTable, profileCategory)

    LibAddonMenu2:RegisterOptionControls("DebuffTrackerSettings", optionsTable)
end


function DebuffTracker.ApplyProfile(name)
	local profile = DebuffTracker.savedVars.profiles and DebuffTracker.savedVars.profiles[name]
	if not profile then
		d("[DebuffTracker] ERROR: Profile '" .. tostring(name) .. "' not found.")
		return
	end

	local SV = DebuffTracker.savedVars

	local function DeepCopyOrEmpty(source)
		return ZO_DeepTableCopy(source or {})
	end

	SV.trackedAbilities         = DeepCopyOrEmpty(profile.trackedAbilities)
	--SV.customAbilities          = DeepCopyOrEmpty(profile.customAbilities)
	SV.customTitles             = DeepCopyOrEmpty(profile.customTitles)
	SV.customAbilityCopies      = DeepCopyOrEmpty(profile.customAbilityCopies)
	SV.reminderEnabled          = DeepCopyOrEmpty(profile.reminderEnabled)
	SV.abilitySettings          = DeepCopyOrEmpty(profile.abilitySettings)
	SV.positions                = DeepCopyOrEmpty(profile.positions)
	SV.ui                       = DeepCopyOrEmpty(profile.ui)

	local generalKeys = {
		"accountWide", "trackDebuffsOnly", "trackEffectsCastByYouOnly", "trackEffectsCastToYouOnly",
		"HighlightTarget", "ShowUptime", "BarBlink", "useGradientBarColor", "alwaysShow",
		"decimalNum", "barTexture", "sortMode", "minimumDifficulty", "maxRows", "showBarsAboveHeader",
		"showMarker", "markerSize", "markerSizeToggleEnabled"
	}
	for _, key in ipairs(generalKeys) do
		if profile[key] ~= nil then
			SV[key] = profile[key]
		end
	end

	SV.currentProfile = name

	for abilityId, pos in pairs(SV.positions) do
		if type(pos) == "table" and pos.x and pos.y then
			local group = DebuffTrackerUI[abilityId]
			if group and group.window then
				group.window:ClearAnchors()

				local safeX = math.max(0, math.min(pos.x, GuiRoot:GetWidth() - 50))
				local safeY = math.max(0, math.min(pos.y, GuiRoot:GetHeight() - 50))

				group.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, safeX, safeY)
				
			end
		end
	end
	
	for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
		local group = GetOrCreateDebuffGroup(abilityId)
		ArrangeDebuffGroup(abilityId)
	end
	
	
	UpdateGroupVisibility({})
	
	
	
	

	-- UI + LAM2 Refresh
	--DebuffTracker.RefreshUI()

	--[[if DebuffTrackerProfilesDropdown then
		local choices, values, tips = DebuffTracker.GetProfileNames()
		DebuffTrackerProfilesDropdown:UpdateChoices(choices, values, tips)

		zo_callLater(function()
			local selected = DebuffTrackerProfilesDropdown.choices[name]
			if selected then
				DebuffTrackerProfilesDropdown.dropdown:SetSelectedItem(selected)
			end
		end, 100)
	end

	if LAM2 and DebuffTrackerSettingsPanel then
		zo_callLater(function()
			LAM2:RefreshPanel(DebuffTrackerSettingsPanel)
		end, 200)
	end]]--

	d(string.format("[DebuffTracker] Profile '%s' applied successfully.", name))
end

local activeTypeDescriptions = {
    [0] = "Not Active",
    [1] = "Active on Both Bars",
    [2] = "Active on Front Bar",
    [3] = "Active on Back Bar"
}

SLASH_COMMANDS["/groupsets"] = function()
    zo_callLater(function()
        GroupSetTracker.GetGroupSets()

        if not next(GroupSetTracker.GROUP_SETS) then
            d("|cFF4500DebuffTracker|r: No set data available. Ensure group members have LibSetDetection installed.")
            return
        end

        d("|cFFD700DebuffTracker|r: Currently Equipped Sets in Group")
        
        for unitTag, sets in pairs(GroupSetTracker.GROUP_SETS) do
			
            local playerName = GetUnitDisplayName(unitTag) or unitTag
            d(string.format("|c00FF00Player: %s|r", playerName))
			

			for setId, data in pairs(sets) do
				local activeTypeText = activeTypeDescriptions[data.activeType] or "Unknown"

				d(string.format("   |cFFA500Set: %s|r (%d pieces, %s)", 
					data.setName, 
					data.numEquip.body + data.numEquip.front + data.numEquip.back, 
					activeTypeText
				))
			end

        end
    end, 500)
end

local function PeriodicSave()
    if not DebuffTracker.needsSave then return end

    local persistent = DebuffTracker.savedVars.persistentData.dynamicDifficultyData
    for zoneId, zoneData in pairs(DebuffTracker.dynamicDifficultyData) do
        persistent[zoneId] = persistent[zoneId] or {}
        for unitName, difficulty in pairs(zoneData) do
            if not persistent[zoneId][unitName] then
                persistent[zoneId][unitName] = difficulty
            end
        end
    end

    DebuffTracker.needsSave = false
end

local updatingEnemyMapping = false

local function OnPlayerActivated()
    DebuffTracker.currentZoneId = GetZoneId(GetUnitZoneIndex("player"))

    local isTrial = trialZones[DebuffTracker.currentZoneId]

    if isTrial and not updatingEnemyMapping then
        EVENT_MANAGER:RegisterForUpdate(DebuffTracker.name .. "_UpdateDynamicEnemyMapping", 30000, PeriodicSave)
        updatingEnemyMapping = true
    elseif not isTrial and updatingEnemyMapping then
        EVENT_MANAGER:UnregisterForUpdate(DebuffTracker.name .. "_UpdateDynamicEnemyMapping")
        updatingEnemyMapping = false
    end

    if DebuffTracker.savedVars.showMarker then
        SetMarker(DebuffTracker.savedVars.markerSizeToggleEnabled and (2.5 * DebuffTracker.savedVars.markerSize) or DebuffTracker.savedVars.markerSize)
    else
        SetMarker(0)
    end
	if not DebuffTracker.ShouldTrackOnlyInCombat() and not DebuffTracker.isTracking then
		DebuffTracker.isTracking = true
		EVENT_MANAGER:RegisterForUpdate(DebuffTracker.name .. "_BuffTracker", 100, DebuffTracker.TrackBuffs)
	end

end

function DebuffTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= DebuffTracker.name then return end

    DebuffTracker.savedVars = ZO_SavedVars:NewAccountWide("DebuffTrackerSavedVars", 1, nil, {
		trackOnlyInCombat = true,
		barTexture = "DebuffTracker/icons/gradientProgressBar.dds",
		trackedAbilities = {},
		customAbilities = {},
		positions = {},
		maxRows = 10,
		showMarker = true,
		markerSize = 32,
		markerSizeToggleEnabled = false,
		profiles = {},
		currentProfile = nil,
		trackDebuffsOnly = true,
		trackEffectsCastByYouOnly = false,
		trackEffectsCastToYouOnly = false,
		reminderEnabled = {},
		showBarsAboveHeader = false,
		sortMode = "Order of debuff application",
		HighlightTarget = false,
		ShowUptime = true,
		BarBlink = true,
		alwaysShow = false,
		showStacks = true,
		showStacksOnPrimaryOnly = false,
		showTimer = true,
		onlyInCombat = true,
		useGradientBarColor = true,
		decimalNum = 1,
		customTitles = {},
		customAbilityCopies = {},
		persistentData = {
			dynamicDifficultyData = {}
		},
		ui = {
			groupWidth = 220,
			headerHeight = 30,
			rowWidth = 215,
			rowHeight = 25,
			iconSize = 24,
			barWidth = 165,
			barHeight = 20,
			rowSpacing = 25,
			stackLabelWidth = 20,
			timerLabelWidth = 20,
			windowAlpha = 1,
			barAlpha = 1,

		},

		
	})
	
	if DebuffTracker.savedVars.ui == {} then
		DebuffTracker.savedVars.ui = {
			groupWidth = 220,
			headerHeight = 30,
			rowWidth = 215,
			rowHeight = 25,
			iconSize = 24,
			barWidth = 165,
			barHeight = 20,
			rowSpacing = 25,
			stackLabelWidth = 20,
			timerLabelWidth = 20,
			windowAlpha = 1,
			barAlpha = 1,

		}
	end
	DebuffTracker.savedVars.accountWide = true
	
	DebuffTracker.savedVars.ui.stackLabelWidth = 30
	DebuffTracker.savedVars.ui.timerLabelWidth = 30
	
	local commonDebuffs = DebuffTracker.GetCommonDebuffs()
    for _, ability in ipairs(commonDebuffs.trackedAbilities) do
        if DebuffTracker.savedVars.trackedAbilities[ability.id] == nil then
            DebuffTracker.savedVars.trackedAbilities[ability.id] = ability.enabled
        end

        if DebuffTracker.savedVars.reminderEnabled[ability.id] == nil then
            DebuffTracker.savedVars.reminderEnabled[ability.id] = false
        end
    end
	DebuffTracker.savedVars.abilitySettings = DebuffTracker.savedVars.abilitySettings or {}

	DebuffTracker.cfg = DebuffTracker.savedVars.ui
	
	for abilityId, isTracked in pairs(DebuffTracker.savedVars.trackedAbilities) do
		if isTracked and DebuffTracker.GetSetting(abilityId, "alwaysShow") then
			local group = GetOrCreateDebuffGroup(abilityId)
			ArrangeDebuffGroup(abilityId)
		end
	end

	
	EVENT_MANAGER:RegisterForEvent(DebuffTracker.name .. "_unit", EVENT_COMBAT_EVENT, DebuffTracker.OnUnitDeath)
	EVENT_MANAGER:AddFilterForEvent(DebuffTracker.name .. "_unit", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2260, REGISTER_FILTER_IS_ERROR, false)

	EVENT_MANAGER:RegisterForEvent(DebuffTracker.name .. "_unit2", EVENT_COMBAT_EVENT, DebuffTracker.OnUnitDeath)
	EVENT_MANAGER:AddFilterForEvent(DebuffTracker.name .. "_unit2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2262, REGISTER_FILTER_IS_ERROR, false)
	EVENT_MANAGER:RegisterForEvent("DebuffTracker_TargetChanged", EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)


	DebuffTracker_LoadSettings()
	ZO_CreateStringId("SI_BINDING_NAME_DebuffTracker_OpenProfiles", "Open Profiles Manager")
    ZO_CreateStringId("SI_BINDING_NAME_DebuffTracker_OpenMenu", "Open Settings Menu")
		
	zo_callLater(function()
		if DebuffTrackerProfilesDropdown then
			local choices, choicesValues, choicesTooltips = DebuffTracker.GetProfileNames()
			DebuffTrackerProfilesDropdown:UpdateChoices(choices, choicesValues, choicesTooltips, DebuffTracker.savedVars.currentProfile)
		end
	end, 500)



	DebuffTracker.inmenu = false
	DebuffTracker.needsSort = {}
	DebuffTracker.ReminderNeeded = BuildReminderNeeds()
	DebuffTracker.dynamicDifficultyData = {}
	DebuffTracker.effectFingerprintLookup = {}

	EVENT_MANAGER:RegisterForEvent(DebuffTracker.name, EVENT_EFFECT_CHANGED, DebuffTracker.OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent(DebuffTracker.name, EVENT_PLAYER_COMBAT_STATE, DebuffTracker.OnCombatStateChanged)
    EVENT_MANAGER:UnregisterForEvent(DebuffTracker.name, EVENT_ADD_ON_LOADED)
	
	EVENT_MANAGER:UnregisterForEvent(DebuffTracker.name .. "active", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForEvent(DebuffTracker.name .. "active", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	
	
	zo_callLater(function()
		GroupSetTracker.GetGroupSets()
	end, 1000)
	
	SLASH_COMMANDS["/dtprofiles"] = function()
		DebuffTrackerProfileManager:Show()
	end

	
end
EVENT_MANAGER:RegisterForEvent(DebuffTracker.name, EVENT_ADD_ON_LOADED, DebuffTracker.OnAddOnLoaded)
