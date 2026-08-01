MailerDemon = MailerDemon or {}
local MailerDemon = MailerDemon

MailerDemon.db = nil
MailerDemon.mdConfig = nil
MailerDemon.NumSlot = 1
MailerDemon.TaskRunning = nil
MailerDemon.ActiveButton = nil
MailerDemon.Success = false
MailerDemon.Delay = 3000
MailerDemon.ActiveTasks = {
	['Bait'] = false,
	["Bounce"] = false,
	["Decon1"] = false,
	["Decon2"] = false,
	["Decon3"] = false,
	["Decon4"] = false,
	["Ref"] = false,
	["Materials1"] = false,
	["Materials2"] = false,
}

local Config = MailerDemon_Config

local defaults =
{
	shutUp = false,
	minQuality = 2,
	ExcludeItemSaver = true,
	ExcludeCrafted = true,
	MinNumber = 1,
	delay = 3000,

	MailSettings = {

		['Bait'] = {
			['Name'] = 				'Bait',
			['tooltipDescriptor'] = 'Sending bait: ',
			['IsActive'] =			true,
			['NextTask'] =			nil,

			['To'] = 				'',
			['Subject'] = 			'Zombie assembly!',

			['SendRaw'] = 			true,
			['SendMaterials'] = 	true, -- the only one that won't be ignored
			['SendBoosters'] = 		true,

		},

		['Bounce'] = {

			['Name'] = 				'Bounce',
			['tooltipDescriptor'] = 'Sending bouncies: ',
			['IsActive'] =			false,
			['NextTask'] =			nil,


			['To'] = 				'',
			['Subject'] = 			'bounce',

			['KeepOrnate'] = 		false,
			['KeepMaxLevel'] = 		false,


			['Send'] = 				false,
			['SendRaw'] = 			false,
			['SendMaterials'] = 	false,
			['SendBoosters'] = 		false,
			['SendConsumables'] = 	false, 
			['SendGear'] 		=   false,

			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	false,
			['SendAlchemy'] = 		false,
			['SendFood'] = 			false,
			['SendBait'] = 			false,



			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,

		},

		['Decon'] = {
			['Name'] = 				'Decon',
			['tooltipDescriptor'] = 'Sending deconstructables: ',
			['NextTask'] =			'Decon1',
			['IsActive'] = 			true,
		},
		['Decon1'] = {

			['Name'] = 				'Decon1',
			['tooltipDescriptor'] = '',
			['IsActive'] =			false,
			['NextTask'] =			'Decon2',

			['To'] = 				'',
			['Subject'] = 			'Metal Decon',

			['KeepOrnate'] = 		false,
			['KeepMaxLevel'] = 		false,

			['SendBlacksmithing'] =	true,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	false,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false, -- the only one that won't be ignored
			['SendBoosters'] = 		false,

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,


		},
		['Decon2'] = {

			['Name'] = 				'Decon2',
			['tooltipDescriptor'] = 'Sending deconstructables: ',
			['IsActive'] =			false,
			['NextTask'] =			'Decon3',

			['To'] = 				'',
			['Subject'] = 			'Cloth Decon',

			['KeepOrnate'] = 		false,
			['KeepMaxLevel'] = 		false,

			['SendBlacksmithing'] =	false,
			['SendClothing']	=	true,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	false,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false, -- the only one that won't be ignored
			['SendBoosters'] = 		false,

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,



		},
		['Decon3'] = {
			['Name'] = 				'Decon3',
			['tooltipDescriptor'] = 'Sending deconstructables: ',
			['IsActive'] =			false,

			['To'] = 				'',
			['Subject'] = 			'Wood Decon',
			['NextTask'] =			'Decon4',

			['KeepOrnate'] = 		false,
			['KeepMaxLevel'] = 		false,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false, -- the only one that won't be ignored
			['SendBoosters'] = 		false,

			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	true,
			['SendEnchanting'] =	false,

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,


		},
		['Decon4'] = {
			['Name'] = 				'Decon4',
			['tooltipDescriptor'] = 'Sending deconstructables: ',
			['IsActive'] =			false,

			['To'] = 				'',
			['Subject'] = 			'Glyph Decon',
			['NextTask'] =			nil,

			['KeepOrnate'] = 		false,
			['KeepMaxLevel'] = 		false,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false, -- the only one that won't be ignored
			['SendBoosters'] = 		false,

			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	true,

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,

		},

		['Ref'] = {
			['Name'] = 				'Ref',
			['tooltipDescriptor'] = 'Sending refineables: ',
			['IsActive'] =			false,
			['NextTask'] =			nil,

			['To'] = 				'',
			['Subject'] = 			'Refineables',
			['KeepMaxLevel'] = 		false,

			['SendRaw'] = 			false,
			['MinQuality'] = 		1,
			['MaxQuality'] = 		1,


			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
		},

		['Materials'] = {
			['Name'] = 				'Materials',
			['tooltipDescriptor'] = 'Sending crafting material: ',
			['NextTask'] =			"Materials1",
			['IsActive'] = 			false,
		},
		["Materials1"] = {

			['Name'] = 				'Materials1',
			['tooltipDescriptor'] = 'Sending crafting material',
			['To'] = 				'',
			['Subject'] = 			'Material',
			['KeepMaxLevel'] = 		false,
			['NextTask'] =			"Materials2",

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false,
			['SendBoosters'] = 		false,

			["SendFood"] = 			false,
			["SendAlchemy"] = 		false,
			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	false,
			['KeepMaxLevel'] = 		false,

		},
		["Materials2"] = {

			['Name'] = 				'Materials2',
			['tooltipDescriptor'] = 'Sending crafting material',
			['To'] = 				'',

			['NextTask'] =			nil,
			['Subject'] = 			'Material',
			['KeepMaxLevel'] = 		false,

			['MinQuality'] = 		1,
			['MaxQuality'] = 		3,

			['SendRaw'] = 			false,
			['SendMaterials'] = 	false,
			['SendBoosters'] = 		false,

			["SendFood"] = 			false,
			["SendAlchemy"] = 		false,
			['SendBlacksmithing'] =	false,
			['SendClothing']	=	false,
			['SendWoodworking'] =	false,
			['SendEnchanting'] =	false,
			['KeepMaxLevel'] = 		false,

		},

	}

}


