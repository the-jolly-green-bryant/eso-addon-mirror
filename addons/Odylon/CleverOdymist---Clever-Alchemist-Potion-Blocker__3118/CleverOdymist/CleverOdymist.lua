local LAM        = LibAddonMenu2
local ADDON_NAME = "CleverOdymist"
local CLEVER_ALC = "|H1:item:140067:370:50:45883:370:50:0:0:0:0:0:0:0:0:1:0:1:1:0:0:0|h|h"
local PROC_ID    = 75746
local PROC_DUR   = 20
local PROC_END   = 0
local DEFAULTS   = {
	blockOOC = true,
	useUI    = true,
}
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
	local store = ZO_SavedVars:New( "CLEOStore", 1, nil, DEFAULTS )
	-- block potion consumption
	ZO_PreHook( "ZO_ActionBar_CanUseActionSlots", function()
		local slotNum = tonumber( debug.traceback():match( "keybind = \"ACTION_BUTTON_(%d)" ) )
		if slotNum == 9 then
			local _, _, _, num = GetItemLinkSetInfo( CLEVER_ALC, true )
			local isInCombat   = not store.blockOOC or IsUnitInCombat( "player" )
			if num >= 3 and ( num < 5 or not isInCombat ) then
				local slotId   = GetCurrentQuickslot()
				local itemLink = GetSlotItemLink( slotId )
				local itemType = GetItemLinkItemType( itemLink )
				if itemType == ITEMTYPE_POTION then	
					return true
				end
			end
		end
		return false
	end )
	-- capture proc event
	EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_COMBAT_EVENT, function()
		PROC_END = GetGameTimeMilliseconds() + PROC_DUR * 1000
	end )
	EVENT_MANAGER:AddFilterForEvent( ADDON_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, PROC_ID )
	EVENT_MANAGER:AddFilterForEvent( ADDON_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER )
	EVENT_MANAGER:AddFilterForEvent( ADDON_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED )
	-- custom ui
	if store.useUI then
		-- customize quickslot button
		local qs      = ActionButton9
		local ct      = qs:GetNamedChild( "CountText" )
		local qsBack  = qs:CreateControl( "QSBack", CT_TEXTURE )
		local qsTimer = qs:CreateControl( "QSTimer", CT_LABEL )
		local qsCount = qs:CreateControl( "QSCount", CT_LABEL )
		qs:GetNamedChild( "Cooldown" ):SetDrawTier( DT_MEDIUM )
		ct:SetAlpha( 0 )
		qsBack:SetAnchorFill( qs )
		qsBack:SetTexture( "cleverodymist/overlay.dds" )
		qsBack:SetAlpha( alphaDefault )
		qsBack:SetDrawTier( DT_HIGH )
		qsBack:SetHidden( true )
		qsTimer:SetAnchorFill( qs )
		qsTimer:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		qsTimer:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		qsTimer:SetFont( "$(BOLD_FONT)|$(KB_18)|outline" )
		qsTimer:SetDrawTier( DT_HIGH )
		qsCount:SetAnchor( TOPRIGHT, qs, TOPRIGHT, -5, 0 )
		qsCount:SetFont( "$(BOLD_FONT)|$(KB_14)|outline" )
		qsCount:SetDrawTier( DT_HIGH )
		EVENT_MANAGER:RegisterForUpdate( ADDON_NAME, 100, function()
			local _, _, _, num = GetItemLinkSetInfo( CLEVER_ALC, true )
			local slotId       = GetCurrentQuickslot()
			local cd, _, glob  = GetSlotCooldownInfo( slotId )
			local cooldown     = glob and 0 or cd
			local itemLink     = GetSlotItemLink( slotId )
			local itemType     = GetItemLinkItemType( itemLink )
			-- handle clever alchemist
			if GetGameTimeMilliseconds() < PROC_END and itemType == ITEMTYPE_POTION then
				qsBack:SetColor( 1, 0, 1, 1 )
				qsBack:SetHidden( false )
			elseif num == 5 and cooldown == 0 and itemType == ITEMTYPE_POTION and IsUnitInCombat( "player" ) then
				qsBack:SetColor( 0, 1, 0, 1 )
				qsBack:SetHidden( false )
			else
				qsBack:SetHidden( true )
			end
			-- update quickslot cooldown and remaining items
			qsTimer:SetText( cooldown > 0 and string.format( "%0.1f", cooldown / 1000 ) or "" )
			qsCount:SetHidden( ct:IsHidden() )
			qsCount:SetText( ct:GetText() )
		end )
		-- lighter color for disabled quickslot
		local disabledColLight  = ZO_ColorDef:New( 0.5, 0.5, 0.5 )
		local qsIconControl     = qs:GetNamedChild( "Icon" )
		local setUnusableBackup = ZO_ActionSlot_SetUnusable
		function ZO_ActionSlot_SetUnusable( iconControl, unusable, useDesaturation )
			local disabledColBackup   = ZO_DEFAULT_DISABLED_COLOR
			ZO_DEFAULT_DISABLED_COLOR = iconControl ~= qsIconControl and disabledColBackup or disabledColLight
			setUnusableBackup( iconControl, unusable, useDesaturation )
			ZO_DEFAULT_DISABLED_COLOR = disabledColBackup
		end
	end
	-- create addon options
	local panel = {
		type				= "panel",
		name				= ADDON_NAME,
		displayName			= ADDON_NAME,
		author				= "|cff8534@Lamierina7|r",
		version				= "|c00ff001.0.1|r",
		slashCommand		= "/cleo",
		registerForRefresh	= true,
		registerForDefaults = true,
    }
	local options = {
		{
			type = "description",
            text = "This tiny addon blocks potion consumption when you are wearing Clever Alchemist and are on a bar without the 5pc set bonus. Optionally you can choose to block potion consumption out of combat and/or to use a custom overlay for the quickslot button which highlights |c00ff00perfect proc conditions|r/|cff00ffactive proc|r. You can use the |cffff00/cleo|r shortcut to open the addon settings.",
		},
        {
            type    = "checkbox",
            name    = "Block while out of combat",
            default = DEFAULTS.blockOOC,
            getFunc = function() return store.blockOOC end,
            setFunc = function( newValue ) store.blockOOC = newValue end,
        },
        {
            type     	   = "checkbox",
            name     	   = "Use custom overlay for quickslot",
            default  	   = DEFAULTS.useUI,
            getFunc  	   = function() return store.useUI end,
            setFunc  	   = function( newValue ) store.useUI = newValue end,
			requiresReload = true,
        },
	}
	LAM:RegisterAddonPanel( ADDON_NAME, panel )
	LAM:RegisterOptionControls( ADDON_NAME, options )
end )
