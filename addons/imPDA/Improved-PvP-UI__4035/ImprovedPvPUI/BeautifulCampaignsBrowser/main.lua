local Log = IMP_PVP_UI_Logger('IMP_BCB')
local showIcereach = false
local showTooltip = false
local showBonuses = false

local autoTransfer = false
local destination
local transferCampaign

-- TODO: conteinerize and unify creation of campaign overview and get rid of these^ local variables

local LOADING_SCREEN_CYRODIIL = 'esoui/art/loadingscreens/loadscreen_cyrodiil_01.dds'
local LOADING_SCREEN_IMPERIAL_CITY = 'esoui/art/loadingscreens/loadscreen_imperialcity_01.dds'
local LOADING_SCREEN_WIDTH = 1680
local LOADING_SCREEN_HEIGHT = 1052

local function CreateTab()
    local sceneName = 'beautifulCampaignsBrowser'
    local sceneGroupName = 'allianceWarSceneGroup'

	-- SYSTEMS:RegisterKeyboardRootScene(sceneName, ESO_PROFILER_SCENE)

    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE = ZO_Scene:New('beautifulCampaignsBrowser', SCENE_MANAGER)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    -- BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(CAMPAIGN_BROWSER_FRAGMENT)
    -- BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(TITLE_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(ALLIANCE_WAR_TITLE_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(CURRENT_CAMPAIGNS_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(CAMPAIGN_AVA_RANK_FRAGMENT)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(ALLIANCE_WAR_WINDOW_SOUNDS)
    -- BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_AVA)

    local fragment = ZO_FadeSceneFragment:New(IMP_beautifulCampaignsBrowser)
    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(fragment)

	local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo[sceneGroupName]
	local iconData = sceneGroupInfo.menuBarIconData
	iconData[#iconData + 1] = {
        categoryName = SI_WINDOW_TITLE_BEAUTIFUL_CAMPAIGNS_BROWSER,
        descriptor = 'beautifulCampaignsBrowser',
        normal = 'EsoUI/Art/Campaign/campaign_tabIcon_browser_up.dds',
        pressed = 'EsoUI/Art/Campaign/campaign_tabIcon_browser_down.dds',
        highlight = 'EsoUI/Art/Campaign/campaign_tabIcon_browser_over.dds',
    }
	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:AddFragment(sceneGroupBarFragment)

	local scenegroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
	scenegroup:AddScene(sceneName)
	MAIN_MENU_KEYBOARD:AddRawScene(sceneName, MENU_CATEGORY_ALLIANCE_WAR, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_ALLIANCE_WAR], sceneGroupName)
end

local campaignControls = {}
local index = 0

local topControl = IMP_beautifulCampaignsBrowser
local campaignsContainer = topControl:GetNamedChild('Subwindow'):GetNamedChild('Campaigns')
local tooltip = topControl:GetNamedChild('CampaignDescriptionTooltip')

local function ClearPanels()
    for i, control in ipairs(campaignControls) do
        control:ClearAnchors()
        control:SetHidden(true)
        control:GetNamedChild('Name'):SetColor(1, 1, 1)
        local details = control:GetNamedChild('Details')
        details:SetHidden(true)
        control:GetNamedChild('SomeInfo'):SetHidden(true)

        local bonusesControls = {
            control:GetNamedChild('Population'):GetNamedChild('DCBonuses'),
            control:GetNamedChild('Population'):GetNamedChild('EPBonuses'),
            control:GetNamedChild('Population'):GetNamedChild('ADBonuses'),
        }
        for _, bonusesControl in ipairs(bonusesControls) do
            for child = 1, bonusesControl:GetNumChildren() do
                bonusesControl:GetChild(child):SetHidden(true)
            end
        end
    end
    campaignsContainer:GetNamedChild('HomeCampaignIcon'):SetHidden(true)
    campaignsContainer:GetNamedChild('AllianceLockIcon'):SetHidden(true)
    index = 0
end

local function GetControl()
    index = index + 1
    -- Log('Index: %d, controls: %d', index, #campaignControls)
    if index > #campaignControls then
        -- Log('No control, creating')
        local newControl = CreateControlFromVirtual(index, campaignsContainer, 'IMP_BCB_CampaignOverviewTemplate')
        assert(newControl ~= nil, 'Cant create campaign control')
        campaignControls[index] = newControl

        return newControl
    else
        -- Log('Using old control')
        campaignControls[index]:SetHidden(false)
        return campaignControls[index]
    end
end

local function GetPreviousControl()
    return campaignControls[index-1]
end

local campaignDataList = {}
IMP_BCB_CAMPAIGNS_DATA_LIST = campaignDataList
local function GetCampaignData(campaignId)
    for i, campaignData in ipairs(campaignDataList) do
        if campaignData.id == campaignId then return campaignData end
    end
end
local function GetCampaignDataIndex(campaignId)
    for i, campaignData in ipairs(campaignDataList) do
        if campaignData.id == campaignId then return i end
    end
end

local function GetCampaignControlByCampaignId(campaignId)
    local campaignDataIndex = GetCampaignDataIndex(campaignId)
    return campaignDataIndex and campaignsContainer:GetChild(2 + campaignDataIndex)
end

local function IsNoCP(campaignId)
    if campaignId == 103 then return true end
    if campaignId == 111 then return true end
    if campaignId == 116 then return true end
    if campaignId == 96 then return true end
end

local function IsNoCP2(rulesetId)
    if rulesetId == 22 then return true end  -- No-CP Cyro
    if rulesetId == 18 then return true end  -- No-CP 7 day Cyro
    if rulesetId == 24 then return true end  -- No-CP IC
    if rulesetId == 15 then return true end  -- Below 50
end

local function ShowTooltip(control)
    local campaignId = control.campaignId
    if not campaignId then return end

    local rulesetId = GetCampaignRulesetId(campaignId)
    local isNoCP = IsNoCP2(rulesetId)

    tooltip:SetAnchor(RIGHT, control, LEFT, -40)

    -- tooltip:AddLine(text, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize, minWidth)
    -- AddHeaderLine(text, font, headerRow, headerSide, r, g, b)

    local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
    -- tooltip:AddHeaderLine(GetCampaignName(campaignId), 'ZoFontWinH2', 1, THS_LEFT, r, g, b)
    tooltip:AddLine(GetCampaignName(campaignId), 'ZoFontWinH2', r, g, b, LABEL_LINE_ANCHOR_BASELINE, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)

    ZO_Tooltip_AddDivider(tooltip)

    tooltip:AddLine(isNoCP and 'noCP' or 'CP', 'ZoFontGameLargeBold', 0, 1, 0)
    tooltip:AddLine(GetCampaignRulesetDescription(rulesetId), 'ZoFontWinH4', r, g, b, nil, nil, TEXT_ALIGN_CENTER)

    if rulesetId == 15 then
        if GetUnitLevel('player') < 50 then
            tooltip:AddLine('Below 50 (can join)', 'ZoFontGameLargeBold', 0, 1, 0)
        else
            tooltip:AddLine('Below 50 (can\'t join)', 'ZoFontGameLargeBold', 1, 0, 0)
        end
    end

    tooltip:SetHidden(false)

    -- Log('Tooltip shown')
end

local function HideTooltip()
    tooltip:SetHidden(true)
    tooltip:ClearLines()

    -- Log('Tooltip hidden')
end

local function OnCampaignQueueChanged(_, campaignId)
    local campaignData = GetCampaignData(campaignId)
    if not campaignData then return end

    campaignData.isQueued = IsQueuedForCampaign(campaignData.id, campaignData.isGroup)
    campaignData.state = GetCampaignQueueState(campaignData.id, campaignData.isGroup)
    Log('State -> %d', campaignData.state)

    local control = GetCampaignControlByCampaignId(campaignId)
    if not control then return end

    local background = control:GetNamedChild('BG')
    local canQueueSolo, canQueueGroup = CAMPAIGN_BROWSER_MANAGER:CanQueueForCampaign(campaignData)
    if canQueueSolo or campaignData.isQueued or autoTransfer then
        if WINDOW_MANAGER:GetMouseOverControl() ~= background then  -- TODO: refactor, this check should not exist
            background:SetDesaturation(0.6)
        -- else
        --     background:SetDesaturation(0)
        end

        background:SetHandler('OnMouseEnter', function(ctrl)
            ctrl:SetDesaturation(0)
        end)
        background:SetHandler('OnMouseExit', function(ctrl)
            ctrl:SetDesaturation(0.6)
        end)

        control:GetNamedChild('Backdrop'):SetEdgeColor(0, 55/255, 0)

        if campaignData.isQueued or campaignData == destination then
            control:GetNamedChild('Backdrop'):SetEdgeColor(99/255, 99/255, 0)
        end
    else
        background:SetDesaturation(1)

        background:SetHandler('OnMouseEnter', nil)
        background:SetHandler('OnMouseExit', nil)
        -- background:SetHandler('OnMouseDoubleClick', nil)

        control:GetNamedChild('Backdrop'):SetEdgeColor(99/255, 0, 0)
    end

    if showTooltip then
        ZO_PostHookHandler(background, 'OnMouseEnter', function() ShowTooltip(control) end)
        ZO_PostHookHandler(background, 'OnMouseExit', function() HideTooltip() end)
    end

    --[[
    if canQueueSolo then
        background:SetHandler('OnMouseDoubleClick', function(ctrl, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            CAMPAIGN_BROWSER_MANAGER:DoQueueForCampaign(campaignData)
        end)
    end
    ]]
    local function QueueTransferCampaign()
        local queuedTo
        local lowestPopulationCampaign
        local playerAlliance = GetUnitAlliance('player')

        if not transferCampaign then
            local lowestPopulation = CAMPAIGN_POP_FULL + 1
            for _, campaignData_ in ipairs(campaignDataList) do
                local canTransfer = CAMPAIGN_BROWSER_MANAGER:CanQueueForCampaign(campaignData_)
                local population = campaignData_.alliances[playerAlliance].population

                Log('%s: %d', campaignData_.name, population + 1)
                if canTransfer and (population < lowestPopulation) then
                    lowestPopulation = population
                    lowestPopulationCampaign = campaignData_
                end

                if campaignData_.isQueued then
                    queuedTo = campaignData_
                end
            end
        end

        transferCampaign = queuedTo or lowestPopulationCampaign

        CAMPAIGN_BROWSER_MANAGER:DoQueueForCampaign(transferCampaign)
        OnCampaignQueueChanged(nil, destination.id)  -- have to do it manually
    end

    background:SetHandler('OnMouseDoubleClick', function(ctrl, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if canQueueSolo then
            CAMPAIGN_BROWSER_MANAGER:DoQueueForCampaign(campaignData)
        elseif autoTransfer then
            Log('Transfer')
            destination = campaignData
            QueueTransferCampaign()
        end
    end)

    local details = control:GetNamedChild('Details')
    if campaignData.isQueued then
        local someBoolean, descriptionText, iconTexture = CAMPAIGN_BROWSER_MANAGER:GetQueueMessage(campaignData.id, false, campaignData.state)
        -- Log('Queued, setting string %s', descriptionText)
        details:SetText(descriptionText)
        details:SetHidden(false)

        if campaignData.state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
            zo_callLater(function() OnCampaignQueueChanged(_, campaignId) end, 500)  -- TODO: optimize(?)
            background:SetHandler('OnMouseDoubleClick', function(ctrl, button)
                if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
                ConfirmCampaignEntry(campaignId, false, true)
            end)
        end
    elseif campaignData == destination and autoTransfer then
        details:SetText(('Will queue here automatically after %s!'):format(transferCampaign.name))
        details:SetHidden(false)
    else
        details:SetText('')
        details:SetHidden(true)
    end

    if GetCurrentCampaignId() == campaignData.id then
        details:SetText(string.format('You are here') .. '\n' .. details:GetText())
        details:SetHidden(false)
    end
end

local function OnCampaignLeaderboardDataChanged(_, campaignId, allianceId)
    if true then return end -- TODO: temporary disabled

    -- if campaignId ~= GetAssignedCampaignId() and (campaignId ~= GetCurrentCampaignId() or not IsInCyrodiil()) then return end
    if campaignId ~= GetCurrentCampaignId() or not IsInCyrodiil() then return end

    local control = GetCampaignControlByCampaignId(campaignId)
    if not control then return end

    local function AddSomeInfo(alliance)
        -- Log('%s - Adding info to %d alliance', GetCampaignName(campaignId), alliance)

        -- local score = GetCampaignAllianceScore(campaignId, alliance)
        local numKeeps = GetTotalCampaignHoldings(campaignId, HOLDINGTYPE_KEEP, alliance)
        local numResources = GetTotalCampaignHoldings(campaignId, HOLDINGTYPE_RESOURCE, alliance)
        local numOutposts = GetTotalCampaignHoldings(campaignId, HOLDINGTYPE_OUTPOST, alliance)
        local numDefensiveScrolls = GetTotalCampaignHoldings(campaignId, HOLDINGTYPE_DEFENSIVE_ARTIFACT, alliance)
        local numOffensiveScrolls = GetTotalCampaignHoldings(campaignId, HOLDINGTYPE_OFFENSIVE_ARTIFACT, alliance)
        -- local potentialScore = GetCampaignAlliancePotentialScore(campaignId, alliance)
        -- local isUnderpop = IsUnderpopBonusEnabled(campaignId, alliance)

        local infoRowControl = control:GetNamedChild('SomeInfo'):GetNamedChild(tostring(alliance))

        -- Log('%s %d score: %d', GetCampaignName(campaignId), alliance, score)

        infoRowControl:GetNamedChild('KeepsValue'):SetText(numKeeps)
        infoRowControl:GetNamedChild('ResourcesValue'):SetText(numResources)
        infoRowControl:GetNamedChild('OutpostsValue'):SetText(numOutposts)
        infoRowControl:GetNamedChild('ScrollsValue'):SetText(numDefensiveScrolls + numOffensiveScrolls)
    end

    control:GetNamedChild('SomeInfo'):SetHidden(false)

    if allianceId ~= 0 then
        AddSomeInfo(allianceId)
    else
        for alliance = 1, NUM_ALLIANCES do
            AddSomeInfo(alliance)
        end
    end
end

local GAP_PX = 8
local ELEMENT_WIDTH = 850

local function RefreshCampaignPanels()
    ClearPanels()

    -- campaignData.queue = self:CreateCampaignQueueData(campaignData, CAMPAIGN_QUEUE_INDIVIDUAL)
    -- self.selectionCampaignList[selectionIndex] = campaignData

    local numCampaigns = #campaignDataList
    local numCyrodiilCampaigns = 0
    local numImperialCityCampaigns = 0
    for _, campaign in ipairs(campaignDataList) do
        if campaign.isImperialCityCampaign then
            numImperialCityCampaigns = numImperialCityCampaigns + 1
        else
            numCyrodiilCampaigns = numCyrodiilCampaigns + 1
        end
    end

    local function NewPavedContainer(imageWidth, imageHeight, horizontalStartP, verticalStartP, elementWidth, elementHeight, numElements, gapHeight)
        local sumHeight = elementHeight * numElements + gapHeight * (numElements - 1)
        local right = 0.99 * imageHeight / sumHeight * elementWidth / imageWidth
        local step = 0.99 * elementHeight / sumHeight

        if right > 1 then
            step = step / right
            right = 1
        end

        local top = 0
        local gap = gapHeight / sumHeight

        return {
            sumHeight = sumHeight,
            left = horizontalStartP,
            right = right + verticalStartP,
            top = top,
            bottom = top + step,
            step = step,
            gap = gap,
        }
    end
    local function Increment(self)
        self.top = self.top + self.step + self.gap
        self.bottom = self.top + self.step
    end

    if numCampaigns > 9 then
        GAP_PX = 4
    end

    local totalHeight = campaignsContainer:GetHeight()
    local totalWidth = campaignsContainer:GetWidth()
    local campaignHeightPx = zo_round((totalHeight - (numCampaigns - 1) * GAP_PX) / numCampaigns)

    local cyrodiilPavedContainer = NewPavedContainer(LOADING_SCREEN_WIDTH, LOADING_SCREEN_HEIGHT, 0, 0, ELEMENT_WIDTH, campaignHeightPx, numCyrodiilCampaigns, GAP_PX)
    local imperialCityPavedContainer = NewPavedContainer(LOADING_SCREEN_WIDTH, LOADING_SCREEN_HEIGHT, 0, 0, ELEMENT_WIDTH, campaignHeightPx, numImperialCityCampaigns, GAP_PX)

    for i, campaignData in ipairs(campaignDataList) do
        local campaignId = campaignData.id

        local control = GetControl()
        control.campaignId = campaignId

        control:SetHeight(campaignHeightPx)
        control:SetWidth(totalWidth)

        local nameControl = control:GetNamedChild('Name')
        nameControl:SetText(campaignData.name)
        if numCampaigns > 9 and not PP then
            local isValid, point, relativeTo, relativePoint, offsetX, offsetY = nameControl:GetAnchor()
            if isValid then
                nameControl:SetAnchor(point, relativeTo, relativePoint, 5, 1)
                nameControl:SetFont('ZoFontHeader2')
                control:GetNamedChild('Details'):SetFont('$(BOLD_FONT)|$(KB_14)|soft-shadow-thick')
            end
        end

        if numCampaigns > 9 then
            control:GetNamedChild('Backdrop'):SetAnchor(TOPLEFT, nil, nil, -1, -1)
            control:GetNamedChild('Backdrop'):SetAnchor(BOTTOMRIGHT, nil, nil, 1, 1)
        end

        local background = control:GetNamedChild('BG')
        if campaignData.isImperialCityCampaign then
            background:SetTexture(LOADING_SCREEN_IMPERIAL_CITY)
            background:SetTextureCoords(imperialCityPavedContainer.left, imperialCityPavedContainer.right, imperialCityPavedContainer.top, imperialCityPavedContainer.bottom)
            Increment(imperialCityPavedContainer)
        else
            background:SetTexture(LOADING_SCREEN_CYRODIIL)
            background:SetTextureCoords(cyrodiilPavedContainer.left, cyrodiilPavedContainer.right, cyrodiilPavedContainer.top, cyrodiilPavedContainer.bottom)
            Increment(cyrodiilPavedContainer)
        end
        background:SetColor(0.5, 0.5, 0.5, 1)

        --[[
        local queued = IsQueuedForCampaign(campaignData.id, false)
        if queued then
            OnCampaignQueueChanged(nil, campaignId)
        end
        ]]

        OnCampaignQueueChanged(nil, campaignId)

        --[[
        local canQueueSolo, canQueueGroup = CAMPAIGN_BROWSER_MANAGER:CanQueueForCampaign(campaignData)
        if canQueueSolo then
            background:SetDesaturation(0.6)

            background:SetHandler('OnMouseEnter', function(ctrl) ctrl:SetDesaturation(0) end)
            background:SetHandler('OnMouseExit', function(ctrl) ctrl:SetDesaturation(0.6) end)
            background:SetHandler('OnMouseDoubleClick', function(ctrl, button)
                if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
                CAMPAIGN_BROWSER_MANAGER:DoQueueForCampaign(campaignData)
            end)

            control:GetNamedChild('Backdrop'):SetEdgeColor(0, 55/255, 0)
        else
            background:SetDesaturation(1)

            background:SetHandler('OnMouseEnter', nil)
            background:SetHandler('OnMouseExit', nil)
            background:SetHandler('OnMouseDoubleClick', nil)

            control:GetNamedChild('Backdrop'):SetEdgeColor(99/255, 0, 0)
        end
        ]]

        local populationControl = control:GetNamedChild('Population')
        populationControl:GetNamedChild('ADPopulationIcon'):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(campaignData.alliancePopulation1))
        populationControl:GetNamedChild('EPPopulationIcon'):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(campaignData.alliancePopulation2))
        populationControl:GetNamedChild('DCPopulationIcon'):SetTexture(ZO_CampaignBrowser_GetPopulationIcon(campaignData.alliancePopulation3))
        if numCampaigns > 9 and not PP then
            local isValid, point, relativeTo, relativePoint, offsetX, offsetY = populationControl:GetAnchor()
            if isValid then
                populationControl:SetAnchor(point, relativeTo, relativePoint, offsetX, 2)
            end
        end

        if showBonuses then
            local allianceToBonusesControl = {
                [1] = 'ADBonuses',
                [2] = 'EPBonuses',
                [3] = 'DCBonuses',
            }
            if not campaignData.isImperialCityCampaign then
                for alliance = 1, 3 do
                    local bonusesControl = control:GetNamedChild('Population'):GetNamedChild(allianceToBonusesControl[alliance])

                    if campaignData.alliances[alliance].underdog then
                        bonusesControl:SetHidden(false)
                        bonusesControl:GetNamedChild('LowScore'):SetHidden(false)
                    end

                    if campaignData.alliances[alliance].underpop then
                        bonusesControl:SetHidden(false)
                        bonusesControl:GetNamedChild('LowPopulation'):SetHidden(false)
                    end
                end
            end
        end

        -- local attachTo = control:GetNamedChild('BackgroundIcons')
        local attachTo = control:GetNamedChild('Name')
        local attachAnchor = RIGHT
        local alliance = campaignData.lockedToAlliance
        if alliance and alliance ~= 0 then
            local allianceLockIcon = campaignsContainer:GetNamedChild('AllianceLockIcon')

            local ALLIANCE_COLORS = {
                [ALLIANCE_ALDMERI_DOMINION]     = ZO_ColorDef:New(183/255, 217/255, 63/255),
                [ALLIANCE_EBONHEART_PACT]       = ZO_ColorDef:New(243/255, 74/255, 57/255),
                [ALLIANCE_DAGGERFALL_COVENANT]  = ZO_ColorDef:New(55/255, 127/255, 213/255),
            }
            local function GetAllianceColor(allianceId)
                return ALLIANCE_COLORS[allianceId] or NO_ALLIANCE_COLOR
            end

            -- GetAllianceColor = GetAllianceColor

            local r, g, b, a = GetAllianceColor(alliance):UnpackRGB()
            control:GetNamedChild('Name'):SetColor(r, g, b)

            -- local backgroundIconsControl = control:GetNamedChild('BackgroundIcons')
            -- local numIcons = backgroundIconsControl:GetNumChildren()

            -- Log('Num icons: %d', numIcons)

            -- local attachTo
            -- if numIcons > 0 then
            --     attachTo = backgroundIconsControl:GetChild(numIcons)
            -- else
            --     attachTo = backgroundIconsControl
            -- end

            local ALLIANCE_ICON = {
                [ALLIANCE_ALDMERI_DOMINION] = 'esoui/art/stats/alliancebadge_aldmeri.dds',
                [ALLIANCE_EBONHEART_PACT] = 'esoui/art/stats/alliancebadge_ebonheart.dds',
                [ALLIANCE_DAGGERFALL_COVENANT] = 'esoui/art/stats/alliancebadge_daggerfall.dds',
            }

            -- local ALLIANCE_ALPHA = {
            --     [ALLIANCE_ALDMERI_DOMINION] = 0.60,
            --     [ALLIANCE_EBONHEART_PACT] = 0.75,
            --     [ALLIANCE_DAGGERFALL_COVENANT] = 0.75,
            -- }

            allianceLockIcon:SetTexture(ALLIANCE_ICON[alliance])
            allianceLockIcon:SetColor(r, g, b)  -- ALLIANCE_ALPHA[alliance])
            allianceLockIcon:SetAnchor(LEFT, attachTo, attachAnchor, 2)  -- 18)
            allianceLockIcon:SetHidden(false)

            attachTo = allianceLockIcon
            attachAnchor = RIGHT
        end

        -- control:GetNamedChild('Details'):SetHidden(true)

        local previousControl = GetPreviousControl()
        if previousControl then
            control:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, GAP_PX)
        else
            control:SetAnchor(TOPLEFT, campaignsContainer)
        end

        if campaignId == GetAssignedCampaignId() then
            -- mark as home campaign
            local homeCampaignIcon = campaignsContainer:GetNamedChild('HomeCampaignIcon')

            homeCampaignIcon:SetAnchor(LEFT, attachTo, attachAnchor, 2)  -- 18)
            homeCampaignIcon:SetHidden(false)

            attachTo = homeCampaignIcon
            attachAnchor = RIGHT
        end
    end

    if QueryCampaignLeaderboardData(ALLIANCE_NONE) == LEADERBOARD_DATA_READY then
        for i, campaignData in ipairs(campaignDataList) do
            OnCampaignLeaderboardDataChanged(nil, campaignData.id, ALLIANCE_NONE)
        end
    end

    -- if IsInAvAZone() then
    --     local currentCampaignId = GetCurrentCampaignId()
    --     local control = GetCampaignControlByCampaignId(currentCampaignId)
    --     local details = control:GetNamedChild('Details')
    --     details:SetText(string.format('You are here'))
    --     details:SetHidden(false)
    -- end