function MailerDemon.New( ... )
	local result =  ZO_Object.New( self )
	return result
end

function MailerDemon_Initialized(eventCode, addonName)
	if addonName ~="MailerDemon" then return end
    --MailerDemon = MailerDemon.New()
    MailerDemon.db = ZO_SavedVars:NewAccountWide( 'MailerDemon_Db', 1.3, nil, defaults )
    MailerDemon.GetDb()
    MailerDemon.mdConfig = MailerDemonMenu:New( MailerDemon.db )

    SLASH_COMMANDS['/sendmails'] = function() MailerDemon.SendMails() end

    --MailerDemon.ToggleAutoLoot()
    MailerDemon_RegisterEvents()
    MailerDemon_HideButtons()
end

function MailerDemon.GetDb()
	if nil == MailerDemon.db then 
		MailerDemon.db = ZO_SavedVars:NewAccountWide('MailerDemon_Db', 1.3, nil, defaults )
	end
	return MailerDemon.db
end

function MailerDemon.MailSettings()
	return MailerDemon.GetDb().MailSettings
end

function MailerDemon.IsActive(craftName)
	if nil == craftName then craftName = MailerDemon.TaskRunning end
	if nil == craftName then return end
	local mailSettings = MailerDemon.MailSettings()
	
	if craftName == "Materials" then 
		return ( 
			(mailSettings.Materials1.IsActive and mailSettings.Materials1.To ~= "") or 
			(mailSettings.Materials2.IsActive and mailSettings.Materials2.To ~= "")
		)
	elseif craftName == "Decon" then
		return ( 
			mailSettings.Decon.IsActive  or
			(mailSettings.Decon1.IsActive and mailSettings.Decon1.To ~= "") or
			(mailSettings.Decon2.IsActive and mailSettings.Decon2.To ~= "") or
			(mailSettings.Decon3.IsActive and mailSettings.Decon3.To ~= "") or
			(mailSettings.Decon4.IsActive and mailSettings.Decon4.To ~= "")
		)
	else
		return (mailSettings[craftName].IsActive and mailSettings[craftName].To ~= "")   
	end
end

--[[ Utility functions]]
function MailerDemon.GetCurrentConfig(craftName)

	if nil == craftName then craftName = MailerDemon.TaskRunning end
	craftName = tostring(craftName):gsub("MailerDemon_Button", "")
	local mailSettings = MailerDemon.MailSettings()
	
	if craftName == "Materials" then

		if mailSettings.Materials1.IsActive then return mailSettings.Materials1 end
		if mailSettings.Materials2.IsActive then return mailSettings.Materials2 end

		elseif craftName == "Decon" then
			if mailSettings.Decon1.IsActive then return mailSettings.Decon1 end
			if mailSettings.Decon2.IsActive then return mailSettings.Decon2 end
			if mailSettings.Decon3.IsActive then return mailSettings.Decon3 end
			if mailSettings.Decon4.IsActive then return mailSettings.Decon4 end

		else
			return mailSettings[craftName]
		end

	end

