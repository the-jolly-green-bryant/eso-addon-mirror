--[[--

		All the world's a stage,
			And all the men and women merely players;
			They have their exits and their entrances...

			-- As You Like It (Act 2, Scene 7, Page 6)  William Shakespeare
		 
--]]--
ESOTheater.ESOStage = {}
local ET = ESOTheater
local maxButtons = 10
local StageIsActive = false

function ET.ESOStage:Initialize()
	local control = GetControl("TheaterFrame")	
	local quickbtns = CreateControlFromVirtual("TheaterFrameButtonGroup", control, "ButtonPanelTemplate",1)
	quickbtns:ClearAnchors()
	quickbtns:SetAnchor(CENTER, control , TOP, 0, 10)
	quickbtns:SetHidden( true )

	local BtnClose = control:GetNamedChild( "ButtonClose" )
	BtnClose:SetHandler( 'OnClicked', function() self:Hide() StageIsActive = false end )
	local BtnMinimize = control:GetNamedChild( "ButtonMinimize" )
	BtnMinimize:SetHandler( 'OnClicked', function() ESOTheater.ESOStage:MinimizeWindowToggle() end )
	
	local BtnTest = control:GetNamedChild( "ButtonTesting" )
	BtnTest:SetHidden( true )

	local checkboxcontrol = GetControl("TheaterFrameCheckbox")
	checkboxcontrol.checkedText = ET.AddOnStrings.EN_OFF
	checkboxcontrol.uncheckedText = ET.AddOnStrings.EN_ON
	checkboxcontrol:SetText(ET.AddOnStrings.EN_OFF)
	--checkboxcontrol:SetState(BSTATE_NORMAL, true)
	ZO_PreHookHandler(checkboxcontrol, "OnClicked", function() ESOTheater.SetTransparentFlag(not ESOTheater.GetTransparentFlag()) end )
	
end

function ET.ESOStage:Show()
	local control = GetControl("TheaterFrame")
	if StageIsActive then
		control:SetHidden( false )
	end
end

function ET.ESOStage:Hide()
	local control = GetControl("TheaterFrame")
	control:SetHidden( true )
end

function ET.ESOStage:ToggleWindow()
	local control = GetControl("TheaterFrame")
    if ( control:IsHidden() ) then
		StageIsActive = true
        control:SetHidden( false )
	else
		StageIsActive = false
		control:SetHidden( true )
    end
end

function ET.ESOStage:LoadFavoriteButtons()
		
		local control = GetControl("TheaterFrame")
		
		local x = 0
		local y = 0

		local uielements = ET.TweaksUI.MainWindow

		control:SetWidth(uielements.WindowWidth)
		control:SetHeight(uielements.WindowHeight)

		local xOffsetbase = uielements.ButtonBaseOffsetX
		local yOffsetbase = uielements.ButtonBaseOffsetY
		local xOffsetRelative = uielements.ButtonRelativeOffsetX
		local yOffsetRelative = uielements.ButtonRelativeOffsetY
		local btnWidth = uielements.ButtonSize


		for i,v in pairs(ET.CurrentSVars.FavoriteTable) do
			if (y < 5) then
				y = y + 1
			else
				y = 1
				x = x + 1
			end
			
			local itemcontrol = CreateControlFromVirtual("TheaterFrameButtonFavorite", control, "ButtonFavoriteTemplate", i)
			itemcontrol:ClearAnchors()
			itemcontrol:SetAnchor(TOPLEFT, nul, nul, xOffsetbase+(xOffsetRelative*x), yOffsetbase+(yOffsetRelative*y))
			local favbtncontrol = itemcontrol:GetNamedChild( "ButtonFavorite" )
			favbtncontrol:SetHandler( 'OnClicked', function() ESOTheater.PlayEmoteByID( v["ID"]  ) end )
			favbtncontrol:SetWidth(btnWidth)
			local favbtnLabel = favbtncontrol:GetLabelControl()
			favbtnLabel:SetText(string.format("%s", v["EmoteName"] ))
			local cfgbtncontrol = itemcontrol:GetNamedChild( "ButtonCfgFavorite" )
			cfgbtncontrol:SetHandler( 'OnClicked', function()  ESOTheater.ESOPlaybill:Show( itemcontrol:GetName() ) end )
			if ( i <= 5 ) then
					local btncontrol = GetControl("TheaterFrameButtonGroup1Panel"..i.."Button" )
					btncontrol:SetHandler( 'OnClicked', function() ESOTheater.PlayEmoteByID( v["ID"]  ) end )
			end
			if ( x > 0) then
				cfgbtncontrol:ClearAnchors()
				cfgbtncontrol:SetAnchor(TOPLEFT, favbtncontrol, TOPRIGHT, -20, -10)
			end
		end

end

