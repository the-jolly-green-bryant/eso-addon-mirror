--[[----------------------------------------------------------
	INITILIZE METERS
 ]]-----------------------------------------------------------
function FCL.InitMeters()
	--Setup variables
	FCL.DPSMeter	= 0
	FCL.HPSMeter	= 0
	FCL.Target 		= {}
	FCL.Damage 		= {}
	FCL.Heal 		= {}
	FCL.State 		= false
	FCL.FTime 		= 0

	-- STAND ALONE DPS METER
	local DPS = FCL.Chain(WINDOW_MANAGER:CreateTopLevelWindow("DPS"))
		--frame:SetDimensions(DPS_Label:GetWidth(),DPS_Label:GetHeight())
		:SetHidden(FCL.CText.HiddenD)
		:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,FCL.CText.SumXDPS,FCL.CText.SumYDPS)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseUp", function(self) FCL.MouseUpDPS( self ) end)
	.__END

	DPS.BG = WINDOW_MANAGER:CreateControlFromVirtual("DPS_BG", DPS, "ZO_ThinBackdrop")

	DPS.LabelTex = FCL.Chain(WINDOW_MANAGER:CreateControl("DPS_LabelTex" , DPS , CT_LABEL))
		:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
		:SetText("DPS/HPS Meter")
	.__END

	DPS.LabelVal = FCL.Chain(WINDOW_MANAGER:CreateControl("DPS_LabelVal" , DPS , CT_LABEL))
		:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
		:SetText(" ")
	.__END

	DPS.Close = FCL.Chain(WINDOW_MANAGER:CreateControl("DPS_Close" , DPS , CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(TOPRIGHT, DPS, TOPRIGHT, 0,0)
		:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
		:SetText("X")
		:SetHandler("OnClicked", function(self) CloseDPS() end)
	.__END

	-- ABILITY BREAKDOWN WINDOW
	local AF = FCL.Chain(WINDOW_MANAGER:CreateTopLevelWindow("AbilityFrame"))
		:SetDimensions(200,200)
		:SetHidden(true)
		:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
	.__END

	AF.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_BD" , AF , CT_BACKDROP))
		:SetCenterColor(0,0,0,.5)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(AF)
	.__END

	--[[
	AF.title = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Title", AF , CT_LABEL ))
		:SetFont("ZoFontGameOutline")
		:SetDimensions(FCL.CText.Width,20)
		:SetColor(255,255,255,1)
		:SetText("Combat Log Statistics")
		:SetAnchor(BOTTOM, AF ,TOP,0,0)
	.__END

	AF.title.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Title_BD", AF.title ,CT_BACKDROP))
		:SetCenterColor(0,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(AF.title)
	.__END	

	AF.scrollchild = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Scroll", AF , CT_SCROLL ))
		:SetAnchorFill(AF)
		:SetVerticalScroll(0)
		:SetScrollBounding(0)
	.__END
	]]--

	AF.label = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Label", AF , CT_LABEL ))
		--:SetDimensions(FCL.CText.Width,FCL.CText.Height)
		:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
		:SetColor(255,255,255,1)
		:SetAnchor(TOPLEFT, AF, TOPLEFT, 0,0)
	.__END

	--[[
	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	AF.sliderV = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_SliderV" , AF , CT_SLIDER))
		:SetDimensions(30,AF:GetHeight())
		:SetMouseEnabled(true)
		:SetThumbTexture(tex,tex,tex,30,10,1,0,1,0)
		:SetValue(0)
		:SetValueStep(1)
		--:SetOrientation(0)
		:SetMinMax(0,AF:GetHeight())
		:SetHandler("OnValueChanged",function(self,value,eventReason)
			_G["AbilityFrame_Scroll"]:SetVerticalScroll(value)	
		end)
		:SetAnchor(RIGHT,AF,RIGHT,5,0)
	.__END
	]]--

	----- CLOSE BUTTON -----
	AF.close = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Close", AF, CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(TOPRIGHT, AF ,TOPRIGHT,0,0)
		:SetFont("ZoFontGameOutline")
		:SetText("X")
		:SetHandler("OnClicked",function(self,but) AF:SetHidden(true) end)
	.__END

	--"/esoui/art/buttons/swatchframe_down.dds"
	AF.close.bd = FCL.Chain(WINDOW_MANAGER:CreateControl("AbilityFrame_Close_BD", AF.close ,CT_TEXTURE))
		:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
		:SetColor(1,1,1,1)
		:SetAnchorFill(AF.close)
	.__END

	--Register event listeners
	EVENT_MANAGER:RegisterForEvent( "FCL" , EVENT_PLAYER_DEAD , FCL.Dead )

	DPS.StartTime = 0
	FCL.Starter = true
end

local BufferTable = {}
function BufferReached(key, buffer)
	if key == nil then return end
	if BufferTable[key] == nil then BufferTable[key] = {} end
	BufferTable[key].buffer = buffer or 3
	BufferTable[key].now = GetFrameTimeSeconds()
	if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
	BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
	BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
	if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
	return BufferTable[key].eval
end

function FCL.LTCreate()
	-- Life Time Stats
		local display = {}
		local dps = FCL.CText.Stats["TDam"]/FCL.CText.Stats["FTime"]
		table.insert(display, "|cff361eDPS:|r " .. string.format( "%.2f" , dps ))
		table.insert(display, "|cff361eMax Damage:|r " .. FCL.CText.Stats["MaxDam"])
		table.insert(display, "|cff361eDamage Done:|r " .. FCL.CText.Stats["TDam"])
		local hps = FCL.CText.Stats["THeal"]/FCL.CText.Stats["FTime"]
		table.insert(display, "|c00ffffHPS:|r " .. string.format( "%.2f" , hps ))
		table.insert(display, "|c00ffffMax Heal:|r " .. FCL.CText.Stats["MaxHeal"])
		table.insert(display, "|c00ffffHealing Done:|r " .. FCL.CText.Stats["THeal"])
		table.insert(display, "|cff361eMax Dam Taken:|r " .. FCL.CText.Stats["MaxIncDam"])
		table.insert(display, "|cff361eDamage Taken:|r " .. FCL.CText.Stats["IncDam"])
		table.insert(display, "|c00ffffMax Heal Taken:|r " .. FCL.CText.Stats["MaxIncHeal"])
		table.insert(display, "|c00ffffHealing Taken:|r " .. FCL.CText.Stats["IncHeal"])
		table.insert(display, "|cff361eKilling Blows:|r " .. FCL.CText.Stats["Kills"])
		table.insert(display, "|cff361eDeaths:|r " .. FCL.CText.Stats["Death"])
		FCL.ScrollWheel(display)
end

--[[----------------------------------------------------------
	Sorts Table
 ]]-----------------------------------------------------------
function FCL.SortTable(Itable)
	local HTable = {}
	local DTable = {}
	local STable = {}
	local MTable = {}
	local MDTable = {}
	local Tdam = 0
	local Scolor = {}

	if Itable ~= nil then
		for k, v in pairs(Itable) do
			HTable[k] = Itable[k]["Total Damage"]
		end
		for k , v in pairs(HTable) do
			table.insert(STable, k)
		end
		local function sortMyTable(a, b)
			return HTable[a] > HTable[b]
		end

		table.sort(STable, sortMyTable)

		DTable = {}
		for i, k in ipairs(STable) do
			local ability = STable[i]
			local color = Itable[ability]["Color"]
			local ctype = ""

			-- Change Color of Spell
			if FCL.CText.AbilityColor == true then
				if (color == 1) then						--Generic	
					if FCL.Hiden == "Heal" then				--Heal
						ctype = FCL.CText.HealColor
					else
						ctype = FCL.CText.GenericColor
					end
				elseif (color == 2) then					--Physical
					ctype = FCL.CText.PhysicalColor
				elseif (color == 3) then					--Fire
					ctype = FCL.CText.FireColor
				elseif (color == 4) then					--Shock
					ctype = FCL.CText.ShockColor
				elseif (color == 5) then					--Oblivion
					ctype = FCL.CText.OblivionColor
				elseif (color == 6) then					--Cold
					ctype = FCL.CText.ColdColor
				elseif (color == 7) then					--Earth
					ctype = FCL.CText.EarthColor
				elseif (color == 8) then					--Magic
					ctype = FCL.CText.MagicColor
				elseif (color == 9) then					--Drown
					ctype = FCL.CText.DrownColor
				elseif (color == 10) then					--Disease
					ctype = FCL.CText.DiseaseColor
				elseif (color == 11) then					--Poison
					ctype = FCL.CText.PoisonColor
				else										--None
				end
			else
				ctype = "|cffffff"
			end

			Scolor[ability] = ctype

			table.insert(MTable, Itable[ability])
			table.insert(DTable, ctype .. ability .. ":|r " .. HTable[k])
			Tdam = Tdam + HTable[k]
		end
	end
	table.insert(DTable, "Total: ".. Tdam)

	if FCL.Hiden == "Attack" then
		for i, v in pairs(MTable) do
			local keytable = {}
			table.insert(keytable, Scolor[STable[i]] .. STable[i] .. " Stats -|r")
			table.insert(keytable, "Total Damage: " .. MTable[i]["Total Damage"])
			table.insert(keytable, "Times Used: " .. MTable[i]["Times Used"])
			table.insert(keytable, "Number of Crits: " .. MTable[i]["Number Crits"])
			table.insert(keytable, "Max Damage: " .. MTable[i]["Max Damage"])
			table.insert(keytable, "Min Damage: " .. MTable[i]["Min Damage"])
			local per = MTable[i]["Total Damage"] / Tdam * 100
			table.insert(keytable, "Percent of Total Damage: " .. string.format( "%.2f" , per) .. "%")
			local crit = MTable[i]["Number Crits"] / MTable[i]["Times Used"] * 100
			table.insert(keytable, "Percent Crit: " .. string.format( "%.2f" , crit) .. "%")
			table.insert(MDTable, table.concat(keytable, "\n"))
		end
	elseif FCL.Hiden == "Heal" then
		for i, v in pairs(MTable) do
			local keytable = {}
			table.insert(keytable, Scolor[STable[i]] .. STable[i] .. " Stats -|r")
			table.insert(keytable, "Total Heal: " .. MTable[i]["Total Damage"])
			table.insert(keytable, "Times Used: " .. MTable[i]["Times Used"])
			table.insert(keytable, "Number of Crits: " .. MTable[i]["Number Crits"])
			table.insert(keytable, "Max Heal: " .. MTable[i]["Max Damage"])
			table.insert(keytable, "Min Heal: " .. MTable[i]["Min Damage"])
			local per = MTable[i]["Total Damage"] / Tdam * 100
			table.insert(keytable, "Percent of Total Heal: " .. string.format( "%.2f" , per) .. "%")
			local crit = MTable[i]["Number Crits"] / MTable[i]["Times Used"] * 100
			table.insert(keytable, "Percent Crit: " .. string.format( "%.2f" , crit) .. "%")
			table.insert(MDTable, table.concat(keytable, "\n"))
		end
	end
	if (FCL.CText.Direction == "DOWN") then
		return DTable, MDTable
	else
		local RevDTable = {}
		local RevMDTable = {}
		RevDTable = table.reverse(DTable)
		RevMDTable = table.reverse(MDTable)
		return RevDTable, RevMDTable
	end
end

--[[----------------------------------------------------------
	Reverse Table
 ]]-----------------------------------------------------------
function table.reverse ( tab )
    local size = #tab+1
    local newTable = {}
    for i,v in ipairs ( tab ) do
        newTable[size-i] = v
    end
    return newTable
end

--[[----------------------------------------------------------
	ADD up Damage for DPS Function
 ]]-----------------------------------------------------------
function FCL.DPS( damage , ability, crit, color )
	-- Record Total Damage
	FCL.CText.Stats.TDam = FCL.CText.Stats.TDam + damage
	-- Record Max Damage
	if damage > FCL.CText.Stats.MaxDam then
		FCL.CText.Stats.MaxDam = damage
	end

	local dps = FCL.DPSMeter
	FCL.Damage = FCL.CText.Attack

	-- Add up Damage
	dps = dps + damage

	-- Send data back to the FTC object
	FCL.DPSMeter = dps
	FCL.TotalDamage = FCL.TotalDamage + damage

	-- Adds ability to table
	if FCL.Damage == nil then
		FCL.Damage = {}
	end

	if FCL.Damage[ability] == nil then
		FCL.Damage[ability] = {
			["Total Damage"] = 0,
			["Times Used"] = 0,
			["Number Crits"] = 0,
			["Max Damage"] = 0,
			["Min Damage"] = 1000000000,
			["Color"] = 0
		}
	end
	FCL.Damage[ability]["Color"] = color
	FCL.Damage[ability]["Total Damage"] = FCL.Damage[ability]["Total Damage"] + damage
	FCL.Damage[ability]["Times Used"] = FCL.Damage[ability]["Times Used"] + 1
	if damage > FCL.Damage[ability]["Max Damage"] then
		FCL.Damage[ability]["Max Damage"] = damage
	end
	if damage < FCL.Damage[ability]["Min Damage"] then
		FCL.Damage[ability]["Min Damage"] = damage
	end
	if crit == true then
		FCL.Damage[ability]["Number Crits"] = FCL.Damage[ability]["Number Crits"] + 1
	end	
	-- Save New Data
	FCL.CText.Attack = FCL.Damage	
	-- Display Results
	FCL.ButtonToggle()
end

--[[----------------------------------------------------------
	ADD up Heal for HPS Function
 ]]-----------------------------------------------------------
function FCL.HPS( damage , ability, crit, color )
	-- Record Total Healing
	FCL.CText.Stats.THeal = FCL.CText.Stats.THeal + damage
	-- Record Max Heal
	if damage > FCL.CText.Stats.MaxHeal then
		FCL.CText.Stats.MaxHeal = damage
	end

	local hps = FCL.HPSMeter
	-- Add up Damage
	hps = hps + damage		

	-- Send data back to the FTC object
	FCL.HPSMeter = hps
	FCL.TotalHealing = FCL.TotalHealing + damage

	-- Adds ability to table
	if FCL.Heal == nil then
		FCL.Heal = {}
	end

	if FCL.Heal[ability] == nil then
		FCL.Heal[ability] = {
			["Total Damage"] = 0,
			["Times Used"] = 0,
			["Number Crits"] = 0,
			["Max Damage"] = 0,
			["Min Damage"] = 1000000000,
			["Color"] = 0
		}
	end
	FCL.Heal[ability]["Color"] = color
	FCL.Heal[ability]["Total Damage"] = FCL.Heal[ability]["Total Damage"] + damage
	FCL.Heal[ability]["Times Used"] = FCL.Heal[ability]["Times Used"] + 1
	if damage > FCL.Heal[ability]["Max Damage"] then
		FCL.Heal[ability]["Max Damage"] = damage
	end
	if damage < FCL.Heal[ability]["Min Damage"] then
		FCL.Heal[ability]["Min Damage"] = damage
	end
	if crit == true then
		FCL.Heal[ability]["Number Crits"] = FCL.Heal[ability]["Number Crits"] + 1
	end
	-- Save New Data
	FCL.CText.Heal = FCL.Heal
	-- Display Results
	FCL.ButtonToggle()
end

--[[----------------------------------------------------------
	Killing Blow (probably only PvP)
 ]]-----------------------------------------------------------
 function FCL.KillBlow()
	-- Record Killing Blows
	FCL.CText.Stats.Kills = FCL.CText.Stats.Kills + 1
	-- Output to You Window
	if FCL.CText.NameColor == true then
		local display = FCL.CText.YouColor .. "You|r dealt KILLING BLOW (" .. FCL.CTEXT.Kills .. ")"
	else
		local display = "You dealt KILLING BLOW (" .. FCL.CTEXT.Kills .. ")"
	end
		-- Puts in time stamp from button
		if (FCL.CText.Time == true) then
			table.insert(FCL.CText.You, 1, "[" ..GetTimeString() .. "]" .. display)
		else	
			table.insert(FCL.CText.You, 1, display)
		end
		if FCL.Hiden == "You" then
			for i = 1, FCL.CText.MaxLines do
				if FCL.CText.You[FCL.Value + i] ~= nil then
					_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
				end
			end
		end
 end

--[[----------------------------------------------------------
	Death Happens
 ]]-----------------------------------------------------------
function FCL.Dead()
	-- Count and Record Deaths
	FCL.CText.Stats.Death = FCL.CText.Stats.Death + 1
	if (FCL.Target.lvl == 1) and (FCL.Target.dif == 0) and (FCL.Target.react == 4 or 3 or 2) then
		local display = "Critter Target While Killed: CANCEL YOUR ACCOUNT, BADDIE"
		-- Puts in time stamp from button
		if (FCL.CText.Time == true) then
			table.insert(FCL.CText.You, 1, "[" ..GetTimeString() .. "]" .. display)
		else
			table.insert(FCL.CText.You, 1, display)
		--FCL.CText.You = "[" ..GetTimeString() .. "]" .. FCL.CText.You
		end
		if FCL.Hiden == "You" then
			for i = 1, FCL.CText.MaxLines do
				if FCL.CText.You[FCL.Value + i] ~= nil then
					_G["CombatLog_Textbox"..i]:SetText(FCL.CText.You[FCL.Value + i])
				end
			end
		end
	end
end

--[[----------------------------------------------------------
	DPS Update with time (OnUpdate)
 ]]-----------------------------------------------------------
function FCL.DPSUpdate( self , time )
	--[[-------------------------------------
		Display
	--]]-------------------------------------
	-- Delay Start
	if FCL.Starter == false then return end

	if FCL.CText.Buffer == true then
		--Wykkyd's Buffer
		if not BufferReached("CLSBuffer", FCL.CText.BufferSpeed) then return end
	end

	DPS:SetDimensions(DPS_LabelVal:GetWidth()+DPS_LabelTex:GetWidth()+25,DPS_LabelVal:GetHeight())
	DPS_LabelTex:SetAnchor(TOPLEFT, DPS ,TOPLEFT,0,0)
	DPS_LabelVal:SetAnchor(TOPLEFT, DPS_LabelTex ,TOPRIGHT,5,0)

	-- Remake LT Display
	if FCL.Hiden == "LT" then
		FCL.LTCreate()
	end

	local bar = ZO_MainMenuCategoryBarButton1:IsHidden()
	local state = IsGameCameraUIModeActive()
	local skill = ZO_InteractWindow:IsHidden()
	local lore = ZO_LoreReader:IsHidden()
	local shared = ZO_SharedRightPanelBackground:IsHidden()
	local escape = ZO_GameMenu_InGame:IsHidden()
	local crafting = IsPlayerInteractingWithObject()
	local options = ZO_OptionsWindow:IsHidden()

	--Hide When in menu and only hide some parts when not
	if (state == true) and (bar == false or skill == false or lore == false or shared == false or escape == false) and (options == true) then
		if FCL.CText.HiddenD == false then
			DPS:SetHidden(true)
		end
		if FCL.CText.HiddenM == false then
			_G["CombatText"]:SetHidden(true)
			if FCL.CText.FadesWithChat == true then
				if FCL.State == true then
					_G["CombatLog"]:SetHidden(false)
				else
					if time < FCL.FadeTime/1000 + FCL.CText.FadeTimer then
						_G["CombatLog"]:SetHidden(false)
					else
						_G["CombatLog"]:SetHidden(true)
					end
				end
			else
				_G["CombatLog"]:SetHidden(true)
			end
			_G["CombatLog_SliderHBD"]:SetAlpha(0)
			_G["CombatLog_SliderH"]:SetHidden(true)
			if FCL.CText.ShowBG == false then
				_G["CombatLog_BD"]:SetAlpha(0)
			end
		end
	elseif (state == false) and (bar == true or skill == true or lore == true or shared == true or escape == true) then
		if FCL.CText.HiddenD == false then
			DPS:SetHidden(false)
		end
		if FCL.CText.HiddenM == false then
			if FCL.CText.FadesWithChat == true then
				if FCL.State == true then
					_G["CombatLog"]:SetHidden(false)
				else
					if time < FCL.FadeTime/1000 + FCL.CText.FadeTimer then
						_G["CombatLog"]:SetHidden(false)
					else
						_G["CombatLog"]:SetHidden(true)
					end
				end
			else
				_G["CombatLog"]:SetHidden(false)
			end
			_G["CombatText"]:SetHidden(true)
			_G["CombatLog_SliderHBD"]:SetAlpha(0)
			_G["CombatLog_SliderH"]:SetHidden(true)
			if FCL.CText.ShowBG == false then
				_G["CombatLog_BD"]:SetAlpha(0)
			end
		end
	elseif (state == true) and (bar == true or skill == true or lore == true or shared == true or escape == true) then
		if FCL.CText.HiddenD == false then
			DPS:SetHidden(false)
		end
		if FCL.CText.HiddenM == false then
		_G["CombatText"]:SetHidden(false)
		_G["CombatLog"]:SetHidden(false)
		_G["CombatLog_BD"]:SetAlpha(1)
		_G["CombatLog_SliderHBD"]:SetAlpha(1)
		_G["CombatLog_SliderH"]:SetHidden(false)
		end
	end

	--[[----------------------------------
		Numbers for Meter
	--]]----------------------------------
	-- Get Player Stats
	local stat_id = _G['POWERTYPE_HEALTH']
	FCL.current, FCL.maximum,_ = GetUnitPower( "player" , stat_id )
	local percent 	= math.floor( ( FCL.current / FCL.maximum ) * 100 )

	if (FCL.State == true) then
		FCL.FadeTime = time * 1000
		-- For Buttons
		if (FCL.DPSMeter == nil) then
			FCL.DPSMeter = 0
		end

		if (FCL.HPSMeter == nil) then
			FCL.HPSMeter = 0
		end

		if (self.StartTime == 0) then
			self.StartTime = time
		end

		local startTime = self.StartTime

		-- Calculate fight time
		local fight_time =  math.max(( time - startTime ) , 1 )
		FCL.FTime = fight_time

		-- Calculate DPS
		local dps = FCL.DPSMeter / fight_time

		-- Calculate HPS
		local hps = FCL.HPSMeter / fight_time

		-- Generate Output to Label
		local displaytex = "DPS:" .. "\n" .. "Total Damage:" .. "\n" .. "HPS:" .. "\n" .. "Total Heal:" .. "\n" .. "Total Time:"
		local displayval = string.format( "%.2f" , dps ) .. "\n" .. FCL.DPSMeter .. "\n" .. string.format( "%.2f" , hps ) .. "\n" .. FCL.HPSMeter .. "\n" .. string.format( "%.2f" , fight_time )

		-- Display Results
		DPS_LabelVal:SetText(displayval)
		DPS_LabelTex:SetText(displaytex)

		-- Wykkyd Told me to do it
		FCL.Target = {
			["lvl"] = GetUnitLevel("reticleover"),
			["dif"] = GetUnitDifficulty("reticleover"),
			["react"] = GetUnitReaction("reticleover")
		}
	elseif (FCL.State == false) and (FCL.Check == false) then
		FCL.CText.Stats.FTime = FCL.CText.Stats.FTime + FCL.FTime
		FCL.FTime = 0
		FCL.DPSMeter = 0
		FCL.HPSMeter = 0
		self.StartTime = 0
	end

	FCL.State = IsUnitInCombat('player')
end