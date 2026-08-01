local UI = NMGuildHall.UI
local Addon = NMGuildHall
local function UILogger()
    if Addon and Addon.Message and Addon.Message.For then
        return Addon.Message:For("UI")
    end
    return nil
end

function UI:CreateContentArea()
    local windowWidth = (self.window and self.window.GetWidth and self.window:GetWidth()) or 700
    local windowHeight = (self.window and self.window.GetHeight and self.window:GetHeight()) or 550
    local contentWidth = math.max(480, windowWidth - 20)
    local contentHeight = math.max(240, windowHeight - 175) -- 70 header + 50 tabs + 40 footer + padding

    local content = WINDOW_MANAGER:CreateControl("NMGuildHall_ContentArea", self.window, CT_CONTROL)
    content:SetDimensions(contentWidth, contentHeight)
    content:SetAnchor(TOP, self.tabBar, BOTTOM, 0, 8)
    
    local contentBg = WINDOW_MANAGER:CreateControl("NMGuildHall_ContentBG", content, CT_BACKDROP)
    contentBg:SetAnchorFill()
    contentBg:SetCenterTexture("EsoUI/Art/Miscellaneous/centerscreen_floating_backing.dds")
    contentBg:SetCenterColor(0.03, 0.03, 0.04, 0.5)
    contentBg:SetEdgeColor(0.15, 0.15, 0.18, 1)
    contentBg:SetEdgeTexture("", 1, 1, 0, 0)
    
    self.content = content
    self.contentBg = contentBg
    
    -- Create content containers for each tab
    self.contentContainers = {}
    self:CreateHomeContent()
    self:CreateTeleportContent()
    self:CreateCampaignContent()
    self:CreatePledgesContent()
    -- Note: Group content is created dynamically
end

function UI:CreateHomeContent()

    local container = WINDOW_MANAGER:CreateControl("NMGuildHall_HomeContainer", self.content, CT_CONTROL)
    local cw = (self.content and self.content.GetWidth and self.content:GetWidth()) or 680
    local ch = (self.content and self.content.GetHeight and self.content:GetHeight()) or 375
    container:SetDimensions(math.max(200, cw - 20), math.max(200, ch - 20))
    container:SetAnchor(TOPLEFT, self.content, TOPLEFT, 10, 10)
    
    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    local crimson = (uiColors and uiColors.CRIMSON) or {0.8, 0.2, 0.3, 1}
    
    local welcomeLabel = WINDOW_MANAGER:CreateControl("NMGuildHall_WelcomeLabel", container, CT_LABEL)
    welcomeLabel:SetFont("ZoFontWinH3")
    local welcomeText = GetString(NMGH_WELCOME)
    if NMGuildHall and NMGuildHall.Message and NMGuildHall.Message._FormatPlain then
        welcomeText = NMGuildHall.Message:_FormatPlain(welcomeText, {player = GetDisplayName()})
    end
    welcomeLabel:SetText(welcomeText)
    welcomeLabel:SetAnchor(TOP, container, TOP, 0, 30)
    welcomeLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    welcomeLabel:SetColor(unpack(crimson))
    
    local yOffset = 80
    
    -- Guild Hub button
    local guildHallBtn = self:CreateActionButton(container, 0, yOffset, 
        GetString(NMGH_BUTTON_GUILD_HALL), 
        "EsoUI/Art/LFG/Gamepad/gp_lfg_groupfinder_mygroup.dds",
        function()
            local log = UILogger()
            if log then
                log:Info(GetString(NMGH_CHAT_TELEPORTING_TO), {destination = GetString(NMGH_GUILD_HUB)})
            end
            
            -- Call TeleportToHouse via Teleport module
            if NMGuildHall and NMGuildHall.Teleport and NMGuildHall.Teleport.TeleportToHouse then
                local megaserver = "UNKNOWN"
                if NMGuildHall.Compatibility and NMGuildHall.Compatibility:GetMegaserver() then
                    megaserver = select(1, NMGuildHall.Compatibility:GetMegaserver())
                end

                local hubData = Constants.TELEPORT.GUILD_HUB[megaserver]
                local owner = hubData and hubData.owner
                local houseId = hubData and hubData.houseId

                if not owner or not houseId then
                    if log then
                        log:Warn(GetString(NMGH_ERROR_GH_TELEPORT_CONFIG), {megaserver = megaserver})
                    end
                    return
                end
                NMGuildHall.Teleport:TeleportToHouse(owner, houseId)
            else
                if log then
                    log:Error(GetString(NMGH_ERROR_PORT_TO_HOUSE_NOT_FOUND))
                end
            end
            
            self:Hide()
        end)
    
    guildHallBtn.label:SetColor(1, 1, 1, 1)
    
    yOffset = yOffset + 75
    
    -- Primary Residence button
    local primaryResBtn = self:CreateActionButton(container, 0, yOffset,
        GetString(NMGH_BUTTON_PRIMARY_RESIDENCE),
        "EsoUI/Art/Campaign/Gamepad/gp_overview_menuicon_home.dds",
        function()
            local log = UILogger()
            local houseId = GetHousingPrimaryHouse()
            if not houseId or houseId == 0 then
                if log then
                    log:Warn(GetString(NMGH_CHAT_PRIMARY_NOT_SET))
                end
                return
            end
            if log then
                log:Info(GetString(NMGH_CHAT_TELEPORTING_TO_PRIMARY))
            end
            RequestJumpToHouse(houseId)
            self:Hide()
        end)
    
    primaryResBtn.label:SetColor(1, 1, 1, 1)
    
    yOffset = yOffset + 75
    
    -- Twitch button
    local twitchBtn = self:CreateActionButton(container, 0, yOffset,
        GetString(NMGH_BUTTON_VISIT_TWITCH),
        "EsoUI/Art/Login/login_icon_info.dds",
        function()
            RequestOpenUnsafeURL("https://twitch.tv/neliserendipity")
        end)
    
    twitchBtn.label:SetColor(1, 1, 1, 1)
    
    container:SetHidden(true)
    self.contentContainers.home = container
