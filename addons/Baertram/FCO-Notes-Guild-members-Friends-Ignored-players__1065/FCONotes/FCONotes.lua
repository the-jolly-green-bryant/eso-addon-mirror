-----------------------------------------------------------------
--FCONotes.lua
-----------------------------------------------------------------
local FCON = FCONotes

--local speedup refs
local tos = tostring

--Constants refs
local addonVars = FCON.addonVars
local addonName = addonVars.addonName

local preventerVars = FCON.preventerVars
local guildRosterVars = FCON.guildRosterVars
local friendsListVars = FCON.friendsListVars
local ignoreListVars = FCON.ignoreListVars
local keystripVars = FCON.keystripVars
local localizationVars = FCON.localizationVars
local zosVars = FCON.zosVars
local textureVars = FCON.textureVars


--================= LOCAL FUNCTIONS ============================================

--[[
--Post-Hook Wrapper
local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end
]]

--Local helper function to copy a deep-structured table/array
--[[
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
]]

local function getGuildIndexById(guildId)
	local numGuilds = GetNumGuilds()
    for guildIndex=1,numGuilds,1 do
        local guildIdOfIndex=GetGuildId(guildIndex)
        if guildId == guildIdOfIndex then return guildIndex end
    end
    return
end

local function setPersonalNoteToSV(noteType, noteText, displayName, updateData)
    if noteType == nil then return false end
    local settings = FCON.settingsVars.settings
    local enableNotes = settings.enableNotes
    if not enableNotes[noteType] then return end

    if noteText == "" then noteText = nil end
    local wasChanged = false

    if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        local activeGuildId = updateData ~= nil and updateData.guildId
        if activeGuildId == nil then activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId() end
        if activeGuildId == nil or activeGuildId <= 0 then return false end

        if not settings.saveGuildPersonalNotesAccountWide then
            settings.personalGuildNotes[activeGuildId] = settings.personalGuildNotes[activeGuildId] or {}
            settings.personalGuildNotes[activeGuildId][displayName] = noteText
            wasChanged = true
        else
            settings.personalGuildNotes[displayName] = noteText
            wasChanged = true
        end

    elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        settings.personalFriendsListNotes[displayName] = noteText
        wasChanged = true
    elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        settings.personalIgnoreListNotes[displayName]  = noteText
        wasChanged = true
    end
    return wasChanged
end

local function getPersonalNoteFromSV(noteType, displayName, readData)
    if noteType == nil then return end
    local settings = FCON.settingsVars.settings
    local enableNotes = settings.enableNotes
    if not enableNotes[noteType] then return end

    if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        local activeGuildId = readData ~= nil and readData.guildId
        if activeGuildId == nil then activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId() end
        if activeGuildId == nil or activeGuildId <= 0 then return end

        if not settings.saveGuildPersonalNotesAccountWide then
            if settings.personalGuildNotes[activeGuildId] == nil then return end
            return settings.personalGuildNotes[activeGuildId][displayName]
        else
            return settings.personalGuildNotes[displayName]
        end

    elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        return settings.personalFriendsListNotes[displayName]
    elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        return settings.personalIgnoreListNotes[displayName]
    end
    return
end


--Function to save the current personal guild member notes for a later backup
local function FCONotes_BackupPersonalNotesNow(noteType, displayName, data)
    local backupAll = (noteType == nil and displayName == nil and data == nil and true) or false
    local somethingBackuped = false
    local settings = FCON.settingsVars.settings
    if backupAll or noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        --Add only 1 new entry to the backup?
        if displayName ~= nil and displayName ~= "" then
            --Saved for each account name or guild Id + account name?
            if not settings.saveGuildPersonalNotesAccountWide then
                local guildId = data.guildId
                if guildId == nil or guildId == -1 then return false end
                if settings.personalGuildNotesBackup[guildId] == nil then settings.personalGuildNotesBackup[guildId] = {} end
                settings.personalGuildNotesBackup[guildId][displayName] = {}
                local noteTable = settings.personalGuildNotes[guildId][displayName]
                settings.personalGuildNotesBackup[guildId][displayName] = noteTable
                somethingBackuped = true
            else
                local noteTable = settings.personalGuildNotes[displayName]
                settings.personalGuildNotesBackup[displayName] = noteTable
                somethingBackuped = true
            end
        else
            --Add all currently saved personal guild member notes to the backup
            settings.personalGuildNotesBackup = {}
            --Copy the settings table with the personal guild member notes to the backup table now
            --settings.personalGuildNotesBackup = deepcopy(settings.personalGuildNotes)
            ZO_ShallowTableCopy(settings.personalGuildNotes, settings.personalGuildNotesBackup)
            somethingBackuped = true
        end
    end
    if backupAll or  noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        if displayName ~= nil and displayName ~= "" then
            local noteTable = settings.personalFriendsListNotes[displayName]
            settings.personalFriendsListNotesBackup[displayName] = noteTable
            somethingBackuped = true
        else
            settings.personalFriendsListNotesBackup = {}
            --settings.personalFriendsListNotesBackup = deepcopy(settings.personalFriendsListNotes)
            ZO_ShallowTableCopy(settings.personalFriendsListNotes, settings.personalFriendsListNotesBackup)
            somethingBackuped = true
        end
    end
    if backupAll or  noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        if displayName ~= nil and displayName ~= "" then
            local noteTable = settings.personalIgnoreListNotes[displayName]
            settings.personalIgnoreListNotesBackup[displayName] = noteTable
            somethingBackuped = true
        else
            settings.personalIgnoreListNotesBackup = {}
            --settings.personalIgnoreListNotesBackup = deepcopy(settings.personalIgnoreListNotes)
            ZO_ShallowTableCopy(settings.personalIgnoreListNotes, settings.personalIgnoreListNotesBackup)
            somethingBackuped = true
        end
    end
    return somethingBackuped
end

--Function to restore the last saved backup of the personal guild member notes
local function FCONotes_RestorePersonalFCONotesNow(noteType)
    local settings = FCON.settingsVars.settings
    local restoreAll = (noteType == nil and true) or false
    local somethingRestored = false

    if restoreAll or noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        if settings.personalGuildNotesBackup ~= nil then
            ZO_ShallowTableCopy(settings.personalGuildNotesBackup, settings.personalGuildNotes)
            somethingRestored = true
        end
    end
    if restoreAll or noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        if settings.personalFriendsListNotesBackup ~= nil then
            ZO_ShallowTableCopy(settings.personalFriendsListNotesBackup, settings.personalFriendsListNotes)
            somethingRestored = true
        end
    end
    if restoreAll or noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        if settings.personalIgnoreListNotesBackup ~= nil then
            ZO_ShallowTableCopy(settings.personalIgnoreListNotesBackup, settings.personalIgnoreListNotes)
            somethingRestored = true
        end
    end
    --Reloading the UI now to saved variables back to the file
    if somethingRestored then
        ReloadUI()
    end
end

