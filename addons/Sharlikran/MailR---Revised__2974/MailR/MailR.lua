--[[
Title: MailR
Description: MailR is a supplemental addon for the ESO in-game mail system.
Version: 2.5.19
Original Author: pills
Previous Authors: calia1120, Ravalox Darkshire
]]

-- GLOBALS
MailR = {}

-------------------------------------------------
----- early helper                          -----
-------------------------------------------------

local function is_in(search_value, search_table)
  for k, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if string.find(string.lower(v), string.lower(search_value)) then return true end
    end
  end
  return false
end

-------------------------------------------------
----- lang setup                            -----
-------------------------------------------------

MailR.client_lang = GetCVar("Language.2")
MailR.effective_lang = nil
MailR.supported_lang = { "de", "en", "fr", "es", }
if is_in(MailR.client_lang, MailR.supported_lang) then
  MailR.effective_lang = MailR.client_lang
else
  MailR.effective_lang = "en"
end
MailR.supported_lang = MailR.client_lang == MailR.effective_lang

-------------------------------------------------
----- mod                                   -----
-------------------------------------------------

MailR.Name = "MailR"
MailR.DEFAULT_SAVE_MAIL_COLOR_STRING = "|c2dc50e"
MailR.DEFAULT_SENT_MAIL_COLOR_STRING = "|c3689ef"
MailR.DEFAULT_HEADER_COLOR_STRING = "|cd5b526"
MailR.RESET_COLOR_STRING = "|r"
-- are we in the mailbox UI
MailR.mailboxActive = false
-- max mail attachments
MailR.currentMessageInfo = {}
-- table for queued message to be sent
MailR.queuedSentMessage = {}
-- table for current message being composed
MailR.currentSendMessageInfo = {}
-- Saved Mail vars --
-- what version of the saved mail table are we using
MailR.SAVED_MAIL_VERSION = "2.0"
-- default table for above version incase this the first time MailR is used
MailR.SavedMail_defaults = {
  display = "all",
  mailr_version = MailR.SAVED_MAIL_VERSION,
  sent_count = 0,
  sent_messages = {},
  inbox_count = 0,
  inbox_messages = {},
  throttle_time = 1 --seconds (can be fractional)
}
MailR.MAX_READ_ATTACHMENTS = MAIL_MAX_ATTACHED_ITEMS + 1
MailR.defaultMailInboxFn = {}

