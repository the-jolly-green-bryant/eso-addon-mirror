Nvk3UT = Nvk3UT or {}
local Addon = Nvk3UT

Addon.TrackerHostLayout = Addon.TrackerHostLayout or {}
local Layout = Addon.TrackerHostLayout

local SECTION_DEFINITIONS = {
    questSectionContainer = { id = "quest", displayName = "Quest" },
    endeavorSectionContainer = { id = "endeavor", displayName = "Endeavor" },
    achievementSectionContainer = { id = "achievement", displayName = "Achievement" },
    goldenSectionContainer = { id = "golden", displayName = "Golden" },
}

local DEFAULT_SECTION_ORDER = {
    "questSectionContainer",
    "endeavorSectionContainer",
    "achievementSectionContainer",
    "goldenSectionContainer",
}

local SECTION_SPACING_Y = 0

local function copyOrder(order)
    local copy = {}
    for index, value in ipairs(order) do
        copy[index] = value
    end
    return copy
end

local SECTION_ORDER = copyOrder(DEFAULT_SECTION_ORDER)

local function debugLog(fmt, ...)
    local diagnostics = Addon and Addon.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("TrackerHostLayout", fmt, ...)
        return
    end

    if Addon then
        local debugFn = Addon.Debug
        if type(debugFn) == "function" then
            pcall(debugFn, Addon, fmt, ...)
        end
    end
end

-- Local debug helper for TrackerHostLayout
local function isDebug()
    return Addon and Addon.Diagnostics and type(Addon.Diagnostics.IsEnabled) == "function"
           and Addon.Diagnostics:IsEnabled()
end
local ANCHOR_TOLERANCE = 0.01

