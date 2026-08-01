SandEmoteList = {}
SandEmoteList.DATA_TYPE = 1
SandEmoteList.list = nil
SandEmoteList.playableEmotes = {}
SandEmoteList.playableEmotesLength = 0
SandEmoteList.specialActionsLength = 1
SandEmoteList.specialActions = {
    [1] = "/wait"
}
SandEmoteList.IDLE = "SandEmoteIDLE"
SandEmoteList.index = 1
SandEmoteList.stop = false
SandEmoteList.playingList = nil
SandEmoteList.displayNames = {}
SandEmoteList.deleteCallBack = nil
SandEmoteList.textChangedCallback = nil
SandEmoteList.busy = false
SandEmoteList.autoCompletes = {}
SandEmoteList.isRandom = false

SandEmoteList.AutoComplete = ZO_AutoComplete:Subclass()
SandEmoteList.RESTORE = ZO_EditContainerSizer.GetHeight

function SandEmoteList.AutoComplete:Initialize(...)
    ZO_AutoComplete.Initialize(self, ...)

    self:SetUseCallbacks(true)
    self:SetAnchorStyle(AUTO_COMPLETION_ANCHOR_BOTTOM)
    self:SetKeepFocusOnCommit(true)
    -- self:SetOwner(SandEmoteList)

    self:RegisterCallback(ZO_AutoComplete.ON_ENTRY_SELECTED, function(name, selectionMethod)
        self.editControl:SetText(name)
    end)

    self.editControl:SetHandler("OnUpArrow", function()
        if not IsShiftKeyDown() and self:IsOpen() then
            local index = self:GetAutoCompleteIndex()
            if not index or index > 1 then
                self:ChangeAutoCompleteIndex(-1)
                return true
            end
        end
    end)

    self.editControl:SetHandler("OnDownArrow", function()
        if not IsShiftKeyDown() and self:IsOpen() then
            local index = self:GetAutoCompleteIndex()
            if not index or index < self:GetNumAutoCompleteEntries() then
                self:ChangeAutoCompleteIndex(1)
                return true --Handled
            end
        end
    end)
end

function SandEmoteList.AutoComplete:New(...)
    self.editControl = ...
    return ZO_AutoComplete.New(self, ...)
end

function SandEmoteList.AutoComplete:GetAutoCompletionResults(text)
    if #text < 2 then
        return
    end

    local startChar = text:sub(1, 1)

    if startChar ~= "/" then
        return
    end

    return unpack(SandEmoteList:GetTabCompletions(text))
end

local function specialCbs(i)
    if i == "/wait" then
        -- d ( "waiting " )
    end
end

-- look into IsUnitActivelyEngaged("player")
-- if we care about DoesGameHaveFocus() maybe a setting
local function isBusy()
    return SandEmoteList.busy or
        not IsPlayerActivated() or
        not ArePlayerWeaponsSheathed() or
        (IsGameCameraUIModeActive() and DoesGameHaveFocus()) or
        IsPlayerMoving() or
        IsPlayerTryingToMove() or
        IsInteracting() or
        IsPlayerInteractingWithObject() or
        IsPlayerStunned() or
        IsInteractionPending() or
        GetInteractionType() ~= 0 or
        IsUnitInCombat("player") or
        GetUnitStealthState("player") ~= 0 or
        IsUnitSwimming("player") or
        IsMounted() or
        IsBlockActive() or
        IsUnitDeadOrReincarnating("player") or
        IsLooting()
end

