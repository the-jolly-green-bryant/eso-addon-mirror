local _addon = WYK_FullImmersion

local compassEnabled, compassLocked, compassHLocked, compassHideTip, compassHideBackground, compassScale, compassHeight, compassWidth, compassTextScale, compassOpacity, offsetX, offsetY

local loadSetting = function( key, val ) return _addon:GetOrDefault( val, _addon.Settings[ key ] ) end

local loadSettings = function()
	offsetX = loadSetting( "offsetX", 0 )
	offsetY = loadSetting( "offsetY", 40 )
	compassEnabled = loadSetting( "compassEnabled", false )
	compassLocked = loadSetting( "compassLocked", true )
	compassHLocked = loadSetting( "compassHLocked", true )
	compassHideTip = loadSetting( "compassHideTip", false )
	compassHideBackground = loadSetting( "compassHideBackground", false )
	compassScale = loadSetting( "compassScale", 100 )
	compassHeight = loadSetting( "compassHeight", 30 )
	compassWidth = loadSetting( "compassWidth", 600 )
	compassTextScale = loadSetting( "compassTextScale", 100 )
	compassOpacity = loadSetting( "compassOpacity", 100 )
end

local hasChanged = false

_addon.HandleCompass = function()
	loadSettings()
	if not compassEnabled then
		if hasChanged then ReloadUI()
		else return end
	end

	hasChanged = true
	if LWF4.__PlayerActivated then _addon:OnUpdateCallback( "compass_hook" ) end

	if not compassLocked then
		ZO_CompassFrame:SetMovable(true)
		ZO_CompassFrame:SetMouseEnabled(true)
		ZO_CompassFrame:SetClampedToScreen(true)
		ZO_CompassFrame:SetHandler( "OnMoveStop", function()
			offsetY = ZO_CompassFrame:GetTop()
			if compassHLocked then offsetX = 0 end
			_addon.Settings[ "offsetX" ] = offsetX
			_addon.Settings[ "offsetY" ] = offsetY
			ZO_CompassFrame:ClearAnchors()
			ZO_CompassFrame:SetAnchor(TOP,GuiRoot,TOP,offsetX,offsetY)
		end )
	else
		ZO_CompassFrame:ClearAnchors()
		ZO_CompassFrame:SetAnchor(TOP,GuiRoot,TOP,offsetX,offsetY)
		ZO_CompassFrame:SetMovable(false)
		ZO_CompassFrame:SetMouseEnabled(false)
		ZO_CompassFrame:SetClampedToScreen(false)
	end

	if compassHideTip then
		ZO_CompassCenterOverPinLabel:SetHidden( true )
		ZO_CompassCenterOverPinLabel:SetHeight( 0 )
	else
		ZO_CompassCenterOverPinLabel:SetHidden( false )
		ZO_CompassCenterOverPinLabel:SetHeight( 23 )
		ZO_CompassCenterOverPinLabel:SetScale(compassTextScale/100)
	end

	if compassHideBackground then
		ZO_CompassFrameCenter:SetHidden( true )
		ZO_CompassFrameLeft:SetHidden( true )
		ZO_CompassFrameRight:SetHidden( true )
	else
		ZO_CompassFrameCenter:SetHidden( false )
		ZO_CompassFrameLeft:SetHidden( false )
		ZO_CompassFrameRight:SetHidden( false )
	end

	ZO_Compass:SetDimensions(compassWidth,compassHeight)
	ZO_CompassFrameLeft:SetDimensions(10,compassHeight)
	ZO_CompassFrameRight:SetDimensions(10,compassHeight)
	ZO_CompassFrame:SetDimensions(compassWidth-20,compassHeight)
	ZO_CompassFrame:SetAnchor(TOP,GuiRoot,TOP,offsetX,offsetY)
	ZO_Compass:SetAlpha( compassOpacity/100 )

	if compassScale then ZO_Compass:SetScale( compassScale/100 )
	else ZO_Compass:SetScale( 1 ) end

end


function CompassLoad(Event, AddonName)

		local timelastrun = 0
		ZO_CompassFrame:SetHandler("OnUpdate", function(self, timerun)
			if (timerun - timelastrun) >= 5 then
				timelastrun = timerun
				_addon.HandleCompass()
			end
		end)

end

EVENT_MANAGER:RegisterForEvent("CompassLoad",  EVENT_ZONE_CHANGED, CompassLoad)

WYK_FullImmersion = _addon
