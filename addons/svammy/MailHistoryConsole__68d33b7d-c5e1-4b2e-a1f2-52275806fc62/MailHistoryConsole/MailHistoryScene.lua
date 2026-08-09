-- MailHistoryConsole scene — gamepad history browser.
--
-- Built on ZO_Gamepad_ParametricList_Screen: history entries in a parametric
-- list, full mail text in the right tooltip pane, browse-only
-- (PS5: Circle = Back, L2/R2 = page).
--
-- This file is new in the console port.  Original Mail History addon by @PacificOshie.

MailHistory = MailHistory or {}

local SCENE_NAME = "mailHistoryGamepad"

-- Row label fonts per the listTextSize setting.  ZoFontGamepad* fonts live in
-- UI space, so they already follow the game's UI scale; this setting adds
-- per-user control on top.  "large" is the ZO_GamepadMenuEntryTemplate default.
local ROW_FONTS = {
    small = "ZoFontGamepad22",
    medium = "ZoFontGamepad27",
    large = "ZoFontGamepad34",
}

function MailHistory.GetRowFont()
    return ROW_FONTS[MailHistory.settings and MailHistory.settings.listTextSize] or ROW_FONTS.medium
end

MailHistoryConsole_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function MailHistoryConsole_Gamepad:New(...)
    return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function MailHistoryConsole_Gamepad:Initialize(control)
    MAILHISTORY_GAMEPAD_SCENE = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    MAILHISTORY_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    MAILHISTORY_GAMEPAD_SCENE:AddFragment(ZO_FadeSceneFragment:New(control))
    MAILHISTORY_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    MAILHISTORY_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    MAILHISTORY_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

    local ACTIVATE_ON_SHOW = true
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, ACTIVATE_ON_SHOW, MAILHISTORY_GAMEPAD_SCENE)

    self.itemList = self:GetMainList()

    self.headerData = { titleText = GetString(SI_MAILHISTORY_TITLE) }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    -- MailHistoryConsole_ListTask
    self.asyncTask = LibAsync:Create("MailHistoryConsole_ListTask")
end

function MailHistoryConsole_Gamepad:SetupList(list)
    -- Same registration as the base class, plus our sized row font.
    local function MailEntrySetup(control, data, selected, reselectingDuringRebuild, enabled, active)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
        control.label:SetFont(MailHistory.GetRowFont())
    end
    list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", MailEntrySetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
end

function MailHistoryConsole_Gamepad:InitializeKeybindStripDescriptors()
    -- Browse-only: Reply/Forward were removed — prefilling the ZOS send screen
    -- from addon code taints the console's secure send path (see the note in
    -- MailHistory.lua's MAIL SEND section).
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        -- Back (PS5: Circle / Xbox: B)
        KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),
    }

    -- L2/R2 page jumps through the list.
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end

function MailHistoryConsole_Gamepad:PerformUpdate()
    self.dirty = false

    local list = self.itemList
    local task = self.asyncTask
    task:Cancel()
    list:Clear()

    -- Work on a copy so mail events landing mid-build can't mutate the table under us.
    local dataCopy = ZO_DeepTableCopy(MailHistory.data.table)
    local entries = {}

    -- Chunked over frames by LibAsync; GetTextFor is the expensive part.
    local function AddEntry(index, mail)
        -- Skip mail that has not yet been taken, returned, or deleted.  (i.e., pending)
        if not mail.show then return end
        -- Skip system mail per settings.
        if mail.fromSystem and (not MailHistory.settings.showSystemMail) then return end
        mail._rowText = MailHistory.GetTextFor(mail, MailHistory.TEXT_FOR_ROW)
        table.insert(entries, mail)
    end

    local function Commit()
        -- Same ordering as the upstream scroll list: newest first.
        table.sort(entries, function(a, b)
            if a.timestamp == b.timestamp then
                if a.id and b.id then
                    return a.id > b.id
                else
                    return a.to > b.to
                end
            end
            return a.timestamp > b.timestamp
        end)

        for _, mail in ipairs(entries) do
            local entryData = ZO_GamepadEntryData:New(mail._rowText, MailHistory.GetMailIcon(mail))
            entryData.mail = mail
            list:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
        end

        if #entries == 0 then
            list:AddEntry("ZO_GamepadMenuEntryTemplate", ZO_GamepadEntryData:New(GetString(SI_MAILHISTORY_EMPTY)))
        end

        list:Commit()
    end

    task:For(ipairs(dataCopy)):Do(AddEntry):Then(Commit)
