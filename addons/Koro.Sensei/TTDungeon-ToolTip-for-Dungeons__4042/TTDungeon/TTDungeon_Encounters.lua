-- TTDungeon_Encounters.lua
-- Manages boss encounter display and mechanics information
-- Creates expandable boss windows with detailed mechanics that can be sent to chat

-- Initialize addon namespace
TTDungeon = TTDungeon or {}

-- Use main debug function or create local fallback
local Debug = TTDungeon.Debug or function(msg) d("[TTDungeon_Encounters Debug] " .. tostring(msg)) end

-- ================================================================================
-- Text Cleanup Functions
-- ================================================================================

-- Remove content reference tags that might appear in imported text
-- These tags are artifacts from data sources and should not be displayed
-- @param str: String to clean
-- @return: Cleaned string
local function RemoveContentReference(str)
    if not str then return "" end
    -- Pattern matches :contentReference[...] tags
    return str:gsub(":contentReference%[%s*oaicite:%d+%]%s*{index=%d+}", "")
end

-- Remove color codes from text strings
-- Used when preparing text for chat output where colors aren't supported
-- @param str: String to clean
-- @return: String without color codes
local function RemoveColorCodes(str)
    if not str then return "" end
    -- Remove |cXXXXXX color start codes and |r reset codes
    return str:gsub("|c%x%x%x%x%x%x",""):gsub("|r","")
end

-- Prepare text for display in the UI by removing unwanted references
-- @param text: Raw text from data
-- @return: Cleaned text safe for UI display
function TTDungeon.PrepareForUI(text)
    if not text then return "" end
    return RemoveContentReference(text)
end

-- Prepare text for chat output by removing all formatting
-- @param text: Raw text from data
-- @return: Plain text safe for chat
function TTDungeon.PrepareForChat(text)
    if not text then return "" end
    local noRef   = RemoveContentReference(text)
    local noColor = RemoveColorCodes(noRef)
    return noColor
end

-- ================================================================================
-- Chat Integration
-- ================================================================================

-- Append text to the current chat input without sending
-- Preserves any existing text and the current chat channel
-- @param rawLine: Text to add to chat input
function TTDungeon.PostLineToChat(rawLine)
    if not rawLine or rawLine == "" then return end
    local lineForChat = TTDungeon.PrepareForChat(rawLine)

    -- Preserve current chat state
    local currentText   = CHAT_SYSTEM.textEntry:GetText() or ""
    local currentChannel= CHAT_SYSTEM.currentChannel
    local currentTarget = CHAT_SYSTEM.currentTarget

    -- Append new text with a space separator
    StartChatInput(currentText .. " " .. lineForChat, currentChannel, currentTarget)
end

-- ================================================================================
-- Window Management
-- ================================================================================

-- Table to store all open boss detail windows
-- Key: boss name (normalized), Value: window data
TTDungeon.ephemeralWindows = TTDungeon.ephemeralWindows or {}

-- ================================================================================
-- Scroll Handling
-- ================================================================================

-- Clamp scroll offset to ensure content stays within visible bounds
-- Handles scroll inversion based on user preference
-- @param scrollControl: The scroll control to clamp
function TTDungeon.BossDetail_ClampScrollOffset(scrollControl)
    if not scrollControl or not scrollControl.scrollChild then return end
    
    local scChild = scrollControl.scrollChild
    local cH      = scrollControl:GetHeight()     -- Container height
    local sH      = scChild:GetHeight()          -- Content height
    
    if sH <= cH then
        -- Content fits in container, no scrolling needed
        scrollControl.offsetY = 0
    else
        -- Calculate valid scroll range
        local minOffset = -(sH - cH)
        if scrollControl.offsetY > 0 then
            scrollControl.offsetY = 0
        elseif scrollControl.offsetY < minOffset then
            scrollControl.offsetY = minOffset
        end
    end
    
    -- Apply the clamped offset
    scChild:ClearAnchors()
    scChild:SetAnchor(TOPLEFT, scrollControl, TOPLEFT, 0, scrollControl.offsetY)
end

-- ================================================================================
-- Mechanics List Builder
-- ================================================================================