local function FCONotes_UpdateNoteRowIcon(noteType, control, data)
    --d("[FCONotes_UpdateNoteRowIcon]-noteType: " ..tos(noteType))
    if noteType == nil then return false end
    if control == nil then return end
    local settings = FCON.settingsVars.settings
    local enableNotes = settings.enableNotes
    if not enableNotes[noteType] then return end

    if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        --FCON._debugDataUpdateNoteRowIcon = data
        local standardESOGuildMemberNote = control:GetNamedChild("Note")
        if standardESOGuildMemberNote ~= nil then
            local personalGuildMemberNote = control:GetNamedChild("FCONote")
            local parent = WINDOW_MANAGER:GetControlByName(control:GetName(), "")
            if parent == nil then
                return true
            end
            if personalGuildMemberNote == nil then
                personalGuildMemberNote = WINDOW_MANAGER:CreateControl(control:GetName() .. "FCONote", parent, CT_TEXTURE)
            end
            local iconDataTab = settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER]
            local iconTexture = iconDataTab.texture
            --Control did already exist or was created now
            if personalGuildMemberNote ~= nil and iconTexture ~= nil then
                local doHide = false
                local noteText = ""
                --This will only use the data at the current row, not the updated data from SavedVariables -> Directly after a change by the editor dialog
                local dataTab = data
                if dataTab == nil then
                    dataTab = control.dataEntry.data
                    dataTab.FCOnote = getPersonalNoteFromSV(noteType, dataTab.displayName, { guildId = dataTab.guildId or GUILD_ROSTER_MANAGER:GetGuildId() })
                end
                if dataTab.FCOnote == nil or dataTab.FCOnote == "" then
                    doHide = true
                elseif dataTab.FCOnote ~= nil then
                    noteText = dataTab.FCOnote
                end
                --d(">found FCO icon texture control, text: " ..tos(noteText))
                local pLeft, pTop
                local pWidth, pHeight
                local pTexture = textureVars.MARKER_TEXTURES[iconTexture]
                if pTexture ~= nil and pTexture ~= "" then
                    --Change the icon's size because it is special?
                    if textureVars.MARKER_TEXTURES_SIZE[iconTexture] ~= nil then
                        pWidth = textureVars.MARKER_TEXTURES_SIZE[iconTexture].width or 32
                        pHeight = textureVars.MARKER_TEXTURES_SIZE[iconTexture].height or 32
                        pLeft = iconDataTab.position.x + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetLeft or 0
                        pTop = iconDataTab.position.y + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetTop or 0
                    else
                        pWidth = iconDataTab.size or 32
                        pHeight = pWidth
                        pLeft = iconDataTab.position.x or 0
                        pTop = iconDataTab.position.y or 0
                    end
                    --Hide or show the control now
                    personalGuildMemberNote:SetHidden(doHide)
                    personalGuildMemberNote:SetDimensions(pWidth, pHeight)
                    personalGuildMemberNote:SetTexture(pTexture)
                    local iconColor = iconDataTab.color
                    personalGuildMemberNote:SetColor(iconColor.r, iconColor.g, iconColor.b, iconColor.a)
                    personalGuildMemberNote:ClearAnchors()
                    personalGuildMemberNote:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, pLeft, pTop)
                    personalGuildMemberNote:SetDrawTier(DT_HIGH)

                    --Add mouse handlers
                    personalGuildMemberNote:SetMouseEnabled(not doHide)
                    if not doHide then
                        personalGuildMemberNote:SetHandler("OnMouseEnter", function(self)
                            if noteText ~= nil and noteText ~= "" then
                                local tooltipText = "|c00FF00FCO|r|cFFFF00Notes|r\n|c8888DD" .. dataTab.displayName .. "|r (" .. dataTab.characterName .. ")\n\n|cFFFFFF" .. noteText .. "|r"
                                ZO_Tooltips_ShowTextTooltip(personalGuildMemberNote, LEFT, tooltipText)
                            else
                                ZO_Tooltips_HideTextTooltip()
                            end
                        end)
                        personalGuildMemberNote:SetHandler("OnMouseExit", function(self)
                            ZO_Tooltips_HideTextTooltip()
                        end)
                        personalGuildMemberNote:SetHandler("OnMouseUp", function(self, button, upInside)
                            ZO_Tooltips_HideTextTooltip()
                            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                                FCONotes_AddNote(self, true, false, FCONOTES_LIST_TYPE_GUILDS_ROSTER)
                            end
                        end)
                    end
                end
            end
        end


    elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        --d("FCONotes_UpdateNoteRowIcon-noteType: " ..tos(noteType))
        local standardESOFriendsListNote = control:GetNamedChild("Note")
        if standardESOFriendsListNote ~= nil then
            local personalFriendsListNote = control:GetNamedChild("FCONote")
            local parent                  = WINDOW_MANAGER:GetControlByName(control:GetName(), "")
            if parent == nil then
                return true
            end
            if personalFriendsListNote == nil then
                personalFriendsListNote = WINDOW_MANAGER:CreateControl(control:GetName() .. "FCONote", parent, CT_TEXTURE)
            end
            local iconDataTab = settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST]
            local iconTexture = iconDataTab.texture
            --Control did already exist or was created now
            if personalFriendsListNote ~= nil and iconTexture ~= nil then
                local doHide = false
                local noteText = ""
                local dataTab = data
                if dataTab == nil then
                    dataTab = control.dataEntry.data
                    dataTab.FCOnote = getPersonalNoteFromSV(noteType, dataTab.displayName, nil)
                end
                --d(">displayName: " .. tos(dataTab.displayName))
                if dataTab.FCOnote == nil or dataTab.FCOnote == "" then
                    doHide = true
                elseif dataTab.FCOnote ~= nil then
                    noteText = dataTab.FCOnote
                end
                local pLeft, pTop
                local pWidth, pHeight
                local pTexture = textureVars.MARKER_TEXTURES[iconTexture]
                if pTexture ~= nil and pTexture ~= "" then
                    --Change the icon's size because it is special?
                    if textureVars.MARKER_TEXTURES_SIZE[iconTexture] ~= nil then
                        pWidth = textureVars.MARKER_TEXTURES_SIZE[iconTexture].width or 32
                        pHeight = textureVars.MARKER_TEXTURES_SIZE[iconTexture].height or 32
                        pLeft = iconDataTab.position.x + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetLeft or 0
                        pTop = iconDataTab.position.y + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetTop or 0
                    else
                        pWidth = iconDataTab.size or 32
                        pHeight = pWidth
                        pLeft = iconDataTab.position.x or 0
                        pTop = iconDataTab.position.y or 0
                    end
                    --Hide or show the control now
                    personalFriendsListNote:SetHidden(doHide)
                    personalFriendsListNote:SetDimensions(pWidth, pHeight)
                    personalFriendsListNote:SetTexture(pTexture)
                    local iconColor = iconDataTab.color
                    personalFriendsListNote:SetColor(iconColor.r, iconColor.g, iconColor.b, iconColor.a)
                    personalFriendsListNote:ClearAnchors()
                    personalFriendsListNote:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, pLeft, pTop)
                    personalFriendsListNote:SetDrawTier(DT_HIGH)

                    --Add mouse handlers
                    personalFriendsListNote:SetMouseEnabled(not doHide)
                    if not doHide then
                        personalFriendsListNote:SetHandler("OnMouseEnter", function(self)
                            if noteText ~= nil and noteText ~= "" then
                                local tooltipText = "|c00FF00FCO|r|cFFFF00Notes|r\n|c8888DD" .. dataTab.displayName .. "|r (" .. dataTab.characterName .. ")\n\n|cFFFFFF" .. noteText .. "|r"
                                ZO_Tooltips_ShowTextTooltip(personalFriendsListNote, LEFT, tooltipText)
                            else
                                ZO_Tooltips_HideTextTooltip()
                            end
                        end)
                        personalFriendsListNote:SetHandler("OnMouseExit", function(self)
                            ZO_Tooltips_HideTextTooltip()
                        end)
                        personalFriendsListNote:SetHandler("OnMouseUp", function(self, button, upInside)
                            ZO_Tooltips_HideTextTooltip()
                            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                                FCONotes_AddNote(self, true, false, FCONOTES_LIST_TYPE_FRIENDS_LIST)
                            end
                        end)
                    end
                end
                --d(">doHide: " ..tos(doHide) )
            end
        end

    elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        local standardESOIgnoreListNote = control:GetNamedChild("Note")
        if standardESOIgnoreListNote ~= nil then
            local personalIgnoreListNote = control:GetNamedChild("FCONote")
            local parent                 = WINDOW_MANAGER:GetControlByName(control:GetName(), "")
            if parent == nil then
                return true
            end
            if personalIgnoreListNote == nil then
                personalIgnoreListNote = WINDOW_MANAGER:CreateControl(control:GetName() .. "FCONote", parent, CT_TEXTURE)
            end
            local iconDataTab = settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST]
            local iconTexture = iconDataTab.texture
            --Control did already exist or was created now
            if personalIgnoreListNote ~= nil and iconTexture ~= nil then
                local doHide = false
                local noteText = ""
                local dataTab = data
                if dataTab == nil then
                    dataTab = control.dataEntry.data
                    dataTab.FCOnote = getPersonalNoteFromSV(noteType, dataTab.displayName, nil)
                end
                if dataTab.FCOnote == nil or dataTab.FCOnote == "" then
                    doHide = true
                elseif dataTab.FCOnote ~= nil then
                    noteText = dataTab.FCOnote
                end
                local pLeft, pTop
                local pWidth, pHeight
                local pTexture = textureVars.MARKER_TEXTURES[iconTexture]
                if pTexture ~= nil and pTexture ~= "" then
                    --Change the icon's size because it is special?
                    if textureVars.MARKER_TEXTURES_SIZE[iconTexture] ~= nil then
                        pWidth = textureVars.MARKER_TEXTURES_SIZE[iconTexture].width or 32
                        pHeight = textureVars.MARKER_TEXTURES_SIZE[iconTexture].height or 32
                        pLeft = iconDataTab.position.x + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetLeft or 0
                        pTop = iconDataTab.position.y + textureVars.MARKER_TEXTURES_SIZE[iconTexture].offsetTop or 0
                    else
                        pWidth = iconDataTab.size or 32
                        pHeight = pWidth
                        pLeft = iconDataTab.position.x or 0
                        pTop = iconDataTab.position.y or 0
                    end
                    --Hide or show the control now
                    personalIgnoreListNote:SetHidden(doHide)
                    personalIgnoreListNote:SetDimensions(pWidth, pHeight)
                    personalIgnoreListNote:SetTexture(pTexture)
                    local iconColor = iconDataTab.color
                    personalIgnoreListNote:SetColor(iconColor.r, iconColor.g, iconColor.b, iconColor.a)
                    personalIgnoreListNote:ClearAnchors()
                    personalIgnoreListNote:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, pLeft, pTop)
                    personalIgnoreListNote:SetDrawTier(DT_HIGH)

                    --Add mouse handlers
                    personalIgnoreListNote:SetMouseEnabled(not doHide)
                    if not doHide then
                        personalIgnoreListNote:SetHandler("OnMouseEnter", function(self)
                            if noteText ~= nil and noteText ~= "" then
                                local tooltipText = "|c00FF00FCO|r|cFFFF00Notes|r\n|c8888DD" .. dataTab.displayName .. "|r\n\n|cFFFFFF" .. noteText .. "|r"
                                ZO_Tooltips_ShowTextTooltip(personalIgnoreListNote, LEFT, tooltipText)
                            else
                                ZO_Tooltips_HideTextTooltip()
                            end
                        end)
                        personalIgnoreListNote:SetHandler("OnMouseExit", function(self)
                            ZO_Tooltips_HideTextTooltip()
                        end)
                        personalIgnoreListNote:SetHandler("OnMouseUp", function(self, button, upInside)
                            ZO_Tooltips_HideTextTooltip()
                            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                                FCONotes_AddNote(self, true, false, FCONOTES_LIST_TYPE_IGNORE_LIST)
                            end
                        end)
                    end
                end
            end
        end
    end
