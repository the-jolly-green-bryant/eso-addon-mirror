local wtStrategyFrameName = "WYK_WarTools_StrategyUI"

WYK_WarTools.UserInterface = {}

WYK_WarTools.UserInterface.Constants = {
	StrategyFrame = {
		UIWidth = 293,
		UIHeight = 670,
		UICenterColor = {0.1,0.1,0.1,1},
		UIEdgeColor = {0,0,0,1},
		UIEdgeTexture = {"", 8, 1, 1},
		UIFontColor = {1,1,1,1},
		UISiegedFontColor = {1,0,0,1},
		UISiegedEdgeColor = {1,.1,.1,1},
	},
}

WYK_WarTools.Events = {}
WYK_WarTools.StrategyUI = {}
WYK_WarTools.ClickEvents = {}

WYK_WarTools.UserInterface.CreateStrategyFrame = function()
	WYK_WarTools.BuildNewWindow()
end

local bufferedTicOnce = {}
local currentTarget = nil
local AvANodes = {}

local shouldParse = function()
	if GetAssignedCampaignId() ~= GetCurrentCampaignId() and GetCurrentCampaignId() ~= 0 then return false; end
	--if GetCampaignUnderdogLeaderAlliance(GetAssignedCampaignId()) == 0 then return false; end
	return true
end

local mapFiguredOut = nil