end

local function RebuildCampaignData()
    ZO_ClearNumericallyIndexedTable(campaignDataList)

    for selectionIndex = 1, GetNumSelectionCampaigns() do
        local campaignId = GetSelectionCampaignId(selectionIndex)
        local rulesetId = GetCampaignRulesetId(campaignId)

        local campaignData = {}

        campaignData.name = ZO_CachedStrFormat(SI_CAMPAIGN_NAME, GetCampaignName(campaignId))
        campaignData.type = ZO_CAMPAIGN_DATA_TYPE_CAMPAIGN
        campaignData.id = campaignId
        campaignData.selectionIndex = selectionIndex
        campaignData.rulesetId = rulesetId
        campaignData.rulesetType = GetCampaignRulesetType(rulesetId)
        campaignData.rulesetName = GetCampaignRulesetName(rulesetId)
        campaignData.queueWaitSeconds = GetSelectionCampaignQueueWaitTime(selectionIndex)

        campaignData.alliancePopulation1 = GetSelectionCampaignPopulationData(selectionIndex, 1)
        campaignData.alliancePopulation2 = GetSelectionCampaignPopulationData(selectionIndex, 2)
        campaignData.alliancePopulation3 = GetSelectionCampaignPopulationData(selectionIndex, 3)

        local underdogLeaderAlliance = GetCampaignUnderdogLeaderAlliance(campaignId)

        local alliances = {}
        for i = 1, 3 do
           table.insert(alliances, {
                underdog = underdogLeaderAlliance == i,
                underpop = IsUnderpopBonusEnabled(campaignId, i),
                score = GetSelectionCampaignAllianceScore(selectionIndex, i),
                potential = GetCampaignAlliancePotentialScore(campaignId, i),
                population = GetSelectionCampaignPopulationData(selectionIndex, i),
            })
        end
        campaignData.alliances = alliances

        campaignData.numGroupMembers = GetNumSelectionCampaignGroupMembers(selectionIndex)
        campaignData.numFriends = GetNumSelectionCampaignFriends(selectionIndex)
        campaignData.numGuildMembers = GetNumSelectionCampaignGuildMembers(selectionIndex)

        campaignData.earnedTier = GetPlayerCampaignRewardTierInfo(campaignId)

        campaignData.canBeAllianceLocked = CanCampaignBeAllianceLocked(campaignId)
        campaignData.lockedToAlliance = GetSelectionCampaignCurrentAllianceLock(selectionIndex)
        campaignData.allianceLockReason = GetSelectionCampaignAllianceLockReason(selectionIndex)
        campaignData.allianceLockConflictingCharacterName = GetSelectionCampaignAllianceLockConflictingCharacterName(selectionIndex)

        campaignData.isImperialCityCampaign = IsImperialCityCampaign(campaignId)

        if (campaignId ~= 104 and campaignId ~= 122) or showIcereach then  -- TODO: move to the top
            table.insert(campaignDataList, campaignData)
        end
    end

    -- 105 - Evergloam (7-day standard, Mayhem)
    -- 106 - Ashpit (7-day standard, Mayhem)
    -- 111 - Quagmire (7-day no-CP, Mayhem)
    -- 112 - Field of Regret (7-day no-CP, Mayhem)
    -- 116 - Legion Zero (no-CP IC, Mayhem)
    -- 119 - Dragonfire (IC, Mayhem)
    -- 122 - Coldharbour (below 50, Mayhem)
    -- 124 - Vengeance

    local LIST = {
        124,
        105, 106, 111, 112, 122, -- Cyro Mayhem
        102, 101, 103, 104, -- Cyro
        119, 116,  -- IC Mayhem
        95, 96  -- IC
    }

    local function getIndex(s, l)
        for i, e in ipairs(l) do
            if s == e then return i end
        end
    end

    local function sortFunction(entry1, entry2)
        if entry1 == entry2 then return end

        local value1, value2 = entry1.id, entry2.id
        local home = GetAssignedCampaignId()

        if value1 == home then return true end
        if value2 == home then return false end

        Log('Comparing %d and %d', value1, value2)

        return getIndex(value1, LIST) < getIndex(value2, LIST)
    end

    table.sort(campaignDataList, sortFunction)

    RefreshCampaignPanels()
