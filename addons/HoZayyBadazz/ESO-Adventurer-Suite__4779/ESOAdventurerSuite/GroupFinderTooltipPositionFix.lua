-- ESO Adventurer Suite
-- Group Finder tooltip placement polish (0.29.693).
-- Keeps listing details readable without covering the left-side Group Finder tabs.

local EPC = ESOProgressionCoach
local GF = EPC and EPC.GroupFinderPlus
if not GF or not WINDOW_MANAGER or not GuiRoot then return end
if GF._tooltipPositionFix029693 then return end
GF._tooltipPositionFix029693 = true

local WM = WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_GroupFinderTooltip029693"

local function callMethod(object, methodName, fallback, ...)
    if not object then return fallback end
    local method = object[methodName]
    if type(method) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(method, object, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d
end

local function clean(text)
    return tostring(text or ""):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
end

local function colorMarkupOnly(text)
    text = tostring(text or "")
    if type(EscapeMarkup) == "function" and rawget(_G, "ALLOW_MARKUP_TYPE_COLOR_ONLY") then
        local ok, escaped = pcall(EscapeMarkup, text, ALLOW_MARKUP_TYPE_COLOR_ONLY)
        if ok and escaped then return escaped end
    end
    return text
end

local function yesNo(value)
    if type(GetString) == "function" then
        local id = value and rawget(_G, "SI_DIALOG_YES") or rawget(_G, "SI_DIALOG_NO")
        if id then
            local ok, text = pcall(GetString, id)
            if ok and text then return text end
        end
    end
    return value and "Yes" or "No"
end

function GF:EnsureCompactListingTooltip029693()
    if self.compactListingTooltip029693 then return self.compactListingTooltip029693 end

    local root = WM:CreateTopLevelWindow("EAS_GroupFinderCompactTooltip029693")
    root:SetDimensions(300, 410)
    root:SetMouseEnabled(false)
    root:SetClampedToScreen(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WM:CreateControl(nil, root, CT_BACKDROP)
    bg:SetAnchorFill(root)
    bg:SetCenterColor(0.015, 0.018, 0.025, 0.96)
    bg:SetEdgeColor(0.72, 0.64, 0.42, 0.95)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local title = WM:CreateControl(nil, root, CT_LABEL)
    title:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 11)
    title:SetDimensions(276, 52)
    title:SetFont("ZoFontWinH3")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    title:SetColor(1, 0.85, 0.35, 1)

    local divider = WM:CreateControl(nil, root, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 4)
    divider:SetDimensions(276, 1)
    divider:SetColor(0.62, 0.56, 0.39, 0.9)

    local body = WM:CreateControl(nil, root, CT_LABEL)
    body:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 8)
    body:SetDimensions(276, 325)
    body:SetFont("ZoFontGame")
    body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)
    body:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    body:SetColor(0.92, 0.92, 0.9, 1)

    root.easTitle029693 = title
    root.easBody029693 = body
    self.compactListingTooltip029693 = root
    return root
end

