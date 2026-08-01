------------------------------------------------
-- Durability
-- @author Flagrick
------------------------------------------------
local Config					= DurabilityConfig
local CBM						= CALLBACK_MANAGER

local Durability				= ZO_Object:Subclass()
Durability.config				= nil
Durability.db					= nil
Durability.name				= "Durability"
Durability.All					= 100
Durability.RepairAllCost	= 0
Durability.ArmorCount		= 0
Durability.MinArmor			= 100
Durability.MinWeapon			= 100
Durability.Alert				= false
Durability.Onloaded			= false

--default values for addon
Durability_Defaults =
{
	DurabilityX								= 0,
	DurabilityY								= 0,
	DurabilityScale						= 3,
	DurabilityColor_NoArmor 			= { ["r"] = 0.667, ["g"] = 0, ["b"] = 0, ["a"] = 1},
	DurabilityColor_UpToStep1 			= { ["r"] = 0.824, ["g"] = 0.392, ["b"] = 0, ["a"] = 1},
	DurabilityColor_UpToStep2 			= { ["r"] = 1, ["g"] = 0.706, ["b"] = 0, ["a"] = 1},
	DurabilityColor_UpToStep3 			= { ["r"] = 0, ["g"] = 0.627, ["b"] = 0, ["a"] = 1},
	DurabilityColor_FullArmor 			= { ["r"] = 0.784, ["g"] = 0.784, ["b"] = 0.784, ["a"] = 1},
	DurabilityColor_WpnFront 			= { ["r"] = 0, ["g"] = 0.431, ["b"] = 0.784, ["a"] = 1},
	DurabilityColor_WpnBack 			= { ["r"] = 0.667, ["g"] = 0, ["b"] = 0, ["a"] = 1},
	DurabilityAlpha						= 100,
	DurabilityFrameAlpha					= 60,
	DurabilityShow							= true,
	DurabilityAutomaticHidding			= false,
	DurabilityArmorThreshold			= false,
	DurabilityGlobalArmorThreshold	= 50,
	DurabilityMinArmorThreshold		= 25,
	DurabilityWeaponThreshold			= false,
	DurabilityMinWeaponThreshold		= 10,
	DurabilityText							= true,
	DurabilityTooltip						= true
}

