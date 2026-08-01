---@diagnostic disable: undefined-global

local SecondChatWindow = {
    name = "SecondChatWindow",
    defaults = {
        left = 500,
        top = 500,
        width = 400,
        height = 250,
        isLocked = false,
        selectedGuild = 1,
    }
}

local function ResolveFirstDefined(...)
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if key and _G[key] ~= nil then
            return _G[key]
        end
    end
    return nil
end

-- Keep compatibility if guild constants are renamed in future API bumps.
local function BuildGuildConstantMaps()
    local guildChannels = {}
    local guildCategories = {}

    for i = 1, 5 do
        local channel = ResolveFirstDefined(
            string.format("CHAT_CHANNEL_GUILD_%d", i),
            string.format("CHAT_CHANNEL_GUILD%d", i)
        )
        local category = ResolveFirstDefined(
            string.format("CHAT_CATEGORY_GUILD_%d", i),
            string.format("CHAT_CATEGORY_GUILD%d", i)
        )

        guildChannels[i] = channel
        if channel and category then
            guildCategories[channel] = category
        end
    end

    return guildChannels, guildCategories
end

local GUILD_CHANNELS, GUILD_CHAT_CATEGORIES = BuildGuildConstantMaps()

local allowedChannels = {}

local function Clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

function SecondChatWindow.GetAvailableGuilds()
    local guilds = {}
    local maxGuilds = math.min(GetNumGuilds(), 5)

    for guildNum = 1, maxGuilds do
        local guildId = GetGuildId(guildNum)
        if guildId then
            local guildName = GetGuildName(guildId)
            if guildName and guildName ~= "" then
                table.insert(guilds, {
                    guildNum = guildNum,
                    guildName = guildName,
                })
            end
        end
    end

    return guilds
end

function SecondChatWindow.GetGuildNameByNumber(guildNumber)
    local guildId = GetGuildId(guildNumber)
    if not guildId then
        return nil
    end

    local guildName = GetGuildName(guildId)
    if guildName and guildName ~= "" then
        return guildName
    end

    return nil
end

function SecondChatWindow.EnsureSelectedGuildValid()
    local selectedGuild = SecondChatWindow.db.selectedGuild
    if selectedGuild and SecondChatWindow.GetGuildNameByNumber(selectedGuild) then
        return
    end

    local guilds = SecondChatWindow.GetAvailableGuilds()
    if #guilds > 0 then
        SecondChatWindow.db.selectedGuild = guilds[1].guildNum
    else
        SecondChatWindow.db.selectedGuild = 1
    end
end

function SecondChatWindow.ApplyChatFontToWindow()
    local fontString = "ZoFontChat"

    local primaryContainer = CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer
    local currentBuffer = primaryContainer and primaryContainer.currentBuffer
    if currentBuffer and currentBuffer.GetFont then
        local liveChatFont = currentBuffer:GetFont()
        if liveChatFont and liveChatFont ~= "" then
            fontString = liveChatFont
        end
    end

    if SecondChatWindow.titleLabel then
        SecondChatWindow.titleLabel:SetFont(fontString)
    end

    if SecondChatWindow.buffer then
        SecondChatWindow.buffer:SetFont(fontString)
    end
end

function SecondChatWindow.IsGamepadPreferredMode()
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode() or false
end

function SecondChatWindow.UpdateAllowedChannels()
    allowedChannels = {}
    SecondChatWindow.EnsureSelectedGuildValid()
    local selectedChannel = GUILD_CHANNELS[SecondChatWindow.db.selectedGuild]
    if selectedChannel then
        allowedChannels[selectedChannel] = true
    end
end