function ET.ESOStage:ReLoadFavoriteButtons()
		
		for i,v in pairs(ET.CurrentSVars.FavoriteTable) do
			local favbtncontrol = GetControl( "TheaterFrameButtonFavorite"..i.."ButtonFavorite" )
			favbtncontrol:SetHandler( 'OnClicked', function() ESOTheater.PlayEmoteByID( v["ID"]  ) end )
			local favbtnLabel = favbtncontrol:GetLabelControl()
			favbtnLabel:SetText(string.format("%s", v["EmoteName"] ))
			local cfgbtncontrol = GetControl( "TheaterFrameButtonFavorite"..i.."ButtonCfgFavorite" )
			cfgbtncontrol:SetHandler( 'OnClicked', function()  ESOTheater.ESOPlaybill:Show( "TheaterFrameButtonFavorite"..i ) end )
		end
		
end

function ET.ESOStage:FavoriteButtonOnChange(aname, emoteid)
	--Change the Stage button
	local control = GetControl("TheaterFrame")
	local favbtncontrol = control:GetNamedChild( aname.."ButtonFavorite" )
	favbtncontrol:SetHandler( 'OnClicked', function() ESOTheater.PlayEmoteByID( emoteid  ) end )
	local favbtnLabel = favbtncontrol:GetLabelControl()
	local oldemote = favbtnLabel:GetText()
	favbtnLabel:SetText(string.format("%s", ET.EmoteNameByID(emoteid)))
	
	--Update the SavedVariables
	--Using table index in-case someone wants an emote more than once 
	local tableindex = 0
	tableindex = tonumber(string.sub(aname,15))
	
	for i,v in pairs(ET.CurrentSVars.FavoriteTable) do
		if ( i == tableindex ) then
		--[[--
			if ET.IsVerbose() then
				ET.PrintSystemChat( string.format("%d %s", i, v["ID"]))
				ET.PrintSystemChat( string.format("%d %s", i, v["EmoteName"]))
			end
		--]]--
			v["ID"] = emoteid
			v["EmoteName"] = string.format("%s", ET.EmoteNameByID(emoteid))
		end
	end
end

function ET.ESOStage:ButtonStateToggle()
	--Used when the configuration window shown/hidden
	for i = 1, maxButtons do
		local cfgbtncontrol = GetControl("TheaterFrameButtonFavorite"..i.."ButtonCfgFavorite")
		local btnstatus = cfgbtncontrol:GetState()
		if (btnstatus == BSTATE_DISABLED) then
			cfgbtncontrol:SetState(BSTATE_NORMAL, false)
		else
			cfgbtncontrol:SetState(BSTATE_DISABLED, true)
		end
	end
end

function ET.ESOStage:MinimizeWindowToggle()
	local control = GetControl("TheaterFrame")
	local btncontrol = control:GetNamedChild("ButtonGroup1" )
	if (btncontrol:IsHidden()) then
		btncontrol:SetHidden( false )
	else
		btncontrol:SetHidden( true )
	end
	--Quick way to appear to be minimizing window
	for i = 1, maxButtons do
		local cfgbtncontrol = GetControl("TheaterFrameButtonFavorite"..i.."ButtonCfgFavorite")
		local favbtncontrol = GetControl( "TheaterFrameButtonFavorite"..i.."ButtonFavorite" )
		
		if cfgbtncontrol:IsHidden() then
			cfgbtncontrol:SetHidden( false )
			favbtncontrol:SetHidden( false )
			control:SetHeight(215)			
		else
			cfgbtncontrol:SetHidden( true )
			favbtncontrol:SetHidden( true )
			control:SetHeight(25)			
		end
	end	
end

function ET.ESOStage:MoveWindow( x, y )
		local mainFrame = GetControl("TheaterFrame")
		mainFrame:ClearAnchors()
		mainFrame:SetAnchor( TOPLEFT, GetControl("GuiRoot"), TOPLEFT, x, y)
end

function ET.ESOStage:SaveWindowPosition()
	
	local mainFrame = GetControl("TheaterFrame")
	local _,a,_,b,x,y = mainFrame:GetAnchor()
	local x2 =mainFrame:GetLeft()
	local y2 = mainFrame:GetTop()
	if ET.IsVerbose() then
		ET.PrintSystemChat( string.format("Anchor location returned= %d : %d",x ,y ))
		ET.PrintSystemChat( string.format("Top and Left inside GuiRoot= %d : %d",x2 ,y2 ))
	end
	--I'm going with Top and Left :D
	--Anchor appears to be influenced by other controls on the screen?
	ET.CurrentSVars.UserSettings.StageLocation.Xoffset = x2
	ET.CurrentSVars.UserSettings.StageLocation.Yoffset = y2

end

function ET.ESOStage:GetFavoriteButtonEmote( btnnumber )
	local buttonid = tonumber(btnnumber) or 0
	if (buttonid > 0) and (buttonid <= maxButtons) then
		local favbtncontrol = GetControl( "TheaterFrameButtonFavorite"..buttonid.."ButtonFavorite" )
		local favbtnLabel = favbtncontrol:GetLabelControl()
		emotename = favbtnLabel:GetText()
		return emotename
	end
	return
end

function ET.ESOStage:OnSlashCommand()
	local control = GetControl("TheaterFrame")
	StageIsActive = true
	ET.ESOStage:Show()
	if ET.IsVerbose() then
		ET.PrintSystemChat(ET.Name.." "..ET.Version.." Loaded.")
	end
end