end


-- Get the guild member/friends list/ignore list information
local function FCONotes_GetListData(noteType, displayName, updateNoteFromSavedVars, data)
    --d("[FCONotes_GetGuildRosterData]")
    if noteType == nil then return end
    updateNoteFromSavedVars = updateNoteFromSavedVars or false
    displayName             = displayName or -1
    local settings = FCON.settingsVars.settings
    local enableNotes = settings.enableNotes
    if not enableNotes[noteType] then return end

    if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        --Check the saved variables
        if updateNoteFromSavedVars and settings.personalGuildNotes == nil then return false end

        local guildRosterList = zosVars.guildRosterList
--d("<refresh scroll list GUILD ROSTER")
        ZO_ScrollList_RefreshVisible(guildRosterList.list or guildRosterList)
        return true

    elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        --Check the saved variables
        if updateNoteFromSavedVars and settings.personalFriendsListNotes == nil then return false end

        local friendsList     = zosVars.friendsList
        ZO_ScrollList_RefreshVisible(friendsList.list or friendsList)
        return true

    elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        --Check the saved variables
        if updateNoteFromSavedVars and settings.personalIgnoreListNotes == nil then return false end

        local ignoreList     = zosVars.ignoreList
        ZO_ScrollList_RefreshVisible(ignoreList.list or ignoreList)
        return true

    end
    return false
end


--Function to save the guild member FCO note now
local function FCONotes_SetFCONote(noteType, displayName, note, data)
--d("[FCONotes_SetFCONote]noteType: " ..tos(noteType) .. ", displayName: " ..tos(displayName) .. ", note: " ..tos(note))
    if displayName == nil or displayName == "" then return false end
    --if note == nil then return false end
    --The note was removed/cleared?
    local noteText = note

    local settings = FCON.settingsVars.settings
    local enableNotes = settings.enableNotes
    if not enableNotes[noteType] then return false end

    if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
        local activeGuildId = data.guildId
        if activeGuildId == nil then activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId() end
        if activeGuildId == nil or activeGuildId <= 0 then return false end
--d(">guildId: " .. activeGuildId)
        local activeGuildIdData = { guildId = activeGuildId }

        local wasChanged = setPersonalNoteToSV(noteType, noteText, displayName, activeGuildIdData)
        if wasChanged then
            --Update the data structures for the current guild member
            if FCONotes_GetListData(noteType, displayName, true, activeGuildIdData) == false then
--d("<abort!")
                return false
            else
                --Update this one, changed icon at the guild roster now
                if guildRosterVars.lastRowControl ~= nil then
--d("SetGuildMemberFCONote - Update icon at row: " .. guildRosterVars.lastRowControl:GetName())
                    FCONotes_UpdateNoteRowIcon(noteType, guildRosterVars.lastRowControl, nil)
                end
            end

        end
        return wasChanged

    elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
        local wasChanged = setPersonalNoteToSV(noteType, noteText, displayName, nil)
        if wasChanged then
            if FCONotes_GetListData(noteType, displayName, true) == false then
                return false
            else
                --Update this one, changed icon at the guild roster now
                if friendsListVars.lastRowControl ~= nil then
                    FCONotes_UpdateNoteRowIcon(noteType, friendsListVars.lastRowControl, nil)
                end
            end
        end
        return wasChanged

    elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
        local wasChanged = setPersonalNoteToSV(noteType, noteText, displayName, nil)
        if wasChanged then
            if FCONotes_GetListData(noteType, displayName, true) == false then
                return false
            else
                --Update this one, changed icon at the guild roster now
                if ignoreListVars.lastRowControl ~= nil then
                    FCONotes_UpdateNoteRowIcon(noteType, ignoreListVars.lastRowControl, nil)
                end
            end
        end
        return wasChanged
    end
    return
end

--Callback function for the guild roster FCO note changed
local function FCONotes_GuildRoster_FCO_Note_Changed(displayName, note)
    local activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId()
    if activeGuildId == nil then return false end
    FCONotes_SetFCONote(FCONOTES_LIST_TYPE_GUILDS_ROSTER, displayName, note, { guildId=activeGuildId })
    guildRosterVars.lastRowControl = nil
end

--Callback function for the friends list FCO note changed
local function FCONotes_FriendsList_FCO_Note_Changed(displayName, note)
    FCONotes_SetFCONote(FCONOTES_LIST_TYPE_FRIENDS_LIST, displayName, note, nil)
    friendsListVars.lastRowControl = nil
end

--Callback function for the ignore list FCO note changed
local function FCONotes_IgnoreList_FCO_Note_Changed(displayName, note)
    FCONotes_SetFCONote(FCONOTES_LIST_TYPE_IGNORE_LIST, displayName, note, nil)
    ignoreListVars.lastRowControl = nil
end


--Global function to show personal note dialog
function FCONotes_AddNote(ctrl, fromKeybind, delete, noteType)
--d("[FCONotes_AddNote]")
    guildRosterVars.lastRowControl = nil
    friendsListVars.lastRowControl = nil
    ignoreListVars.lastRowControl = nil

    local isGuildRoster =   guildRosterVars.scene == SCENE_SHOWN
    local isFriendsList =   friendsListVars.scene == SCENE_SHOWN
    local isIgnoreList =    ignoreListVars.scene == SCENE_SHOWN
    noteType = noteType or ((isGuildRoster and FCONOTES_LIST_TYPE_GUILDS_ROSTER) or (isFriendsList and FCONOTES_LIST_TYPE_FRIENDS_LIST) or (isIgnoreList and FCONOTES_LIST_TYPE_IGNORE_LIST))
    if noteType == nil then return end

    local enableNotes = FCON.settingsVars.settings.enableNotes
    if not enableNotes[noteType] then return false end

    if ctrl ~= nil then
        local control = ctrl
        if fromKeybind then
            control = control:GetParent()
        end
        local data = ZO_ScrollList_GetData(control)

        local activeGuildId, callbackFunc
        if noteType ==  FCONOTES_LIST_TYPE_GUILDS_ROSTER then
            guildRosterVars.lastRowControl  = control
            callbackFunc                    = FCONotes_GuildRoster_FCO_Note_Changed
        elseif noteType ==  FCONOTES_LIST_TYPE_FRIENDS_LIST then
            friendsListVars.lastRowControl  = control
            callbackFunc                    = FCONotes_FriendsList_FCO_Note_Changed
        elseif noteType ==  FCONOTES_LIST_TYPE_IGNORE_LIST then
            ignoreListVars.lastRowControl   = control
            callbackFunc                    = FCONotes_IgnoreList_FCO_Note_Changed
        end

        if not delete then
            if data ~= nil then
                ClearMenu()
                ZO_Dialogs_ShowDialog("EDIT_NOTE", {displayName = data.displayName, note = data.FCOnote, changedCallback = callbackFunc, noteType=noteType})
            end
        else
            local settings = FCON.settingsVars.settings

            if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
                activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId()
                --Saved personal guild notes for each account or for each guild Id and account?
                if not settings.saveGuildPersonalNotesAccountWide then
                    --Get the active guild ID
                    if activeGuildId == nil then return false end
                    if   settings.personalGuildNotes[activeGuildId] ~= nil
                            and settings.personalGuildNotes[activeGuildId][data.displayName] ~= nil then
                        --Backup this note so you can restore it with next ReloadUI
                        FCONotes_BackupPersonalNotesNow(FCONOTES_LIST_TYPE_GUILDS_ROSTER, data.displayName, { guildID = activeGuildId })
                        --Delete the personal guild member note now
                        settings.personalGuildNotes[activeGuildId][data.displayName] = nil
                    end
                else
                    if settings.personalGuildNotes[data.displayName] ~= nil then
                        --Backup this note so you can restore it with next ReloadUI
                        FCONotes_BackupPersonalNotesNow(FCONOTES_LIST_TYPE_GUILDS_ROSTER, data.displayName, nil)

                        --Delete the personal guild member note now
                        settings.personalGuildNotes[data.displayName] = nil
                    end
                end
            elseif noteType == FCONOTES_LIST_TYPE_FRIENDS_LIST then
                --Friends list
                --Saved personal friends list notes
                if settings.personalFriendsListNotes[data.displayName] ~= nil then
                    --Backup this note so you can restore it with next ReloadUI
                    FCONotes_BackupPersonalNotesNow(noteType, data.displayName)
                    --Delete the personal guild member note now
                    settings.personalFriendsListNotes[data.displayName] = nil
                end
            elseif noteType == FCONOTES_LIST_TYPE_IGNORE_LIST then
                --Ignore list
                --Saved personal ignore list notes
                if settings.personalIgnoreListNotes[data.displayName] ~= nil then
                    --Backup this note so you can restore it with next ReloadUI
                    FCONotes_BackupPersonalNotesNow(noteType, data.displayName)
                    --Delete the personal guild member note now
                    --settings.personalIgnoreListNotes[data.displayName] = nil
                    -->Try specil way to updae the ignore list note here as setupFunc does not seem to update properly?
                    ignoreListVars.lastRowControl   = control
                    FCONotes_SetFCONote(noteType, data.displayName, nil, nil)
                    ignoreListVars.lastRowControl   = nil
                end
            end
            --Delete the personal guild note now
            data.FCOnote = nil
        end
    end