function SecondChatWindow.SetSelectedGuild(guildNumber)
    if guildNumber >= 1 and guildNumber <= 5 and SecondChatWindow.GetGuildNameByNumber(guildNumber) then
        SecondChatWindow.db.selectedGuild = guildNumber
        SecondChatWindow.UpdateAllowedChannels()
        SecondChatWindow.UpdateWindowTitle()
        SecondChatWindow.ClearBuffer()
        local guildName = SecondChatWindow.GetGuildNameByNumber(guildNumber) or ("Guild " .. guildNumber)
        d("SecondChatWindow now displaying " .. guildName .. " chat.")
    end
end

function SecondChatWindow.ClearBuffer()
    if SecondChatWindow.buffer and SecondChatWindow.buffer.Clear then
        SecondChatWindow.buffer:Clear()
    end
end

function SecondChatWindow.RefreshGuildState()
    SecondChatWindow.EnsureSelectedGuildValid()
    SecondChatWindow.UpdateAllowedChannels()
    SecondChatWindow.UpdateWindowTitle()
end

function SecondChatWindow.PrintCommandHelp()
    d("SecondChatWindow commands:")
    d("  /secondchat - Show/hide the window")
    d("  /lockchat - Toggle lock/unlock")
    d("  /resetchat - Reset position and unlock")
    d("  /setguild [1-5] - Show a specific guild channel")
    d("  /secondchatclear - Clear this window's history")
    d("  /secondchathelp - Show this help text")
end

function SecondChatWindow.OnAddOnLoaded(_, addonName)
    if addonName ~= SecondChatWindow.name then return end
    EVENT_MANAGER:UnregisterForEvent(SecondChatWindow.name, EVENT_ADD_ON_LOADED)

    -- Initialize Saved Variables
    SecondChatWindow.db = ZO_SavedVars:NewAccountWide("SecondChatVars", 1, nil, SecondChatWindow.defaults)
    
    -- Update allowed channels based on saved guild selection
    SecondChatWindow.UpdateAllowedChannels()

    SecondChatWindow.InitializeUI()

    local activationEventName = SecondChatWindow.name .. "_PlayerActivated"
    EVENT_MANAGER:RegisterForEvent(activationEventName, EVENT_PLAYER_ACTIVATED, function()
        SecondChatWindow.ApplyChatFontToWindow()
        SecondChatWindow.UpdateWindowTitle()
        EVENT_MANAGER:UnregisterForEvent(activationEventName, EVENT_PLAYER_ACTIVATED)
    end)

    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        local inputModeEventName = SecondChatWindow.name .. "_InputModeChanged"
        EVENT_MANAGER:RegisterForEvent(
            inputModeEventName,
            EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
            function()
                SecondChatWindow.UpdateWindowTitle()
            end
        )
    end

    local guildEvents = {
        EVENT_GUILD_SELF_JOINED,
        EVENT_GUILD_SELF_LEFT,
    }
    for _, eventCode in ipairs(guildEvents) do
        if eventCode then
            EVENT_MANAGER:RegisterForEvent(
                SecondChatWindow.name .. "_GuildState_" .. tostring(eventCode),
                eventCode,
                function()
                    SecondChatWindow.RefreshGuildState()
                end
            )
        end
    end
end

