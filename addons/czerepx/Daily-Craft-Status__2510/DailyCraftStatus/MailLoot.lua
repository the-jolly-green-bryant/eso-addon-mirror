local _addon = _G["DailyCraftStatus"]

local MAIL_ACTION_NONE = 0
local MAIL_ACTION_LOOT = 1
local MAIL_ACTION_DELETE = 2
local MAIL_ACTION_COUNT = 3
local MAIL_TIMEOUT_RESTART = 5000 --ms
local MAIL_TIMEOUT_ABORT = 10000 --ms
local MAIL_NEXTOP_DELAY = 10 --ms
local MAIL_OPEN_DELAY = 500 --ms

local mailAction = 0
local mailActionId = 0 --id64 for delayed restart/abort operations
local mailToCount = {}
local mailToLoot = {}
local lootedMail = {}
local curMailIndex = 0
local deleteAfterLoot = false
local abortOnTimeout = false

local FindFromList = _addon.FindFromList
local _out = _addon._out
local _outd = _addon._outd
local _translate = _addon._translate


local function DCS_tryOpenMailbox()
	if mailAction==MAIL_ACTION_NONE then return end
	if SCENE_MANAGER:GetCurrentScene().name == "mailInbox" then
		SCENE_MANAGER:HideCurrentScene()
	end	
	
	CloseMailbox()	
	
	local cMailAction = mailAction
	local cMailActionId = mailActionId

	--if inbox is not open within 5s, abort all
	zo_callLater(function () 
			if mailAction==cMailAction then
				if mailActionId==cMailActionId then
					if curMailIndex==0 then
						EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_OPEN_MAILBOX)
						mailAction = MAIL_ACTION_NONE
						mailActionId = 0
						_out("Failed to open mailbox, |cFF8080operation aborted")
					end
				end	
			end 
		end, 5000)  
		
	RequestOpenMailbox() 
end

local function DCS_mailActionCleanup()
	if mailAction==MAIL_ACTION_COUNT then 
		EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_READABLE) 
	elseif mailAction==MAIL_ACTION_DELETE then 
		EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_REMOVED) 
	elseif mailAction==MAIL_ACTION_LOOT then 
		EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_READABLE)
		EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
		EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_INVENTORY_IS_FULL)
	end
	mailAction = MAIL_ACTION_NONE
	mailActionId = 0
end

local function DCS_regUnexpectedCloseEvent()
	local cMailAction = mailAction
	local cMailActionId = mailActionId
	
	--abort if mailbox is closed before we are done
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_CLOSE_MAILBOX, function ()
			EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_CLOSE_MAILBOX)
			if mailAction==cMailAction then
				if mailActionId==cMailActionId then
					DCS_mailActionCleanup()
					_out("Mailbox prematurely closed, |cFF8080operation aborted")
				end	
			end 
		end)	
end
	
local function DCS_closeMailbox()	
	DCS_mailActionCleanup()
	CloseMailbox()
end	

--------------------------------------------------------------------


local function DCS_tryCountNextMail()
	if mailAction~=MAIL_ACTION_COUNT then return end
	_outd("Counting Next")
	while curMailIndex < #mailToCount do 
		curMailIndex = curMailIndex + 1
		local mailId = mailToCount[curMailIndex]
		local _,_,subject = GetMailItemInfo(mailId)
		if subject then 
	 		_outd("Opening for count: " .. subject)

			local reqResult = RequestReadMail(mailId)
			if reqResult <= REQUEST_READ_MAIL_RESULT_SUCCESS_SERVER_REQUESTED then
				--restart/abort if single mail processing takes too long
				local curMailActionId = mailActionId
				zo_callLater(function () 
						if mailActionId~=curMailActionId then return end
						local lateMailId = mailId
						if mailToCount[curMailIndex]==lateMailId then
							RequestReadMail(lateMailId)
							_out("Count Materials in Mail: restarting")
							zo_callLater(function () 
									if mailActionId~=curMailActionId then return end
									if mailToCount[curMailIndex]==lateMailId then
										DCS_closeMailbox()
										_out("Count Materials in Mail: |cFF8080aborted due to timeout")
									end
								end, MAIL_TIMEOUT_ABORT)  

						end
					end, MAIL_TIMEOUT_RESTART)  

				return
			else	
				_out("Skipping locked mail: " ..subject)
			end	
		end
	end	
	_out("Count Materials in Mail: |c80FF80done")
	DCS_closeMailbox()
