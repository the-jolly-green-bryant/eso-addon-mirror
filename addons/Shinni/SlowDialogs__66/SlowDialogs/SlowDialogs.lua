SlowDialogsGlobal = {}
-- local reference for performance (especially for the OnUpdate method which is called every frame)
local SlowDialogs = SlowDialogsGlobal
SlowDialogs.oldText = ZO_InteractWindowTargetAreaBodyText.SetText
SlowDialogs.oldOption = INTERACTION.PopulateChatterOption
SlowDialogs.oldquest = INTERACTION.ShowQuestRewards
SlowDialogs.start_time = 0

function SlowDialogs.match_height()
	local str = ZO_InteractWindowTargetAreaBodyText:GetText()
	while SlowDialogs.height > ZO_InteractWindowTargetAreaBodyText:GetTextHeight() do
		str = str .. "\n"
		SlowDialogs.oldText(ZO_InteractWindowTargetAreaBodyText, str)
	end
end

-- overwrite the set text function,
-- we save the given string and split it into its characters
ZO_InteractWindowTargetAreaBodyText.SetText = function (self, bodyText)
	SlowDialogs.COMPLETE_TEXT = bodyText
	SlowDialogs.COMPLETE_CHARS = {}
	-- split COMPLETE_TEXT into its characters
	-- there are some utf-8 encoded characters and the string library isn't utf-8 save
	-- so i have to write my own split function
	local char
	local i = 1
	local len = zo_strlen(SlowDialogs.COMPLETE_TEXT)
	while i <= len do
		-- the first byte tells us how many bytes the character is long
		char = string.byte(SlowDialogs.COMPLETE_TEXT, i)
		if char > 240 then
			table.insert(SlowDialogs.COMPLETE_CHARS, string.sub(SlowDialogs.COMPLETE_TEXT, i, i+3))
			i = i + 4
		elseif char > 225 then
			table.insert(SlowDialogs.COMPLETE_CHARS, string.sub(SlowDialogs.COMPLETE_TEXT, i, i+2))
			i = i + 3
		elseif char > 192 then
			table.insert(SlowDialogs.COMPLETE_CHARS, string.sub(SlowDialogs.COMPLETE_TEXT, i, i+1))
			i = i + 2
		else
			table.insert(SlowDialogs.COMPLETE_CHARS, string.sub(SlowDialogs.COMPLETE_TEXT, i, i))
			i = i + 1
		end
	end
	SlowDialogs.text_length = #SlowDialogs.COMPLETE_CHARS
	SlowDialogs.start_time = GetFrameTimeMilliseconds() + SlowDialogs.settings.start_delay
	SlowDialogs.quest = -1
	SlowDialogs.options = {}
	-- get the height of the finished text
	SlowDialogs.oldText(self, bodyText)
	SlowDialogs.height = self:GetTextHeight() 
	-- set the dialog field to an empty text
	SlowDialogs.oldText(self, " ")
	-- this function will add a bunch of line breaks, so that the empty text's height fits the complete text's height
	SlowDialogs.match_height()
	-- we have to fade in text, so add the OnUpdate handler
	EVENT_MANAGER:RegisterForUpdate("SlowDialogs", 0, SlowDialogs.OnUpdate)
	-- check if dialog starts with "<" character
	-- if so, skip the animation
	if bodyText:sub(1,1) == "<" then
		SlowDialogs.start_time = SlowDialogs.start_time - (SlowDialogs.settings.animation_length + SlowDialogs.text_length) * SlowDialogs.settings.speed - SlowDialogs.settings.start_delay
	end
end

local instantDisplayTypes = {
	[CHATTER_START_BANK] = true,
	[CHATTER_START_SHOP] = true,
	[CHATTER_START_STABLE] = true,
	[CHATTER_START_TRADINGHOUSE] = true,
}

-- overwrite the dialog answer options
-- they are added after the text is complete
INTERACTION.PopulateChatterOption = function ( ... )
	-- banks and shops aren't supposed to be delayed
	-- so we set the start time to a lower value to display the text completely
	local optionType = ({ ... })[5]
	if instantDisplayTypes[optionType] then
		SlowDialogs.start_time = SlowDialogs.start_time - (SlowDialogs.settings.animation_length + SlowDialogs.text_length) * SlowDialogs.settings.speed - SlowDialogs.settings.start_delay
	end
	-- save the dialog answers so we can add them later
	table.insert(SlowDialogs.options, { ... } )
end

-- save the given quest reward so we can display it later
INTERACTION.ShowQuestRewards = function (self, journalQuestIndex)
	SlowDialogs.quest = journalQuestIndex
end