-- Build the mechanics list for a boss detail window
-- Creates rows with text and "→Chat" buttons for each mechanic
-- @param windowData: Table containing window references and boss data
local function BuildMechanics(windowData)
    local scChild = windowData.scChild
    local bData   = windowData.bossData
    if not scChild or not bData then return end

    -- Remove all existing child elements
    for i = scChild:GetNumChildren()-1, 0, -1 do
        local oldC = scChild:GetChild(i)
        if oldC then
            oldC:SetHidden(true)
            oldC:SetParent(nil)
        end
    end
    scChild:SetHeight(0)

    -- Layout parameters
    local offsetY  = 0
    local marginV  = 5      -- Vertical margin between rows
    local rowWidth = scChild:GetWidth()

    -- Get mechanics list or use empty table
    local mechs = bData.mechanics or {}
    
    -- Create a row for each mechanic
    for _, rawLine in ipairs(mechs) do
        -- Prepare text for UI display (remove references)
        local uiText = TTDungeon.PrepareForUI(rawLine)

        -- Create row container
        local row = CreateControl(nil, scChild, CT_CONTROL)
        row:SetAnchor(TOPLEFT, scChild, TOPLEFT, 0, offsetY)
        row:SetDimensions(rowWidth, 30)  -- Minimum height, will adjust
        row:SetMouseEnabled(false)

        -- Create text label for mechanic description
        local label = CreateControl(nil, row, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
        label:SetWrapMode(TEXT_WRAP_MODE_WORD)
        label:SetMaxLineCount(0)  -- Unlimited lines
        label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 0)
        label:SetWidth(rowWidth - 90)  -- Leave space for button
        label:SetText("• "..uiText)

        -- Adjust row height based on actual text height
        local actualHeight = label:GetTextHeight() or 20
        local finalH = actualHeight + marginV * 2
        if finalH < 30 then finalH = 30 end  -- Minimum height
        row:SetDimensions(rowWidth, finalH)

        -- Create "→Chat" button to send mechanic to chat
        local chatBtn = CreateControl(nil, row, CT_BUTTON)
        chatBtn:SetDimensions(70, 28)
        chatBtn:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 0)
        chatBtn:SetFont("ZoFontGameSmall")
        chatBtn:SetText("→Chat")
        chatBtn:SetNormalTexture("EsoUI/Art/Buttons/wood_up.dds")
        chatBtn:SetPressedTexture("EsoUI/Art/Buttons/wood_down.dds")
        chatBtn:SetMouseOverTexture("EsoUI/Art/Buttons/wood_over.dds")
        chatBtn:SetHandler("OnClicked", function()
            TTDungeon.PostLineToChat(rawLine)
        end)

        offsetY = offsetY + finalH + marginV
    end
    
    -- Set final scroll child height with padding
    offsetY = offsetY + 10
    scChild:SetHeight(offsetY)
end

-- ================================================================================
-- Boss Window Creation
-- ================================================================================

-- Generate a unique key from boss name for window tracking
-- @param bName: Boss name
-- @return: Normalized key string
local function BossKeyFromName(bName)
    if not bName then return "unknown_boss" end
    -- Convert to lowercase and replace non-word characters with underscores
    return bName:lower():gsub("[^%w]+","_")
end