function SandEmoteList:GetTabCompletions(action)
    local completions = {}

    for i=1, SandEmoteList.playableEmotesLength do
        local emote = SandEmoteList.playableEmotes[i]
        if emote.slash:sub(1, #action) == action then
            table.insert(completions, emote.slash)
        end
    end

    -- could insertion sort but.. Im lazy
    table.sort(completions)

    return completions
end

function SandEmoteList:SetBusy(busy)
    self.busy = busy
end

function SandEmoteList:Stop()
    EVENT_MANAGER:UnregisterForUpdate(SandEmoteList.IDLE)
    self.stop = true
end

function SandEmoteList:SetPlayingList(list, length, isRandom)
    self.playingList = list
    self.playingLength = length
    self.isRandom = isRandom or false
    SandEmoteList:Start()
end

-- TODO Random
function SandEmoteList:GetNext()
    if self.playingLength > 0  then
        if self.isRandom and self.playingLength > 2 then
            local index = math.random(self.playingLength)
            while index == self.index do
                index = math.random(self.playingLength)
            end
            self.index = index
        else
            self.index = (self.index) % self.playingLength + 1
        end

        local data = self.playingList[self.index]

        return data
    else
        return nil
    end
end

function SandEmoteList:Play(data)
    if self.stop or data == nil then
        return
    end

    zo_callLater(function()
        if self.index > self.playingLength then
            return
        end

        if isBusy() then
            EVENT_MANAGER:RegisterForUpdate(self.IDLE, 1000, function ()
                EVENT_MANAGER:UnregisterForUpdate(SandEmoteList.IDLE)
                self:Play(data)
            end)
        else
            if data.emoteIndex == nil then
                specialCbs(data.action)
            else
                PlayEmoteByIndex(data.emoteIndex)
            end

            EVENT_MANAGER:RegisterForUpdate(self.IDLE, data.time * 1000, function ()
                EVENT_MANAGER:UnregisterForUpdate(SandEmoteList.IDLE)
                self:Play(self:GetNext())
            end)
        end

    end, 100)
end

function SandEmoteList:Start()
    SandEmoteList:Stop()

    if self.playingList ~= nil and self.playingLength > 0 then
        self.stop = false
        self.index = 0
        local data = self:GetNext()
        EVENT_MANAGER:RegisterForUpdate(self.IDLE, 100, function ()
            EVENT_MANAGER:UnregisterForUpdate(SandEmoteList.IDLE)
            self:Play(data)
        end)
    end
end

function SandEmoteList:IsSpecialAction(action)
    for i=1, SandEmoteList.specialActionsLength do
        if SandEmoteList.specialActions[i] == action then
            return true
        end
    end

    return false
end

function SandEmoteList:GetEmoteIndex(action)
    for i=1, SandEmoteList.playableEmotesLength do
        local emote = SandEmoteList.playableEmotes[i]
        if action == emote.slash then
            return emote.emoteIndex
        end
    end

    return nil
end

function SandEmoteList:GetAllPlayableEmotes()
    for v in next, self.playableEmotes do rawset(self.playableEmotes, v, nil) end -- clear table
    SandEmoteList.playableEmotesLength = 0

    for i=1, GetNumEmotes() do
        local slash, cat, id, displayName, _ = GetEmoteInfo(i)
        local emoteIndex = GetEmoteIndex(id)
        local emoteCollectibleId = GetEmoteCollectibleId(emoteIndex)

        if not emoteCollectibleId or IsCollectibleUnlocked(emoteCollectibleId) then
            self.displayNames[slash] = displayName

            self.playableEmotesLength = self.playableEmotesLength + 1

            table.insert(self.playableEmotes, {
                i,
                emoteIndex = emoteIndex,
                displayName = displayName,
                slash = slash,
                colId = emoteCollectibleId
            })
        end
    end

    return self.playableEmotes
end

function SandEmoteList:New(control)
    self.list = control
    ZO_ScrollList_Initialize(self.list)
    ZO_ScrollList_AddDataType(
        self.list,
        SandEmoteList.DATA_TYPE,
        "SandEmoteListRow",
        30,
        function(control, data)
            SandEmoteList:SetupItemRow(control, data)
        end
    )

    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
end

function SandEmoteList:ClearList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    self:commit()
    for v in next, self.autoCompletes do rawset(self.autoCompletes, v, nil) end
end

-- Batch Update
function SandEmoteList:NewTable(t, length)
    local scrollData = ZO_ScrollList_GetDataList(self.list)

    for i=1, length do
       local p = t[i]

        local data = {
            action = p.action,
            time   = p.time,
            emoteIndex = p.emoteIndex
        }

        table.insert(scrollData,
                    ZO_ScrollList_CreateDataEntry(SandEmoteList.DATA_TYPE, data))
    end

    self:commit()
end

function SandEmoteList:NewAction(action, time, emoteIndex)
    local scrollData = ZO_ScrollList_GetDataList(self.list)

    local data = {
        action = action,
        time   = time,
        emoteIndex = emoteIndex
    }

    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(
        SandEmoteList.DATA_TYPE,
        data
    ))

    self:commit()

    return {
        action = action,
        time = time,
        emoteIndex = emoteIndex
    }
