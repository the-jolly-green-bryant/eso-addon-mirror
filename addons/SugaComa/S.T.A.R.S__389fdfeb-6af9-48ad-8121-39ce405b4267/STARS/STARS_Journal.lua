STARS_JOURNAL = STARS_JOURNAL or {}
local Journal = STARS_JOURNAL

local SCENE_NAME = "starsJournalGamepad"
local MENU_ENTRY_ID = 997
local ICON = "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds"

if type(ZO_CreateStringId) == "function" then
    ZO_CreateStringId("SI_BINDING_NAME_STARS_TOGGLE_STATS_SHEET", "Open STARS Journal")
end

function STARS_ToggleStats()
    if not SCENE_MANAGER or not STARS_JOURNAL_GAMEPAD_SCENE then return end
    if SCENE_MANAGER:IsShowing(SCENE_NAME) then
        SCENE_MANAGER:ShowBaseScene()
    else
        SCENE_MANAGER:Show(SCENE_NAME)
    end
end

local PAGE_PROFILE = 1
local PAGE_CAMPAIGN = 2
local PAGE_HISTORY = 3
local PAGE_LEGACY = 4
local PAGE_UNDERWORLD = 5
local PAGE_PRESTIGE = 6
local PAGE_CHRONICLE = 7
local PAGE_ADVENTURES = 8
local PAGE_CORRESPONDENCE = 9
local PAGE_LIBRARY = 10

STARS_Journal_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

local function FormatNumber(value)
    value = math.floor(tonumber(value) or 0)
    return ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(value) or tostring(value)
end

local function AddToJournalMenu()
    if Journal.menuAdded or not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES then return false end

    local journalEntry
    for _, entry in ipairs(ZO_MENU_ENTRIES) do
        if entry.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
            journalEntry = entry
            break
        end
    end
    if not journalEntry then return false end

    local menuData = {
        name = "STARS",
        icon = ICON,
        scene = SCENE_NAME,
    }

    local entry = ZO_GamepadEntryData:New(menuData.name, menuData.icon)
    entry:SetIconTintOnSelection(true)
    if entry.SetIconDisabledTintOnSelection then
        entry:SetIconDisabledTintOnSelection(true)
    end
    entry.data = menuData
    entry.id = MENU_ENTRY_ID

    if journalEntry.subMenu then
        table.insert(journalEntry.subMenu, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end

    Journal.menuAdded = true
    return true
end

function STARS_Journal_Gamepad:New(control)
    local object = ZO_Object.New(self)
    object:Initialize(control)
    return object
end

function STARS_Journal_Gamepad:ApplyContentFrameAnchors()
    if not self.contentFrame or not GuiRoot then return end

    local width = GuiRoot:GetWidth() or 0
    local height = GuiRoot:GetHeight() or 0
    if width <= 0 or height <= 0 then return end

    -- 0.5.16: use ZOS's actual Q2+Q3+Q4 geometry.
    -- Q1 remains the inherited parametric navigation panel. STARS page content
    -- begins at the Q2 left edge and now extends through the Q4 right edge.
    local horizontalPadding = 20
    local topPadding = 135
    local bottomPadding = 110

    local left
    local right
    local geometrySource = "fallback"

    -- Best source: the live ZOS Q2_3_4 background control defined by
    -- GamepadQuadrants.xml. Hidden controls still retain their layout bounds.
    local q234 = ZO_SharedGamepadNavQuadrant_2_3_4_Background
    if q234 and q234.GetLeft and q234.GetRight then
        local bgLeft = q234:GetLeft()
        local bgRight = q234:GetRight()
        if bgLeft and bgRight and bgRight > bgLeft then
            left = bgLeft + horizontalPadding
            right = bgRight - horizontalPadding
            geometrySource = "Q2_3_4 background"
        end
    end

    -- Second choice: use the exact ZOS quadrant offsets directly.
    if not left or not right then
        local q2LeftOffset = tonumber(ZO_GAMEPAD_QUADRANT_2_LEFT_OFFSET)
        local q4RightOffset = tonumber(ZO_GAMEPAD_QUADRANT_4_RIGHT_OFFSET)
        if q2LeftOffset and q4RightOffset then
            left = q2LeftOffset + horizontalPadding
            right = width + q4RightOffset - horizontalPadding
            geometrySource = "Q2/Q4 offsets"
        end
    end

    -- Compatibility fallback for clients where the combined quadrant globals
    -- are unavailable. This still reserves Q1 using the ZOS panel width, but
    -- unlike 0.5.15 it extends content to the safe right edge (through Q4).
    if not left or not right or right <= left then
        local panelWidth = tonumber(ZO_GAMEPAD_PANEL_WIDTH)
        local safeInsetX = tonumber(ZO_GAMEPAD_SAFE_ZONE_INSET_X) or 0
        if panelWidth and panelWidth > 0 then
            left = safeInsetX + panelWidth + horizontalPadding
            right = width - safeInsetX - horizontalPadding
            geometrySource = "panel/safe fallback"
        else
            local quadrantWidth = width / 4
            left = quadrantWidth + horizontalPadding
            right = width - horizontalPadding
            geometrySource = "quarter fallback"
        end
    end

    self.contentFrame:ClearAnchors()
    self.contentFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, topPadding)
    self.contentFrame:SetAnchor(BOTTOMRIGHT, GuiRoot, TOPLEFT, right, height - bottomPadding)
    self:ApplyResponsiveLayout()

    if STARS and STARS.debug then
        d(string.format("[STARS] Journal geometry 0.5.16: source=%s root=%.1fx%.1f left=%.1f right=%.1f width=%.1f",
            geometrySource, width, height, left, right, right - left))
    end
end

function STARS_Journal_Gamepad:ApplyThreeColumnLayout(page, topY, bodyHeight, bodyGap)
    if not page or not self.contentFrame then return end
    local width = self.contentFrame:GetWidth() or 0
    if width <= 0 then return end

    local margin = 10
    local gap = 28
    local colWidth = math.max(240, math.floor((width - (margin * 2) - (gap * 2)) / 3))
    for i = 1, 3 do
        local x = margin + ((i - 1) * (colWidth + gap))
        local header = page:GetNamedChild("Col" .. i .. "Header")
        local body = page:GetNamedChild("Col" .. i .. "Body")
        local icon = page:GetNamedChild("Col" .. i .. "Icon")
        if icon then
            icon:ClearAnchors()
            icon:SetDimensions(96, 96)
            icon:SetAnchor(TOPLEFT, page, TOPLEFT, x, topY)
        end
        if header then
            header:ClearAnchors()
            if icon then
                header:SetAnchor(TOPLEFT, page, TOPLEFT, x + 112, topY + 4)
                header:SetDimensions(math.max(120, colWidth - 112), 92)
            else
                header:SetAnchor(TOPLEFT, page, TOPLEFT, x, topY)
                header:SetDimensions(colWidth, 64)
            end
        end
        if body and header then
            body:ClearAnchors()
            if icon then
                body:SetAnchor(TOPLEFT, page, TOPLEFT, x, topY + 112)
            else
                body:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, bodyGap or 14)
            end
            body:SetDimensions(colWidth, bodyHeight or 470)
        end
    end
end

