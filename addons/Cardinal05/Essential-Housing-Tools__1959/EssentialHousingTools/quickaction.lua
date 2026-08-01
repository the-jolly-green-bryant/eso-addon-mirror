if not EHT then EHT = { } end
if not EHT.UI then EHT.UI = { } end

---[ Quick Action Menu ]---

local QuickActionMenu = ZO_InteractiveRadialMenuController:Subclass()

local EMPTY_QUICKSLOT_TEXTURE = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds"
local EMPTY_QUICKSLOT_STRING = GetString( SI_QUICKSLOTS_EMPTY )

local function IsItemSelected()
	return ( EHT.QuickActionMenu.Furniture.Id or 0 ) ~= 0
end

local function OnQuickActionSelected( state )
	local self = EHT.QuickActionMenu

	if IsItemSelected() then
		if state and state.selectedEntry and state.selectedEntry.data then
			local data = state.selectedEntry.data
			EHT.UI.InitChooseAnItem()

			if data.name == "Edit Item" then
				local f = self.Furniture
				if f and f.Id then
					EHT.UI.ShowPositionDialog( f.Id )
					EHT.QuickActionMenu:ResetTarget()
				end
			elseif data.name == "Select Item" or data.name == "Deselect Item" or data.name == "Select / Deselect Item" then
				local f = self.Furniture
				if f and f.Id then
					if not EHT.Data.GetGroupFurniture( f.Id ) then
						EHT.Data.AddGroupFurniture( f.Id )
						EHT.UI.DisplayNotification( "Selected." )
					else
						EHT.Data.RemoveGroupFurniture( f.Id )
						EHT.UI.DisplayNotification( "Deselected." )
					end
					EHT.UI.ShowToolDialog()
					EHT.QuickActionMenu:ResetTarget()
				end
			elseif data.name == "Select Radius" or data.name == "Deselect Radius" or data.name == "Select / Deselect Radius" then
				local f = self.Furniture
				if f and f.Id then
					if not EHT.Data.GetGroupFurniture( f.Id ) then
						EHT.Biz.BeginRadiusSelection( f.Id, true, false, true )
					else
						EHT.Biz.BeginRadiusSelection( f.Id, false, false, true )
					end
					EHT.QuickActionMenu:ResetTarget()
				end
			elseif data.name == "Snap Together" then
				local f = self.Furniture
				if f then
					local fId, fX, fY, fZ, fPitch, fYaw, fRoll = f.Id, f.X, f.Y, f.Z, f.Pitch, f.Yaw, f.Roll
					zo_callLater( function()
						EHT.UI.SnapFurniture( fId, fX, fY, fZ, fPitch, fYaw, fRoll )
					end, 200 )
				end
				EHT.QuickActionMenu:ResetTarget( false )
			elseif data.name == "Level With" then
				EHT.UI.ChooseAnItem( function( id )
					EHT.Biz.ArrangeLevelEachWithTarget( id )
					EHT.QuickActionMenu:ResetTarget()
					EHT.UI.DisplayNotification( "Leveled." )
				end, nil, nil, nil, "Click the item to LEVEL with" )
			elseif data.name == "Straighten" then
				EHT.Biz.ArrangeStraightenItem( function()
					EHT.QuickActionMenu:ResetTarget()
					EHT.UI.DisplayNotification( "Straightened." )
				end )
			elseif data.name == "Align With" then
				EHT.UI.ChooseAnItem( function( id )
					EHT.Biz.AlignWithItem( id )
					EHT.QuickActionMenu:ResetTarget()
					EHT.UI.DisplayNotification( "Aligned." )
				end, nil, nil, nil, "Click the item to ALIGN with" )
			elseif data.name == "Orient With" then
				EHT.UI.ChooseAnItem( function( id )
					EHT.Biz.OrientWithItem( id )
					EHT.QuickActionMenu:ResetTarget()
					EHT.UI.DisplayNotification( "Oriented." )
				end, nil, nil, nil, "Click the item to ORIENT with" )
			elseif data.name == "Center On" then
				EHT.UI.ChooseAnItem( function( id )
					EHT.Biz.CenterOnItem( id )
					EHT.QuickActionMenu:ResetTarget()
					EHT.UI.DisplayNotification( "Centered." )
				end, nil, nil, nil, "Click the item to CENTER ON" )
			elseif data.name == "Center Between" then
				--EHT.UI.ChooseAnItem( function( furnitureId1 ) EHT.UI.ChooseAnItem( EHT.Biz.ArrangeCenterBetweenTargets, furnitureId1, nil, nil, "Select 2nd item" ) end, nil, nil, nil, "Select 1st item" )
				EHT.UI.ChooseAnItem( function( id1 )
					EHT.UI.ChooseAnItem( function( id2 )
						if id1 and id2 and id1 ~= id2 then
							EHT.Biz.CenterBetweenItems( id1, id2 )
							EHT.UI.DisplayNotification( "Centered." )
						end

						EHT.QuickActionMenu:ResetTarget()
					end, nil, nil, nil, "Click SECOND item to CENTER BETWEEN" )
				end, nil, nil, nil, "Click FIRST item to CENTER BETWEEN" )
			else
				self:ResetTarget()
			end
		else
			self:ResetTarget()
		end
	else
		self:ResetTarget()
	end