--[[TODO Don't think this is truly needed ]]--
MailR.guildies = {}

-- saved mail
MailR.SavedMail = nil
-- Locale vars --
MailR.localeStringMap = {
  ["en"] = {
    ["Reply"] = "Reply",
    ["Forward"] = "Forward",
    ["Reply To Message"] = "Reply To Message",
    ["Forward Message"] = "Forward Message",
    ["Original Message"] = "Original Message",
    ["Save Mail"] = "Save Mail",
    ["From: "] = "From: ",
    ["Fwd: "] = "Fwd: ",
    ["Re: "] = "Re: ",
    ["Attachments: "] = "Attachments: ",
    ["To:"] = "To:",
    ["Received:"] = "Received:",
    ["Sent:"] = "Sent:",
    ["Attached Gold: "] = "Attached Gold: ",
    ["COD: "] = "COD: ",
    ["Postage: "] = "Postage: "
  },
  ["de"] = {
    ["Reply"] = "Antworten",
    ["Forward"] = "Vorwärts",
    ["Reply To Message"] = "Antwort auf Beitrag",
    ["Forward Message"] = "Nachricht weiterleiten",
    ["Original Message"] = "Ursprüngliche Nachricht",
    ["Save Mail"] = "Save Mail",
    ["From: "] = "Von: ",
    ["Fwd: "] = "WG: ",
    ["Re: "] = "AW: ",
    ["Attachments: "] = "Anhänge: ",
    ["To:"] = "An:",
    ["Received:"] = "Erhalten am:",
    ["Sent:"] = "Gesendet:",
    ["Attached Gold: "] = "Angehängte Gold: ",
    ["COD: "] = "COD: ",
    ["Postage: "] = "Porto: "
  },
  ["fr"] = {
    ["Reply"] = "Répondre",
    ["Forward"] = "Transférer",
    ["Reply To Message"] = "Répondre au Message",
    ["Forward Message"] = "Transférer le Message",
    ["Original Message: "] = "Message Original: ",
    ["Save Mail"] = "Save Mail",
    ["From: "] = "Von: ",
    ["Fwd: "] = "Tr: ",
    ["Re: "] = "Re: ",
    ["Attachments: "] = "Pièces jointes: ",
    ["To:"] = "A:",
    ["Received:"] = "Reçus:",
    ["Sent:"] = "Envoyé:",
    ["Attached Gold: "] = "Or Attaché: ",
    ["COD: "] = "COD: ",
    ["Postage: "] = "Affranchissement: "
  },
  ["es"] = {
    ["Reply"] = "Responder",
    ["Forward"] = "Reenviar",
    ["Reply To Message"] = "Responder mensaje",
    ["Forward Message"] = "Reenviar mensaje",
    ["Original Message"] = "Mensaje original",
    ["Save Mail"] = "Guardar correo",
    ["From: "] = "De: ",
    ["Fwd: "] = "RV: ",
    ["Re: "] = "RE: ",
    ["Attachments: "] = "Adjuntos: ",
    ["To:"] = "Para:",
    ["Received:"] = "Recibido:",
    ["Sent:"] = "Enviar:",
    ["Attached Gold: "] = "Oro adjunto: ",
    ["COD: "] = "Contra reembolso: ",
    ["Postage: "] = "Gastos de envío: ",
  },
}
local ShowPlayerContextMenu_Orig = CHAT_SYSTEM.ShowPlayerContextMenu
local ShowPlayerInteractMenu_Orig = ZO_PlayerToPlayer.ShowPlayerInteractMenu

-------------------------------------------------
----- logger                                -----
-------------------------------------------------

MailR.show_log = false
if LibDebugLogger then
  local logger = LibDebugLogger.Create(MailR.Name)
  MailR.logger = logger
end
local SDLV = DebugLogViewer
if SDLV then MailR.viewer = true else MailR.viewer = false end

local function create_log(log_type, log_content)
  if log_type == "Debug" then
    MailR.logger:Debug(log_content)
  end
  if log_type == "Info" then
    MailR.logger:Info(log_content)
  end
  if log_type == "Verbose" then
    MailR.logger:Verbose(log_content)
  end
  if log_type == "Warn" then
    MailR.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function MailR.dm(log_type, ...)
  if not MailR.logger then return end
  if not MailR.show_log then return end
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

-- temp fix for Wykyyds Mailbox
if type(WYK_MailBox) == "table" then
  WYK_MailBox.ReadMail = function() return end
end
-- /GLOBALS


-- When Forward Button Clicked or Key Pressed
function MailR.CreateForward()
  -- make sure we only try to create/show a reply when the mailInbox is active
  MailR.dm("Debug", "CreateForward")
  if not MailR.mailboxActive then return end
  MailR.dm("Debug", "mailboxActive")
  if SCENE_MANAGER.currentScene.name ~= "mailInbox" then return end
  if MailR.currentMessageInfo["numAttachments"] == nil or MailR.currentMessageInfo["isSentMail"] == nil then return end
  if MailR.currentMessageInfo["numAttachments"] > 0 and not MailR.currentMessageInfo["isSentMail"] then return end
  local openMailId = MAIL_INBOX:GetOpenMailId()
  if not MAIL_INBOX:GetMailData(openMailId) then return end

  MailR.dm("Debug", "Creating Forward")

  -- ZO_MainMenuSceneGroupBarButton2.m_object.m_buttonData:callback()
  local fwdStr = MailR.localeStringMap[MailR.effective_lang]["Fwd: "]
  local replyString = MailR.currentMessageInfo["subject"]:gsub("^" .. fwdStr, "")
  ZO_MailSendSubjectField:SetText(fwdStr .. replyString)
  local origStr = MailR.localeStringMap[MailR.effective_lang]["Original Message"]
  local bodyStr = "\n***" .. MailR.DEFAULT_HEADER_COLOR_STRING .. origStr .. MailR.RESET_COLOR_STRING .. "***\n"
  local senderStr = MailR.currentMessageInfo["displayName"]
  if not MailR.currentMessageInfo["characterName"] == "" and not MailR.currentMessageInfo["characterName"] == nil then
    senderStr = MailR.currentMessageInfo["characterName"] .. "(" .. senderStr .. ")"
  end
  bodyStr = bodyStr .. MailR.DEFAULT_HEADER_COLOR_STRING .. MailR.localeStringMap[MailR.effective_lang]["From: "] .. MailR.RESET_COLOR_STRING .. senderStr .. "\n"
  bodyStr = bodyStr .. "\n" .. MailR.currentMessageInfo["body"] .. "\n"
  bodyStr = bodyStr .. "***" .. MailR.DEFAULT_HEADER_COLOR_STRING .. "/" .. MailR.localeStringMap[MailR.effective_lang]["Original Message"] .. MailR.RESET_COLOR_STRING .. "***\n"
  ZO_MailSendBodyField:SetText(bodyStr)
  ZO_MailSendBodyField:TakeFocus()

end

-- Handles when a message in the inbox is selected
function MailR.OnMailReadable(eventCode, mailId)
  MailR.dm("Debug", "OnMailReadable")
  MailR.dm("Verbose", mailId)
  MailR.dm("Verbose", { GetMailItemInfo(mailId) })

  local senderDisplayName, senderCharacterName, subject, mailItemIcon, unread,
  fromSystem, fromCustomerService, returned, numAttachments, attachedMoney,
  codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)

  --[[ TODO: Update the concept of isSentMail such that when you send mail
  it is auto saved and flagged as sent. Received Mail is flagged when saved.
  However, both types then indicate that it is a MailR mail and not player or
  system mail.
  MailR.currentMessageInfo["isSentMail"] = MailR.IsMailIdSentMail(mailId)
  MailR.currentMessageInfo["isReceivedMail"] = false

  6/17/2024 The list is no longer a scroll list and MailR enhanced that
  scroll list so storing sent or received no longer applies because we
  are not altering the new tree
  ]]--
  MailR.currentMessageInfo["displayName"] = senderDisplayName
  MailR.currentMessageInfo["recipient"] = senderDisplayName
  MailR.currentMessageInfo["characterName"] = senderCharacterName
  MailR.currentMessageInfo["subject"] = subject
  MailR.currentMessageInfo["body"] = ZO_MailInboxMessageBody:GetText()
  MailR.currentMessageInfo["numAttachments"] = numAttachments
  MailR.currentMessageInfo["secsSinceReceived"] = secsSinceReceived
  MailR.currentMessageInfo["timeSent"] = GetTimeStamp() - secsSinceReceived
  MailR.currentMessageInfo["gold"] = 0
  MailR.currentMessageInfo["cod"] = false
  MailR.currentMessageInfo["postage"] = 0
  MailR.currentMessageInfo["mailId"] = mailId
  -- Initialize attachments table with empty tables
  MailR.currentMessageInfo["attachments"] = {}
  for a = 1, MailR.MAX_READ_ATTACHMENTS do
    MailR.currentMessageInfo["attachments"][a] = {}
  end
  --[[ we dont do anything with this information yet
  if not MailR.IsMailIdSentMail(mailId) then

  TODO: Make sure the attachments are saved with the mail
  because previously it was checked whether or not it was
  sent mail
  ]]--
  for a = 1, numAttachments do
    local textureName, stack, creatorName = GetAttachedItemInfo(mailId, a)
    local link = GetAttachedItemLink(mailId, a, LINK_STYLE_DEFAULT)
    local icon = GetItemLinkInfo(link)
    MailR.currentMessageInfo["attachments"][a].textureName = textureName
    MailR.currentMessageInfo["attachments"][a].stack = stack
    MailR.currentMessageInfo["attachments"][a].creatorName = creatorName
    MailR.currentMessageInfo["attachments"][a].link = link
    MailR.currentMessageInfo["attachments"][a].icon = icon
  end
  --[[
  end

  TODO: Make sure the attachments are saved with the mail
  because previously it was checked whether or not it was
  sent mail
  ]]--
  -- shoud we include the body of the original message? Is there a message limit?

  -- this doesn't seem to return what I expect so use whats below
  --if IsMailReturnable(mailId) then
  -- some messages you cant reply to (e.g. system messages)
  if senderDisplayName == nil or senderDisplayName == "" or fromSystem then
    MailR.currentMessageInfo["returnable"] = false
  else
    MailR.currentMessageInfo["returnable"] = true
  end
  if MailR and MailR.selectionKeybindStripDescriptor then
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
    MailR.dm("Debug", "UpdateKeybindButtonGroup OnMailReadable")
  end
end

-- Mail UI opened
function MailR.OnOpenMailbox(eventCode)
  MailR.dm("Debug", "OnOpenMailbox")
  MailR.mailboxActive = true
end

-- Mail UI closed
function MailR.OnCloseMailbox(eventCode)
  MailR.dm("Debug", "OnCloseMailbox")
  MailR.mailboxActive = false
end

-- called when text in recipient field of composed message is updated
--TODO Keep: Examine why this is needed
function MailR.UpdateSendTo()
  MailR.dm("Verbose", "recipient updated")
  MailR.currentSendMessageInfo["recipient"] = ZO_MailSendToField:GetText()
end

-- called when text in subject field of composed message is updated
--TODO Keep: Examine why this is needed
function MailR.UpdateSendSubject()
  MailR.dm("Verbose", "subject updated")
  MailR.currentSendMessageInfo["subject"] = ZO_MailSendSubjectField:GetText()
end

-- called when text in body field of composed message is updated
--TODO Keep: Examine why this is needed
function MailR.UpdateSendBody()
  MailR.dm("Verbose", "body updated")
  MailR.currentSendMessageInfo["body"] = ZO_MailSendBodyField:GetText()
end

MailR.MAX_MAILID = 2147483647
function MailR.GenerateMailId()
  return math.random(MailR.MAX_MAILID)
end

function MailR.rtrim(s)
  MailR.dm("Debug", "rtrim")
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

function MailR.OnMailSendSuccess(eventCode, playerName)
  MailR.dm("Debug", "OnMailSendSuccess")
  if next(MailR.queuedSentMessage) == nil then return end
  MailR.queuedSentMessage["timeSent"] = GetTimeStamp()
  if MailR.rtrim(MailR.queuedSentMessage["subject"]) == "" then
    MailR.queuedSentMessage["subject"] = "(No Subject)"
  end
  MailR.queuedSentMessage["isSentMail"] = true
  -- MailR.dm("Debug", MailR.queuedSentMessage)
  local mailId = MailR.GenerateMailId()
  while MailR.SavedMail.sent_messages["MailR_" .. tostring(mailId)] ~= nil do
    mailId = MailR.GenerateMailId()
  end
  MailR.SavedMail.sent_messages["MailR_" .. tostring(mailId)] = MailR.CopyMessage(MailR.queuedSentMessage)
  MailR.SavedMail.sent_count = MailR.SavedMail.sent_count + 1
  MailR.ClearCurrentSendMessage()
  MailR.queuedSentMessage = {}
  QueueMoneyAttachment(0) --reset per awesomebillys recommendation for known COD bug as of 2014-05-15
  MAIL_INBOX:RefreshData()
end

-- clear current message table
function MailR.ClearCurrentSendMessage()
  MailR.dm("Debug", "ClearCurrentSendMessage")
  MailR.currentSendMessageInfo["recipient"] = ""
  MailR.currentSendMessageInfo["subject"] = ""
  MailR.currentSendMessageInfo["body"] = ""
  MailR.currentSendMessageInfo["gold"] = 0
  MailR.currentSendMessageInfo["cod"] = false
  MailR.currentSendMessageInfo["postage"] = 0
  MailR.currentSendMessageInfo["timeSent"] = 0
  MailR.currentSendMessageInfo["attachments"] = {}
  -- Initialize attachments table with empty tables
  MailR.currentSendMessageInfo["attachments"] = {}
  for a = 1, MailR.MAX_READ_ATTACHMENTS do
    MailR.currentSendMessageInfo["attachments"][a] = {}
  end
end

-- copy message_table to a new table
function MailR.CopyMessage(messageToCopy)
  MailR.dm("Debug", "CopyMessage")
  local copyMessage = {}
  copyMessage["recipient"] = messageToCopy["recipient"]
  copyMessage["subject"] = messageToCopy["subject"]
  copyMessage["body"] = messageToCopy["body"]
  copyMessage["gold"] = messageToCopy["gold"]
  copyMessage["cod"] = messageToCopy["cod"]
  copyMessage["postage"] = messageToCopy["postage"]
  copyMessage["timeSent"] = messageToCopy["timeSent"]
  copyMessage["isSentMail"] = messageToCopy["isSentMail"]
  copyMessage["isReceivedMail"] = messageToCopy["isReceivedMail"]
  copyMessage["returnable"] = messageToCopy["returnable"]
  copyMessage["attachments"] = {}
  for a = 1, MailR.MAX_READ_ATTACHMENTS do
    table.insert(copyMessage["attachments"], messageToCopy["attachments"][a])
  end
  return copyMessage
end

-- called when attachments are added to composed mail
function MailR.OnMailAttachmentAdded(eventCode, slot)
  MailR.dm("Debug", "OnMailAttachmentAdded")
  local attachment = ZO_MailSendAttachments:GetChild(slot)
  local bagid = attachment.bagId
  local slotid = attachment.slotIndex
  local stack = attachment.stackCount
  local link = GetItemLink(bagid, slotid, LINK_STYLE_DEFAULT)
  local icon = GetItemLinkInfo(link)
  MailR.currentSendMessageInfo["attachments"][slot] = { ["stack"] = stack, ["link"] = link, ["icon"] = icon }
  MailR.currentSendMessageInfo["postage"] = GetQueuedMailPostage()
end

-- called when attachments are removed from composed mail
function MailR.OnMailAttachmentRemoved(eventCode, slot)
  MailR.dm("Debug", "OnMailAttachmentRemoved")
  MailR.currentSendMessageInfo["attachments"][slot] = {}
  MailR.currentSendMessageInfo["postage"] = GetQueuedMailPostage()
end

-- Shared updater for queued money / COD / postage
local function MailR_UpdateQueuedMoneyInfo()
  local queuedCOD = GetQueuedCOD()
  local queuedMoney = GetQueuedMoneyAttachment()
  local postage = GetQueuedMailPostage()

  if queuedCOD and queuedCOD > 0 then
    -- Mail is COD: gold represents the COD amount
    MailR.currentSendMessageInfo["cod"] = true
    MailR.currentSendMessageInfo["gold"] = queuedCOD
  else
    -- Not COD: gold represents the attached money amount
    MailR.currentSendMessageInfo["cod"] = false
    MailR.currentSendMessageInfo["gold"] = queuedMoney or 0
  end

  MailR.currentSendMessageInfo["postage"] = postage or 0
end

-- called when attached money updated
function MailR.AttachmentMoneyChanged(eventCode, moneyAmount)
  MailR.dm("Debug", "AttachmentMoneyChanged")
  MailR_UpdateQueuedMoneyInfo()
end

-- called when changed from gold payment to COD
function MailR.CODChanged(eventCode, codAmount)
  MailR.dm("Debug", "CODChanged")
  MailR_UpdateQueuedMoneyInfo()
end

-- when SendMail is called do this first, otherwise currentSendMessageInfo gets cleared (by ZOS)
function MailR.QueueSentMessage()
  MailR.dm("Debug", "QueueSentMessage")
  MailR.queuedSentMessage = {}
  MailR.queuedSentMessage = MailR.CopyMessage(MailR.currentSendMessageInfo)
end

function MailR.OnMouseUp(control, button, upInside)
  MailR.dm("Debug", "OnMouseUp")
  MAIL_INBOX:Row_OnMouseUp(control)
  if not control then return end
  local mailId = control.dataEntry.data.mailId

  if button == 2 then
    ClearMenu()
    AddMenuItem("Save Message", MailR.SaveMail)
    ShowMenu()
  end
end

function MailR.SaveMail()
  MailR.dm("Debug", "SaveMail")
  local mail = MailR.currentMessageInfo
  local savedMailId = "MailR_" .. Id64ToString(MailR.currentMessageInfo.mailId)
  mail.isSentMail = false
  mail.isReceivedMail = true
  MailR.SavedMail.sent_messages[savedMailId] = MailR.CopyMessage(MailR.currentMessageInfo)
  MailR.SavedMail.sent_count = MailR.SavedMail.sent_count + 1
  if MailR and MailR.selectionKeybindStripDescriptor then
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
    MailR.dm("Debug", "UpdateKeybindButtonGroup SaveMail")
  end
  MAIL_INBOX:RefreshData()
end

function MailR.ShowPlayerContextMenu(self, playerName, rawName)
  ShowPlayerContextMenu_Orig(self, playerName, rawName)
  AddMenuItem('Send Mail', function()
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText(playerName)
  end)
  ShowMenu()
end

function MailR.ShowPlayerInteractMenu(self, isIgnored)
  MailR.dm("Debug", "ShowPlayerInteractMenu")
  local currentTarget = self.currentTargetCharacterName
  local icons = {
    enabledNormal = "EsoUI/Art/Mail/mail_tabicon_compose_up.dds",
    enabledSelected = "EsoUI/Art/Mail/mail_tabicon_compose_down.dds",
    disabledNormal = "EsoUI/Art/Mail/mail_tabicon_compose_up.dds",
    disabledSelected = "EsoUI/Art/Mail/mail_tabicon_compose_down.dds",
  }
  self:AddMenuEntry("Send Mail", icons, isIgnored, function()
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText(currentTarget)
  end)
  ShowPlayerInteractMenu_Orig(self, isIgnored)
end

function MailR.CheckMailIdEquality(mailId1, mailId2)
  MailR.dm("Debug", "CheckMailIdEquality")
  return mailId1 == mailId2
end

function MailR.MailIdEquality(...)
  MailR.dm("Debug", "MailIdEquality")
  -- return MailR.CheckMailIdEquality(data1.mailId, data2.mailId)
  return true
end

function MailR.HasAlreadyReportedSelectedMail(self)
  MailR.dm("Debug", "HasAlreadyReportedSelectedMail")
  return self.reportedMailIds[zo_getSafeId64Key(self.mailId)]
end

function MailR.OverloadMailInbox()
  MailR.dm("Debug", "OverloadMailInbox")
  --[[ 6/17/2024 The list is no longer a scroll list and MailR enhanced that
  scroll list so storing sent or received no longer applies because we
  are not altering the new tree

  local originalIsMailReturnable = IsMailReturnable
  IsMailReturnable = function(mailId)
    if MailR.IsMailIdSentMail(mailId) then
      MailR.dm("Debug", "MailR IsMailReturnable")
      return false
    else
      MailR.dm("Debug", "Original IsMailReturnable")
      return originalIsMailReturnable(mailId)
    end
  end
  ]]--
  --[[ Many older functions were removed because it is not a ScrollList now

    MAIL_INBOX.RequestReadMessage = MailR.RequestReadMessage
    MAIL_INBOX.HasAlreadyReportedSelectedMail = MailR.HasAlreadyReportedSelectedMail
    ZO_MailInboxRow_OnMouseUp = MailR.OnMouseUp
    ZO_PlayerToPlayer.ShowPlayerInteractMenu = MailR.ShowPlayerInteractMenu
    MAIL_INBOX.ConfirmDelete = MailR.ConfirmDelete
    MAIL_INBOX.IsMailDeletable = MailR.IsMailDeletable
  ]]--
  CHAT_SYSTEM.ShowPlayerContextMenu = MailR.ShowPlayerContextMenu
  MAIL_INBOX.Delete = MailR.Delete
  -- MAIL_INBOX.EndRead = MailR.EndRead
  for i = 1, MailR.MAX_READ_ATTACHMENTS do
    table.insert(MailR.defaultMailInboxFn,
      { MAIL_INBOX.attachmentSlots[i]:GetHandler("OnMouseEnter"), MAIL_INBOX.attachmentSlots[i]:GetHandler("OnClicked"), MAIL_INBOX.attachmentSlots[i]:GetHandler("OnMouseDoubleClicked") })
  end

  -- overload keybinds...I think I have effectively rewritten ESO Mail at this point
  -- instead of adding on :/
  MAIL_INBOX.InitializeKeybindDescriptors = MailR.InitializeInboxKeybindDescriptors
  MAIL_INBOX:InitializeKeybindDescriptors()
end

function MailR.OverloadMailSend()
  MailR.dm("Debug", "OverloadMailSend")
  MAIL_SEND.InitializeKeybindDescriptors = MailR.InitializeSendKeybindDescriptors
  MAIL_SEND:InitializeKeybindDescriptors()
end

function MailR.Guild_MouseEnter(control)
  MailR.GuildControl:Row_OnMouseEnter(control)
end

function MailR.Guild_MouseExit(control)
  MailR.GuildControl:Row_OnMouseExit(control)
end

function MailR.Guild_MouseUp(control, button, upInside)
  MailR.dm("Debug", "Guild_MouseUp")
  --[[TODO not sure what the MouseUp feature was supposed to do]]--
  local name = control.data.name
  local pressed_button = 1
  local api_ver = GetAPIVersion()

  if api_ver > 100011 then pressed_button = MOUSE_BUTTON_INDEX_LEFT end

  if button == pressed_button then
    MailR.GuildControl:RefreshVisible()
  end
  --MailR.Guild:MouseEnter(control, button, upInside)
end

function MailR.EndRead(self)
  for i = 1, MailR.MAX_READ_ATTACHMENTS do
    self.attachmentSlots[i].money = nil
    ZO_Inventory_SetupSlot(self.attachmentSlots[i], 0)
  end

  self.messageControl:SetHidden(true)
  self.mailId = nil
  self.pendingAcceptCOD = nil

  if MailR and MailR.selectionKeybindStripDescriptor then
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
    MailR.dm("Debug", "UpdateKeybindButtonGroup EndRead")
  end
end

local function CreateInboxSelectionKeybindDescriptor(self)
  local selectionKeybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,

    --Return
    {
      name = GetString(SI_MAIL_READ_RETURN),
      keybind = "UI_SHORTCUT_SECONDARY",

      callback = function()
        self:Return()
      end,

      visible = function()
        if self.mailId and not self.isMailFromGuild then
          return IsMailReturnable(self.mailId)
        end
        return false
      end
    },

    --Reply
    {
      name = GetString(SI_MAIL_READ_REPLY),
      keybind = "UI_SHORTCUT_TERTIARY",

      callback = function()
        self:Reply()
      end,

      visible = function()
        if self.mailId and not self.isMailFromGuild then
          local mailData = self:GetMailData(self.mailId, self.isMailFromGuild)
          return mailData and mailData.isFromPlayer or false
        end
        return false
      end
    },

    -- Delete
    {
      name = GetString(SI_MAIL_READ_DELETE),
      keybind = "UI_SHORTCUT_NEGATIVE",

      callback = function()
        self:Delete()
      end,

      visible = function()
        if self.mailId then
          if self.isMailFromGuild then
            return true
          else
            return not IsMailReturnable(self.mailId)
          end
        end
        return false
      end
    },

    -- Take Attachments
    {
      name = GetString(SI_MAIL_READ_ATTACHMENTS_TAKE),
      keybind = "UI_SHORTCUT_PRIMARY",

      callback = function()
        self:TryTakeAll()
      end,

      visible = function()
        if self.mailId and not self.isMailFromGuild then
          local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(self.mailId)
          if numAttachments > 0 or attachedMoney > 0 then
            return true
          end
        end
        return false
      end
    },

    --Take All
    {
      name = function()
        if self.mailId then
          local mailData = self:GetMailData(self.mailId)
          return GetString("SI_MAILCATEGORY_TAKEALL", mailData.category)
        end
      end,
      keybind = "UI_SHORTCUT_QUATERNARY",
      callback = function()
        if self.mailId then
          local mailData = self:GetMailData(self.mailId)
          ZO_Dialogs_ShowPlatformDialog("MAIL_CONFIRM_TAKE_ALL", { category = mailData.category })
        end
      end,
      visible = function()
        if self.mailId and not self.isMailFromGuild then
          local mailData = self:GetMailData(self.mailId)
          if mailData then
            local canTakeAttachments = CanTryTakeAllMailAttachmentsInCategory(mailData.category, MAIL_MANAGER:ShouldDeleteOnClaim())
            return canTakeAttachments
          end
        end
        return false
      end,
    },

    --Report Player
    {
      name = function()
        if self.isMailFromGuild then
          return GetString(SI_MAIL_READ_REPORT_GUILD)
        end
        return GetString(SI_MAIL_READ_REPORT_PLAYER)
      end,

      keybind = "UI_SHORTCUT_HELP",

      visible = function()
        if self.mailId and not self:HasAlreadyReportedSelectedMail() then
          local mailData = self:GetMailData(self.mailId, self.isMailFromGuild)
          return mailData and (mailData.isFromPlayer or mailData.fromGuild) and not mailData.isFromLocalPlayer
        end
      end,

      callback = function()
        if self.isMailFromGuild then
          local function ReportCallback()
            self:RecordSelectedMailAsReported()
          end
          local mailData = self:GetMailData(self.mailId, self.isMailFromGuild)
          local guildName = GetGuildName(mailData.guildId)
          ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportGuildTicketScene(guildName, CUSTOMER_SERVICE_ASK_FOR_HELP_REPORT_GUILD_CATEGORY_INAPPROPRIATE_MAIL, ReportCallback)
        else
          local senderDisplayName = GetMailSender(self.mailId)
          local function ReportCallback()
            self:RecordSelectedMailAsReported()
            if not IsIgnored(senderDisplayName) then
              AddIgnore(senderDisplayName)
            end
          end
          ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(senderDisplayName, ReportCallback)
        end
      end,
    },

    --Forward Mail
    {
      name = MailR.localeStringMap[MailR.effective_lang]["Forward"],
      keybind = "MAIL_FORWARD",

      visible = function()
        if (self.mailId) then
          return not IsMailReturnable(self.mailId)
        end
      end,

      callback = function()
        if (self.mailId) then
          MailR.CreateForward()
        end
      end,
    },

    --Save Mail
    {
      name = MailR.localeStringMap[MailR.effective_lang]["Save Mail"],
      keybind = "MAIL_SAVE",

      visible = function()
        if self.mailId == nil then return false end
        if not MailR.SavedMail.sent_messages["MailR_" .. Id64ToString(self.mailId)] then
          return true
        end
      end,

      callback = function()
        if self.mailId then
          MailR.SaveMail()
        end
      end,
    },
  }

  return selectionKeybindStripDescriptor