end

function MailHistoryConsole_Gamepad:OnSelectionChanged(list, selectedData, oldSelectedData)
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
    if selectedData and selectedData.mail then
        GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(GAMEPAD_RIGHT_TOOLTIP, MailHistory.GetTextFor(selectedData.mail, MailHistory.TEXT_FOR_POPUP))
    end
end

function MailHistoryConsole_Gamepad:OnShowing()
    self:PerformUpdate()
end

function MailHistoryConsole_Gamepad:OnHide(...)
    ZO_Gamepad_ParametricList_Screen.OnHide(self, ...)
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
    GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
end

-- Icon for the list entry: sent / returned / received (same art as the upstream row markup).
function MailHistory.GetMailIcon(mail)
    if GetDisplayName() == mail.from then  -- SENT
        return "EsoUI/Art/mail/mail_tabicon_compose_down.dds"
    elseif mail.rts then  -- RTS
        return "EsoUI/Art/mail/mail_inbox_returned.dds"
    else  -- RECEIVED
        return "EsoUI/Art/mail/mail_tabicon_inbox_down.dds"
    end
end

-- Called from DataTableUpdated whenever the history changes.
function MailHistory.RefreshHistoryList()
    if MAILHISTORY_GAMEPAD and MAILHISTORY_GAMEPAD_SCENE and MAILHISTORY_GAMEPAD_SCENE:IsShowing() then
        MAILHISTORY_GAMEPAD:Update()
    end
end

function MailHistory.ToggleHistoryScene()
    if SCENE_MANAGER:IsShowing(SCENE_NAME) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Push(SCENE_NAME)
    end
end

-- Entry keybind shown on the ZOS gamepad mail scene (PS5: L3 — "Mail History").
-- Registered as our own keybind group, scene-scoped; ZOS descriptor tables
-- are never touched.  CAVEAT: when a viewed mail body contains an item/guild
-- link, ZO_GamepadLinks claims this same L3 slot and the keybind strip evicts
-- our button until the mail scene is next re-shown.  Every other shortcut in
-- this scene is also taken (PRIMARY/SECONDARY/TERTIARY/QUINARY/RIGHT_STICK,
-- L1/R1 tabs, L2/R2 paging), so L3 remains the least-bad choice; /mailhistory
-- is the fallback entry point.
local function AttachMailSceneKeybind()
    local mailScene = SCENE_MANAGER:GetScene("mailGamepad")
    if not mailScene then return end

    local keybindGroup =
    {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        {
            name = GetString(SI_MAILHISTORY_TITLE),
            keybind = "UI_SHORTCUT_LEFT_STICK",
            callback = function() SCENE_MANAGER:Push(SCENE_NAME) end,
        },
    }

    mailScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup)
        end
    end)
end

-- Called once from OnAddOnLoaded.
function MailHistory.InitHistoryScene()
    -- The screen must live under a top-level control: ESO draws all top-level
    -- controls above plain GuiRoot children, and the quadrant background
    -- (ZO_SharedGamepadNavQuadrant_1_Background, a BACKGROUND-layer top-level)
    -- otherwise paints over the header and list.  ZOS declares every
    -- ZO_Gamepad_ParametricList_Screen instance as a TopLevelControl in XML;
    -- this is the Lua equivalent.  The template re-anchors itself to the
    -- quadrant background on show, so the empty wrapper needs no anchors.
    local topLevel = WINDOW_MANAGER:CreateTopLevelWindow("MailHistoryConsole_SceneTopLevel")
    local control = WINDOW_MANAGER:CreateControlFromVirtual("MailHistoryConsole_Scene", topLevel, "ZO_Gamepad_ParametricList_Screen")
    MAILHISTORY_GAMEPAD = MailHistoryConsole_Gamepad:New(control)
    AttachMailSceneKeybind()
end
