local IST = IST

function IST.GetActive()
	return IST.settings.active
end
function IST.SetActive(value)
	settings.active = value
	text = ((value and "|c00FF00Heeding thy summons...|r") or "|cFF0000No longer heeding thy summons...|r")
	
	IST.ShowText(text)
end

function IST.GetDelay()
	return IST.settings.delay
end
function IST.SetDelay(value)
	IST.settings.delay = value
end

function IST.GetMaxTries()
	return IST.settings.maxTries
end
function IST.SetMaxTries(value)
	IST.settings.maxTries = value
end

function IST.GetTrigger()
	return IST.settings.trigger
end
function IST.SetTrigger(value)
	IST.settings.trigger = value
end