end

function MailR.InitializeInboxKeybindDescriptors(self)
  MailR.dm("Debug", "InitializeInboxKeybindDescriptors")

  -- Only create the descriptor once so KEYBIND_STRIP always sees the same table
  if not MailR.selectionKeybindStripDescriptor then
    MailR.selectionKeybindStripDescriptor = CreateInboxSelectionKeybindDescriptor(self)
    MailR.dm("Debug", "Keybind Descriptor Created")
  end

  -- Point the inbox at the same descriptor table
  self.selectionKeybindStripDescriptor = MailR.selectionKeybindStripDescriptor
  MAIL_INBOX.selectionKeybindStripDescriptor = MailR.selectionKeybindStripDescriptor
end

function MailR:InitializeSendKeybindDescriptors()
  MailR.dm("Debug", "InitializeSendKeybindDescriptors")
  self.staticKeybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,

    -- Clear
    {
      name = GetString(SI_MAIL_SEND_CLEAR),
      keybind = "UI_SHORTCUT_NEGATIVE",
      callback = function()
        ZO_Dialogs_ShowDialog("CONFIRM_CLEAR_MAIL_COMPOSE", { callback = function() self:ClearFields() end })
      end,
    },

    -- Send
    {
      name = GetString(SI_MAIL_SEND_SEND),
      keybind = "UI_SHORTCUT_SECONDARY",
      callback = function()
        MailR.QueueSentMessage()
        self:Send()
      end,
    },
  }