function SecondChatWindow.UpdateWindowTitle()
    if SecondChatWindow.titleLabel then
        local selectedChannel = GUILD_CHANNELS[SecondChatWindow.db.selectedGuild]
        local fallbackCategory = ResolveFirstDefined(
            "CHAT_CATEGORY_GUILD_1",
            "CHAT_CATEGORY_GUILD1",
            "CHAT_CATEGORY_SAY"
        )
        local category = (selectedChannel and GUILD_CHAT_CATEGORIES[selectedChannel]) or fallbackCategory
        local r, g, b = 1, 1, 1
        if category and GetChatCategoryColor then
            r, g, b = GetChatCategoryColor(category)
        end

        local guildName = SecondChatWindow.GetGuildNameByNumber(SecondChatWindow.db.selectedGuild)
        local titleText
        if guildName then
            titleText = guildName .. " Chat"
        else
            titleText = "Guild " .. SecondChatWindow.db.selectedGuild .. " Chat"
        end

        if not SecondChatWindow.IsGamepadPreferredMode() then
            titleText = titleText .. " · Right-click to change"
        end

        SecondChatWindow.titleLabel:SetText(titleText)
        SecondChatWindow.titleLabel:SetColor(r, g, b, 1)

        if SecondChatWindow.headerBackdrop then
            local cr = Clamp01(r * 0.2)
            local cg = Clamp01(g * 0.2)
            local cb = Clamp01(b * 0.2)
            local er = Clamp01(r * 0.55)
            local eg = Clamp01(g * 0.55)
            local eb = Clamp01(b * 0.55)
            SecondChatWindow.headerBackdrop:SetCenterColor(cr, cg, cb, 0.95)
            SecondChatWindow.headerBackdrop:SetEdgeColor(er, eg, eb, 0.95)
        end

        if SecondChatWindow.divider then
            local dr = Clamp01(r * 0.8)
            local dg = Clamp01(g * 0.8)
            local db = Clamp01(b * 0.8)
            SecondChatWindow.divider:SetCenterColor(dr, dg, db, 0.85)
            SecondChatWindow.divider:SetEdgeColor(dr, dg, db, 0.95)
        end
    end
end