-- called every frame while there is text to be faded in
function SlowDialogs.OnUpdate()
	time = GetFrameTimeMilliseconds()
	-- calculate how many characters are to be displayed
	local offset = 1.0 * (time - SlowDialogs.start_time) / SlowDialogs.settings.speed
	local length = zo_floor(offset)
	if length <= 0 then
		return
	end
	-- calculate how many caracters are completely faded in
	local white_length = zo_min(length - SlowDialogs.settings.animation_length, SlowDialogs.text_length )--zo_max(, 0)
	local length = zo_min(length, SlowDialogs.text_length)
	-- how many characters are fading in
	local current_animation_length = length - white_length
	local white_text = ""
	-- add the completely faded in characters to the displayed text
	if white_length > 0 then
		white_text = table.concat(SlowDialogs.COMPLETE_CHARS, nil, 1, white_length )
	end
	-- list for the displayed text
	local text = {}
	table.insert(text, white_text)
	-- add the characters that are currently fading in
	local maxR, maxG, maxB = ZO_InteractWindowTargetAreaBodyText:GetColor()
	local minR, minG, minB = 0, 0, 0
	if DialogColors then
		minR, minG, minB = ZO_InteractWindowTopBG:GetColor()
	end
	local r, g, b, lambda
	for i = 1,SlowDialogs.settings.animation_length do
		if white_length+i > 0 and white_length+i <= length then
			-- value between 0 and 1 depending on how far this character is colored
			lambda = (SlowDialogs.settings.animation_length - i) / SlowDialogs.settings.animation_length
			-- linearly interpolating the color values
			r = zo_min(255 * (lambda * maxR + (1 - lambda) * minR))
			g = zo_min(255 * (lambda * maxG + (1 - lambda) * minG))
			b = zo_min(255 * (lambda * maxB + (1 - lambda) * minB))
			-- add the color formated character to the buffer
			table.insert(text, string.format("|c%02x%02x%02x%s|r", r, g, b, SlowDialogs.COMPLETE_CHARS[white_length+i] ) )
		end
	end
	-- create a text from the white text and the colored characters
	text = table.concat(text)
	-- add the text to the dialog box
	SlowDialogs.oldText( ZO_InteractWindowTargetAreaBodyText, text )
	-- match colored text's height to the finished text's height
	SlowDialogs.match_height()
	-- check if the text is completely displayed
	if white_length >= SlowDialogs.text_length then
		SlowDialogs.COMPLETE_TEXT = nil
		-- if there is a quest reward, then display it
		if SlowDialogs.quest >= 0 then
			SlowDialogs.oldquest( INTERACTION, SlowDialogs.quest)
		end
		-- add the dialog answers
		for _, option in pairs(SlowDialogs.options) do
			SlowDialogs.oldOption( unpack(option) )
		end
		-- remove the OnUpdtae handler as the text has finished fading in
		EVENT_MANAGER:UnregisterForUpdate("SlowDialogs", 0, SlowDialogs.OnUpdate)
	end
end

-- skip function, which will immediately display the text
function SlowDialogs.Skip()
	if SlowDialogs.COMPLETE_TEXT then
		SlowDialogs.start_time = SlowDialogs.start_time - (SlowDialogs.settings.animation_length + SlowDialogs.text_length) * SlowDialogs.settings.speed - SlowDialogs.settings.start_delay
	end
end
-- clicking on the name of the person you are talking to will skip the dialog animation
ZO_InteractWindowTargetAreaTitle:SetMouseEnabled(true)
ZO_InteractWindowTargetAreaTitle:SetHandler("OnMouseUp", SlowDialogs.Skip )

function SlowDialogs.OnAddonLoaded( _, addon )
	if addon ~= "SlowDialogs" then
		return
	end
	-- some hacks to fix the conflict with Wykkyds Quest Tracker
	if LWF3 then
		LWF3.UI.ShouldBeHidden = function()
			if not ZO_MainMenuCategoryBar:IsHidden() then return true end
			if not ZO_OptionsWindow:IsHidden() then return true end
			if not ZO_SharedTreeUnderlay:IsHidden() then return true end
			-- quest tracker compability
			--if not ZO_ChatterOption1:IsHidden() then return true end
			if not ZO_InteractWindow:IsHidden() then return true end
			
			if not STORE_WINDOW["container"]:IsHidden() then return true end
			--if not STABLE["control"]:IsHidden() then return true end
			if not SMITHING["control"]:IsHidden() then return true end
			if not LOCK_PICK["control"]:IsHidden() then return true end
			if not KEYBIND_STRIP["control"]:IsHidden() then return true end
			return false
		end
	end
	if LWF4 then
		LWF4.UI.ShouldBeHidden = function()
			if not ZO_MainMenuCategoryBar:IsHidden() then return true end
			if not ZO_OptionsWindow:IsHidden() then return true end
			if not ZO_SharedTreeUnderlay:IsHidden() then return true end
			-- quest tracker compability
			--if not ZO_ChatterOption1:IsHidden() then return true end
			if not ZO_InteractWindow:IsHidden() then return true end
			
			if not STORE_WINDOW["container"]:IsHidden() then return true end
			--if not STABLE["control"]:IsHidden() then return true end
			if not SMITHING["control"]:IsHidden() then return true end
			if not LOCK_PICK["control"]:IsHidden() then return true end
			if not KEYBIND_STRIP["control"]:IsHidden() then return true end
			return false
		end
	end
	-- load saved settings
	SlowDialogs.settings = ZO_SavedVars:New("SlowDialogs_SavedVariables", 2, "settings", {start_delay = 5, speed = 30, animation_length = 20})
	-- initialize the options menu
	SlowDialogsGlobal.InitOptions()
end

EVENT_MANAGER:RegisterForEvent("SlowDialogs", EVENT_ADD_ON_LOADED , SlowDialogs.OnAddonLoaded)