end

function MailR.IsMailDeletable(mailId)
  local numAttachments, attachedMoney = GetMailAttachmentInfo(mailId)
  local noAttachments = numAttachments == 0 and attachedMoney == 0
  return noAttachments
end

function MailR.Delete()
  MailR.dm("Debug", "Delete")
  local mailId = MAIL_INBOX.mailId
  MailR.dm("Debug", mailId)

  -- original
  if mailId then
    if MailR.IsMailDeletable(mailId) then
      if MAIL_MANAGER.savedVars.deleteOnClaim then
        if MAIL_INBOX.isMailFromGuild then
          MAIL_MANAGER:MarkGuildMailDeleted(mailId)
        else
          DeleteMail(mailId)
        end
      else
        ZO_Dialogs_ShowPlatformDialog("DELETE_MAIL", { confirmationCallback = function(...)
          if MAIL_INBOX.isMailFromGuild then
            MAIL_MANAGER:MarkGuildMailDeleted(mailId)
          else
            DeleteMail(mailId)
          end
          PlaySound(SOUNDS.MAIL_ITEM_DELETED)
        end, mailId = MAIL_INBOX.mailId, })
      end
    end
  end
  if MailR and MailR.selectionKeybindStripDescriptor then
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
    MailR.dm("Debug", "UpdateKeybindButtonGroup Delete")
  end
