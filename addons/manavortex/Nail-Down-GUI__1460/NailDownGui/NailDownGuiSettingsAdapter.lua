local NailDownGui = NailDownGui
local NDG = NailDownGui 

local settings = NailDownGui.settings


local function getSubSettings(key)
	return NailDownGui.settings[key] or {}
end

function NDG.GetActive(key)
	return getSubSettings(key).active
end
function NDG.SetActive(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.active = value
	NDG.UpdateControl(key)
end

function NDG.GetPosition(key)
	return (getSubSettings(key).position or TOPLEFT)
end
function NDG.SetPosition(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.position = value
	NDG.UpdateControl(key)
end
function NDG.GetAnchorPosition(key)
	ret = getSubSettings(key).anchorPosition or TOPLEFT
	return ret
end
function NDG.SetAnchorPosition(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.anchorPosition = value
	NDG.UpdateControl(key)
end

function NDG.GetXOffset(key)
	return (getSubSettings(key).offsetX or 0)
end
function NDG.SetXOffset(key, value)	
	local settingsArray = getSubSettings(key)
	settingsArray.offsetX = tonumber(value)
	NDG.UpdateControl(key)
end
function NDG.GetYOffset(key)
	return (getSubSettings(key).offsetY or 0)
end
function NDG.SetYOffset(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.offsetY = tonumber(value)
	NDG.UpdateControl(key)
end

function NDG.GetSizeY(key)
	return ( getSubSettings(key).height or nil )
end
function NDG.SetSizeY(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.height = value	 	 
	NDG.UpdateControl(key)
end

function NDG.GetSizeX(key)
	return ( getSubSettings(key).width or nil )
end
function NDG.SetSizeX(key, value)
	local settingsArray = getSubSettings(key)
	settingsArray.width = value	 	 
	NDG.UpdateControl(key)
end

function NDG.GetAnchorName(key) 
	ret = ( getSubSettings(key).anchorName or "GuiRoot" )
	return ret
end
function NDG.SetAnchorName(key, value) 
	local settingsArray = getSubSettings(key)
	settingsArray.anchorName = value	 	 
	NDG.UpdateControl(key)
end

function NDG.GetControlName(key) 
	return ( getSubSettings(key).controlName or nil )
end
function NDG.SetControlName(key, value) 
	local settingsArray = getSubSettings(key)
	settingsArray.controlName = value	 	 
	NDG.UpdateControl(key)
end

function NDG.GetDrawLayer(key) 
	return ( getSubSettings(key).drawLayer or 1 )
end
function NDG.SetDrawLayer(key, value) 
	local settingsArray = getSubSettings(key)
	settingsArray.drawLayer = value	 	 
	NDG.UpdateControl(key)
end


function NDG.GetAnchorChoices(key)
	
	ret = {"GuiRoot"}
	
	local anchorChoices = {
		healthBar = {
			"GuiRoot", 
			"ZO_ActionBar1"
		}, 
		magickaBar = {
			NDG.GetControlName("healthBar"),
			NDG.GetControlName("staminaBar"),
		}, 
		staminaBar = {
			NDG.GetControlName("healthBar"),
			NDG.GetControlName("magickaBar"),
		}, 
		alertText = {
			NDG.GetControlName("miniMap"),
		}, 
	}
	
	if nil ~= anchorChoices[key] then 
		for key, value in pairs(anchorChoices[key]) do 
			ret[#ret+1] = value
		end
	end

	return ret
end