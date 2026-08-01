AIList = {}

AIList.defaults =  {
    AffectedPlayers = {},     
}

AIList.settings = nil

AIList.defaultGroupEnterHandler = nil
AIList.defaultGroupExitHandler = nil


function AIList.BlockPlayer(playerName, note)
	if not AIList.settings.AffectedPlayers[playerName] then
		AIList.settings.AffectedPlayers[playerName] = { blocked = true, note = note }		
		d("Player " .. playerName .. " added to block list. Reason: " .. note)
	else	
		AIList.settings.AffectedPlayers[playerName].blocked = true
		d("Player " .. playerName .. " blocked. Reason: " .. note)
	end

	AIList_PlayersList:updateData()
end		

function AIList.EditNote(playerName, note)
	if not AIList.settings.AffectedPlayers[playerName] then
		AIList.settings.AffectedPlayers[playerName] = { blocked = false, note = note }		
		d("Note for " .. playerName .. " added. Note: " .. note)
	else	
		AIList.settings.AffectedPlayers[playerName].note = note
		d("Note for " .. playerName .. " updated. Note: " .. note)
	end

	AIList_PlayersList:updateData()
end	

function AIList:NormalizePlayerName(name)	
    if not name then return "" end
	 if type(name) ~= "string" then
        d("NormalizePlayerName: Expected string, got "..tostring(type(name)))
        return name
    end
    if string.sub(name, 1, 1) == "@" then
        return name
    else
        return "@" .. name
    end
end

function AIList:ShowEditNote(name, note)
	local nameMsg = "Edit note for "..name 
	local confirmDialog =
	{
		title = { text = nameMsg},
		mainText = { text = "Enter note" },
		editBox = {			
            selectAll = true
        },
		buttons =
		{
			{
				text = "Edit note",
				callback = function(dialog)
					local editBox = dialog:GetNamedChild("EditBox")
					local note = editBox:GetText()
					local name = dialog.data.playerName
 					AIList.EditNote(name, note)
				end
			},
			{
                text =       SI_DIALOG_CANCEL,
                callback =  function(dialog) end,
            },
		}
   }
 
   ZO_Dialogs_RegisterCustomDialog("AIL_ADD_EDIT_NOTE", confirmDialog)
   ZO_Dialogs_ReleaseDialog("AIL_ADD_EDIT_NOTE", false)
   ZO_Dialogs_ShowDialog("AIL_ADD_EDIT_NOTE",{ playerName = name,  block = false}, {initialEditText = note})
end

function AIList:ShowBlockPlayer(name, note)
	local nameMsg = "Block person "..name 
	local confirmDialog =
	{
		title = { text = nameMsg},
		mainText = { text = "Enter note" },
		editBox = {			
            selectAll = true
        },
		buttons =
		{
			{
				text = "Block",
				callback = function(dialog)
					local editBox = dialog:GetNamedChild("EditBox")
					local note = editBox:GetText()
					local name = dialog.data.playerName
 					AIList.BlockPlayer(name, note)
				end
			},
			{
                text =       SI_DIALOG_CANCEL,
                callback =  function(dialog) end,
            },
		}
   }
 
   ZO_Dialogs_RegisterCustomDialog("AIL_BLOCK", confirmDialog)
   ZO_Dialogs_ReleaseDialog("AIL_BLOCK", false)
   ZO_Dialogs_ShowDialog("AIL_BLOCK",{ playerName = name,  block = false}, {initialEditText = note})
end


function AIList.AddCustomMenuItemGuild(rowData)	
	AIList.AddCustomMenuItem(rowData.displayName)
end

function AIList.AddCustomMenuItem(playerName, rawName, shortMode)
	playerName = AIList:NormalizePlayerName(playerName)

	--don't let user block himself :)
	accountPlayerName = AIList:NormalizePlayerName(GetDisplayName())
	if accountPlayerName == playerName then return end

	if not shortMode then
		AddCustomMenuItem("---Advanced Ignore List---", function() end)
	end

	if AIList.settings.AffectedPlayers[playerName] then
		local note = AIList.settings.AffectedPlayers[playerName].note
		local blocked = AIList.settings.AffectedPlayers[playerName].blocked

		if (blocked) then
			AddCustomMenuItem("Unblock player (AIL)", function()        
				AIList.settings.AffectedPlayers[playerName].blocked = false	
				AIList_PlayersList:updateData()	
			end)
		else 
			AddCustomMenuItem("Block player (AIL)", function()        
				AIList:ShowBlockPlayer(playerName, note)
			end)			
		end

		AddCustomMenuItem("Edit note (AIL)", function()        						
			AIList:ShowEditNote(playerName, note)			
		end)	
		if not shortMode then
			if (AIList.settings.AffectedPlayers[playerName].note ~= nil) then
				AddCustomMenuItem("NOTE: "..note, function()        
					d("Note for "..playerName .. ": "..AIList.settings.AffectedPlayers[playerName].note)
				end)	
			end		
		end
	else
		AddCustomMenuItem("Add note (AIL)", function()        
			AIList:ShowEditNote(playerName, "")
		end)	
		AddCustomMenuItem("Block player (AIL)", function()        
			AIList:ShowBlockPlayer(playerName, "")
		end)
    end    