function SecondChatWindow.InitializeUI()
    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("SecondChat_TLW")
    
    tlw:SetDimensions(SecondChatWindow.db.width, SecondChatWindow.db.height)
    tlw:ClearAnchors()
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SecondChatWindow.db.left, SecondChatWindow.db.top)
    
    tlw:SetDimensionConstraints(200, 100, 800, 600)
    tlw:SetMouseEnabled(true)
    tlw:SetClampedToScreen(true)
    tlw:SetResizeHandleSize(16)
    tlw:SetHidden(false)
    
    -- Apply the saved lock state
    tlw:SetMovable(not SecondChatWindow.db.isLocked)

    -- Save position/size handlers
    tlw:SetHandler("OnMoveStop", function(self)
        SecondChatWindow.db.left = self:GetLeft()
        SecondChatWindow.db.top = self:GetTop()
    end)
    tlw:SetHandler("OnResizeStop", function(self)
        SecondChatWindow.db.width = self:GetWidth()
        SecondChatWindow.db.height = self:GetHeight()
    end)

    -- Background
    local bg = WINDOW_MANAGER:CreateControl("SecondChat_BG", tlw, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.03, 0.04, 0.06, 0.78)
    bg:SetEdgeColor(0.38, 0.43, 0.52, 0.85)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/listItem_backdrop.dds", 16, 1, 1)
    if bg.SetInsets then
        bg:SetInsets(1, 1, -1, -1)
    end
    bg:SetMouseEnabled(true)

    local headerBackdrop = WINDOW_MANAGER:CreateControl("SecondChat_Header", tlw, CT_BACKDROP)
    headerBackdrop:SetAnchor(TOPLEFT, tlw, TOPLEFT, 3, 3)
    headerBackdrop:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -3, 3)
    headerBackdrop:SetHeight(24)
    headerBackdrop:SetCenterColor(0.08, 0.1, 0.14, 0.95)
    headerBackdrop:SetEdgeColor(0.3, 0.34, 0.4, 0.9)
    headerBackdrop:SetEdgeTexture("", 8, 1, 1)

    local divider = WINDOW_MANAGER:CreateControl("SecondChat_Divider", tlw, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, headerBackdrop, BOTTOMLEFT, 0, 1)
    divider:SetAnchor(TOPRIGHT, headerBackdrop, BOTTOMRIGHT, 0, 1)
    divider:SetHeight(1)
    divider:SetCenterColor(0.48, 0.52, 0.6, 0.85)
    divider:SetEdgeColor(0.48, 0.52, 0.6, 0.95)
    divider:SetEdgeTexture("", 4, 1, 1)

    local shadow = WINDOW_MANAGER:CreateControl("SecondChat_Shadow", tlw, CT_BACKDROP)
    shadow:SetAnchorFill(tlw)
    shadow:SetCenterColor(0, 0, 0, 0)
    shadow:SetEdgeColor(0, 0, 0, 0.7)
    -- Backdrop edge texture dimensions must be powers of two and > 0.
    shadow:SetEdgeTexture("", 16, 16, 8)
    if shadow.SetDrawLayer then
        shadow:SetDrawLayer(DL_BACKGROUND)
    end
    if shadow.SetDrawTier then
        shadow:SetDrawTier(DT_LOW)
    end
    
    -- Right-click handler for guild selection
    local function OnRightClick()
        SecondChatWindow.ShowGuildContextMenu()
    end
    
    bg:SetHandler("OnMouseDown", function(_, button)
        if button == 1 and not SecondChatWindow.db.isLocked then
            tlw:StartMoving()
        end
    end)
    bg:SetHandler("OnMouseUp", function(_, button, upInside)
        if button == 1 then
            tlw:StopMovingOrResizing()
        elseif button == 2 and upInside then  -- Right mouse button
            OnRightClick()
        end
    end)

    -- Title Label
    local titleLabel = WINDOW_MANAGER:CreateControl("SecondChat_Title", tlw, CT_LABEL)
    titleLabel:SetAnchor(LEFT, headerBackdrop, LEFT, 8, 0)
    titleLabel:SetFont("ZoFontChat")
    titleLabel:SetText("")
    titleLabel:SetMouseEnabled(true)

    local hintLabel = WINDOW_MANAGER:CreateControl("SecondChat_Hint", tlw, CT_LABEL)
    hintLabel:SetAnchor(RIGHT, headerBackdrop, RIGHT, -8, 0)
    hintLabel:SetFont("ZoFontGameSmall")
    hintLabel:SetColor(0.78, 0.82, 0.9, 0.95)
    hintLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hintLabel:SetText("RMB: Select Guild")
    hintLabel:SetMouseEnabled(false)
    
    -- Right-click handler on title label
    titleLabel:SetHandler("OnMouseDown", function(_, button)
        if button == 1 and not SecondChatWindow.db.isLocked then
            tlw:StartMoving()
        end
    end)
    titleLabel:SetHandler("OnMouseUp", function(_, button, upInside)
        if button == 1 then
            tlw:StopMovingOrResizing()
        elseif button == 2 and upInside then  -- Right mouse button
            OnRightClick()
        end
    end)
    
    SecondChatWindow.titleLabel = titleLabel
    SecondChatWindow.headerBackdrop = headerBackdrop
    SecondChatWindow.divider = divider
    SecondChatWindow.hintLabel = hintLabel

    -- Text Buffer (Chat area)
    local buffer = WINDOW_MANAGER:CreateControl("SecondChat_Buffer", tlw, CT_TEXTBUFFER)
    buffer:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 32)
    buffer:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -12, -12)
    buffer:SetFont("ZoFontChat")
    buffer:SetMaxHistoryLines(200)
    buffer:SetMouseEnabled(true)

    -- Corrected ESO Mouse Wheel Scrolling
    buffer:SetHandler("OnMouseWheel", function(self, delta)
        local currentPosition = self:GetScrollPosition()
        local newPosition = currentPosition + (delta * 3)
        
        -- Prevents scrolling past the newest message at the bottom
        if newPosition < 0 then newPosition = 0 end 
        self:SetScrollPosition(newPosition)
    end)
    
    SecondChatWindow.buffer = buffer
    SecondChatWindow.UpdateWindowTitle()
    SecondChatWindow.ApplyChatFontToWindow()

    -- Add to HUD scenes so it hides during loading screens/menus
    local fragment = ZO_HUDFadeSceneFragment:New(tlw)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    -- SLASH COMMANDS 
    SLASH_COMMANDS["/secondchat"] = function()
        tlw:SetHidden(not tlw:IsHidden())
    end
    
    SLASH_COMMANDS["/lockchat"] = function()
        SecondChatWindow.db.isLocked = not SecondChatWindow.db.isLocked
        tlw:SetMovable(not SecondChatWindow.db.isLocked)
        
        local statusText = SecondChatWindow.db.isLocked and "LOCKED" or "UNLOCKED"
        d("SecondChatWindow is now " .. statusText .. ".")
    end

    SLASH_COMMANDS["/resetchat"] = function()
        tlw:ClearAnchors()
        tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        SecondChatWindow.db.left = tlw:GetLeft()
        SecondChatWindow.db.top = tlw:GetTop()
        SecondChatWindow.db.isLocked = false
        tlw:SetMovable(true)
        tlw:SetHidden(false)
        d("SecondChatWindow reset to center and unlocked.")
    end
    
    SLASH_COMMANDS["/setguild"] = function(guildNumber)
        local guild = tonumber(guildNumber)
        if guild and guild >= 1 and guild <= 5 then
            SecondChatWindow.SetSelectedGuild(guild)
        else
            d("Usage: /setguild [1-5]")
            local guilds = SecondChatWindow.GetAvailableGuilds()
            for _, guildData in ipairs(guilds) do
                d(string.format("  %d = %s", guildData.guildNum, guildData.guildName))
            end
        end
    end

    SLASH_COMMANDS["/secondchatclear"] = function()
        SecondChatWindow.ClearBuffer()
        d("SecondChatWindow history cleared.")
    end

    SLASH_COMMANDS["/secondchathelp"] = function()
        SecondChatWindow.PrintCommandHelp()
    end

    -- Register Chat Event
    EVENT_MANAGER:RegisterForEvent(SecondChatWindow.name, EVENT_CHAT_MESSAGE_CHANNEL, SecondChatWindow.OnChatMessage)