--	d(_addon.mailStock)
	_addon.updateStock()
	_addon.showStatusBar(true)
end


local function DCS_countSingleMailMats(eventCode, mailId)
	if mailAction~=MAIL_ACTION_COUNT then return end
	if mailToCount[curMailIndex]~=mailId then return end 
	local _,_,subject,_,_,_,_,_,numAtt = GetMailItemInfo(mailId)
	_outd("Counting: " .. subject)
	ReadMail(mailId)
	for i = 1, numAtt do 
		local itemLink = GetAttachedItemLink(mailId,i,LINK_STYLE_DEFAULT)
		local itemId = GetItemLinkItemId(itemLink)
		if not _addon.mailStock[itemId] then _addon.mailStock[itemId] = 0; end
		local _, stack = GetAttachedItemInfo(mailId,i)
		_addon.mailStock[itemId] = _addon.mailStock[itemId] + stack
	end
	_outd("Counting done: " .. subject)
	zo_callLater(function () DCS_tryCountNextMail() end, MAIL_NEXTOP_DELAY)  
end

function _addon.countMatsInMail()
	if mailAction~=MAIL_ACTION_NONE then 
		_out("Already busy with another mail action")
		return 
	end

	_addon.mailStock = {}

	if GetNumMailItems==0 then 
		_out("Inbox is empty")
		return 
	end

	mailToCount = {}
	mailAction = MAIL_ACTION_COUNT
	mailActionId = GetTimeStamp()
	curMailIndex = 0

	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_OPEN_MAILBOX, function ()
			EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_OPEN_MAILBOX)
			zo_callLater(function () 
					if mailAction~=MAIL_ACTION_COUNT then return end
					_outd("Inbox Opened for Count")

					local mailId = GetNextMailId(nil)
					while mailId do
						local _,_,subject,_,_,_,_,_,numAtt = GetMailItemInfo(mailId) 
						if numAtt>0 then
							mailToCount[#mailToCount+1] = mailId
						end	
						mailId = GetNextMailId(mailId)
					end
					--todo: mailId removal from mailToCount table, just in case...

					EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_READABLE, DCS_countSingleMailMats)
					DCS_regUnexpectedCloseEvent()		
					DCS_tryCountNextMail()
				end, MAIL_OPEN_DELAY)
		end)

	_out("Count Materials in All Mail: please wait...")
	DCS_tryOpenMailbox() 
end

--------------------------------------------------------------------

--mail system is stuttering, occasionally it just stucks and locks the entire inbox
--deleting mails is what stucks the most, so it is separated from looting

local function DCS_tryDeleteNextMail()
	while curMailIndex < #lootedMail do --the loop is only in case some other code messes up with deletion...
		curMailIndex = curMailIndex + 1
		local mailId = lootedMail[curMailIndex]
		local _,_,subject,_,_,_,_,_,numAtt,attMoney = GetMailItemInfo(mailId)
		if subject then
			if numAtt==0 and attMoney==0 then 

	 		_outd("Deleting: " .. subject)

			--restart/abort if single mail loot processing takes too long
				local curMailActionId = mailActionId
				zo_callLater(function () 
						if mailActionId~=curMailActionId then return end
						local lateMailId = mailId
						if lootedMail[curMailIndex]==lateMailId then
							DeleteMail(lateMailId,true)
							_out("Delete Emptied Mail: restarting")

							zo_callLater(function () 
									if mailActionId~=curMailActionId then return end
									if lootedMail[curMailIndex]==lateMailId then
										DCS_closeMailbox()
										_out("Delete Emptied Mail: |cFF8080aborted due to timeout")
									end
								end, MAIL_TIMEOUT_ABORT)  

						end
					end, MAIL_TIMEOUT_RESTART)  

					
				DeleteMail(mailId,true)
				return
			end	
		end	
	end	
	lootedMail = {}
	DCS_closeMailbox()
	_out("Delete Looted Mail: |c80FF80done")