function STARS_Journal_Gamepad:ApplyChronicleLayout()
    local page = self.chroniclePage
    if not page or not self.contentFrame then return end
    local width = self.contentFrame:GetWidth() or 0
    local height = self.contentFrame:GetHeight() or 0
    if width <= 0 or height <= 0 then return end

    -- 0.5.20-test7: remove the redundant shared date banner and use the
    -- freed vertical space to lift both floating cards. Keep their established
    -- height so the layout feels lighter rather than simply larger. The Story
    -- card is narrower to preserve more open centre space for the live character
    -- and Persona animations.
    local outerMargin = 18
    local cardTop = 8
    local bottomMargin = 10
    local availableWidth = width - (outerMargin * 2)

    local leftCardWidth = math.min(405, math.floor(availableWidth * 0.36))
    local rightCardWidth = math.min(470, math.floor(availableWidth * 0.39))
    local minimumCentreGap = 165
    if availableWidth - leftCardWidth - rightCardWidth < minimumCentreGap then
        local shortage = minimumCentreGap - (availableWidth - leftCardWidth - rightCardWidth)
        rightCardWidth = math.max(360, rightCardWidth - shortage)
    end

    local leftX = outerMargin
    local rightX = width - outerMargin - rightCardWidth
    -- Preserve the test6 card height while shifting the cards upward.
    local cardHeight = math.max(540, height - 82)

    local memoryBackdrop = page:GetNamedChild("MemoryBackdrop")
    if memoryBackdrop then
        memoryBackdrop:ClearAnchors()
        memoryBackdrop:SetAnchor(TOPLEFT, page, TOPLEFT, leftX, cardTop)
        memoryBackdrop:SetDimensions(leftCardWidth, cardHeight)
        if memoryBackdrop.SetCenterColor then memoryBackdrop:SetCenterColor(0.02, 0.02, 0.02, 0.70) end
        if memoryBackdrop.SetEdgeColor then memoryBackdrop:SetEdgeColor(0.73, 0.58, 0.28, 0.84) end
    end

    local storyBackdrop = page:GetNamedChild("StoryBackdrop")
    if storyBackdrop then
        storyBackdrop:ClearAnchors()
        storyBackdrop:SetAnchor(TOPLEFT, page, TOPLEFT, rightX, cardTop)
        storyBackdrop:SetDimensions(rightCardWidth, cardHeight)
        if storyBackdrop.SetCenterColor then storyBackdrop:SetCenterColor(0.02, 0.02, 0.02, 0.70) end
        if storyBackdrop.SetEdgeColor then storyBackdrop:SetEdgeColor(0.73, 0.58, 0.28, 0.84) end
    end

    local title = page:GetNamedChild("Title")
    local subtitle = page:GetNamedChild("Subtitle")
    local icon = page:GetNamedChild("MemoryIcon")
    local kicker = page:GetNamedChild("MemoryKicker")
    local cardName = page:GetNamedChild("MemoryCardName")
    local name = page:GetNamedChild("MemoryName")
    local meta = page:GetNamedChild("MemoryMeta")
    local description = page:GetNamedChild("MemoryDescription")
    local rewardHeader = page:GetNamedChild("MemoryRewardHeader")
    local reward = page:GetNamedChild("MemoryReward")
    local indicator = page:GetNamedChild("PageIndicator")
    local storyHeader = page:GetNamedChild("StoryHeader")
    local storyBody = page:GetNamedChild("StoryBody")

    local leftPad = 24
    local rightPad = 28
    local leftContentWidth = leftCardWidth - (leftPad * 2)
    local rightContentWidth = rightCardWidth - (rightPad * 2)
    local isFrontPage = (tonumber(self.chroniclePageIndex) or 1) == 1

    -- The milestone overview already tells the player how many memories are
    -- waiting today, so the shared date/count banner is intentionally removed.
    if subtitle then
        subtitle:SetHidden(true)
    end

    -- Left card identity.
    if title then
        title:ClearAnchors()
        title:SetAnchor(TOPLEFT, page, TOPLEFT, leftX + leftPad, cardTop + 15)
        title:SetDimensions(leftContentWidth, 52)
    end

    local iconSize = math.min(305, leftContentWidth)
    if icon then
        icon:ClearAnchors()
        icon:SetDimensions(iconSize, iconSize)
        icon:SetAnchor(TOP, page, TOPLEFT, leftX + math.floor(leftCardWidth / 2), cardTop + 145)
    end
    if kicker then
        kicker:ClearAnchors()
        kicker:SetAnchor(TOPLEFT, page, TOPLEFT, leftX + leftPad, cardTop + 78)
        kicker:SetDimensions(leftContentWidth, 52)
    end
    if cardName then
        cardName:ClearAnchors()
        cardName:SetAnchor(TOPLEFT, page, TOPLEFT, leftX + leftPad, cardTop + 465)
        -- Memory titles get enough vertical room for two or three wrapped lines.
        cardName:SetDimensions(leftContentWidth, 118)
    end
    if description then
        description:ClearAnchors()
        description:SetAnchor(TOPLEFT, page, TOPLEFT, leftX + leftPad, cardTop + 590)
        description:SetDimensions(leftContentWidth, math.max(82, cardHeight - 700))
    end
    if meta then
        meta:ClearAnchors()
        if isFrontPage then
            meta:SetAnchor(TOPLEFT, page, TOPLEFT, leftX + leftPad, cardTop + 125)
            meta:SetDimensions(leftContentWidth, cardHeight - 175)
        else
            -- Category lives on the Chronicle card and may wrap across several lines.
            meta:SetAnchor(BOTTOMLEFT, page, TOPLEFT, leftX + leftPad, cardTop + cardHeight - 28)
            meta:SetDimensions(leftContentWidth, 112)
        end
    end

    -- Chronicle numbering now lives directly in the left-card title:
    -- CHRONICLE 0 for the overview, then CHRONICLE 1..N for memories.
    -- ESO's native L1/R1 keybind strip remains the only navigation footer.
    if indicator then
        indicator:SetHidden(true)
    end

    -- Right detail card.
    if storyHeader then
        storyHeader:ClearAnchors()
        storyHeader:SetAnchor(TOPLEFT, page, TOPLEFT, rightX + rightPad, cardTop + 18)
        storyHeader:SetDimensions(rightContentWidth, 54)
    end
    if name then
        name:ClearAnchors()
        name:SetAnchor(TOPLEFT, page, TOPLEFT, rightX + rightPad, cardTop + 82)
        name:SetDimensions(rightContentWidth, 86)
    end
    if storyBody then
        storyBody:ClearAnchors()
        if isFrontPage then
            storyBody:SetAnchor(TOPLEFT, page, TOPLEFT, rightX + rightPad, cardTop + 95)
            storyBody:SetDimensions(rightContentWidth, cardHeight - 130)
        else
            -- With the duplicate achievement title removed, The Story can begin
            -- immediately beneath the card heading and use nearly the full card.
            storyBody:SetAnchor(TOPLEFT, page, TOPLEFT, rightX + rightPad, cardTop + 88)
            storyBody:SetDimensions(rightContentWidth, cardHeight - 118)
        end
    end

    -- test6 renders reward information inside StoryBody so long titles, dyes,
    -- and collectible names can wrap into the remaining flexible card space.
    -- with Category / Achievement Points on shorter cards.
    if rewardHeader then rewardHeader:SetHidden(true) end
    if reward then reward:SetHidden(true) end
end

function STARS_Journal_Gamepad:ApplyResponsiveLayout()
    if not self.contentFrame then return end
    self:ApplyChronicleLayout()
    self:ApplyThreeColumnLayout(self.profilePage, 120, 470, 16)
    self:ApplyThreeColumnLayout(self.campaignPage, 140, 450, 18)
    self:ApplyThreeColumnLayout(self.historyPage, 90, 500, 15)
    self:ApplyThreeColumnLayout(self.legacyPage, 130, 470, 18)
    self:ApplyThreeColumnLayout(self.underworldPage, 130, 470, 18)

    if self.campaignPage then
        local icon = self.campaignPage:GetNamedChild("RankIcon")
        if icon then
            icon:ClearAnchors()
            icon:SetDimensions(170, 170)
            icon:SetAnchor(TOPRIGHT, self.campaignPage, TOPRIGHT, -26, 0)
        end
    end

    if self.prestigePage then
        local width = self.contentFrame:GetWidth() or 0
        if width > 0 then
            local badge = self.prestigePage:GetNamedChild("Badge")
            local title = self.prestigePage:GetNamedChild("Title")
            local tier = self.prestigePage:GetNamedChild("Tier")
            local details = self.prestigePage:GetNamedChild("Details")
            local legacyHeader = self.prestigePage:GetNamedChild("LegacyHeader")
            local legacyDetails = self.prestigePage:GetNamedChild("LegacyDetails")
            local footer = self.prestigePage:GetNamedChild("Footer")
            local left = 40
            local right = 40
            local badgeSpace = 220
            local upperWidth = math.max(500, width - left - right - badgeSpace)

            if badge then
                badge:ClearAnchors()
                badge:SetDimensions(180, 180)
                badge:SetAnchor(TOPRIGHT, self.prestigePage, TOPRIGHT, -45, 15)
            end
            if title then
                title:ClearAnchors()
                title:SetAnchor(TOPLEFT, self.prestigePage, TOPLEFT, left, 20)
                title:SetDimensions(upperWidth, 80)
            end
            if tier and title then
                tier:ClearAnchors()
                tier:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 0)
                tier:SetDimensions(upperWidth, 55)
            end
            if details and tier then
                details:ClearAnchors()
                details:SetAnchor(TOPLEFT, tier, BOTTOMLEFT, 0, 35)
                details:SetDimensions(upperWidth, 235)
            end
            if legacyHeader then
                legacyHeader:ClearAnchors()
                legacyHeader:SetAnchor(TOPLEFT, self.prestigePage, TOPLEFT, left, 410)
                legacyHeader:SetDimensions(width - left - right, 55)
            end
            if legacyDetails and legacyHeader then
                legacyDetails:ClearAnchors()
                legacyDetails:SetAnchor(TOPLEFT, legacyHeader, BOTTOMLEFT, 0, 8)
                legacyDetails:SetDimensions(width - left - right, 110)
            end
            if footer and legacyDetails then
                footer:ClearAnchors()
                footer:SetAnchor(TOPLEFT, legacyDetails, BOTTOMLEFT, 0, 20)
                footer:SetDimensions(width - left - right, 90)
            end
        end
    end
end