end

function IMP_BCB_ColorizeSomeInfoRow(self)
    local alliance = tonumber(self:GetName():sub(-1))

    for i = 1, self:GetNumChildren() do
        self:GetChild(i):SetColor(GetAllianceColor(alliance):UnpackRGB())
    end

    -- self:GetParent():SetHidden(false)
end

function IMP_BCB_Initialize(settigns)
    CreateTab()

    local function OnPlayerActivated()
        transferCampaign = nil
        if destination and CAMPAIGN_BROWSER_MANAGER:CanQueueForCampaign(destination) then
            CAMPAIGN_BROWSER_MANAGER:DoQueueForCampaign(destination)
        else
            destination = nil
        end
        RebuildCampaignData()

        -- EVENT_MANAGER:UnregisterForEvent('IMP_BCB', EVENT_PLAYER_ACTIVATED)
    end

    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    local function OnCampaignSelectionDataChanged()
        RebuildCampaignData()
    end
    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, OnCampaignSelectionDataChanged)

    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_QUEUE_JOINED, OnCampaignQueueChanged)
    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_QUEUE_LEFT, OnCampaignQueueChanged)
    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueChanged)
    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueueChanged)  -- TODO campaignId, sGroup, position

    EVENT_MANAGER:RegisterForEvent('IMP_BCB', EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, function(...)
        local arg = {...}
        Log('EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, campaign: %s, alliance: %d', GetCampaignName(arg[2]), arg[3])
        OnCampaignLeaderboardDataChanged(...)
    end)

    BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE:RegisterCallback('StateChange', function(oldState, newState)
        if newState == SCENE_SHOWN then
            Log('Browser scene opened')
            -- RefreshCampaignPanels()
            QueryCampaignSelectionData()
        end
    end)

    local function MakeItPerfect()
        local FRAGMENTS_TO_REMOVE = {
            FRAME_PLAYER_FRAGMENT,
            RIGHT_BG_FRAGMENT,
            TREE_UNDERLAY_FRAGMENT,
            TITLE_FRAGMENT,
            ALLIANCE_WAR_TITLE_FRAGMENT,
        }

        local function EditScene(scene, topLevelControl)
            PP.removeFragmentsFromScene(scene, FRAGMENTS_TO_REMOVE)

            PP:CreateBackground(topLevelControl, --[[#1]] nil, nil, nil, -10, -10, --[[#2]] nil, nil, nil, 0, 10)
            PP.Anchor(topLevelControl, --[[#1]] TOPRIGHT, GuiRoot, TOPRIGHT, 0, 120, --[[#2]] true, BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, -70)
        end

        if PP.allianceWarSceneGroupEditScene ~= nil then
            PP.allianceWarSceneGroupEditScene(BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE, topControl)
        else
            EditScene(BEAUTIFUL_CAMPAIGNS_BROWSER_SCENE, topControl)
        end

        PP.SetStyle_Tooltip(tooltip)
    end

    if PP then
        Log('PP detected')
        -- ZO_PostHook(PP, 'allianceWarSceneGroup', MakeItPerfect)
        MakeItPerfect()
    end

    showIcereach = GetUnitLevel('player') < 50 or settigns.showIcereach
    showTooltip = settigns.showTooltip

    showBonuses = settigns.showBonuses
    autoTransfer = settigns.autotransfer

    -- function CampaignBrowser:OnCampaignQueueStateUpdated(campaignData)
    --     self:CheckForConfirmingQueues()
    --     self:RefreshFilters()
    -- end

    -- function CampaignBrowser:OnCampaignQueuePositionChanged()
    --     self:RefreshVisible()
    -- end

    -- function CampaignBrowser:OnCampaignSelectionDataChanged()
    --     self:RefreshData()
    -- end

    -- function CampaignBrowser:OnAssignedCampaignChanged()
    --     self:SelectAssignedCampainRulesetNode()
    --     self:RefreshVisible()
    -- end

    -- ZO_UI_SYSTEM_MANAGER.systems[UI_SYSTEM_ALLIANCE_WAR].keyboardOpen = function()
    --     MAIN_MENU_KEYBOARD:ShowSceneGroup('allianceWarSceneGroup', 'beautifulCampaignsBrowser')
    -- end

    -- ZO_PreHook(MAIN_MENU_KEYBOARD, 'ShowSceneGroup', function(self, sceneGroupName, specificScene)
    --     Log('%s:%s', sceneGroupName, tostring(specificScene))

    --     return false
    -- end)
end