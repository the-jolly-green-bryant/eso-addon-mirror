------------------------
-- ravSpeed
-- original addon by rav
-- https://www.esoui.com/downloads/info423-ravSpeed.html
--
-- Main.lua


-----------------------
-- tables

ravSpeed = {
	lastSpeeds = {},
	lastSpeedIndex = 1,
	lastPos = nil,
	lastMean = 0,
	initDone = false,
	queueArrayUpdate = true,
}


ravSpeed.Default = {

	-- gen
	isLocked = false,
	forceShow = false,

	displayStyle = "UPS %",
	showUps = true,
	showPct = true,

	-- ctrl
	ctrlPos = {TOPLEFT, TOPLEFT, 20, 20},
	fontName = "BOLD_FONT",
	fontSize = 18,
	fontStyle = "soft-shadow-thick",
	fontColor = {0.8, 0.86, 0.74, 1},
  
	referenceSpeed = 250,

	-- OG
	forceOnUpdate = false,
	customArrayForOnUpdate = false,

	refreshRate = 50,

	autoAdjustArray = true,
	customArraySize = 10,

	-- magic
	magicValue = 370,
	overrideMagicValue = false,
	overrideforOnUpdate = false,
	customMagicValue = 373,
	
}


-----------------------
-- funcs

function ravSpeed.adjustArray()

	-- og size, will only be used if OnUpdate + no custom size
	local newSize = 15

	-- if normal update + no autoadjust OR if onupdate + custom onupdate size
	if (not ravSpeed.SV.forceOnUpdate and not ravSpeed.SV.autoAdjustArray) or (ravSpeed.SV.forceOnUpdate and ravSpeed.SV.customArrayForOnUpdate) then
		newSize = ravSpeed.SV.customArraySize
	-- normal update + autoadjust
	elseif not ravSpeed.SV.forceOnUpdate and ravSpeed.SV.autoAdjustArray then
		newSize = 10*(1/(ravSpeed.SV.refreshRate/70))
		newSize = math.floor(newSize)
		newSize = math.min(newSize, 15)
	end

	ravSpeed.lastSpeeds = {}
	for i = 1, newSize do
		ravSpeed.lastSpeeds[i] = 0
	end

end


function ravSpeed.adjustMagic()

	if (not ravSpeed.SV.forceOnUpdate and ravSpeed.SV.overrideMagicValue) or (ravSpeed.SV.forceOnUpdate and ravSpeed.SV.overrideforOnUpdate) then
		ravSpeed.SV.magicValue = ravSpeed.SV.customMagicValue
	else
		ravSpeed.SV.magicValue = 373
	end

end


function ravSpeed.update()

	if not ravSpeed.initDone then return end

	-- calc
	local _, xPos, _, yPos = GetUnitRawWorldPosition('player')
	
	if ravSpeed.lastPos ~= nil then
		local lastX, lastY = unpack(ravSpeed.lastPos) 
		local xd = xPos - lastX
		local yd = yPos - lastY
		local dist = math.sqrt(xd * xd + yd * yd)

		local distPerMs

		if ravSpeed.SV.forceOnUpdate then
			distPerMs = dist / GetFrameDeltaTimeMilliseconds()
		else
			distPerMs = dist / ravSpeed.SV.refreshRate
		end

		ravSpeed.lastSpeedIndex = math.mod(ravSpeed.lastSpeedIndex + 1, #ravSpeed.lastSpeeds)
		ravSpeed.lastSpeeds[ravSpeed.lastSpeedIndex] = distPerMs
	end
	
	ravSpeed.lastPos = {xPos, yPos}
	
	local meanSpeed = 0
	for i = 0, #ravSpeed.lastSpeeds do
		-- find better. disabling/reenabling initDone or queuing adjust doesnt work so idk
		if ravSpeed.lastSpeeds[i] ~= nil then
			meanSpeed = meanSpeed + ravSpeed.lastSpeeds[i]
		end
	end
	
	meanSpeed = meanSpeed / #ravSpeed.lastSpeeds
	meanSpeed = meanSpeed * ravSpeed.SV.magicValue
	meanSpeed = math.floor(meanSpeed+0.5)

	-- display
	if ravSpeed.SV.showUps then
		ravSpeedCtrlUps:SetText(string.format("%03dups", meanSpeed))
	end

	if ravSpeed.SV.showPct then
		pctSpeed = math.floor(meanSpeed / ravSpeed.SV.referenceSpeed * 100 + 0.5)
		ravSpeedCtrlPct:SetText(string.format("%03d%%", pctSpeed))
	end

end


-----------------------
-- init + load

function ravSpeed.init(eventCode, addOnName)
	if (addOnName ~= "ravSpeed") then return end
	ravSpeed.SV = ZO_SavedVars:NewAccountWide("ravSpeed_SV", 1.2, nil, ravSpeed.Default, nil)

	ravSpeed.initControl()
	ravSpeed:settingsMenu()
	ravSpeedCtrl:SetHandler("OnMouseUp", ravSpeed.saveWindowPos)

	ravSpeed.adjustArray()
	ravSpeed.adjustMagic()


	if ravSpeed.SV.forceOnUpdate then
		ravSpeedCtrl:SetHandler("OnUpdate", ravSpeed.update)
	else
		EVENT_MANAGER:RegisterForUpdate("ravSpeedRefresh", ravSpeed.SV.refreshRate, ravSpeed.update)
	end

	EVENT_MANAGER:RegisterForEvent("ravSpeed", EVENT_ACTION_LAYER_POPPED, ravSpeed.OnActionLayerChange)
    EVENT_MANAGER:RegisterForEvent("ravSpeed", EVENT_ACTION_LAYER_PUSHED, ravSpeed.OnActionLayerChange)

	ravSpeed.initDone = true
end



function ravSpeed.commandHandler(text)

	if text == "lock" then
		ravSpeed.SV.isLocked = not ravSpeed.SV.isLocked
		d("ravSpeed locked position: "..tostring(ravSpeed.SV.isLocked))
		ravSpeed.setLock()
	elseif text == "force" then
		ravSpeed.SV.forceShow = not ravSpeed.SV.forceShow
		d("ravSpeed forced display: "..tostring(ravSpeed.SV.forceShow))
		ravSpeedCtrl:SetHidden(ravSpeed.SV.forceShow)
	elseif tonumber(text) ~= nil then
		ravSpeed.SV.referenceSpeed = tonumber(text)
		d("ravSpeed new reference: "..ravSpeed.SV.referenceSpeed)
	elseif text == "info" then
		d("current reference: "..ravSpeed.SV.referenceSpeed..
		  "\ncurrent refresh rate: "..ravSpeed.SV.refreshRate..
		  "\nonUpdate: "..tostring(ravSpeed.SV.forceOnUpdate)..
		  "\narray size: "..#ravSpeed.lastSpeeds..
		  "\nscale value: "..ravSpeed.SV.magicValue)
	else
		d("ravSpeed usage:\n/ravspeed info\n/ravspeed lock\n/ravspeed force\n/ravspeed 250")
	end

end



SLASH_COMMANDS["/ravspeed"] = ravSpeed.commandHandler
EVENT_MANAGER:RegisterForEvent("ravSpeed", EVENT_ADD_ON_LOADED, ravSpeed.init)