function STARS_Journal_Gamepad:Initialize(control)
    self.control = control
    self.contentFrame = control:GetNamedChild("ContentFrame")
    self.chroniclePage = self.contentFrame and self.contentFrame:GetNamedChild("ChroniclePage")
    self.profilePage = self.contentFrame and self.contentFrame:GetNamedChild("ProfilePage")
    self.campaignPage = self.contentFrame and self.contentFrame:GetNamedChild("CampaignPage")
    self.historyPage = self.contentFrame and self.contentFrame:GetNamedChild("HistoryPage")
    self.legacyPage = self.contentFrame and self.contentFrame:GetNamedChild("LegacyPage")
    self.underworldPage = self.contentFrame and self.contentFrame:GetNamedChild("UnderworldPage")
    self.prestigePage = self.contentFrame and self.contentFrame:GetNamedChild("PrestigePage")
    self.adventuresPage = self.contentFrame and self.contentFrame:GetNamedChild("AdventuresPage")
    self.adventurePageIndex = 1

    -- 0.5.16 ZOS Q2+Q3+Q4 geometry: the inherited parametric screen remains
    -- Quadrant 1 navigation-only; STARS content uses the live combined quadrant bounds.
    self:ApplyContentFrameAnchors()

    STARS_JOURNAL_GAMEPAD_FRAGMENT = ZO_FadeSceneFragment:New(control)
    -- The fragment owns layout and content only. Keybind groups are managed
    -- exclusively by OnShowing / OnHiding so the same descriptor can never be
    -- added through two independent lifecycles.
    STARS_JOURNAL_GAMEPAD_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:ApplyContentFrameAnchors()
            if self.mainList then
                self:SetCurrentList(self.mainList)
                self:RefreshList()
                self:ShowPage(self.currentPage or PAGE_CHRONICLE)
            end
        end
    end)

    STARS_JOURNAL_GAMEPAD_SCENE = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    -- Native background for the Journal information area. Prefer the live
    -- Q2+Q3+Q4 fragment so the page container and background share the same
    -- ZOS quadrant geometry; retain Q2+Q3 as a compatibility fallback.
    if GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT then
        STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT)
    elseif GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT then
        STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
    end
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT)
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    if FRAME_EMOTE_FRAGMENT_SOCIAL then
        STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
    end
    STARS_JOURNAL_GAMEPAD_SCENE:AddFragment(STARS_JOURNAL_GAMEPAD_FRAGMENT)

    local ACTIVATE_ON_SHOW = true
    ZO_Gamepad_ParametricList_Screen.Initialize(
        self,
        control,
        ZO_GAMEPAD_HEADER_TABBAR_CREATE,
        ACTIVATE_ON_SHOW,
        STARS_JOURNAL_GAMEPAD_SCENE
    )
    self:SetListsUseTriggerKeybinds(true)
end

function STARS_Journal_Gamepad:OnDeferredInitialize()
    self.headerData = {
        titleText = "STARS",
        subtitleText = "Your Story in Tamriel",
        tabBarEntries = nil,
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData, true)

    self.mainList = self:AddList("Pages", function(list)
        list:AddDataTemplate(
            "ZO_GamepadItemSubEntryTemplate",
            ZO_SharedGamepadEntry_OnSetup,
            ZO_GamepadMenuEntryTemplateParametricListFunction
        )
        list:SetNoItemText("No STARS pages available")
    end)

    if self.mainList and self.mainList.SetOnTargetDataChangedCallback then
        self.mainList:SetOnTargetDataChangedCallback(function(list, targetData)
            if targetData and targetData.starsPage then
                self:ShowPage(targetData.starsPage)
            end
        end)
    end

    self:InitializeKeybindStripDescriptors()
end

function STARS_Journal_Gamepad:GetChronicleMemoryCount()
    local chronicle = STARS and STARS.GetChronicleData and STARS:GetChronicleData() or {}
    local memories = chronicle.memories or chronicle.displayMemories or {}
    -- Chronicle page 1 is always the Story So Far overview.
    return #memories + 1
end

function STARS_Journal_Gamepad:ChangeChronicleMemory(delta)
    if self.currentPage ~= PAGE_CHRONICLE then return end
    local pageCount = self:GetChronicleMemoryCount()
    if pageCount <= 1 then return end

    local index = tonumber(self.chroniclePageIndex) or 1
    index = ((index - 1 + (tonumber(delta) or 0)) % pageCount) + 1
    self.chroniclePageIndex = index
    self:ShowPage(PAGE_CHRONICLE)
end


function STARS_Journal_Gamepad:GetModulesForPage(page)
    if not STARS then return {} end
    if page == PAGE_ADVENTURES and STARS.GetActiveAdventureModules then
        return STARS:GetActiveAdventureModules()
    elseif page == PAGE_CORRESPONDENCE and STARS.GetActiveCorrespondenceModules then
        return STARS:GetActiveCorrespondenceModules()
    elseif page == PAGE_LIBRARY and STARS.GetActiveLibraryModules then
        return STARS:GetActiveLibraryModules()
    end
    return {}
end

function STARS_Journal_Gamepad:GetCurrentModuleIndex(page)
    self.connectPageIndexes = self.connectPageIndexes or {}
    return tonumber(self.connectPageIndexes[page]) or 1
end

function STARS_Journal_Gamepad:SetCurrentModuleIndex(page, index)
    self.connectPageIndexes = self.connectPageIndexes or {}
    self.connectPageIndexes[page] = index
end

function STARS_Journal_Gamepad:ChangeConnectedModule(delta)
    local page = self.currentPage
    if page ~= PAGE_ADVENTURES and page ~= PAGE_CORRESPONDENCE and page ~= PAGE_LIBRARY then return end
    local modules = self:GetModulesForPage(page)
    local count = #modules
    if count <= 1 then return end
    local index = self:GetCurrentModuleIndex(page)
    index = ((index - 1 + (tonumber(delta) or 0)) % count) + 1
    self:SetCurrentModuleIndex(page, index)
    self:ShowPage(page)
end

function STARS_Journal_Gamepad:GetCurrentConnectedModule()
    local modules = self:GetModulesForPage(self.currentPage)
    local count = #modules
    if count == 0 then return nil end
    local index = self:GetCurrentModuleIndex(self.currentPage)
    if index > count then index = 1 elseif index < 1 then index = count end
    self:SetCurrentModuleIndex(self.currentPage, index)
    return modules[index]
end

function STARS_Journal_Gamepad:GetCurrentModuleEntryCount()
    local module = self:GetCurrentConnectedModule()
    if not module then return 0 end
    if type(module.GetEntryCount) == "function" then
        local ok, count = pcall(module.GetEntryCount, module)
        if ok then return math.max(0, tonumber(count) or 0) end
    end
    return 1
end

function STARS_Journal_Gamepad:ChangeConnectedEntry(delta)
    local module = self:GetCurrentConnectedModule()
    if not module then return end

    local realCount = self:GetCurrentModuleEntryCount()
    local totalCount = self:GetConnectedPresentedEntryCount()
    if totalCount <= 1 then return end

    local current = tonumber(module.entryIndex) or 1
    local nextIndex = current + delta
    if nextIndex < 1 then nextIndex = totalCount end
    if nextIndex > totalCount then nextIndex = 1 end

    -- STARS owns only the synthetic diagnostic entry.
    if self:IsDeveloperDiagnosticsEnabled() and nextIndex == realCount + 1 then
        module.entryIndex = nextIndex
    else
        -- When leaving the synthetic diagnostic page, restore the module to a
        -- real entry before asking the module to change entries.
        if current > realCount then
            module.entryIndex = (delta > 0) and realCount or 1
            current = module.entryIndex
        end

        if type(module.ChangeEntry) == "function" then
            local moduleDelta = nextIndex - current
            pcall(module.ChangeEntry, module, moduleDelta)
        else
            module.entryIndex = nextIndex
        end
    end

    self:ShowPage(self.currentPage)
end


function STARS_Journal_Gamepad:GetCurrentConnectedActions()
    local module = self:GetCurrentConnectedModule()
    if not module or not LibSTARSConnect or type(LibSTARSConnect.GetModuleActions) ~= "function" then
        return {}
    end
    return LibSTARSConnect:GetModuleActions(module.id)
end

function STARS_Journal_Gamepad:GetConnectedAction(slot)
    local actions = self:GetCurrentConnectedActions()
    return actions and actions[slot] or nil
end

function STARS_Journal_Gamepad:IsConnectedActionVisible(slot)
    local module = self:GetCurrentConnectedModule()
    local action = self:GetConnectedAction(slot)
    if not module or not action then return false end
    if type(action.visible) == "function" then
        local ok, visible = pcall(action.visible, module)
        return ok and visible ~= false
    end
    return true
end

function STARS_Journal_Gamepad:IsConnectedActionEnabled(slot)
    local module = self:GetCurrentConnectedModule()
    local action = self:GetConnectedAction(slot)
    if not module or not action then return false end
    if type(action.enabled) == "function" then
        local ok, enabled = pcall(action.enabled, module)
        return ok and enabled ~= false
    end
    return true
