local debugMessageCount = 0

function AUI.DebugMessage(str)
	if AUI_DEBUG then
		if debugMessageCount > 1000 then
			AUI_DEBUG_MESSAGES = {}
			debugMessageCount = 0
		end

		local frameRate = GetFramerate()
	
		if frameRate <= 100 then
			local message = GetTimeString() .. ":" .. GetGameTimeMilliseconds()  .. "_" .. AUI.Math.Round(GetFramerate())  .. ": " .. tostring(str)
			
			table.insert(AUI_DEBUG_MESSAGES, message)
			
			debugMessageCount = debugMessageCount + 1
		end
	end
end

local function CreateDebugWindow()
	if AUI_DEBUG then
		AUI.CreateListBox("AUI_Debug_ListBox", AUI_DebugWindow, false, false)
		
		AUI_Debug_ListBox:ClearAnchors()
		AUI_Debug_ListBox:SetAnchor(TOPLEFT, AUI_DebugWindow, TOPLEFT, 0, 0)					
		AUI_Debug_ListBox:SetDimensions(AUI_DebugWindow:GetWidth(), AUI_DebugWindow:GetHeight())				
		AUI_Debug_ListBox:SetSortKey(1)
		AUI_Debug_ListBox:SetSortOrder(ZO_SORT_ORDER_DOWN)		
		
		local columnList = 
		{
			[1] = 	
			{
				["Name"] = "Column1",
				["Text"] = "Column1",
				["Width"] = "15%",
				["Height"] = "100%",
				["AllowSort"] = true,
				["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
			},
			[2] = 	
			{
				["Name"] = "Column2",
				["Text"] = "Column2",
				["Width"] = "85%",
				["Height"] = "100%",
				["AllowSort"] = false,
				["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
			},					
		}

		AUI_Debug_ListBox:SetColumnList(columnList)		
	end
end

local function ShowDebugWindow()
	if AUI_DEBUG then
		local itemList = {}
	
		for id, message in ipairs(AUI_DEBUG_MESSAGES) do
			local data =
			{
				[1] = 
				{
					["ControlType"] = "label",
					["Value"] = id,	
					["SortValue"] = id,		
					["SortType"] = "string",					
				},	
				[2] = 
				{
					["ControlType"] = "label",
					["Value"] = message,			
				},					
			}
			
			table.insert(itemList, data)
		end

		AUI_Debug_ListBox:SetItemList(itemList)		
		AUI_Debug_ListBox:Refresh()	

		AUI_DebugWindow:SetHidden(false)
	end
end

local function ToggleDebugWindow()
	if AUI_DEBUG then
		if AUI_DebugWindow:IsHidden() then
			ShowDebugWindow()
		else
			AUI_DebugWindow:SetHidden(true)
		end
	end
end

function AUI.CreateDebugWindow()
	if AUI_DEBUG then
		CreateDebugWindow()
		SLASH_COMMANDS["/auidebug"] = ToggleDebugWindow			
	end
end