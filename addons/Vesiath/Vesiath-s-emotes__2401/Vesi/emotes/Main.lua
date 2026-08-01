V.Emotes = {
    path = V.name.."/emotes/images/",
    emoteList = {},
    titleSize = 32,
    sv = nil,

    scaling = {
        shrink = 0.9,
		none = 1,
		small = 1.1,
		medium = 1.2,
		large = 1.3,
    },

    defaults = {
        emoteSize = 24,
        message = true,
    },
    
    Init = function(self)
        self.sv = V:RegisterSavedVars("emotes", self.defaults)

        self.Menu:Build()
        self.EmoteMenu:Init()
        self:WelcomeMessage()
    end,

    WelcomeMessage = function(self)
        if self.sv.message then
            zo_callLater(function()
				d(self:ParseEmote("Honk") .. "Welcome to Vesiath's emote addon" .. self:ParseEmote("Honk"))
				d("Open the emote menu by binding a keybind in the controls menu or typing /em")
				d("The emote sizes and disabling the welcome message can be changed in the addon settings")
			end, 3000)
        end
    end,

    Add = function(self, key, _name, _scale)
        self.emoteList[key] = {
            name = key,
            img = _name or key,
            scale = _scale or self.scaling.none,
        }
    end,

    Get = function(self, name)
		if name ~= nil then return self.emoteList[name] else return self.emoteList end
	end,
	
	GetImage = function(self, name)
		if name ~= nil then return self.path .. name .. V.Util.extension else return nil end
	end,

    ParseEmote = function(self, text)
		return string.format("|t%d:%d:%s|t", self.titleSize, self.titleSize, self:GetImage(text))
	end,
	
	ParseEmoteFromText = function(self, text)
        for k, v in pairs(self:Get()) do
            local scaling = v.scale
            local pattern = "(%A)" .. V.Util.Case_Insensitive_Pattern(k) .. "(%A)"
            local replacement = "%1" .. string.format("|t%d:%d:%s|t", self.sv.emoteSize * scaling, self.sv.emoteSize * scaling, self:GetImage(v.img)) .. "%2"
            text = string.sub((" " .. text .. " "):gsub(pattern, replacement), 2, -2)
         end
		return text
    end,
}