end

--Function to send the note to the guild officer chat
local function FCONotes_SendNoteToGuildOfficerChat(noteText, displayName, characterName)
    if noteText == "" or noteText == nil then return false end
    if characterName == "" or characterName == nil then return false end
    if displayName == "" or displayName == nil then return false end
    local currentguildId = GUILD_ROSTER_MANAGER.guildId
    if currentguildId == nil then return false end
    local currentGuildIndex = getGuildIndexById(currentguildId)
    if not currentGuildIndex or currentGuildIndex < 1 or  currentGuildIndex > MAX_GUILDS then return end
    --the guild officer channels
    local mappingTableGuildToOfficerChanel = {
        [1] = CHAT_CHANNEL_OFFICER_1,
        [2] = CHAT_CHANNEL_OFFICER_2,
        [3] = CHAT_CHANNEL_OFFICER_3,
        [4] = CHAT_CHANNEL_OFFICER_4,
        [5] = CHAT_CHANNEL_OFFICER_5,
    }
    local guildOfficerChannel = mappingTableGuildToOfficerChanel[currentGuildIndex]
    if guildOfficerChannel == nil then return false end
    --Change the chat channel to the guild officer channel now
    CHAT_SYSTEM:SetChannel(guildOfficerChannel, "")
    --Put the chat message into the chat text edit field
    local textMessage = "[" .. localizationVars.fco_notes_loc["chat_pre_guild_officer"] .. ": " .. characterName .. " (" .. displayName .. ")] " .. noteText
    CHAT_SYSTEM.textEntry.editControl:SetText(textMessage)
    CHAT_SYSTEM.textEntry.editControl:TakeFocus()
end

