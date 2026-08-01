--[[----------------------------------------------------------
	Combat Log Statistics
		AddonAuthor: Zeakfury	
	Thanks to Atropos (FTC) and Errc for much of the code here
	patched by katkat42 to work with the Vet Crypt of Hearts patch
	patched by katkat42 to work with the Update 3 (dyes and guilds) patch
  ]]----------------------------------------------------------

-- Create Global

FCL = {}
FCL.version = "2.2"
FCL.Starter = false
FCL.LAM = LibStub("LibAddonMenu-2.0")

--[[----------------------------------------------------------
	INITIALIZATION
  ]]----------------------------------------------------------

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= "CombatLogStatistics" then return end
	EVENT_MANAGER:UnregisterForEvent("CombatLogStatistics", ON_ADD_ON_LOADED)
	FCL.Default	= {
		["You"] = {"Loaded"},
		["Dam"] = {"Loaded"},
		["Attack"] = {},
		["Heal"] = {},
		["SumX"] = 0,
		["SumY"] = 0,
		["Width"] = 400,
		["Height"] = 200,
		["SumXDPS"] = 0,
		["SumYDPS"] = 0,
		["MaxLines"] = 15,
		["MaxLinesSaved"] = 100,
		["YouColor"] = "|c00ff00",
		["PetColor"] = "|c98eab8",
		["GroupColor"] = "|c0000ff",
		["AllyColor"] = "|c80ffff",
		["NPCColor"] = "|cFFFF00",
		["EnemyColor"] = "|cff0000",
		["SpecialColor"] = "|cead585",
		["GoodBuffColor"] = "|cFF00FF",
		["BadBuffColor"] = "|c8F00FF",
		["FoodBuffColor"] = "|cFF7F00",
		["HealColor"] = "|c73bdff",
		["GenericColor"] = "|cafb9cc",
		["PhysicalColor"] = "|cffe29d",
		["FireColor"] = "|cff2e2b",
		["ShockColor"] = "|c78bfff",
		["OblivionColor"] = "|c000030",
		["ColdColor"] = "|c3b55ff",
		["EarthColor"] = "|cc66300",
		["MagicColor"] = "|cd37fff",
		["DrownColor"] = "|cff72bc",
		["DiseaseColor"] = "|c24c603",
		["PoisonColor"] = "|c76dd14",
		["Time"] = false,
		["ShowHeals"] = true,
		["ShowDamage"] = true,
		["NameColor"] = true,
		["AbilityColor"] = true,
		["BuffColor"] = true,
		["ShowPower"] = true,
		["ShowBG"] = false,
		["FadesWithChat"] = true,
		["FadeTimer"] = 10,
		["BGColor"] = {0,0,0,.5},
		["XP"] = true,
		["AP"] = true,
		["Buffs"] = true,
		["Chat"] = false,
		["FontSize"] = 18,
		["Font"] = "EsoUI/Common/Fonts/univers57.otf",
		["HiddenM"] = false,
		["HiddenD"] = false,
		["Direction"] = "DOWN",
		["ToggleTracking"] = true,
		["Buffer"] = true,
		["BufferSpeed"] = 0.1,
		["Skills"] = {
			[8] = {
				[1] = true,	-- alchemy
				[2] = true,	-- blacksmithing
				[3] = true,	-- clothing
				[4] = true,	-- enchanting
				[5] = true,	-- provisioning
				[6] = true	-- woodworking
			},
			[7] = { [1] = true },	-- XP: is this still used?
			[6] = {
				[1] = true,	-- assault
				[2] = true,	-- support
				[3] = true	-- emperor
			},
			[5] = {	
				[1] = true,	-- fighter's guild
				[2] = true,	-- mages' guild
				[3]	= true	-- undaunted
			},
			[4] = {
				[1] = true,	-- soul trap
				[2] = true	-- vampire/werewolf
			},
			[3]	= {	
				[1] = true,	-- light armor
				[2] = true,	-- medium armor
				[3] = true	-- heavy armor
			},
			[2] = {	
				[1] = true,	-- Two-handed
				[2] = true,	-- One hand and shield
				[3] = true,	-- dual wield
				[4] = true,	-- bow
				[5] = true,	-- destruction staff
				[6] = true	-- restoration staff
			},
			[1]	= {	
				[1] = true,	-- Class skill line 1
				[2] = true,	-- Class skill line 2
				[3] = true	-- Class skill line 3
			}
		},
		["Stats"] = {
			["Death"] = 0,
			["THeal"] = 0,
			["TDam"] = 0,
			["IncDam"] = 0,
			["IncHeal"] = 0,
			["MaxDam"] = 0,
			["MaxHeal"] = 0,
			["MaxIncDam"] = 0,
			["MaxIncHeal"] = 0,
			["FTime"] = 1,
			["Kills"] = 0,
		}
	}

	-- Load saved variables
	FCL.CText = ZO_SavedVars:New( "FCLText" , math.floor( FCL.version * 100 ) , nil , FCL.Default , nil )
	if FCL.CText.Chat == true then FCL.CText.Chat = "First Tab" end
	if FCL.CText.Chat == false then FCL.CText.Chat = "None" end

	FCL.InitializeCL()
	FCL.InitSettings()
	FCL.InitMenu()
	FCL.InitMeters()
	-- can't touch the chat system until player activated
	EVENT_MANAGER:RegisterForEvent("CLSChat", EVENT_PLAYER_ACTIVATED, function(...) FCL.InitChatTab(...) end)
end

--In your initialize:
EVENT_MANAGER:RegisterForEvent("CombatLogStatistics", EVENT_ADD_ON_LOADED, OnAddOnLoaded)


-- Register keybindings
ZO_CreateStringId("SI_BINDING_NAME_DISPLAY_COMBAT_LOG", "Display Combat Log")


--[[---------------------------------------------------------------
 * A handy chaining function for quickly setting up UI elements
 ]]----------------------------------------------------------------
function FCL.Chain( object )
	-- Setup the metatable
	local T = {}
	setmetatable( T , { __index = function( self , func )
		-- Know when to stop chaining
		if func == "__END" then	return object end
		-- Otherwise, add the method to the parent object
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })

	-- Return the metatable
	return T
end


--[[----------------------------------------------------------
	Combat Log Window Set Up
 ]]-----------------------------------------------------------