function GF:BuildCompactListingText029693(data)
    if not data then return "" end

    local ownerDisplay = callMethod(data, "GetOwnerDisplayName", "")
    local ownerCharacter = callMethod(data, "GetOwnerCharacterName", "")
    local owner = tostring(ownerDisplay or "")
    if type(ZO_GetPrimaryPlayerNameWithSecondary) == "function" then
        local ok, formatted = pcall(ZO_GetPrimaryPlayerNameWithSecondary, ownerDisplay, ownerCharacter)
        if ok and formatted then owner = formatted end
    elseif ownerCharacter and ownerCharacter ~= "" then
        owner = tostring(ownerCharacter) .. " (" .. tostring(ownerDisplay) .. ")"
    end

    local category = tonumber(callMethod(data, "GetCategory", 0)) or 0
    local categoryText = tostring(category)
    if type(GetString) == "function" then
        local ok, text = pcall(GetString, "SI_GROUPFINDERCATEGORY", category)
        if ok and text and text ~= "" then categoryText = text end
    end

    local primary = tostring(callMethod(data, "GetPrimaryOptionText", "") or "")
    local secondary = tostring(callMethod(data, "GetSecondaryOptionText", "") or "")
    local optionParts = {}
    if primary ~= "" then optionParts[#optionParts + 1] = primary end
    if secondary ~= "" and secondary ~= primary then optionParts[#optionParts + 1] = secondary end
    if #optionParts > 0 then categoryText = categoryText .. " — " .. table.concat(optionParts, ", ") end

    local playerCount, roleList = "", ""
    if type(ZO_GroupFinder_GroupListing_GetPlayerCountAndRoleStrings) == "function" then
        local ok, a, b = pcall(ZO_GroupFinder_GroupListing_GetPlayerCountAndRoleStrings, data, 24)
        if ok then playerCount, roleList = tostring(a or ""), tostring(b or "") end
    end

    local desc = colorMarkupOnly(callMethod(data, "GetDescription", "") or "")
    local requiresChampion = callMethod(data, "DoesGroupRequireChampion", false) == true
    local championPoints = callMethod(data, "GetChampionPoints", 0)
    local championText = requiresChampion and tostring(championPoints or 0) or "N/A"
    local requiresInvite = callMethod(data, "DoesGroupRequireInviteCode", false) == true
    local autoAccept = callMethod(data, "DoesGroupAutoAcceptRequests", false) == true
    local requiresVoice = callMethod(data, "DoesGroupRequireVOIP", false) == true

    local lines = {
        "|cC8B98CListing Owner|r  " .. tostring(owner or ""),
        "|cC8B98CCategory|r  " .. categoryText,
    }

    if playerCount ~= "" or roleList ~= "" then
        lines[#lines + 1] = "|cC8B98CPlayers|r  " .. playerCount .. (roleList ~= "" and ("   " .. roleList) or "")
    end

    if clean(desc) ~= "" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = desc
        lines[#lines + 1] = ""
    end

    lines[#lines + 1] = "|cC8B98CChampion Points Required|r  " .. championText
    lines[#lines + 1] = "|cC8B98CRequires Invite Code|r  " .. yesNo(requiresInvite)

    if category == rawget(_G, "GROUP_FINDER_CATEGORY_DUNGEON")
        or category == rawget(_G, "GROUP_FINDER_CATEGORY_ARENA")
        or category == rawget(_G, "GROUP_FINDER_CATEGORY_TRIAL") then
        local playstyle = tonumber(callMethod(data, "GetPlaystyle", 0)) or 0
        local playstyleText = tostring(playstyle)
        if type(GetString) == "function" then
            local ok, text = pcall(GetString, "SI_GROUPFINDERPLAYSTYLE", playstyle)
            if ok and text and text ~= "" then playstyleText = text end
        end
        lines[#lines + 1] = "|cC8B98CPlaystyle|r  " .. playstyleText
    end

    lines[#lines + 1] = "|cC8B98CAuto Accepts Applications|r  " .. yesNo(autoAccept)
    lines[#lines + 1] = "|cC8B98CRequires Voice Chat|r  " .. yesNo(requiresVoice)

    if type(ZO_GroupFinder_GroupListing_GetDesiredRolesList) == "function" then
        local ok, roles = pcall(ZO_GroupFinder_GroupListing_GetDesiredRolesList, data, 24)
        if ok and roles and roles ~= "" then
            lines[#lines + 1] = "|cC8B98CLooking For|r  " .. tostring(roles)
        end
    end

    local warning = callMethod(data, "GetWarningText", nil)
    if warning and warning ~= "" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "|cFF6666" .. clean(warning) .. "|r"
    end

    return table.concat(lines, "\n")
end

function GF:PositionCompactListingTooltip029693(anchorControl)
    local tip = self:EnsureCompactListingTooltip029693()
    if not tip then return end

    local screenW = tonumber(GuiRoot:GetWidth()) or 1920
    local screenH = tonumber(GuiRoot:GetHeight()) or 1080
    local anchorLeft = anchorControl and tonumber(anchorControl:GetLeft()) or (screenW * 0.68)
    local anchorTop = anchorControl and tonumber(anchorControl:GetTop()) or (screenH * 0.25)

    -- Native Group Finder keeps roughly a 280px navigation strip to the left of
    -- the listing content. Place the compact tooltip just left of that strip,
    -- but clamp its left edge so it does not slide over the character preview.
    local width, height = 300, 410
    local rightEdge = anchorLeft - 265
    local left = rightEdge - width
    local characterSafeLeft = screenW * 0.31
    if left < characterSafeLeft then left = characterSafeLeft end
    if left + width > screenW - 20 then left = screenW - width - 20 end

    local top = math.max(95, anchorTop - 105)
    if top + height > screenH - 55 then top = math.max(40, screenH - height - 55) end

    tip:ClearAnchors()
    tip:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function GF:ShowCompactListingTooltip029693(anchorControl, data)
    if not data then return end
    if GroupFinderGroupListingTooltip and type(ClearTooltip) == "function" then
        pcall(ClearTooltip, GroupFinderGroupListingTooltip)
    end

    local tip = self:EnsureCompactListingTooltip029693()
    if not tip then return end
    tip.easTitle029693:SetText(colorMarkupOnly(callMethod(data, "GetTitle", "") or ""))
    tip.easBody029693:SetText(self:BuildCompactListingText029693(data))
    self:PositionCompactListingTooltip029693(anchorControl)
    tip:SetHidden(false)
end

function GF:HideCompactListingTooltip029693()
    if self.compactListingTooltip029693 then
        self.compactListingTooltip029693:SetHidden(true)
    end
end

function GF:PatchNativeListingTooltips029693()
    local keyboard = rawget(_G, "GROUP_FINDER_KEYBOARD")
    if not keyboard then return false end

    local applications = keyboard.applicationsManagementContent
    if applications and applications.myListingControl and applications.myListingData then
        local control = applications.myListingControl
        if not control.easCompactTooltip029693 then
            control.easCompactTooltip029693 = true
            control:SetHandler("OnMouseEnter", function(c)
                GF:ShowCompactListingTooltip029693(c, applications.myListingData)
            end)
            control:SetHandler("OnMouseExit", function()
                GF:HideCompactListingTooltip029693()
            end)
        end
    end

    local overview = keyboard.overviewAppliedToGroupListingControl
    if overview and keyboard.appliedToListingData and not overview.easCompactTooltip029693 then
        overview.easCompactTooltip029693 = true
        overview:SetHandler("OnMouseEnter", function(c)
            GF:ShowCompactListingTooltip029693(c, keyboard.appliedToListingData)
            if KEYBIND_STRIP and keyboard.appliedToListingKeybindStripDescriptor then
                KEYBIND_STRIP:AddKeybindButtonGroup(keyboard.appliedToListingKeybindStripDescriptor)
            end
        end)
        overview:SetHandler("OnMouseExit", function()
            GF:HideCompactListingTooltip029693()
            if KEYBIND_STRIP and keyboard.appliedToListingKeybindStripDescriptor then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(keyboard.appliedToListingKeybindStripDescriptor)
            end
        end)
    end

    return applications and applications.myListingControl ~= nil
end

-- Search-result rows use the same native 512px tooltip. Keep ESO's native row
-- hover/keybind behavior, then replace only the tooltip with the compact panel.
if rawget(_G, "ZO_GroupFinder_SearchResultsList_Keyboard")
    and type(ZO_GroupFinder_SearchResultsList_Keyboard.Row_OnMouseEnter) == "function"
    and not ZO_GroupFinder_SearchResultsList_Keyboard.easCompactTooltipPatched029693 then

    ZO_GroupFinder_SearchResultsList_Keyboard.easCompactTooltipPatched029693 = true
    local baseEnter = ZO_GroupFinder_SearchResultsList_Keyboard.Row_OnMouseEnter
    local baseExit = ZO_GroupFinder_SearchResultsList_Keyboard.Row_OnMouseExit

    function ZO_GroupFinder_SearchResultsList_Keyboard:Row_OnMouseEnter(control)
        baseEnter(self, control)
        if GroupFinderGroupListingTooltip and type(ClearTooltip) == "function" then
            pcall(ClearTooltip, GroupFinderGroupListingTooltip)
        end
        local data = type(ZO_ScrollList_GetData) == "function" and ZO_ScrollList_GetData(control) or nil
        if data then GF:ShowCompactListingTooltip029693(control, data) end
    end

    function ZO_GroupFinder_SearchResultsList_Keyboard:Row_OnMouseExit(control)
        GF:HideCompactListingTooltip029693()
        if type(baseExit) == "function" then return baseExit(self, control) end
    end
end

local function install(retries)
    if GF:PatchNativeListingTooltips029693() then return end
    if retries > 0 and type(zo_callLater) == "function" then
        zo_callLater(function() install(retries - 1) end, 500)
    end
end

install(8)

if EVENT_MANAGER and rawget(_G, "EVENT_PLAYER_ACTIVATED") then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
        GF:HideCompactListingTooltip029693()
        if type(zo_callLater) == "function" then
            zo_callLater(function() GF:PatchNativeListingTooltips029693() end, 100)
        else
            GF:PatchNativeListingTooltips029693()
        end
    end)
end

EPC.groupFinderTooltipPositionFix029693 = true