--armor items except for shield
Durability.ArmorItems = {
	["HEAD"] = {Name="HEAD", Icon = "/Durability/textures/body_HEAD", Slot = EQUIP_SLOT_HEAD, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["CHEST"] = {Name="CHEST", Icon = "/Durability/textures/body_CHEST", Slot = EQUIP_SLOT_CHEST, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["SHOULDERS"] = {Name="SHOULDERS", Icon = "/Durability/textures/body_SHOULDERS", Slot = EQUIP_SLOT_SHOULDERS, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["HANDS"] = {Name="HANDS", Icon = "/Durability/textures/body_HANDS", Slot = EQUIP_SLOT_HAND, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["WAIST"] = {Name="WAIST", Icon = "/Durability/textures/body_WAIST", Slot = EQUIP_SLOT_WAIST, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["LEGS"] = {Name="LEGS", Icon = "/Durability/textures/body_LEGS", Slot = EQUIP_SLOT_LEGS, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["FEET"] = {Name="FEET", Icon = "/Durability/textures/body_FEET", Slot = EQUIP_SLOT_FEET, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0}
}

Durability.WeaponItems = {
	["MAIN_HAND"] = {Name="MAIN", Icon = "/Durability/textures/body_SHIELD", Slot = EQUIP_SLOT_MAIN_HAND, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["OFF_HAND"] = {Name="OFF", Icon = "/Durability/textures/body_SHIELD", Slot = EQUIP_SLOT_OFF_HAND, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["BACKUP_MAIN"] = {Name="BCK MAIN", Icon = "/Durability/textures/body_SHIELD", Slot = EQUIP_SLOT_BACKUP_MAIN, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0},
	["BACKUP_OFF"] = {Name="BCK OFF", Icon = "/Durability/textures/body_SHIELD", Slot = EQUIP_SLOT_BACKUP_OFF, StatePercent = 100, RepairCost = 0, Charge = 0, ChargeMax=0}
}
-------------------------------------------------------------------------------
function Durability_Initialized( self )
	DurabilityAddon=Durability:New(self)
end
-------------------------------------------------------------------------------
function Durability_SetHideShow()
	DurabilityAddon:ToggleShowBinding()
end
-------------------------------------------------------------------------------
function Durability_SwitchSize()
	DurabilityAddon:SwitchSize()
end
-------------------------------------------------------------------------------
function Durability:SwitchSize()
	if (self.db.DurabilityShow) then
		self.db.DurabilityScale=(self.db.DurabilityScale % 3) + 1
		self:EntryScale()
	end
end
-------------------------------------------------------------------------------
function Durability:New( ... )
		local result = ZO_Object.New( self )
	result:Initialize(...)
		return result
end
-------------------------------------------------------------------------------
function Durability:Initialize( control ) 
	--link addon to the XML top level control
	self.control = control

	--register event to addon
	self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, 						function( ... ) self:OnLoaded( ... )				end )
	self.control:RegisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 	function( ... ) self:OnInventoryUpdate( ... )	end )
	self.control:RegisterForEvent( EVENT_ACTIVE_WEAPON_PAIR_CHANGED, 		function( ... ) self:OnWeaponChange( ... )		end ) 

	--handler
	self.control:SetHandler( 'OnUpdate',				function() self:OnUpdate( )		end )
	self.control:SetHandler( 'OnMoveStop', 			function() self:OnMoveStop( )		end )
	self.control:SetHandler( 'OnMouseEnter',			function()	self:MakeToolTips()	end )
	self.control:SetHandler( 'OnMouseExit',			function()	self:HideToolTips()	end )

	--register callback from config and allocate actions
	CBM:RegisterCallback( Config.EVENT_TOGGLE_TOOLTIP,					function() self:ToggleTooltip()				end )
	CBM:RegisterCallback( Config.EVENT_TOGGLE_SHOW,						function() self:ToggleShow()					end )
	CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOMATIC_HIDDING,	function() self:ToggleAutomaticHidding()	end )
	CBM:RegisterCallback( Config.EVENT_ENTRY_SCALE,						function() self:EntryScale()					end )
	CBM:RegisterCallback( Config.EVENT_CHANGE_ARMOR_COLORS,			function() self:ChangeArmorColors()			end )
	CBM:RegisterCallback( Config.EVENT_CHANGE_WEAPON_COLORS,			function() self:ChangeWeaponColors()		end )
	CBM:RegisterCallback( Config.EVENT_ENTRY_ALPHA,						function() self:ChangeAlpha()					end )
	CBM:RegisterCallback( Config.EVENT_ENTRY_TRESHOLD,					function() self:ChangeTresholds()			end )

end
-------------------------------------------------------------------------------
function Durability:ChangeTresholds()

	--if (not self.db.DurabilityShow) then
	local ShouldBeVisible = false
	if (self.db.DurabilityArmorThreshold) then
		dbgDura('Global Durability: ' .. self.All .. ' / ' .. self.db.DurabilityGlobalArmorThreshold)
		dbgDura('Min Durability: ' .. self.MinArmor .. ' / ' .. self.db.DurabilityMinArmorThreshold )
		ShouldBeVisible=((self.MinArmor <= self.db.DurabilityMinArmorThreshold) or (self.All <= self.db.DurabilityGlobalArmorThreshold))
	end

	dbgDura('ShouldBeVisible: ' .. tostring(ShouldBeVisible))
	dbgDura('self.db.DurabilityWeaponThreshold: ' .. tostring(self.db.DurabilityWeaponThreshold))
	dbgDura(tostring((self.db.DurabilityWeaponThreshold) and (not ShouldBeVisible)))

	if ((self.db.DurabilityWeaponThreshold) and (not ShouldBeVisible)) then
		dbgDura('Min Weapon: ' .. self.MinWeapon .. ' / ' .. self.db.DurabilityMinWeaponThreshold )
		ShouldBeVisible = (self.MinWeapon <= self.db.DurabilityMinWeaponThreshold)
	end

	if ((ShouldBeVisible)and (not self.Alert)) then
		dbgDura ('ShouldBeVisible')
		PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
		PlaySound("Book_Acquired")
	end

	self.Alert=ShouldBeVisible

	self:ToggleShow()
	--end
end
-------------------------------------------------------------------------------
function Durability:ToggleTooltip()
	self.db.DurabilityTooltip=self.db.DurabilityTooltip
end
-------------------------------------------------------------------------------
function Durability:ToggleShow()
	if (self.Alert) then
		self.control:SetHidden(not self.Alert)
	else
		self.control:SetHidden(not self.db.DurabilityShow)
	end
end
-------------------------------------------------------------------------------
function Durability:initAutoHide()
	local AutoHide=(self.db.DurabilityAutomaticHidding)
	--or (not self.db.DurabilityShow))

	local AutoShow = not(self.Alert)
	if (self.Alert) then
		AutoShow = not(self.Alert)
	else
		AutoShow = not(self.db.DurabilityShow)
	end

	if (AutoHide) then
		ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnShow', function()
			self.control:SetHidden(AutoHide)
		end)
		ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnHide', function()
			self.control:SetHidden(AutoShow)
		end)
		ZO_PreHookHandler(ZO_InteractWindow, 'OnShow', function()
			self.control:SetHidden(AutoHide)
		end)
		ZO_PreHookHandler(ZO_InteractWindow, 'OnHide', function()
			self.control:SetHidden(AutoShow)
		end)
		ZO_PreHookHandler(ZO_KeybindStripControl, 'OnShow', function()
			self.control:SetHidden(AutoHide)
		end)
		ZO_PreHookHandler(ZO_KeybindStripControl, 'OnHide', function()
			self.control:SetHidden(AutoShow)
		end)
		ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
			 self.control:SetHidden(AutoHide)
		end)
		ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
			self.control:SetHidden(AutoShow)
		end)
	end