end

function STARS_Journal_Gamepad:InvokeConnectedAction(slot)
    local module = self:GetCurrentConnectedModule()
    local chatDebug = STARS and STARS.sv and STARS.sv.options and STARS.sv.options.developerChatDebug

    if not module then
        if chatDebug and d then d("[STARS Connect] No current connected module") end
        return
    end
    if not LibSTARSConnect or type(LibSTARSConnect.InvokeModuleAction) ~= "function" then
        if chatDebug and d then d("[STARS Connect] InvokeModuleAction unavailable") end
        return
    end

    local ok, err = LibSTARSConnect:InvokeModuleAction(module.id, slot)
    if not ok and chatDebug and d then
        d(string.format("[STARS Connect] %s action failed: %s", tostring(slot), tostring(err)))
    end

    self:ShowPage(self.currentPage)
end


function STARS_Journal_Gamepad:RefreshConnectedKeybinds()
    if not KEYBIND_STRIP or not self:IsSceneActive() then return end
    if self._connectedKeybindGroupActive and self:IsConnectedPage() and self.connectedKeybindStripDescriptor then
        pcall(function()
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.connectedKeybindStripDescriptor)
        end)
    end
end

function STARS_Journal_Gamepad:InitializeKeybindStripDescriptors()
    -- Normal STARS Journal controls. Connected-module action buttons are kept
    -- in a completely separate group so ESO never has to resolve duplicate
    -- X / Triangle descriptors inside the same keybind group.
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function()
                return self.currentPage == PAGE_CHRONICLE and self:GetChronicleMemoryCount() > 1
            end,
            callback = function()
                self:ChangeChronicleMemory(-1)
            end,
        },
        {
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function()
                return self.currentPage == PAGE_CHRONICLE and self:GetChronicleMemoryCount() > 1
            end,
            callback = function()
                self:ChangeChronicleMemory(1)
            end,
        },
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                local data = self.mainList and self.mainList:GetTargetData()
                if data and data.starsPage then
                    self:ShowPage(data.starsPage)
                end
            end,
        },
        {
            name = "View Veterancy Rewards",
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                return self.currentPage == PAGE_CAMPAIGN and self.veterancyHasUnclaimedRewards == true
            end,
            callback = function()
                if SCENE_MANAGER then
                    SCENE_MANAGER:Show("VeterancySceneGamepad")
                end
            end,
        },
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
        },
    }

    self.connectedKeybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Previous Module",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function()
                return #self:GetModulesForPage(self.currentPage) > 1
            end,
            callback = function()
                self:ChangeConnectedModule(-1)
            end,
        },
        {
            name = "Next Module",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function()
                return #self:GetModulesForPage(self.currentPage) > 1
            end,
            callback = function()
                self:ChangeConnectedModule(1)
            end,
        },
        {
            name = "Previous Entry",
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            visible = function()
                return self:GetConnectedPresentedEntryCount() > 1
            end,
            callback = function()
                self:ChangeConnectedEntry(-1)
            end,
        },
        {
            name = "Next Entry",
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            visible = function()
                return self:GetConnectedPresentedEntryCount() > 1
            end,
            callback = function()
                self:ChangeConnectedEntry(1)
            end,
        },
        {
            name = function()
                local action = self:GetConnectedAction("primary")
                return action and action.name or "Action"
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                return self:IsConnectedActionVisible("primary")
            end,
            enabled = function()
                return self:IsConnectedActionEnabled("primary")
            end,
            callback = function()
                self:InvokeConnectedAction("primary")
            end,
        },
        {
            name = function()
                local action = self:GetConnectedAction("secondary")
                return action and action.name or "Secondary"
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function()
                return self:IsConnectedActionVisible("secondary")
            end,
            enabled = function()
                return self:IsConnectedActionEnabled("secondary")
            end,
            callback = function()
                self:InvokeConnectedAction("secondary")
            end,
        },
        {
            name = function()
                local action = self:GetConnectedAction("tertiary")
                return action and action.name or "Tertiary"
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                return self:IsConnectedActionVisible("tertiary")
            end,
            enabled = function()
                return self:IsConnectedActionEnabled("tertiary")
            end,
            callback = function()
                self:InvokeConnectedAction("tertiary")
            end,
        },
        {
            name = function()
                local action = self:GetConnectedAction("utility")
                return action and action.name or "Utility"
            end,
            keybind = "UI_SHORTCUT_LEFT_STICK",
            visible = function()
                return self:IsConnectedActionVisible("utility")
            end,
            enabled = function()
                return self:IsConnectedActionEnabled("utility")
            end,
            callback = function()
                self:InvokeConnectedAction("utility")
            end,
        },
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
        },
    }
end

function STARS_Journal_Gamepad:IsConnectedPage(page)
    page = page or self.currentPage
    return page == PAGE_ADVENTURES or page == PAGE_CORRESPONDENCE or page == PAGE_LIBRARY
end

function STARS_Journal_Gamepad:IsSceneActive()
    local scene = STARS_JOURNAL_GAMEPAD_SCENE
    if not scene or not scene.GetState then return false end
    local state = scene:GetState()
    return state == SCENE_SHOWING or state == SCENE_SHOWN
end

function STARS_Journal_Gamepad:RefreshActiveKeybindGroup()
    if not KEYBIND_STRIP or not self:IsSceneActive() then return end

    local useConnected = self:IsConnectedPage()

    if self._connectedKeybindGroupActive and not useConnected then
        pcall(function()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.connectedKeybindStripDescriptor)
        end)
        self._connectedKeybindGroupActive = false
    end

    if self._normalKeybindGroupActive and useConnected then
        pcall(function()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
        end)
        self._normalKeybindGroupActive = false
    end

    if useConnected then
        if not self._connectedKeybindGroupActive then
            pcall(function()
                KEYBIND_STRIP:AddKeybindButtonGroup(self.connectedKeybindStripDescriptor)
            end)
            self._connectedKeybindGroupActive = true
        else
            pcall(function()
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.connectedKeybindStripDescriptor)
            end)
        end
    else
        if not self._normalKeybindGroupActive then
            pcall(function()
                KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            end)
            self._normalKeybindGroupActive = true
        else
            pcall(function()
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            end)
        end
    end
end


function STARS_Journal_Gamepad:OnShowing()
    ZO_Gamepad_ParametricList_Screen.OnShowing(self)
    self:RefreshActiveKeybindGroup()
end

function STARS_Journal_Gamepad:OnHiding()
    -- Remove both exact descriptor references unconditionally. This also cleans
    -- up safely if a previous refresh failed before its activity flag changed.
    if KEYBIND_STRIP then
        if self.keybindStripDescriptor then
            pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor) end)
        end
        if self.connectedKeybindStripDescriptor then
            pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.connectedKeybindStripDescriptor) end)
        end
    end
    self._normalKeybindGroupActive = false
    self._connectedKeybindGroupActive = false
    ZO_Gamepad_ParametricList_Screen.OnHiding(self)
end

function STARS_Journal_Gamepad:PerformUpdate()
    self.dirty = false
end

function STARS_Journal_Gamepad:RefreshList()
    if not self.mainList then return end
    self.mainList:Clear()

    local pages = {
        { name = "Chronicle", page = PAGE_CHRONICLE },
        { name = "Profile", page = PAGE_PROFILE },
        { name = "Veterancy", page = PAGE_CAMPAIGN },
        { name = "Veterancy History", page = PAGE_HISTORY },
        { name = "PvP Legacy", page = PAGE_LEGACY },
        { name = "Underworld Legacy", page = PAGE_UNDERWORLD },
        { name = "Adventures", page = PAGE_ADVENTURES },
        { name = "Correspondence", page = PAGE_CORRESPONDENCE },
        { name = "Library", page = PAGE_LIBRARY },
        { name = "Prestige", page = PAGE_PRESTIGE },
    }

    for _, page in ipairs(pages) do
        local entry = ZO_GamepadEntryData:New(page.name)
        entry.starsPage = page.page
        self.mainList:AddEntry("ZO_GamepadItemSubEntryTemplate", entry)
    end

    self.mainList:Commit()
end

local function SetLabel(parent, childName, value)
    local control = parent and parent:GetNamedChild(childName)
    if control then control:SetText(value or "") end
end


local COLORS = {
    bronze = {0.78, 0.47, 0.24},
    silver = {0.82, 0.86, 0.94},
    gold = {1.00, 0.78, 0.24},
    ascendant = {0.68, 0.48, 1.00},
    legendary = {1.00, 0.34, 0.22},
    veterancy = {0.45, 0.82, 1.00},
    battleground = {0.73, 0.50, 1.00},
    pvp = {1.00, 0.48, 0.32},
    underworld = {0.82, 0.32, 0.72},
    reward = {1.00, 0.82, 0.28},
    chronicle = {0.94, 0.74, 0.34},
    white = {1.00, 1.00, 1.00},
}