local makeResourceNode = function( parent, alliance, index, obj1, obj2, name1, name2, list, anchor, primaryResource, isOverview )
	local w2, h2 = 20, 20
	local w1, h1 = 22, 22
	local w3, h3 = 24, 24
	local drawLayer = 9
	local temp = .0001
	local bgCenterTexture = 64
	local settings = {}
	settings.Images = list
	settings.DefaultCColor = { 0, 0, 0, .5 }
	settings.DefaultEColor = { 0, 0, 0, 0 }
	settings.CurrentAlliance = 0
	if isOverview then
		w2, h2 = 24, 24
	end
	if primaryResource then
		drawLayer = 5
		temp = 1
		w2, h2 = 64, 64
		w1, h1 = 66, 66
		w3, h3 = 72, 72
	end
	local Border = WYK_WarTools.Frames.__NewImage(name1.."Border", parent) 
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetDimensions( w3, w3 )
		:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )
		:SetAlpha( 1 )
		:SetDrawLayer( drawLayer-1 )
	.__END
	obj1 = WYK_WarTools.Frames.__NewBackdrop(name1, parent)
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetDimensions( w1, h1 )
		:SetCenterColor( 0, 0, 0, .5 )
		:SetEdgeColor( 0, 0, 0, 0 )
		:SetAlpha( 1 )
		:SetDrawLayer( drawLayer )
	.__END
	obj1.Alliance = alliance
	obj1.ResourceIndex = index
	obj1.ResourceSubIndex = 0
	obj1.DisplayName = ""
	obj1.ResourceType = ""
	if     string.find(name1, "_Keep") then    obj1.ResourceType = "keep"; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index].displayName
	elseif string.find(name1, "_Farm") then    obj1.ResourceType = "farm"; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index].displayName.." Farm"
	elseif string.find(name1, "_Mill") then    obj1.ResourceType = "mill"; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index].displayName.." Lumbermill"
	elseif string.find(name1, "_Mine") then    obj1.ResourceType = "mine"; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index].displayName.." Mine"
	elseif string.find(name1, "_Outpost") then obj1.ResourceType = "outpost"; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index].displayName
	elseif string.find(name1, "_Scroll1") then obj1.ResourceType = "scroll1"; obj1.ResourceSubIndex = 1; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index][1].displayName
	elseif string.find(name1, "_Scroll2") then obj1.ResourceType = "scroll2"; obj1.ResourceSubIndex = 2; obj1.DisplayName = WYK_WarTools.Lists.AllianceObjectives[alliance][index][2].displayName
	end
	AvANodes[obj1.DisplayName] = obj1
	obj1.Border = Border
	obj1:SetParent(obj1.Border)
	obj1:ClearAnchors()
	obj1:SetAnchor( CENTER, obj1.Border, CENTER, 0, 0 )
	obj1.Settings = settings
	obj1.Settings.UnderSiege = false
	obj1.Settings.IsTarget = false
	obj1.MouseIsOver = false
	obj1.positionX = nil
	obj1.positionY = nil
	obj1.PositionSet = function() return obj1.positionX ~= nil; end
	obj1.SetPosition = function(x, y) obj1.positionX = x; obj1.positionY = y; end
	obj1.SetAlliance = function( allianceCode )
		if obj1.Settings.CurrentAlliance ~= allianceCode then
			obj1.Settings.CurrentAlliance = allianceCode
			if obj1.Settings.UnderSiege then
				if obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] ~= nil then
					obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] )
				else
					obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance] )
				end
			else
				obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance] )
			end
		end
	end
	obj1.SetSiege = function( underSiege )
		if underSiege then
			if not obj1.Settings.UnderSiege then
				obj1.Settings.UnderSiege = true
				if obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] ~= nil then
					obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] )
				else
					obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance] )
				end
				obj1:SetCenterColor( .9, .2, .1, .45 )
			end
		else
			if obj1.Settings.UnderSiege then
				local c = obj1.Settings.DefaultCColor
				obj1.Settings.UnderSiege = false
				obj2:SetTexture( obj1.Settings.Images[obj1.Settings.CurrentAlliance] )
				obj1:SetCenterColor( c[1], c[2], c[3], c[4], c[5] )
			end
		end
	end
	obj1.SetTarget = function( isTarget )
		if isTarget then
			if not obj1.Settings.IsTarget then
				obj1.Settings.IsTarget = true
				if obj1.MouseIsOver then
					obj1.Border:SetTexture( "/esoui/art/buttons/swatchframe_up.dds" )
				else
					obj1.Border:SetTexture( "/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds" )
				end
			end
		else
			if obj1.Settings.IsTarget then
				local c = obj1.Settings.DefaultCColor
				obj1.Settings.IsTarget = false
				if obj1.MouseIsOver then
					obj1.Border:SetTexture( "/esoui/art/actionbar/abilityframe64_down.dds" )
				else
					obj1.Border:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )
				end
			end
		end
	end
	obj2 = WYK_WarTools.Frames.__NewImage(name2, obj1) 
		:SetAnchor( CENTER, obj1, CENTER, 0, 0 )
		:SetDimensions( w2, h2 )
		:SetTexture( list[obj1.Settings.CurrentAlliance] )
		:SetAlpha( 1 )
		:SetMouseEnabled( true )
		:SetHandler( "OnMouseEnter", function(self)
			obj1.MouseIsOver = true
			WYK_WarTools_StrategyUI:MouseIn()
			if not obj1.Settings.UnderSiege then 
				obj1:SetCenterColor( .35, 0, .35, .75 ) 
			else
				if obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] ~= nil then
					obj1:SetCenterColor( 1, .4, .2, 1 )
				end
			end
			if obj1.Settings.IsTarget then
				obj1.Border:SetTexture( "/esoui/art/buttons/swatchframe_up.dds" )
			else
				obj1.Border:SetTexture( "/esoui/art/actionbar/abilityframe64_down.dds" )
			end
		end )
		:SetHandler( "OnMouseExit", function(self)
			obj1.MouseIsOver = false
			WYK_WarTools_StrategyUI:MouseOut()
			local c = obj1.Settings.DefaultCColor
			if not obj1.Settings.UnderSiege then 
				obj1:SetCenterColor( c[1], c[2], c[3], c[4], c[5] )
			else
				if obj1.Settings.Images[obj1.Settings.CurrentAlliance+10] ~= nil then
					obj1:SetCenterColor( .9, .2, .1, .55 )
				end
			end
			if obj1.Settings.IsTarget then
				obj1.Border:SetTexture( "/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds" )
			else
				obj1.Border:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )
			end
		end )
		:SetHandler( "OnMouseUp", function(self,button)
			local isGrouped = IsUnitGrouped( 'player' )
			if button == 1 and WYK_WarTools.InCyrodiil() then
				if not mapFiguredOut then
					local maps = GetNumMaps()
					for m = 1, maps, 1 do
						local name, mapType, mapContentType = GetMapInfo(m)
						if name == "Cyrodiil" then
							mapFiguredOut = m
						end
					end
				end
				if GetMapName() == "Cyrodiil" then
					--OpenMap()s
					--PingMap(PING_EVENT_ADDED, MAP_TYPE_LOCATION_CENTERED, obj1.positionX, obj1.positionY)
					--AddMapPin(obj1.positionX, obj1.positionY)
					-- if obj1.PositionSet() then
						-- SetMapWaypoint( obj1.positionX, obj1.positionY )
					-- end
				end
				--MapZoomOut()
				if obj1.PositionSet() then
					d( obj1.positionX .. " x " .. obj1.positionY )
				end
			end
			if button == 2 and WYK_WarTools.InCyrodiil() and isGrouped then
				local msg = ""
				if WYK_WarTools.Mode.Commander then 
					msg = "\n"..WYK_WarTools.Prefix.Commander.." SOMEONE SCOUT >> "..obj1.DisplayName.." <<"
				else
					msg = WYK_WarTools.Prefix.Tools.." Scouting "..obj1.DisplayName
				end
				--WYK_WarTools.Say(WYK_WarTools.channel.PARTY(), msg, nil)
			end
			if button == 3 then
				if currentTarget == obj1 then
					obj1.SetTarget( false )
					currentTarget = nil
				else
					if currentTarget ~= nil then
						currentTarget.SetTarget( false )
					end
					obj1.SetTarget( true )
					currentTarget = obj1
				end
				if currentTarget ~= nil and WYK_WarTools.Mode.Commander and WYK_WarTools.InCyrodiil() and isGrouped then
					local msg = "\n"..WYK_WarTools.Prefix.Commander.." TARGET >> "..obj1.DisplayName.." <<"
					--WYK_WarTools.Say(WYK_WarTools.channel.PARTY(), msg, nil)
				end
			end
		end )
		:SetDrawLayer( drawLayer )
	.__END
	obj2.Settings = settings
	obj2.SetAlliance = obj1.SetAlliance
	obj2.PositionSet = obj1.PositionSet
	obj2.SetPosition = obj1.SetPosition
	obj2.SetSiege = obj1.SetSiege
	obj2.SetTarget = obj1.SetTarget
	return obj1, obj2
