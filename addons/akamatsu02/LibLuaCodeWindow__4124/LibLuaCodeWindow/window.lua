LibLuaCodeWindow = LibLuaCodeWindow or {}

local function uuid()
	return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function (cur)
		local tmp = (cur == 'x') and math.random(0, 0xf) or math.random(8, 0xf)
		return string.format('%x', tmp)
	end)
end

local orphanControls = {}

local defaultColors = {
	keyword = "007acc",
	value = "007acc",
	vararg = "007acc",
	string = "ff9900",
	string_end = "ff9900",
	string_start = "ff9900",
	number = "a3ffae",
	ident = "389a42",
	comment = "616361"
}

local function createControls(id, parent)
	local element = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)" .. id, parent, "LibLuaCodeWindowElement")
	element:GetNamedChild("Input"):SetHandler("OnTextChanged", function(control)
		pcall(function() 
			if control:GetText():find("\t", 1, true) ~= nil then
				control:SetText(string.gsub(control:GetText(), "\t", "    "))
			end
		end)
		local parent = control:GetParent()
		if parent.controller then
			parent.controller:processText()
		end
	end)
	return element
end

function LibLuaCodeWindow.new(self, parent, colors)
	local tokenColors = colors or defaultColors
	local id = uuid()
	local control = nil
	if orphanControls[1] then
		control = orphanControls[1]
		table.remove(orphanControls, 1)
	else
		control = createControls(id, parent)
	end
    local new = {
	    id = id,
        control = control,
		_text = control:GetNamedChild("Input"),
		_colored = control:GetNamedChild("InputColored"),
		_lines = control:GetNamedChild("Lines"),
		_colors = tokenColors
	}
	control.controller = new
    setmetatable(new, self)
    self.__index = self
	new:show()
    return new
end

function LibLuaCodeWindow.show(self)
	EVENT_MANAGER:RegisterForUpdate("LibLuaCodeWindowLineRefresh_" .. self.id, 250, function() self:processText() end)
	self.control:SetHidden(false)
	return self
end

function LibLuaCodeWindow.hide(self)
	EVENT_MANAGER:UnregisterForUpdate("LibLuaCodeWindowLineRefresh_" .. self.id)
	self.control:SetHidden(true)
	return self
end

function LibLuaCodeWindow.destroy(self)
	self:hide()
	self._text:SetText("")
	self._colored:SetText("")
	self.control.controller = nil
	table.insert(orphanControls, self.control)
	setmetatable(self, nil)
	return true
end

local function setLines(self, count)
	self._lines:SetTopLineIndex(self._text:GetTopLineIndex());
	self._colored:SetTopLineIndex(self._text:GetTopLineIndex());
	local text = ""
	for index = 1,count,1 do 
		text = text .. tostring(index) .. "\n";
	end
	self._lines:SetText(text);
end

local function colorLine(self, tokens, applyColor)
	local text = ""
	for index, token in ipairs(tokens) do
		if applyColor == true then
			if self._colors[token.type] then
				if token.type == "string_start" then
					text = text .. "|c" .. self._colors["string"] .. token.data
				elseif token.type == "string_end" then
					text = text .. token.data .. "|r"
				elseif token.type == "string" then
					text = text .. token.data
				elseif token.type == "ident" then
					local nextToken = tokens[index + 1]
					if nextToken then
						if nextToken.data == "(" or nextToken.data == "()" then
							text = text .. "|c" .. self._colors[token.type] .. token.data .. "|r"
						else
							text = text .. token.data
						end
					else
						text = text .. token.data
					end
				else
					text = text .. "|c" .. self._colors[token.type] .. token.data .. "|r"
				end
			else
				text = text .. token.data
			end
		else
			text = text .. token.data
		end
	end
	return text
end

function LibLuaCodeWindow.processText(self)
	local lines = LuaLexer.getTokens(self:getText())
	local texttable = {}
	local texttable2 = {}
	for line, tokens in ipairs(lines) do
		if line < self._text:GetTopLineIndex() then
			table.insert(texttable2, colorLine(self, tokens, false))
		else
			table.insert(texttable, colorLine(self, tokens, true))
		end
	end
	local uncolored = table.concat(texttable2, "\n")
	local colored = table.concat(texttable, "\n")
	local output = colored
	if uncolored ~= "" then
		output = uncolored.."\n"..colored
	end
	self._colored:SetText(output)
	setLines(self, #lines)
	return self
end

function LibLuaCodeWindow.getText(self)
	return self._text:GetText()
end

function LibLuaCodeWindow.setText(self, text)
	if type(text) ~= "string" then
		self._text:SetText("")
		return self
	end
	self._text:SetText(text)
	self:processText()
	return self
end