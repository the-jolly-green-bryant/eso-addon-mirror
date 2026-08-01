--[[----------------------------------------------------------
	Chat Tab
 ]]-----------------------------------------------------------
function FCL.WriteToChat(message)
	if (FCL.CText.Chat == "Own Tab" or FCL.CText.Chat == "Both") and FCL.ChatBuffer then
		FCL.ChatBuffer:AddMessage(message)
	end
	if FCL.CText.Chat == "First Tab" or FCL.CText.Chat == "Both" then
		d(message)
	end
end
 
 local function FindCLSChatTab()
	-- first, find out if the CLS tab already exists and where
	local myContainer = 0
	local myTab = 0
	local contains = GetNumChatContainers()
	for container = 1, contains do
		local tabs = GetNumChatContainerTabs(container)
		for tab = 1, tabs do
			local tName = GetChatContainerTabInfo(container, tab)
			if (tName == "CLS") then 
				myTab = tab
				myContainer = container
				break
			end
		end
		if myContainer ~= 0 then break end
	end
	return myContainer, myTab
end

local function GetCLSChatTab()
	local myContainer, myTab = FindCLSChatTab()
	-- if the tab doesn't already exist, create it
	if myTab == 0 then 
		-- AddChatContainerTab(1, "CLS", false) -- doesn't add tab to UI immediately
		-- default to the primary container
		myContainer = 1
		CHAT_SYSTEM.containers[myContainer]:AddWindow("CLS")
		myTab = GetNumChatContainerTabs(myContainer)
		-- remove all chat channels from it
		local numChannels = GetNumChatCategories()
		for i = 1, numChannels do
			SetChatContainerTabCategoryEnabled(myContainer, myTab, i, false)
		end
	end

	return myContainer, myTab, CHAT_SYSTEM.containers[myContainer].windows[myTab].buffer
end

local function RemoveCLSChatTab()
	local myContainer, myTab = FindCLSChatTab()
	-- if the tab already doesn't exist, our work here is done
	if myTab == 0 then return end
	RemoveChatContainerTab(myContainer, myTab)
end

function FCL.InitChatTab()
	if FCL.CText.Chat == "Own Tab" or FCL.CText.Chat == "Both" then
		FCL.ChatContainerIndex, FCL.ChatTabIndex, FCL.ChatBuffer = GetCLSChatTab()
		FCL.ChatBuffer:AddMessage("|cFF0A0ACombat Log Statistics|r")
	else
		RemoveCLSChatTab()
	end
end