local function PrestigeColor(tier)
    return COLORS[string.lower(tostring(tier or "bronze"))] or COLORS.bronze
end

local function SetLabelColor(parent, childName, color)
    local control = parent and parent:GetNamedChild(childName)
    if control and color then
        control:SetColor(color[1], color[2], color[3], 1)
    end
end

local function SetTexture(parent, childName, texturePath)
    local control = parent and parent:GetNamedChild(childName)
    if not control then return end
    if texturePath and texturePath ~= "" then
        control:SetTexture(texturePath)
        control:SetHidden(false)
    else
        control:SetHidden(true)
    end
end

local function FormatTimeRemaining(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    if days > 0 then
        return string.format("%sd %sh", FormatNumber(days), FormatNumber(hours))
    end
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return string.format("%sh %sm", FormatNumber(hours), FormatNumber(minutes))
    end
    return string.format("%sm", FormatNumber(minutes))
end

local function FormatTrackingDate(timestamp)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 then return "Not started" end
    if GetDateStringFromTimestamp then
        local ok, value = pcall(GetDateStringFromTimestamp, timestamp)
        if ok and value and value ~= "" then return value end
    end
    return tostring(timestamp)
end

local function VeterancyHistorySummary(record)
    if not record then return "No Veterancy season recorded." end
    return string.format(
        "Highest Rank\n%s\n\nRank Title\n%s\n\nSeason ID\n%s",
        FormatNumber(record.highestRank),
        record.rankTitle or "Unranked",
        FormatNumber(record.seasonId)
    )
end


local CHRONICLE_MONTHS = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
}

local function ChronicleDateText(year, month, day)
    year = tonumber(year) or 0
    month = tonumber(month) or 0
    day = tonumber(day) or 0
    if year <= 0 or month <= 0 or day <= 0 then return "Unknown date" end
    return string.format("%s %s %s", FormatNumber(day), CHRONICLE_MONTHS[month] or tostring(month), FormatNumber(year))
end

local function ChronicleMemoryHeader(memory, currentYear)
    if not memory then return "MEMORY" end
    if memory.source == "today" then
        local yearsAgo = math.max(0, (tonumber(currentYear) or 0) - (tonumber(memory.year) or 0))
        if yearsAgo == 0 then return "THIS YEAR" end
        if yearsAgo == 1 then return "1 YEAR AGO" end
        return FormatNumber(yearsAgo) .. " YEARS AGO"
    end
    return "FROM " .. FormatNumber(memory.year)
end

local function ChronicleTrim(text, maxLength)
    text = tostring(text or "")
    maxLength = tonumber(maxLength) or 260
    if #text <= maxLength then return text end
    local trimmed = string.sub(text, 1, maxLength)
    local lastSpace = string.match(trimmed, "^.*()%s")
    if lastSpace and lastSpace > (maxLength * 0.65) then
        trimmed = string.sub(trimmed, 1, lastSpace - 1)
    end
    return trimmed .. "..."
end

local function ChronicleMemoryBody(memory)
    if not memory then return "No achievement memory is available yet." end
    local category = tostring(memory.category or "Achievements")
    if memory.subcategory and memory.subcategory ~= "" then
        category = category .. " • " .. tostring(memory.subcategory)
    end
    local rewardText = ""
    if memory.rewardSummary and memory.rewardSummary ~= "" then
        rewardText = "\n\nUNLOCKED\n" .. memory.rewardSummary
    end
    return string.format(
        "%s\n\n%s\n%s Achievement Points\n%s\n\n%s%s",
        tostring(memory.name or "Achievement"),
        ChronicleDateText(memory.year, memory.month, memory.day),
        FormatNumber(memory.points),
        category,
        ChronicleTrim(memory.description, 235),
        rewardText)
end