end

local function DCS_mailRemoved(eventCode, mailId)
	if mailAction~=MAIL_ACTION_DELETE then return end
	if lootedMail[curMailIndex]~=mailId then return end 
	DCS_tryDeleteNextMail()
end

function _addon.deleteLootedMail()
	if mailAction~=MAIL_ACTION_NONE then 
		_out("Already busy with another mail action")
		return 
	end

	if #lootedMail==0 then 
		_out("Nothing to delete")
		return 
	end
	
	mailAction = MAIL_ACTION_DELETE
	mailActionId = GetTimeStamp()
	curMailIndex = 0

	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_OPEN_MAILBOX, function ()
			EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_OPEN_MAILBOX)
			zo_callLater(function () 
					if mailAction~=MAIL_ACTION_DELETE then return end
					--todo: get out of the action if we get stuck
					EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_REMOVED, DCS_mailRemoved)
					DCS_regUnexpectedCloseEvent()		
					DCS_tryDeleteNextMail()
				end, MAIL_OPEN_DELAY)
		end)	

	_out("Delete Looted Mail: please wait...")
	DCS_tryOpenMailbox() 
end

----------------------------------------------------------------------

local function DCS_tryLootNextMail()
	if mailAction~=MAIL_ACTION_LOOT then return end
	while curMailIndex < #mailToLoot do --the loop is only in case some other code messes up with deletion...
		curMailIndex = curMailIndex + 1
		local mailId = mailToLoot[curMailIndex]
		local _,_,subject = GetMailItemInfo(mailId)
		if subject then 
	 		_outd("Opening for loot: " .. subject)

			local reqResult = RequestReadMail(mailId)
			if reqResult <= REQUEST_READ_MAIL_RESULT_SUCCESS_SERVER_REQUESTED then
				--restart/abort if single mail loot processing takes too long
				local curMailActionId = mailActionId
				zo_callLater(function () 
						if mailActionId~=curMailActionId then return end
						local lateMailId = mailId
						if mailToLoot[curMailIndex]==lateMailId then
							RequestReadMail(lateMailId)
							_out("Extract from Mail: restarting")

							zo_callLater(function () 
									if mailActionId~=curMailActionId then return end
									if mailToLoot[curMailIndex]==lateMailId then
										if abortOnTimeout then 
											abortOnTimeout = false
											DCS_closeMailbox()
											_out("Extract from Mail: |cFF8080aborted due to timeout")
										else	
											_out("Extract from Mail: |cFF8000skipping|r "  .. subject)
											abortOnTimeout = true
											DCS_tryLootNextMail()
										end	
									end
								end, MAIL_TIMEOUT_ABORT)  

						end
					end, MAIL_TIMEOUT_RESTART)  

				return
			else
				_out("Skipping locked mail: " ..subject)
			end 	
		end
	end	
	DCS_closeMailbox()
	_out("Extract from Mail: |cFFFFFFdone")
	if deleteAfterLoot then 
		deleteAfterLoot = false
		--todo: this may currently fail since I don't wait for close mailbox event from previous action
		zo_callLater(function () _addon.deleteLootedMail() end, 1000)
	end
end