-- Create or show a boss detail window with mechanics information
-- @param bossData: Table containing boss name and mechanics
local function CreateOrShowBossWindow(bossData)
    if not bossData or not bossData.name then return end
    local bossKey = BossKeyFromName(bossData.name)

    -- Check if window already exists
    if TTDungeon.ephemeralWindows[bossKey] then
        local winData = TTDungeon.ephemeralWindows[bossKey]
        Debug("Window exists => unhide bossKey="..bossKey)
        winData.ui:SetHidden(false)
        return
    end

    -- Create new boss window
    Debug("Create new boss window => bossKey="..bossKey)
    local uiName = "TTD_BossWin_"..bossKey
    local ui     = CreateControl(uiName, GuiRoot, CT_TOPLEVELCONTROL)
    ui:SetDimensions(450, 300)
    ui:SetClampedToScreen(true)
    ui:SetMouseEnabled(true)
    ui:SetMovable(true)
    ui:SetResizeHandleSize(16)
    ui:SetHidden(false)
    ui:ClearAnchors()
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    ui:SetDimensionConstraints(450, 200, 800, 1000)  -- Min and max size

    -- Window background
    local backdrop = CreateControl(nil, ui, CT_BACKDROP)
    backdrop:SetAnchorFill(ui)
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
    backdrop:SetEdgeColor(1, 1, 1, 1)

    -- Title bar container
    local titleContainer = CreateControl(nil, ui, CT_CONTROL)
    titleContainer:SetResizeToFitDescendents(true)
    titleContainer:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0)
    titleContainer:SetAnchor(TOPRIGHT, ui, TOPRIGHT, 0, 0)

    -- Close button in top-right corner
    local closeBtn = CreateControl(nil, titleContainer, CT_BUTTON)
    closeBtn:SetDimensions(32, 32)
    closeBtn:SetAnchor(TOPRIGHT, titleContainer, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_over.dds")
    closeBtn:SetHandler("OnClicked", function()
        ui:SetHidden(true)
    end)

    -- Title label showing boss name
    local titleLabel = CreateControl(nil, titleContainer, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH2")
    titleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    titleLabel:SetMaxLineCount(1)
    titleLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
    titleLabel:SetColor(1, 1, 0.5, 1)  -- Yellow-gold color
    titleLabel:SetAnchor(TOPLEFT,  titleContainer, TOPLEFT, 10, 10)
    titleLabel:SetAnchor(TOPRIGHT, titleContainer, TOPRIGHT, -50, 10)
    titleLabel:SetText(TTDungeon.PrepareForUI("Boss: "..bossData.name))

    -- Scrollable container for mechanics list
    local scroll = CreateControl(nil, ui, CT_SCROLL)
    scroll:SetAnchor(TOPLEFT, titleContainer, BOTTOMLEFT, 0, 0)
    scroll:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -10, -10)
    scroll:SetMouseEnabled(true)
    scroll.offsetY = 0

    -- Mouse wheel scroll handler
    scroll:SetHandler("OnMouseWheel", function(self, delta)
        local step = 20  -- Pixels to scroll per wheel notch
        -- Apply scroll inversion preference
        if TTDungeon.savedVars and TTDungeon.savedVars.invertScroll then
            self.offsetY = self.offsetY + (delta * step)
        else
            self.offsetY = self.offsetY - (delta * step)
        end
        TTDungeon.BossDetail_ClampScrollOffset(self)
    end)
    
    -- Allow dragging the window by clicking on the scroll area
    scroll:SetHandler("OnMouseDown", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            ui:StartMoving()
        end
    end)
    scroll:SetHandler("OnMouseUp", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            ui:StopMovingOrResizing()
        end
    end)

    -- Scroll child to contain the actual mechanics content
    local scChild = CreateControl(nil, scroll, CT_CONTROL)
    scChild:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
    scChild:SetDimensions(scroll:GetWidth(), 0)  -- Height set by content
    scroll.scrollChild = scChild

    -- Store window data for future reference
    TTDungeon.ephemeralWindows[bossKey] = {
        ui      = ui,
        bossData= bossData,
        scroll  = scroll,
        scChild = scChild,
    }

    -- Handle window resize to update content layout
    ui:SetHandler("OnResizeStop", function()
        BuildMechanics(TTDungeon.ephemeralWindows[bossKey])
        TTDungeon.BossDetail_ClampScrollOffset(scroll)
    end)

    -- Build the initial mechanics list
    BuildMechanics(TTDungeon.ephemeralWindows[bossKey])
end

-- ================================================================================
-- Window Management Functions
-- ================================================================================

-- Hide all open boss detail windows
-- Called when changing zones or hiding the main UI
function TTDungeon.HideBossDetailWindows()
    for bossKey, winData in pairs(TTDungeon.ephemeralWindows) do
        if winData and winData.ui then
            winData.ui:SetHidden(true)
        end
    end
end

-- ================================================================================
-- Boss List Entry Creation
-- ================================================================================

-- Create a clickable boss entry for the encounters tab
-- @param bossData: Boss information including name and mechanics
-- @param zoneId: Current zone ID (for context)
-- @return: The created control or nil
function TTDungeon.CreateBossLine(bossData, zoneId)
    if not TTDungeon.encounterScrollChild then
        Debug("encounterScrollChild missing => can't create boss line.")
        return nil
    end

    local sc = TTDungeon.encounterScrollChild
    local rowHeight = 30
    
    -- Create row container
    local entry = CreateControl(nil, sc, CT_CONTROL)
    entry:SetDimensions(sc:GetWidth(), rowHeight)
    entry:SetMouseEnabled(false)

    -- Background for hover effect
    local bg = CreateControl(nil, entry, CT_BACKDROP)
    bg:SetAnchorFill(entry)
    bg:SetCenterColor(0, 0, 0, 0)     -- Transparent
    bg:SetEdgeColor(0, 0, 0, 0)
    entry.bg = bg

    -- Interactive button spanning the row
    local btn = CreateControl(nil, entry, CT_BUTTON)
    btn:SetMouseEnabled(true)
    btn:SetDimensions(entry:GetWidth(), rowHeight)
    btn:SetAnchor(TOPLEFT, entry, TOPLEFT, 0, 0)
    btn:SetNormalTexture("EsoUI/Art/Buttons/wood_up.dds")
    btn:SetPressedTexture("EsoUI/Art/Buttons/wood_down.dds")
    btn:SetMouseOverTexture("EsoUI/Art/Buttons/wood_over.dds")

    -- Boss name display
    local rawName = bossData.name or "Boss"
    local uiName  = TTDungeon.PrepareForUI(rawName)
    btn:SetFont("ZoFontGameBold")
    btn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    btn:SetText("|cFFFFFF"..uiName.."|r")  -- White text

    -- Mouse enter - show tooltip with mechanics preview
    btn:SetHandler("OnMouseEnter", function()
        -- Highlight row
        bg:SetCenterColor(0.3, 0.3, 0.3, 0.3)
        bg:SetEdgeColor(0.5, 0.5, 0.5, 0.5)
        
        -- Show tooltip with mechanics preview
        InitializeTooltip(InformationTooltip, btn, TOPRIGHT, 0, 0, TOPLEFT)
        InformationTooltip:ClearLines()
        InformationTooltip:AddLine(uiName, "ZoFontGameMedium", nil, nil, nil, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        
        if bossData.mechanics then
            for _, mechtxt in ipairs(bossData.mechanics) do
                local lineUI = TTDungeon.PrepareForUI(mechtxt)
                InformationTooltip:AddLine("• "..lineUI, "ZoFontGame", nil, nil, nil, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
            end
        end
    end)

    -- Mouse exit - hide tooltip and remove highlight
    btn:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(0, 0, 0, 0)
        bg:SetEdgeColor(0, 0, 0, 0)
        ClearTooltip(InformationTooltip)
    end)

    -- Click handler - open detailed boss window
    btn:SetHandler("OnClicked", function(_, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            Debug("Boss clicked => "..rawName)
            CreateOrShowBossWindow(bossData)
        end
    end)

    return entry
end

-- ================================================================================
-- Layout Management
-- ================================================================================

-- Layout all boss entries in the encounters scroll container
-- Updates scroll child height based on content
function TTDungeon.LayoutBossEntries()
    if not TTDungeon.encounterScrollChild then return end
    
    local sc = TTDungeon.encounterScrollChild
    local offsetY = 10
    local spacing = 5

    -- Position each boss entry
    for _, e in ipairs(TTDungeon.bossEntries or {}) do
        e:ClearAnchors()
        e:SetAnchor(TOPLEFT, sc, TOPLEFT, 0, offsetY)
        offsetY = offsetY + e:GetHeight() + spacing
    end
    
    -- Set final container height
    offsetY = offsetY + 10
    sc:SetHeight(offsetY)
    
    -- Update scroll clamping
    if TTDungeon.encounterScroll then
        TTDungeon.BossDetail_ClampScrollOffset(TTDungeon.encounterScroll)
    end
end

-- ================================================================================
-- Main Population Function
-- ================================================================================

-- Populate the encounters tab with boss information
-- @param data: Dungeon data containing boss array
-- @param zoneId: Current zone ID
function TTDungeon.PopulateEncounters(data, zoneId)
    -- Clear existing boss entries
    if TTDungeon.bossEntries then
        for _, e in ipairs(TTDungeon.bossEntries) do
            e:SetHidden(true)
            e:SetParent(nil)
        end
    end
    TTDungeon.bossEntries = {}

    -- Reset scroll container
    if TTDungeon.encounterScrollChild then
        TTDungeon.encounterScrollChild:SetHeight(0)
    end

    local sc = TTDungeon.encounterScrollChild
    if not sc then
        Debug("No encounterScrollChild => can't populate")
        return
    end

    local offsetY = 10

    -- Add instruction label at top
    local label = CreateControl(nil, sc, CT_LABEL)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(0.7, 0.7, 0.7, 1)  -- Light gray
    label:SetText("Hover: Info, Click: Expand Boss")
    label:SetAnchor(TOPLEFT, sc, TOPLEFT, 10, offsetY)
    offsetY = offsetY + 25

    -- Create boss entries if data exists
    if data and data.bosses and #data.bosses > 0 then
        Debug("Populating " .. tostring(#data.bosses) .. " bosses.")
        
        for _, bData in ipairs(data.bosses) do
            local entry = TTDungeon.CreateBossLine(bData, zoneId)
            if entry then
                entry:ClearAnchors()
                entry:SetAnchor(TOPLEFT, sc, TOPLEFT, 0, offsetY)
                offsetY = offsetY + entry:GetHeight() + 5
                table.insert(TTDungeon.bossEntries, entry)
            end
        end
    else
        Debug("No boss data found to populate.")
    end

    -- Set final container height with padding
    offsetY = offsetY + 10
    sc:SetHeight(offsetY)
    
    -- Update scroll clamping
    if TTDungeon.encounterScroll then
        TTDungeon.BossDetail_ClampScrollOffset(TTDungeon.encounterScroll)
    end
end