end
-------------------------------------------------------------------------------
function Durability:ToggleAutomaticHidding()
	self:initAutoHide()
	ReloadUI()
end
-------------------------------------------------------------------------------
function Durability:ToggleShowBinding()
	self.db.DurabilityShow = not self.db.DurabilityShow
	self:ToggleShow()
end
-------------------------------------------------------------------------------
function Durability:EntryScale()
	self:Scale()
end
-------------------------------------------------------------------------------
function Durability:ChangeArmorColors()
	----------------------------
	--Update info
	----------------------------
	self:UpdateArmorState()
	self:UpdateWeaponState()
	self:OtherFrameUpdate()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
end
-------------------------------------------------------------------------------
function Durability:ChangeWeaponColors()
	----------------------------
	--Update info
	----------------------------
	self:UpdateArmorState()
	self:UpdateWeaponState()
	self:OtherFrameUpdate()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
end
-------------------------------------------------------------------------------
function Durability:ChangeAlpha()
	self:UpdateArmorState()
	self:UpdateWeaponState()
	self:OtherFrameUpdate()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
	self:MainFrameAlphaUpdate()
end
-------------------------------------------------------------------------------
function Durability:GetControl()
	return self.control
end
-------------------------------------------------------------------------------
function Durability:OnLoaded( event, addon )

	 if ( addon ~= 'Durability' ) then
		 return
	 end

	----------------------------
	--Configuration (save/load)
	----------------------------
	self.db		 = ZO_SavedVars:NewAccountWide( 'Durability_DB', 1.1, nil, Durability_Defaults )
	self.config = Config:New( self.db )

	---------------------------
	--MAIN FRAME INITIALISATION
	----------------------------
	self:MainFrameInit()
	----------------------------
	-- OTHER FRAME INITIALISATION
	self:OtherFrameInit()
	----------------------------
	--Action to refresh with loaded var
	----------------------------
	self:ToggleShow()
	self:initAutoHide()
	----------------------------
	--Update info
	----------------------------
	self:UpdateArmorState()
	self:UpdateWeaponState()
	self:OtherFrameUpdate()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
	self:MainFrameAlphaUpdate()
	--scaling texture frame
	self:Scale()
	self:ChangeTresholds()
	self.Onloaded=true
end
-------------------------------------------------------------------------------
function Durability:OnMoveStop()
	local left, top, right, bottom = self.control:GetScreenRect()
	self.db.DurabilityX=left
	self.db.DurabilityY=top
end
-------------------------------------------------------------------------------
function Durability:MainFrameInit()
	--The Main TopLevelControl
	self.control:ClearAnchors()
	self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.DurabilityX, self.db.DurabilityY)	
	self.control:SetClampedToScreen(true)
	self.control:SetMovable(true)
	self.control:SetMouseEnabled(true)
	self.control:SetDrawLayer(0)
	self.control:SetHidden(false)

	--The Main TopLevelControl Background
	local BG =WINDOW_MANAGER:CreateControl( "DurabilityBG",	self.control, CT_BACKDROP)
	DurabilityBG:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, 0)
	DurabilityBG:SetAnchorFill(self.control)
	DurabilityBG:SetCenterColor( 0,0,0,0.6 )
	DurabilityBG:SetCenterTexture("",8,1,2)
	DurabilityBG:SetEdgeColor( 0,0,0,1 )
	DurabilityBG:SetEdgeTexture("",8,1,2)

	--Global Durability Label
	local DuraAll = WINDOW_MANAGER:CreateControl( "DurabilityALL", self.control, CT_LABEL)
	DurabilityALL:SetAnchor(CENTER, self.control, TOP, 0, 152)
	--DurabilityALL:SetFont("ZoFontWinH5")
	DurabilityALL:SetFont("ZoFontGameShadow")
	DurabilityALL:SetColor( 1,1,1,1 )
	DurabilityALL:SetHorizontalAlignment( CENTER )
	DurabilityALL:SetVerticalAlignment( CENTER )

	--Global Repair Cost Label
	local DuraCOST = WINDOW_MANAGER:CreateControl( "DurabilityCOST", self.control, CT_LABEL)
	--DurabilityCOST:SetFont("ZoFontWinH5")
	DurabilityCOST:SetFont("ZoFontGameShadow")
	DurabilityCOST:SetColor( 1,1,1,1 )
	DurabilityCOST:SetHorizontalAlignment( CENTER )
	DurabilityCOST:SetVerticalAlignment( CENTER )
