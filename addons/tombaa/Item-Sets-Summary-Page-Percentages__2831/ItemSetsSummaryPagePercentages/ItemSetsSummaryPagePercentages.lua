ItemSetsSummaryPagePercentages = {}

local ADDON_NAME = "ItemSetsSummaryPagePercentages"
local ADDON_DISPLAY_NAME = "Item Sets Summary Page Percentages"


local function OnAddOnLoaded(_, addOnName)
	if addOnName == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

		ITEM_SETS_BOOK_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
			if newState == "showing" then

				function addPercentagesToChildProgressBars(control, startNum, endNum)
					local numChildren = zo_min(control:GetNumChildren(), endNum)
					local numStart = zo_min(startNum, numChildren)
						
					for i = numStart, numChildren do
						local child = control:GetChild(i)
						if child and child.GetName and child.GetText and zo_plainstrfind(child:GetName():lower(), "progress") then
							if string.len(child:GetText()) > 0 then
								local found  = { zo_strsplit( " / ", child:GetText() ) }
								local first = found[1]:gsub("%,","")
								local second = found[2]:gsub("%,", "")
								child:SetText(found[1] .. "/" .. found[2] .. " (" .. tostring(math.floor((tonumber(first) / tonumber(second))*100)) .. "%)")
							end
						end
						if child then
							addPercentagesToChildProgressBars(child, 1, 100)
						end
					end
				end
				addPercentagesToChildProgressBars(ZO_ItemSetsBook_Keyboard_TopLevelSummaryContentScrollChild, 1, 100)
			end
		end)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

