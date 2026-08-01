local MailerDemon = MailerDemon
local db = MailerDemon.GetDb()



function MailerDemon.GenerateTooltipText(craftName, ret)
	
	-- d("MailerDemon.GenerateTooltipText(craftName, ret) called with " .. tostring(craftName) .. ", " .. tostring(ret)) 
	
	local currConfig = MailerDemon.GetCurrentConfig(craftName)
	if not currConfig or not currConfig.isActive then return ret end
	local nextTask = currConfig.NextTask
	if (nil == ret) or (ret == "") then
		ret = currConfig.tooltipDescriptor 
	end

	if currConfig.IsActive then

		-- d("About to generate tooltip for " .. currConfig.Name .. ", ret so far is " .. tostring(ret) .. ", next task is " .. tostring(nextTask))
		-- d("Materials: " .. tostring(currConfig.SendMaterials) .. ", boosters: "  .. tostring(currConfig.SendBoosters) .. ", metal "  .. tostring(currConfig.SendBlacksmithing) .. ", cloth: "  .. tostring(currConfig.SendClothing) ..  ", wood:"  .. tostring(currConfig.SendWoodworking) ..  ", glyphs: "  .. tostring(currConfig.SendEnchanting) .. ", flowers: "  .. tostring(currConfig.SendAlchemy) ..  ", food: "  .. tostring(currConfig.SendFood) )

		ret = MailerDemon.Itemize(ret, currConfig.SendMaterials, "material")
		ret = MailerDemon.Itemize(ret, currConfig.SendBoosters, "boosters")
		ret = MailerDemon.Itemize(ret, currConfig.SendBlacksmithing, "metal")
		ret = MailerDemon.Itemize(ret, currConfig.SendClothing, "cloth")
		ret = MailerDemon.Itemize(ret, currConfig.SendWoodworking, "wood")
		ret = MailerDemon.Itemize(ret, currConfig.SendEnchanting, "glyphs")
		ret = MailerDemon.Itemize(ret, currConfig.SendAlchemy, "flowers")
		ret = MailerDemon.Itemize(ret, currConfig.SendFood, "food items")


	end


	if (nil == nextTask) or (not MailerDemon.GetCurrentConfig(craftName).iusActive) then
		-- d("next task is nil for " .. craftName)
		return (ret .. " to " .. MailerDemon.GetTo(craftName))
	else
		return MailerDemon.GenerateTooltipText(nextTask, ret)
	end

end


--[[ ====____=======_===_==================
		/ __ \_   _| |_| |_ ___  _ __  ___
		||__// | | | __| __/ _ \| '_ \/ __|
		||__\\ |_| | |_| || (_) | | | \__ \
		\____/\__,_|\__|\__\___/|_| |_|___/
		====================================    ]]

function MailerDemon.ActivateButton(button)
	button:SetState(BSTATE_PRESSED)
	MailerDemon.ActiveButton = button
end
function MailerDemon.DeactivateButton(button)
	if nil == button then button = MailerDemon.ActiveButton end
	if nil == button then return end
	button:SetState(BSTATE_NORMAL)
	MailerDemon.ActiveButton = nil
end

local function getCraftTooltip(craftName)
	return "sending " .. craftName:gsub("%d+", "") .. ": "
end

function MailerDemon_CreateTooltip(button)
	local buttonName = button:GetName()
	local craftName = buttonName:gsub("MailerDemon_", "")
	-- currConfig.tooltipDescriptor
	local tooltipText = MailerDemon.GenerateTooltipText(craftName, getCraftTooltip(craftName))
	MailerDemon_Tooltip:AddLine(tooltipText)
	MailerDemon_Tooltip:ClearAnchors()
	MailerDemon_Tooltip:SetAnchor(BOTTOMRIGHT, button, TOPLEFT, -20, -40)
	MailerDemon_Tooltip:SetHidden(false)	
end

function MailerDemon_HideTooltip()	
	MailerDemon_Tooltip:ClearLines()
	MailerDemon_Tooltip:SetHidden(true)	
end

function MailerDemon_PushButton(button)
	MailerDemon.ActivateButton(button)
	MailerDemon.SetupActiveTasks(button:GetName():gsub("MailerDemon_", ""))
	MailerDemon.Success = true -- set this to true so SendMails doesn't try to get the next task
	MailerDemon.SendMails()
	
end