--Add the new context menu entry "[FCO Notes] Add personal note" for the guild roster row contetx menu
local function FCONotes_AddContextMenuEntry(ctrl, noteType)
--d("FCONotes_AddContextMenuEntry - Control name: " .. ctrl:GetName())
    local data = ZO_ScrollList_GetData(ctrl)
    if data ~= nil then
        local locVars = localizationVars.fco_notes_loc
        --Call this function later as the original menu will be build in OnMouseUp function and we are in the PreHook of this function here!
        --So all menu entries will be overwritten again and we must add this entry later
        zo_callLater(function()
            --Add context menu entry now
            --AddMenuItem(localizationVars.fco_notes_loc["context_menu_add_personal_guild_note"],
            AddCustomMenuItem(locVars["context_menu_add_personal_guild_note"],
                function()
    --d("Add personal note clicked", MENU_ADD_OPTION_LABEL)
                    FCONotes_AddNote(ctrl, false, false, noteType)
            end)
            --Add a remove context menu too?
            if data.FCOnote ~= nil and data.FCOnote ~= "" then
                --AddMenuItem(localizationVars.fco_notes_loc["context_menu_remove_personal_guild_note"],
                AddCustomMenuItem(locVars["context_menu_remove_personal_guild_note"],
                    function()
                        --d("Add personal note clicked", MENU_ADD_OPTION_LABEL)
                        FCONotes_AddNote(ctrl, false, true, noteType)
                end)

                --Add a "Send to officer chat" context menu for guild messages
                if noteType == FCONOTES_LIST_TYPE_GUILDS_ROSTER then
                    if DoesPlayerHaveGuildPermission(GUILD_ROSTER_MANAGER:GetGuildId(), GUILD_PERMISSION_OFFICER_CHAT_WRITE) then
                        --AddMenuItem(localizationVars.fco_notes_loc["context_menu_send_personal_guild_note_to_officer_chat"],
                        AddCustomMenuItem(locVars["context_menu_send_personal_guild_note_to_officer_chat"],
                                function()
                                    FCONotes_SendNoteToGuildOfficerChat(data.FCOnote, data.displayName, data.characterName)
                                end)
                    end
                end
            end

            ShowMenu(ctrl)
        end, 50)
    end
end

--Callback function for the OnMouseUp of guild roster rows
local function FCONotes_GuildRosterRow_OnMouseUp(control, button, upInside)
--d("GuildRosterRow - On Mouse Up: button " .. button .. ", upInside " .. tostring(upInside))
    --button 1= left mouse button / 2= right mouse button
    --Right click/mouse button 2 context menu hook part:
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        --Add context menu entry
        FCONotes_AddContextMenuEntry(control, FCONOTES_LIST_TYPE_GUILDS_ROSTER)
    end
end

local function FCONotes_FriendsListRow_OnMouseUp(control, button, upInside)
    --button 1= left mouse button / 2= right mouse button
    --Right click/mouse button 2 context menu hook part:
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        --Add context menu entry
        FCONotes_AddContextMenuEntry(control, FCONOTES_LIST_TYPE_FRIENDS_LIST)
    end
end

local function FCONotes_IgnoreListRow_OnMouseUp(control, button, upInside)
    --button 1= left mouse button / 2= right mouse button
    --Right click/mouse button 2 context menu hook part:
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        --Add context menu entry
        FCONotes_AddContextMenuEntry(control, FCONOTES_LIST_TYPE_IGNORE_LIST)
    end
end

--Callback function for the guild roster keyboard, setuprow
local function FCONotes_GuildRoster_SetupRow(guildRosterObject, control, data)
    if not preventerVars.addonLoaded --[[or guildRosterVars.scene ~= SCENE_SHOWING]] then return false end
--d("[FCONotes_GuildRoster_SetupRow] Scene: " .. tostring(guildRosterVars.scene) .. "/" .. tostring(SCENE_SHOWING) .. ", firstCall: " ..tos(guildRosterVars.firstCall))

    if not guildRosterVars.firstCall then
        if ZO_GuildRoster:IsHidden() then
--d(">guild roster is hidden!")
            return false
        end
    end

    --Do not go on if the edit note dialog is shown
    if not ZO_EditNoteDialog:IsHidden() then
        return false
    end

    --Update the note from SV
    if data ~= nil and data.displayName ~= nil and (data.FCOnote == nil or data.FCOnote == "") then
--d("GuildRoster - SetupRow: " .. tos(data.displayName) .. " (" .. tos(data.characterName) .. ")")

        local settings = FCON.settingsVars.settings
        local savedNotes
        if not settings.saveGuildPersonalNotesAccountWide then
            --Get the actual guildId
            local activeGuildId = data and data.guildId
            if activeGuildId == nil or activeGuildId <= 0 then
                --Get the active guild ID
                activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId()
            end
            if activeGuildId == nil or activeGuildId <= 0 then
                return false
            end
            savedNotes = FCON.settingsVars.settings.personalGuildNotes[activeGuildId]
        else
            savedNotes = FCON.settingsVars.settings.personalGuildNotes
        end
        local guildPersonalNote = savedNotes ~= nil and savedNotes[data.displayName]
--d(">guildPersonalNote: " ..tos(guildPersonalNote))

        data.FCOnote = guildPersonalNote or ""
    end
    FCONotes_UpdateNoteRowIcon(FCONOTES_LIST_TYPE_GUILDS_ROSTER, control, data)

    return false
end

--Callback function for the friends list keyboard, setuprow
local function FCONotes_FriendsList_SetupRow(friendListObject, control, data)
--d("[FCONotes_FriendsList_SetupRow] Scene: " .. tostring(friendsListVars.scene) .. "/" .. tostring(SCENE_SHOWING))
    if not preventerVars.addonLoaded or friendsListVars.scene == SCENE_SHOWING then return false end

    --Do not go on if the edit note dialog is shown
    if not ZO_EditNoteDialog:IsHidden() then
        return false
    end

    --Update the note from SV
    if data ~= nil and data.displayName ~= nil and (data.FCOnote == nil or data.FCOnote == "") then
        local savedNotes = FCON.settingsVars.settings.personalFriendsListNotes
        local friendPersonalNote = savedNotes ~= nil and savedNotes[data.displayName]
        data.FCOnote = friendPersonalNote or ""
    end
    FCONotes_UpdateNoteRowIcon(FCONOTES_LIST_TYPE_FRIENDS_LIST, control, data)

    return false
end

local function FCONotes_IgnoreList_SetupRow(ignoreListObject, control, data)
--d("[FCONotes_IgnoreList_SetupRow] Scene: " .. tostring(ignoreListVars.scene) .. "/" .. tostring(SCENE_SHOWING))
    if not preventerVars.addonLoaded or ignoreListVars.scene == SCENE_SHOWING then return false end

    --Do not go on if the edit note dialog is shown
    if not ZO_EditNoteDialog:IsHidden() then
        return false
    end

    --Update the note from SV
    if data ~= nil and data.displayName ~= nil and (data.FCOnote == nil or data.FCOnote == "") then
        local savedNotes         = FCON.settingsVars.settings.personalIgnoreListNotes
        local ignorePersonalNote = savedNotes ~= nil and savedNotes[data.displayName]
        data.FCOnote = ignorePersonalNote or ""
    end

    FCONotes_UpdateNoteRowIcon(FCONOTES_LIST_TYPE_IGNORE_LIST, control, data)
    return false
end


local function help()
	d(localizationVars.fco_notes_loc["chatcommands_info"])
	d(localizationVars.fco_notes_loc["chatcommands_help"])
	d(localizationVars.fco_notes_loc["chatcommands_backup"])
    d(localizationVars.fco_notes_loc["chatcommands_restore"])
end

local function backupSlashCommand(noteType)
    local feedback = FCONotes_BackupPersonalNotesNow(noteType, nil, nil)
    d(localizationVars.fco_notes_loc["chatcommands_backup_feedback_" .. tostring(feedback)])
    if feedback then
        zo_callLater(function() ReloadUI() end, 3000)
    end
end

--chat command handlers
local function command_handler(arg)
    arg = string.lower(arg)
	if(arg == "help" or arg == "list" or arg == "") then
       	help()
    --Backup
	elseif(arg == "backup") then
        backupSlashCommand(nil)
    elseif(arg == "backupguild") then
        backupSlashCommand(FCONOTES_LIST_TYPE_GUILDS_ROSTER)
    elseif(arg == "backupfriends") then
        backupSlashCommand(FCONOTES_LIST_TYPE_FRIENDS_LIST)
    elseif(arg == "backupignore") then
        backupSlashCommand(FCONOTES_LIST_TYPE_IGNORE_LIST)
    --Restore
    elseif(arg == "restore") then
        FCONotes_RestorePersonalFCONotesNow()
    elseif(arg == "restoreguild") then
        FCONotes_RestorePersonalFCONotesNow(FCONOTES_LIST_TYPE_GUILDS_ROSTER)
    elseif(arg == "restorefriends") then
        FCONotes_RestorePersonalFCONotesNow(FCONOTES_LIST_TYPE_FRIENDS_LIST)
    elseif(arg == "restoreignore") then
        FCONotes_RestorePersonalFCONotesNow(FCONOTES_LIST_TYPE_IGNORE_LIST)
    end
end

--get the main menu variable from ZOs gamepad/keyboard stuff
local function FCONotes_GetMainMenu()
    if IsInGamepadPreferredMode() then
    	return MAIN_MENU_GAMEPAD
    else
    	return MAIN_MENU_KEYBOARD
    end
end

--Callback function for the scene change
local function FCONotes_GuildRoster_OnGuildIdChanged(guildInfo)
--d("Guild roster guild id changed to: " .. guildInfo.guildId .. " (" .. preventerVars.lastguildId .. ")")
	--Change the current scene to guildRoster if not already shown
	preventerVars.dontChangeSceneVar = false
    --if the setting is enabled
    if FCON.settingsVars.settings.showAlwaysGuildRoster then
		if not preventerVars.dontChangeSceneVar and not SCENE_MANAGER:IsShowing("guildRoster") then
			local mainMenuVar = FCONotes_GetMainMenu()
        	mainMenuVar:ShowScene("guildRoster")
		end
	end

	--Change the guild notes, only if the guild changed
    if preventerVars.lastguildId == -1 or preventerVars.lastguildId ~= guildInfo.guildId then
        preventerVars.lastguildId = guildInfo.guildId
        --Is the current scene the guild roster? The scene manager will not reckognize that the guild was changed so
        --we need to manually call the function to read the current guild roster notes here
        zo_callLater(function()
            if SCENE_MANAGER.currentScene.name == "guildRoster" then
                if not FCONotes_GetListData(FCONOTES_LIST_TYPE_GUILDS_ROSTER, -1, true, { guildId = guildInfo.guildId }) then
                    --d("[ERROR - FCO Notes] Guild roster data could not be read!")
                end
            end
        end, 50)
    end
end

--Global function to copy the control below the mouse cursor, for the keybinds
function FCONotes_CopyNameUnderControl()
    local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
    local mocName = mouseOverControl:GetName()
    if mocName == nil then return end
--d("[FCONotes]mocName: " ..tos(mocName))
    local noteType
    if (mocName:find("^ZO_GuildRosterList%dRow%d+DisplayName*") or mocName:find("^ZO_GuildRosterList%dRow%d%d+DisplayName*")) then
        noteType = FCONOTES_LIST_TYPE_GUILDS_ROSTER
    --ZO_KeyboardFriendsListList1Row1DisplayName
    elseif (mocName:find("^ZO_KeyboardFriendsListList%dRow%d+DisplayName*") or mocName:find("^ZO_KeyboardFriendsListList%dRow%d%d+DisplayName*")) then
        noteType = FCONOTES_LIST_TYPE_FRIENDS_LIST
    --ZO_KeyboardIgnoreListList1Row1
    elseif (mocName:find("^ZO_KeyboardIgnoreListList%dRow%d") or mocName:find("^ZO_KeyboardIgnoreListList%dRow%d%d")) then
        noteType = FCONOTES_LIST_TYPE_IGNORE_LIST
        mouseOverControl = mouseOverControl:GetNamedChild("DisplayName")
    end
    if noteType == nil then return end

    FCONotes_AddNote(mouseOverControl, true, false, noteType)
end

--Function for the mouse over keybinds at guild roster member rows
local function FCONotes_GetMouseOverGuildMembers(mouseOverControl)
	if (not mouseOverControl) then return end
    if (not ZO_GuildRoster:IsHidden() and FCON.settingsVars.settings.useKeybind) then
        KEYBIND_STRIP:AddKeybindButtonGroup(keystripVars.GuildRosterAddPersonalNote)
    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripVars.GuildRosterAddPersonalNote)
    end
end

--Callback function for the event if a guild member gets added
local function FCONotes_OnGuildMemberAdded(eventCode, guildId, displayName)
--d("[GuildMemberAdded] guildId: " .. guildId .. ", displayName: " .. displayName)
    if guildId ~= nil and displayName ~= nil and displayName ~= "" then
        --Reorganize the notes now
--d("Reorganize notes now")
        FCONotes_GetListData(FCONOTES_LIST_TYPE_GUILDS_ROSTER, -1, true, { guildId = guildId })
    end
end

--Callback function for the event if a guild member gets removed
local function FCONotes_OnGuildMemberRemoved(eventCode, guildId, displayName, characterName)
--d("[GuildMemberRemoved] guildId: " .. guildId .. ", displayName: " .. displayName .. ", characterName: " .. characterName)
    if not FCON.settingsVars.settings.saveGuildPersonalNotesAccountWide
       and guildId ~= nil
       and displayName ~= nil and displayName ~= "" then
        --Remove the note about this account in this guild
        if FCON.settingsVars.settings.personalGuildNotes[guildId] ~= nil then
            FCON.settingsVars.settings.personalGuildNotes[guildId][displayName] = nil
        end
    end
end

--PreHook function for the main menu scene group bar buttons
local function FCONotes_MainMenuSceneGroupBarButtonClick(ctrl, button, upInside)
	--d("[FCO Notes] FCONotes_MainMenuSceneGroupBarButtonClick: " .. ctrl:GetName())
    --if the setting is enabled
    if not FCON.settingsVars.settings.showAlwaysGuildRoster then return false end
    --Button 1 is pressed and mouse is above the control?
    if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
   		preventerVars.buttonPressed = true
		preventerVars.dontChangeSceneVar = true
    end
end

--Callback function for the guild ranks, home and history scenes
local function FCONotes_Guild_Scenes_Callback(oldState, newState)
    --if the setting is enabled
    local settings = FCON.settingsVars.settings
    if not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] then return end
    if not settings.showAlwaysGuildRoster then return false end

	--d("[".. SCENE_MANAGER.currentScene.name .."] State: " .. tostring(newState))
	if newState == SCENE_SHOWING then
		--Reset the button pressed preventer variable
    	if preventerVars.buttonPressed then preventerVars.buttonPressed = false end

    --If guild home is shown the first time, open the guild roster automatically instead of showing the home scene
    elseif newState == SCENE_SHOWN then
        --PreHook the buttons of the guild scene, but only once
    	if not preventerVars.sceneButtonsPreHook then
            --PreeHook the mouse OnMouseUp handler for the main menu group bar buttons at the guild scenes
            ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton1, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
            --ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton2, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
            ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton3, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
            ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton5, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
			--Support for GuildEvents addon
            if ZO_MainMenuSceneGroupBarButton6 ~= nil then
	            ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton6, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
			end
            preventerVars.sceneButtonsPreHook = true
        end
        --PreHook the buttons of the guild heraldric scene, but only once
    	if not preventerVars.sceneButtonsHeraldricPreHook then
			--Guild heraldric
			if ZO_MainMenuSceneGroupBarButton4 ~= nil then
				ZO_PreHookHandler(ZO_MainMenuSceneGroupBarButton4, "OnMouseUp", FCONotes_MainMenuSceneGroupBarButtonClick)
	            preventerVars.sceneButtonsHeraldricPreHook = true
			end
		end
		--Change the current scene to guildRoster if not one of the guild buttons was clicked manually
		if not preventerVars.dontChangeSceneVar and not SCENE_MANAGER:IsShowing("guildRoster") then
			local mainMenuVar = FCONotes_GetMainMenu()
        	mainMenuVar:ShowScene("guildRoster")
        end

    elseif newState == SCENE_HIDING then
        if not preventerVars.buttonPressed then
			preventerVars.dontChangeSceneVar = false
        end
    end
end

local function FCONotes_Friend_Scenes_Callback(oldState, newState)
    --if the setting is enabled
    if not FCON.settingsVars.settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] then return end
    friendsListVars.scene = newState