end

function QuickActionMenu:New( ... )
    return ZO_InteractiveRadialMenuController.New( self, ... )
end

function QuickActionMenu:Initialize( control, entryTemplate, animationTemplate, entryAnimationTemplate )
    ZO_InteractiveRadialMenuController.Initialize( self, control, entryTemplate, animationTemplate, entryAnimationTemplate )
end

function QuickActionMenu:PrepareForInteraction()
    return true
end

function QuickActionMenu:PopulateMenu()
	local id = QuickActionMenu:GetSelectedFurnitureId()

	self.menu:AddEntry( "Snap Together", EHT.Textures.ICON_QAM_SNAP, EHT.Textures.ICON_QAM_SNAP, OnQuickActionSelected, { name = "Snap Together" } )
	self.menu:AddEntry( "Align With", EHT.Textures.ICON_QAM_ALIGN, EHT.Textures.ICON_QAM_ALIGN, OnQuickActionSelected, { name = "Align With" } )
	self.menu:AddEntry( "Level With", EHT.Textures.ICON_QAM_LEVEL, EHT.Textures.ICON_QAM_LEVEL, OnQuickActionSelected, { name = "Level With" } )
	self.menu:AddEntry( "Orient With", EHT.Textures.ICON_QAM_ORIENT, EHT.Textures.ICON_QAM_ORIENT, OnQuickActionSelected, { name = "Orient With" } )
	self.menu:AddEntry( "Straighten", EHT.Textures.ICON_QAM_STRAIGHTEN, EHT.Textures.ICON_QAM_STRAIGHTEN, OnQuickActionSelected, { name = "Straighten" } )
	self.menu:AddEntry( "Center Between", EHT.Textures.ICON_QAM_CENTER_BETWEEN, EHT.Textures.ICON_QAM_CENTER_BETWEEN, OnQuickActionSelected, { name = "Center Between" } )
	self.menu:AddEntry( "Center On", EHT.Textures.ICON_QAM_CENTER_ON, EHT.Textures.ICON_QAM_CENTER_ON, OnQuickActionSelected, { name = "Center On" } )
	self.menu:AddEntry( "Edit Item", EHT.Textures.ICON_QAM_EDIT, EHT.Textures.ICON_QAM_EDIT, OnQuickActionSelected, { name = "Edit Item" } )

	if id and EHT.Data.GetGroupFurniture( id ) then
		self.menu:AddEntry( "Deselect Radius", EHT.Textures.ICON_QAM_DESELECT_RADIUS, EHT.Textures.ICON_QAM_DESELECT_RADIUS, OnQuickActionSelected, { name = "Deselect Radius" } )
	else
		self.menu:AddEntry( "Select Radius", EHT.Textures.ICON_QAM_SELECT_RADIUS, EHT.Textures.ICON_QAM_SELECT_RADIUS, OnQuickActionSelected, { name = "Select Radius" } )
	end

	if id and EHT.Data.GetGroupFurniture( id ) then
		self.menu:AddEntry( "Deselect Item", EHT.Textures.ICON_QAM_DESELECT, EHT.Textures.ICON_QAM_DESELECT, OnQuickActionSelected, { name = "Deselect Item" } )
	else
		self.menu:AddEntry( "Select Item", EHT.Textures.ICON_QAM_SELECT, EHT.Textures.ICON_QAM_SELECT, OnQuickActionSelected, { name = "Select Item" } )
	end

	self.menu:AddEntry( "Cancel", EHT.Textures.ICON_QAM_CANCEL, EHT.Textures.ICON_QAM_CANCEL, OnQuickActionSelected, { name = "Cancel" } )
end