end

function SandEmoteList:SetupItemRow(control, data)
    control.data = data

    control:GetNamedChild("ActionEdit"):SetText(data.action)
    control:GetNamedChild("ActionEdit"):SetMouseEnabled(true)
    control:GetNamedChild("ActionEdit"):SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    control:GetNamedChild("ActionBackground"):SetHidden(false)
    control:GetNamedChild("ActionBackground"):SetDimensions(165, 64)

    control:GetNamedChild("ActionEdit"):SetHandler("OnSpace", function()
        control:GetNamedChild("TimeEdit"):TakeFocus()
    end)

    control:GetNamedChild("ActionEdit"):SetHandler("OnTextChanged", function(self)
        local orig = self:GetText()
        action = string.gsub(orig, "%s+", "")
        if orig ~= action then
            self:SetText(action)
            return
        end
    end)

    control:GetNamedChild("ActionEdit"):SetHandler("OnEnter", function(self)
        if self.complete then
            return true
        end

        local action = self:GetText()
        action = string.gsub(action, "%s+", "")

        self.complete = true

        self:LoseFocus()

        if self.origText == action then
            return true
        end

        if SandEmoteList:GetEmoteIndex(action) == nil and not SandEmoteList:IsSpecialAction(action) then
            self:SetText(self.origText)
            return true
        end

        local scrollData = ZO_ScrollList_GetDataList(SandEmoteList.list)
        local index = -1
        for v in next, scrollData do
            if scrollData[v].control == control then
                scrollData[v].control.data.action = action
                scrollData[v].control.data.emoteIndex = SandEmoteList:GetEmoteIndex(action)
                index = v
                break
            end
        end

        if index == -1 then
        else
            SandEmoteList.textChangedCallback(index, action, nil)
        end
    end)

    control:GetNamedChild("ActionEdit"):SetHandler("OnFocusLost", function(self)
        if self.complete then
            return true
        end

        local action = self:GetText()
        action = string.gsub(action, "%s+", "")

        self.complete = true

        self:LoseFocus()

        if self.origText == action then
            return true
        end

        if SandEmoteList:GetEmoteIndex(action) == nil and not SandEmoteList:IsSpecialAction(action) then
            self:SetText(self.origText)
            return true
        end

        local scrollData = ZO_ScrollList_GetDataList(SandEmoteList.list)
        local index = -1
        for v in next, scrollData do
            if scrollData[v].control == control then
                scrollData[v].control.data.action = action
                scrollData[v].control.data.emoteIndex = SandEmoteList:GetEmoteIndex(action)
                index = v
                break
            end
        end

        if index == -1 then
        else
            SandEmoteList.textChangedCallback(index, action, nil)
        end
    end)

    control:GetNamedChild("ActionEdit"):SetHandler("OnFocusGained", function(self)
        self.origText = self:GetText()
        self.complete = false
    end)

    table.insert(
        SandEmoteList.autoCompletes,
        SandEmoteList.AutoComplete:New(control:GetNamedChild("ActionEdit"), nil, nil, nil, 8, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_DONT_USE_ARROWS)
    )

    control:GetNamedChild("TimeEdit"):SetText(data.time)
    control:GetNamedChild("TimeEdit"):SetMouseEnabled(true)
    control:GetNamedChild("TimeEdit"):SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    control:GetNamedChild("TimeBackground"):SetHidden(false)
    control:GetNamedChild("TimeBackground"):SetDimensions(115, 64)

    control:GetNamedChild("TimeEdit"):SetHandler("OnSpace", function()
        control:GetNamedChild("ActionEdit"):TakeFocus()
    end)

    control:GetNamedChild("TimeEdit"):SetHandler("OnTextChanged", function(self)
        local orig = self:GetText()
        time = string.gsub(orig, "%s+", "")
        if orig ~= time then
            self:SetText(time)
            return
        end
    end)

    control:GetNamedChild("TimeEdit"):SetHandler("OnEnter", function(self)
        if self.complete then
            return true
        end

        local time = self:GetText()
        time = string.gsub(time, "%s+", "")

        self.complete = true

        self:LoseFocus()

        if self.origText == time then
            return true
        end

        if not tonumber(time) then
            self:SetText(self.origText)
            return
        end

        local scrollData = ZO_ScrollList_GetDataList(SandEmoteList.list)
        local index = -1
        for v in next, scrollData do
            if scrollData[v].control == control then
                scrollData[v].control.data.time = time
                index = v
                break
            end
        end

        if index == -1 then
        else
            SandEmoteList.textChangedCallback(index, nil, time)
        end
    end)

    control:GetNamedChild("TimeEdit"):SetHandler("OnFocusLost", function(self)
        if self.complete then
            return true
        end

        local time = self:GetText()
        time = string.gsub(time, "%s+", "")

        self.complete = true

        self:LoseFocus()

        if self.origText == time then
            return true
        end

        if not tonumber(time) then
            self:SetText(self.origText)
            return
        end

        local scrollData = ZO_ScrollList_GetDataList(SandEmoteList.list)
        local index = -1
        for v in next, scrollData do
            if scrollData[v].control == control then
                scrollData[v].control.data.time = time
                index = v
                break
            end
        end

        if index == -1 then
        else
            SandEmoteList.textChangedCallback(index, nil, time)
        end
    end)

    control:GetNamedChild("TimeEdit"):SetHandler("OnFocusGained", function(self)
        self.origText = self:GetText()
        self.complete = false
    end)