end

local function FCONotes_Ignore_Scenes_Callback(oldState, newState)
    --if the setting is enabled
    if not FCON.settingsVars.settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] then return end
    ignoreListVars.scene = newState
end


--Hooks
local function hook_functions()
    local enableNotes = FCON.settingsVars.settings.enableNotes
    if enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] then
        --======== GUILD EVENTS - Additional addon =================================
        --Register a callback function for the guild events scene from the GuildEvents addon
        if GUILD_EVENTS_SCENE ~= nil then
            GUILD_EVENTS_SCENE:RegisterCallback("StateChange", FCONotes_Guild_Scenes_Callback)
        end
        --======== GUILD HOME ======================================================
        --Register a callback function for the guild home scene
        GUILD_HOME_SCENE:RegisterCallback("StateChange", FCONotes_Guild_Scenes_Callback)
        --======== GUILD RANKS =====================================================
        --Register a callback function for the guild home scene
        GUILD_RANKS_SCENE:RegisterCallback("StateChange", FCONotes_Guild_Scenes_Callback)
        --======== GUILD HISTORY ===================================================
        --Register a callback function for the guild home scene
        GUILD_HISTORY_KEYBOARD_SCENE:RegisterCallback("StateChange", FCONotes_Guild_Scenes_Callback)
        --======== GUILD HERALDRY ==================================================
        --Register a callback function for the guild home scene
        GUILD_HERALDRY_SCENE:RegisterCallback("StateChange", FCONotes_Guild_Scenes_Callback)
        --======== GUILD ROSTER ====================================================
        --Register a callback function for the guild roster scene
        GUILD_ROSTER_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            --d("[GUILD ROSTER SCENE] State: " .. tostring(newState))
            --Guild roster is starting to show
            guildRosterVars.scene = newState

            if newState == SCENE_SHOWING then
                --Get all the data from the guild roster rows
                --if not FCONotes_GetListData(FCONOTES_LIST_TYPE_GUILDS_ROSTER, -1, true, nil) then
                --d("[ERROR - FCO Notes] Guild roster data could not be read!")
                --end
                --Guild roster was shown at least once now so update the variable "first call" to false
                if guildRosterVars.firstCall then
                    guildRosterVars.firstCall = false
                end

            elseif newState == SCENE_SHOWN then
                --Reset the preventer variable
                preventerVars.dontChangeSceneVar = false
                preventerVars.buttonPressed		 = false

            elseif newState == SCENE_HIDING then
                --Hide possibly shown tooltips
                ZO_Tooltips_HideTextTooltip()
            end
        end)

        --PreHook the MouseEnter and Exit functions for the guild roster list rows + names in the rows
        ZO_PreHook("ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter", function(control)
            --d("Mouse enter guild roster name: " .. control:GetName())
            FCONotes_GetMouseOverGuildMembers(control)
        end)
        ZO_PreHook("ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit", function(control)
            --d("Mouse exit guild roster  name: " .. control:GetName())
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripVars.GuildRosterAddPersonalNote)
        end)
        ZO_PreHook("ZO_KeyboardGuildRosterRow_OnMouseExit", function(control)
            --d("Mouse exit guild roster row: " .. control:GetName())
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripVars.GuildRosterAddPersonalNote)
        end)

        --======== PreHook Guild ID changed =======================================================================
        ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", FCONotes_GuildRoster_OnGuildIdChanged)
        --Setup function of the guild roster keyboard row: Add the new note control
        SecurePostHook(GUILD_ROSTER_KEYBOARD, "SetupRow", FCONotes_GuildRoster_SetupRow)

        --======== PreHook GuildRoster Row OnMouseUp =======================================================================
        --Pre-Hook the handler "OnMouseUp" event for the rowControl of each guild roster row to
        --add a context menu entry
        ZO_PreHook("ZO_KeyboardGuildRosterRow_OnMouseUp", FCONotes_GuildRosterRow_OnMouseUp)
    end


    if enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] then
        --======== KEYBOARD FRIENDS LIST ===================================================================================
        --Register a callback function for the friends list scene
        FRIENDS_LIST_SCENE:RegisterCallback("StateChange", FCONotes_Friend_Scenes_Callback)

        --Setup function of the friendslist row: Add the new note control
        SecurePostHook(FRIENDS_LIST, "SetupRow", FCONotes_FriendsList_SetupRow)

        --Pre-Hook the handler "OnMouseUp" event for the rowControl
        ZO_PreHook("ZO_FriendsListRow_OnMouseUp", FCONotes_FriendsListRow_OnMouseUp)
    end


    if enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] then
        --======== KEYBOARD IGNORE LIST ====================================================================================
        --Register a callback function for the ignore list scene
        IGNORE_LIST_SCENE:RegisterCallback("StateChange", FCONotes_Ignore_Scenes_Callback)

        --Setup function of the friendslist row: Add the new note control
        SecurePostHook(IGNORE_LIST, "SetupIgnoreEntry", FCONotes_IgnoreList_SetupRow)

        --Pre-Hook the handler "OnMouseUp" event for the rowControl
        ZO_PreHook("ZO_IgnoreListRow_OnMouseUp", FCONotes_IgnoreListRow_OnMouseUp)
    end
end

local function buildTextureIdsList()
    FCON.textureVars.MARKER_TEXTURES_IDS = {}
    local MARKER_TEXTURES_IDS = FCON.textureVars.MARKER_TEXTURES_IDS
    for k, _ in ipairs(textureVars.MARKER_TEXTURES) do
        MARKER_TEXTURES_IDS[k] = tos(k)
    end
    return MARKER_TEXTURES_IDS
end

local function getTextureIdByPath(texturePath)
    local markerTextures = FCON.textureVars.MARKER_TEXTURES
    for k, v in ipairs(markerTextures) do
        if v == texturePath then return k end
    end
    return
end

