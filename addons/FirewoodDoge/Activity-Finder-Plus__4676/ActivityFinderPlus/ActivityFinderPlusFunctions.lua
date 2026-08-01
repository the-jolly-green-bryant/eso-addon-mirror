local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS

function ACTIVITY_FINDER_PLUS.leaveGroup()
    if IsPlayerInGroup(ACTIVITY_FINDER_PLUS.playerName) then
        GroupLeave()
        d("You have left the group.")
        zo_callLater(function() CHAT_SYSTEM:Minimize() end, 3000)
    end
end

function ACTIVITY_FINDER_PLUS.print(message, ...)
    df("|cb7ff00[%s]|r |cffffff%s|r", ACTIVITY_FINDER_PLUS.displayName, message:format(...))
end

function ACTIVITY_FINDER_PLUS.printCenter(message)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    messageParams:SetText(message)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

local function NormalizeColor(color)
    if type(color) == "table" and #color == 4 then
        return color
    end
    return { 1, 1, 1, 1 }
end

local function NormalizeAlignment(align, defaultHorizontal, defaultVertical)
    if type(align) == "table" and #align == 2 then
        return align
    end
    return { defaultHorizontal or 0, defaultVertical or 0 }
end

local function SetControlAnchor(control, parent, anchor)
    if type(anchor) ~= "table" or (#anchor ~= 4 and #anchor ~= 5) then
        return false
    end

    control:ClearAnchors()
    control:SetAnchor(anchor[1], anchor[5] or parent, anchor[2], anchor[3], anchor[4])
    return true
end

function ACTIVITY_FINDER_PLUS.Label(name, parent, dims, anchor, font, color, align, text, hidden)
    parent = parent or GuiRoot
    if type(anchor) ~= "table" or (#anchor ~= 4 and #anchor ~= 5) then return end

    font = font or "ZoFontGame"
    color = NormalizeColor(color)
    align = NormalizeAlignment(align, 0, 0)
    hidden = hidden or false

    local isNew = _G[name] == nil
    local label = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    if dims then
        label:SetDimensions(dims[1], dims[2])
    end
    SetControlAnchor(label, parent, anchor)
    label:SetFont(font)
    label:SetColor(unpack(color))
    label:SetHorizontalAlignment(align[1])
    label:SetVerticalAlignment(align[2])
    label:SetText(text)
    label:SetHidden(hidden)

    if isNew then
        local fragment = ZO_FadeSceneFragment:New(label)
        KEYBOARD_GROUP_MENU_SCENE:AddFragment(fragment)
        GAMEPAD_ACTIVITY_FINDER_ROOT_SCENE:AddFragment(fragment)
    end
    return label
end

function ACTIVITY_FINDER_PLUS.groupFinderVisible()
    if ACTIVITY_FINDER_PLUS.BUICompat then
        BUI_AutoQueue:SetHidden(ACTIVITY_FINDER_PLUS.BUICompat)
    end
end

local function IsAddonLoaded(addonName)
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, enabled, loadable = select(1, manager:GetAddOnInfo(i))
        name = name:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|[rR]", "")
        if name == addonName and enabled and loadable == 2 then
            return true
        end
    end
    return false
end

ACTIVITY_FINDER_PLUS.perfectPixelCompat = IsAddonLoaded("PerfectPixel")
ACTIVITY_FINDER_PLUS.BUICompat = IsAddonLoaded("BanditsUserInterface")