function STARS_Journal_Gamepad:GetConnectedActionDiagnosticColumns()
    local left = {}
    local right = {}

    local module = self:GetCurrentConnectedModule()
    local lib = LibSTARSConnect

    local function YesNo(value)
        return value and "|c66FF66YES|r" or "|cFF6666NO|r"
    end

    local function StateText(value, trueText, falseText)
        return value
            and ("|c66FF66" .. trueText .. "|r")
            or ("|c999999" .. falseText .. "|r")
    end

    local function GetActionState(action)
        if not action then
            return "|c999999not returned|r"
        end

        local visible = true
        local enabled = true

        if type(action.visible) == "function" then
            local ok, result = pcall(action.visible, module)
            visible = ok and result ~= false
        end

        if type(action.enabled) == "function" then
            local ok, result = pcall(action.enabled, module)
            enabled = ok and result ~= false
        end

        return string.format(
            "%s\n   %s / %s",
            tostring(action.name or "<unnamed>"),
            StateText(visible, "VISIBLE", "HIDDEN"),
            enabled and "|c66FF66ENABLED|r" or "|cFF6666DISABLED|r"
        )
    end

    if not module then
        left[#left + 1] = "Module detected: " .. YesNo(false)
        right[#right + 1] = "No module is selected."
        return table.concat(left, "\n"), table.concat(right, "\n")
    end

    left[#left + 1] = "|cE6C75AMODULE IDENTITY|r"
    left[#left + 1] = "Name:"
    left[#left + 1] = tostring(module.name or "?")
    left[#left + 1] = ""
    left[#left + 1] = "ID:"
    left[#left + 1] = tostring(module.id or "?")
    left[#left + 1] = ""
    left[#left + 1] = "Presentation: " .. tostring(module.presentationType or "?")
    left[#left + 1] = "API version: " .. tostring(module.apiVersion or "?")
    left[#left + 1] = ""
    left[#left + 1] = "|cE6C75AMODULE API|r"
    left[#left + 1] = "GetPresentationData: " .. YesNo(type(module.GetPresentationData) == "function")
    left[#left + 1] = "GetEntryCount: " .. YesNo(type(module.GetEntryCount) == "function")
    left[#left + 1] = "ChangeEntry: " .. YesNo(type(module.ChangeEntry) == "function")
    left[#left + 1] = "GetActions: " .. YesNo(type(module.GetActions) == "function")

    right[#right + 1] = "|cE6C75AACTION BRIDGE|r"
    local hasGetActions = lib and type(lib.GetModuleActions) == "function"
    local hasInvoke = lib and type(lib.InvokeModuleAction) == "function"
    right[#right + 1] = "GetModuleActions: " .. YesNo(hasGetActions)
    right[#right + 1] = "InvokeModuleAction: " .. YesNo(hasInvoke)

    local actions = {}
    local actionsReturned = false
    if hasGetActions and module.id then
        local ok, result = pcall(function()
            return lib:GetModuleActions(module.id)
        end)
        if ok and type(result) == "table" then
            actions = result
            actionsReturned = true
        end
    end

    right[#right + 1] = "Actions table: " .. YesNo(actionsReturned)
    right[#right + 1] = ""
    right[#right + 1] = "|cE6C75AREQUESTED KEYBINDS|r"
    right[#right + 1] = "X Primary:"
    right[#right + 1] = "   " .. GetActionState(actions.primary)
    right[#right + 1] = ""
    right[#right + 1] = "Square Secondary:"
    right[#right + 1] = "   " .. GetActionState(actions.secondary)
    right[#right + 1] = ""
    right[#right + 1] = "Triangle Tertiary:"
    right[#right + 1] = "   " .. GetActionState(actions.tertiary)
    right[#right + 1] = ""
    right[#right + 1] = "L3 Utility:"
    right[#right + 1] = "   " .. GetActionState(actions.utility)
    right[#right + 1] = ""
    right[#right + 1] = "|cE6C75ASTARS DESCRIPTOR|r"
    right[#right + 1] = "Primary visible: " .. YesNo(self:IsConnectedActionVisible("primary"))
    right[#right + 1] = "Primary enabled: " .. YesNo(self:IsConnectedActionEnabled("primary"))
    right[#right + 1] = "Connected group active: " .. YesNo(self._connectedKeybindGroupActive == true)
    right[#right + 1] = "Normal group active: " .. YesNo(self._normalKeybindGroupActive == true)

    return table.concat(left, "\n"), table.concat(right, "\n")
end


function STARS_Journal_Gamepad:SetDiagnosticControlsVisible(visible)
    if not self.adventuresPage then return end
    local names = {
        "DiagLeftHeader",
        "DiagLeftBody",
        "DiagRightHeader",
        "DiagRightBody",
    }
    for _, name in ipairs(names) do
        local control = self.adventuresPage:GetNamedChild(name)
        if control then control:SetHidden(not visible) end
    end

    local body = self.adventuresPage:GetNamedChild("Body")
    if body then body:SetHidden(visible) end
end

function STARS_Journal_Gamepad:IsDeveloperDiagnosticsEnabled()
    return STARS and STARS.sv and STARS.sv.options
        and STARS.sv.options.developerDiagnostics == true
end

function STARS_Journal_Gamepad:IsConnectedDiagnosticEntry()
    if not self:IsDeveloperDiagnosticsEnabled() then return false end
    local module = self:GetCurrentConnectedModule()
    if not module then return false end
    local realCount = self:GetCurrentModuleEntryCount()
    local index = tonumber(module.entryIndex) or 1
    return index > realCount
end

function STARS_Journal_Gamepad:GetConnectedPresentedEntryCount()
    local realCount = self:GetCurrentModuleEntryCount()
    if self:IsDeveloperDiagnosticsEnabled() and self:GetCurrentConnectedModule() then
        return realCount + 1
    end
    return realCount
end

function STARS_Journal_Gamepad:ShowPage(page)
    self.currentPage = page

    local pages = {
        [PAGE_CHRONICLE] = self.chroniclePage,
        [PAGE_PROFILE] = self.profilePage,
        [PAGE_CAMPAIGN] = self.campaignPage,
        [PAGE_HISTORY] = self.historyPage,
        [PAGE_LEGACY] = self.legacyPage,
        [PAGE_UNDERWORLD] = self.underworldPage,
        [PAGE_PRESTIGE] = self.prestigePage,
    }
    for pageId, control in pairs(pages) do
        if control then control:SetHidden(pageId ~= page) end
    end
    if self.adventuresPage then
        local isConnectPage = page == PAGE_ADVENTURES or page == PAGE_CORRESPONDENCE or page == PAGE_LIBRARY
        self.adventuresPage:SetHidden(not isConnectPage)
    end

    local profile = STARS and STARS.GetCharacterProfile and STARS:GetCharacterProfile() or {}
    local veterancyRecord, veterancy = nil, {}
    if STARS and STARS.EnsureVeterancySeason then
        veterancyRecord, veterancy = STARS:EnsureVeterancySeason()
    end
    veterancy = veterancy or {}
    local pvp = STARS and STARS.sv and STARS.sv.stats and STARS.sv.stats.pvp or {}
    local bg = pvp.battlegrounds or {}
    local underworld = STARS and STARS.sv and STARS.sv.stats and STARS.sv.stats.underworld or {}
    local prestige = STARS and STARS.sv and STARS.sv.prestige or {}
    local veterancyHistory = STARS and STARS.sv and STARS.sv.stats
        and STARS.sv.stats.veterancy and STARS.sv.stats.veterancy.history or {}
    local tier, tierIcon = "Bronze", ""
    if STARS and STARS.GetPrestigeTier then
        tier, tierIcon = STARS:GetPrestigeTier()
    end
    local tierColor = PrestigeColor(tier)

    self:ApplyResponsiveLayout()
    self.veterancyHasUnclaimedRewards = veterancy.active and veterancy.hasUnclaimedRewards == true

    if page == PAGE_CHRONICLE and self.chroniclePage then
        local chronicle = STARS and STARS.GetChronicleData and STARS:GetChronicleData() or {}
        local memories = chronicle.memories or chronicle.displayMemories or {}
        local memoryCount = #memories
        local pageCount = memoryCount + 1

        if self.chronicleDayKey ~= chronicle.dayKey then
            self.chronicleDayKey = chronicle.dayKey
            self.chroniclePageIndex = 1
        end
        local pageIndex = tonumber(self.chroniclePageIndex) or 1
        if pageIndex > pageCount then
            pageIndex = 1
        elseif pageIndex < 1 then
            pageIndex = pageCount
        end
        self.chroniclePageIndex = pageIndex
        local isFrontPage = pageIndex == 1
        local memoryIndex = pageIndex - 1
        local memory = not isFrontPage and memories[memoryIndex] or nil

        -- Re-apply layout after resolving the Chronicle page because front-page
        -- and memory-page text blocks use different vertical positions.
        self:ApplyChronicleLayout()

        local function SetChildHidden(childName, hidden)
            local control = self.chroniclePage:GetNamedChild(childName)
            if control then control:SetHidden(hidden) end
        end

        -- Number the overview as Chronicle 0 and the memories as Chronicle 1..N.
        -- This replaces the redundant shared date/count banner entirely.
        SetLabel(self.chroniclePage, "Title", "CHRONICLE " .. FormatNumber(pageIndex - 1))
        SetLabel(self.chroniclePage, "Subtitle", "")

        local earliestText = "No dated achievements found"
        if chronicle.earliest then
            earliestText = ChronicleDateText(chronicle.earliest.year, chronicle.earliest.month, chronicle.earliest.day)
                .. "\n" .. tostring(chronicle.earliest.name or "Achievement")
        end
        local busiestText = "No dated achievements found"
        if chronicle.busiest then
            busiestText = ChronicleDateText(chronicle.busiest.year, chronicle.busiest.month, chronicle.busiest.day)
                .. "\n" .. FormatNumber(chronicle.busiest.count) .. " achievements"
        end
        local yearsText = "Not available"
        if (tonumber(chronicle.firstYear) or 0) > 0 and (tonumber(chronicle.lastYear) or 0) > 0 then
            yearsText = FormatNumber(chronicle.firstYear) .. " — " .. FormatNumber(chronicle.lastYear)
        end

        if isFrontPage then
            -- Album cover / contents page: the account history is the opening memory.
            SetChildHidden("MemoryIcon", true)
            SetChildHidden("MemoryCardName", true)
            SetChildHidden("MemoryName", true)
            SetChildHidden("MemoryDescription", true)
            SetChildHidden("MemoryRewardHeader", true)
            SetChildHidden("MemoryReward", true)
            SetChildHidden("MemoryKicker", false)
            SetChildHidden("MemoryMeta", false)
            SetChildHidden("StoryHeader", false)
            SetChildHidden("StoryBody", false)

            SetLabel(self.chroniclePage, "MemoryKicker", "YOUR STORY SO FAR")
            SetLabel(self.chroniclePage, "MemoryCardName", "")
            SetLabel(self.chroniclePage, "MemoryDescription", "")
            SetLabel(self.chroniclePage, "MemoryMeta", string.format(
                "ACHIEVEMENTS REMEMBERED\n%s\n\nACHIEVEMENT POINTS\n%s\n\nYEARS RECORDED\n%s",
                FormatNumber(chronicle.completed), FormatNumber(chronicle.earnedPoints), yearsText))

            SetLabel(self.chroniclePage, "StoryHeader", "MILESTONES")
            local todayText
            if (tonumber(chronicle.todayCount) or 0) > 0 then
                todayText = string.format("%s %s\n%s memories waiting",
                    FormatNumber(chronicle.currentDay), tostring(chronicle.monthName or ""),
                    FormatNumber(chronicle.todayCount))
            else
                todayText = "No dated memories today\nA highlight reel is ready"
            end
            SetLabel(self.chroniclePage, "StoryBody", string.format(
                "EARLIEST MEMORY\n%s\n\nBUSIEST DAY\n%s\n\nTODAY IN YOUR STORY\n%s",
                earliestText, busiestText, todayText))

            SetLabel(self.chroniclePage, "PageIndicator", "")
        else
            -- Memory spread: the left card identifies the memory; the right card
            -- tells its story without repeating the achievement title or category.
            SetChildHidden("MemoryIcon", false)
            SetChildHidden("MemoryCardName", false)
            SetChildHidden("MemoryName", true)
            SetChildHidden("MemoryDescription", true)
            SetChildHidden("MemoryRewardHeader", true)
            SetChildHidden("MemoryReward", true)
            SetChildHidden("MemoryKicker", false)
            SetChildHidden("MemoryMeta", false)
            SetChildHidden("StoryHeader", false)
            SetChildHidden("StoryBody", false)

            SetTexture(self.chroniclePage, "MemoryIcon", memory and memory.icon or "")
            SetLabel(self.chroniclePage, "MemoryKicker", ChronicleMemoryHeader(memory, chronicle.currentYear))
            SetLabel(self.chroniclePage, "MemoryCardName", memory and tostring(memory.name or "Achievement") or "")
            SetLabel(self.chroniclePage, "MemoryDescription", "")

            local category = "Achievements"
            if memory then
                category = tostring(memory.category or "Achievements")
                if memory.subcategory and memory.subcategory ~= "" then
                    category = category .. " - " .. tostring(memory.subcategory)
                end
            end
            SetLabel(self.chroniclePage, "MemoryMeta", category)

            SetLabel(self.chroniclePage, "StoryHeader", "THE STORY")
            SetLabel(self.chroniclePage, "MemoryName", "")

            local rewardText = memory and tostring(memory.rewardSummary or "") or ""
            if rewardText == "" then rewardText = "None" end
            local gold = "|cF0BD57"
            local reset = "|r"
            SetLabel(self.chroniclePage, "StoryBody", memory and string.format(
                "%s\n\n" ..
                "Completed: %s\n" ..
                "Achievement Points: %s\n\n" ..
                "%sReward Unlocked:%s\n%s",
                ChronicleTrim(memory.description, 760),
                ChronicleDateText(memory.year, memory.month, memory.day),
                FormatNumber(memory.points),
                gold, reset, rewardText) or
                "STARS could not find a completed achievement with a usable historical timestamp.")

            SetLabel(self.chroniclePage, "MemoryRewardHeader", "")
            SetLabel(self.chroniclePage, "MemoryReward", "")
            SetLabel(self.chroniclePage, "PageIndicator", "")
        end

        SetLabelColor(self.chroniclePage, "Title", COLORS.chronicle)
        SetLabelColor(self.chroniclePage, "MemoryKicker", memory and memory.source == "today" and COLORS.reward or COLORS.chronicle)
        SetLabelColor(self.chroniclePage, "MemoryCardName", COLORS.white)
        SetLabelColor(self.chroniclePage, "MemoryDescription", COLORS.white)
        SetLabelColor(self.chroniclePage, "MemoryName", COLORS.white)
        SetLabelColor(self.chroniclePage, "MemoryMeta", COLORS.white)
        SetLabelColor(self.chroniclePage, "MemoryRewardHeader", COLORS.reward)
        SetLabelColor(self.chroniclePage, "PageIndicator", COLORS.chronicle)
        SetLabelColor(self.chroniclePage, "StoryHeader", COLORS.chronicle)
        SetLabelColor(self.chroniclePage, "StoryBody", COLORS.white)

    elseif page == PAGE_PROFILE and self.profilePage then
        SetLabel(self.profilePage, "Title", "PRESTIGE " .. FormatNumber(profile.prestige or 0))
        SetLabel(self.profilePage, "Subtitle",
            string.upper(tier or "BRONZE") .. "   •   Champion " .. FormatNumber(profile.cp or 0)
            .. "   •   Session +" .. FormatNumber(prestige.session or 0))

        SetLabel(self.profilePage, "Col1Header", "PRESTIGE")
        SetLabel(self.profilePage, "Col1Body", string.format(
            "Level\n%s\n\nTier\n%s\n\nBaseline CP\n%s",
            FormatNumber(profile.prestige or 0), string.upper(tier or "BRONZE"),
            FormatNumber(prestige.baselineCP or 0)))

        SetLabel(self.profilePage, "Col2Header", "VETERANCY")
        if veterancy.active then
            SetLabel(self.profilePage, "Col2Body", string.format(
                "%s\n\nRank  %s\n%s\n\nProgress  %s%%\nTime Left  %s",
                veterancy.seasonName or "Veterancy",
                FormatNumber(veterancy.rank),
                veterancy.rankTitle or "Unranked",
                FormatNumber(veterancy.progressPercent),
                FormatTimeRemaining(veterancy.timeRemainingS)))
        else
            SetLabel(self.profilePage, "Col2Body", "No active Veterancy season.")
        end

        SetLabel(self.profilePage, "Col3Header", "PVP LEGACY")
        SetLabel(self.profilePage, "Col3Body", string.format(
            "Cyrodiil\nKills  %s\nDeaths  %s\nRevives  %s\n\nBattlegrounds\nK %s   D %s   A %s",
            FormatNumber(pvp.kills), FormatNumber(pvp.deaths), FormatNumber(pvp.revives),
            FormatNumber(bg.kills), FormatNumber(bg.deaths), FormatNumber(bg.assists)))

        SetLabelColor(self.profilePage, "Title", tierColor)
        SetLabelColor(self.profilePage, "Col1Header", tierColor)
        SetLabelColor(self.profilePage, "Col2Header", COLORS.veterancy)
        SetLabelColor(self.profilePage, "Col3Header", COLORS.pvp)

    elseif page == PAGE_CAMPAIGN and self.campaignPage then
        SetTexture(self.campaignPage, "RankIcon", veterancy.largeRankIcon or veterancy.rankIcon)

        if veterancy.active then
            SetLabel(self.campaignPage, "Title", string.upper(veterancy.seasonName or "VETERANCY"))
            SetLabel(self.campaignPage, "Subtitle",
                "CURRENT VETERANCY SEASON  •  " .. FormatTimeRemaining(veterancy.timeRemainingS) .. " REMAINING")

            SetLabel(self.campaignPage, "Col1Header", "CURRENT RANK")
            SetLabel(self.campaignPage, "Col1Body", string.format(
                "Rank\n%s\n\nTitle\n%s",
                FormatNumber(veterancy.rank),
                veterancy.rankTitle or "Unranked"))

            SetLabel(self.campaignPage, "Col2Header", "PROGRESS")
            SetLabel(self.campaignPage, "Col2Body", string.format(
                "Current Tier\n%s / %s\n\nProgress\n%s%%\n\nSeason Ranks\n%s",
                FormatNumber(veterancy.progress),
                FormatNumber(veterancy.progressTotal),
                FormatNumber(veterancy.progressPercent),
                FormatNumber(veterancy.numRanks)))

            SetLabel(self.campaignPage, "Col3Header", "REWARDS")
            SetLabel(self.campaignPage, "Col3Body", string.format(
                "Rewards At Rank\n%s\n\nUnclaimed Rewards\n%s\n\nHighest Recorded Rank\n%s",
                FormatNumber(veterancy.numClaimableRewards),
                veterancy.hasUnclaimedRewards and "YES" or "NO",
                FormatNumber(veterancyRecord and veterancyRecord.highestRank or veterancy.rank)))
        else
            SetLabel(self.campaignPage, "Title", "VETERANCY")
            SetLabel(self.campaignPage, "Subtitle", "NO ACTIVE VETERANCY SEASON")
            SetLabel(self.campaignPage, "Col1Header", "CURRENT RANK")
            SetLabel(self.campaignPage, "Col1Body", "No active Veterancy season.")
            SetLabel(self.campaignPage, "Col2Header", "PROGRESS")
            SetLabel(self.campaignPage, "Col2Body", "")
            SetLabel(self.campaignPage, "Col3Header", "REWARDS")
            SetLabel(self.campaignPage, "Col3Body", "")
        end
        SetLabelColor(self.campaignPage, "Title", COLORS.veterancy)
        SetLabelColor(self.campaignPage, "Col1Header", COLORS.veterancy)
        SetLabelColor(self.campaignPage, "Col2Header", COLORS.veterancy)
        SetLabelColor(self.campaignPage, "Col3Header", veterancy.hasUnclaimedRewards and COLORS.reward or COLORS.veterancy)

    elseif page == PAGE_HISTORY and self.historyPage then
        SetLabel(self.historyPage, "Title", "VETERANCY HISTORY")

        local h1, h2, h3 = veterancyHistory[1], veterancyHistory[2], veterancyHistory[3]
        SetLabel(self.historyPage, "Col1Header", h1 and string.upper(h1.name or "PREVIOUS SEASON") or "PREVIOUS SEASON")
        SetLabel(self.historyPage, "Col1Body", VeterancyHistorySummary(h1))
        SetLabel(self.historyPage, "Col2Header", h2 and string.upper(h2.name or "TWO SEASONS AGO") or "TWO SEASONS AGO")
        SetLabel(self.historyPage, "Col2Body", VeterancyHistorySummary(h2))
        SetLabel(self.historyPage, "Col3Header", h3 and string.upper(h3.name or "THREE SEASONS AGO") or "THREE SEASONS AGO")
        SetLabel(self.historyPage, "Col3Body", VeterancyHistorySummary(h3))
        SetLabelColor(self.historyPage, "Title", COLORS.veterancy)
        SetLabelColor(self.historyPage, "Col1Header", COLORS.veterancy)
        SetLabelColor(self.historyPage, "Col2Header", COLORS.veterancy)
        SetLabelColor(self.historyPage, "Col3Header", COLORS.veterancy)

    elseif page == PAGE_LEGACY and self.legacyPage then
        SetLabel(self.legacyPage, "Title", "PVP LEGACY")
        SetLabel(self.legacyPage, "Subtitle", "YOUR RECORDED PVP LEGACY")

        SetLabel(self.legacyPage, "Col1Header", "CYRODIIL")
        SetLabel(self.legacyPage, "Col1Body", string.format(
            "Kills\n%s\n\nDeaths\n%s\n\nRevives\n%s",
            FormatNumber(pvp.kills), FormatNumber(pvp.deaths), FormatNumber(pvp.revives)))

        SetLabel(self.legacyPage, "Col2Header", "BATTLEGROUNDS")
        SetLabel(self.legacyPage, "Col2Body", string.format(
            "Kills\n%s\n\nDeaths\n%s\n\nAssists\n%s",
            FormatNumber(bg.kills), FormatNumber(bg.deaths), FormatNumber(bg.assists)))

        SetLabel(self.legacyPage, "Col3Header", "CONTRIBUTION")
        SetLabel(self.legacyPage, "Col3Body", string.format(
            "Keeps Captured\n%s\n\nKeeps Defended\n%s\n\nAP Earned\n%s",
            FormatNumber(pvp.keepsTaken), FormatNumber(pvp.keepsDefended), FormatNumber(pvp.apEarned)))

        SetLabelColor(self.legacyPage, "Title", COLORS.pvp)
        SetLabelColor(self.legacyPage, "Col1Header", COLORS.pvp)
        SetLabelColor(self.legacyPage, "Col2Header", COLORS.battleground)
        SetLabelColor(self.legacyPage, "Col3Header", COLORS.reward)

    elseif page == PAGE_UNDERWORLD and self.underworldPage then
        SetLabel(self.underworldPage, "Title", "UNDERWORLD LEGACY")
        SetLabel(self.underworldPage, "Subtitle", "YOUR RECORDED CRIMINAL LEGACY")

        SetLabel(self.underworldPage, "Col1Header", "PICKPOCKETING")
        SetLabel(self.underworldPage, "Col1Body", string.format(
            "Successful Pickpockets\n%s",
            FormatNumber(underworld.pickpockets)))

        SetLabel(self.underworldPage, "Col2Header", "BLADE OF WOE")
        SetLabel(self.underworldPage, "Col2Body", string.format(
            "Assassinations\n%s",
            FormatNumber(underworld.bladeOfWoeKills)))

        SetLabel(self.underworldPage, "Col3Header", "RECORD")
        SetLabel(self.underworldPage, "Col3Body", string.format(
            "Tracking Since\n%s\n\nCounters record activity observed by STARS from this version onward.",
            FormatTrackingDate(underworld.trackingStarted)))

        SetLabelColor(self.underworldPage, "Title", COLORS.underworld)
        SetLabelColor(self.underworldPage, "Col1Header", COLORS.reward)
        SetLabelColor(self.underworldPage, "Col2Header", COLORS.underworld)
        SetLabelColor(self.underworldPage, "Col3Header", COLORS.white)

    elseif (page == PAGE_ADVENTURES or page == PAGE_CORRESPONDENCE or page == PAGE_LIBRARY) and self.adventuresPage then
        local modules = self:GetModulesForPage(page)
        local count = #modules
        local index = self:GetCurrentModuleIndex(page)
        local pageTitle = page == PAGE_ADVENTURES and "ADVENTURES"
            or (page == PAGE_CORRESPONDENCE and "CORRESPONDENCE" or "LIBRARY")
        local pageType = page == PAGE_ADVENTURES and "game"
            or (page == PAGE_CORRESPONDENCE and "correspondence" or "library")

        if count == 0 then
            self:SetDiagnosticControlsVisible(false)
            self:SetCurrentModuleIndex(page, 1)
            SetLabel(self.adventuresPage, "Title", pageTitle)
            SetLabel(self.adventuresPage, "Subtitle", "No active " .. string.lower(pageTitle) .. " modules")
            SetLabel(self.adventuresPage, "ModuleTitle", "LIBSTARSCONNECT")
            SetLabel(self.adventuresPage, "ModuleSubtitle", "Install or activate a compatible " .. pageType .. " module")
            SetLabel(self.adventuresPage, "Body", "Connected addons keep ownership of their data and logic. STARS provides a dedicated presentation home for this content type.")
            SetLabel(self.adventuresPage, "Indicator", "0 / 10 active modules in this category")
        else
            if index > count then index = 1 elseif index < 1 then index = count end
            self:SetCurrentModuleIndex(page, index)
            local module = modules[index]
            local data = {}
            if module and type(module.GetPresentationData) == "function" then
                local ok, result = pcall(module.GetPresentationData, module)
                if ok and type(result) == "table" then data = result end
            end
            local lines = data.lines or {}
            local body = type(data.body) == "string" and data.body or table.concat(lines, "\n")
            local moduleTitle, moduleSubtitle

            if page == PAGE_CORRESPONDENCE then
                moduleTitle = data.collectionTitle or module.name or "CORRESPONDENCE"
                local sender = data.senderName or "Unknown Sender"
                local subject = data.subject or ""
                local pos = (data.entryIndex and data.entryCount) and string.format(" • %d / %d", data.entryIndex, data.entryCount) or ""
                moduleSubtitle = sender .. (subject ~= "" and (" — " .. subject) or "") .. pos
            elseif page == PAGE_LIBRARY then
                moduleTitle = data.collectionTitle or module.name or "LIBRARY"
                local title = data.title or "Untitled"
                local author = data.author and (" — " .. data.author) or ""
                local pos = (data.entryIndex and data.entryCount) and string.format(" • %d / %d", data.entryIndex, data.entryCount) or ""
                moduleSubtitle = title .. author .. pos
            else
                moduleTitle = data.title or module.name or module.id or "Adventure"
                moduleSubtitle = data.subtitle or module.description or ""
            end

            SetLabel(self.adventuresPage, "Title", pageTitle)
            SetLabel(self.adventuresPage, "Subtitle", string.format("Module %d of %d • maximum 10 active in %s", index, count, string.lower(pageTitle)))
            SetLabel(self.adventuresPage, "ModuleTitle", moduleTitle)
            SetLabel(self.adventuresPage, "ModuleSubtitle", moduleSubtitle)

            if self:IsConnectedDiagnosticEntry() then
                self:SetDiagnosticControlsVisible(true)
                local leftBody, rightBody = self:GetConnectedActionDiagnosticColumns()
                SetLabel(self.adventuresPage, "DiagLeftHeader", "MODULE / API")
                SetLabel(self.adventuresPage, "DiagLeftBody", leftBody)
                SetLabel(self.adventuresPage, "DiagRightHeader", "ACTIONS / KEYBINDS")
                SetLabel(self.adventuresPage, "DiagRightBody", rightBody)
            else
                self:SetDiagnosticControlsVisible(false)
                SetLabel(self.adventuresPage, "Body", body)
            end

            local entryCount = self:GetConnectedPresentedEntryCount()
            local controls = {}
            if count > 1 then controls[#controls + 1] = "L1 / R1 modules" end
            if entryCount > 1 then controls[#controls + 1] = "L2 / R2 entries" end
            if #controls == 0 then controls[1] = "Connected through LibSTARSConnect" end
            SetLabel(self.adventuresPage, "Indicator", table.concat(controls, " • "))
        end

    elseif page == PAGE_PRESTIGE and self.prestigePage then
        SetTexture(self.prestigePage, "Badge", tierIcon)
        SetLabel(self.prestigePage, "Title", "PRESTIGE " .. FormatNumber(profile.prestige or 0))
        SetLabel(self.prestigePage, "Tier", string.upper(tier or "BRONZE"))
        SetLabel(self.prestigePage, "Details", string.format(
            "Champion Points\n%s\n\nPrestige Baseline\nCP %s\n\nPrestige Gained This Session\n+%s",
            FormatNumber(profile.cp or 0),
            FormatNumber(prestige.baselineCP or 0),
            FormatNumber(prestige.session or 0)))

        local recordedSeasonCount = #veterancyHistory + (veterancyRecord and 1 or 0)
        local currentVeterancyText = veterancy.active
            and string.format("%s — Rank %s", veterancy.rankTitle or "Veterancy", FormatNumber(veterancy.rank))
            or "No active Veterancy season"
        SetLabel(self.prestigePage, "LegacyHeader", "CURRENT LEGACY")
        SetLabel(self.prestigePage, "LegacyDetails", string.format(
            "Veterancy: %s\nVeterancy Seasons Recorded: %s",
            currentVeterancyText, FormatNumber(recordedSeasonCount)))
        SetLabel(self.prestigePage, "Footer",
            "Prestige tracks Champion progression beyond your STARS baseline. Your Journal records the legacy you build along the way.")

        SetLabelColor(self.prestigePage, "Title", tierColor)
        SetLabelColor(self.prestigePage, "Tier", tierColor)
        SetLabelColor(self.prestigePage, "LegacyHeader", COLORS.reward)

    end

    -- Refresh only the group STARS currently owns, and only while its scene is
    -- active. No delayed callback is allowed to run after OnHiding.
    if self:IsSceneActive() then
        self:RefreshActiveKeybindGroup()
        self:RefreshConnectedKeybinds()
    end
end

function Journal:Initialize()
    if self.initialized then return end
    self.initialized = true

    local control = STARSJournalGamepad
    if not control then
        d("[STARS] Journal root control was not created.")
        return
    end

    STARS_JOURNAL_GAMEPAD = STARS_Journal_Gamepad:New(control)

    -- Main menu data is not always ready at addon load. Try immediately, then
    -- again on player activation until the Journal submenu accepts the entry.
    if not AddToJournalMenu() then
        EVENT_MANAGER:RegisterForEvent("STARS_Journal_Menu", EVENT_PLAYER_ACTIVATED, function()
            if AddToJournalMenu() then
                EVENT_MANAGER:UnregisterForEvent("STARS_Journal_Menu", EVENT_PLAYER_ACTIVATED)
            end
        end)
    end
end