function FCL.InitializeCL()
	FCL.Hiden = "You"
	FCL.StartTime = 0
	FCL.Offset = 0
	FCL.PlayerBuffs = {}
	FCL.Check = false
	FCL.TotalDamage = 0
	FCL.TotalHealing = 0
	FCL.Value = 0
	FCL.Alpha = 0
	FCL.Font = "EsoUI/Common/Fonts/univers57.otf"
	FCL.FontStyle = "soft-shadow-thin"
	FCL.XPGain = 0
	FCL.APGain = 0
	FCL.FadeTime = GetGameTimeMilliseconds()

	-- Setup Combat Log
	local CL = FCL.Chain(WINDOW_MANAGER:CreateTopLevelWindow("CombatLog"))
		:SetDimensions(FCL.CText.Width,FCL.CText.Height)
		:SetHidden(FCL.CText.HiddenM)
		:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,FCL.CText.SumX,FCL.CText.SumY)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetDrawLevel(3)
		:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
		:SetHandler( "OnMouseUp" , function(self) FCL.MouseUp(self) end)
		:SetHandler("OnMouseWheel",function(self,delta)
			if FCL.CText.Direction == "DOWN" then
				delta = delta * -1
			end
			FCL.Value = FCL.Value + delta
			if FCL.Hiden == "You" then
				FCL.ScrollWheel(FCL.CText.You)
			elseif FCL.Hiden == "Dam" then
				FCL.ScrollWheel(FCL.CText.Dam)
			elseif FCL.Hiden == "LT" then
				
			else
				FCL.ButtonToggle()
			end
		end)
	.__END

	CL.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_BD" , CL , CT_BACKDROP))
		:SetCenterColor(FCL.CText.BGColor[1],FCL.CText.BGColor[2],FCL.CText.BGColor[3],FCL.CText.BGColor[4])
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(CL)
	.__END

	local CT = FCL.Chain(WINDOW_MANAGER:CreateTopLevelWindow("CombatText"))
		:SetHidden(FCL.CText.HiddenM)
		:SetDrawLevel(3)
	.__END

	CL.title = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Title", CT , CT_LABEL ))
		:SetFont("ZoFontGameOutline")
		:SetDimensions(FCL.CText.Width,40)
		:SetColor(255,255,255,1)
		:SetText("Combat Log Statistics")
		:SetAnchor(BOTTOM, CL ,TOP,0,-2)
	.__END

	CL.title.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Title_BD", CL.title ,CT_BACKDROP))
		:SetCenterColor(0,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(CL.title)
	.__END

	----- CLOSE BUTTON -----
	CL.title.close = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Close", CL.title , CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(TOPRIGHT, CL.title ,TOPRIGHT,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("X")
		:SetHandler("OnClicked",function(self,but)
			FCL.CText.HiddenM = true
			CL:SetHidden(true)
			CT:SetHidden(true)
		end)
	.__END

	--"/esoui/art/buttons/swatchframe_down.dds"
	CL.title.close.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Close_BD", CL.title.close ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.close)
	.__END

	----- Back to TOP BUTTON -----
	CL.title.Top = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Top", CL.title , CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(RIGHT , CL.title , RIGHT,0,10)
		:SetHandler("OnClicked",function(self,but)
			FCL.Value = 0
			if FCL.Hiden == "You" then
				FCL.ScrollWheel(FCL.CText.You)
			elseif FCL.Hiden == "Dam" then
				FCL.ScrollWheel(FCL.CText.Dam)
			else
				FCL.ButtonToggle()
			end
		end)
	.__END

	CL.title.Top.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Top_BD" , CL.title.Top , CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/dropbox_arrow_disabled.dds")
		:SetColor(1,1,1,1)
		:SetDimensions(20,20)
		:SetAnchor(TOPLEFT,CL.title.Top.bd,TOPLEFT,0,0)
	.__END

	----- ScrollChild -----
	CL.scrollchild = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Scroll", CL, CT_SCROLL))
		:SetAnchorFill(CL)
		:SetHorizontalScroll(0)
	.__END

	----- TEXT BOX -----
	local function createTextbox(num)
		local textbox= FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Textbox" .. num, CL.scrollchild, CT_LABEL))
			:SetFont(FCL.CText.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
			:SetText(FCL.CText.You[num])
			:SetDimensions(1000,FCL.CText.FontSize+1)
		.__END
		local Textbutton = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Textbutton" .. num, CL.scrollchild , CT_BUTTON))
			:SetDimensions(20,FCL.CText.FontSize+1)
			:SetFont(FCL.CText.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
			:SetAnchor(TOPLEFT, textbox, TOPLEFT, -20,0)
			:SetHidden(true)
		.__END
		local Textbuttonbd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_TextbuttonBD" .. num, CL.scrollchild , CT_TEXTURE))
			:SetAnchorFill(Textbutton)
			:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
			:SetHidden(true)
			:SetDrawLayer(11)
		.__END
		return textbox, Textbutton, Textbuttonbd
	end
	FCL.textbox = {}
	FCL.textbutton = {}
	FCL.textbuttonbd = {}
	for i = 1, FCL.CText.MaxLines , 1 do
		FCL.textbox[i], FCL.textbutton[i], FCL.textbuttonbd[i] = createTextbox(i)
	end	
	FCL.DirectionChange()

	----- TEXT BOX BUTTON Switcher (You and Dam)-----
	CL.title.ButtonYou = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_You", CL.title , CT_BUTTON))
		:SetDimensions(40,20)
		:SetAnchor(LEFT, CL.title , LEFT ,0,10)
		:SetFont("ZoFontGameOutline")
		:SetText("You")
		:SetHandler("OnClicked",function(self,but)
			FCL.Hiden = "You"
			FCL.Value = 0
			FCL.ScrollWheel(FCL.CText.You)
			FCL.DirectionChange()
			FCL.ButtonToggle()
		end)
	.__END

	CL.title.ButtonYou.bd  = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_You_BD", CL.title.ButtonYou ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.ButtonYou)
	.__END

	CL.title.ButtonDam = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Dam", CL.title , CT_BUTTON))
		:SetDimensions(40,20)
		:SetAnchor(LEFT, CL.title.ButtonYou , RIGHT ,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("Dam")
		:SetHandler("OnClicked",function(self,but)
			FCL.Hiden = "Dam"
			FCL.Value = 0
			FCL.ScrollWheel(FCL.CText.Dam)
			FCL.DirectionChange()
			FCL.ButtonToggle()
		end)
	.__END

	CL.title.ButtonDam.bd  = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Dam_BD", CL.title.ButtonDam ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.ButtonDam)
	.__END

	CL.title.ButtonAttack = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Attack", CL.title , CT_BUTTON))
		:SetDimensions(70,20)
		:SetAnchor(LEFT, CL.title.ButtonDam , RIGHT ,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("Attack")
		:SetHandler("OnClicked",function(self,but)
			FCL.Hiden = "Attack"
			FCL.Value = 0
			FCL.DirectionChange()
			FCL.ButtonToggle()
		end)
	.__END

	CL.title.ButtonAttack.bd  = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Attack_BD", CL.title.ButtonAttack ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.ButtonAttack)
	.__END

	CL.title.ButtonHeal = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Heal", CL.title , CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(LEFT, CL.title.ButtonAttack , RIGHT ,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("Heal")
		:SetHandler("OnClicked",function(self,but)
			FCL.Hiden = "Heal"
			FCL.Value = 0
			FCL.DirectionChange()
			FCL.ButtonToggle()
		end)
	.__END

	CL.title.ButtonHeal.bd  = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Heal_BD", CL.title.ButtonHeal ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.ButtonHeal)
	.__END

	CL.title.ButtonLT = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_LT", CL.title , CT_BUTTON))
		:SetDimensions(30,20)
		:SetAnchor(LEFT, CL.title.ButtonHeal , RIGHT ,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("LT")
		:SetHandler("OnClicked",function(self,but)
			FCL.Hiden = "LT"
			FCL.Value = 0
			FCL.DirectionChange()
			FCL.ButtonToggle()
		end)
	.__END

	CL.title.ButtonLT.bd  = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_LT_BD", CL.title.ButtonLT ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(CL.title.ButtonLT)
	.__END

	----- TEXT BOX BUTTON Clear -----
	CL.title.labelClear = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Clear", CL.title, CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(RIGHT, CL.title.close , LEFT , -10,0)
		:SetFont("ZoFontCreditsText")
		:SetText("|cff0000" .. "Clear" .. "|r")
		:SetHandler("OnClicked",function(self,but)
			FCL.CText.You = {"Cleared"}
			FCL.CText.Dam = {"Cleared"}
			FCL.CText.Attack = {}
			FCL.CText.Heal = {}
			FCL.Value = 0
			if FCL.Hiden == "You" then
				FCL.ScrollWheel(FCL.CText.You)
			elseif FCL.Hiden == "Dam" then
				FCL.ScrollWheel(FCL.CText.Dam)
			elseif FCL.Hiden == "Attack" then
				FCL.ButtonToggle()
				FCL.textbox[1]:SetText("Cleared")
			elseif FCL.Hiden == "Heal" then
				FCL.ButtonToggle()
				FCL.textbox[1]:SetText("Cleared")
			end
			collectgarbage()
		end)
	.__END

	CL.title.labelClear.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_Clear_BD", CL.title.labelClear ,CT_BACKDROP))
		:SetCenterColor(255,230,128,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(CL.title.labelClear)
	.__END

	----- Vertical Slider -----
	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	--CL.sliderV = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_SliderV" , CL , CT_SLIDER))
		--:SetDimensions(30,CL:GetHeight())
		--:SetMouseEnabled(true)
		--:SetThumbTexture(tex,tex,tex,30,10,1,0,1,0)
		--:SetValue(0)
		--:SetValueStep(2)
		--:SetMinMax(0,CL:GetHeight())
		--:SetHandler("OnValueChanged",function(self,value,eventReason)
			--CL.scrollchild:SetVerticalScroll(value*10)
			--FCL.Offset = value			
		--end)
		--:SetAnchor(RIGHT,CL,RIGHT,5,0)
	--.__END

	----- Horizontal Slider -----
	CL.sliderH = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_SliderH" , CL , CT_SLIDER))
		:SetDimensions(FCL.CText.Width,20)
		:SetMouseEnabled(true)
		:SetThumbTexture(tex,tex,tex,10,20,1,1,0,0)
		:SetValue(0)
		:SetMinMax(0,1000)
		:SetValueStep(1)
		:SetOrientation(1)
		:SetHandler("OnValueChanged",function(self,value,eventReason)
			d(value)
			_G["CombatLog_Scroll"]:SetHorizontalScroll(value)
		end)
		:SetAnchor(BOTTOMLEFT,CL,BOTTOMLEFT,0,22)
		:SetDrawLevel(2)
	.__END

	CL.sliderH.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("CombatLog_SliderHBD" , CL.sliderH , CT_BACKDROP))
		:SetCenterColor(0,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(CL.sliderH)
		:SetDrawLevel(1)
	.__END	

	-- Get Character Info
	FCL.CharacterStats()

	-- Register event listeners
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_COMBAT_EVENT , FCL.NewCombatEvent )
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_PLAYER_COMBAT_STATE , FCL.InCombat)
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_EFFECT_CHANGED , FCL.NewBuff )
	--EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_RETICLE_HIDDEN_UPDATE , FCL.Hide )
	--EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_ACTION_LAYER_PUSHED , FCL.Hide )
	--EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_ACTION_LAYER_POPPED , FCL.Hide )
	-- EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_FINESSE_RANK_CHANGED , FCL.Finesse )
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_EXPERIENCE_UPDATE , FCL.NewExp )
	--EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_QUEST_COMPLETE_EXPERIENCE , FCL.QuestExp )
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_VETERAN_POINTS_UPDATE , FCL.NewExp )
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_ALLIANCE_POINT_UPDATE  , FCL.NewAP )
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_SKILL_XP_UPDATE , FCL.NewSkill)

	-- Register Slash Commands
	SLASH_COMMANDS["/cls"] = FCL.SlashCommands

	-- Populate buffs for the player
	FCL.GetBuffs( 'player' )
