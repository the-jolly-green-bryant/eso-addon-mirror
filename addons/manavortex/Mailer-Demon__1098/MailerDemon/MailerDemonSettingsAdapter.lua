local MailerDemon = MailerDemon

function MailerDemon.GetTo(craftName)
	local currConfig = MailerDemon.GetCurrentConfig(craftName)
	local ret = currConfig.To
	if nil == ret then ret = "" end
	return ret
end
function MailerDemon.SetTo(craftName, value)
	local currConfig = MailerDemon.GetCurrentConfig(craftName)
	currConfig.To = value
end


function MailerDemon.GetSubject(craftName)
	local currConfig = MailerDemon.GetCurrentConfig(craftName)
	return currConfig.Subject
end
function MailerDemon.SetSubject(craftName, value)
	local currConfig = MailerDemon.GetCurrentConfig(craftName)
	currConfig.Subject = value
end