end

function UI:CreateTeleportContent()
    local container = WINDOW_MANAGER:CreateControl("NMGuildHall_TeleportContainer", self.content, CT_CONTROL)
    local cw = (self.content and self.content.GetWidth and self.content:GetWidth()) or 680
    local ch = (self.content and self.content.GetHeight and self.content:GetHeight()) or 375
    container:SetDimensions(math.max(200, cw - 20), math.max(200, ch - 20))
    container:SetAnchor(TOPLEFT, self.content, TOPLEFT, 10, 10)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl("NMGuildHall_TeleportTitle", container, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetText(GetString(NMGH_TELEPORT_STATUS))
    title:SetAnchor(TOP, container, TOP, 0, 5)
    title:SetColor(0.8, 0.2, 0.3, 1)
    
    -- Search bar container
    local searchContainer = WINDOW_MANAGER:CreateControl("NMGuildHall_TeleportSearchContainer", container, CT_CONTROL)
    searchContainer:SetDimensions(640, 40)
    searchContainer:SetAnchor(TOP, title, BOTTOM, 0, 10)
    
    -- Search bar background
    local searchBg = WINDOW_MANAGER:CreateControl("NMGuildHall_TeleportSearchBG", searchContainer, CT_BACKDROP)
    searchBg:SetAnchorFill()
    searchBg:SetCenterColor(0.10, 0.10, 0.12, 0.9)
    searchBg:SetEdgeColor(0.25, 0.25, 0.28, 1)
    searchBg:SetEdgeTexture("", 1, 1, 0, 0)
    
    -- Add search icon FIRST
    local searchIcon = WINDOW_MANAGER:CreateControl("NMGuildHall_TeleportSearchIcon", searchContainer, CT_TEXTURE)
    searchIcon:SetDimensions(20, 20)
    searchIcon:SetAnchor(LEFT, searchContainer, LEFT, 12, 0)
    searchIcon:SetTexture("EsoUI/Art/Buttons/search_up.dds")
    searchIcon:SetColor(0.7, 0.7, 0.7, 1)
    
    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual(nil, searchContainer, "ZO_DefaultEdit")
    searchBox:SetDimensions(540, 32)
    searchBox:SetAnchor(LEFT, searchIcon, RIGHT, 15, 3)
    searchBox:SetFont("ZoFontGame")
    searchBox:SetMaxInputChars(30)
    searchBox:SetText("")
    searchBox:SetDefaultText(GetString(NMGH_SEARCH_PLACEHOLDER))
    searchBox:SetColor(1, 1, 1, 1)
    searchBox:SetHandler("OnTextChanged", function(control)
        -- Guard against recursion: SetText inside OnTextChanged can retrigger OnTextChanged.
        if self._teleportSearchSettingText then
            return
        end

        local searchText = control:GetText()
        -- Validate search text using Validator
        if NMGuildHall.Validator then
            local sanitized = NMGuildHall.Validator:SanitizeSearchText(searchText)
            if sanitized ~= searchText then
                self._teleportSearchSettingText = true
                control:SetText(sanitized)
                self._teleportSearchSettingText = false
                return
            end
        end

        -- Debounce refresh to avoid rebuilding the list on every keystroke.
        if self._teleportSearchDebounceHandle then
            zo_removeCallLater(self._teleportSearchDebounceHandle)
            self._teleportSearchDebounceHandle = nil
        end
        self._teleportSearchDebounceHandle = zo_callLater(function()
            self._teleportSearchDebounceHandle = nil
            self:RefreshTeleportList(control:GetText() or "")
        end, 150)
    end)
    
    -- Create scroll container
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NMGuildHallTeleportScroll", container, "ZO_ScrollContainer")
    scrollContainer:SetDimensions(660, 260)
    scrollContainer:SetAnchor(TOP, searchContainer, BOTTOM, 0, 10)
    
    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    scrollChild:SetResizeToFitDescendents(true)
    
    self.scrollLists.teleport = scrollContainer
    self.teleportScrollChild = scrollChild
    self.teleportSearchBox = searchBox
    
    container:SetHidden(true)
    self.contentContainers.teleport = container
end

function UI:CreateCampaignContent()
    local container = WINDOW_MANAGER:CreateControl("NMGuildHall_CampaignContainer", self.content, CT_CONTROL)
    local cw = (self.content and self.content.GetWidth and self.content:GetWidth()) or 680
    local ch = (self.content and self.content.GetHeight and self.content:GetHeight()) or 375
    container:SetDimensions(math.max(200, cw - 20), math.max(200, ch - 20))
    container:SetAnchor(TOPLEFT, self.content, TOPLEFT, 10, 10)

    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    local crimson = (uiColors and uiColors.CRIMSON) or {0.8, 0.2, 0.3, 1}

    local title = WINDOW_MANAGER:CreateControl("NMGuildHall_CampaignTitle", container, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetText(GetString(NMGH_QUEUE_CAMPAIGN_TITLE))
    title:SetAnchor(TOP, container, TOP, 0, 15)
    title:SetColor(unpack(crimson))

    local description = WINDOW_MANAGER:CreateControl("NMGuildHall_CampaignDescription", container, CT_LABEL)
    description:SetFont("ZoFontGame")
    description:SetText(GetString(NMGH_QUEUE_CAMPAIGN_DESCRIPTION))
    description:SetAnchor(TOP, title, BOTTOM, 0, 10)
    description:SetWidth(620)
    description:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    description:SetColor(0.9, 0.9, 0.9, 1)

    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NMGuildHall_CampaignScroll", container, "ZO_ScrollContainer")
    scrollContainer:SetDimensions(660, 260)
    scrollContainer:SetAnchor(TOP, description, BOTTOM, 0, 10)
    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    scrollChild:SetResizeToFitDescendents(true)
    self.scrollLists.campaign = scrollContainer
    self.campaignScrollChild = scrollChild
    self.campaignDirty = true

    container:SetHidden(true)
    self.contentContainers.campaign = container

    local function OnCampaignSelectionChanged()
        self.campaignDirty = true
        if self.currentTab == "campaign" then
            self:RefreshCampaignList(true)
        end
    end
    if Addon and Addon.EventManager then
        Addon.EventManager:RegisterEvent(EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, function()
            OnCampaignSelectionChanged()
        end, "NMGuildHall_UI")
    else
        local evtName = Addon.name .. "_UI_CampaignSelectionChanged"
        -- Fallback bookkeeping must be eventCode -> ownerName for UI:Cleanup.
        self.registeredEvents[EVENT_CAMPAIGN_SELECTION_DATA_CHANGED] = evtName
        EVENT_MANAGER:RegisterForEvent(evtName, EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, function()
            OnCampaignSelectionChanged()
        end)
    end
end

function UI:RefreshCampaignList(force)
    local Constants = Addon and Addon.Constants
    if not Constants or not Constants.UI or not Constants.UI.CAMPAIGN then
        if Addon and Addon.Message then
            Addon.Message:For("UI"):Warn(GetString(NMGH_WARN_CAMPAIGN_DEBUG_NOT_AVAIL))
        end
        return
    end
    if not self.campaignScrollChild then return end
    if not force and self.campaignDirty == false then
        return
    end

    if QueryCampaignSelectionData then
        QueryCampaignSelectionData()
    end

    -- 1. Initialize/Release campaign row pool
    if not self.campaignRowPool then
        self:CreateCampaignRowPool()
    end
    self.campaignRowPool:ReleaseAllObjects()

    local parent = self.campaignScrollChild
    -- Hide the empty label if it exists
    local emptyLabel = WINDOW_MANAGER:GetControlByName("NMGuildHall_CampaignEmpty")
    if emptyLabel then emptyLabel:SetHidden(true) end

    local numCampaigns = GetNumSelectionCampaigns()
    if not numCampaigns or numCampaigns == 0 then
        local emptyName = "NMGuildHall_CampaignEmpty"
        local label = WINDOW_MANAGER:GetControlByName(emptyName)
        if not label then
            label = WINDOW_MANAGER:CreateControl(emptyName, parent, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            label:SetColor(0.8, 0.8, 0.8, 1)
            label:SetDimensions(640, 40)
        end
        label:SetAnchor(TOP, parent, TOP, 0, 0)
        label:SetText(GetString(NMGH_CAMPAIGN_NONE_AVAILABLE))
        label:SetHidden(false)
        parent:SetHeight(40)
        self.campaignDirty = false
        return
    end

    local currentCampaignId = GetCurrentCampaignId and GetCurrentCampaignId() or nil

    local friendsInCyrodiil = 0
    if GetNumFriends and GetFriendCharacterInfo then
        local function GetZoneNameByIdSafe(zoneId)
            if not (GetZoneNameById and zoneId and zoneId > 0) then
                return nil
            end
            local ok, result = pcall(GetZoneNameById, zoneId)
            if ok and type(result) == "string" and result ~= "" then
                return result
            end
            return nil
        end

        local ava = Constants and Constants.AVA
        local cyroZoneId = ava and ava.CYRODIIL_ZONE_ID or nil
        local cyroName = cyroZoneId and GetZoneNameByIdSafe(cyroZoneId) or nil

        local numFriends = GetNumFriends()
        for fi = 1, numFriends do
            local hasCharacter, _, zoneName, _, _, _, _, zoneId = GetFriendCharacterInfo(fi)
            local inCyro = false
            if cyroZoneId and zoneId and zoneId == cyroZoneId then
                inCyro = true
            elseif cyroName and zoneName and zoneName == cyroName then
                inCyro = true
            end

            if hasCharacter and inCyro then
                friendsInCyrodiil = friendsInCyrodiil + 1
            end
        end
    end

    local rowHeight = 36
    local spacing = 4
    local yOffset = 0
    local maxQueueSeconds = 0

    local function setAllianceTexture(texture, allianceIndex, pop)
        if not texture then return end
        local textures = Constants.UI.CAMPAIGN.POP_TEXTURES
        local texturePath = textures[pop] or textures[0]
        texture:SetTexture(texturePath)
        
        local colors = Constants.UI.CAMPAIGN.ALLIANCE_COLORS
        local color = colors[allianceIndex] or {1, 1, 1, 1}
        texture:SetColor(unpack(color))
    end

    for index = 1, numCampaigns do
        local campaignId = GetSelectionCampaignId(index)
        local name = GetCampaignName(campaignId)
        local rulesetType = GetCampaignRulesetType(campaignId)
        local rulesetName = GetString("SI_CAMPAIGNRULESETTYPE", rulesetType)
        if rulesetName == "" then
            rulesetName = GetString(NMGH_UNKNOWN_TYPE) .. " " .. tostring(rulesetType)
        end

        if Constants.UI.CAMPAIGN.CATEGORY_MAP[name] then
            rulesetName = Constants.UI.CAMPAIGN.CATEGORY_MAP[name]
        end

        -- Acquire pooled row
        local row = self.campaignRowPool:AcquireObject()
        row:SetParent(parent)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
        row:SetHidden(false)

        row:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                local campaignData = CAMPAIGN_BROWSER_MANAGER and CAMPAIGN_BROWSER_MANAGER:GetDataByCampaignId(campaignId)
                if not campaignData then
                    if Addon and Addon.Message then
                        Addon.Message:For("UI"):Warn(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = tostring(campaignId)})
                    end
                    return
                end
                local isGrouped = IsUnitGrouped("player")
                if Addon.Campaign then
                    Addon.Campaign:ShowQueueDialog(campaignData)
                end
            end
        end)

        -- Name label
        local isHomeCampaign = GetAssignedCampaignId and campaignId == GetAssignedCampaignId()
        local nameText = name or GetString(NMGH_UNKNOWN_CAMPAIGN)
        if isHomeCampaign then
            nameText = string.format("%s |t16:16:EsoUI/Art/Campaign/campaignbrowser_homecampaign.dds|t", nameText)
        end
        if row.nameLabel then row.nameLabel:SetText(nameText) end

        -- Category label
        if row.catLabel then
            row.catLabel:SetText(rulesetName)
            local catWidth = row.catLabel:GetTextWidth() + 10
            if catWidth < 60 then catWidth = 60 end
            row.catLabel:SetWidth(catWidth)
        end

        -- Social data
        local guildCount = (GetNumSelectionCampaignGuildMembers and GetNumSelectionCampaignGuildMembers(index)) or 0
        local friendCount = (GetNumSelectionCampaignFriends and GetNumSelectionCampaignFriends(index)) or 0
        local groupCount = (GetNumSelectionCampaignGroupMembers and GetNumSelectionCampaignGroupMembers(index)) or 0
        
        if friendCount == 0 and currentCampaignId and campaignId == currentCampaignId and friendsInCyrodiil > 0 then
            friendCount = friendsInCyrodiil
        end

        local counts = { Guild = guildCount, Friends = friendCount, Group = groupCount }
        for typeSuffix, data in pairs(row.socialCols) do
            local count = counts[typeSuffix] or 0
            if count > 0 then
                data.label:SetText(count)
                data.container:SetHidden(false)
            else
                data.container:SetHidden(true)
            end
        end

        -- Info label (Queue/Ends)
        local endSeconds = 0
        if GetSelectionCampaignTimes then
            local _, t2 = GetSelectionCampaignTimes(index)
            endSeconds = t2
        end
        local queueSeconds = (GetSelectionCampaignQueueWaitTime and GetSelectionCampaignQueueWaitTime(index)) or 0

        local infoText = ""
        if queueSeconds > 0 then
            if Addon and Addon.Campaign and Addon.Campaign.FormatSelectionQueueInfo then
                infoText = Addon.Campaign:FormatSelectionQueueInfo(queueSeconds)
            else
                if queueSeconds < 60 then queueSeconds = 60 end
                local queueIconTag = "|t16:16:EsoUI/Art/Campaign/campaignbrowser_queued.dds|t"
                infoText = queueIconTag .. " " .. GetString(NMGH_UI_CAMPAIGN_QUEUE_PREFIX) .. string.format("%4s", Addon.FormatShortTime(queueSeconds))
            end
            if queueSeconds > maxQueueSeconds then maxQueueSeconds = queueSeconds end
        elseif endSeconds > 0 then
            infoText = Addon.FormatShortTime(endSeconds)
        end
        if row.infoLabel then 
            row.infoLabel:SetText(infoText)
            row.infoLabel:ClearAnchors()
            row.infoLabel:SetAnchor(LEFT, row, LEFT, 330 + (3 * 55) - 18, 0)
        end

        -- Alliance icons
        local adPop, epPop, dcPop = 0, 0, 0
        if GetSelectionCampaignPopulationData then
            adPop = GetSelectionCampaignPopulationData(index, 1)
            epPop = GetSelectionCampaignPopulationData(index, 2)
            dcPop = GetSelectionCampaignPopulationData(index, 3)
        end
        
        local iconSize = 20
        local iconSpacing = 4
        local pops = {adPop, epPop, dcPop}
        for i, icon in ipairs(row.allianceIcons) do
            icon:ClearAnchors()
            icon:SetAnchor(RIGHT, row, RIGHT, -( (3-i) * (iconSize + iconSpacing) + 5), 0)
            setAllianceTexture(icon, i, pops[i])
        end

        yOffset = yOffset + rowHeight + spacing
    end

    local totalHeight = numCampaigns * (rowHeight + spacing)
    parent:SetHeight(totalHeight)
    self.campaignDirty = false
end

function UI:CreatePledgesContent()
    local container = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgesContainer", self.content, CT_CONTROL)
    local cw = (self.content and self.content.GetWidth and self.content:GetWidth()) or 680
    local ch = (self.content and self.content.GetHeight and self.content:GetHeight()) or 375
    container:SetDimensions(math.max(200, cw - 20), math.max(200, ch - 20))
    container:SetAnchor(TOPLEFT, self.content, TOPLEFT, 10, 10)

    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    local crimson = (uiColors and uiColors.CRIMSON) or {0.8, 0.2, 0.3, 1}
    local tabActiveEdge = (uiColors and uiColors.TAB_ACTIVE_EDGE) or {0.9, 0.3, 0.4, 0.8}

    local title = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgesTitle", container, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetText(GetString(NMGH_PLEDGES_TITLE))
    title:SetAnchor(TOP, container, TOP, 0, 15)
    title:SetColor(unpack(crimson))
    
    local description = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgesDescription", container, CT_LABEL)
    description:SetFont("ZoFontGame")
    description:SetText(GetString(NMGH_PLEDGES_DESCRIPTION))
    description:SetAnchor(TOP, title, BOTTOM, 0, 10)
    description:SetWidth(620)
    description:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    description:SetColor(0.9, 0.9, 0.9, 1)

    local yOffset = 100
    local boxWidth = 200
    local boxHeight = 100
    local spacing = 15
    local totalWidth = (boxWidth * 3) + (spacing * 2)
    local startX = (660 - totalWidth) / 2

    self.pledgeLabels = {}
    for i = 1, 3 do
        local pledgeBox = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgeBox" .. i, container, CT_CONTROL)
        pledgeBox:SetDimensions(boxWidth, boxHeight)
        pledgeBox:SetAnchor(TOPLEFT, container, TOPLEFT, startX + (i - 1) * (boxWidth + spacing), yOffset)
        
        local pledgeBg = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgeBox" .. i .. "_BG", pledgeBox, CT_BACKDROP)
        pledgeBg:SetAnchorFill()
        pledgeBg:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Match home buttons
        pledgeBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1) -- Power of 2 dimensions
        pledgeBg:SetEdgeColor(unpack(crimson)) -- Crimson edges
        pledgeBg:SetInsets(2, 2, -2, -2) -- Match home buttons
        
        local label = WINDOW_MANAGER:CreateControl("NMGuildHall_PledgeLabel" .. i, pledgeBox, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetAnchorFill()
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetText(GetString(NMGH_UI_LOADING))
        
        self.pledgeLabels[i] = label

        -- Hover effect
        pledgeBox:SetMouseEnabled(true)
        pledgeBox:SetHandler("OnMouseEnter", function()
            pledgeBg:SetEdgeColor(unpack(tabActiveEdge))
        end)
        pledgeBox:SetHandler("OnMouseExit", function()
            pledgeBg:SetEdgeColor(unpack(crimson))
        end)
    end
    
    container:SetHidden(true)
    self.contentContainers.pledges = container
end

function UI:UpdatePledges()
    local Constants = Addon and Addon.Constants
    local pled = NMGuildHallPledges
    if not pled or not pled.dailies then 
        local log = UILogger()
        if log then
            log:Error(GetString(NMGH_ERR_PLEDGE_DATA_MISSING))
        end
        return 
    end
    
    local pledgeConfig = Constants and Constants.QUESTS
    local originTimestamp = (pledgeConfig and pledgeConfig.PLEDGE_ORIGIN_TIMESTAMP) or 1615168800
    local secondsPerDay = (pledgeConfig and pledgeConfig.SECONDS_PER_DAY) or 86400
    local daysSinceOrigin = math.floor((GetTimeStamp() - originTimestamp) / secondsPerDay)
    local npcCount = math.min(#pled.dailies, 3)
    
    for i = 1, npcCount do
        if self.pledgeLabels[i] and pled.dailies[i] then
            local row = pled.dailies[i]
            local maxIds = #row
            local actualId = 1 + (daysSinceOrigin % maxIds)
            local entry = row[actualId]
            local pledgeName = entry
            if type(entry) == "table" then
                pledgeName = entry[1]
            end
            local npcName = pled.npcNames[i]
            local crimson = (Constants and Constants.UI and Constants.UI.COLORS and Constants.UI.COLORS.CRIMSON_TEXT) or "|cCC334C"
            
            if pledgeName then
                self.pledgeLabels[i]:SetText("|cffffff" .. (pledgeName or GetString(NMGH_UI_UNKNOWN)) .. "|r\n" .. crimson .. (npcName or GetString(NMGH_UI_UNKNOWN_NPC)) .. "|r")
            else
                self.pledgeLabels[i]:SetText("|cffffff" .. (pledgeName or GetString(NMGH_UI_UNKNOWN)) .. "|r\n" .. (npcName or GetString(NMGH_UI_UNKNOWN_NPC)))
            end
        end
    end
end

function UI:UpdateGroupContent()
    local containerName = "NMGuildHall_GroupContainer"
    
    -- 1. Ensure the group container exists
    if not self.contentContainers.group then
        local container = WINDOW_MANAGER:CreateControl(containerName, self.content, CT_CONTROL)
        local cw = (self.content and self.content.GetWidth and self.content:GetWidth()) or 680
        local ch = (self.content and self.content.GetHeight and self.content:GetHeight()) or 375
        container:SetDimensions(math.max(200, cw - 20), math.max(200, ch - 20))
        container:SetAnchor(TOPLEFT, self.content, TOPLEFT, 10, 10)
        container:SetHidden(true)
        self.contentContainers.group = container
    end
    
    local container = self.contentContainers.group
    
    -- 2. Release previously created group buttons and reset counter
    if self.groupButtonPool then
        self.groupButtonPool:ReleaseAllObjects()
    end
    self.actionButtonCounter = 0
    
    -- 3. Define the content (build content once)
    local noGroupTextName = containerName .. "_NoGroupText"
    local noGroupText = WINDOW_MANAGER:GetControlByName(noGroupTextName)

    if not IsUnitGrouped("player") then
        if not noGroupText then
            noGroupText = WINDOW_MANAGER:CreateControl(noGroupTextName, container, CT_LABEL)
            noGroupText:SetFont("ZoFontWinH4")
            noGroupText:SetAnchor(CENTER, container, CENTER, 0, 0)
            noGroupText:SetColor(0.8, 0.8, 0.8, 1)
            noGroupText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        noGroupText:SetText(GetString(NMGH_CHAT_NOT_IN_GROUP))
        noGroupText:SetHidden(false)
    else
        if noGroupText then noGroupText:SetHidden(true) end
        
        -- Add buttons dynamically
        local yOffset = 70
        local xOffset = -150
        
        -- Share all dailies
        self:AcquireGroupActionButton(
            container, xOffset, yOffset,
            GetString(NMGH_BUTTON_SHARE_ALL_DAILIES),
            "EsoUI/Art/Compass/quest_icon_assisted.dds",
            function() if Addon.Quests then Addon.Quests:ShareAllDailies() end end
        )

        -- Share zone dailies
        self:AcquireGroupActionButton(
            container, -xOffset, yOffset,
            GetString(NMGH_BUTTON_SHARE_ZONE_DAILIES),
            "EsoUI/Art/Compass/quest_icon_assisted.dds",
            function() if Addon.Quests then Addon.Quests:ShareZoneDailies() end end
        )

        yOffset = yOffset + 80

        -- Jump to leader
        self:AcquireGroupActionButton(
            container, 0, yOffset,
            GetString(NMGH_BUTTON_JUMP_LEADER),
            "EsoUI/Art/Compass/groupleader.dds",
            function()
                JumpToGroupLeader()
                self:Hide()
            end
        )

        yOffset = yOffset + 80

        -- Leave group
        local leaveBtn = self:AcquireGroupActionButton(
            container, 0, yOffset,
            GetString(NMGH_BUTTON_LEAVE_GROUP),
            "EsoUI/Art/Contacts/Gamepad/gp_social_status_dnd.dds",
            function()
                GroupLeave()
                zo_callLater(function()
                    if self.currentTab == "group" then
                        self:UpdateGroupContent()
                    end
                end, 100)
            end
        )
        if leaveBtn and leaveBtn.label and leaveBtn.background then
            leaveBtn.label:SetColor(0.85, 0.25, 0.25, 1)
            leaveBtn.background:SetEdgeColor(0.85, 0.25, 0.25, 0.5)
        end
    end
    
    -- Ensure container is visible if this is the current tab
    if self.currentTab == "group" then
        container:SetHidden(false)
    end
    
    self.groupContentInitialized = true
end

-- Helper for standardized text color based on semantic name
function UI:GetTextColor(colorRef)
    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    
    if not colorRef or not uiColors then
        return {1, 1, 1, 1}
    end
    
    local color = uiColors[colorRef]
    if not color then
        -- Default to crimson if semantic name not found
        return uiColors.CRIMSON or {0.8, 0.2, 0.3, 1}
    end
    
    return color
end

function UI:RefreshTeleportList(searchText)
    local Constants = Addon and Addon.Constants
    if not self.teleportScrollChild then
        if Addon and Addon.Message then
            Addon.Message:For("UI"):Error(GetString(NMGH_ERR_TELEPORT_SCROLL_MISSING))
        end
        return
    end

    -- If teleport data isn't loaded, this is a real error (not an empty search result).
    if not NMGuildHallTeleportData or not NMGuildHallTeleportData.TeleportList then
        if Addon and Addon.Message then
            Addon.Message:For("UI"):Error(GetString(NMGH_ERR_TELEPORT_DATA_MISSING))
        end
        return
    end

    local parent = self.teleportScrollChild
    local emptyName = "NMGuildHall_TeleportEmpty"
    local emptyLabel = WINDOW_MANAGER:GetControlByName(emptyName)
    if emptyLabel then
        emptyLabel:SetHidden(true)
    end

    -- Release button pool
    if self.teleportButtonPool then
        local success, err = pcall(function()
            self.teleportButtonPool:ReleaseAllObjects()
        end)
        if not success then
            if Addon and Addon.Message then
                Addon.Message:For("UI"):Warn(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = "teleport buttons"})
            end
            return
        end
    else
        if Addon and Addon.Message then
            Addon.Message:For("UI"):Error(GetString(NMGH_ERR_TELEPORT_POOL_NOT_INIT))
        end
        return
    end

    -- Acquire teleport data safely
    local teleportData
    local success, err = pcall(function()
        teleportData = (Addon.Teleport and Addon.Teleport.CreateTeleportEntryList) and Addon.Teleport:CreateTeleportEntryList(searchText or "") or {}
    end)
    
    if not success or not teleportData then
        if Addon and Addon.Message then
            Addon.Message:For("UI"):Warn(GetString(NMGH_ERR_TELEPORT_DATA_MISSING))
        end
        return
    end

    -- Valid state: search can yield zero results. Show an empty state instead of warning.
    if #teleportData == 0 then
        if not emptyLabel then
            emptyLabel = WINDOW_MANAGER:CreateControl(emptyName, parent, CT_LABEL)
            emptyLabel:SetFont("ZoFontGame")
            emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            emptyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            emptyLabel:SetColor(0.8, 0.8, 0.8, 1)
            emptyLabel:SetDimensions(640, 40)
        end
        emptyLabel:SetAnchor(TOP, parent, TOP, 0, 0)
        emptyLabel:SetText(GetString(NMGH_TELEPORT_NONE_FOUND))
        emptyLabel:SetHidden(false)
        parent:SetHeight(40)
        return
    end

    local uiConfig = Constants and Constants.UI
    local btnWidth = (uiConfig and uiConfig.BUTTON_WIDTH) or 300
    local btnHeight = (uiConfig and uiConfig.BUTTON_HEIGHT) or 42
    local xPadding = 20
    local yPadding = 10
    local buttonsPerRow = 2

    -- Static icon table (avoid rebuilding it per entry)
    local iconPaths = {
        ["Ald"] = "esoui/art/compass/ava_flagaldmeri.dds",
        ["Dag"] = "esoui/art/compass/ava_flagdaggerfall.dds",
        ["Ebon"] = "esoui/art/compass/ava_flagebonheart.dds",
        ["Neu"] = "esoui/art/compass/ava_flagneutral.dds",
        ["Crown"] = "esoui/art/currency/currency_crown.dds"
    }

    for i, entry in ipairs(teleportData) do
        -- Calculate row and column
        local col = (i - 1) % buttonsPerRow
        local row = math.floor((i - 1) / buttonsPerRow)
        local xPos = col * (btnWidth + xPadding)
        local yPos = row * (btnHeight + yPadding)

        -- Acquire button from pool with error handling
        local btn
        local success, err = pcall(function()
            btn = self.teleportButtonPool:AcquireObject()
        end)
        
        if not success or not btn then
            if Addon and Addon.Message then
                Addon.Message:For("UI"):Error(GetString(NMGH_ERR_TELEPORT_BTN_ACQUIRE_FAILED), {error = tostring(err)})
            end
            break
        end

        -- Position button
        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, self.teleportScrollChild, TOPLEFT, xPos, yPos)

        -- Update appearance based on zone data
        if entry.available then
            btn.background:SetCenterColor(0.05, 0.18, 0.08, 0.9) -- Green background for available
            btn.background:SetEdgeTexture("", 1, 1, 0, 0) -- No edges
            btn.background:SetEdgeColor(0, 0, 0, 0) -- Transparent edges
            btn.label:SetColor(1, 1, 1, 1)
        else
            btn.background:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Gray background for unavailable
            btn.background:SetEdgeTexture("", 1, 1, 0, 0) -- No edges
            btn.background:SetEdgeColor(0, 0, 0, 0) -- Transparent edges
            btn.label:SetColor(1, 1, 1, 1) -- White text for consistency
        end

        -- Set icon and text separately
        
        -- Set icon texture from zone data
        if entry.icon and btn.icon then
            local iconKey = entry.icon

            local texturePath = iconPaths[iconKey]
            
            if texturePath then
                btn.icon:SetTexture(texturePath)
                btn.icon:SetHidden(false)
            else
                btn.icon:SetHidden(true)
            end
        else
            if btn.icon then
                btn.icon:SetHidden(true)
            end
        end

        -- entry.label may include ESO color codes (|c...|r). Avoid treating textColor as a constants key here.
        btn.label:SetText(entry.label or GetString(NMGH_UI_NO_NAME))

        -- Safe button click handler
        btn:SetHandler("OnClicked", function()
            if entry.callback and type(entry.callback) == "function" then
                local success, err = pcall(entry.callback)
                if not success then
                        if Addon and Addon.Message then
                            Addon.Message:For("UI"):Error(GetString(NMGH_ERR_ACTION_BTN_CALLBACK), {error = tostring(err)})
                        end
                    end
            end
        end)

        -- Clean mouse hover effects without edges
        btn:SetHandler("OnMouseEnter", function()
            if entry.available then
                btn.background:SetCenterColor(0.08, 0.25, 0.12, 0.95) -- Brighter green hover
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
            else
                btn.background:SetCenterColor(0.15, 0.15, 0.20, 0.95) -- Lighter gray hover
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
            end
        end)
        
        btn:SetHandler("OnMouseExit", function()
            if entry.available then
                btn.background:SetCenterColor(0.05, 0.18, 0.08, 0.9) -- Restore to green
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
            else
                btn.background:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Restore to gray
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
            end
        end)

        btn:SetHandler("OnMouseDown", function()
            if entry.available then
                btn.background:SetCenterColor(0.03, 0.12, 0.05, 1.0) -- Darkest green pressed
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
                btn.background:SetInsets(1, 1, -1, -1) -- Compress when pressed
            end
        end)

        btn:SetHandler("OnMouseUp", function()
            if entry.available then
                btn.background:SetCenterColor(0.08, 0.25, 0.12, 0.95) -- Back to hover green
                btn.background:SetEdgeColor(0, 0, 0, 0) -- No edges
                btn.background:SetInsets(2, 2, -2, -2) -- Restore normal insets
            end
        end)

        btn:SetHidden(false)
    end

    -- Resize scroll child to fit buttons
    local totalRows = math.ceil(#teleportData / buttonsPerRow)
    local totalHeight = totalRows * (btnHeight + yPadding)
    self.teleportScrollChild:SetHeight(totalHeight)
end
