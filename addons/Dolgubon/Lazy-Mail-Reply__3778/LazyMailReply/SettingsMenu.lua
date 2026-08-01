local panel =  
{
     type = "panel",
     name = "Lazy Mail Reply",
     registerForRefresh = true,
     displayName = "Lazy Mail Reply",
     author = "@Dolgubon",
}
local function shallowCopy (source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end

local function getMailSettingTable(index)
	local mailOptions = 
	{
		{
			type = "dropdown",
			name = "Send Mail or Fill send mail screen",
			tooltip ="Send -> Sends the template mail immediately\nFill -> Switches to the send mail screen and fills in the template",
			choices = {"Send", "Fill"},
			choicesValues = {true, false},
			getFunc = function() return LazyMailReply.settings.mailReplyOptions[index].sendMail end,
			setFunc = function(value) 
				LazyMailReply.settings.mailReplyOptions[index].sendMail = value
				LazyMailReply:UpdateMailControls(index , nil , nil, nil , value )
			end,
		},
		{
			type = "editbox",
			name = "Mail Name (20 chars)",
			getFunc = function() return LazyMailReply.settings.mailReplyOptions[index].name end,
			setFunc = function(text) 
				LazyMailReply.settings.mailReplyOptions[index].name = text
				LazyMailReply:UpdateMailControls(index , text, nil, nil , nil )
			end,
			tooltip = "Name of the button to send mail #"..index,
			isMultiline = false,
			isExtraWide = true,
			maxChars = 20, 
			default = "default Mail",
		},
		{
			type = "editbox",
			name = "Subject (45 chars)",
			getFunc = function() return LazyMailReply.settings.mailReplyOptions[index].subject end,
			setFunc = function(text) 
				LazyMailReply.settings.mailReplyOptions[index].subject = text
				LazyMailReply:UpdateMailControls(index , nil, text, nil  , nil )
			end,
			tooltip = "Subject of mail template #"..index,
			isMultiline = false,
			isExtraWide = true,
			maxChars = 45, 
			default = "Subject",
		},
		{
			type = "editbox",
			name = "Body (700 chars)",
			getFunc = function() return LazyMailReply.settings.mailReplyOptions[index].body end,
			setFunc = function(text) 
				LazyMailReply.settings.mailReplyOptions[index].body = text
				LazyMailReply:UpdateMailControls(index , nil, nil, text  , nil )
			end,
			tooltip = "Body of mail template #"..index,
			isMultiline = true,
			isExtraWide = true,
			maxChars = 700, 
			default = "Body",
		}
	}
	return 	{
		type = "submenu",
		name = "Mail #"..index,
		tooltip = "First mail template",
		controls = mailOptions,
	}
end


local options =
{
	{
	    type = "slider",
	    name ="Number of template Mails",
	    getFunc = function() return LazyMailReply.settings.numberMails end,
	    setFunc = function(value) LazyMailReply.settings.numberMails = value end,
	    min = 0,
	    max = 8,
	    step = 1, --(optional)
	    clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
	    requiresReload = true, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
	} ,
}


function LazyMailReply.initializeSettingsMenu()
	for i = 1, LazyMailReply.settings.numberMails do
		table.insert(options,getMailSettingTable(i))
	end
	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("LazyMailReplyPanel", panel)
	LAM:RegisterOptionControls("LazyMailReplyPanel", options)
end