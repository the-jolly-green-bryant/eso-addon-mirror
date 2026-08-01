if Zgoo then return end

Zgoo = {
	version = 1.33,
	author = "@Errc"
}
setmetatable(Zgoo, {__call = function(me,tab) Zgoo.CommandHandler(tab) end})

local defaults = {
	events = {},
	conditionTypes = {},
}

local wm = WINDOW_MANAGER

function Zgoo.ChainCall(obj)
	local T={}
	setmetatable(T,{__index = function(self,fun)
		if fun=="__END" then
			return obj
		end
		return function(self,...)
			assert(obj[fun],fun.." missing in object")
			obj[fun](obj,...)
			return self
		end
	end})
	return T
end

local firsttime=true
function Zgoo.CommandHandler(text,freecam)
	local self = Zgoo

	Zgoo.SV = ZO_SavedVars:New("ZgooSV",Zgoo.version, nil,defaults)	-- This isn't actually used.... But without it global examining doesn't work with a for loop... wat?

	if freecam == nil then
		SetGameCameraUIMode(true)	--Free da mouse!
	end	

	if (not text or text=="") and firsttime then text="global" firsttime=false end

	if not text or text=="" then
		if not self.Frame then self:CreateFrame() end
		self.Frame:SetHidden(not self.Frame:IsHidden())
	elseif text=="global" or text=="_G" or text=="GLOBAL" then
		Zgoo:Main(nil,1,_G,nil,"global") -- indicate global mode explicitly
	elseif text=="g2" then  -- unused, not needed
		Zgoo:CloneGlobals()
		Zgoo:Main(nil,1,Zgoo._G2,nil,"global")
	elseif text == "sv" or text == "savedvars" then
		local data = Zgoo:FindSavedVarsTables()
		Zgoo:Main(nil, 1, data)		
	elseif text.find and text:find("^find") then  -- unused, not needed
		self.find = text:match("^find (.*)")
		d("Finding "..(self.find and self.find or "(nothing)")..", keep scrolling around...")
		Zgoo:Update()
	elseif text=="free" or text=="FREE" then
		-- Just freed the mouse. We done....
	elseif text=="events" or text=="EVENTS" then
		if not self.Events.EventTracker then self.Events:CreateEventTracker() end
		-- Reset defaults
		self.Events.curBotEvent = 0
		self.Events.eventsTable = {}
		Zgoo.ChainCall(self.Events.EventTracker.slider)
			:SetMinMax(0,0)
			:SetValue(0)
		self.Events.EventTracker:SetHidden(not self.Events.EventTracker:IsHidden())
	--Allow delayed mouse usage
	elseif text.find and text:find("dmouse") then
		local delay = 3
		if text~="dmouse" then
			text = text:match("%d+")
			text = tonumber(text)
			if text ~= nil then
				delay = text
			end
		end
		zo_callLater(function() Zgoo.CommandHandler("mouse") end, delay*1000)
	--Allow delayed functions
	elseif text.find and text:find("^delay") then
		local delay = 3
		local temp = text
		temp = temp:match("^delay (%d+)")
		temp = tonumber(temp)
		text = text:gsub("^delay (%d*%s*)","")
		if temp ~= nil then
			delay = temp
		end
		zo_callLater(function() Zgoo.CommandHandler(text,false) end, delay*1000)		
	elseif text=="mouse" then
		local control = wm:GetMouseOverControl()
		-- TODO maybe find a way to do all controls under the mouse.
		Zgoo:Main(nil,1,control)
	elseif type(text)=="table" or type(text)=="userdata" then
		Zgoo:Main(nil,1,text)
	elseif type(text)=="string" then
		local s = ("Zgoo:Main(nil,1,%s)"):format(text)
		local f,err = zo_loadstring( s )
		if f then f() else d("|cffff0000Error:|r "..err) end
	else
		error("Invalid Zgoo Param: "..tostring(text))
	end
	
	--free mouse after
	if not freecam then
		SetGameCameraUIMode(true)
	end	
end

SLASH_COMMANDS["/zgoo"] = Zgoo.CommandHandler
SLASH_COMMANDS["/spoo"] = Zgoo.CommandHandler
SLASH_COMMANDS["/run"] = SLASH_COMMANDS["/script"]
SLASH_COMMANDS["/re"] = SLASH_COMMANDS["/reloadui"]
SLASH_COMMANDS['/console'] = function()  local newVal = IsConsoleUI()and "0" or "1" SetCVar("ForceConsoleFlow.2",newVal) end
SLASH_COMMANDS["/dump"] = function(text)
	local f,err = zo_loadstring( ("d(%s)"):format(text) )
	if f then f() else d("|cffff0000Error:|r "..err) end
end

SLASH_COMMANDS["/findlorebook"] = function(text)
	text=text:lower()
	local lore = Zgoo.Utils:GetLoreBookInfo()
	for cati,cat in ipairs(lore) do
		for coli,col in ipairs(cat) do
			for booki,book in ipairs(col) do
				if book:lower():match(text) then d(book) end
			end
		end
	end
end

do
	local strfind = string.find
	local function unknownControlType(tab, key)
		return "NO_TYPE"
	end
	local function cacheControlTypes(tab, key)
		for k, v in zo_insecureNext, _G do
			if type(k) == "string" and type(v) == "number" then
				if strfind(k, "^CT_[A-Z_]+$") then
					rawset(tab, v, k)
				end
			end
		end
		getmetatable(tab).__index = unknownControlType
		return tab[key]
	end
	Zgoo.UiTypes = setmetatable({}, {__index = cacheControlTypes})
end


-- Register Keybinding
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ZGOO", "Toggle Zgoo")
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ZGOO_MOUSE", "/zgoo mouse")


ESO_Dialogs["Zgoo_ConfirmDeleteTableKey"] =
{
    title = {
        text = "Delete <<1>>",
    },
    mainText = {
        text = "Do you really want to delete |cff1919<<1>>|r ?\n\nThis may break your add-ons, perhaps even the vanilla UI. Make sure you have backed up your SavedVariables before proceeding.",
        align = TEXT_ALIGN_CENTER
    },
    buttons = {
        [1] = {
            text = "|cff1919Delete|r",
            callback = function(dialog)
                Zgoo:DeleteData(dialog.data)
            end
        },
        [2] = {
            text = SI_DIALOG_CANCEL
        }
    }
}