end

function AIList:FindPlayerNameObject(control,controlName)
    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)		

        if child:GetName():find(controlName) then
            return child
        end
    end
end


function AIList:UpdateNameColor(control, controlName,data)   
	local addonData = AIList.settings.AffectedPlayers[data.displayName]
	local online = data.online
	local color		

	if addonData then
		if addonData.blocked then
        	color = ZO_ColorDef:New("FF0000")        	
		elseif addonData.note ~= "" then
			color = ZO_ColorDef:New("FFEE11")        	
		end
	end    

	if color then
		if not online then			
			local r, g, b = color:UnpackRGB()
			r = r * 0.5
			g = g * 0.5
			b = b * 0.5
			color = ZO_ColorDef:New(r, g, b)
		end

		if controlName then
			controlName:SetColor(color:UnpackRGB())
		end
	end

	local WHITE_PX = "EsoUI\\Art\\miscellaneous\\help_icon.dds"

		local label = controlName
		local icon = control:GetNamedChild("StatusSquare")
		if not icon then
			icon = control:CreateControl(control:GetName().."StatusSquare", CT_TEXTURE)
			icon:SetTexture(WHITE_PX)
			icon:SetParent(control)
			icon:SetDimensions(36, 36)
			icon:ClearAnchors()
			icon:SetDrawLayer( 5 )			
			icon:SetAnchor(LEFT, label, RIGHT, -36, 0)			
		end

		local entry = addonData
		if entry then
			if entry.blocked then
				icon:SetColor(1, 0, 0, 1)     
				icon:SetHidden(false)				
			elseif entry.note ~= "" then
				icon:SetColor(1, 0.65, 0, 1)   
				icon:SetHidden(false)
			else
				icon:SetHidden(true)
			end
		else
			icon:SetHidden(true)
		end
end

function AIList:ShowBlockedPlayersList()
    AIList_PlayersList:toggle()                    
end

AIList.formatter = nil