-- Build the menu
local function BuildAddonMenu()
	local panelData = {
		type 				= 'panel',
		name   				= addonVars.addonNameMenu,
		displayName 		= addonVars.addonNameMenuDisplay,
		author 				= addonVars.addonAuthor,
		version 			= addonVars.addonVersionOptions,
		registerForRefresh  = true,
		registerForDefaults = true,
		slashCommand = "/fcons",
	}

    local defaults = FCON.settingsVars.defaults
    local settings = FCON.settingsVars.settings
    local locVars = localizationVars.fco_notes_loc

	local languageOptions = {
	    [1] = locVars["options_language_dropdown_selection1"],
	    [2] = locVars["options_language_dropdown_selection2"],
	    [3] = locVars["options_language_dropdown_selection3"],
	    [4] = locVars["options_language_dropdown_selection4"],
	    [5] = locVars["options_language_dropdown_selection5"],
	}
    local languageOptionsValues = {
        1, 2, 3, 4, 5
    }
    local savedVariablesOptions = {
    	[1] = locVars["options_savedVariables_dropdown_selection1"],
        [2] = locVars["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
        1, 2,
    }

    local texturesIdsList = buildTextureIdsList()

    -- Build options menu parts
    local FCONotesSettingsPanel = FCON.LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)

    --Notes icon preview: Update colors at first open
    local CallBackLAMPanelControlsCreated, Preview1
    CallBackLAMPanelControlsCreated = function(panel)
        if panel == FCONotesSettingsPanel then
            --Icon FCONOTES_LIST_TYPE_GUILDS_ROSTER
            FCONotes_Settings_NoteGuildIconPreview:SetColor(ZO_ColorDef:New(settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color))
            FCONotes_Settings_NoteGuildIconPreview:SetIconSize(settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].size)
            FCONotes_Settings_NoteGuildIconPreview.label:SetText(locVars["options_icon1_texture"] .. ": " .. settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].texture)
            --Icon FCONOTES_LIST_TYPE_FRIENDS_LIST
            FCONotes_Settings_NoteFriendsIconPreview:SetColor(ZO_ColorDef:New(settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color))
            FCONotes_Settings_NoteFriendsIconPreview:SetIconSize(settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].size)
            FCONotes_Settings_NoteFriendsIconPreview.label:SetText(locVars["options_icon2_texture"] .. ": " .. settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].texture)
            --Icon FCONOTES_LIST_TYPE_IGNORE_LIST
            FCONotes_Settings_NoteIgnoreIconPreview:SetColor(ZO_ColorDef:New(settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color))
            FCONotes_Settings_NoteIgnoreIconPreview:SetIconSize(settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].size)
            FCONotes_Settings_NoteIgnoreIconPreview.label:SetText(locVars["options_icon3_texture"] .. ": " .. settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].texture)

            CALLBACK_MANAGER:UnregisterCallback("LAM-RefreshPanel", CallBackLAMPanelControlsCreated)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CallBackLAMPanelControlsCreated)

	local optionsTable =
    {
		{
			type = 'description',
			text = locVars["options_description"],
		},
--==============================================================================
		{
        	type = 'header',
        	name = locVars["options_header1"],
        },
		{
			type = 'dropdown',
			name = locVars["options_language"],
			tooltip = locVars["options_language_TT"],
			choices = languageOptions,
            choicesValues = languageOptionsValues,
            getFunc = function()
                return FCON.settingsVars.defaultSettings.language
            end,
            setFunc = function(value)
                FCON.settingsVars.defaultSettings.language = value
                --Tell the settings that you have manually chosen the language and want to keep it
                --Read in function Localization() after ReloadUI()
                settings.languageChoosen = true
                ReloadUI()
            end,
            warning = locVars["options_language_description1"],
		},
		{
			type = 'dropdown',
			name = locVars["options_savedvariables"],
			tooltip = locVars["options_savedvariables_TT"],
			choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCON.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                FCON.settingsVars.defaultSettings.saveMode = value
                ReloadUI()
            end,
            warning = locVars["options_language_description1"],
            --requiresReload = true,
		},

        --==============================================================================
        {
            type = 'header',
            name = locVars["options_header_guild_roster"],
        },

        {
            type = "checkbox",
            name = locVars["options_enable_notes_guild_roster"],
            tooltip = locVars["options_enable_notes_guild_roster_TT"],
            getFunc = function() return settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end,
            setFunc = function(value) settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] = value
            end,
            default = defaults.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER],
            width="full",
            requiresReload = true,
        },

        {
            type = "checkbox",
            name = locVars["options_always_open_guild_roster"],
            tooltip = locVars["options_always_open_guild_roster_TT"],
            getFunc = function() return settings.showAlwaysGuildRoster end,
            setFunc = function(value) settings.showAlwaysGuildRoster = value
            end,
            default = defaults.showAlwaysGuildRoster,
            width="full",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },

        {
            type = "checkbox",
            name = locVars["options_save_guild_notes_account_wide"],
            tooltip = locVars["options_save_guild_notes_account_wide_TT"],
            getFunc = function() return settings.saveGuildPersonalNotesAccountWide end,
            setFunc = function(value) settings.saveGuildPersonalNotesAccountWide = value
                --Update all the values and icons now
                local activeGuildId = GUILD_ROSTER_MANAGER:GetGuildId()
                FCONotes_GetListData(FCONOTES_LIST_TYPE_GUILDS_ROSTER, -1, true, { guildId = activeGuildId })
            end,
            default = defaults.saveGuildPersonalNotesAccountWide,
            width="full",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },

        {
            type = "colorpicker",
            name = locVars["options_icon1_color"],
            tooltip = locVars["options_icon1_color_TT"],
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color.r, settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color.g, settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color.b, settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color.a end,
            setFunc = function(r,g,b,a)
                settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                FCONotes_Settings_NoteGuildIconPreview:SetColor(ZO_ColorDef:New(r,g,b,a))
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].color,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },
        {
            type = "iconpicker",
            name = locVars["options_icon1_texture"],
            tooltip = locVars["options_icon1_texture_TT"],
            choices = textureVars.MARKER_TEXTURES,
            choicesTooltips = texturesIdsList,
            getFunc = function() return textureVars.MARKER_TEXTURES[settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].texture] end,
            setFunc = function(texturePath)
                local textureId = getTextureIdByPath(texturePath)
                if textureId ~= 0 then
                    settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].texture = textureId
                    FCONotes_Settings_NoteGuildIconPreview.label:SetText(locVars["options_icon1_texture"] .. ": " .. textureId)
                end
            end,
            maxColumns = 6,
            visibleRows = 5,
            iconSize = settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].size,
            width = "half",
            default = textureVars.MARKER_TEXTURES[defaults.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].texture],
            reference = "FCONotes_Settings_NoteGuildIconPreview",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_size"],
            tooltip = locVars["options_icon1_size_TT"],
            min = 12,
            max = 64,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].size end,
            setFunc = function(size)
                settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].size = size
                --Preview1:SetDimensions(size, size)
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].size,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },

        {
            type = "slider",
            name = locVars["options_icon1_x"],
            tooltip = locVars["options_icon1_x_TT"],
            min = -15,
            max = 850,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.x end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.x = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.x,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_y"],
            tooltip = locVars["options_icon1_y_TT"],
            min = -10,
            max = 10,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.y end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.y = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_GUILDS_ROSTER].position.y,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] end
        },

        --==============================================================================================================
        {
            type = 'header',
            name = locVars["options_header_friends_list"],
        },

        {
            type = "checkbox",
            name = locVars["options_enable_notes_friends_list"],
            tooltip = locVars["options_enable_notes_friends_list_TT"],
            getFunc = function() return settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end,
            setFunc = function(value) settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] = value
            end,
            default = defaults.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST],
            width="full",
            requiresReload = true,
        },

        {
            type = "colorpicker",
            name = locVars["options_icon1_color"],
            tooltip = locVars["options_icon1_color_TT"],
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color.r, settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color.g, settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color.b, settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color.a end,
            setFunc = function(r,g,b,a)
                settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                FCONotes_Settings_NoteFriendsIconPreview:SetColor(ZO_ColorDef:New(r,g,b,a))
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].color,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end
        },
        {
            type = "iconpicker",
            name = locVars["options_icon2_texture"],
            tooltip = locVars["options_icon2_texture_TT"],
            choices = textureVars.MARKER_TEXTURES,
            choicesTooltips = texturesIdsList,
            getFunc = function() return textureVars.MARKER_TEXTURES[settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].texture] end,
            setFunc = function(texturePath)
                local textureId = getTextureIdByPath(texturePath)
                if textureId ~= 0 then
                    settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].texture = textureId
                    FCONotes_Settings_NoteFriendsIconPreview.label:SetText(locVars["options_icon2_texture"] .. ": " .. textureId)
                end
            end,
            maxColumns = 6,
            visibleRows = 5,
            iconSize = settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].size,
            width = "half",
            default = textureVars.MARKER_TEXTURES[defaults.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].texture],
            reference = "FCONotes_Settings_NoteFriendsIconPreview",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_size"],
            tooltip = locVars["options_icon1_size_TT"],
            min = 12,
            max = 64,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].size end,
            setFunc = function(size)
                settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].size = size
                --Preview1:SetDimensions(size, size)
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].size,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end
        },

        {
            type = "slider",
            name = locVars["options_icon1_x"],
            tooltip = locVars["options_icon1_x_TT"],
            min = -15,
            max = 850,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.x end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.x = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.x,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_y"],
            tooltip = locVars["options_icon1_y_TT"],
            min = -10,
            max = 10,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.y end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.y = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_FRIENDS_LIST].position.y,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_FRIENDS_LIST] end
        },

        --==============================================================================================================
        {
            type = 'header',
            name = locVars["options_header_ignore_list"],
        },

        {
            type = "checkbox",
            name = locVars["options_enable_notes_ignore_list"],
            tooltip = locVars["options_enable_notes_ignore_list_TT"],
            getFunc = function() return settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end,
            setFunc = function(value) settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] = value
            end,
            default = defaults.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST],
            width="full",
            requiresReload = true,
        },

        {
            type = "colorpicker",
            name = locVars["options_icon1_color"],
            tooltip = locVars["options_icon1_color_TT"],
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color.r, settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color.g, settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color.b, settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color.a end,
            setFunc = function(r,g,b,a)
                settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                FCONotes_Settings_NoteIgnoreIconPreview:SetColor(ZO_ColorDef:New(r,g,b,a))
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].color,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end
        },
        {
            type = "iconpicker",
            name = locVars["options_icon3_texture"],
            tooltip = locVars["options_icon3_texture_TT"],
            choices = textureVars.MARKER_TEXTURES,
            choicesTooltips = texturesIdsList,
            getFunc = function() return textureVars.MARKER_TEXTURES[settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].texture] end,
            setFunc = function(texturePath)
                local textureId = getTextureIdByPath(texturePath)
                if textureId ~= 0 then
                    settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].texture = textureId
                    FCONotes_Settings_NoteIgnoreIconPreview.label:SetText(locVars["options_icon3_texture"] .. ": " .. textureId)
                end
            end,
            maxColumns = 6,
            visibleRows = 5,
            iconSize = settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].size,
            width = "half",
            default = textureVars.MARKER_TEXTURES[defaults.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].texture],
            reference = "FCONotes_Settings_NoteIgnoreIconPreview",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_size"],
            tooltip = locVars["options_icon1_size_TT"],
            min = 12,
            max = 64,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].size end,
            setFunc = function(size)
                settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].size = size
                --Preview1:SetDimensions(size, size)
            end,
            width="half",
            default = defaults.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].size,
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end
        },

        {
            type = "slider",
            name = locVars["options_icon1_x"],
            tooltip = locVars["options_icon1_x_TT"],
            min = -15,
            max = 850,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.x end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.x = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.x,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end
        },
        {
            type = "slider",
            name = locVars["options_icon1_y"],
            tooltip = locVars["options_icon1_y_TT"],
            min = -10,
            max = 10,
            getFunc = function() return settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.y end,
            setFunc = function(offset)
                settings.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.y = offset
            end,
            default = defaults.icon[FCONOTES_LIST_TYPE_IGNORE_LIST].position.y,
            width="half",
            disabled = function() return not settings.enableNotes[FCONOTES_LIST_TYPE_IGNORE_LIST] end
        },
	}
	FCON.LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end

