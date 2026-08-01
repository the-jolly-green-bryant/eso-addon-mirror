local LCA = LibCombatAlerts
local CA2 = CombatAlerts2


--[[ Important note for addon developers ---------------------------------------
A number of the controls here are intended for use only by stock Combat Alerts
modules and should not be used by third-party addons. To avoid conflicts, third-
party addons should instead use LibCombatAlerts to instantiate their own copies
of these controls.

Instead of CA2.Status, use LCA.StatusPanel
Instead of CA2.GroupPanel, use LCA.GroupPanel
Instead of CA2.ScreenBorder, use LCA.ScreenBorder
Instead of CA2.World, use LCA.WorldDrawing
]]


--------------------------------------------------------------------------------
-- Status panel
--------------------------------------------------------------------------------

do
	local Status
	local function GetStatus( )
		if (not Status) then
			Status = LCA.StatusPanel:New()
			Status:SetRepositionCallback(function(pos) CA2.sv.statusPanel = pos end)
		end
		return Status
	end

	function CA2.StatusEnable( options )
		options = options or { }
		options.pos = CA2.sv.statusPanel
		return GetStatus():Enable(options)
	end

	function CA2.StatusDisable( )
		if (Status) then
			Status:Disable()
		end
	end

	function CA2.StatusGetOwnerId( )
		if (Status) then
			return Status:GetOwnerId()
		else
			return nil
		end
	end

	function CA2.StatusSetPosition( ... )
		if (CA2.StatusGetOwnerId()) then
			Status:SetPosition(...)
		end
	end

	function CA2.StatusSetRowColor( ... )
		if (CA2.StatusGetOwnerId()) then
			Status:SetRowColor(...)
		end
	end

	function CA2.StatusSetRowAlpha( ... )
		if (CA2.StatusGetOwnerId()) then
			Status:SetRowAlpha(...)
		end
	end

	function CA2.StatusSetRowHidden( ... )
		if (CA2.StatusGetOwnerId()) then
			Status:SetRowHidden(...)
		end
	end

	function CA2.StatusModifyCell( ... )
		if (CA2.StatusGetOwnerId()) then
			Status:ModifyCell(...)
		end
	end

	function CA2.StatusSetCellText( r, c, text )
		if (CA2.StatusGetOwnerId()) then
			Status:ModifyCell(r, c, { text = text })
		end
	end
end


--------------------------------------------------------------------------------
-- Group status panel
--------------------------------------------------------------------------------

do
	local GroupPanel
	local function GetGroupPanel( )
		if (not GroupPanel) then
			GroupPanel = LCA.GroupPanel:New()
			GroupPanel:SetRepositionCallback(function(pos) CA2.sv.groupPanel = pos end)
		end
		return GroupPanel
	end

	function CA2.GroupPanelEnable( options )
		options = options or { }
		options.pos = CA2.sv.groupPanel
		GetGroupPanel():Enable(options)
	end

	function CA2.GroupPanelDisable( )
		if (GroupPanel) then
			GroupPanel:Disable()
		end
	end

	function CA2.GroupPanelIsEnabled( )
		if (GroupPanel) then
			return GroupPanel:IsEnabled()
		else
			return false
		end
	end

	function CA2.GroupPanelSetPosition( ... )
		if (CA2.GroupPanelIsEnabled()) then
			GroupPanel:SetPosition(...)
		end
	end

	function CA2.GroupPanelUpdate( ... )
		if (CA2.GroupPanelIsEnabled()) then
			GroupPanel:UpdateUnitData(...)
		end
	end
end


--------------------------------------------------------------------------------
-- Screen border alerts
--------------------------------------------------------------------------------

do
	local Border
	local function GetBorder( )
		if (not Border) then
			Border = LCA.ScreenBorder:New()
		end
		return Border
	end

	function CA2.ScreenBorderEnable( ... )
		return GetBorder():Enable(...)
	end

	function CA2.ScreenBorderDisable( ... )
		if (Border) then
			Border:Disable(...)
		end
	end
end


--------------------------------------------------------------------------------
-- World drawing
--------------------------------------------------------------------------------

do
	local Canvas
	local function GetCanvas( )
		if (not Canvas) then
			Canvas = LCA.WorldDrawing:New()
		end
		return Canvas
	end

	function CA2.WorldTexturePlace( ... )
		return GetCanvas():PlaceTexture(...)
	end

	function CA2.WorldTextureUpdate( ... )
		if (Canvas) then
			Canvas:UpdateTexture(...)
		end
	end

	function CA2.WorldElementRemove( ... )
		if (Canvas) then
			Canvas:RemoveElement(...)
		end
	end

	function CA2.WorldCanvasClear( )
		if (Canvas) then
			Canvas:Clear()
		end
	end

	function CA2.WorldGrowingCircularTelegraph( ... )
		return GetCanvas():PlaceGrowingCircularTelegraph(...)
	end
end


--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

function CA2.CleanupControls( )
	CA2.StatusDisable()
	CA2.GroupPanelDisable()
	CA2.ScreenBorderDisable()
	CA2.WorldCanvasClear()
end
