-- ESO Adventurer Suite
-- v0.29.496 - opaque chat with native slash-command rendering preserved.
-- Uses a background child inside ESO's chat window instead of a competing
-- top-level blocker. Chat stays above HUD overlays while ESO menus stay native.

local EPC = ESOProgressionCoach
if not EPC then return end

local CHAT_ROOT_NAME = "ZO_ChatWindow"
local CHAT_EDIT_NAME = "ZO_ChatWindowTextEntryEditBox"
local BACKDROP_NAME = "EAS_ChatOpaqueBackdrop029496"
local CHAT_LEVEL = 139 -- ESO native keyboard dropdown menus use HIGH tier level 140.

local state = {
    raised = false,
    originalTier = nil,
    originalLayer = nil,
    originalLevel = nil,
    backdrop = nil,
}

local function GetControl(name)
    return rawget(_G, name)
end

local function CaptureDrawState(control)
    if not control then return end
    if state.originalTier == nil and control.GetDrawTier then
        local ok, value = pcall(control.GetDrawTier, control)
        if ok then state.originalTier = value end
    end
    if state.originalLayer == nil and control.GetDrawLayer then
        local ok, value = pcall(control.GetDrawLayer, control)
        if ok then state.originalLayer = value end
    end
    if state.originalLevel == nil and control.GetDrawLevel then
        local ok, value = pcall(control.GetDrawLevel, control)
        if ok then state.originalLevel = value end
    end
end

local function EnsureOpaqueBackdrop029496(chat)
    if state.backdrop then return state.backdrop end
    if not chat or not WINDOW_MANAGER then return nil end

    -- Make the opaque surface a CHILD of the native chat window. This keeps it
    -- inside chat's draw hierarchy, so it can never cover ESO's separate
    -- HIGH-tier ZO_Menus slash-command dropdown.
    local backdrop = WINDOW_MANAGER:CreateControl(BACKDROP_NAME, chat, CT_BACKDROP)
    backdrop:SetMouseEnabled(false)
    backdrop:ClearAnchors()
    backdrop:SetAnchor(TOPLEFT, chat, TOPLEFT, -8, -6)
    backdrop:SetAnchor(BOTTOMRIGHT, chat, BOTTOMRIGHT, 4, 4)

    if backdrop.SetDrawLayer and rawget(_G, "DL_BACKGROUND") then
        pcall(backdrop.SetDrawLayer, backdrop, DL_BACKGROUND)
    end
    if backdrop.SetDrawLevel then
        pcall(backdrop.SetDrawLevel, backdrop, 1)
    end

    backdrop:SetCenterColor(0, 0, 0, 1)
    backdrop:SetEdgeColor(0.018, 0.018, 0.024, 1)
    if backdrop.SetEdgeTexture then
        pcall(backdrop.SetEdgeTexture, backdrop, "EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)
    end
    backdrop:SetHidden(true)

    state.backdrop = backdrop
    return backdrop
end

local function RaiseChat029496()
    local chat = GetControl(CHAT_ROOT_NAME)
    if not chat then return end

    CaptureDrawState(chat)

    -- Raise only the native chat top-level. Do not touch ZO_Menus, ZO_Menu,
    -- autocomplete objects, or any chat text handlers.
    if chat.SetDrawTier and rawget(_G, "DT_HIGH") then
        pcall(chat.SetDrawTier, chat, DT_HIGH)
    end
    if chat.SetDrawLevel then
        pcall(chat.SetDrawLevel, chat, CHAT_LEVEL)
    end

    local backdrop = EnsureOpaqueBackdrop029496(chat)
    if backdrop then
        backdrop:ClearAnchors()
        backdrop:SetAnchor(TOPLEFT, chat, TOPLEFT, -8, -6)
        backdrop:SetAnchor(BOTTOMRIGHT, chat, BOTTOMRIGHT, 4, 4)
        backdrop:SetHidden(false)
    end

    state.raised = true
end

local function RestoreChat029496()
    if state.backdrop then
        state.backdrop:SetHidden(true)
    end

    local chat = GetControl(CHAT_ROOT_NAME)
    if not state.raised or not chat then
        state.raised = false
        return
    end

    if state.originalTier ~= nil and chat.SetDrawTier then
        pcall(chat.SetDrawTier, chat, state.originalTier)
    end
    if state.originalLayer ~= nil and chat.SetDrawLayer then
        pcall(chat.SetDrawLayer, chat, state.originalLayer)
    end
    if state.originalLevel ~= nil and chat.SetDrawLevel then
        pcall(chat.SetDrawLevel, chat, state.originalLevel)
    end

    state.raised = false
end

local function HookChatEditBox029496()
    local edit = GetControl(CHAT_EDIT_NAME)
    if not edit or edit._easChatOpaque029496 then return false end
    edit._easChatOpaque029496 = true

    -- Additive hooks only. ESO keeps its native OnTextChanged, autocomplete,
    -- slash-command, focus, tab, arrow, enter and escape handlers untouched.
    if type(ZO_PreHookHandler) == "function" then
        ZO_PreHookHandler(edit, "OnFocusGained", function()
            RaiseChat029496()
            return false
        end)
        ZO_PreHookHandler(edit, "OnFocusLost", function()
            RestoreChat029496()
            return false
        end)
    else
        local oldFocusGained = edit.GetHandler and edit:GetHandler("OnFocusGained") or nil
        local oldFocusLost = edit.GetHandler and edit:GetHandler("OnFocusLost") or nil
        if edit.SetHandler then
            edit:SetHandler("OnFocusGained", function(control, ...)
                if oldFocusGained then oldFocusGained(control, ...) end
                RaiseChat029496()
            end)
            edit:SetHandler("OnFocusLost", function(control, ...)
                if oldFocusLost then oldFocusLost(control, ...) end
                RestoreChat029496()
            end)
        end
    end

    if edit.HasFocus then
        local ok, focused = pcall(edit.HasFocus, edit)
        if ok and focused then RaiseChat029496() end
    end

    return true
end

local function Install029496()
    if HookChatEditBox029496() then return end
    if type(zo_callLater) == "function" then
        zo_callLater(HookChatEditBox029496, 250)
        zo_callLater(HookChatEditBox029496, 1000)
    end
end

Install029496()