local function Localization()
    --Was localization already done during keybindings? Then abort here
    if preventerVars.KeyBindingTexts == true and preventerVars.gLocalizationDone == true then return end

    local settingsVars = FCON.settingsVars
    if settingsVars == nil then return end

    --Fallback to english
    if FCON.settingsVars.defaultSettings.language == nil or (FCON.settingsVars.defaultSettings.language < 1 and FCON.settingsVars.defaultSettings.language > 5) then
        FCON.settingsVars.defaultSettings.language = 1
    end
    --Is the standard language english set?
    if preventerVars.KeyBindingTexts == true or (FCON.settingsVars.defaultSettings.language == 1 and FCON.settingsVars.settings.languageChoosen == false) then
        local lang = GetCVar("language.2")
        --Check for supported languages
        if lang == "de" then
            FCON.settingsVars.defaultSettings.language = 2
        elseif lang == "en" then
            FCON.settingsVars.defaultSettings.language = 1
        elseif lang == "fr" then
            FCON.settingsVars.defaultSettings.language = 3
        elseif lang == "es" then
            FCON.settingsVars.defaultSettings.language = 4
        elseif lang == "it" then
            FCON.settingsVars.defaultSettings.language = 5
        else
            FCON.settingsVars.defaultSettings.language = 1
        end
    end
    localizationVars = FCON.localizationVars
    localizationVars.fco_notes_loc = FCON.fco_notesloc[FCON.settingsVars.defaultSettings.language]

    preventerVars.gLocalizationDone = true
end

local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fconotes"]	= command_handler
	SLASH_COMMANDS["/fcon"]		= command_handler
end

--Callback function for player activated event
local function FCONotes_PlayerActivated(event)
    EVENT_MANAGER:UnregisterForEvent(addonName, event)

    --Set the variable for the guild roster: It's the first time the next time we open the guild roster
    guildRosterVars.firstCall = true

    --Load the hooks
    hook_functions()

    --Show the menu
    BuildAddonMenu()

    --Register for event if a guild member gets added
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_MEMBER_ADDED, FCONotes_OnGuildMemberAdded)
    --Register for event if a guild member gets removed
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GUILD_MEMBER_REMOVED, FCONotes_OnGuildMemberRemoved)

    --Update the current guild ID with NONE
    preventerVars.lastguildId = -1

    --Addon is finished with loading now
    preventerVars.addonLoaded = true
end

local function LoadSavedVariables()
    if FCON.svLoaded then
        if FCON.settingsVars.settings == nil then
            FCON.svLoaded = false
        else
            return
        end
    end

    local svName = addonVars.savedVariablesName
    local svVersion = addonVars.addonVersion
    local defaultSettingsDefaults = FCON.settingsVars.defaultSettingsDefaults
    local defaults = FCON.settingsVars.defaults

    --Load the user's FCON.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
    FCON.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svName, 999, "SettingsForAll", defaultSettingsDefaults)

    --Check, by help of basic version 999 FCON.settingsVars.settings, if the FCON.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCON.settingsVars.settings now
    if FCON.settingsVars.defaultSettings.saveMode == 1 then
        FCON.settingsVars.settings = ZO_SavedVars:New(svName, svVersion , "Settings", defaults )
    else
        FCON.settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, "Settings", defaults)
    end

    FCON.svLoaded = true
end

--Addon got loaded
local function FCONotes_Loaded(eventCode, addOnNameOfEachAddonLoaded)
    if addOnNameOfEachAddonLoaded ~= addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    LoadSavedVariables()
--=============================================================================================================

    --Backup the actual personal guild, friend and ignore list notes
    FCONotes_BackupPersonalNotesNow(nil, nil, nil)

    -- Set Localization
	preventerVars.KeyBindingTexts = false
    Localization()

    -- Register slash commands
    RegisterSlashCommands()

    --Add keybindStrip info
    keystripVars.GuildRosterAddPersonalNote = {
        {
            name = localizationVars.fco_notes_loc["SI_BINDING_NAME_FCO_NOTES_ADD"],
            keybind = "FCO_NOTES_ADD",
            callback = function() FCONotes_CopyNameUnderControl() end,
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
        }
    }

    --Player activated event as alla ddons are loaded and the UI is ready
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCONotes_PlayerActivated)
end

-- Register the event "addon loaded" for this addon
local function FCONotes_Initialized()
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCONotes_Loaded)
end

--========== GLOBAL FUNCTIONS ==================================================

--Global function to get text for the keybindings etc.
function FCONotes_GetLocText(textName, isKeybindingText)
	isKeybindingText = isKeybindingText or false

    preventerVars.KeyBindingTexts = isKeybindingText

	--Do the localization now
   	Localization()
    localizationVars = FCON.localizationVars
    local fcoNotesLoc = localizationVars.fco_notes_loc

	if textName == nil or fcoNotesLoc == nil or fcoNotesLoc[textName] == nil then return "" end
   	return fcoNotesLoc[textName]
end


--========== API FUNCTIONS ==================================================
--Set the guild member's note via guildId and displayname
--Respecting the setting saveGuildPersonalNotesAccountWide (saving notes for the same account the same in each guild, or not)
--number guildId                    The unique guildId
--String displayName                The @accountName
--boolean useDialog                 true: Show dialog to enter text -> Please read parameter "callbackChangeFunc" below! / false: Directly update FCONotes SavedVariables
--function callbackChangeFunc       Attention: If "useDialog" false: This parameter will not be used!
--                                  A callback function called as the dialog's "Accept" button was used.
--                                  If useDialog true:
--                                  The function callbackChangedFunc will be called. You can specify your code to run
--                                  The function parameters are:
--                                  displayName p_displayName, String p_noteText
--returns Boolean noteWasChanged    If useDialog==false and note was updated in SavedVariables -> Will return true
--                                  If useDialog==false and note was not updated in SavedVariables -> Will return false
--                                  If useDialog==true and callbackChangedFunc==nil (standard calbackFunc was used) and note was updated in SavedVariables -> Will return true
--                                  If useDialog==true and callbackChangedFunc~=nil and is function -> your calbackFunc was used -> Will return true
function FCON.SetGuildMemberNote(guildId, displayName, guildMemberNoteText, useDialog, callbackChangedFunc)
    useDialog = useDialog or false
    guildMemberNoteText = guildMemberNoteText or ""
    local retVar = false

    --Update the SavedVariables
    LoadSavedVariables()
    if not FCON.settingsVars.settings.enableNotes[FCONOTES_LIST_TYPE_GUILDS_ROSTER] then return false end

    --Callback function for the notes dialog "Accept" button
    local standardCallBackFunc = function(p_displayName, p_noteText)
        retVar = setPersonalNoteToSV(FCONOTES_LIST_TYPE_GUILDS_ROSTER, p_noteText, p_displayName, { guildId = guildId })
    end
    if not callbackChangedFunc or type(callbackChangedFunc) ~= "function" then
        callbackChangedFunc =  standardCallBackFunc
    end

    --Do not show a dialog to input the memberNote?
    if not useDialog then
       standardCallBackFunc(guildId, displayName, guildMemberNoteText)
    else
    --Show a dialog to input the memberNote
        ZO_Dialogs_ShowDialog("EDIT_NOTE", {displayName = displayName, note = guildMemberNoteText, changedCallback = callbackChangedFunc})
        --Custom callbackFunc was provided?
        if callbackChangedFunc ~= standardCallBackFunc then
            retVar = true
        end
    end
    return retVar
end


--Get the guild member's note via guildId and displayname
--Respecting the setting saveGuildPersonalNotesAccountWide (saving notes for the same account the same in each guild, or not)
--number guildId                        The unique guildId
--String displayName                    The @accountName
--returns String noteText
function FCON.GetGuildMemberNote(guildId, displayName)
    LoadSavedVariables()
    return getPersonalNoteFromSV(FCONOTES_LIST_TYPE_GUILDS_ROSTER, displayName, { guildId = guildId }) or ""
end

function FCON.GetFriendsListNote(displayName)
    LoadSavedVariables()
    return getPersonalNoteFromSV(FCONOTES_LIST_TYPE_FRIENDS_LIST, displayName, nil) or ""
end

function FCON.GetIgnoreListNote(displayName)
    LoadSavedVariables()
    return getPersonalNoteFromSV(FCONOTES_LIST_TYPE_IGNORE_LIST, displayName, nil) or ""
end


--========== Initialize the addon FUNCTIONS ==================================================
-- Call the start function for this addon
FCONotes_Initialized()
