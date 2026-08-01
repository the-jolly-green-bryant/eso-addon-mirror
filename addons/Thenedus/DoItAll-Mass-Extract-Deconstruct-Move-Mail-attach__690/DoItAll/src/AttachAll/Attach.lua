DoItAll = DoItAll or {}
local slots = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
local mailer = nil
local keybindPressed = 0

local function IsShowingSendMail()
  return MAIL_SEND_SCENE.state == SCENE_SHOWN
end

local function FindAttachmentSlot()
  for i = 1, MAIL_MAX_ATTACHED_ITEMS do
    if GetQueuedItemAttachmentInfo(i) == 0 then
      return i
    end
  end
end

local function HasAttachment()
  local nextFreeAttachmentSlot = FindAttachmentSlot()
  return not nextFreeAttachmentSlot or nextFreeAttachmentSlot > 1
end

local function IsMailFull()
  return not FindAttachmentSlot()
end

local function CheckIfMailFullAndSend()
  if IsMailFull() and DoItAll.Settings.GetSendMailFull() then
    mailer:SendMail(function() DoItAll.RunAttachAll(true) end)
  end
end

local function SendMailAtEnd()
  if not HasAttachment() then return end
  if DoItAll.Settings.GetSendMailEnd() then
    mailer:SendMail()
	--Reset the keybind pressed counter
    keybindPressed = 0
  else
    mailer:RestoreRecipient()
  end
end

local function ReportAttachmentResult(result, itemName)
  -- TODO: Use onscreen reporting instead
  itemName = itemName or "n/a"
  if result == MAIL_ATTACHMENT_RESULT_ALREADY_ATTACHED then
    d(itemName .. ": Item is already attached")
  elseif result == MAIL_ATTACHMENT_RESULT_BOUND then
    d(itemName .. ": Item is bound")
  elseif result == MAIL_ATTACHMENT_RESULT_ITEM_NOT_FOUND then
    d(itemName .. ": Item not found")
  elseif result == MAIL_ATTACHMENT_RESULT_LOCKED then
    d(itemName .. ": Item is locked")
  end
end

local function AttachItem(inventorySlot)
	local nextFreeAttachmentSlot = FindAttachmentSlot()
	if not nextFreeAttachmentSlot then
		return false
	end

	local result = QueueItemAttachment(inventorySlot.bagId, inventorySlot.slotIndex, nextFreeAttachmentSlot)
    local itemName = inventorySlot.name
    if itemName == nil and inventorySlot.bagId ~= nil and inventorySlot.slotIndex ~= nil then
        itemName = GetItemName(inventorySlot.bagId, inventorySlot.slotIndex)
    end
    ReportAttachmentResult(result, itemName)
	CheckIfMailFullAndSend()

	return true
end

function DoItAll.RunAttachAll(isCallback)
	isCallback = isCallback or false
	--Reset the keybind pressed counter if this is a callback function call after full mail was sent successfully
    if isCallback then
		keybindPressed = 0
    end

	--Keybind "add all" was pressed again, slots are added and no open slots are left? -> Remove the added items again
	if keybindPressed > 0 and HasAttachment() and not FindAttachmentSlot() then
		ClearQueuedMail()
		keybindPressed = 0
		--Abort here so the slots do not get filled again
        return false
	end
	--Fill the slots with the inventory slots
	slots:Fill(ZO_PlayerInventoryBackpack)
	--Scan each slot
	slots:ForEach(AttachItem)
	--Check if mail should be automatically sent as attachment slots are filled
	SendMailAtEnd()
end

function DoItAll.AttachAll()
	--Mail panel is shown?
	if not IsShowingSendMail() then return end
	--Initiate mailer object
	mailer = mailer or DoItAll.Mailer:New()
	--Scan the inventory slots and add them now
	DoItAll.RunAttachAll()
	--Increase the "pressed keybind button" counter
	keybindPressed = keybindPressed + 1
end
