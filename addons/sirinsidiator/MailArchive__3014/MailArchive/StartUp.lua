local ADDON_NAME = "MailArchive"

local callbackObject = ZO_CallbackObject:New()
local MA = {
    class = {},
    data = {},
    callback = {},
    internal = {
        callbackObject = callbackObject,
        logger = LibDebugLogger(ADDON_NAME),
    }
}
_G[ADDON_NAME] = MA

function MA.internal:FireCallbacks(...)
    return callbackObject:FireCallbacks(...)
end

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

local internal = MA.internal
internal.UnregisterForEvent = UnregisterForEvent
internal.RegisterForEvent = RegisterForEvent
internal.WrapFunction = WrapFunction
-----------------------------------------------------------------------------------------

local function GetOrCreateArchive()
    local key = string.format("%s%s", GetWorldName(), GetDisplayName())
    MailArchive_Data = MailArchive_Data or {}
    MailArchive_Data[key] = MailArchive_Data[key] or {}
    return MailArchive_Data[key]
end

OnAddonLoaded(function()
    local logger = internal.logger

    local archive = GetOrCreateArchive()
    MA.archive = archive

    ZO_PreHook("ZO_MailInboxShared_PopulateMailData", function(dataTable, mailId)
        if dataTable.archived then return true end
    end)

    local function SetTimeReceived(dataTable)
        dataTable._maTimeReceived = GetTimeStamp() - dataTable.secsSinceReceived
    end

    SecurePostHook("ZO_MailInboxShared_PopulateMailData", SetTimeReceived)
    SecurePostHook("ZO_MailInboxShared_PopulateGuildMailData", SetTimeReceived)

    SecurePostHook(MAIL_INBOX, "OnMailReadable", function(self, mailId)
        local mailId64 = id64(mailId)
        if not mailId64 or mailId64 ~= id64(self.mailId) then return end

        local archived = archive[mailId64.string] or {
            numAttachments = 0,
            attachedMoney = 0,
            codAmount = 0
        }
        if archived.archived then return end

        local data = self:GetMailData(mailId, self.isMailFromGuild)
        archived.mailId = mailId64.string
        archived.subject = data.subject
        archived.returned = data.returned
        archived.senderDisplayName = data.senderDisplayName
        archived.senderCharacterName = data.senderCharacterName
        if data.numAttachments > archived.numAttachments then
            archived.numAttachments = data.numAttachments
            archived.attachmentData = {}
            archived.attachmentLink = {}
            for i = 1, data.numAttachments do
                archived.attachmentData[i] = {GetAttachedItemInfo(mailId, i)}
                archived.attachmentLink[i] = GetAttachedItemLink(mailId, i)
            end
        end
        if data.attachedMoney > archived.attachedMoney then
            archived.attachedMoney = data.attachedMoney
        end
        if data.codAmount > archived.codAmount then
            archived.codAmount = data.codAmount
        end
        archived.timeReceived = data._maTimeReceived
        archived.fromSystem = data.fromSystem
        archived.fromCS = data.fromCS
        archived.body = ReadMail(data.mailId)
        if data.fromGuild then
            archived.fromGuild = data.fromGuild
            archived.chatCategory = data.chatCategory
            archived.guildId = data.guildId
        end
        archive[mailId64.string] = archived
        logger:Verbose("updated mail data")
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.selectionKeybindStripDescriptor)
    end)

    local descriptors = MAIL_INBOX.selectionKeybindStripDescriptor
    descriptors[#descriptors + 1] = {
        name = function()
            local mailId64 = id64(MAIL_INBOX.mailId)
            if mailId64 and archive[mailId64.string] ~= nil and archive[mailId64.string].archived then
                return "Unarchive Mail"
            end
            return "Archive Mail"
        end,
        keybind = "UI_SHORTCUT_QUINARY",
    
        callback = function()
            logger:Verbose("toggle archive mail")
            local mailId64 = id64(MAIL_INBOX.mailId)
            if mailId64 == nil then return end
            local archived = archive[mailId64.string]
            archived.archived = not archived.archived
            MAIL_INBOX:OnInboxUpdate()
            KEYBIND_STRIP:UpdateKeybindButtonGroup(MAIL_INBOX.selectionKeybindStripDescriptor)
        end,

        visible = function()
            if MAIL_INBOX.mailId then
                local mailId64 = id64(MAIL_INBOX.mailId)
                if mailId64 and archive[mailId64.string] ~= nil then
                    return true
                end
            end
            return false
        end
    }

    logger:Verbose("clean up unarchive mail") -- TODO only remove mails that no longer exist
    local numCleaned = 0
    for key, archived in pairs(archive) do
        if not archived.archived then
            archive[key] = nil
            numCleaned = numCleaned + 1
        end
    end
    logger:Verbose("removed %d unarchive mails", numCleaned)

    local tree = MAIL_INBOX.navigationTree
    internal.archiveMailNodeData = { text = "Archived Mail", unreadData = {} }
    internal.archiveMailEmptyNodeData = { text = "You have no archived mail." }

    local ARCHIVED_MAIL_ENTRY_SORT_KEYS =
    {
        ["secsSinceReceived"]  = { numeric = true, tiebreaker = "mailId" },
        ["mailId"] = { isId64 = true },
    }
    local ARCHIVED_MAIL_ENTRY_FIRST_SORT_KEY = "secsSinceReceived"

    local function MailComparator(mailData1, mailData2)
        return ZO_TableOrderingFunction(mailData1, mailData2, ARCHIVED_MAIL_ENTRY_FIRST_SORT_KEY, ARCHIVED_MAIL_ENTRY_SORT_KEYS, ZO_SORT_ORDER_UP)
    end

    local mailDataCache = {}
    internal.mailDataCache = mailDataCache

    local originalReadMail = ReadMail
    function ReadMail(mailId, ...)
        local mailId64 = id64(mailId)
        if mailId64 and mailDataCache[mailId64.string] then
            logger:Verbose("return archive mail body")
            return mailDataCache[mailId64.string].body
        end
        return originalReadMail(mailId, ...)
    end

    local function RecreateMailDataFromArchive(archived)
        local mailId64 = id64(archived.mailId)
        if mailId64 and not mailDataCache[mailId64.string] then
            local dataTable = {}
            ZO_MailInboxShared_PopulateMailData(dataTable, 0)
            dataTable.archived = true
            dataTable.mailId = mailId64.id64
            dataTable.subject = archived.subject
            dataTable.returned = archived.returned
            dataTable.senderDisplayName = archived.senderDisplayName
            dataTable.senderCharacterName = archived.senderCharacterName
            dataTable.expiresInDays = nil
            dataTable.unread = false
            dataTable.numAttachments = 0 -- TODO archived.numAttachments
            -- dataTable.attachmentData = archived.attachmentData
            dataTable.attachedMoney = 0 -- TODO archived.attachedMoney
            dataTable.codAmount = 0 -- TODO archived.codAmount
            dataTable.secsSinceReceived = GetTimeStamp() - archived.timeReceived
            dataTable.fromSystem = archived.fromSystem
            dataTable.fromGuild = archived.fromGuild
            dataTable.fromCS = archived.fromCS
            dataTable.isFromPlayer = not (archived.fromSystem or archived.fromCS or archived.fromGuild)
            dataTable.priority = archived.fromCS and 1 or 2
            dataTable.isReadInfoReady = true
            dataTable.body = archived.body
            dataTable.chatCategory = archived.chatCategory
            dataTable.guildId = archived.guildId
            mailDataCache[mailId64.string] = dataTable
            logger:Verbose("recreate mail data")
        end
        return mailDataCache[mailId64.string]
    end

    local function FindPreviousBGControl()
        local controls = {}
        local isNotLast = {}
        for _, control in pairs(MAIL_INBOX.nodeBGControlPool.m_Active) do
            controls[#controls + 1] = control
            local _, _, target = control:GetAnchor(0)
            isNotLast[target] = true
        end
        for i = 1, #controls do
            if not isNotLast[controls[i]] then
                logger:Verbose("found previous bg control")
                return controls[i]
            end
        end
    end

    ZO_PreHook(tree, "Commit", function(self)
        local archiveList = {}
        local archiveMailNodeData = internal.archiveMailNodeData

        for _, archived in pairs(archive) do
            if archived.archived then
                local mailData = RecreateMailDataFromArchive(archived)
                table.insert(archiveList, mailData)
            end
        end
        table.sort(archiveList, MailComparator)
        local numArchivedMails = #archiveList

        local masterList = MAIL_INBOX.masterList
        local numPlayerMails = 0
        local numSystemMails = 0
        for i = 1, #masterList do
            local mailData = masterList[i]
            if mailData.isFromPlayer then
                numPlayerMails = numPlayerMails + 1
            else
                numSystemMails = numSystemMails + 1
            end
        end
        local numPlayerNodes = zo_max(numPlayerMails, 1) + 1
        local numSystemNodes = zo_max(numSystemMails, 1) + 1
        local numTotalNodes = numPlayerNodes + numSystemNodes
        local numBGControlsToAdd = zo_max(zo_ceil(numTotalNodes / 2), MAIL_INBOX.minNumBackgroundControls)

        local numArchivedNodes = zo_max(numArchivedMails, 1) + 1
        local newNumBGControlsToAdd = zo_max(zo_ceil((numTotalNodes + numArchivedNodes) / 2), MAIL_INBOX.minNumBackgroundControls)

        local previousBGControl = nil
        if numBGControlsToAdd > 0 then
            previousBGControl = FindPreviousBGControl()
        end
        if not previousBGControl then
            logger:Verbose("no previous bg control found")
        end
        for i = numBGControlsToAdd, newNumBGControlsToAdd do
            local bgControl = MAIL_INBOX.nodeBGControlPool:AcquireObject()
            if previousBGControl then
                bgControl:SetAnchor(TOPLEFT, previousBGControl, BOTTOMLEFT, 0, ZO_MAIL_INBOX_KEYBOARD_NODE_HEIGHT)
            else
                bgControl:SetAnchor(TOPLEFT)
            end
            previousBGControl = bgControl
        end

        archiveMailNodeData.text = (numArchivedMails > 0) and zo_strformat("Archived Mail (<<1>>)", numArchivedMails) or "Archived Mail"
        local archivedMailNode = tree:AddNode("ZO_MailInboxHeader", archiveMailNodeData)

        if numArchivedMails > 0 then
            for index, mailData in ipairs(archiveList) do
                mailData.node = tree:AddNode("ZO_MailInboxRow", mailData, archivedMailNode) -- TODO use modified template and call our own read mail function
            end
        else
            tree:AddNode("ZO_MailInboxEmptyRow", internal.archiveMailEmptyNodeData, archivedMailNode)
        end
        logger:Verbose("injected %d archived mails", numArchivedMails)
    end)

    local originalGetMailData = MAIL_INBOX.GetMailData
    MAIL_INBOX.GetMailData = function(self, mailId, ...)
        local mailId64 = id64(mailId)
        if mailId64 and mailDataCache[mailId64.string] then
            return mailDataCache[mailId64.string]
        end
        return originalGetMailData(self, mailId, ...)
    end

    ZO_PreHook(MAIL_INBOX, "RequestReadMessage", function(self, mailId)
        local mailId64 = id64(mailId)
        if mailId64 ~= id64(self.mailId) and mailId64 and mailDataCache[mailId64.string] then
            self.pendingRequestMailId = mailId
            self:OnMailReadable(mailId)
            return true
        end
    end)
end)