end

--[[----------------------------------------------------------
	Frame Handlers
 ]]-----------------------------------------------------------

--[[
  * Adds global /FCL to show CombatLog
 ]]--
function FCL.SlashCommands(text)
	text = text:upper()
	if (text == "HELP") or (text == "") then
		d("|cff180fCLS Help Guide|r")
		d("|c00ffffIf you are wondering why you cannot see the Target that hit you or the Ability they hit you with and only the damage that was done to you, the reason is because ZOS decided to block these in the API. Please show support for getting these unblocked.|r")
		d("|cff180f/CLS Main|r to open up Main window")
		d("|cff180f/CLS DPS|r to open up DPS window")
		d("|cff180f/CLS Settings|r to open up Settings window")
	elseif text == "MAIN" then
		FCL.CText.HiddenM = false
		_G["CombatLog"]:SetHidden(false)
	elseif text == "DPS" then
		FCL.CText.HiddenD = false
		DPS:SetHidden(false)
	elseif text == "SETTINGS" then
		_G["FCLSettings"]:SetHidden(false)
	end	
end

--[[
  * Closes DPS Meter
 ]]--
function CloseDPS()
	FCL.CText.HiddenD = true
	DPS:SetHidden(true)
end

--[[----------------------------------------------------------
	Keybind Function
 ]]-----------------------------------------------------------

function FCL.DisplayFCL()
	local frame = _G["CombatLog"]
	local CT = _G["CombatText"]

	if (frame:IsHidden() == true) then
		FCL.CText.HiddenM = false
		frame:SetHidden(false)
		CT:SetHidden(false)
	elseif (frame:IsHidden() == false) then
		FCL.CText.HiddenM = true
		frame:SetHidden(true)
		CT:SetHidden(true)
	end
end

--[[--
 * Function to record frame positions in saved variables
 ]]--
function FCL.MouseUp(self)
	-- assign the LEFT point of the window
	local left = self:GetLeft()

	-- assign the TOP point of the window
	local top = self:GetTop()

	-- assign Height and Width of window
	local Height = self:GetHeight()
	local Width = self:GetWidth()

	-- Save the position information for LEFT and TOP to the variables file
	FCL.CText.Height = Height
	FCL.CText.Width = Width
	FCL.CText.SumX = left
	FCL.CText.SumY = top

	-- Resize Title
	local title = _G["CombatLog_Title"]
	local slider = _G["CombatLog_SliderH"]
	title:SetDimensions(Width,40)
	slider:SetDimensions(Width,20)
end

--[[--
 * Function to record frame positions in saved variables
 ]]--
function FCL.MouseUpDPS(self)
	-- assign the LEFT point of the window
	local left = self:GetLeft()

	-- assign the TOP point of the window
	local top = self:GetTop()

	-- Save the position information for LEFT and TOP to the variables file
	FCL.CText.SumXDPS = left
	FCL.CText.SumYDPS = top
end

--[[--
 * Function scroll labels
 ]]--
function FCL.ScrollWheel(Dtable)
	if FCL.Value < 0 then
		FCL.Value = 0
	end
	--if FCL.CText.MaxLines > #Dtable then
		--FCL.Value = 0
	if FCL.Value > #Dtable - 1 then
		FCL.Value = #Dtable - 1
	end
	for i = 1, FCL.CText.MaxLines do
		if Dtable[FCL.Value + i] ~= nil then
			FCL.textbox[i]:SetText(Dtable[FCL.Value + i])
		else
			FCL.textbox[i]:SetText("")
		end
	end
end