end

local makeAvAResourcedObjectiveContent = function( parent, index, alliance )
	local idx = index
	local name = parent:GetName().."Node"..idx
	local obj = WYK_WarTools.Frames.__NewTopLevel(name.."Content") 
		:SetParent( parent )
		:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
		:SetDimensions( 96, 72 )
	.__END

	obj.KeepBG, obj.Keep = makeResourceNode( obj, alliance, index, obj.KeepBG, obj.Keep, name.."_KeepBG", name.."_Keep", WYK_WarTools.Lists.Images.Keeps, { TOPLEFT, obj, TOPLEFT, 0, 0}, true )
	obj.FarmBG, obj.Farm = makeResourceNode( obj, alliance, index, obj.FarmBG, obj.Farm, name.."_FarmBG", name.."_Farm", WYK_WarTools.Lists.Images.Farms, { TOPLEFT, obj.KeepBG.Border, TOPRIGHT, 0, 0 }, false )
	obj.MillBG, obj.Mill = makeResourceNode( obj, alliance, index, obj.MillBG, obj.Mill, name.."_MillBG", name.."_Mill", WYK_WarTools.Lists.Images.Mills, { TOPLEFT, obj.FarmBG.Border, BOTTOMLEFT, 0, 0 }, false )
	obj.MineBG, obj.Mine = makeResourceNode( obj, alliance, index, obj.MineBG, obj.Mine, name.."_MineBG", name.."_Mine", WYK_WarTools.Lists.Images.Mines, { TOPLEFT, obj.MillBG.Border, BOTTOMLEFT, 0, 0 }, false )
	
	return obj