local function normalizeSectionOrder(orderTable)
    local sanitized = {}
    local seen = {}

    if type(orderTable) == "table" then
        for _, key in ipairs(orderTable) do
            if type(key) == "string" and SECTION_DEFINITIONS[key] and not seen[key] then
                sanitized[#sanitized + 1] = key
                seen[key] = true
            end
        end
    end

    for _, key in ipairs(DEFAULT_SECTION_ORDER) do
        if not seen[key] then
            sanitized[#sanitized + 1] = key
            seen[key] = true
        end
    end

    return sanitized
end

local function formatOrder(order)
    local labels = {}
    for index, key in ipairs(order) do
        local definition = SECTION_DEFINITIONS[key]
        labels[index] = definition and definition.displayName or tostring(key)
    end

    return table.concat(labels, ", ")
end

local function ordersEqual(a, b)
    if a == b then
        return true
    end

    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end

    if #a ~= #b then
        return false
    end

    for index = 1, #a do
        if a[index] ~= b[index] then
            return false
        end
    end

    return true
end

function Layout.GetDefaultSectionOrder()
    return copyOrder(DEFAULT_SECTION_ORDER)
end

function Layout.GetSectionOrder()
    return copyOrder(SECTION_ORDER)
end

function Layout.SetSectionOrder(orderTable)
    local previousOrder = SECTION_ORDER
    local normalized = normalizeSectionOrder(orderTable)

    if not ordersEqual(previousOrder, normalized) and isDebug() then
        debugLog(
            "HostLayout: section order %s → %s",
            formatOrder(previousOrder),
            formatOrder(normalized)
        )
    end

    SECTION_ORDER = normalized

    return Layout.GetSectionOrder()
end

local function getHost(host)
    if type(host) == "table" then
        return host
    end

    if type(Addon.TrackerHost) == "table" then
        return Addon.TrackerHost
    end

    return nil
end

local function getSectionParent(host)
    if host and type(host.GetSectionParent) == "function" then
        local parent = host.GetSectionParent()
        if parent ~= nil then
            return parent
        end
    end

    return nil
end

local function GetOrderedSections(host)
    host = getHost(host)

    local registry
    local trackerHost = Addon and Addon.TrackerHost
    if type(trackerHost) == "table" and type(trackerHost.sectionContainers) == "table" then
        registry = trackerHost.sectionContainers
    end

    if not registry and host and type(host.sectionContainers) == "table" then
        registry = host.sectionContainers
    end

    local ordered = {}
    local orderList = SECTION_ORDER
    if type(orderList) ~= "table" then
        orderList = DEFAULT_SECTION_ORDER
    end

    for _, sectionKey in ipairs(orderList) do
        local definition = SECTION_DEFINITIONS[sectionKey]
        local sectionId = definition and definition.id or sectionKey
        local container
        if registry then
            container = registry[sectionId]
        end

        if not container then
            container = getSectionContainer(host, sectionKey)
        end

        if container then
            ordered[#ordered + 1] = {
                id = sectionId,
                key = sectionKey,
                definition = SECTION_DEFINITIONS[sectionKey],
                container = container,
            }
        end
    end

    return ordered or {}
end

local function getSectionContainer(host, sectionKey)
    if type(host) == "table" and host[sectionKey] ~= nil then
        return host[sectionKey]
    end

    if host and type(host.GetSectionContainer) == "function" then
        local definition = SECTION_DEFINITIONS[sectionKey]
        local sectionId = definition and definition.id or sectionKey
        return host.GetSectionContainer(sectionId)
    end

    return nil
end

local function getLayoutSettings(host)
    if host and type(host.GetLayoutSettings) == "function" then
        return host.GetLayoutSettings()
    end

    return nil
end

local function getWindowBars(host)
    if host and type(host.GetWindowBarSettings) == "function" then
        return host.GetWindowBarSettings()
    end

    return nil
end

local function getHeaderControl(host)
    if host and type(host.GetHeaderControl) == "function" then
        return host.GetHeaderControl()
    end

    return nil
end

local function getFooterControl(host)
    if host and type(host.GetFooterControl) == "function" then
        return host.GetFooterControl()
    end

    return nil
end

local function getContentStack(host)
    if host and type(host.GetContentStack) == "function" then
        return host.GetContentStack()
    end

    return nil
end

local function getScrollContent(host)
    if host and type(host.GetScrollContent) == "function" then
        return host.GetScrollContent()
    end

    return nil
end

local function getScrollContainer(host)
    if host and type(host.GetScrollContainer) == "function" then
        return host.GetScrollContainer()
    end

    return nil
end

local function getScrollbar(host)
    if host and type(host.GetScrollbar) == "function" then
        return host.GetScrollbar()
    end

    return nil
end

local function getScrollbarWidth(host)
    if host and type(host.GetScrollbarWidth) == "function" then
        local width = host.GetScrollbarWidth()
        if width ~= nil then
            width = tonumber(width)
            if width then
                return width
            end
        end
    end

    local scrollbar = getScrollbar(host)
    if scrollbar and type(scrollbar.GetWidth) == "function" then
        local ok, measured = pcall(scrollbar.GetWidth, scrollbar)
        if ok then
            measured = tonumber(measured)
            if measured then
                return measured
            end
        end
    end

    return 0
end

local function getScrollOvershootPadding(host)
    if host and type(host.GetScrollOvershootPadding) == "function" then
        local padding = host.GetScrollOvershootPadding()
        padding = tonumber(padding)
        if padding then
            if padding < 0 then
                padding = 0
            end
            return padding
        end
    end

    return 0
end

local function getScrollContentRightOffset(host)
    if host and type(host.GetScrollContentRightOffset) == "function" then
        local offset = host.GetScrollContentRightOffset()
        offset = tonumber(offset)
        if offset then
            return offset
        end
    end

    return 0
end

local function setScrollContentRightOffset(host, offset)
    if host and type(host.SetScrollContentRightOffset) == "function" then
        host.SetScrollContentRightOffset(offset)
    end
end

local function updateScrollbarRange(host, minimum, maximum)
    if host and type(host.UpdateScrollbarRange) == "function" then
        host.UpdateScrollbarRange(minimum, maximum)
        return
    end

    local scrollbar = getScrollbar(host)
    if not (scrollbar and type(scrollbar.SetMinMax) == "function") then
        return
    end

    pcall(scrollbar.SetMinMax, scrollbar, minimum or 0, maximum or 0)
end

local function setScrollbarHidden(host, hidden)
    if host and type(host.SetScrollbarHidden) == "function" then
        host.SetScrollbarHidden(hidden)
        return
    end

    local scrollbar = getScrollbar(host)
    if scrollbar and type(scrollbar.SetHidden) == "function" then
        scrollbar:SetHidden(hidden)
    end
end

local function setScrollMaxOffset(host, maxOffset)
    if host and type(host.SetScrollMaxOffset) == "function" then
        host.SetScrollMaxOffset(maxOffset)
    end
end

local function getScrollState(host)
    if host and type(host.GetScrollState) == "function" then
        local state = host.GetScrollState()
        if type(state) == "table" then
            return state
        end
    end

    local actual = 0
    local desired

    if host and type(host.GetScrollOffset) == "function" then
        actual = tonumber(host.GetScrollOffset()) or 0
    end

    return { actual = actual, desired = desired }
end

local function setScrollOffset(host, offset, skipScrollbarUpdate)
    if host and type(host.SetScrollOffset) == "function" then
        host.SetScrollOffset(offset, skipScrollbarUpdate)
    end
end

local function isControlHidden(control)
    if not control then
        return true
    end

    local isHidden = control.IsHidden
    if type(isHidden) == "function" then
        local hidden = isHidden(control)
        if hidden ~= nil then
            return hidden == true
        end
    end

    return false
end

local function getTrackerHeight(sectionId)
    local tracker
    if sectionId == "quest" then
        tracker = Addon and Addon.QuestTracker
    elseif sectionId == "endeavor" then
        tracker = (Addon and Addon.Endeavor) or (Addon and Addon.EndeavorTracker)
    elseif sectionId == "achievement" then
        tracker = Addon and Addon.AchievementTracker
    elseif sectionId == "golden" then
        tracker = Addon and Addon.GoldenTracker
    end

    if type(tracker) ~= "table" then
        return nil
    end

    local getHeight = tracker.GetHeight or tracker.GetContentHeight or tracker.GetSize
    if type(getHeight) ~= "function" then
        return nil
    end

    local ok, height = pcall(getHeight, tracker)
    if not ok then
        return nil
    end

    local resolved = tonumber(height)
    if resolved == nil or resolved ~= resolved or resolved < 0 then
        return 0
    end

    return resolved
end

local function measureSection(host, sectionId, container)
    local width = 0
    local height = 0
    local hostWidth
    local hostHeight

    if host and type(host.GetSectionMeasurements) == "function" then
        local measuredWidth, measuredHeight = host.GetSectionMeasurements(sectionId)
        width = tonumber(measuredWidth) or 0
        height = tonumber(measuredHeight) or 0
        hostWidth = width
        hostHeight = height
    end

    local trackerHeight = getTrackerHeight(sectionId)
    if trackerHeight ~= nil then
        height = trackerHeight
    end

    local runtime = Addon and Addon.TrackerRuntime
    if runtime and type(runtime._geometry) == "table" then
        local geometry = runtime._geometry[sectionId]
        if type(geometry) == "table" then
            width = math.max(width, tonumber(geometry.width) or 0)
            height = math.max(height, tonumber(geometry.height) or 0)
        end
    end

    local fallbackWidth
    local fallbackHeight
    if (width <= 0 or height <= 0) and container then
        local holder = container.holder
        if holder and holder.GetWidth and holder.GetHeight then
            width = math.max(width, tonumber(holder:GetWidth()) or 0)
            height = math.max(height, tonumber(holder:GetHeight()) or 0)
            fallbackWidth = width
            fallbackHeight = height
        else
            if container.GetWidth then
                width = math.max(width, tonumber(container:GetWidth()) or 0)
            end
            if container.GetHeight then
                height = math.max(height, tonumber(container:GetHeight()) or 0)
            end
            fallbackWidth = fallbackWidth or width
            fallbackHeight = fallbackHeight or height
        end
    end

    if width < 0 then
        width = 0
    end

    if height < 0 then
        height = 0
    end

    if isDebug() then
        if sectionId == "endeavor" or sectionId == "achievement" then
            debugLog(
                "HostLayout: measureSection section=%s host=(%s,%s) fallback=(%s,%s) final=(%s,%s)",
                tostring(sectionId),
                tostring(hostWidth),
                tostring(hostHeight),
                tostring(fallbackWidth),
                tostring(fallbackHeight),
                tostring(width),
                tostring(height)
            )
        end
    end

    return width, height
end

local function getAnchor(control, index)
    if type(control.GetAnchor) ~= "function" then
        return nil
    end

    local ok, point, relativeTo, relativePoint, offsetX, offsetY = pcall(control.GetAnchor, control, index)
    if not ok then
        return nil
    end

    return point, relativeTo, relativePoint, offsetX or 0, offsetY or 0
end

local function anchorsMatch(control, anchors)
    if type(control.GetNumAnchors) ~= "function" then
        return false
    end

    local numAnchors = control:GetNumAnchors()
    if numAnchors ~= #anchors then
        return false
    end

    for index, expected in ipairs(anchors) do
        local anchorIndex = index - 1
        local point, relativeTo, relativePoint, offsetX, offsetY = getAnchor(control, anchorIndex)
        if not point then
            return false
        end

        if point ~= expected.point or relativeTo ~= expected.relativeTo or relativePoint ~= expected.relativePoint then
            return false
        end

        if math.abs((offsetX or 0) - (expected.offsetX or 0)) > ANCHOR_TOLERANCE then
            return false
        end

        if math.abs((offsetY or 0) - (expected.offsetY or 0)) > ANCHOR_TOLERANCE then
            return false
        end
    end

    return true
end

local function applyAnchors(control, anchors)
    if not control or type(control.ClearAnchors) ~= "function" or type(control.SetAnchor) ~= "function" then
        return false
    end

    if anchorsMatch(control, anchors) then
        return false
    end

    control:ClearAnchors()

    for _, anchor in ipairs(anchors) do
        control:SetAnchor(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.offsetX or 0, anchor.offsetY or 0)
    end

    return true
end

local function reportAnchored(host, sectionId)
    if host and type(host.ReportSectionAnchored) == "function" then
        host.ReportSectionAnchored(sectionId)
    end
end

local function reportMissing(host, sectionId)
    if host and type(host.ReportSectionMissing) == "function" then
        host.ReportSectionMissing(sectionId)
    end
end

local function sanitizeLength(value)
    local number = tonumber(value)
    if not number then
        return 0
    end

    if number < 0 then
        number = 0
    end

    return number
end

local function resolvePadding(layout, keys)
    if type(layout) ~= "table" then
        return 0
    end

    for _, key in ipairs(keys) do
        local value = layout[key]
        if value ~= nil then
            local number = tonumber(value)
            if number then
                if number < 0 then
                    number = 0
                end
                return number
            end
        end
    end

    return 0
end

local function numbersDiffer(a, b, tolerance)
    if a == b then
        return false
    end

    if a == nil or b == nil then
        return true
    end

    if a == math.huge or b == math.huge then
        return a ~= b
    end

    tolerance = tolerance or ANCHOR_TOLERANCE
    return math.abs(a - b) > tolerance
end

local function copyTable(source)
    if type(source) ~= "table" then
        return source
    end

    local target = {}
    for key, value in pairs(source) do
        target[key] = value
    end

    return target
end

Layout._lastSizes = Layout._lastSizes or nil
Layout._lastScrollMetrics = Layout._lastScrollMetrics or setmetatable({}, { __mode = "k" })
Layout._loggedSectionSpacing = Layout._loggedSectionSpacing or false

function Layout.UpdateHeaderFooterSizes(host)
    host = getHost(host)

    local result = {
        headerHeight = 0,
        footerHeight = 0,
        headerTargetHeight = 0,
        footerTargetHeight = 0,
        headerVisible = false,
        footerVisible = false,
        headerPadding = 0,
        footerPadding = 0,
        contentTopPadding = 0,
        contentBottomPadding = 0,
        contentTopY = 0,
        contentBottomY = math.huge,
        headerChanged = false,
        footerChanged = false,
        changed = false,
    }

    if not host then
        Layout._lastSizes = copyTable(result)
        return result
    end

    local layout = getLayoutSettings(host)
    local headerPadding = resolvePadding(layout, { "headerPadding", "contentPaddingTop", "contentPadding" })
    local footerPadding = resolvePadding(layout, { "footerPadding", "contentPaddingBottom", "contentPadding" })

    local bars = getWindowBars(host) or {}
    local headerTargetHeight = sanitizeLength(bars.headerHeightPx)
    local footerTargetHeight = sanitizeLength(bars.footerHeightPx)

    local headerVisible = headerTargetHeight > 0
    local footerVisible = footerTargetHeight > 0

    local headerControl = getHeaderControl(host)
    local footerControl = getFooterControl(host)

    local headerEffectiveHeight = headerTargetHeight
    if headerControl and type(headerControl.GetHeight) == "function" then
        local ok, measured = pcall(headerControl.GetHeight, headerControl)
        if ok then
            measured = sanitizeLength(measured)
            if measured > 0 then
                headerEffectiveHeight = measured
            end
        end
    end
    if not headerVisible then
        headerEffectiveHeight = 0
    end

    local footerEffectiveHeight = footerTargetHeight
    if footerControl and type(footerControl.GetHeight) == "function" then
        local ok, measured = pcall(footerControl.GetHeight, footerControl)
        if ok then
            measured = sanitizeLength(measured)
            if measured > 0 then
                footerEffectiveHeight = measured
            end
        end
    end
    if not footerVisible then
        footerEffectiveHeight = 0
    end

    local parent = getSectionParent(host)
    local contentStack = getContentStack(host)
    local scrollContent = getScrollContent(host)

    local contentTopY
    if parent and contentStack and parent == contentStack then
        contentTopY = headerPadding
    else
        contentTopY = headerEffectiveHeight + headerPadding
    end
    contentTopY = sanitizeLength(contentTopY)

    local contentBottomY
    if parent and contentStack and parent == contentStack then
        local parentHeight = parent.GetHeight and parent:GetHeight()
        parentHeight = tonumber(parentHeight)
        if parentHeight and parentHeight > 0 then
            contentBottomY = math.max(contentTopY, sanitizeLength(parentHeight) - footerPadding)
        end
    else
        local container = scrollContent or parent
        local totalHeight = container and container.GetHeight and container:GetHeight()
        totalHeight = tonumber(totalHeight)
        if totalHeight and totalHeight > 0 then
            local candidate = sanitizeLength(totalHeight) - (footerEffectiveHeight + footerPadding)
            contentBottomY = math.max(contentTopY, candidate)
        end
    end

    if not contentBottomY or contentBottomY <= contentTopY then
        contentBottomY = math.huge
    end

    local last = Layout._lastSizes
    local headerChanged = not last
        or numbersDiffer(last.headerTargetHeight, headerTargetHeight)
        or numbersDiffer(last.headerHeight, headerEffectiveHeight)
        or (last.headerVisible ~= headerVisible)
        or numbersDiffer(last.headerPadding or 0, headerPadding)
    local footerChanged = not last
        or numbersDiffer(last.footerTargetHeight, footerTargetHeight)
        or numbersDiffer(last.footerHeight, footerEffectiveHeight)
        or (last.footerVisible ~= footerVisible)
        or numbersDiffer(last.footerPadding or 0, footerPadding)

    local topChanged = not last or numbersDiffer(last.contentTopY, contentTopY)
    local bottomChanged = not last or numbersDiffer(last.contentBottomY, contentBottomY)
    local changed = headerChanged or footerChanged or topChanged or bottomChanged

    result.headerHeight = headerEffectiveHeight
    result.footerHeight = footerEffectiveHeight
    result.headerTargetHeight = headerTargetHeight
    result.footerTargetHeight = footerTargetHeight
    result.headerVisible = headerVisible
    result.footerVisible = footerVisible
    result.headerPadding = headerPadding
    result.footerPadding = footerPadding
    result.contentTopPadding = headerPadding
    result.contentBottomPadding = footerPadding
    result.contentTopY = contentTopY
    result.contentBottomY = contentBottomY
    result.headerChanged = headerChanged
    result.footerChanged = footerChanged
    result.changed = changed

    Layout._lastSizes = {
        headerHeight = headerEffectiveHeight,
        footerHeight = footerEffectiveHeight,
        headerTargetHeight = headerTargetHeight,
        footerTargetHeight = footerTargetHeight,
        headerVisible = headerVisible,
        footerVisible = footerVisible,
        headerPadding = headerPadding,
        footerPadding = footerPadding,
        contentTopY = contentTopY,
        contentBottomY = contentBottomY,
    }

    return result
end

function Layout.UpdateScrollAreaHeight(host, contentHeight, sizes)
    host = getHost(host)
    if not host then
        return 0
    end

    if type(sizes) ~= "table" then
        sizes = Layout.UpdateHeaderFooterSizes(host)
    end

    local scrollContainer = getScrollContainer(host)
    local scrollContent = getScrollContent(host)
    if not (scrollContainer and scrollContent) then
        return 0
    end

    local metrics = Layout._lastScrollMetrics
    local last = metrics[host]
    if not last then
        last = {}
        metrics[host] = last
    end

    local stackHeight = sanitizeLength(contentHeight)
    if stackHeight < 0 then
        stackHeight = 0
    end

    local headerHeight = 0
    if sizes and sizes.headerVisible ~= false then
        headerHeight = sanitizeLength(sizes.headerTargetHeight or sizes.headerHeight)
    end

    local footerHeight = 0
    if sizes and sizes.footerVisible ~= false then
        footerHeight = sanitizeLength(sizes.footerTargetHeight or sizes.footerHeight)
    end

    local previousScrollChildHeight = last.scrollChildHeight
    local scrollChildHeight = headerHeight + stackHeight + footerHeight
    if scrollChildHeight < 0 then
        scrollChildHeight = 0
    end

    if type(scrollContent.SetResizeToFitDescendents) == "function" then
        scrollContent:SetResizeToFitDescendents(false)
    end

    local scrollChildHeightChanged = not previousScrollChildHeight
        or numbersDiffer(previousScrollChildHeight, scrollChildHeight)

    if type(scrollContent.SetHeight) == "function" then
        if scrollChildHeightChanged then
            scrollContent:SetHeight(scrollChildHeight)
            last.scrollChildHeight = scrollChildHeight
        end
    else
        last.scrollChildHeight = scrollChildHeight
    end

    local viewportHeight

    if type(scrollContainer.GetHeight) == "function" then
        local ok, height = pcall(scrollContainer.GetHeight, scrollContainer)
        if ok then
            viewportHeight = sanitizeLength(height)
        end
    end

    viewportHeight = sanitizeLength(viewportHeight or 0)
    if viewportHeight < 0 then
        viewportHeight = 0
    end

    last.viewportHeight = viewportHeight

    local overshoot = getScrollOvershootPadding(host)
    local maxOffset = math.max(scrollChildHeight - viewportHeight + overshoot, 0)

    if not last.maxOffset or numbersDiffer(last.maxOffset, maxOffset) then
        setScrollMaxOffset(host, maxOffset)
        updateScrollbarRange(host, 0, maxOffset)
        last.maxOffset = maxOffset
    else
        setScrollMaxOffset(host, maxOffset)
    end

    local showScrollbar = maxOffset > 0.5
    local desiredRightOffset = 0

    if showScrollbar then
        local width = getScrollbarWidth(host)
        width = sanitizeLength(width)
        desiredRightOffset = -width
    end

    if not last.scrollbarHidden or last.scrollbarHidden ~= (not showScrollbar) then
        setScrollbarHidden(host, not showScrollbar)
        last.scrollbarHidden = not showScrollbar
    end

    local previousRightOffset = getScrollContentRightOffset(host)
    if numbersDiffer(previousRightOffset, desiredRightOffset) then
        setScrollContentRightOffset(host, desiredRightOffset)
        last.rightOffset = desiredRightOffset
    else
        last.rightOffset = previousRightOffset
    end

    local state = getScrollState(host)
    local actual = state and tonumber(state.actual) or 0
    if actual > maxOffset then
        setScrollOffset(host, maxOffset, true)
    end

    if scrollChildHeightChanged then
        if not last._pendingDeferredScrollRange then
            last._pendingDeferredScrollRange = true

            zo_callLater(function()
                last._pendingDeferredScrollRange = nil

                -- Re-read scroll child and viewport
                local scrollContainer = getScrollContainer(host)
                local scrollContent   = getScrollContent(host)

                if scrollContainer and scrollContent then
                    local okH, h  = pcall(scrollContent.GetHeight, scrollContent)
                    local okV, vh = pcall(scrollContainer.GetHeight, scrollContainer)
                    if okH and okV and type(h) == "number" and type(vh) == "number" then
                        local newRange = math.max(h - vh, 0)

                        -- Use our own scroll range function (same as main path)
                        setScrollMaxOffset(host, newRange)
                        updateScrollbarRange(host, 0, newRange)

                        debugLog(string.format(
                            "[DeferredRange] child=%s viewport=%s newRange=%s",
                            tostring(h), tostring(vh), tostring(newRange)
                        ))
                    end
                end
            end, 0)
        end
    end

    return viewportHeight
end

function Layout.ApplyLayout(host, sizes)
    host = getHost(host)
    if not host then
        return 0
    end

    if not Layout._loggedSectionSpacing then
        debugLog("HostLayout: Section spacing set to %dpx", SECTION_SPACING_Y)
        Layout._loggedSectionSpacing = true
    end

    if type(sizes) ~= "table" then
        sizes = Layout.UpdateHeaderFooterSizes(host)
    end

    local parent = getSectionParent(host)
    if not parent then
        debugLog("HostLayout: no section parent for host, skipping layout")
        return 0
    end

    local sections = GetOrderedSections(host)
    if type(sections) ~= "table" then
        debugLog("HostLayout: GetOrderedSections returned %s, skipping layout", type(sections))
        return 0
    end

    if #sections == 0 then
        debugLog("HostLayout: GetOrderedSections returned empty list, skipping layout")
        return 0
    end

    local gap = SECTION_SPACING_Y

    local startOffset = sanitizeLength(sizes and sizes.contentTopY)
    local topPadding = sanitizeLength(sizes and sizes.contentTopPadding)
    local bottomPadding = sanitizeLength(sizes and sizes.contentBottomPadding)
    local limitBottom = sizes and tonumber(sizes.contentBottomY)
    if limitBottom and (limitBottom == math.huge or limitBottom <= startOffset) then
        limitBottom = nil
    end

    local totalHeight = topPadding
    local previousVisible
    local placedCount = 0
    local currentTop = startOffset

    if isDebug() then
        local ids = {}
        for index, entry in ipairs(sections) do
            ids[index] = tostring(entry.id or entry.key or index)
        end
        debugLog("HostLayout: Sections to layout: %s", table.concat(ids, ", "))
    end

    local foundSections = {}
    for _, entry in ipairs(sections) do
        foundSections[entry.id] = true
    end

    if type(ORDERED_SECTIONS) == "table" then
        for _, spec in ipairs(ORDERED_SECTIONS) do
            if not foundSections[spec.id] then
                reportMissing(host, spec.id)
            end
        end
    elseif isDebug() then
        debugLog("HostLayout: ORDERED_SECTIONS missing or invalid (type=%s)", type(ORDERED_SECTIONS))
    end

    local goldenAccounted = false

    for _, section in ipairs(sections) do
        local container = section.container
        local sectionId = section.id

        local _, height = measureSection(host, sectionId, container)
        local isEndeavorSection = sectionId == "endeavor"
        local isAchievementSection = sectionId == "achievement"

        if (isEndeavorSection or isAchievementSection) and isDebug() then
            debugLog(
                "HostLayout: %s measured height=%s currentTop=%s",
                tostring(sectionId),
                tostring(height),
                tostring(currentTop)
            )
        end

        -- Endeavor visibility is driven by the tracker layout via hideEntireSection, which sets
        -- _nvk3utAutoHidden and collapses the measured height. This avoids host-side height <= 0
        -- heuristics permanently hiding the section when content briefly measures to zero.
        local autoHiddenBefore = container and container._nvk3utAutoHidden == true
        local sectionVisibleBefore = not isControlHidden(container)
        local collapsed = isEndeavorSection and autoHiddenBefore

        if container and type(container.ClearAnchors) == "function" then
            container:ClearAnchors()
        end

        local sectionVisible = sectionVisibleBefore and not collapsed
        local predictedBottom = currentTop + height
        local blockedByLimit = sectionVisible
            and limitBottom
            and predictedBottom > (limitBottom + ANCHOR_TOLERANCE)

        if isEndeavorSection then
            local autoHiddenAfter = container and container._nvk3utAutoHidden == true
            debugLog(
                "HostLayout: Endeavor section height=%s collapsed=%s visibleBefore=%s visibleAfter=%s autoHidden(before=%s after=%s) limitBottom=%s predictedBottom=%s blockedByLimit=%s",
                tostring(height),
                tostring(collapsed),
                tostring(sectionVisibleBefore),
                tostring(sectionVisible),
                tostring(autoHiddenBefore),
                tostring(autoHiddenAfter),
                tostring(limitBottom),
                tostring(predictedBottom),
                tostring(blockedByLimit)
            )
        end

        if sectionVisible then
            local anchorTarget = previousVisible or parent
            local anchors
            local anchorTargetName = anchorTarget and anchorTarget.GetName and anchorTarget:GetName() or "<nil>"
            local topOffset = previousVisible and gap or startOffset

            if isAchievementSection then
                debugLog(
                    "HostLayout: Achievement section visible=%s height=%s anchorTarget=%s offsetY=%s predictedBottom=%s",
                    tostring(sectionVisible),
                    tostring(height),
                    tostring(anchorTargetName),
                    tostring(topOffset),
                    tostring(predictedBottom)
                )
            end

            if blockedByLimit then
                break
            end

            if previousVisible then
                anchors = {
                    { point = TOPLEFT, relativeTo = anchorTarget, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = gap },
                    { point = TOPRIGHT, relativeTo = anchorTarget, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = gap },
                }
            else
                anchors = {
                    { point = TOPLEFT, relativeTo = anchorTarget, relativePoint = TOPLEFT, offsetX = 0, offsetY = topOffset },
                    { point = TOPRIGHT, relativeTo = anchorTarget, relativePoint = TOPRIGHT, offsetX = 0, offsetY = topOffset },
                }
            end

            if container and type(container.SetAnchor) == "function" and type(container.ClearAnchors) == "function" then
                applyAnchors(container, anchors)
            end

            if sectionId == "golden" then
                local anchorTargetName = anchorTarget and anchorTarget.GetName and anchorTarget:GetName() or "<nil>"
                debugLog(
                    "HostLayout: goldenSection anchored under %s (height=%d)",
                    anchorTargetName,
                    height
                )
            end

            if placedCount > 0 then
                totalHeight = totalHeight + gap
            end

            totalHeight = totalHeight + height
            currentTop = currentTop + height + gap
            previousVisible = container
            placedCount = placedCount + 1

            if sectionId == "golden" then
                goldenAccounted = true
            end
        elseif sectionId == "golden" then
            goldenAccounted = goldenAccounted or height > 0
        else
            if container and type(container.SetHeight) == "function" then
                container:SetHeight(height)
            end
            if isAchievementSection then
                debugLog(
                    "HostLayout: Achievement section hidden height=%s limitBottom=%s predictedBottom=%s",
                    tostring(height),
                    tostring(limitBottom),
                    tostring(predictedBottom)
                )
            end
        end

        reportAnchored(host, sectionId)
    end

    if not goldenAccounted then
        local goldenTracker = Addon and Addon.GoldenTracker
        local getHeight = goldenTracker and goldenTracker.GetHeight
        if type(getHeight) == "function" then
            local ok, measured = pcall(getHeight, goldenTracker)
            if ok then
                local extraHeight = sanitizeLength(measured)
                if extraHeight > 0 then
                    totalHeight = totalHeight + extraHeight
                end
            end
        end
    end

    totalHeight = totalHeight + bottomPadding

    if totalHeight < 0 then
        totalHeight = 0
    end

    Layout.UpdateScrollAreaHeight(host, totalHeight, sizes)

    local orderLabels = {}
    local controlNames = {}
    for index, section in ipairs(sections) do
        local sectionId = section.id
        local definition = section.definition
        orderLabels[index] = definition and definition.displayName or tostring(sectionId)

        local controlName
        local control = section.container
        if control and type(control.GetName) == "function" then
            local ok, name = pcall(control.GetName, control)
            if ok and name then
                controlName = tostring(name)
            end
        end

        controlNames[index] = controlName or tostring(sectionId)
    end

    local suffix = ""
    if #controlNames > 0 then
        suffix = string.format("; controls=%s", table.concat(controlNames, " → "))
    end

    debugLog(
        "HostLayout: section spacing = %dpx (%s); placed=%d%s",
        SECTION_SPACING_Y,
        table.concat(orderLabels, " → "),
        placedCount,
        suffix
    )

    return totalHeight
end

Layout.Apply = Layout.ApplyLayout

return Layout