--Show or Hides Buttons
function FCL.ButtonToggle()
	local dtable = {}
	for i = 1, FCL.CText.MaxLines do
		FCL.textbutton[i]:SetHidden(true)
		FCL.textbuttonbd[i]:SetHidden(true)
	end
	if FCL.Hiden == "Attack" then
		dtable = FCL.CText.Attack
	elseif FCL.Hiden == "Heal" then
		dtable = FCL.CText.Heal
	else
		return
	end
	local Display, Match = FCL.SortTable(dtable)
	if FCL.Value < 0 then
		FCL.Value = 0
	end
	if FCL.Value > #Display - 1 then
		FCL.Value = #Display - 1
	end
	for i = 1, FCL.CText.MaxLines do
		FCL.textbox[i]:SetText("")
		FCL.textbox[i]:SetText(Display[i+FCL.Value])
		if (Display[i+FCL.Value] ~= nil) and not (i+FCL.Value > #Display) and not (i+FCL.Value == #Display) then
			if (FCL.CText.Direction == "DOWN") then
				FCL.textbutton[i]:SetHidden(false)
				FCL.textbuttonbd[i]:SetHidden(false)
				FCL.textbutton[i]:SetText(i+FCL.Value .. ".")
				FCL.textbutton[i]:SetHandler("OnClicked",function(self,but)
					_G["AbilityFrame_Label"]:SetText("")
					_G["AbilityFrame_Label"]:SetText(Match[i+FCL.Value])
					if _G["AbilityFrame_Label"]:GetWidth() == 0 then
						_G["AbilityFrame"]:SetDimensions(300,300)
					else
						_G["AbilityFrame"]:SetDimensions(_G["AbilityFrame_Label"]:GetWidth()+20,_G["AbilityFrame_Label"]:GetHeight())
					end
					_G["AbilityFrame_BD"]:SetAnchorFill(_G["AbilityFrame"])
					_G["AbilityFrame"]:SetHidden(false)
				end)
			else
				i = i + FCL.Value
				FCL.textbutton[#Display+1-i]:SetHidden(false)
				FCL.textbuttonbd[#Display+1-i]:SetHidden(false)
				FCL.textbutton[#Display+1-i]:SetText(i-FCL.Value.. ".")
				FCL.textbutton[#Display+1-i]:SetHandler("OnClicked",function(self,but)
					_G["AbilityFrame_Label"]:SetText("")
					_G["AbilityFrame_Label"]:SetText(Match[#Display-i+FCL.Value])
					if _G["AbilityFrame_Label"]:GetWidth() == 0 then
						_G["AbilityFrame"]:SetDimensions(300,300)
					else
						_G["AbilityFrame"]:SetDimensions(_G["AbilityFrame_Label"]:GetWidth()+20,_G["AbilityFrame_Label"]:GetHeight())
					end
					_G["AbilityFrame_BD"]:SetAnchorFill(_G["AbilityFrame"])
					_G["AbilityFrame"]:SetHidden(false)
				end)
			end
		end
	end
end

--[[-----------------------------------------------
	Changes Direction of You and Dam windows
 --]]-----------------------------------------------
function FCL.DirectionChange()
	if (FCL.Hiden == "You") or (FCL.Hiden == "Dam") or (FCL.Hiden == "LT") then
		if (FCL.CText.Direction == "UP") then
			for i = 1, FCL.CText.MaxLines , 1 do
				if i == 1 then
					FCL.textbox[i]:SetAnchor(BOTTOMLEFT, _G["CombatLog_Scroll"], BOTTOMLEFT, 0,0)
				else
					FCL.textbox[i]:SetAnchor(BOTTOMLEFT, FCL.textbox[i-1], TOPLEFT, 0,0)
				end
			end	
		elseif (FCL.CText.Direction == "DOWN") then
			for i = 1, FCL.CText.MaxLines , 1 do
				if i == 1 then
					FCL.textbox[i]:SetAnchor(TOPLEFT, _G["CombatLog_Scroll"], TOPLEFT, 0,0)
				else
					FCL.textbox[i]:SetAnchor(TOPLEFT, FCL.textbox[i-1], BOTTOMLEFT, 0,0)
				end
			end
		end
	elseif (FCL.Hiden == "Attack") or (FCL.Hiden == "Heal") then
		if (FCL.CText.Direction == "UP") then
			for i = 1, FCL.CText.MaxLines , 1 do
				if i == 1 then
					FCL.textbox[i]:SetAnchor(BOTTOMLEFT, _G["CombatLog_Scroll"], BOTTOMLEFT, 20,0)
				else
					FCL.textbox[i]:SetAnchor(BOTTOMLEFT, FCL.textbox[i-1], TOPLEFT, 0,0)
				end
			end	
		elseif (FCL.CText.Direction == "DOWN") then
			for i = 1, FCL.CText.MaxLines , 1 do
				if i == 1 then
					FCL.textbox[i]:SetAnchor(TOPLEFT, _G["CombatLog_Scroll"], TOPLEFT, 20,0)
				else
					FCL.textbox[i]:SetAnchor(TOPLEFT, FCL.textbox[i-1], BOTTOMLEFT, 0,0)
				end
			end
		end
	end
end

--[[
  * Handles Skill XP events and adds them to the combat damage table.
  * Runs on the EVENT_SKILL_XP_UPDATE.
  altered by katkat42 to account for new EVENT_SKILL_XP_UPDATE return values, and to display correct skill titles
 ]]--
function FCL.NewSkill(eventCode, Category, Type, reason, rank, previousXP, CurrentXP)
    local diff = 0
    local inLevel = 0
    local display = ""

    if (FCL.SkillsXP[Category][Type][3] == nil) or (FCL.SkillsXP[Category][Type][3] >= CurrentXP) then return end
	-- if we've requested not to update this particular skill, go away
    if (FCL.CText.Skills[Category][Type] == false) then return end

    diff = CurrentXP - previousXP
	lastRankXP, nextRankXP = GetSkillLineXPInfo(Category,Type)
	cLevelXP = nextRankXP - lastRankXP
	levelProg = CurrentXP - lastRankXP
    percent = string.format( "%.2f" , (levelProg/cLevelXP)*100)
	skillName = GetSkillLineInfo(Category,Type)
    display = "|cc8ff3a+" .. diff .. " " .. skillName ..  " (" .. percent .. "%)"

	FCL.SkillsXP[Category][Type][3] = CurrentXP

	-- timestamp it if we want it, then insert it into the table
    if (FCL.CText.Time == true) then
        table.insert(FCL.CText.You, 1, "[" ..GetTimeString() .. "]" .. display)
    else
        table.insert(FCL.CText.You, 1, display)
    end

	-- display in chat if we want it
	FCL.WriteToChat(FCL.CText.You[1])

    if FCL.Hiden == "You" then
        FCL.FadeTime = GetGameTimeMilliseconds()
        for i = 1, FCL.CText.MaxLines do
            if FCL.CText.You[FCL.Value + i] ~= nil then
                _G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
            end
        end
    end
end

--[[
	OLD CODE
  * Handles experience events and adds them to the combat damage table.
  * Runs on the EVENT_EXPERIENCE_UPDATE and EVENT_VETERAN_POINTS_UPDATE listeners.
  altered by katkat42 to account for new event return values, and to display XP/VP properly
 ]]--
function FCL.NewExp( eventCode, unitTag, currentExp, maxExp, reason )
	--d("NewExp // " .. currentExp)
	local display = ""

	-- Bail if it's not earned by the player
	if ( unitTag ~= "player" ) then return end

	-- Don't display experience for level 50 characters
	if ( eventCode == EVENT_EXPERIENCE_UPDATE and GetUnitLevel('player') == 50 ) then return end

	-- Check whether it's VP or EXP
	local isveteran = ( eventCode == EVENT_VETERAN_POINTS_UPDATE ) and true or false

	-- Ignore finesse bonuses, they will get rolled into the next reward
	if ( reason == PROGRESS_REASON_FINESSE ) then return end

	-- Get the base experience
	local base = isveteran and FCL.VetXP or FCL.XP

	-- Calculate the difference
	local diff 	= currentExp - base
	--d(currentExp.." - "..base.." = "..diff)

	-- Record Gains for current Game-play
	FCL.XPGain = FCL.XPGain + diff

	-- Ignore zero experience rewards
	if ( diff == 0 ) or ( diff < 0 ) then return end

	-- Only show if wanted
	if ( FCL.CText.XP == false ) then return end

	-- Update the base experience
	if ( isveteran ) then
		display = "|c75d3ff+" .. diff .. " Veteran Points"
		FCL.VetXP = currentExp
	else
		display = "|c75d3ff+" .. diff .. " Experience Points"
		FCL.XP = currentExp
	end

	-- Puts in time stamp from button and add it to the log
	if (FCL.CText.Time == true) then
		table.insert(FCL.CText.You, 1, "[" .. GetTimeString() .. "]" .. display)
	else
		table.insert(FCL.CText.You, 1, display)
		--FCL.CText.You = "[" .. GetTimeString() .. "]" .. FCL.CText.You
	end

	-- display in chat if wanted
	FCL.WriteToChat(FCL.CText.You[1])

	if FCL.Hiden == "You" then
		for i = 1, FCL.CText.MaxLines do
			if FCL.CText.You[FCL.Value + i] ~= nil then
				_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
			end
		end
	end
end

--[[
  * Handles alliance point gains.
  * Runs on the EVENT_ALLIANCE_POINT_UPDATE listener.
 ]]--
function FCL.NewAP( eventCode, alliancePoints, playSound, difference )
	-- Record Gains for current Game-play
	FCL.APGain = FCL.APGain + difference

	-- ONly if player wants
	if ( FCL.CText.AP == false ) then return end

	-- Ignore tiny AP rewards
	if ( difference  < 5 ) then return end

	display = "|cff8f41+" .. difference .. " Alliance Points"

	if (FCL.CText.Time == true) then
		table.insert(FCL.CText.You, 1, "[" .. GetTimeString() .. "]" .. display)
	else
		table.insert(FCL.CText.You, 1, display)
	end

	FCL.WriteToChat(FCL.CText.You[1])

	if FCL.Hiden == "You" then
		FCL.FadeTime = GetGameTimeMilliseconds()
		for i = 1, FCL.CText.MaxLines do
			if FCL.CText.You[FCL.Value + i] ~= nil then
				_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
			end
		end
	end
end

--[[
	* Gets Current Stats for Character
--]]
function FCL.CharacterStats()
	FCL.CName = GetUnitName( 'player' )
	FCL.XP = GetUnitXP('player')
	FCL.VetXP = GetUnitVeteranPoints('player')
	-- GetSkillLineXPInfo() returns lastrank, nextrank, current
	FCL.SkillsXP = {
		[8] = {	
			[1] = {GetSkillLineXPInfo(8,1)}, 	-- Alchemy
			[2] = {GetSkillLineXPInfo(8,2)}, 	-- Blacksmithing
			[3] = {GetSkillLineXPInfo(8,3)},	-- Clothing
			[4] = {GetSkillLineXPInfo(8,4)},	-- Enchanting
			[5] = {GetSkillLineXPInfo(8,5)},	-- Provisioning
			[6] = {GetSkillLineXPInfo(8,6)}		-- Woodworking
		},
		[7] = { [1] = { GetSkillLineXPInfo(7,1) } },	-- PlayerXP
		[6] = {
			[1] = {GetSkillLineXPInfo(6,1)},	-- Assault
			[2] = {GetSkillLineXPInfo(6,2)},	-- Support
			[3] = {GetSkillLineXPInfo(6,3)}		-- Emperor
		},
		[5] = {	
			[1] = {GetSkillLineXPInfo(5,1)},	-- Fighters Guild
			[2] = {GetSkillLineXPInfo(5,2)},	-- Mages Guild
			[3]	= {GetSkillLineXPInfo(5,3)}		-- Undaunted Guild
		},
		[4] = {
			[1] = {GetSkillLineXPInfo(4,1)},	-- World
			[2] = {GetSkillLineXPInfo(4,2)}		-- Vamp/WW
		},	
		[3]	= {	
			[1] = {GetSkillLineXPInfo(3,1)},	-- Light Armor
			[2] = {GetSkillLineXPInfo(3,2)},	-- Medium Armor
			[3] = {GetSkillLineXPInfo(3,3)}		-- Heavy Armor
		},
		[2] = {	
			[1] = {GetSkillLineXPInfo(2,1)},	-- Two Handed
			[2] = {GetSkillLineXPInfo(2,2)},	-- One Handed & Shield
			[3] = {GetSkillLineXPInfo(2,3)},	-- Dual Wield
			[4] = {GetSkillLineXPInfo(2,4)},	-- Bow
			[5] = {GetSkillLineXPInfo(2,5)},	-- Destruction Staff
			[6] = {GetSkillLineXPInfo(2,6)}		-- Restoration Staff
		},
		[1]	= {	
			[1] = {GetSkillLineXPInfo(1,1)},	-- Class Tree 1
			[2] = {GetSkillLineXPInfo(1,2)},	-- Class Tree 2
			[3] = {GetSkillLineXPInfo(1,3)}		-- Class Tree 3
		}
	}

	-- this is a more i18n way to do it
	FCL.SkillXPNames = {
		[8] = {	
			[1] = GetSkillLineInfo(8,1), -- Alchemy
			[2] = GetSkillLineInfo(8,2), -- "Blacksmithing",
			[3] = GetSkillLineInfo(8,3), -- "Clothing",
			[4] = GetSkillLineInfo(8,4), --"Enchanting",
			[5] = GetSkillLineInfo(8,5), -- "Provisioning",
			[6] = GetSkillLineInfo(8,6), -- "Woodworking"
		},
		[7] = { [1] = GetSkillLineInfo(7,1)}, -- EXP
		[6] = {
			[1] = GetSkillLineInfo(6,1), -- "Assault",
			[2] = GetSkillLineInfo(6,2), -- "Support",
			[3] = GetSkillLineInfo(6,3), -- "Emperor"
		},
		[5] = {	
			[1] = GetSkillLineInfo(5,1), -- "Fighters Guild",
			[2] = GetSkillLineInfo(5,2), -- "Mages Guild",
			[3]	= GetSkillLineInfo(5,3), -- "Undaunted Guild"
		},
		[4] = {
			[1] = GetSkillLineInfo(4,1), -- "World ",
			[2] = GetSkillLineInfo(4,2), -- "Vamp/WW"
		},
		[3]	= {	
			[1] = GetSkillLineInfo(3,1), -- "Light Armor",
			[2] = GetSkillLineInfo(3,2), -- "Medium Armor",
			[3] = GetSkillLineInfo(3,3), -- "Heavy Armor"
		},
		[2] = {	
			[1] = GetSkillLineInfo(2,1), -- "Two Handed",
			[2] = GetSkillLineInfo(2,2), -- "One Handed & Shield",
			[3] = GetSkillLineInfo(2,3), -- "Dual Wield",
			[4] = GetSkillLineInfo(2,4), -- "Bow",
			[5] = GetSkillLineInfo(2,5), -- "Destruction Staff",
			[6] = GetSkillLineInfo(2,6), -- "Restoration Staff"
		},
		[1]	= {	
			[1] = GetSkillLineInfo(1,1), -- Class skill line 1
			[2] = GetSkillLineInfo(1,2), -- Class skill line 2
			[3] = GetSkillLineInfo(1,3), -- Class skill line 3
		}
	}
end

--[[----------------------------------------------------------
	Combat Event Handler
 ]]-----------------------------------------------------------

 --[[
  * Handles combat events and adds them to the combat damage table.
  * Runs on the EVENT_COMBAT_EVENT listener.
 ]]--
 function FCL.NewCombatEvent( eventCode , result , isError , abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )
	-- Display all combat events for debugging
	--d( "[" ..result .. "]," .. "[" ..abilityName .. "]," .. "[" ..sourceName .. "]," .. "[" ..sourceType .. "]," .. "[" ..targetName .. "]," .. "[" ..targetType .. "]," .. "[" ..hitValue .. "]," .. "[" ..abilityActionSlotType .. "]," .. "[" ..powerType .. "]," .. "[" ..damageType .. "]" )

	if (FCL.State == false) and (FCL.Check == false) then return end

	-- Verify it's a valid result type
	if ( not FCL.FilterSCT( result , abilityName , sourceType , targetName ) ) then return end
	if ( hitValue == 0 ) then return end

	-- Setup a new SCT object
	local newSCT = {
		["source"]		= sourceName,
		["sourceType"]	= sourceType,
		["targetType"]	= targetType,
		["target"]		= targetName,
		["name"]		= abilityName,
		["dam"]			= hitValue,
		["power"]		= powerType,
		["type"]		= damageType,
		["ms"]			= GetGameTimeMilliseconds(),
		["killblow"] 	= ( result == ACTION_RESULT_KILLING_BLOW) and true or false,
		["ifheal"] 		= ( result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK_CRITICAL or result == ACTION_RESULT_HOT_TICK) and true or false,
		["crit"]		= ( result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK_CRITICAL or result == ACTION_RESULT_DOT_TICK_CRITICAL) and true or false,
		["critdam"]		= ( result == ACTION_RESULT_CRITICAL_DAMAGE) and true or false,
		["critheal"] 	= ( result == ACTION_RESULT_CRITICAL_HEAL) and true or false,
		["critdot"]		= ( result == ACTION_RESULT_DOT_TICK_CRITICAL ) and true or false,
		["heal"]		= ( result == ACTION_RESULT_HEAL) and true or false,
		["hot"]			= ( result == ACTION_RESULT_HOT_TICK) and true or false,
		["crithot"]		= ( result == ACTION_RESULT_HOT_TICK_CRITICAL) and true or false,
		["blockeddam"]	= ( result == ACTION_RESULT_BLOCKED_DAMAGE ) and true or false,
		["blocked"]		= ( result == ACTION_RESULT_BLOCKED ) and true or false,
		["immune"]		= ( result == ACTION_RESULT_IMMUNE ) and true or false,
		["dot"]			= ( result == ACTION_RESULT_DOT_TICK ) and true or false,
		["miss"]		= ( result == ACTION_RESULT_MISS ) and true or false,
		["parried"]		= ( result == ACTION_RESULT_PARRIED) and true or false,
		["interrupt"]	= ( result == ACTION_RESULT_INTERRUPT ) and true or false,
		["resist"]		= ( result == ACTION_RESULT_RESIST ) and true or false,
		["reflect"]		= ( result == ACTION_RESULT_REFLECTED ) and true or false,
		["dodge"]		= ( result == ACTION_RESULT_DODGED ) and true or false,
		["absorb"]		= ( result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_ABSORBED) and true or false,
		["energy"]		= ( result == ACTION_RESULT_POWER_ENERGIZE ) and true or false,
	}
	--d("Before Source=" .. sourceType)
	--d("Before Target=" .. targetType)

	-- Add Damage or Healing to Log
	if (newSCT.energy == false) then
		if (newSCT.ifheal == false) and (FCL.CText.ShowDamage == true) then
			if (sourceType == 1) or (targetType == 1) or (sourceType == 2) or (targetType == 2) then
			--d("Source=" .. sourceType)
			--d("Target=" .. targetType)
			FCL.UpdateCL( newSCT )
			end
		elseif (newSCT.ifheal == true) and (FCL.CText.ShowHeals == true) then
			if (sourceType == 1) or (targetType == 1) or (sourceType == 2) or (targetType == 2) then
			--d("Source=" .. sourceType)
			--d("Target=" .. targetType)
			FCL.UpdateCL( newSCT )
			end
		end
	end
	-- Energy Gains
	if (targetType == 1 and newSCT.energy == true) then
		FCL.UpdateCL( newSCT )
	end

	-- to Damage Meters
	if (newSCT.interrupt ~= true and newSCT.absorb ~= true and newSCT.blocked ~= true and newSCT.resist ~= true and newSCT.dodge ~= true and newSCT.energy ~= true) then
		if (sourceType == 1 and newSCT.ifheal == false) or (sourceType == 2 and newSCT.ifheal == false)then
			FCL.DPS( newSCT.dam , newSCT.name, newSCT.crit, newSCT.type)
		end
		if (sourceType == 1 and targetType == 1) or (sourceType == 1 and newSCT.ifheal == true) or (sourceType == 2 and targetType == 1) or (sourceType == 2 and newSCT.ifheal == true) then
			FCL.HPS( newSCT.dam , newSCT.name, newSCT.crit, newSCT.type )
		end
	end
	if (sourceType == 1 and newSCT.killblow == true) or (sourceType == 2 and newSCT.killblow == true) then
		FCL.KillBlow()
	end
end

--[[-----------------------------------------------
	Buff Event Handler
 ]]------------------------------------------------

--[[
 * Set up buffs which are currently active on the target
 * Runs when the addon is first loaded for the player
 * Runs whenever the reticle target changes
 ]]--
function FCL.GetBuffs( target )
	-- Get the number of buffs currently affecting the target
	local nbuffs = GetNumBuffs( target )

	-- Iterate through them, adding them to the active buffs table
	for i = 1 , nbuffs , 1 do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, longTerm = GetUnitBuffInfo( target , i )
		FCL.UpdateBuff( 1, buffName , buffSlot , timeStarted , timeEnding , stackCount, abilityType )
	end	
end

--[[
 * This is a wrapper function for processing new active buffs.
 * It runs on the EVENT_EFFECT_CHANGED listener.
 * Changes are passed through the AddBuff function.
 ]]--
function FCL.NewBuff( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType )
	if FCL.CText.Buffs == false then return end
	--d( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType )

	-- Update the active buffs
	--if (effectName == FCL.PlayerBuffs.[effectName].name) and (FCL.PlayerBuffs.[effectName].start == beginTime) and (FCL.PlayerBuffs.[effectName].start == endTime) then return end
	if (unitTag == "player") and (abilityType ~= 2) then
		FCL.UpdateBuff( changeType, effectName, effectSlot, beginTime, endTime, stackCount, abilityType )
	end
end

--[[
 * This function handles updates to buffs.
 * New buffs, changes to buffs, and expired buffs are passed through.
 ]]--
function FCL.UpdateBuff( changeType, effectName, effectSlot, beginTime, endTime, stackCount, abilityType )
	if FCL.CText.Buffs == false then return end

	-- Debugging all registered abilities
	--d( eventCode .. "/" .. changeType .. "/" .. effectSlot .. "/" .. effectName .. "/" .. unitTag .. "/" .. beginTime .. "/" .. endTime .. "/" .. stackCount .. "/" .. iconName .. "/" .. buffType .. "/" .. effectType .. "/" .. abilityType .. "/" .. statusEffectType )

	-- Keeps track of buffs so that they are not repeated
	local newBuff= {
		["name"] = string.gsub(effectName, "%s+", ""),
		["startT"] = beginTime,
		["endT"] = endTime,
	}
	if (FCL.PlayerBuffs[effectName] == nil) then
		FCL.PlayerBuffs[effectName] = newBuff
	elseif (FCL.PlayerBuffs[effectName].startT ~= beginTime) and (FCL.PlayerBuffs[effectName].endT ~= endTime) then
		FCL.PlayerBuffs[effectName] = newBuff
	else return end

	-- Get Output Box
	local display = " "

	-- Run the effect through a filter
	isValid, effectName, effectDuration , beginTime , endTime = FCL.FilterBuffInfo( effectName , abilityType , beginTime , endTime, effectSlot )
	--d(effectName .. "/ " .. beginTime .. " / " .. endTime .. " / " .. changeType)

	-- Drop ignored effects
	if ( isValid == false ) then return end

	local name = string.gsub(effectName, "%s+", "")
	name = string.gsub(effectName, "%s+", "")

	-- Add new effects or refreshed effects to the active buffs table
	if ( 1 == changeType ) or ( 3 == changeType ) then
		if ( stackCount == nil or 0) then
			display = "You gain " .. effectName
		else
			display = "You gain " .. stackCount .. " of " .. effectName
		end
	-- Remove expired  effects from the active buffs table
	elseif ( 2 == changeType ) then
		display = effectName .. " fades from you"
	end

	-- Format and send to Output box
	if FCL.CText.BuffColor == true then
		if ( abilityType == 0) then                            -- Food Buff
			display = FCL.CText.FoodBuffColor .. display .. "|r"
		elseif ( abilityType == 1) or (abilityType == 10) then -- Good Buff
			display = FCL.CText.GoodBuffColor .. display .. "|r"
		else                                                   -- Bad Buff
			display = FCL.CText.BadBuffColor .. display .. "|r"
		end
	end

	--FCL.CText.You = display .. "\n" .. FCL.CText.You

	-- Puts in time stamp from button
	if (FCL.CText.Time == true) then
		table.insert(FCL.CText.You, 1, "[" ..GetTimeString() .. "]" .. display)
	else	
		table.insert(FCL.CText.You, 1, display)
		--FCL.CText.You = "[" ..GetTimeString() .. "]" .. FCL.CText.You
	end

	FCL.WriteToChat(FCL.CText.You[1])

	if FCL.Hiden == "You" then
		FCL.FadeTime = GetGameTimeMilliseconds()
		for i = 1, FCL.CText.MaxLines do
			if FCL.CText.You[FCL.Value + i] ~= nil then
				_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
			end
		end		
	end
end

--[[-----------------------------------------------
	Check to see if in Combat
 ]]------------------------------------------------
function FCL.InCombat( eventCode , CombatStatus)
	FCL.Check = CombatStatus
	--d(FCL.Check)
	--d(FCL.State)
end


--[[-----------------------------------------------
	Sets Up Text for Combat Log
 ]]------------------------------------------------
function FCL.UpdateCL( CombatData )
	--d(CombatData)

	if (FCL.CText == nil) then
		FCL.CText.You = {"Loaded"}
		FCL.CText.Dam = {"Loaded"}
	end	

	local CLlabelyou = _G["CombatLog_LabelYou"]
	local CLlabeldam = _G["CombatLog_LabelDam"]
	local CLSV = _G["CombatLog_SliderV"]
	local CLSH = _G["CombatLog_SliderH"]
	local display = ""
	local damage = CombatData.dam
	local type = CombatData.type
	local source = CombatData.source
	local sType = CombatData.sourceType
	local tType = CombatData.targetType
	local target = CombatData.target
	local time = CombatData.ms
	local ability = CombatData.name
	local DisTable = {}

	-- health
	local percent = math.floor( ( FCL.current / FCL.maximum ) * 100 )

	-- Removes "^" and following characters from targets name
	source = string.gsub( source , "%^.*", "")

	-- Removes "^" and following characters from targets name
	target = string.gsub( target , "%^.*", "")

	if (source ~= "") and (ability ~= "") then
		if FCL.CText.NameColor == true then
			-- Change color of source and target
			-- source
			if (sType == 1) then									-- Your Character
				source = FCL.CText.YouColor .. "You" .. "|r"
			elseif ( sType == 2) then								-- Pet
				source = FCL.CText.PetColor .. source .. "|r"
			elseif ( sType == 3) then								-- Your Group Members
				source = FCL.CText.GroupColor .. source .. "|r"
			elseif ( sType == 4) and ( tType == 1) and (CombatData.heal == false) and (CombatData.hot == false) and (CombatData.crithot == false) then -- Enemy Player
				source = FCL.CText.EnemyColor .. source .. "|r"
			elseif ( sType == 4) then								-- Friendly Player
				source = FCL.CText.AllyColor .. source .. "|r"
			else													-- Enemy NPC
				source = FCL.CText.EnemyColor .. source .. "|r"
			end

			-- target
			if (tType == 1) then									-- Your Character
				target = FCL.CText.YouColor .. "You" .. "|r"
			elseif (tType == 2) then								-- Pet
				sourse = FCL.CText.PetColor .. target .. "|r"
			elseif (tType == 3) then								-- Your Group Members
				target = FCL.CText.GroupColor .. target .. "|r"
			elseif (tType == 4) and (CombatData.heal == false) and (CombatData.hot == false) and (CombatData.crithot == false) then -- Enemy Player
				target = FCL.CText.EnemyColor .. target .. "|r"
			elseif (tType == 4) then								-- Friendly Player
				target = FCL.CText.AllyColor .. target .. "|r"
			else													-- Enemy NPC
				target = FCL.CText.EnemyColor .. target .. "|r"
			end
		else
			-- no pretty colors here
			if (sType == 1) then
				source = "You"
			end
			if (tType == 1) then
				target = "You"
			end
		end

		if FCL.CText.AbilityColor == true then
		-- Change Color of Spell
			if (type == 1) then											--Generic
				if (CombatData.heal == true or CombatData.critheal == true or CombatData.hot == true or CombatData.crithot == true) then	--Heal
					ability = FCL.CText.HealColor .. ability .. "|r"
				elseif (CombatData.energy ~= true) then
					ability = FCL.CText.GenericColor .. ability .. "|r"
				end
			elseif (type == 2) then										--Physical
				ability = FCL.CText.PhysicalColor .. ability .. "|r"
			elseif (type == 3) then										--Fire
				ability = FCL.CText.FireColor .. ability .. "|r"
			elseif (type == 4) then										--Shock
				ability = FCL.CText.ShockColor .. ability .. "|r"
			elseif (type == 5) then										--Oblivion
				ability = FCL.CText.OblivionColor .. ability .. "|r"
			elseif (type == 6) then										--Cold
				ability = FCL.CText.ColdColor .. ability .. "|r"
			elseif (type == 7) then										--Earth
				ability = FCL.CText.EarthColor .. ability .. "|r"
			elseif (type == 8) then										--Magic
				ability = FCL.CText.MagicColor .. ability .. "|r"
			elseif (type == 9) then										--Drown
				ability = FCL.CText.DrownColor .. ability .. "|r"
			elseif (type == 10) then									--Disease
				ability = FCL.CText.DiseaseColor .. ability .. "|r"
			elseif (type == 11) then									--Poison
				ability = FCL.CText.PoisonColor .. ability .. "|r"
			else														--None
			end
		end

		-- Get the Health stats
		if ( CombatData.type == 999 ) then
			-- Experience
			display = source .. " gained " .. damage .. " EXP"
		elseif ( CombatData.heal == true ) then
			-- Flag heals
			if string.match( ability , "Potion" ) then
				ability = "Health Potion"
				display = source .. " used " .. ability .. " and Healed " .. damage .. " on " .. target
			else
				if (tType == 0) then
					-- Friendly NPC
					target = FCL.CText.NPCColor .. CombatData.target .. "|r"
				end
				display = source .. " used " .. ability .. " and Healed " .. damage .. " on " .. target
			end
		elseif ( CombatData.critheal == true) then
			-- Flag Crit Heal
			if string.match( ability , "Potion" ) then
				ability = "Health Potion"
				display = source .. " used " .. ability .. " and Crit Healed " .. damage .. " on " .. target
			else
				if (tType == 0) then
					-- Friendly NPC
					target = FCL.CText.NPCColor .. CombatData.target .. "|r"
				end
				display = source .. " used " .. ability .. " and " .. FCL.CText.SpecialColor .. "CRIT|r " .. "Healed " .. damage .. " on " .. target
			end
		elseif ( CombatData.hot == true ) then
			-- Flag HOT
			if (tType == 0) then
				-- Friendly NPC
				target = FCL.CText.NPCColor .. CombatData.target .. "|r"
			end
			display = source .. " used " .. ability .. " HoT tick " .. damage .. " on " .. target
		elseif ( CombatData.crithot == true ) then
			-- Flag Crit HOT
			if (tType == 0) then
				-- Friendly NPC
				target = FCL.CText.NPCColor .. CombatData.target .. "|r"
			end
			display = source .. " used " .. ability .. FCL.CText.SpecialColor .. " CRIT HoT tick " .. "|r" .. damage .. " on " .. target
		elseif ( CombatData.critdam == true ) then
			-- Flag Crit Damage
			display = source .. FCL.CText.SpecialColor .. " CRIT " .. "|r" .. target .. " for " .. damage .. " with " .. ability
		elseif ( CombatData.blockeddam == true ) then
			-- Flag blocked damage
			display = target .. FCL.CText.SpecialColor .. " BLOCKED " .. "|r" .. source .. " took " .. damage .. " from " .. ability
		elseif ( CombatData.immune == true ) then
			-- Flag damage immunity
			display = source .. " is immune from " .. ability
		elseif ( CombatData.parried == true ) then
			-- Flag damage parried
			display = source .. FCL.CText.SpecialColor .. " parried " .. "|r" .. target .. "'s " .. ability
		elseif ( CombatData.interrupt == true ) then
			-- Flag damage inturrupted
			display = source .. FCL.CText.SpecialColor .. " inturrupted " .. "|r" .. target
		elseif ( CombatData.reflect == true ) then
			-- Flag damage reflect
			display = source .. FCL.CText.SpecialColor .. " reflected " .. "|r" .. target .. "'s " .. ability
		elseif ( CombatData.miss == true ) then
			-- Flag damage missed
			display = source .. FCL.CText.SpecialColor .. " missed " .. "|r" .. target .. "'s " .. ability
		elseif ( CombatData.resist == true ) then
			-- Flag damage resist
			display = source .. FCL.CText.SpecialColor .. " resisted " .. "|r" .. target .. "'s " .. ability
		elseif ( CombatData.dodge == true ) then
			-- Flag damage dodged
			display = source .. FCL.CText.SpecialColor .. " dodged " .. "|r" .. target .. "'s " .. ability
		elseif ( CombatData.absorb == true ) then
			-- Flag damage absorbed
			display = target .. FCL.CText.SpecialColor .. " absorb " .. "|r" .. damage .. " with " .. ability
		elseif ( CombatData.energy == true ) then
			-- Flag STAM/MAGIC/ULTIMAT Gains
			if ( CombatData.power == 0) then
				-- Magicka
				display = "|c4542ff" .. "+" .. damage .. " Magicka with " .. ability .. "|r"
			elseif ( CombatData.power == 6) then
				-- Stamina
				display = "|c08db19" .. "+" .. damage .. " Stamina with " .. ability .. "|r"
			elseif ( CombatData.power == 10) then
				-- Ultimate
				display = "|cffe862" .. "+" .. damage .. " Ultimate with " .. ability .. "|r"
			end
		elseif ( CombatData.dot == true ) then
			-- Flag damage DoT
			display = source .. " DoT tick " .. target .. " for " .. damage .. " with " .. ability
		elseif ( CombatData.critdot == true ) then
			-- Flag damage DoT CRIT
			display = source .. FCL.CText.SpecialColor .. " CRIT DoT tick " .. "|r" .. target .. " for " .. damage .. " with " .. ability
		else
			-- Standard hits
			display = source .. " hit " .. target .. " for " .. damage .. " with " .. ability
		end
	else
		if (CombatData.ifheal == false) then
			FCL.CText.Stats.IncDam = FCL.CText.Stats.IncDam + damage
			if damage > FCL.CText.Stats.MaxIncDam then
				FCL.CText.Stats.MaxIncDam = damage
			end
			if (CombatData.blockeddam == true) then
				display = FCL.CText.YouColor .. "You|r" .. FCL.CText.SpecialColor .. " BLOCKED|r took " .. damage
			else
				display = FCL.CText.YouColor .. "You|r were hit for " .. damage
			end
		else
			FCL.CText.Stats.IncHeal = FCL.CText.Stats.IncHeal + damage
			if damage > FCL.CText.Stats.MaxIncHeal then
				FCL.CText.Stats.MaxIncHeal = damage
			end
			display = FCL.CText.YouColor .. "You|r were healed for " .. damage
		end
	end

	-- Save Data into Table	
	if (tType == 1) and (CombatData.energy == false) then
		if (percent == 0) then
			table.insert(FCL.CText.Dam, 1, "Dead")
			--FCL.CText.Dam = "Dead" .. "\n" .. FCL.CText.Dam
		else
			table.insert(FCL.CText.Dam, 1, percent .. "% ( " .. FCL.current .. " ) - " .. display)
			--FCL.CText.Dam = percent .. "% ( " .. current .. " ) - " .. display .. "\n" .. FCL.CText.Dam
		end
	end

	-- Puts in time stamp from button
	if (FCL.CText.Time == true) then
		table.insert(FCL.CText.You, 1, "[" .. GetTimeString() .. "]" .. display)
	else
		table.insert(FCL.CText.You, 1, display)
		--FCL.CText.You = "[" .. GetTimeString() .. "]" .. FCL.CText.You
	end

	-- Limits number of lines in combat log (remember to make this global for settings)
	if FCL.CText.MaxLinesSaved ~= 0 or nil then
		if  #FCL.CText.You > FCL.CText.MaxLinesSaved then
			for i = FCL.CText.MaxLinesSaved, #FCL.CText.You do
				FCL.CText.You[i] = nil
			end
		end
		if  #FCL.CText.Dam > FCL.CText.MaxLinesSaved then
			for i = FCL.CText.MaxLinesSaved, #FCL.CText.Dam do
				FCL.CText.Dam[i] = nil
			end
		end
	end

	FCL.WriteToChat(FCL.CText.You[1])

	-- Send data to Frames
	if FCL.Hiden == "You" then
		FCL.FadeTime = GetGameTimeMilliseconds()
		for i = 1, FCL.CText.MaxLines do
			if FCL.CText.You[FCL.Value + i] ~= nil then
				_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
			end
		end		
	end
	--CLlabelyou:SetText(table.concat(FCL.CText.You, "\n"))
	if FCL.Hiden == "Dam" then
		FCL.FadeTime = GetGameTimeMilliseconds()
		for i = 1, FCL.CText.MaxLines do
			if FCL.CText.Dam[i] ~= nil then
				_G["CombatLog_Textbox"..i]:SetText(FCL.CText.Dam[i])
			end
		end
	end
	--_G["TestBox_Label"]:SetText(FCL.CText.You)
	--d(FCL.CText.You)
end

--[[-----------------------------------------------
	Finesse Rank Event Handler
 ]]------------------------------------------------
--function FCL.Finesse(eventcode, target, finesseType, text, source, log)
	--d(eventcode .. "/" .. target .. "/" .. targetType .. "/" .. text .. "/" .. source)
	--local finesse = _G["CombatLog_Finesse"]
	--if (target == "player") then
		--finesse:SetText("|cead585" .. text .. "|r")
	--end
--end

--[[----------------------------------------------------------
	Combat FILTER FUNCTIONS
 ]]-----------------------------------------------------------

--[[
 * Filter combat events to validate including them in SCT
 ]]--
function FCL.FilterSCT( result , abilityName , sourceType , targetName )
	targetName = string.gsub(targetName, "%^.*", "")
	if ( result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_FALL_DAMAGE ) then
		-- Direct Damage
		return true
	elseif ( result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL ) then
		-- Damage Over Time
		return true
	elseif ( result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HOT_TICK_CRITICAL ) then
		-- Heals
		return true
	elseif ( result == ACTION_RESULT_IMMUNE
		or result == ACTION_RESULT_DODGED
		or result == ACTION_RESULT_REFLECTED
		or result == ACTION_RESULT_RESIST
		or result == ACTION_RESULT_INTERRUPT
		or result == ACTION_RESULT_PARRIED
		or result == ACTION_RESULT_MISS
		or result == ACTION_RESULT_DAMAGE_SHIELDED
		or result == ACTION_RESULT_ABSORBED ) then
		-- Damage Immunity
		return true
	elseif ( FCL.CText.ShowPower == true) and (result == ACTION_RESULT_POWER_ENERGIZE) then
		-- Power attack charge
		return true
	else
		-- Otherwise, ignore it
		return false
	end	
end

--[[----------------------------------------------------------
	Buff Filter Function
 ]]-----------------------------------------------------------	
--[[
 * Filter abilities to override their displayed names or durations as necessary
 ]]--
function FCL.FilterBuffInfo( name , buffType , beginTime , endTime, effectSlot )
	-- Default to no duration
	local duration 	= nil
	local isValid	= true

	if ( string.match( name , 'TargetingHit' ) or string.match( name , 'Hack' ) or string.match( name , 'dummy' ) or string.match( name , "Mount Up" ) or string.match( name , "Boon: " ) or string.match( name , "Force Siphon" ) or string.match( name , "Regeneration" )) then
		-- Effects to ignore
		isValid		= false
	elseif ( name == "Unstable Clannfear" or name == "Unstable Familiar" or name == "Volatile Familiar" ) then
		-- Summons
		duration 	= "Summon"
	elseif ( name == "Siphoning Strikes" ) or ( name == "Magelight" ) then
		-- Toggles
		duration 	= "Toggle"	
	elseif ( buffType == ABILITY_TYPE_BONUS ) then
		-- "Bonus" Abilities
		-- Ignore Cyrodiil Keep Bonuses
		if ( string.match( name , "Keep Bonus" ) ) then
			isValid		= false
		end
	elseif ( buffType == ABILITY_TYPE_STUN ) then
		-- Stunned (9)
		name		= "Stunned"
	elseif ( buffType == ABILITY_TYPE_STAGGER ) then
		-- Power Attack (33)
		if ( beginTime == 0 ) then
			isValid		= false
		else
			name		= "Staggered"
			endTime		= beginTime + 3
		end
	elseif ( ( buffType == ABILITY_TYPE_BLOCK ) or ( name == "Brace (Generic)" ) ) then
		-- Blocking (52)
		isValid = false
	elseif ( buffType == ABILITY_TYPE_OFFBALANCE ) then
		-- Off-Balance (53)
		endTime		= beginTime + 3
	elseif ( string.match( name , "^.-Potion" ) ) then
		-- Potions
		name		= string.match( name , '^.-Potion' )
	end

	return isValid, name, duration , beginTime , endTime
end