end

local makeAvAResourcedNode = function( parent, index, name, alliance )
	local idx = index
	local c = WYK_WarTools.Lists.AllianceFonts[alliance]
	local oname = parent:GetName().."Container"..idx
	local obj = WYK_WarTools.Frames.__NewTopLevel(oname) 
		:SetParent( parent )
		:SetResizeToFitDescendents( true )
	.__END
	obj.Content = makeAvAResourcedObjectiveContent( obj, idx, alliance )
	obj.TitleBG = WYK_WarTools.Frames.__NewBackdrop(oname.."TitleBG", obj)
		:SetAnchor( TOPLEFT, obj, TOPLEFT, 4, 4 )
		:SetDimensions( 67 , 14 )
		:SetCenterColor( .1, .1, .1, 1 )
		:SetEdgeColor( 0, 0, 0, 1 )
		:SetEdgeTexture( "", 8, 1, 1 )
		:SetAlpha( 1 )
		:SetDrawLayer( 20 )
	.__END
	obj.Title = WYK_WarTools.Frames.__NewLabel(oname.."Title", obj.TitleBG)
		:SetAnchor( CENTER, obj.TitleBG, CENTER, 0, -3 )
		:SetText( name )
		:SetDimensions( 96 , 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( c[1], c[2], c[3], c[4], c[5] )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["center"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
	.__END
	obj.Title:SetScale( .7 )
	return obj
end

local makeAvaSection = function( parent, alliance )
	local obj = WYK_WarTools.Frames.__NewTopLevel("WWT_SFOBJA"..alliance.."Resources") 
		:SetParent( parent )
		:SetAnchor( TOP, parent, TOP, 0, 73 )
		:SetResizeToFitDescendents( true )
	.__END
	obj.Child = {}

	local firstNode = nil
	local lastNode = nil
	for idx = 1, 6, 1 do
		local nm = WYK_WarTools.Lists.AllianceObjectives[alliance][idx].key
		local a = {} -- anchor
		obj.Child[idx] = makeAvAResourcedNode( obj, idx, nm, alliance )
		if lastNode == nil and idx == 1 then
			a = { TOPLEFT, obj, TOPLEFT, 0, 0 }
			firstNode = obj.Child[idx]
		elseif lastNode == nil and idx == 4 then
			a = { TOPLEFT, firstNode, BOTTOMLEFT, 0, 2 }
		else
			a = { LEFT, lastNode, RIGHT, 2, 0 }
		end
		obj.Child[idx]:SetAnchor( a[1], a[2], a[3], a[4], a[5] )
		lastNode = obj.Child[idx]
		if idx == 3 then lastNode = nil end
	end
	return obj
end

local statTextScore = function( parent, alliance, stat, updateFunc, anchor )
	local c = WYK_WarTools.Lists.AllianceFonts[alliance]
	local left = WYK_WarTools.Frames.__NewLabel(parent:GetName().."_StatL_"..stat, parent)
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetText( stat )
		:SetDimensions( 55, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( c[1], c[2], c[3], c[4], c[5] )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["right"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( .8 )
	.__END
	local right = WYK_WarTools.Frames.__NewLabel(parent:GetName().."_StatR_"..stat, left)
		:SetAnchor( LEFT, left, RIGHT, 4, 0 )
		:SetText( "" )
		:SetDimensions( 50, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( 1, 1, 1, 1 )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["left"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( 1 )
	.__END
	local updateMe
	updateMe = function()
		if not shouldParse() then return end
		if bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Stat_"..stat] == nil then
			bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Stat_"..stat] = true
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat )
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat, updateMe, (10+(alliance/10)) )
		end
		local val = updateFunc()
		if val == nil or val == 0 or val == "+0"
		then right:SetText( "" )
		else right:SetText( val )
		end
	end
	WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat, updateMe, 2 )
end

local statImageScore = function( parent, alliance, stat, image, updateFunc, anchor )
	local left = WYK_WarTools.Frames.__NewImage(parent:GetName().."_StatL_"..stat, parent) 
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetDimensions( 28, 28 )
		:SetTexture( image )
		:SetAlpha( 1 )
	.__END
	local right = WYK_WarTools.Frames.__NewLabel(parent:GetName().."_StatR_"..stat, left)
		:SetAnchor( LEFT, left, RIGHT, -5, -2 )
		:SetText( "" )
		:SetDimensions( 30, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( 1, 1, 1, 1 )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["left"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( .8 )
	.__END
	local updateMe
	updateMe = function()
		if not shouldParse() then return end
		if bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Stat_"..stat] == nil then
			bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Stat_"..stat] = true
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat )
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat, updateMe, (10+(alliance/10)+.05) )
		end
		local val = updateFunc()
		if val == nil
		then right:SetText( "" )
		else right:SetText( "x"..val )
		end
	end
	WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Stat_"..stat, updateMe, 2 )
end

local buildAllianceHeader = function( parent, alliance )
	local campaign = GetAssignedCampaignId()
	local leadAlliance = GetCampaignUnderdogLeaderAlliance(campaign)
	local name = "WWT_SFOBJA"..alliance
	local obj = WYK_WarTools.Frames.__NewTopLevel(name.."Header") 
		:SetParent( parent )
		:SetAnchor( TOP, parent, TOP, 0, 0 )
		:SetDimensions( 291, 72 )
	.__END
	obj.BG = WYK_WarTools.Frames.__NewBackdrop(name.."HeaderBG", obj)
		:SetAnchor( CENTER, obj, CENTER, 0, 0 )
		:SetDimensions( 291, 72 )
		:SetCenterColor( .1, .1, .1, .8 )
		:SetEdgeColor( 0, 0, 0, .9 )
		:SetEdgeTexture( "", 8, 1, 1 )
		:SetAlpha( 1 )
		:SetDrawLayer( 20 )
	.__END
	obj.AllianceIconBG = WYK_WarTools.Frames.__NewBackdrop(name.."AllianceIconBG", obj)
		:SetAnchor( LEFT, obj.BG, LEFT, 0, 0 )
		:SetDimensions( 72, 72 )
		:SetCenterColor( 1, 1, 1, 0 )
		:SetEdgeColor( 0, 0, 0, 0 )
		:SetEdgeTexture( "", 8, 1, 1 )
		:SetAlpha( 1 )
		:SetDrawLayer( 20 )
	.__END
	obj.AllianceIcon = WYK_WarTools.Frames.__NewImage(name.."AllianceIcon", obj) 
		:SetAnchor( CENTER, obj.AllianceIconBG, CENTER, 0, 0 )
		:SetDimensions( 64, 64 )
		:SetTexture( WYK_WarTools.Lists.Images.AllianceIcons[alliance] )
		:SetAlpha( 1 )
	.__END

	statTextScore( obj, alliance, "Score", function() return GetCampaignAllianceScore( GetAssignedCampaignId(), alliance ) end, { TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 2, 2 } )
	statTextScore( obj, alliance, "+Points", function() 
		leadAlliance = GetCampaignUnderdogLeaderAlliance(GetAssignedCampaignId())
		if alliance ~= leadAlliance and leadAlliance ~= 0 then
			return "+"..GetCampaignAlliancePotentialScore( GetAssignedCampaignId(), alliance ).."*"
		else
			return "+"..GetCampaignAlliancePotentialScore( GetAssignedCampaignId(), alliance ) 
		end
	end, { TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 2, 18 } )

	statImageScore( obj, alliance, "Keeps", WYK_WarTools.Lists.Images.Overview[alliance][1], function() return GetTotalCampaignHoldings(GetAssignedCampaignId(), HOLDINGTYPE_KEEP, alliance) end, 
		{ TOPLEFT, obj.AllianceIconBG, TOPRIGHT, -5, 29 } )
	statImageScore( obj, alliance, "Outposts", WYK_WarTools.Lists.Images.Overview[alliance][2], function() return GetTotalCampaignHoldings(GetAssignedCampaignId(), HOLDINGTYPE_OUTPOST, alliance) end, 
		{ TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 40, 29 } )
	statImageScore( obj, alliance, "Resources", WYK_WarTools.Lists.Images.Overview[alliance][3], function() return GetTotalCampaignHoldings(GetAssignedCampaignId(), HOLDINGTYPE_RESOURCE, alliance) end, 
		{ TOPLEFT, obj.AllianceIconBG, TOPRIGHT, -5, 47 } )
	statImageScore( obj, alliance, "Scrolls", WYK_WarTools.Lists.Images.Overview[alliance][4], function() 
		return GetTotalCampaignHoldings(GetAssignedCampaignId(), HOLDINGTYPE_OFFENSIVE_ARTIFACT, alliance) + GetTotalCampaignHoldings(GetAssignedCampaignId(), HOLDINGTYPE_DEFENSIVE_ARTIFACT, alliance)
	end, 
		{ TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 40, 47 } )

	local updateStats
	updateStats = function()
		if not shouldParse() then return end
		leadAlliance = GetCampaignUnderdogLeaderAlliance(GetAssignedCampaignId())
		if bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Statistics"] == nil then
			bufferedTicOnce["WWT_UpdateAlliance"..alliance.."Statistics"] = true
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Statistics" )
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Statistics", updateStats, (15+(alliance/10)+.075) )
		end
		if alliance ~= leadAlliance then
			obj.AllianceIconBG:SetCenterColor( 1, 1, 1, 1 )
			obj.AllianceIconBG:SetCenterTexture( "/esoui/art/mappins/ava_attackburst_64.dds", 64 )
			obj.AllianceIcon:SetDimensions( 48, 48 )
		else
			obj.AllianceIconBG:SetCenterTexture( "", 64 )
			obj.AllianceIconBG:SetCenterColor( 1, 1, 1, 0 )
			obj.AllianceIcon:SetDimensions( 64, 64 )
		end
	end
	WYK_WarTools:OnUpdateCallback( "WWT_UpdateAlliance"..alliance.."Statistics", updateStats, 2 )

	obj.OutpostBG, obj.Outpost = makeResourceNode( obj, alliance, 7, obj.OutpostBG, obj.Outpost, name.."_OutpostBG", name.."_Outpost", WYK_WarTools.Lists.Images.Outposts, { TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 90, 0 }, false, true )
	obj.Scroll1BG, obj.Scroll1 = makeResourceNode( obj, alliance, 8, obj.Scroll1BG, obj.Scroll1, name.."_Scroll1BG", name.."_Scroll1", WYK_WarTools.Lists.Images.Scrolls, { TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 90, 24 }, false, true )
	obj.Scroll2BG, obj.Scroll2 = makeResourceNode( obj, alliance, 8, obj.Scroll2BG, obj.Scroll2, name.."_Scroll2BG", name.."_Scroll2", WYK_WarTools.Lists.Images.Scrolls, { TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 90, 48 }, false, true )

	local c = WYK_WarTools.Lists.AllianceFonts[alliance]
	obj.OutpostTitle = WYK_WarTools.Frames.__NewLabel(name.."_OutpostTitle", obj)
		:SetAnchor( TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 117, 5 )
		:SetText( WYK_WarTools.Lists.AllianceObjectives[alliance][7].displayName )
		:SetDimensions( 150, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( c[1], c[2], c[3], c[4], c[5] )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["left"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( .74 )
	.__END

	obj.Scroll1Title = WYK_WarTools.Frames.__NewLabel(name.."_OutpostTitle", obj)
		:SetAnchor( TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 117, 29 )
		:SetText( string.gsub( WYK_WarTools.Lists.AllianceObjectives[alliance][8][1].displayName, "Elder ", "E. " ) )
		:SetDimensions( 150, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( c[1], c[2], c[3], c[4], c[5] )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["left"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( .68 )
	.__END

	obj.Scroll2Title = WYK_WarTools.Frames.__NewLabel(name.."_OutpostTitle", obj)
		:SetAnchor( TOPLEFT, obj.AllianceIconBG, TOPRIGHT, 117, 55 )
		:SetText( string.gsub( WYK_WarTools.Lists.AllianceObjectives[alliance][8][2].displayName, "Elder ", "E. " ) )
		:SetDimensions( 150, 14 )
		:SetFont( "ZoFontGame" )
		:SetColor( c[1], c[2], c[3], c[4], c[5] )
		:SetAlpha( 1 )
		:SetHorizontalAlignment(WYK_WarTools.GLOBAL.TextAlign["h"]["left"])
		:SetVerticalAlignment(WYK_WarTools.GLOBAL.TextAlign["v"]["center"])
		:SetScale( .68 )
	.__END
	return obj
end

local buildAlliance = function( parent, alliance, anchor )
	local obj = WYK_WarTools.Frames.__NewTopLevel(parent:GetName().."Wrapper") 
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetParent( parent )
		:SetDimensions( 291, 218 )
	.__END
	obj.Header = buildAllianceHeader( obj, alliance )
	obj.Header:ClearAnchors()
	obj.Header:SetAnchor( TOP, obj, TOP, 0, 0 )
	obj.Objectives = makeAvaSection( obj, alliance )
	obj.Objectives:ClearAnchors()
	obj.Objectives:SetAnchor( TOP, obj, TOP, 0, 73 )
end

local buildWindow = function( parent )
	local obj = WYK_WarTools.Frames.__NewTopLevel(name) 
		:SetAnchor( TOP, parent, TOP, 0, 17 )
		:SetParent( parent )
		:SetDimensions( 291, 654 )
	.__END
	buildAlliance( obj, 1, { TOP, obj, TOP, 0, 0 } )
	buildAlliance( obj, 2, { TOP, obj, TOP, 0, 219 } )
	buildAlliance( obj, 3, { TOP, obj, TOP, 0, 438 } )
end

function WYK_WarTools.BuildNewWindow()
	local obj = WYK_WarTools.Frames.UIWindow:Create(
		wtStrategyFrameName,
		"Strategy UI . "..WYK_WarTools.DisplayName.." "..WYK_WarTools.Version,
		true,
		true,
		WYK_WarTools:GetOrDefault( { Moveable=true, Hidden=false, ShiftX=0, ShiftY=0, }, WYK_WarTools.Settings["UI"]),
		WYK_WarTools.UserInterface.Constants.StrategyFrame.UIWidth,
		WYK_WarTools.UserInterface.Constants.StrategyFrame.UIHeight,
		1
	)
	obj.Title.Label:ClearAnchors()
	obj.Title.Label:SetAnchor(LEFT, obj.Title.Backdrop, LEFT, 3, -4)
	obj.Title.Label:SetColor( .5, .65, .9, 1 )
	WYK_WarTools_StrategyUI = obj
	buildWindow( WYK_WarTools_StrategyUI.Backdrop )
	WYK_WarTools_StrategyUI:SetScale(WYK_WarTools:GetOrDefault(1, WYK_WarTools.Settings["UIScale"]))
	WYK_WarTools_StrategyUI:SetOutAlpha(WYK_WarTools:GetOrDefault(.5, WYK_WarTools.Settings["UIMouseOutAlpha"]))
	WYK_WarTools_StrategyUI:SetInAlpha(WYK_WarTools:GetOrDefault(.85, WYK_WarTools.Settings["UIMouseInAlpha"]))
	if WYK_WarTools_StrategyUI:IsMousedOver() 
	then WYK_WarTools_StrategyUI.Backdrop:SetAlpha(WYK_WarTools:GetOrDefault(.85, WYK_WarTools.Settings["UIMouseInAlpha"]))
	else WYK_WarTools_StrategyUI.Backdrop:SetAlpha(WYK_WarTools:GetOrDefault(.5, WYK_WarTools.Settings["UIMouseOutAlpha"]))
	end
	WYK_WarTools_StrategyUI:SetHidden( WYK_WarTools:GetOrDefault( false, WYK_WarTools.Settings["UI"].Hidden ) )
	local updateOwnersAndSiege
	updateOwnersAndSiege = function()
		if not shouldParse() then return end
		if bufferedTicOnce["WWT_UpdateOwnersAndSiege"] == nil then
			bufferedTicOnce["WWT_UpdateOwnersAndSiege"] = true
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateOwnersAndSiege" )
			WYK_WarTools:OnUpdateCallback( "WWT_UpdateOwnersAndSiege", updateOwnersAndSiege, (3.675) )
		end
		for keepIndex = 1, GetNumKeeps(), 1 do
			local keepId, battlegroundContext = GetKeepKeysByIndex(keepIndex)
			local keepName, keepAlliance, underSiege = GetKeepName( keepId ), GetKeepAlliance(keepId, battlegroundContext), GetKeepUnderAttack(keepId, battlegroundContext)
			if AvANodes[ keepName ] ~= nil then 
				if not AvANodes[ keepName ].PositionSet() then
					local pinType, currentNormalizedX, currentNormalizedY = GetKeepPinInfo(keepId, battlegroundContext)
					AvANodes[ keepName ].SetPosition( currentNormalizedX, currentNormalizedY )
				end
				AvANodes[ keepName ].SetAlliance( keepAlliance ) 
				if underSiege then AvANodes[ keepName ].SetSiege( true ) 
				else 
					local siegesPresent = 0
					for a = 1, 3, 1 do if AvANodes[ keepName ].Alliance ~= a then siegesPresent = siegesPresent + GetNumSieges(keepId, battlegroundContext, a) end end
					if siegesPresent > 0 then AvANodes[ keepName ].SetSiege( true ) 
					else AvANodes[ keepName ].SetSiege( false ) end
				end
			end
		end
		for avaIndex = 1, GetNumAvAObjectives(), 1 do
			local keepId, objectiveId, battlegroundContext = GetAvAObjectiveKeysByIndex(avaIndex)
			local objectiveName, objectiveType, objectiveState, allianceParam1, allianceParam2 = GetAvAObjectiveInfo(keepId, objectiveId, battlegroundContext)
			if objectiveType == OBJECTIVE_ARTIFACT_DEFENSIVE or objectiveType == OBJECTIVE_ARTIFACT_OFFENSIVE then
				local owner = allianceParam2
				if owner == 0 then owner = allianceParam1 end
				if AvANodes[ objectiveName ] ~= nil then AvANodes[ objectiveName ].SetAlliance( owner ) end
			end
			if AvANodes[ objectiveName ] ~= nil then
				if not AvANodes[ objectiveName ].PositionSet() then
					local pinType, currentNormalizedX, currentNormalizedY, continuousUpdate = GetAvAObjectivePinInfo(keepId, objectiveId, battlegroundContext)
					AvANodes[ objectiveName ].SetPosition( currentNormalizedX, currentNormalizedY )
				end
			end
		end
	end
	WYK_WarTools:OnUpdateCallback( "WWT_UpdateOwnersAndSiege", updateOwnersAndSiege, 2 )
end

