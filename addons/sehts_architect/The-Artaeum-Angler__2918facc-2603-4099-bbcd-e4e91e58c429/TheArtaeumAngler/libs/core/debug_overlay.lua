(function()
    return function(Addon)
        Addon.Debug = Addon.Debug or {}
        Addon.DebugOverlay = Addon.DebugOverlay or {}
    
        local DebugOverlay = Addon.DebugOverlay
        local OVERLAY_WIDTH = 620
        local MIN_BODY_HEIGHT = 40
        local MIN_HEIGHT = 120
        local PADDING_X = 18
        local PADDING_Y = 14
        local LINE_HEIGHT = 24
        local SECTION_SPACING = ""
        local TITLE_HEIGHT = 28
        local MAX_LOG_ENTRIES = 8
        local ROOT_DRAW_LEVEL = 320
        local BACKDROP_DRAW_LEVEL = 321
        local TEXT_DRAW_LEVEL = 322
    
        DebugOverlay.sectionOrder = DebugOverlay.sectionOrder or {}
        DebugOverlay.sections = DebugOverlay.sections or {}
        DebugOverlay.logEntries = DebugOverlay.logEntries or {}
    
        local function isEnabled()
            return Addon.Debug and Addon.Debug.enabled == true
        end
    
        local function getOverlayTitle()
            if Addon.Debug and type(Addon.Debug.overlayTitle) == "string" and Addon.Debug.overlayTitle ~= "" then
                return Addon.Debug.overlayTitle
            end
    
            return string.format("%s Debug Telemetry", Addon.Name)
        end
    
        local function ensureSectionOrder(sectionKey)
            for _, existingKey in ipairs(DebugOverlay.sectionOrder) do
                if existingKey == sectionKey then
                    return
                end
            end
    
            DebugOverlay.sectionOrder[#DebugOverlay.sectionOrder + 1] = sectionKey
        end
    
        local function formatEventTime()
            if type(GetFrameTimeMilliseconds) ~= "function" then
                return "--.--"
            end
    
            return string.format("%0.2f", GetFrameTimeMilliseconds() / 1000)
        end
    
        local function ensureControls()
            if DebugOverlay.root then
                return true
            end
    
            if type(CreateTopLevelWindow) ~= "function"
                or type(CreateControl) ~= "function"
                or type(CreateControlFromVirtual) ~= "function"
            then
                return false
            end
    
            local overlayName = string.format("%sDebugOverlay", Addon.Name)
            local root = CreateTopLevelWindow(overlayName)
            local backdrop = CreateControlFromVirtual(overlayName .. "Backdrop", root, "ZO_DefaultBackdrop_Gamepad")
            local titleLabel = CreateControl(overlayName .. "Title", root, CT_LABEL)
            local offsetX = Addon.Debug and Addon.Debug.offsetX or 24
            local offsetY = Addon.Debug and Addon.Debug.offsetY or 180
    
            root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
            root:SetDimensions(OVERLAY_WIDTH, MIN_HEIGHT)
            root:SetDrawLayer(DL_OVERLAY)
            root:SetDrawTier(DT_HIGH)
            root:SetDrawLevel(ROOT_DRAW_LEVEL)
            root:SetTopmost(true)
            root:SetAlpha(1)
            root:SetMouseEnabled(false)
            root:SetMovable(false)
            root:SetHidden(true)
    
            backdrop:SetAnchorFill(root)
            backdrop:SetDrawLayer(DL_OVERLAY)
            backdrop:SetDrawTier(DT_HIGH)
            backdrop:SetDrawLevel(BACKDROP_DRAW_LEVEL)
            backdrop:SetAlpha(1)
            backdrop:SetCenterColor(0.04, 0.07, 0.11, 0.96)
            backdrop:SetEdgeColor(0.70, 0.80, 0.92, 1)
    
            titleLabel:SetAnchor(TOPLEFT, root, TOPLEFT, PADDING_X, PADDING_Y)
            titleLabel:SetDimensions(OVERLAY_WIDTH - (PADDING_X * 2), TITLE_HEIGHT)
            titleLabel:SetDrawLayer(DL_OVERLAY)
            titleLabel:SetDrawTier(DT_HIGH)
            titleLabel:SetDrawLevel(TEXT_DRAW_LEVEL)
            titleLabel:SetFont("ZoFontGamepad27")
            titleLabel:SetColor(0.98, 0.98, 0.95, 1)
            titleLabel:SetText(getOverlayTitle())
    
            DebugOverlay.root = root
            DebugOverlay.backdrop = backdrop
            DebugOverlay.titleLabel = titleLabel
            DebugOverlay.bodyLabels = DebugOverlay.bodyLabels or {}
            DebugOverlay.overlayName = overlayName
    
            return true
        end
    
        local function ensureBodyLabels(requiredCount)
            if not DebugOverlay.root or not DebugOverlay.titleLabel then
                return
            end
    
            while #DebugOverlay.bodyLabels < requiredCount do
                local labelIndex = #DebugOverlay.bodyLabels + 1
                local labelName = string.format("%sLine%d", DebugOverlay.overlayName, labelIndex)
                local label = CreateControl(labelName, DebugOverlay.root, CT_LABEL)
    
                if labelIndex == 1 then
                    label:SetAnchor(TOPLEFT, DebugOverlay.titleLabel, BOTTOMLEFT, 0, 10)
                else
                    label:SetAnchor(TOPLEFT, DebugOverlay.bodyLabels[labelIndex - 1], BOTTOMLEFT, 0, 0)
                end
    
                label:SetDimensions(OVERLAY_WIDTH - (PADDING_X * 2), LINE_HEIGHT)
                label:SetDrawLayer(DL_OVERLAY)
                label:SetDrawTier(DT_HIGH)
                label:SetDrawLevel(TEXT_DRAW_LEVEL)
                label:SetFont("ZoFontGamepad20")
                label:SetColor(0.84, 0.91, 0.98, 1)
                label:SetHidden(true)
                DebugOverlay.bodyLabels[labelIndex] = label
            end
        end
    
        local function buildBodyLines()
            local lines = {}
    
            for _, sectionKey in ipairs(DebugOverlay.sectionOrder) do
                local section = DebugOverlay.sections[sectionKey]
    
                if section and section.lines and #section.lines > 0 then
                    lines[#lines + 1] = section.title
    
                    for _, line in ipairs(section.lines) do
                        lines[#lines + 1] = "  " .. tostring(line)
                    end
    
                    lines[#lines + 1] = SECTION_SPACING
                end
            end
    
            while #lines > 0 and lines[#lines] == SECTION_SPACING do
                lines[#lines] = nil
            end
    
            if #DebugOverlay.logEntries > 0 then
                if #lines > 0 then
                    lines[#lines + 1] = ""
                end
    
                lines[#lines + 1] = "Recent Events"
    
                for _, entry in ipairs(DebugOverlay.logEntries) do
                    lines[#lines + 1] = "  " .. entry
                end
            end
    
            if #lines == 0 then
                return { "No telemetry yet." }
            end
    
            return lines
        end
    
        local function render()
            if not ensureControls() then
                return
            end
    
            if not isEnabled() then
                DebugOverlay.root:SetHidden(true)
                return
            end
    
            local bodyLines = buildBodyLines()
    
            DebugOverlay.titleLabel:SetText(getOverlayTitle())
            ensureBodyLabels(#bodyLines)
    
            for index, label in ipairs(DebugOverlay.bodyLabels) do
                local lineText = bodyLines[index]
    
                if lineText then
                    label:SetText(lineText)
                    label:SetHidden(false)
                else
                    label:SetText("")
                    label:SetHidden(true)
                end
            end
    
            local finalBodyHeight = math.max(MIN_BODY_HEIGHT, #bodyLines * LINE_HEIGHT)
            local finalHeight = math.max(MIN_HEIGHT, finalBodyHeight + TITLE_HEIGHT + (PADDING_Y * 3))
    
            DebugOverlay.root:SetHeight(finalHeight)
            DebugOverlay.root:SetHidden(false)
        end
    
        function DebugOverlay.Initialize()
            render()
        end
    
        function DebugOverlay.SetEnabled(enabled)
            Addon.Debug.enabled = enabled == true
            render()
        end
    
        function DebugOverlay.SetSection(sectionKey, title, lines)
            if type(sectionKey) ~= "string" or sectionKey == "" then
                return
            end
    
            ensureSectionOrder(sectionKey)
            DebugOverlay.sections[sectionKey] = {
                title = title or sectionKey,
                lines = lines or {},
            }
    
            render()
        end
    
        function DebugOverlay.ClearSection(sectionKey)
            if type(sectionKey) ~= "string" or sectionKey == "" then
                return
            end
    
            DebugOverlay.sections[sectionKey] = nil
            render()
        end
    
        function DebugOverlay.ClearAll()
            DebugOverlay.sections = {}
            DebugOverlay.logEntries = {}
            render()
        end
    
        function DebugOverlay.PushEvent(message)
            if type(message) ~= "string" or message == "" then
                return
            end
    
            DebugOverlay.logEntries[#DebugOverlay.logEntries + 1] = string.format("[%s] %s", formatEventTime(), message)
    
            while #DebugOverlay.logEntries > MAX_LOG_ENTRIES do
                table.remove(DebugOverlay.logEntries, 1)
            end
    
            render()
        end
    end
    
end)()(_G["TheArtaeumAngler"])