end

function SecondChatWindow.ShowGuildContextMenu()
    -- Create context menu
    ClearMenu()

    local guilds = SecondChatWindow.GetAvailableGuilds()
    if #guilds == 0 then
        AddMenuItem("No guilds found", function() end)
    else
        for _, guildData in ipairs(guilds) do
            local guildNum = guildData.guildNum
            local guildName = guildData.guildName
            local isSelected = (SecondChatWindow.db.selectedGuild == guildNum)
            AddMenuItem(
                guildName .. (isSelected and " ✓" or ""),
                function()
                    SecondChatWindow.SetSelectedGuild(guildNum)
                end
            )
        end
    end

    ShowMenu()
end

function SecondChatWindow.OnChatMessage(_, channelType, fromName, text, _, fromDisplayName)
    if not allowedChannels[channelType] then return end
    if not SecondChatWindow.buffer or not SecondChatWindow.buffer.AddMessage then return end

    local displayName = fromDisplayName or fromName or "Unknown"
    local cleanName = ZO_FormatUserFacingDisplayName(displayName)
    local safeText = text or ""
    local formattedText = string.format("[%s]: %s", cleanName, safeText)
    
    local fallbackCategory = ResolveFirstDefined("CHAT_CATEGORY_GUILD_1", "CHAT_CATEGORY_GUILD1", "CHAT_CATEGORY_SAY")
    local category = GUILD_CHAT_CATEGORIES[channelType] or fallbackCategory
    local r, g, b = 1, 1, 1
    if category and GetChatCategoryColor then
        r, g, b = GetChatCategoryColor(category)
    end
    SecondChatWindow.buffer:AddMessage(formattedText, r, g, b)
end

EVENT_MANAGER:RegisterForEvent(SecondChatWindow.name, EVENT_ADD_ON_LOADED, SecondChatWindow.OnAddOnLoaded)