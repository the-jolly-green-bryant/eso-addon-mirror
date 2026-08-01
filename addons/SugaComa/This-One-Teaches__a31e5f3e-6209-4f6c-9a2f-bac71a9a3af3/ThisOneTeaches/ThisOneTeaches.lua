--------------------------------------------------------------
-- ThisOneTeaches.lua - v1.0.5 (solo-only, understated)
--------------------------------------------------------------

ThisOneTeaches = {}
ThisOneTeaches.name     = "ThisOneTeaches"
ThisOneTeaches.version  = "1.0.5"
ThisOneTeaches.enabled  = true

--------------------------------------------------------
-- PS5 SavedVars Commit Helper
--------------------------------------------------------
local function ForceSave()
    if SetCVar then
        SetCVar("Language.2", GetCVar("Language.2"))
    end
end

--------------------------------------------------------
-- Language loader
--------------------------------------------------------
ThisOneTeachesLang = ThisOneTeachesLang or {}

local function TOT_LoadLanguage()
    local lang = string.lower(GetCVar("Language.2") or "en")
    if not ThisOneTeachesLang[lang] then lang = "en" end

    ThisOneTeaches.text = ThisOneTeachesLang[lang] or { victory = {}, defeat = {}, argonian = {} }
    ThisOneTeaches.victoryMessages = ThisOneTeaches.text.victory or {}
    ThisOneTeaches.defeatMessages = ThisOneTeaches.text.defeat or {}
    ThisOneTeaches.argonianMessages = ThisOneTeaches.text.argonian or {}
end

--------------------------------------------------------
-- Utilities
--------------------------------------------------------
local function CleanName(name)
    if not name or name == "" then return "Unknown" end
    if string.sub(name, 1, 1) == "@" then
        return string.sub(name, 2)
    end
    return name
end

local function IsPlayerName(displayName)
    return displayName == CleanName(GetUnitDisplayName("player"))
end

