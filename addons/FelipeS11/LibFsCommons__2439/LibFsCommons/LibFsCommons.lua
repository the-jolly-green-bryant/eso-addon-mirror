--
-- internal functions
--
local function GetLibFsCommons()
	--A UNIQUE identifier
	local _LibFsCommons = {
		name				= "LibFsCommons",
		version				= "3.0",
		author				= "FelipeS11",
		authorId			= "@FelipeS11",
		longTag				= "",
		shortTag			= "",
		useLibChatMessage	= true,
		useShortTag			= false
	}
	-- Wraps text with a color.
	function _LibFsCommons.Colorize(message , color)
		-- Default to addon's .color.
		if (not color or color == nil or color == '' or color == 'nil' ) then color = "DDFFEE" end
		message  = tostring(message )

		message  = "|c" .. color .. message  .. "|r"

		return message 
	end

	-- print messages in the chat 
	function _LibFsCommons.PrintMsg(message, tagColor)
		message = tostring(message)
		
		if(_LibFsCommons.useLibChatMessage) then
			if(tagColor) then
				_LibFsCommons.chat:SetTagColor(tagColor):Print(message)
			else
				_LibFsCommons.chat:Print(message)
			end
		else
			local __tag = _LibFsCommons.GetTag()
			if(tagColor) then
				__tag = _LibFsCommons.Colorize(_LibFsCommons.GetTag(), tagColor)
			end
			d(__tag .. ' -> ' .. message);
		end
	end

	-- print messages in the chat with collor
	function _LibFsCommons.PrintMsgColorize(message, textColor, tagColor)
		message = tostring(message)
		message = _LibFsCommons.Colorize(message, textColor)
		_LibFsCommons.PrintMsg(message, tagColor)
	end

	-- print messages in the chat with collor
	function _LibFsCommons.PrintMsgColorizeAr(message, textColor, tagColor)
		local msgAux = ''
		
		for i, v in pairs(message) do
			if(i) then
				_col = textColor[i]
				msgAux = msgAux .. _LibFsCommons.Colorize(tostring(v), tostring(_col)) .. ' ' 
			end
		end
		
		_LibFsCommons.PrintMsg(msgAux, tagColor)
	end

	-- create an animation 
	function _LibFsCommons.AnimateTextDefault(_control, duration)
		-- Avoid playing the animation over itself.
		if not _control:IsHidden() then return end

		local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, _control)

		_control:SetHidden(false)
		animation:SetAlphaValues(_control:GetAlpha(), 1)
		animation:SetDuration(duration)

		-- Fade-out after fade-in.
		timeline:SetHandler('OnStop', function()
			local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, _control)

			animation:SetAlphaValues(_control:GetAlpha(), 0)
			animation:SetDuration(duration)

			timeline:SetHandler('OnStop', function()
				_control:SetHidden(true)
			end)

			timeline:PlayFromStart()
		end)

		timeline:PlayFromStart()
	end
	
	-- compare the same property in two objects
	function _LibFsCommons.PropObjEqual(_obj1, _obj2, prop)
		return _obj1[prop] == _obj2[prop]
	end

	-- Test if exist another version, or addon using the same 'name'
	function _LibFsCommons.CanCreateAddon(_IDENTIFIER, _NewConf)
		if(not _G[_IDENTIFIER])then return true end
		
		_G[_IDENTIFIER].fsAddonCreated = false
		
		if(not _G[_IDENTIFIER].version or not _G[_IDENTIFIER].name)then
			local msgAux = '';
			for _, xx in pairs(_G[_IDENTIFIER]) do
				if(type(xx)=='number' or type(xx)=='string')then
					msgAux = msgAux .. ' ' .. xx
				end
			end
			return assert(_G[_IDENTIFIER].version and _G[_IDENTIFIER].name, _IDENTIFIER .. " says: Some addon is using MY Global variable, so I can't load. :( || Variable's contents: " .. msgAux)
		end
		
		local _Name = _LibFsCommons.PropObjEqual(_G[_IDENTIFIER], _NewConf, 'name')
		if(not _Name)then
			return assert(_Name ,_IDENTIFIER .. " says: the Addon '" ..  _G[_IDENTIFIER].name .. "' is using MY Global variable, so I can't load. :(")
		end
		local _Version = _LibFsCommons.PropObjEqual(_G[_IDENTIFIER], _NewConf, 'version')
		if(not _Version)then
			return assert(_Version, _IDENTIFIER .. ": there is another version instaled...")
		end
	end
	
	-- add a caracter(PadValue) in the left of the string(PadString) till the result reaches value specified(HowMany)
	function _LibFsCommons.LeftPad(PadString, HowMany, PadValue)
		local Counter = HowMany - string.len(PadString)
		local x = 1
		local NewString = ''
		
	   while x <= Counter do
		  NewString = NewString .. PadValue
		  x = x + 1
	   end;
	   return NewString .. PadString;
	end
	
	-- convert the seconds to the format HH:MM:SS
	function _LibFsCommons.SecondsToStr(_Secs)
		local h = _LibFsCommons.LeftPad(tostring(math.floor(_Secs / 3600)), 2, '0')
		local m = _LibFsCommons.LeftPad(tostring(math.floor(_Secs % 3600 / 60)), 2, '0')
		local s = _LibFsCommons.LeftPad(tostring(math.floor(_Secs % 3600 % 60)), 2, '0')
		return h .. ':' .. m  .. ':' .. s
	end
	
	-- print messages using LibChatMessage or d()
	function _LibFsCommons.UseLibChatMessage(useLib)
		_LibFsCommons.useLibChatMessage = useLib
	end
	
	-- print using short/long tag in the chat
	function _LibFsCommons.UseShortTag(useShort)
		_LibFsCommons.useShortTag = useShort
		if(useShort)then
			LibChatMessage:SetTagPrefixMode(3)
		else
			LibChatMessage:SetTagPrefixMode(2)
		end
	end
	
	-- return the value of the selected tag
	function _LibFsCommons.GetTag()
		if(_LibFsCommons.useShortTag)then
			return _LibFsCommons.shortTag
		else
			return _LibFsCommons.longTag
		end
	end
	
	-- Default Slash command function
	function _LibFsCommons.SlashCommandFuncDef(slashCommands, slashCommandName, notFoundMsg, option)
		local options = { 
			string.match(option,"^(%S*)%s*(.-)$") 
		}

		if not option or option == "" then
			_LibFsCommons.DisplaySlashCommands(slashCommands, slashCommandName)
		elseif options[1] and options[2]then
			_LibFsCommons.ExecuteSlashCommands(slashCommands, options, notFoundMsg);
		end
	end
	
	-- print to the chat the slash commands in the list
	function _LibFsCommons.DisplaySlashCommands(slashCommands, slashCommandName)
		for idx, obj in ipairs(slashCommands) do
			_LibFsCommons.GetSlashCommandsObj(obj, slashCommandName)
		end
	end

	-- execute the function of an slash command
	function _LibFsCommons.ExecuteSlashCommands(slashCommands, options, notFoundMsg)
		local _objSel = nil;
		for idx, obj in ipairs(slashCommands) do
			if options[1] == obj.cmd then
				_objSel = obj;
			end
		end
		if(_objSel)then
			if(_objSel.func)then
				_objSel.func(options)
			end
		else
			_LibFsCommons.PrintMsgColorize(GetString(notFoundMsg))
		end
	end
	
	-- print to the chat the slash command
	function _LibFsCommons.GetSlashCommandsObj(obj, slashCommandName)
		if(obj)then
			local color1 = 'e5e1b4'
			local color2 = 'ffffff'
			if(obj.defColor == true)then
				color1 = nil
				color2 = nil
			end
			local msg1 = GetString(_G[obj.str])
			local msg2 = ''
			if(obj.cmd) then
				msg2 = slashCommandName .. ' ' .. obj.cmd
			end
			
			if(obj.compl)then
				msg2 = msg2 .. obj.compl
			end
			
			_LibFsCommons.PrintMsgColorizeAr({msg1, msg2}, {color1, color2}, nil)
		end
	end
	
	return _LibFsCommons
end
--
-- public API
--

--- @param name - a string identifier that is used to identify messages printed in chat. e.g. MyCoolAddon
--- @param shortTag - a string identifier that is used to identify messages printed in chat. e.g. MCA
--- @return a new LibFsCommons instance with the passed tags and defaults functions
function LibFsCommons(LongAddonName, ShortAddonName)
	if not LongAddonName or not ShortAddonName then return nil end

	local _IDENTIFIER = 'LibFsCommons_' .. LongAddonName
	local _LibFsCommons = GetLibFsCommons()
	-- Test if exist another version, or addon using the same 'LongAddonName'
	if(_LibFsCommons.CanCreateAddon(_IDENTIFIER, _LibFsCommons))then
		_LibFsCommons.chat = LibChatMessage(LongAddonName, ShortAddonName)
		_LibFsCommons.longTag = LongAddonName
		_LibFsCommons.shortTag = ShortAddonName
		return _LibFsCommons
	end
end