function isItemSaved(bagSlot)

	local ret = false
	
	if IsItemPlayerLocked(BAG_BACKPACK, bagSlot) then return true end
	if IsItemBound(BAG_BACKPACK, bagSlot) then return true end
	if (nil ~= ItemSaver) then
		ret = ret or ItemSaver_IsItemSaved(BAG_BACKPACK, bagSlot)
	end
	if (nil ~= FCOIS) then
		local itemMarked = FCOIsMarked(GetItemInstanceId(BAG_BACKPACK, bagSlot), -1)
		-- d(zo_strformat("item is marked: <<1>>: <<2>>", itemLink, tostring(itemMarked )))
		if itemMarked then return true end	
		
	end
	if MailerDemon.db.ExcludeCrafted and (not tostring(GetItemCreatorName(BAG_BACKPACK, bagSlot)) == "") then
		ret = ret or GetRawUnitName("player"):gsub("^Fx", ""):match(GetItemCreatorName(BAG_BACKPACK, bagSlot))
	end

	

	return ret

end

local function checkSendItem(bagSlot, currConfig, taskRunning)
	if isItemSaved(bagSlot) then return false end
	return MailerDemon.CheckSendItem(bagSlot, currConfig, taskRunning)
end


--[[   _===_===_=============_===_===_===_=========_=__================_=
	  /_\ | |_| |_ __ _  ___| |__   /_\  _ __   __| / _\ ___ _ __   __| |
	 //_\\| __| __/ _` |/ __| '_ \ //_\\| '_ \ / _` \ \ / _ \ '_ \ / _` |
	/  _  \ |_| || (_| | (__| | | /  _  \ | | | (_| |\ \  __/ | | | (_| |
	\_/ \_/\__|\__\__,_|\___|_| |_\_/ \_/_| |_|\__,_\__/\___|_| |_|\__,_|
=====================================================================    ]]
function MailerDemon.AttachAndSend()

	-- this is where the magick happens!

	local db = 				MailerDemon.GetDb()
	local canAttach, subject, recipient, taskRunning, currConfig = nil
	taskRunning 		= MailerDemon.TaskRunning
	currConfig 			= MailerDemon.GetCurrentConfig(taskRunning)


	if not currConfig then					MailerDemon.Report("no current Config") return false end
	if not MailerDemon.Success then			MailerDemon.Report("we're not supposed to be running anyway") return false end
	if not taskRunning then 				MailerDemon.Report("no job to do") return false end



	local bagSlots 		= GetBagSize and GetBagSize(BAG_BACKPACK) or select(2, GetBagInfo(BAG_BACKPACK))
	local numSlot 		= 1



	-- if keepRunning is false that means that we won't come here for a third time - we're
	-- sending refined materials now
	-- before that we're sending raw materials
	MailerDemon.Success = false

	if  currConfig.IsActive then
		-- d(" ")
		-- d(" ")
		-- d("================================================")
		-- d("Sending " .. currConfig.Name ..
		-- ", Cloth: " .. tostring(currConfig.SendClothing) ..
		-- ", Metal: " .. tostring(currConfig.SendBlacksmithing) ..
		-- ", Wood: " .. tostring(currConfig.SendWoodworking) ..
		-- ", Material: " .. tostring(currConfig.SendMaterials) ..
		-- ", Raw: " .. tostring(currConfig.SendRaw)
        
		-- )
		-- d("================================================")
		-- d("================================================")

		subject = currConfig.Subject
		recipient = currConfig.To

		--MailerDemon.Report(recipient)


		for bagSlot = 0, bagSlots, 1 do
			if checkSendItem(bagSlot, currConfig, taskRunning) then  -- make sure the item should be sent
				if CanQueueItemAttachment(1, bagSlot, numSlot) then	 -- make sure that the item can be attached to a mail (not bound etc)
					QueueItemAttachment(1, bagSlot, numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then
						--ClearQueuedMail()
						MailerDemon.Report("About to send 1 mail to ".. recipient .. " containing 6 items")
						SendMail(recipient, subject, "")
						MailerDemon.Success = true
						numSlot=1
						return zo_callLater(function() MailerDemon.EndTask() end, delay)
					end
				end
			end

		end -- for end

		if(numSlot >= 2) then

			if not ((numSlot - 1) < db.MinNumber) then
				MailerDemon.Report("About to send 1 mail to ".. recipient .." containing ".. numSlot -1 .." items")
				SendMail(recipient,subject,"")
				MailerDemon.Success = true
				return zo_callLater(function() MailerDemon.EndTask() end, delay)
			end
		end
		-- all mails are sent - keepRunning is set - we can ascend again
		return MailerDemon.EndTask()
	end


	return MailerDemon.EndTask()


end



--[[ __================_==============_=_=====
	/ _\ ___ _ __   __| | /\/\   __ _(_) |___
	\ \ / _ \ '_ \ / _` |/    \ / _` | | / __|
	_\ \  __/ | | | (_| / /\/\ \ (_| | | \__ \
	\__/\___|_| |_|\__,_\/    \/\__,_|_|_|___/
===========================================    ]]
function MailerDemon.SendMails()

	--if MailerDemon.ActiveButton then MailerDemon.ActiveButton:SetEnabled(true) end
	local taskRunning = MailerDemon.TaskRunning
	-- d("SendMails called with " .. tostring(taskRunning))

	if not taskRunning then MailerDemon.Report("MailerDemon is done!") return MailerDemon.Reset() end

	local currConfig = MailerDemon.db.MailSettings[taskRunning]
	MailerDemon.Report("Sending .. " .. tostring(MailerDemon.TaskRunning))
	MailerDemon.AttachAndSend()

end



--[[  ===___=========   _=    _____=========_====
		/__ \____    __| |   /__   \_ _ ___| | __
	   /|__|| '_ \  / _` |     / // _` / __| |/ /
	   ||__|| | | |(_|_| |    / /| (_| \__ \   <
		\__/|_| |_| \__,_|    \/  \__,_|___/_|\_\
=====================================    ]]

function MailerDemon.EndTask()

	if not MailerDemon.TaskRunning then
		MailerDemon.Success = false
		MailerDemon.Reset()
		return
	end

	local delay = MailerDemon.Delay
	local currConfig = MailerDemon.db.MailSettings[MailerDemon.TaskRunning]

	if MailerDemon.Success then
		return zo_callLater(function() MailerDemon.SendMails() end, delay)
	else
		MailerDemon.TaskRunning = currConfig.NextTask
		delay = 0
		MailerDemon.Success = true
		return zo_callLater(function() MailerDemon.SendMails() end, delay)
	end


end


function MailerDemon.Report(recipient)

	if MailerDemon.db.shutUp then return end
	local taskRunning = MailerDemon.TaskRunning
	local output = ""
	if taskRunning then
		output = "Sending "

		if MailerDemon.TaskRunning == "Ref" then
			output = output .. "Refineables"
			elseif MailerDemon.TaskRunning:match("Materials") then
			output = output .. "Materials"
			else output = output .. taskRunning
		end

		if  MailerDemon.TaskRunning:match("1") then
			output = output .. " 1 "
			elseif  MailerDemon.TaskRunning:match("2") then
			output = output .. " 2 "
			elseif  MailerDemon.TaskRunning:match("3") then
			output = output .. " 3 "
		end


		output = output .. " to " .. recipient
		else
		output = "Nothing left to send."
	end
	
	if nil == output then return end
	if tostring(output):match("Nothing left to send.") then
		d(output)
	end

end


function MailerDemon.Reset()

	MailerDemon.TaskRunning = nil
	MailerDemon.Success = false
	for key, value in pairs(MailerDemon.ActiveTasks) do
		value = false
	end

	MailerDemon.DeactivateButton()		
	-- ClearQueuedMail()

	return false
end

function MailerDemon_MailFail()
	MailerDemon.Reset()
end

function MailerDemon_OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, inCombat)
	if inCombat then
		MailerDemon_MailFail()
	end
end


-- we call this on buttonPush
function MailerDemon.SetupActiveTasks(taskRunning)
	MailerDemon.TaskRunning = taskRunning
	
	local mailSettings = MailerDemon.db.MailSettings

	-- iterate over mail settings - check all child tasks, set their activity value
	for key, values in pairs(mailSettings) do
		if key:match(taskRunning) then
			MailerDemon.ActiveTasks[key] = values.IsActive
		end
	end

	-- now override possible "false"s from child tasks
	if mailSettings[taskRunning].IsActive then
		MailerDemon.ActiveTasks[taskRunning] = true
	end

end


EVENT_MANAGER:RegisterForEvent("MailerDemon_Initialized", EVENT_ADD_ON_LOADED, MailerDemon_Initialized)