end
-------------------------------------------------------------------------------
function Durability:MainFrameAlphaUpdate()
	local alpha = (self.db.DurabilityFrameAlpha/100)
	DurabilityBG:SetCenterColor( 0,0,0,alpha)
	if (alpha < 0.1) then
		DurabilityBG:SetEdgeColor( 0,0,0,alpha)
	else
		DurabilityBG:SetEdgeColor( 0,0,0,alpha+(0.02*alpha))
	end
end
-------------------------------------------------------------------------------
function Durability:Scale()

	local MainDimX = 48+28*(self.db.DurabilityScale-1)
	local MainDimY = 180

	local DimX = 32+16*(self.db.DurabilityScale-1)
	local DimY = 64+32*(self.db.DurabilityScale-1)
	local ArmorPosX = 0
	local ArmorPosY = 4+4*(self.db.DurabilityScale-1)

	local WeaponDimX =2+2*(self.db.DurabilityScale-1)

	------------------------------
	--MAIN FRAME
	------------------------------
	if (self.db.DurabilityScale == 1) then
		MainDimY=72
	elseif (self.db.DurabilityScale == 2) then
		DurabilityCOST:ClearAnchors()
		DurabilityCOST:SetAnchor(CENTER, self.control, TOP, 0, 118)
		if (self.db.DurabilityText) then
		MainDimY=130
		else
			MainDimY=110
		end
	else
		DurabilityCOST:ClearAnchors()
		DurabilityCOST:SetAnchor(CENTER, self.control, TOP, 0, 170)
		if (self.db.DurabilityText) then
			MainDimY=180
		else
			MainDimY=150
		end
	end
	self.control:SetDimensions(MainDimX, MainDimY)
	DurabilityCOST:SetHidden((self.db.DurabilityScale < 2) or (not self.db.DurabilityText))
	DurabilityALL:SetHidden((self.db.DurabilityScale < 3) or (not self.db.DurabilityText))
	------------------------------
	--TEXTURES
	------------------------------
	--ARMOR
	Texture_HEAD:ClearAnchors()
	Texture_HEAD:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_HEAD:SetDimensions(DimX, DimY)

	Texture_CHEST:ClearAnchors()
	Texture_CHEST:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_CHEST:SetDimensions(DimX, DimY)

	Texture_LEGS:ClearAnchors()
	Texture_LEGS:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_LEGS:SetDimensions(DimX, DimY)

	Texture_SHOULDERS:ClearAnchors()
	Texture_SHOULDERS:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_SHOULDERS:SetDimensions(DimX, DimY)

	Texture_WAIST:ClearAnchors()
	Texture_WAIST:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_WAIST:SetDimensions(DimX, DimY)

	Texture_HANDS:ClearAnchors()
	Texture_HANDS:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_HANDS:SetDimensions(DimX, DimY)

	Texture_FEET:ClearAnchors()
	Texture_FEET:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_FEET:SetDimensions(DimX, DimY)
	
	--SHIELD (ARMOR & WEAPON)
	Texture_SHIELD:ClearAnchors()
	Texture_SHIELD:SetAnchor(TOP, self.control, TOP, ArmorPosX, ArmorPosY)
	Texture_SHIELD:SetDimensions(DimX, DimY)
	
	--WEAPONS MAIN & OFF
	Texture_WPN_OFF_BG:ClearAnchors()
	Texture_WPN_OFF_BG:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -(WeaponDimX+2), ArmorPosY)
	Texture_WPN_OFF_BG:SetDimensions(WeaponDimX, DimY)

	Texture_WPN_OFF:ClearAnchors()
	Texture_WPN_OFF:SetAnchor(BOTTOMLEFT, Texture_WPN_OFF_BG, BOTTOMLEFT, 0, 0)
	Texture_WPN_OFF:SetDimensions(WeaponDimX, 0)

	Texture_WPN_MAIN_BG:ClearAnchors()
	Texture_WPN_MAIN_BG:SetAnchor(TOPLLEFT, self.control, TOPLLEFT, WeaponDimX+2, ArmorPosY)
	Texture_WPN_MAIN_BG:SetDimensions(WeaponDimX, DimY)

	Texture_WPN_MAIN:ClearAnchors()
	Texture_WPN_MAIN:SetAnchor(BOTTOMLEFT, Texture_WPN_MAIN_BG, BOTTOMLEFT, 0, 0)
	Texture_WPN_MAIN:SetDimensions(WeaponDimX, 0)