function QuickActionMenu:OnShowMenu()
	if EHT.Biz.IsRadiusSelecting() then
		EHT.Biz.EndRadiusSelection()
		return false
	end

	local furnitureId = HousingEditorGetSelectedFurnitureId()

	if not self.Furniture then
		self.Furniture = { }
	end

	local f = self.Furniture

	LockCameraRotation( true )

	if furnitureId and 0 ~= furnitureId and EHT.Housing.IsPlacementMode() then
		f.Id = furnitureId
		f.X, f.Y, f.Z = EHT.Housing.GetFurniturePosition( furnitureId )
		f.Pitch, f.Yaw, f.Roll = EHT.Housing.GetFurnitureOrientation( furnitureId )

		HousingEditorRequestSelectedPlacement()
	else
		if not EHT.Housing.IsSelectionMode() then
			HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
		end

		local effect = EHT.World:GetReticleTargetEffect()

		if effect then
			furnitureId = effect:GetRecordId()
		end

		if 0 == ( furnitureId or 0 ) then
			HousingEditorSelectTargettedFurniture()
			furnitureId = HousingEditorGetSelectedFurnitureId()

			if 0 == ( furnitureId or 0 ) then
				self:ResetTarget()
				LockCameraRotation( false )
				EHT.UI.DisplayNotification( "Please point at (target) the item to organize." )

				return
			end
		end

		f.Id = furnitureId
		f.X, f.Y, f.Z = EHT.Housing.GetFurniturePosition( furnitureId )
		f.Pitch, f.Yaw, f.Roll = EHT.Housing.GetFurnitureOrientation( furnitureId )
	end

	HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )

	LockCameraRotation( false )

	self.IsShowing = true
	self:PopulateMenu()
	self:StartInteraction()
	EHT.QuickActionMenu.menuLabel:SetHidden( false )
end

function QuickActionMenu:OnReleaseMenu()
	local furnitureId = HousingEditorGetSelectedFurnitureId()
	local f = self.Furniture

	if not f.Id and EHT.Housing.IsPlacementMode() then
		f.Id = furnitureId
		f.X, f.Y, f.Z, f.Pitch, f.Yaw, f.Roll = EHT.Housing.GetFurniturePositionAndOrientation( furnitureId )

		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
		EHT.Housing.SetFurniturePositionAndOrientation( f.Id, f.X, f.Y, f.Z, f.Pitch, f.Yaw, f.Roll )
	end

	self:StopInteraction()
end

function QuickActionMenu:ResetTarget( resetMode )
	self.resetMode = resetMode ~= false

	if false ~= resetMode and not EHT.Housing.IsSelectionMode() then
		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
	end

	if not self.Furniture then
		self.Furniture = { }
	else
		for k in pairs( self.Furniture ) do
			self.Furniture[k] = nil
		end
	end
end

function QuickActionMenu:StopInteraction( ... )
	self.IsShowing = false
	EHT.QuickActionMenu.menuLabel:SetHidden( true )
	ZO_InteractiveRadialMenuController.StopInteraction( self, ... )

	if self.resetMode then
		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
	end
end

function QuickActionMenu:IsHidden()
	return not self.IsShowing
end

function QuickActionMenu:SetupEntryControl( entryControl, data )
	if data then
		entryControl.label:SetText( data.name )
		entryControl.icon:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )

        if data.selected then
            if entryControl.glow then
                 entryControl.glow:SetAlpha( 1 )
            end

            entryControl.animation:GetLastAnimation():SetAnimatedControl( nil )
        else
            if entryControl.glow then
                 entryControl.glow:SetAlpha( 0 )
            end

            entryControl.animation:GetLastAnimation():SetAnimatedControl( entryControl.glow )
		end

		if IsInGamepadPreferredMode() then
			entryControl.label:SetFont( "ZoFontGamepad54" )
		else
			entryControl.label:SetFont( "ZoInteractionPrompt" )
		end
	end
end

function QuickActionMenu:OnSelectionChangedCallback( entry )
	-- No Op
end

function QuickActionMenu:GetSelectedFurnitureId()
	local f = EHT.QuickActionMenu.Furniture
	if f then
		return f.Id
	end
end

function QuickActionMenu:GetSelectedFurniture()
	local f = EHT.QuickActionMenu.Furniture
	if f then
		return f.Id, f.X, f.Y, f.Z, f.Pitch, f.Yaw, f.Roll
	end
end

function EHT.QuickActionMenuEntryTemplate_OnInitialized( self )
    self.label = self:GetNamedChild( "Label" )
    ZO_SelectableItemRadialMenuEntryTemplate_OnInitialized( self )
end

function EHT.QuickActionMenu_Initialize( control )
    EHT.QuickActionMenu = QuickActionMenu:New( control, "EHTQuickActionMenuEntryTemplate", nil, "SelectableItemRadialMenuEntryAnimation" )
	EHT.QuickActionMenu.menuLabel = control:GetNamedChild( "MenuLabel" )

	if IsInGamepadPreferredMode() then
		EHT.QuickActionMenu.menuLabel:SetFont( "ZoFontGamepadBold61" )
	else
		EHT.QuickActionMenu.menuLabel:SetFont( "ZoFontCallout3" )
	end
end


EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.QuickAction = true