end

function SandEmoteListRow_OnMouseEnter(control)
    ZO_ScrollList_MouseEnter(SandEmoteList.list, control)

    local emoteCollectibleId = GetEmoteCollectibleId(control.data.emoteIndex)

    if emoteCollectibleId then
        local link = GetCollectibleLink(emoteCollectibleId, LINK_STYLE_BRACKETS)

        if link then
            SandEmoteList.itemtool = ItemTooltip
            InitializeTooltip(SandEmoteList.itemtool, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
            SandEmoteList.itemtool:SetLink(link)
        end
    else
        SandEmoteList.itemtool = InformationTooltip
        InitializeTooltip(SandEmoteList.itemtool, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
        SetTooltipText(SandEmoteList.itemtool, SandEmoteList.displayNames[control.data.action])
    end
end

function SandEmoteListRow_OnMouseExit(control)
    ZO_ScrollList_MouseExit(SandEmoteList.list, control)

    if SandEmoteList.itemtool then
        ClearTooltip(SandEmoteList.itemtool)
    end
end

function SandEmoteListRow_OnMouseUp(control, button, upInside)
    -- 1 : left, play
    -- 2 : right, delete
    local data = control.data

    if button == 1 then
        if data.emoteIndex == nil then
            specialCbs(data.action)
        else
            PlayEmoteByIndex(data.emoteIndex)
        end
    elseif button == 2 then
        local scrollData = ZO_ScrollList_GetDataList(SandEmoteList.list)
        local deletedIndex = -1

        for v in next, scrollData do
            if scrollData[v].control == control then
                table.remove(scrollData, v)
                deletedIndex = v
                break
            end
        end
        SandEmoteList:commit()
        SandEmoteList.deleteCallBack(deletedIndex)
    end
end

function SandEmoteList:SetDeleteCallback(cb)
    SandEmoteList.deleteCallBack = cb
end

function SandEmoteList:SetTextChangedCallback(cb)
    SandEmoteList.textChangedCallback = cb
end

function SandEmoteList:EmoteFailed(eventCode, failure)
    d ( "Emote Failed for some resaon : " .. tostring(failure) )
end

function SandEmoteList:commit()
    -- I don't use a backdrop nor do I want one
    -- So make the height be set manually then unhook it
    hook()
    ZO_ScrollList_Commit(self.list)
    unhook()
end

function hook()
    ZO_EditContainerSizer.GetHeight = fake
end

function unhook()
    ZO_EditContainerSizer.GetHeight = SandEmoteList.RESTORE
end

function fake(backdrop, bufferTop, bufferBottom)
    return 30 + bufferTop + bufferBottom 
end
