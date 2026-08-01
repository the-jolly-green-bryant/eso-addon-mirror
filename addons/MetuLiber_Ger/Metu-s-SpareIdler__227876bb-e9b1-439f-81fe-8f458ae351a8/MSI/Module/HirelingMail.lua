-- HirelingMail.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

local hirelingMailsMailSubjects = {
	["Raw Enchanter Materials"] = true ,
	["Raw Clothier Materials"] = true ,
	["Raw Blacksmith Materials"] = true ,
	["Raw Woodworker Materials"] = true ,
	["Raw Provisioner Materials"] = true ,
	["Schreinermaterial"] = true,
	["Versorgerzutaten"] = true,
	["Schneidermaterial"] = true,
	["Verzauberermaterial"] = true,
	["Schmiedematerial"] = true,
}

local hirelingMails = {}

local currentWorkingMail
local function lootMails()
	if #hirelingMails == 0 then
		MSI.Print("d", GetString(MSI_MOD_HIRELING_MAILS_DONE))
		return
	else
		local mailId = hirelingMails[1]
		-- d(mailId)
		currentWorkingMail = mailId
		local requestResult = RequestReadMail(mailId)
		if requestResult and requestResult <= REQUEST_READ_MAIL_RESULT_SUCCESS_SERVER_REQUESTED then
		end
		zo_callLater(function()
			if currentWorkingMail == mailId and not IsReadMailInfoReady(mailId) then
				RequestReadMail(mailId)
			end 
		end, math.max(GetLatency()+10, 300))
	end
end

local function findLootableMails()
	if not MSI.SVars.IsHirelingMail then return end
	
	hirelingMails = {}
	local nextMail = GetNextMailId(nil)
	if not nextMail then
	 	MSI.Print("d", GetString(MSI_MOD_HIRELING_MAILS_NONE))
	 	EVENT_MANAGER:UnregisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_READABLE)
	 	return
	end
	
	while nextMail do
		local  _,_,subject, _,_,system,customer, _, numAtt, money = GetMailItemInfo (nextMail)
		if not customer and money == 0 and system and hirelingMailsMailSubjects[subject] then
			if false or numAtt > 0 then
			-- if #hirelingMails < 3 then
				-- hirelingMails[nextMail] = true
				table.insert(hirelingMails,  nextMail)
			end
			-- end
			-- DeleteMail(mailId, true)
		end
		nextMail = GetNextMailId(nextMail)
	end

	if #hirelingMails > 0 then
		MSI.Print("d", zo_strformat(GetString(MSI_MOD_HIRELING_MAILS_FOUND), #hirelingMails))
		zo_callLater(lootMails, math.max(GetLatency()+10, 300))
	else
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_READABLE)
		MSI.Print("d", GetString(MSI_MOD_HIRELING_MAILS_NONE))
	end
end

local lootReadMail
local function deleteLootedMail(mailId)
	local  _,_,subject, _,_,system,customer, _, numAtt, money = GetMailItemInfo(mailId)
	if (numAtt > GetNumBagFreeSlots(1)) then
		return
	end
	if (numAtt <= GetNumBagFreeSlots(1) or IsESOPlusSubscriber()) and numAtt>0 then
		MSI.Print("d", GetString(MSI_MOD_HIRELING_MAILS_FAILED))
		lootReadMail(1, mailId)
		return
	end
	if false and numAtt == 0 then
		DeleteMail(mailId, true)
	end

	if hirelingMails[1] == mailId then
		table.remove(hirelingMails, 1)
		zo_callLater(lootMails, math.max(GetLatency()+10, 300))
	end
end

local antiKick = 0
local function lootReadMail(event, mailId)
	if not IsReadMailInfoReady(mailId) and (FindFirstEmptySlotInBag(BAG_BACKPACK) or IsESOPlusSubscriber()) then
		-- d("Stop")
		zo_callLater(function() lootMails() end , 10 )
		return
	end
	local  _,_,subject, _,_,system,customer, _, numAtt, money = GetMailItemInfo(mailId)
	if not customer and money == 0 and system and hirelingMailsMailSubjects[subject] then
		if antiKick>40 then
			antiKick = 0
			return
		end
		if numAtt > 0 and (FindFirstEmptySlotInBag(BAG_BACKPACK) or IsESOPlusSubscriber()) then
			MSI.Print("d", zo_strformat(GetString(MSI_MOD_HIRELING_MAILS_GET), subject))
			antiKick = antiKick + 1
			ZO_MailInboxShared_TakeAll(mailId)
			zo_callLater(function() deleteLootedMail(mailId) end, math.max(GetLatency()+10, 300))
			return
		elseif FindFirstEmptySlotInBag(BAG_BACKPACK) == nil and numAtt > 0 then
			return
		else
			MSI.Print("d", GetString(MSI_MOD_HIRELING_MAILS_DELETE))
			deleteLootedMail(mailId)
			return
		end
	end
end

local function lootHireling(event)
	--MSI.Print("d", "Beginn der Bugs!")
	EVENT_MANAGER:RegisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_REMOVED, function(event, mailId)if hirelingMails[1] == mailId then
		table.remove(hirelingMails, 1)
		if #hirelingMails == 0 then
			--MSI.Print("d", "COMPLETETIONS")
		else
			lootMails()
		end
	end
	end)
	EVENT_MANAGER:RegisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, function(event, mailId) 
		local toremove
		for k, v in pairs(hirelingMails) do 
			if v == mailId then 
				local _,_,sub = GetMailItemInfo(mailId)
				MSI.Print("d", zo_strformat(GetString(MSI_MOD_HIRELING_MAILS_PICKUP), sub))
				if not MSI.SVars.IsHirelingMail then
					table.remove(hirelingMails, k)
					break
				end
			end 
		end 
	end )
	if MSI.SVars.IsHirelingMail then
		findLootableMails()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_READABLE, lootReadMail)
	end
end

function MSI.InitModHirelingMail()
	EVENT_MANAGER:RegisterForEvent(MSI.Name.."MailBox", EVENT_MAIL_OPEN_MAILBOX, function() lootHireling() end)
end
-- eof