local function GetLine(list, killer, victim, location)
    if not list or #list == 0 then return nil end
    local line = list[zo_random(1, #list)]
    return line
        :gsub("%%k", "|c00FF00"..killer.."|r")
        :gsub("%%v", "|cFF0000"..victim.."|r")
        :gsub("%%l", "|cFFFFFF"..location.."|r")
end

local function GetArgonianLine()
    if not ThisOneTeaches.argonianMessages or #ThisOneTeaches.argonianMessages == 0 then
        return nil
    end
    -- Rare: ~1 in 12 kills/deaths
    if zo_random(1, 12) ~= 1 then return nil end
    return ThisOneTeaches.argonianMessages[zo_random(1, #ThisOneTeaches.argonianMessages)]
end


--------------------------------------------------------
-- Fancy Popup (embedded, no external libs)
--------------------------------------------------------
local TOT_POPUP = {
    control = nil,
    img = nil,
    bubble = nil,
    title = nil,
    body = nil,
    hideToken = 0,
}

local function TOT_EnsurePopup()
    if TOT_POPUP.control then return end
    if not WINDOW_MANAGER or not GuiRoot then return end

    local c = WINDOW_MANAGER:CreateTopLevelWindow("TOT_FancyPopup")
    c:SetHidden(true)
    c:SetClampedToScreen(true)
    c:SetMouseEnabled(false)
    c:SetMovable(false)
    if DL_OVERLAY then c:SetDrawLayer(DL_OVERLAY) end
    if DT_HIGH then c:SetDrawTier(DT_HIGH) end
    c:SetDrawLevel(5)
    c:SetDimensions(980, 260)

    -- Character image
    local img = WINDOW_MANAGER:CreateControl("TOT_FancyPopup_Image", c, CT_TEXTURE)
    img:SetDimensions(256, 256)
    img:SetAnchor(LEFT, c, LEFT, 0, 0)
    img:SetTexture("ThisOneTeaches/tot_victory.png")

    -- Speech bubble backdrop
    local bubble = WINDOW_MANAGER:CreateControl("TOT_FancyPopup_Bubble", c, CT_BACKDROP)
    bubble:SetAnchor(LEFT, img, RIGHT, 18, 0)
    bubble:SetAnchor(RIGHT, c, RIGHT, 0, 0)
    bubble:SetDimensions(700, 200)
    bubble:SetCenterColor(0.05, 0.05, 0.05, 0.82)
    bubble:SetEdgeColor(0.25, 0.25, 0.25, 0.95)
    bubble:SetEdgeTexture("", 2, 2, 2)

    local title = WINDOW_MANAGER:CreateControl("TOT_FancyPopup_Title", bubble, CT_LABEL)
    title:SetAnchor(TOPLEFT, bubble, TOPLEFT, 18, 14)
    title:SetAnchor(TOPRIGHT, bubble, TOPRIGHT, -18, 14)
    title:SetFont("ZoFontGamepadBold27")
    title:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    title:SetText("")

    local body = WINDOW_MANAGER:CreateControl("TOT_FancyPopup_Body", bubble, CT_LABEL)
    -- Controls can only have TWO anchors. Use TOPLEFT + BOTTOMRIGHT to fill the bubble area.
    body:ClearAnchors()
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
    body:SetAnchor(BOTTOMRIGHT, bubble, BOTTOMRIGHT, -18, -16)
    body:SetFont("ZoFontGamepad34")
    body:SetWrapMode(TEXT_WRAP_MODE_WORD)
    body:SetText("")

    TOT_POPUP.control = c
    TOT_POPUP.img = img
    TOT_POPUP.bubble = bubble
    TOT_POPUP.title = title
    TOT_POPUP.body = body
end

local function TOT_ShowPopup(kind, titleText, bodyText)
    TOT_EnsurePopup()
    if not TOT_POPUP.control then return end

    -- Pull position/duration from GroupKillFeed settings if present
    local xOff, yOff, dur = 0, 0, 6000
    if GroupKillFeed and type(GroupKillFeed.GetPopupSettings) == "function" then
        local s = GroupKillFeed.GetPopupSettings()
        xOff = tonumber(s.xOffset) or xOff
        yOff = tonumber(s.yOffset) or yOff
        dur  = tonumber(s.durationMs) or dur
    end

    local c = TOT_POPUP.control
    c:ClearAnchors()
    c:SetAnchor(CENTER, GuiRoot, CENTER, xOff, yOff)

    -- Pick image + layout based on kind
    -- Requested behavior:
    --   * Loss/Defeat: image on the LEFT (facing toward the text)
    --   * Win/Victory: image on the RIGHT (facing toward the text)
    -- We "face" by mirroring texture coords when the image is on the right.
    local function SetImageFacing(side)
        if side == "right" then
            -- Mirror horizontally so the character faces left toward the text.
            TOT_POPUP.img:SetTextureCoords(1, 0, 0, 1)
        else
            TOT_POPUP.img:SetTextureCoords(0, 1, 0, 1)
        end
    end

    local isVictory = (kind == "victory")
    if isVictory then
        TOT_POPUP.img:SetTexture("ThisOneTeaches/tot_victory.png")
        SetImageFacing("right")
        TOT_POPUP.img:ClearAnchors()
        TOT_POPUP.img:SetAnchor(RIGHT, c, RIGHT, 0, 0)

        TOT_POPUP.bubble:ClearAnchors()
        TOT_POPUP.bubble:SetAnchor(LEFT, c, LEFT, 0, 0)
        TOT_POPUP.bubble:SetAnchor(RIGHT, TOT_POPUP.img, LEFT, -18, 0)
    else
        TOT_POPUP.img:SetTexture("ThisOneTeaches/tot_defeat.png")
        SetImageFacing("left")
        TOT_POPUP.img:ClearAnchors()
        TOT_POPUP.img:SetAnchor(LEFT, c, LEFT, 0, 0)

        TOT_POPUP.bubble:ClearAnchors()
        TOT_POPUP.bubble:SetAnchor(LEFT, TOT_POPUP.img, RIGHT, 18, 0)
        TOT_POPUP.bubble:SetAnchor(RIGHT, c, RIGHT, 0, 0)
    end

    TOT_POPUP.title:SetText(tostring(titleText or ""))
    TOT_POPUP.body:SetText(tostring(bodyText or ""))

    c:SetAlpha(1)
    c:SetHidden(false)

    -- Hide after duration (token prevents older timers hiding newer popup)
    TOT_POPUP.hideToken = (TOT_POPUP.hideToken or 0) + 1
    local token = TOT_POPUP.hideToken
    zo_callLater(function()
        if TOT_POPUP.hideToken ~= token then return end
        if TOT_POPUP.control then
            TOT_POPUP.control:SetHidden(true)
        end
    end, dur)
end


-- Expose the embedded popup for other addons (e.g., GroupKillFeed)
function ThisOneTeaches:ShowFancyPopup(kind, titleText, bodyText)
    TOT_ShowPopup(kind, titleText, bodyText)
end

local function TOT_Print(msg)
    -- Route chat output through GroupKillFeed so all three kill-feed
    -- addons share the same [KF] tag for VCAP2 detection.
    if GroupKillFeed and type(GroupKillFeed.Print) == "function" then
        GroupKillFeed.Print(msg)
        return
    end

    local text = "[KF] " .. tostring(msg or "")
    if CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

local function TOT_ShowCenterScreen(titleText, bodyText)
    local textMsg = (titleText and titleText ~= "" and (titleText .. ": ") or "") .. (bodyText or "")
    -- On console, ZO_Alert is the most reliably visible "center" output.
    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, textMsg)
        return
    end
    -- Fallback attempts
    if CENTER_SCREEN_ANNOUNCE and type(CENTER_SCREEN_ANNOUNCE.AddMessage) == "function" then
        local ok = pcall(function() CENTER_SCREEN_ANNOUNCE:AddMessage(CSA_CATEGORY_LARGE_TEXT, nil, textMsg) end)
        if ok then return end
        ok = pcall(function() CENTER_SCREEN_ANNOUNCE:AddMessage(CSA_CATEGORY_LARGE_TEXT, textMsg) end)
        if ok then return end
    end
    TOT_Print(textMsg)
end

local function TOT_GetOutputMode()
    if GroupKillFeed and type(GroupKillFeed.GetToTOutputMode) == "function" then
        return GroupKillFeed.GetToTOutputMode()
    end
    if ThisOneTeaches.outputMode then
        return ThisOneTeaches.outputMode
    end
    return "fancy"
end

local function TOT_Output(kind, titleText, bodyText)
    local mode = TOT_GetOutputMode()
    local chatText = (titleText and titleText ~= "" and (titleText .. ": ") or "") .. (bodyText or "")

    if mode == "chat" then
        TOT_Print(chatText)
    elseif mode == "both" then
        TOT_Print(chatText)
        TOT_ShowPopup(kind, titleText, bodyText)
    else
        TOT_ShowPopup(kind, titleText, bodyText)
    end
end

--------------------------------------------------------
-- Saved Variables
--------------------------------------------------------
local SV_VERSION = 1
local SV = nil

local function SaveState()
    if SV then
        SV.enabled = ThisOneTeaches.enabled
    end
end

function ThisOneTeaches.SetEnabled(state)
    ThisOneTeaches.enabled = (state == true)
    SaveState()
    ForceSave()
end

local function InitializeSavedVars()
    local ok, sv = pcall(function()
        return ZO_SavedVars:NewAccountWide("ThisOneTeaches_SV", SV_VERSION, nil, {
            enabled = true,
        })
    end)

    if ok and type(sv) == "table" then
        SV = sv
        ThisOneTeaches.enabled = (SV.enabled ~= false)
    else
        SV = { enabled = true }
        ThisOneTeaches.enabled = true
        TOT_Print("ThisOneTeaches: SavedVariables failed, using defaults.")
    end
end

--------------------------------------------------------
-- GroupKillFeed extension API
--
-- Do NOT wrap GroupKillFeed.BuildMessage here. GroupKillFeed owns the
-- kill event and calls this function only when This One Teaches is enabled
-- in Solo mode. Returning true means the kill was handled and no normal
-- kill-feed line should be printed.
--------------------------------------------------------
function ThisOneTeaches.HandleKill(killerName, killerAlliance, victimName, victimAlliance, location)
    -- GroupKillFeed is the sole mode owner and only calls this function when
    -- This One Teaches is enabled. Do not add a second local enable gate here:
    -- the two addons initialize SavedVariables at different points during load,
    -- and a stale local flag can otherwise silently suppress valid kills.

    local killer = CleanName(killerName)
    local victim = CleanName(victimName)
    local playerKilled = IsPlayerName(killer)
    local playerDied = IsPlayerName(victim)

    if not playerKilled and not playerDied then
        return false
    end

    local argonianLine = GetArgonianLine()
    if argonianLine then
        if playerKilled then
            TOT_Output("victory", "", argonianLine)
        else
            TOT_Output("defeat", "", argonianLine)
        end
        return true
    end

    if playerKilled then
        local line = GetLine(ThisOneTeaches.victoryMessages, killer, victim, location)
        if line then
            TOT_Output("victory", "", line)
            return true
        end
    elseif playerDied then
        local line = GetLine(ThisOneTeaches.defeatMessages, killer, victim, location)
        if line then
            TOT_Output("defeat", "", line)
            return true
        end
    end

    return false
end

-- Slash commands removed; handled via settings menu

--------------------------------------------------------
-- Init
--------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= ThisOneTeaches.name then return end

    EVENT_MANAGER:UnregisterForEvent(ThisOneTeaches.name, EVENT_ADD_ON_LOADED)

    TOT_LoadLanguage()
    InitializeSavedVars()

    -- GroupKillFeed owns the actual mode switch. Mirror it here for legacy
    -- compatibility and settings-disable checks, but HandleKill itself trusts
    -- the core dispatcher rather than this local flag.
    if GroupKillFeed and GroupKillFeed.thisOneTeachesEnabled ~= nil then
        ThisOneTeaches.enabled = (GroupKillFeed.thisOneTeachesEnabled == true)
        SaveState()
    end

    TOT_Print("ThisOneTeaches v"..ThisOneTeaches.version.." loaded.")
end

EVENT_MANAGER:RegisterForEvent(ThisOneTeaches.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)