end

function MailR.ConvertSavedMail()
  MailR.dm("Debug", "ConvertSavedMail")
  -- version 1.0 to 2.0
  if MailR.SavedMail.messages ~= nil then
    MailR.SavedMail.inbox_messages = {}
    MailR.SavedMail.inbox_count = 0
    MailR.SavedMail.sent_messages = {}
    for k, v in pairs(MailR.SavedMail.messages) do
      MailR.SavedMail.sent_messages[k] = v
    end
    MailR.SavedMail.sent_count = #MailR.SavedMail.sent_messages
    MailR.SavedMail.messages = nil
    MailR.SavedMail.count = nil
    MailR.SavedMail.mailr_version = MailR.SAVED_MAIL_VERSION
  end
end

-- do all this when the addon is loaded
function MailR.Init(eventCode, addOnName)
  if addOnName ~= "MailR" then return end
  MailR.dm("Debug", "OnAddonLoaded, Init")

  -- Event Registration
  EVENT_MANAGER:RegisterForEvent("MailR_OnMailReadable", EVENT_MAIL_READABLE, MailR.OnMailReadable)
  EVENT_MANAGER:RegisterForEvent("MailR_OnOpenMailbox", EVENT_MAIL_OPEN_MAILBOX, MailR.OnOpenMailbox)
  EVENT_MANAGER:RegisterForEvent("MailR_OnCloseMailbox", EVENT_MAIL_CLOSE_MAILBOX, MailR.OnCloseMailbox)
  EVENT_MANAGER:RegisterForEvent("MailR_MailSentSuccessfully", EVENT_MAIL_SEND_SUCCESS, MailR.OnMailSendSuccess)
  EVENT_MANAGER:RegisterForEvent("MailR_OnMailAttachmentAdded", EVENT_MAIL_ATTACHMENT_ADDED, MailR.OnMailAttachmentAdded)
  EVENT_MANAGER:RegisterForEvent("MailR_OnMailAttachmentRemoved", EVENT_MAIL_ATTACHMENT_REMOVED, MailR.OnMailAttachmentRemoved)
  EVENT_MANAGER:RegisterForEvent("MailR_CODChanged", EVENT_MAIL_COD_CHANGED, MailR.CODChanged)
  EVENT_MANAGER:RegisterForEvent("MailR_AttachmentMoneyChanged", EVENT_MAIL_ATTACHED_MONEY_CHANGED, MailR.AttachmentMoneyChanged)

  local inboxScene = SCENE_MANAGER:GetScene("mailInbox")
  local sendScene = SCENE_MANAGER:GetScene("mailSend")
  inboxScene:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWN then
      MailR.dm("Debug", "Inbox opened")
      KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
    end
  end)
  sendScene:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWN then
      MailR.dm("Debug", "Send Mail opened")
      -- refresh send-mail strip if you want
    end
  end)

  SLASH_COMMANDS["/mailr"] = MailR.FilterDisplay

  MailR.mailboxActive = false
  MailR.ClearCurrentSendMessage()
  MailR.SavedMail = ZO_SavedVars:New("SV_MailR_SavedMail", 1, nil, MailR.SavedMail_defaults)

  local sv = SV_MailR_SavedMail.Default[GetDisplayName()][GetUnitName("player")]
  -- Clean up saved variables (from previous versions)
  for key, val in pairs(sv) do
    -- Delete key-value pair if the key can't also be found in the default settings (except for version)
    if key ~= "version" and MailR.SavedMail_defaults[key] == nil then
      sv[key] = nil
    end
  end
  MailR.SavedMail.disableDeleteConfirmation = nil -- Removed for U42

  if MailR.SavedMail.display == nil then
    MailR.SavedMail.display = "all"
  end
  -- we have to do this because if we tell ZO_SavedVars our version changed it will delete everything
  -- check for messags as well as version because of version 1.0 conflict with ZOS
  if MailR.SavedMail.messages ~= nil or MailR.SavedMail.mailr_version ~= MailR.SAVED_MAIL_VERSION then
    MailR.ConvertSavedMail()
  end
  math.randomseed(GetTimeStamp())

  local forwardSettingStr = MailR.localeStringMap[MailR.effective_lang]["Forward Message"]
  local mailSaveStr = MailR.localeStringMap[MailR.effective_lang]["Save Mail"]
  ZO_CreateStringId("SI_BINDING_NAME_MAIL_FORWARD", forwardSettingStr)
  ZO_CreateStringId("SI_BINDING_NAME_MAIL_SAVE", mailSaveStr)

  local originalSendToHandler = ZO_MailSendToField:GetHandler("OnTextChanged")
  ZO_MailSendToField:SetHandler("OnTextChanged", function(...)
    originalSendToHandler(...)
    MailR.UpdateSendTo()
  end)
  local originalSubjectHandler = ZO_MailSendSubjectField:GetHandler("OnTextChanged")
  if originalSubjectHandler then
    ZO_MailSendSubjectField:SetHandler("OnTextChanged", function(...)
      originalSubjectHandler(...)
      MailR.UpdateSendSubject()
    end)
  else
    ZO_MailSendSubjectField:SetHandler("OnTextChanged", function(...) MailR.UpdateSendSubject() end)
  end
  ZO_MailSendBodyField:SetHandler("OnTextChanged", function(...) MailR.UpdateSendBody() end)

  SecurePostHook(MAIL_INBOX, "EndRead", function()
    zo_callLater(function()
      if MailR and MailR.selectionKeybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(MailR.selectionKeybindStripDescriptor)
        MailR.dm("Debug", "Final re-center from EndRead SPH (delayed)")
      end
    end, 5)
  end)

  MailR.OverloadMailInbox()
  MailR.OverloadMailSend()
end
EVENT_MANAGER:RegisterForEvent("MailR_Init", EVENT_ADD_ON_LOADED, MailR.Init)