local function DCS_lootSingleMail(eventCode, mailId)
	if mailAction~=MAIL_ACTION_LOOT then return end
	if mailToLoot[curMailIndex]~=mailId then return end 

	abortOnTimeout = false --any succesfull mail read prevents abort on next loot
	ReadMail(mailId)
	local _,_,subject,_,_,fromSystem,fromCustSrv,returned,numAtt,attMoney,codAmount = GetMailItemInfo(mailId)
	--d(subject)
	if not fromCustSrv and not returned and attMoney==0 and codAmount==0 then
		if numAtt>0 then
			_outd(" - looting: " .. subject)
			TakeMailAttachedItems(mailId)
			return
		else 
			_outd(" - skipping empty: " .. subject)
			lootedMail[#lootedMail+1] = mailId
		end
	end	
	zo_callLater(function () DCS_tryLootNextMail() end, MAIL_NEXTOP_DELAY)  
end

local function DCS_takeMailAttSuccess(eventCode, mailId)
	if mailAction~=MAIL_ACTION_LOOT then return end
	if mailToLoot[curMailIndex]~=mailId then return end 
	lootedMail[#lootedMail+1] = mailId
	zo_callLater(function () DCS_tryLootNextMail() end, MAIL_NEXTOP_DELAY)  
end

local function DCS_takeMailAttFail(eventCode)
	if mailAction~=MAIL_ACTION_LOOT then return end
	zo_callLater(function () DCS_tryLootNextMail() end, MAIL_NEXTOP_DELAY)  
end

function _addon.lootHirelingMail(deletef,subjtext)
	local langStrings = _addon.langQuestInfo
	
	if not langStrings then 
		_out("Unsupported language")
		return 
	end

	if mailAction~=MAIL_ACTION_NONE then 
		_out("Already busy with another mail action")
		return 
	end

	mailToLoot = {}
	lootedMail = {}
	_addon.mailStock = {}

	--todo: turn off inventory update upon looting? could actually be a bad idea due to mail system stuttering

	mailAction = MAIL_ACTION_LOOT
	mailActionId = GetTimeStamp()
	curMailIndex = 0
	
	if deletef then deleteAfterLoot = true end
	
	abortOnTimeout = false

--changed EVENT_MAIL_OPEN_MAILBOX to EVENT_MAIL_INBOX_UPDATE, as this is working better since Update 36

	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_INBOX_UPDATE, function ()
			_out("Extract from Mail: mailbox updated, processing...")
	
			EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_MAIL_INBOX_UPDATE)
			zo_callLater(function () 
					if mailAction~=MAIL_ACTION_LOOT then return end
					--todo: get out of the action if we get stuck

					local mailId = GetNextMailId(nil)

					if not mailId then
						DCS_closeMailbox()
						_out("Extract from Mail: |cFF8080mailbox empty or not ready yet|r")
						return
					end	
					
					while mailId do
						local _,_,subject,_,_,fromSystem,fromCustSrv,returned,numAtt,attMoney,codAmount = GetMailItemInfo(mailId)
						local lootf = false
						if not fromCustSrv and not returned and attMoney==0 and codAmount==0 then
							if subjtext and subjtext~="" then
								lootf = string.find(subject,subjtext)
							else
								lootf = FindFromList(string.lower(subject),langStrings["material"])
							end 
						end	
						if lootf then
							if numAtt==0 then
								lootedMail[#lootedMail+1] = mailId
							else	
								mailToLoot[#mailToLoot+1] = mailId
							end	
						end
						mailId = GetNextMailId(mailId)
					end

					EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_READABLE, DCS_lootSingleMail)
					EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, DCS_takeMailAttSuccess)
					EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_INVENTORY_IS_FULL, DCS_takeMailAttFail)
					DCS_regUnexpectedCloseEvent()		
					DCS_tryLootNextMail()
				end, MAIL_OPEN_DELAY)	
		end)

	_out("Extract from Mail: please wait...")
	DCS_tryOpenMailbox() 
end