function AIList:Initialize()
	EVENT_MANAGER:RegisterForEvent("AIListInit", EVENT_PLAYER_ACTIVATED, function()
		CHAT_SYSTEM:AddMessage("|c00ff00 Additional ignore list activated!|r")
		EVENT_MANAGER:UnregisterForEvent("AIListInit", EVENT_PLAYER_ACTIVATED)		
		
		--AIListBlockedPlayers:init(AIListBlockedPlayersDialog)		
		

		AIList_PlayersList:init()

		if pChat == nil then
			if not AIList.formatter then
				AIList.formatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
			end
        	--pChat is not loaded: Add your own handler to the CHAT_ROUTER
        	--I'd always check if any other chat addon is active though and maybe thus always add the code below, even if pChat is not loaded
        	--as it will keep exisitng callback functions of other addons or event add to the original vanilla chat formatter callback function
        	CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(channelID, from, text, isCustomerService, fromDisplayName)					
					local playerName = AIList:NormalizePlayerName(fromDisplayName)
					if channelID ~= 4 then
						if AIList.settings.AffectedPlayers[playerName] and AIList.settings.AffectedPlayers[playerName].blocked then	
							return nil
						end				
					else
						if AIList.settings.AffectedPlayers[playerName] and AIList.settings.AffectedPlayers[playerName].blocked then	
							CHAT_SYSTEM:AddMessage("|cff0000 You sent message to blocked player!|r")		
						end
					end
					return AIList.formatter(channelID, from, text, isCustomerService, fromDisplayName)
				end)
    	else
	        --pChat is loaded
        	--!!!ATTENTION!!!
        	--Do the following at EVENT_PLAYER_ACTIVATED after pChat has set CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, pChatChatHandlersMessageChannelReceiver)
        	--Get all chat formatters. Table formatters will contain the different chat event entries, like EVENT_CHAT_MESSAGE_CHANNEL now
        	local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
        	--Get the chat callback function for EVENT_CHAT_MESSAGE_CHANNEL of pChat
        	local originalpChatFormatter = formatters[EVENT_CHAT_MESSAGE_CHANNEL]
        	if originalpChatFormatter then 
			--Either:
				--Post Hook pChat's EVENT_CHAT_MESSAGE_CHANNEL callbackFunction by re-applying the own handler function
				--which first calls pChat's function, and then your own code
				CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(channelID, from, text, isCustomerService, fromDisplayName)
					
					local playerName = AIList:NormalizePlayerName(fromDisplayName)
				
					if channelID ~= 4 then
						if AIList.settings.AffectedPlayers[playerName] and AIList.settings.AffectedPlayers[playerName].blocked then	
							--d("Blocked message from: "..playerName)
							return nil
						end		
					else
						if AIList.settings.AffectedPlayers[playerName] and AIList.settings.AffectedPlayers[playerName].blocked then	
							CHAT_SYSTEM:AddMessage("|cff0000 You sent message to blocked player!|r")		
						end
					end
					return originalpChatFormatter(channelID, from, text, isCustomerService, fromDisplayName)				
				end)
        	end
    	end



	
		
	end)

	AIList.settings = ZO_SavedVars:NewAccountWide("AdditionalIgnoreList", 1, nil, AIList.defaults)

	--add custom menu
	LibCustomMenu:RegisterPlayerContextMenu(self.AddCustomMenuItem, LibCustomMenu.CATEGORY_LATE)
	LibCustomMenu:RegisterGroupListContextMenu(self.AddCustomMenuItemGuild, LibCustomMenu.CATEGORY_LATE)
	LibCustomMenu:RegisterGuildRosterContextMenu(self.AddCustomMenuItemGuild, LibCustomMenu.CATEGORY_LATE)
	LibCustomMenu:RegisterFriendsListContextMenu(self.AddCustomMenuItemGuild, LibCustomMenu.CATEGORY_LATE)	
	
	--change user name color in lists

	ZO_PostHook("ZO_SocialList_ColorRow", function(control, data, displayNameTextColor, iconColor, otherTextColor)
        AIList:UpdateNameColor(control, AIList:FindPlayerNameObject(control,"DisplayName"), data)
    end)

	SLASH_COMMANDS["/ail"] = function(extra)
    	local arg1, arg2, arg3 = extra:match("^(%S+)%s+(%S+)%s+(.*)$")
    	if (arg1 == "block") then
			if (arg2 ~= nil) then		
				accountPlayerName = AIList:NormalizePlayerName(arg2)		
				AIList.BlockPlayer(accountPlayerName, arg3)				
			end
		elseif (arg1 == "unblock") then
			if (arg2 ~= nil) then		
				accountPlayerName = AIList:NormalizePlayerName(arg2)		
				if AIList.settings.AffectedPlayers[accountPlayerName] then
					AIList.settings.AffectedPlayers[accountPlayerName].blocked = false	
				end
			end
		elseif (arg1 == nil) then --show list		
			AIList:ShowBlockedPlayersList()			
		end		
	end

	ZO_PostHook(GROUP_LIST, "SetupGroupEntry", function(self, control, data) 
		local text = data.displayName
		local data = AIList.settings.AffectedPlayers[control.dataEntry.data.displayName]
		
		control.characterNameLabel:SetText(text)
		
		local WHITE_PX = "EsoUI\\Art\\miscellaneous\\help_icon.dds"

		local label = control.characterNameLabel
		
		local icon = label:GetNamedChild("StatusSquare")
		if not icon then
			icon = label:CreateControl(label:GetName().."StatusSquare", CT_TEXTURE)
			icon:SetTexture(WHITE_PX)
			icon:SetParent(label)
			icon:SetDimensions(36, 36)
			icon:ClearAnchors()
			icon:SetDrawLayer( 2 )			
			icon:SetAnchor(LEFT, label, RIGHT, -36, 0)
		end	
		
		local entry = data
		if entry then
			if entry.blocked then
				icon:SetColor(1, 0, 0, 1)       
				icon:SetHidden(false)				
			elseif entry.note ~= "" then
				icon:SetColor(1, 0.65, 0, 1) 
				icon:SetHidden(false)
			else
				icon:SetHidden(true)
			end
		else
			icon:SetHidden(true)
		end
	end)





	--change reticle color
	EVENT_MANAGER:RegisterForEvent("AIList_TargetChange", EVENT_RETICLE_TARGET_CHANGED, function()
		local displayName = GetUnitDisplayName("reticleover")
		if not displayName or displayName == "" then return end

		local label = ZO_TargetUnitFramereticleoverName
		if not label then return end

		local entry = AIList.settings.AffectedPlayers[displayName]
		if not entry then
			label:SetColor(1, 1, 1, 1)
			return
		end

		local color
		if entry.blocked then
			color = ZO_ColorDef:New("FF0000")
		elseif entry.note and entry.note ~= "" then
			color = ZO_ColorDef:New("FFEE11")
		end

		if color then
			label:SetColor(color:UnpackRGB())
			text = label:GetText()
			if entry.note and entry.note then
				label:SetText(text.." - "..entry.note)
			end
		end
	end)
end

local function OnAddonLoaded(event, addonName)
	if addonName == "AdditionalIgnoreList" then
		AIList:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent("AIListLoad", EVENT_ADD_ON_LOADED, OnAddonLoaded)