end
-------------------------------------------------------------------------------
function Durability:OtherFrameInit()
	--ARMOR
	local TEXTUREHEAD =WINDOW_MANAGER:CreateControl( "Texture_HEAD",	self.control, CT_TEXTURE)
	Texture_HEAD:SetTexture('/Durability/textures/body_HEAD.dds')

	local TEXTURECHEST =WINDOW_MANAGER:CreateControl( "Texture_CHEST",	self.control, CT_TEXTURE)
	Texture_CHEST:SetTexture('/Durability/textures/body_CHEST.dds')
	
	local TEXTURELEGS =WINDOW_MANAGER:CreateControl( "Texture_LEGS",	self.control, CT_TEXTURE)
	Texture_LEGS:SetTexture('/Durability/textures/body_LEGS.dds')
	
	local TEXTURESHOULDERS =WINDOW_MANAGER:CreateControl( "Texture_SHOULDERS",	self.control, CT_TEXTURE)
	Texture_SHOULDERS:SetTexture('/Durability/textures/body_SHOULDERS.dds')
	
	local TEXTUREWAIST =WINDOW_MANAGER:CreateControl( "Texture_WAIST",	self.control, CT_TEXTURE)
	Texture_WAIST:SetTexture('/Durability/textures/body_WAIST.dds')
	
	local TEXTUREHANDS =WINDOW_MANAGER:CreateControl( "Texture_HANDS",	self.control, CT_TEXTURE)
	Texture_HANDS:SetTexture('/Durability/textures/body_HANDS.dds')
	
	local TEXTUREFEET =WINDOW_MANAGER:CreateControl( "Texture_FEET",	self.control, CT_TEXTURE)
	Texture_FEET:SetTexture('/Durability/textures/body_FEET.dds')

	--SHIELD (ARMOR & WEAPON)
	local TEXTURESHIELD =WINDOW_MANAGER:CreateControl( "Texture_SHIELD",	self.control, CT_TEXTURE)
	Texture_SHIELD:SetTexture('/Durability/textures/body_SHIELD.dds')

	--WEAPONS MAIN & OFF
	local TEXTUREWPN_L_BG =WINDOW_MANAGER:CreateControl( "Texture_WPN_MAIN_BG",	self.control, CT_TEXTURE)
	Texture_WPN_MAIN_BG:SetTexture('/Durability/textures/barre.dds')
	local TEXTUREWPNL =WINDOW_MANAGER:CreateControl( "Texture_WPN_MAIN",	Texture_WPN_MAIN_BG, CT_TEXTURE)
	Texture_WPN_MAIN:SetTexture('/Durability/textures/barre.dds')

	local TEXTUREWPN_R_BG =WINDOW_MANAGER:CreateControl( "Texture_WPN_OFF_BG",	self.control, CT_TEXTURE)
	Texture_WPN_OFF_BG:SetTexture('/Durability/textures/barre.dds')
	local TEXTUREWPNR =WINDOW_MANAGER:CreateControl( "Texture_WPN_OFF",	Texture_WPN_OFF_BG, CT_TEXTURE)
	Texture_WPN_OFF:SetTexture('/Durability/textures/barre.dds')

end
-------------------------------------------------------------------------------
function Durability:OtherFrameUpdate()
	local number=self.ArmorItems['HEAD'].StatePercent
	local color=self:GetDurabilityColor(number)
	Texture_HEAD:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['CHEST'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_CHEST:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['LEGS'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_LEGS:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['SHOULDERS'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_SHOULDERS:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['WAIST'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_WAIST:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['HANDS'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_HANDS:SetColor(color:UnpackRGBA())

	number=self.ArmorItems['FEET'].StatePercent
	color=self:GetDurabilityColor(number)
	Texture_FEET:SetColor(color:UnpackRGBA())

	local alpha = (self.db.DurabilityAlpha/100)

	Texture_WPN_MAIN_BG:SetColor(self.db.DurabilityColor_WpnBack["r"],self.db.DurabilityColor_WpnBack["g"],self.db.DurabilityColor_WpnBack["b"],alpha)
	Texture_WPN_MAIN:SetColor(self.db.DurabilityColor_WpnFront["r"],self.db.DurabilityColor_WpnFront["g"],self.db.DurabilityColor_WpnFront["b"],alpha)

	Texture_WPN_OFF_BG:SetColor(self.db.DurabilityColor_WpnBack["r"],self.db.DurabilityColor_WpnBack["g"],self.db.DurabilityColor_WpnBack["b"],alpha)
	Texture_WPN_OFF:SetColor(self.db.DurabilityColor_WpnFront["r"],self.db.DurabilityColor_WpnFront["g"],self.db.DurabilityColor_WpnFront["b"],alpha)
end
-------------------------------------------------------------------------------
function Durability:WeaponsFrameUpdate()
	local sWeaponItemOFF="OFF_HAND"
	local sWeaponItemMAIN="MAIN_HAND"
	
	local activeWeaponPair, locked = GetActiveWeaponPairInfo()
	if (activeWeaponPair==ACTIVE_WEAPON_PAIR_BACKUP) then
		sWeaponItemOFF="BACKUP_OFF"
		sWeaponItemMAIN="BACKUP_MAIN"
	end

--SHIELD
	local HasArmor=DoesItemHaveDurability(BAG_WORN, self.WeaponItems[sWeaponItemOFF].Slot)
	if (HasArmor) then
		local number=self.WeaponItems[sWeaponItemOFF].StatePercent
		local ShieldColor=self:GetDurabilityColor(number)
		Texture_SHIELD:SetColor(ShieldColor:UnpackRGBA())
	end
	Texture_SHIELD:SetHidden(not HasArmor)

--OFF HAND

	if( not HasArmor) then
		local dimRx, dimRy =Texture_WPN_OFF:GetDimensions()
		local dimRxBG, dimRyBG =Texture_WPN_OFF_BG:GetDimensions()

		local Charge=self.WeaponItems[sWeaponItemOFF].Charge
		local ChargeMax=self.WeaponItems[sWeaponItemOFF].ChargeMax

		if (ChargeMax>0) then
			dimRy = math.floor((Charge/ChargeMax)*dimRyBG)
		else
			dimRy = 0
		end

		Texture_WPN_OFF:SetDimensions(dimRx, dimRy)
	end

	--TWO HAND ?
	local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(BAG_WORN, self.WeaponItems[sWeaponItemMAIN].Slot)
	local Twohand=(equipType==EQUIP_TYPE_TWO_HAND)
	Texture_WPN_OFF:SetHidden(HasArmor or Twohand)
	Texture_WPN_OFF_BG:SetHidden(HasArmor or Twohand)

	--MAIN HAND
	local dimRx, dimRy =Texture_WPN_MAIN:GetDimensions()
	local dimRxBG, dimRyBG =Texture_WPN_MAIN_BG:GetDimensions()

	local Charge=self.WeaponItems[sWeaponItemMAIN].Charge
	local ChargeMax=self.WeaponItems[sWeaponItemMAIN].ChargeMax

	if (0 < ChargeMax) then
		dimRy = math.floor((Charge/ChargeMax)*dimRyBG)
	else
		dimRy = 0
	end

	Texture_WPN_MAIN:SetDimensions(dimRx, dimRy)
end
-------------------------------------------------------------------------------
function Durability:TextFrameUpdate()
	local color = self:GetDurabilityColor(self.All)
	DurabilityALL:SetColor(color:UnpackRGBA())
		
	local alpha = (self.db.DurabilityAlpha/100)
	DurabilityCOST:SetColor( 1, 1, 1, alpha )

	DurabilityALL:SetText ( "Global : " .. self.All .. "%")
	DurabilityCOST:SetText ( "Cost: " .. self.RepairAllCost)
end
-------------------------------------------------------------------------------
function Durability:OnInventoryUpdate( eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason )
	if (not self.Onloaded) then return; end

	--if ((updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) and (bagId == BAG_WORN)) then
	if (bagId == BAG_WORN) then
		self:UpdateArmorState()
		self:UpdateWeaponState()
		self:ChangeTresholds()
		self:TextFrameUpdate()
		self:OtherFrameUpdate()
		self:WeaponsFrameUpdate()
	end
end
-------------------------------------------------------------------------------
function Durability:OnWeaponChange(activeWeaponPair, locked)
	if (not self.Onloaded) then return; end
	self:UpdateWeaponState()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
	self:ChangeTresholds()
end
-------------------------------------------------------------------------------
function Durability:OnUpdate()
	if ((not BufferReached("Durability:OnUpdate", 1)) or (not self.Onloaded)) then return; end
	self:UpdateArmorState()
	self:UpdateWeaponState()
	self:OtherFrameUpdate()
	self:WeaponsFrameUpdate()
	self:TextFrameUpdate()
	self:ChangeTresholds()
end
-------------------------------------------------------------------------------
-- white/grey - 90 - 100% durability or item is not equiped
-- Green - 60 - 89% durability
-- Yellow - 30 - 59% durability
-- Orange - 1 - 29% durability
-- Red - 0% no armor
function Durability:GetDurabilityColor(number)

	local alpha=(self.db.DurabilityAlpha/100)
	--red
	if (number == 0) then
		return ZO_ColorDef:New(self.db.DurabilityColor_NoArmor["r"],self.db.DurabilityColor_NoArmor["g"],self.db.DurabilityColor_NoArmor["b"],alpha)
	end
	--orange
	if ((number > 0) and (number < 30)) then
		return ZO_ColorDef:New(self.db.DurabilityColor_UpToStep1["r"],self.db.DurabilityColor_UpToStep1["g"],self.db.DurabilityColor_UpToStep1["b"],alpha)
	end
	--yellow
	if ((number >= 30) and (number < 60)) then
		return ZO_ColorDef:New(self.db.DurabilityColor_UpToStep2["r"],self.db.DurabilityColor_UpToStep2["g"],self.db.DurabilityColor_UpToStep2["b"],alpha)
	end
	--green
	if ((number >= 60) and (number < 90)) then
		return ZO_ColorDef:New(self.db.DurabilityColor_UpToStep3["r"],self.db.DurabilityColor_UpToStep3["g"],self.db.DurabilityColor_UpToStep3["b"],alpha)
	end
	--white/grey
	return ZO_ColorDef:New(self.db.DurabilityColor_FullArmor["r"],self.db.DurabilityColor_FullArmor["g"],self.db.DurabilityColor_FullArmor["b"],alpha)
end
-------------------------------------------------------------------------------
function Durability:UpdateArmorState()
	local DurabilitySumm = 0
	self.ArmorCount = 0
	self.RepairAllCost = 0
	self.MinArmor = 100

	for k,v in pairs(self.ArmorItems) do
		self.ArmorCount = self.ArmorCount + 1
		v.StatePercent = GetItemCondition(BAG_WORN, v.Slot)
		if (self.MinArmor > v.StatePercent) then
			self.MinArmor = v.StatePercent
		end
		DurabilitySumm = DurabilitySumm+v.StatePercent
		v.StatePercent=math.floor(v.StatePercent)
		v.RepairCost=GetItemRepairCost(BAG_WORN, v.Slot)
		self.RepairAllCost = self.RepairAllCost + v.RepairCost
		v.Charge, v.ChargeMax=GetChargeInfoForItem(BAG_WORN, v.Slot)
	end

	--SHIELD
	for k,v in pairs(self.WeaponItems) do
		if (DoesItemHaveDurability(BAG_WORN, v.Slot)) then
			v.StatePercent = GetItemCondition(BAG_WORN, v.Slot)
			if (self.MinArmor > v.StatePercent) then
				self.MinArmor = v.StatePercent
			end
			DurabilitySumm = DurabilitySumm+v.StatePercent
			v.RepairCost=GetItemRepairCost(BAG_WORN, v.Slot)
			self.RepairAllCost = self.RepairAllCost + v.RepairCost
			self.ArmorCount = self.ArmorCount + 1
		end
	end

	if( self.ArmorCount ~= 0 ) then
		self.All=math.floor(DurabilitySumm/self.ArmorCount)
	else
		self.All=100
	end	
end
-------------------------------------------------------------------------------
--Todo after UpdateArmorState()
function Durability:UpdateWeaponState()

	--weapon charge tresholds
	self.MinWeapon=100

	local sWeaponItemOFF=EQUIP_SLOT_OFF_HAND
	local sWeaponItemMAIN=EQUIP_SLOT_MAIN_HAND

	local activeWeaponPair, locked = GetActiveWeaponPairInfo()
	if (activeWeaponPair==ACTIVE_WEAPON_PAIR_BACKUP) then
		sWeaponItemOFF=EQUIP_SLOT_BACKUP_OFF
		sWeaponItemMAIN=EQUIP_SLOT_BACKUP_MAIN
	end

	--MAIN Charge Alert
	local chargepercent = 0
	local Charge, ChargeMax = GetChargeInfoForItem(BAG_WORN, sWeaponItemMAIN)
	local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(BAG_WORN, sWeaponItemMAIN)
	local Twohand = (equipType==EQUIP_TYPE_TWO_HAND)
	if (ChargeMax>0) then
		chargepercent = math.floor((Charge/ChargeMax)*100)
	end
	if (self.MinWeapon > chargepercent) then
		self.MinWeapon = chargepercent
	end
	
	--OFF Charge alert
	if (not Twohand) then
		chargepercent=0
		--SHIELD
		if (DoesItemHaveDurability(BAG_WORN, sWeaponItemOFF)) then chargepercent=100 end
		Charge, ChargeMax = GetChargeInfoForItem(BAG_WORN, sWeaponItemOFF)
		if (ChargeMax>0) then
			chargepercent = math.floor((Charge/ChargeMax)*100)
		end
		if (self.MinWeapon > chargepercent) then
			self.MinWeapon = chargepercent
		end
	 end

	--All weapons Charge
	for k,v in pairs(self.WeaponItems) do
		v.Charge, v.ChargeMax=GetChargeInfoForItem(BAG_WORN, v.Slot)

		--shield
		if (DoesItemHaveDurability(BAG_WORN, v.Slot)) then
			v.StatePercent = GetItemCondition(BAG_WORN, v.Slot)
			if (self.MinArmor > v.StatePercent) then
				self.MinArmor = v.StatePercent
			end
			v.RepairCost=GetItemRepairCost(BAG_WORN, v.Slot)
		else
			v.StatePercent=100
			v.RepairCost=0
		end
	end
end
-------------------------------------------------------------------------------
function Durability:DebugPrint()
	dbgDura('-----Durability-----')
	for k,v in pairs(self.ArmorItems) do
		d(v.Name .. ": " .. v.StatePercent .. " - cost: " .. v.RepairCost .. " - charge: " .. v.Charge .. "/" .. v.ChargeMax)
	end
	
	for k,v in pairs(self.WeaponItems) do
		d(v.Name .. ": " .. v.StatePercent .. " - cost: " .. v.RepairCost .. " - charge: " .. v.Charge .. "/" .. v.ChargeMax)
	end

	dbgDura('Global durability: ' .. self.All)
	dbgDura('Total repair cost: ' .. self.RepairAllCost)
	dbgDura('--------------')
end
--------------------------------------------------------------------------------------------------------------
function Durability:MakeToolTips()
	if (not self.db.DurabilityTooltip) then
		return
	end

	local text =""
	local temp=""
	local color
	
	for k,v in pairs(self.ArmorItems) do
		temp="" .. v.StatePercent .. "%"
		color=self:GetDurabilityColor(v.StatePercent)
		temp = color:Colorize( temp )
		text=text .. "|cFF9600" .. v.Name .. ": |r" .. temp .. " - cost: " .. v.RepairCost
		if (v.ChargeMax>0) then
			text=text .. " - charge: " ..	v.Charge	..	"/"	 ..	v.ChargeMax
		end
		text=text .. "\n"
	end
	text=text .. "\n"
	for k,v in pairs(self.WeaponItems) do
		text=text .. "|cFF9600" .. v.Name .. ": |r"
		if (DoesItemHaveDurability(BAG_WORN, v.Slot)) then
			temp="" .. v.StatePercent .. "%"
			color=self:GetDurabilityColor(v.StatePercent)
			temp = color:Colorize( temp )
			text=text .. temp .. " - cost: " .. v.RepairCost
		else
			text=text .. "na"
		end
		text=text .. " - charge: " .. v.Charge .. "/" .. v.ChargeMax .. "\n"
	end
	text=text .. "\n"
	
	temp ="Global durability: " .. self.All .. "%\n"
	color=self:GetDurabilityColor(self.All)
	temp = color:Colorize( temp )
	text=text .. temp
	text=text .. 'Total repair cost: ' .. self.RepairAllCost
	
	ZO_Tooltips_ShowTextTooltip(self.control, TOP, text)
end
--------------------------------------------------------------------------------------------------------------
function Durability:HideToolTips()
	ZO_Tooltips_HideTextTooltip()
end
--------------------------------------------------------------------------------------------------------------
--TOOLS
--------------------------------------------------------------------------------------------------------------
--taken from http://wiki.esoui.com/Event_%26_Update_Buffering
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
--------------------------------------------------------------------------------------------------------------
local OkdebugDura=false
function dbgDura(...)
	if (OkdebugDura) then
		d('[' .. GetTimeString() .. ']: ' .. tostring(...))
	end
end
--------------------------------------------------------------------------------------------------------------