OSI = OSI or {}
local OSI = OSI

OSI.name 		= "OdySupportIcons"
OSI.version 	= "|c00ff001.13.3|r"
OSI.author 		= "|cff8534@Lamierina7|r & |c00FF00@ExoY94|r"
OSI.show        = true
OSI.debug       = false
OSI.player      = string.lower( GetDisplayName() )
OSI.events		= GetEventManager()
OSI.window 		= GetWindowManager()

-- DEPRECATED
-- icon size
OSI.store = {
    iconsize = 1
}

-- icon roles
OSI.ROLE_DEAD   = 100 -- dead player
OSI.ROLE_LEAD   = 1   -- group leader
OSI.ROLE_TANK   = 2   -- tank
OSI.ROLE_HEAL   = 4   -- healer
OSI.ROLE_DPS    = 3   -- damage dealer
OSI.ROLE_BG     = 5   -- battleground group member

-- not used atm, maybe use it for group member companions later...
-- OSI.ALLY_COMPANION = 50

-- ally types
OSI.ALLY_BANKER    = 51
OSI.ALLY_VENDOR    = 52
OSI.ALLY_FENCE     = 53
OSI.ALLY_ARMORY    = 54
OSI.ALLY_DECON     = 55
OSI.ALLY_BASTIAN   = 60
OSI.ALLY_MIRRI     = 61
OSI.ALLY_EMBER     = 62
OSI.ALLY_ISOBEL    = 63
OSI.ALLY_SHARP     = 64
OSI.ALLY_AZANDAR   = 65
OSI.ALLY_TANLORIN  = 66 -- 12172, 12235
OSI.ALLY_ZERITHVAR = 67 -- 12173, 12236


-- default color
OSI.BASECOLOR = { 1, 1, 1 }

-- player status icons
OSI.STATUS = {
    [PLAYER_STATUS_ONLINE]          = "odysupporticons/icons/status/status-on.dds",
    [PLAYER_STATUS_AWAY]            = "odysupporticons/icons/status/status-afk.dds",
    [PLAYER_STATUS_DO_NOT_DISTURB]  = "odysupporticons/icons/status/status-dnd.dds",
    [PLAYER_STATUS_OFFLINE]         = "odysupporticons/icons/status/status-off.dds",
}

-- iconpicker data
OSI.custom      = {
    displayName = nil,
    color       = OSI.BASECOLOR,
    texture     = nil,
    raidlead    = false,
}

-- libraries
local LAM = LibAddonMenu2
local LCI = LibCustomIcons

--[[
/script d( GetActiveCollectibleByType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER ) )
function OSI.FindAssitentIds()
    for i = 1, GetTotalCollectiblesByCategoryType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT ) do
        local id = GetCollectibleIdFromType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, i )
        d( "-> " .. GetCollectibleName( id ) .. " " .. id )
    end
end
]]

-- allies by collectible id
local ALLIES = {
    [267]   = OSI.ALLY_BANKER,  -- tythis andromo, the banker
    [300]   = OSI.ALLY_FENCE,   -- pirharri the smuggler
    [301]   = OSI.ALLY_VENDOR,  -- nuzhimeh the merchant
    [396]   = OSI.ALLY_VENDOR,  -- allaria erwen the exporter
    [397]   = OSI.ALLY_BANKER,  -- cassus andronicus the mercenary
    [6376]  = OSI.ALLY_BANKER,  -- ezabi the banker
    [6378]  = OSI.ALLY_VENDOR,  -- fezez the merchant
    [8994]  = OSI.ALLY_BANKER,  -- baron jangleplume, the banker
    [8995]  = OSI.ALLY_VENDOR,  -- peddler of prizes, the merchant
    [9743]  = OSI.ALLY_BANKER,  -- factotum property steward
    [9744]  = OSI.ALLY_VENDOR,  -- factotum commerce delegate
    [9745]  = OSI.ALLY_ARMORY,  -- ghrashgarog, armory assustant
    [10184] = OSI.ALLY_DECON,   -- giladil the ragpicker
    [10617] = OSI.ALLY_DECON,   -- aderene, fargrave dregs dealer
    [10618] = OSI.ALLY_ARMORY,  -- zuqoth, armory advisor
    [11059] = OSI.ALLY_VENDOR,  -- hoarfrost, takubar trader
    [11097] = OSI.ALLY_BANKER,  -- pyroclast, infernace conservator
    [11876] = OSI.ALLY_ARMORY,  -- drinweth, valenwood armorer
    [11877] = OSI.ALLY_DECON,   -- tzozabrar, dwarven deconstructor
    [12413] = OSI.ALLY_BANKER,  -- eri, barking banker
    [12414] = OSI.ALLY_VENDOR,  -- xyn, planar purveyor
    [13063] = OSI.ALLY_DECON,	-- siluruz, realm craftsmaster
    [13066] = OSI.ALLY_VENDOR,  -- terilorne, dibellan freetrader
    [13518] = OSI.ALLY_ARMORY,  -- voko, carnaval weapondancer
}

-- companions by collectible id
local COMPANIONS = {
    [9245] = OSI.ALLY_BASTIAN,  -- bastian hallix
    [9353] = OSI.ALLY_MIRRI,    -- mirri elendis
    [9911] = OSI.ALLY_EMBER,    -- ember
    [9912] = OSI.ALLY_ISOBEL,    -- isobel
    [11113] = OSI.ALLY_SHARP, -- sharp as night (11113 / 11390)
    [11114] = OSI.ALLY_AZANDAR, --azandar (11114 / 11391)
    [12172] = OSI.ALLY_TANLORIN, --12172, 12235
    [12173] = OSI.ALLY_ZERITHVAR, -- 12173, 12236
}

-- debug
local ERRORS = {
    [1] = "does not exist",
    [2] = "is you",
    [3] = "is not a player",
    [4] = "is not online",
    [5] = "is not in same instance",
    [6] = "is not in same world",
    [7] = "is in remote region",
}

local icon3DConfig = {
    ["dead"]     = true,
    ["mechanic"] = true,
    ["raid"]     = true,
    ["leader"]   = true,
    ["tank"]     = true,
    ["healer"]   = true,
    ["dps"]      = true,
    ["bg"]       = true,
    ["custom"]   = true,
    ["unique"]   = true,
    ["anim"]     = true,
}

function OSI.CreateUI()
    -- DEBUG:
    if OSI.debug then
        OSI.bgw = OSI.window:CreateTopLevelWindow( "OSIBGDebug" )
        OSI.bgw:SetClampedToScreen( true )
        OSI.bgw:SetMouseEnabled( false )
        OSI.bgw:SetMovable( false )
        OSI.bgw:ClearAnchors()
        OSI.bgw:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
        OSI.bgw:SetDimensions( GuiRoot:GetWidth(), GuiRoot:GetHeight() )
        OSI.bgd = OSI.window:CreateControl( "OSIBGDebugLabel", OSI.bgw, CT_LABEL )
        OSI.bgd:ClearAnchors()
        OSI.bgd:SetAnchor( TOPRIGHT, OSI.bgw, RIGHT, 0, 0 )
        OSI.bgd:SetDimensions( 250, 500 )
        OSI.bgd:SetFont( "$(MEDIUM_FONT)|$(KB_10)|soft-shadow-thin" )
    end

    -- create render space control
    OSI.ctrl = OSI.window:CreateControl( "OSICtrl", GuiRoot, CT_CONTROL )
    OSI.ctrl:SetAnchorFill( GuiRoot )
    OSI.ctrl:Create3DRenderSpace()
    OSI.ctrl:SetHidden( true )

    -- create parent window for icons
	OSI.win = OSI.window:CreateTopLevelWindow( "OSIWin" )
    OSI.win:SetClampedToScreen( true )
    OSI.win:SetMouseEnabled( false )
    OSI.win:SetMovable( false )
    OSI.win:SetAnchorFill( GuiRoot )
	OSI.win:SetDrawLayer( DL_BACKGROUND )
	OSI.win:SetDrawTier( DT_LOW )
	OSI.win:SetDrawLevel( 0 )

    -- create parent window scene fragment
	local frag = ZO_HUDFadeSceneFragment:New( OSI.win )
	HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )
end

function OSI.CreateUICustom()
    -- create custom icon picker window
	OSI.pick = OSI.window:CreateTopLevelWindow( "OSIPick" )
    OSI.pick:SetClampedToScreen( true )
    OSI.pick:SetMouseEnabled( true )
    OSI.pick:SetMovable( false )
	OSI.pick:ClearAnchors()
	OSI.pick:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
    OSI.pick:SetDimensions( 350, 198 )
    OSI.pick:SetHidden( true )

    -- create window backdrop
    local back = OSI.window:CreateControl( "OSIPickBack", OSI.pick, CT_BACKDROP )
    back:ClearAnchors()
    back:SetAnchor( TOPLEFT, OSI.pick, TOPLEFT, 0, 0 )
    back:SetDimensions( 350, 198 )
    back:SetEdgeTexture( "EsoUI/Art/Tooltips/UI-Border.dds", 128, 16 )
    back:SetCenterTexture( "EsoUI/Art/Tooltips/UI-TooltipCenter.dds" )
    back:SetInsets( 16, 16, -16, -16 )
    back.data = { }

    -- create window title
    local label = OSI.window:CreateControl( "OSIPickLabel", back, CT_LABEL )
    label:ClearAnchors()
    label:SetAnchor( TOPLEFT, back, TOPLEFT, 16, 16 )
    label:SetDimensions( 318, 48 )
    label:SetFont( "ZoFontWinH4" )

    -- create icon picker
    local icondata = {
        type       = "iconpicker",
        name       = "Texture",
        iconSize   = 48,
        maxColumns = 5,
        getFunc    = function() return OSI.custom.texture end,
        setFunc    = function( newValue ) OSI.custom.texture = newValue end,
        choices    = ICONS_CUSTOM,
    }
    local icon = LAMCreateControl.iconpicker( back, icondata, "OSIPickIcon" )
    icon:ClearAnchors()
    icon:SetAnchor( TOPLEFT, label, BOTTOMLEFT, 0, 0 )

    -- create save button
    local savedata = {
        type  = "button",
        name  = "SAVE",
        func  = function()
            if OSI.custom.raidlead then
                OSI.AssignRaidIconForUnit( OSI.custom.displayName, OSI.custom.texture )
            else
                OSI.SetCustomIconForUnit( OSI.custom.displayName, OSI.custom.texture, OSI.BASECOLOR )
            end
            -- hide picker window
            OSI.pick:SetHidden( true )
        end,
        width = "half",
    }
    local save = LAMCreateControl.button( back, savedata, "OSIPickSave" )
    save:ClearAnchors()
    save:SetAnchor( TOPLEFT, icon, BOTTOMLEFT, 0, 16 )

    -- create cancel button
    local canceldata = {
        type  = "button",
        name  = "CANCEL",
        func  = function() OSI.pick:SetHidden( true ) end,
        width = "half",
    }
    local cancel = LAMCreateControl.button( back, canceldata, "OSIPickCancel" )
    cancel:ClearAnchors()
    cancel:SetAnchor( TOPRIGHT, icon, BOTTOMRIGHT, 14, 16 )

    -- store window title and controls
    OSI.picklabel = label
    OSI.pickicon  = icon

    -- hide window if group window, friends list or guild roster are closed
    local function sceneCheck( showing )
        if showing ~= "showing" then
            LAM.util.GetIconPickerMenu().control:SetHidden( true )
            OSI.pick:SetHidden( true )
        end
    end

    -- keyboard
    KEYBOARD_GROUP_MENU_SCENE:RegisterCallback( "StateChange", sceneCheck )
    FRIENDS_LIST_SCENE:RegisterCallback( "StateChange", sceneCheck )
    GUILD_ROSTER_SCENE:RegisterCallback( "StateChange", sceneCheck )
end

function OSI.RefreshData()
    GROUP_LIST:RefreshData()
    FRIENDS_LIST_MANAGER:RefreshData()
    GUILD_ROSTER_MANAGER:RefreshData()
    ZO_WorldMap_RefreshGroupPins()
end

function OSI.ToggleIcons()
    OSI.show = not OSI.show
end

function OSI.UnitErrorCheck( unit )
    -- check if unit is valid
    if not DoesUnitExist( unit ) then return 1 end
    if AreUnitsEqual( "player", unit ) then 
        if not OSI.GetOption( "showOwnIcon" ) then return 2 end
    end
    if not IsUnitPlayer( unit ) then return 3 end
    if not IsUnitOnline( unit ) then return 4 end
    -- while in battlegrounds, instance check sometimes returns false
    if not IsGroupMemberInSameInstanceAsPlayer( unit ) and not IsActiveWorldBattleground() then return 5 end
    if not IsGroupMemberInSameWorldAsPlayer( unit ) then return 6 end
    if IsGroupMemberInRemoteRegion( unit ) then return 7 end
    return 0
end

function OSI.OnUpdate()
    -- reset icons
    OSI.ResetMechanicIcons()
    OSI.ResetRaidIcons()
    OSI.ResetIcons()

    -- early out if 3d icons are toggled
    if not OSI.show then
        return
    end

    -- prepare render space
    Set3DRenderSpaceToCurrentCamera( OSI.ctrl:GetName() )

    -- retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition( OSI.ctrl:Get3DRenderSpaceOrigin() )
    local fX, fY, fZ = OSI.ctrl:Get3DRenderSpaceForward()
    local rX, rY, rZ = OSI.ctrl:Get3DRenderSpaceRight()
    local uX, uY, uZ = OSI.ctrl:Get3DRenderSpaceUp()

    -- https://semath.info/src/inverse-cofactor-ex4.html
    -- calculate determinant for camera matrix
    -- local det = rX * uY * fZ - rX * uZ * fY - rY * uX * fZ + rZ * uX * fY + rY * uZ * fX - rZ * uY * fX
    -- local mul = 1 / det
    -- determinant should always be -1
    -- instead of multiplying simply negate
    -- calculate inverse camera matrix
    local i11 = -( uY * fZ - uZ * fY )
    local i12 = -( rZ * fY - rY * fZ )
    local i13 = -( rY * uZ - rZ * uY )
    local i21 = -( uZ * fX - uX * fZ )
    local i22 = -( rX * fZ - rZ * fX )
    local i23 = -( rZ * uX - rX * uZ )
    local i31 = -( uX * fY - uY * fX )
    local i32 = -( rY * fX - rX * fY )
    local i33 = -( rX * uY - rY * uX )
    local i41 = -( uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY )
    local i42 = -( rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY )
    local i43 = -( rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY )

    -- screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()

    -- drawing order
    local ztotal = 0
    local zorder = {}

    -- icon data
    local tex       = nil
    local lci     = nil
    local col       = OSI.BASECOLOR
    local size      = OSI.GetOption( "iconsize" )
    local offset    = OSI.GetOption( "offset" )
    local scaling   = OSI.GetOption( "scaling" )
    local fadeout   = OSI.GetOption( "fadeout" )
    local fadedist  = OSI.GetOption( "fadedist" )
    local basealpha = OSI.GetOption( "alpha" )
    local dead      = OSI.GetOption( OSI.ROLE_DEAD )

    -- DEPRECATED
    -- update icon size
    OSI.store.iconsize = size

    local function UpdateUnit( unit, icon )
        local zone, wX, wY, wZ
        if unit then
            -- get unit world position
            zone, wX, wY, wZ = GetUnitRawWorldPosition( unit )
        else
            -- get icon position
            wX, wY, wZ = icon.x, icon.y, icon.z
        end
        wY = wY + offset * 100

        -- calculate unit view position
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

        -- if unit is in front
        if pZ > 0 then
            -- calculate unit screen position
            local w, h = GetWorldDimensionsOfViewFrustumAtDepth( pZ )
            local x, y = pX * uiW / w, -pY * uiH / h

            -- update icon position
            local ctrl = icon.ctrl
            ctrl:ClearAnchors()
            ctrl:SetAnchor( BOTTOM, OSI.win, CENTER, x, y )

            -- update icon data
            OSI.UpdateIconData( icon, tex, col, lci )

            -- calculate distance
            local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
            local dist       = 1 + zo_sqrt( dX * dX + dY * dY + dZ * dZ )

            -- update icon size
            ctrl:SetDimensions( size, size )
            ctrl:SetScale( scaling and 1000 / dist or 1 )

            -- update icon opacity
            local alpha = fadeout and zo_clampedPercentBetween( 1, fadedist * 100, dist ) or 1
            ctrl:SetAlpha( basealpha * alpha * alpha )

            -- show icon
            ctrl:SetHidden( false )

            -- FIXME: handle draw order
            -- in theory, 2 icons could have the same floored pZ
            -- zorder buffer should either store icons in tables or
            -- decrease chance for same depth by multiplying pZ before
            -- flooring for additional precision
            zorder[1 + zo_floor( pZ * 100 )] = icon
            ztotal = ztotal + 1
        end
    end

    -- ally icons
    local ally = ALLIES[GetActiveCollectibleByType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER )]
    if ally then
        for i = 1, MAX_PET_UNIT_TAGS do
            local unit = "playerpet" .. i
            if DoesUnitExist( unit ) and IsUnitFriendlyFollower( unit ) and (GetUnitCaption( unit )  or GetUnitName( unit ):find(".*Giladil.*")) then
                local data = OSI.GetOption( ally )
                if data.show then
                    tex = data.icon
                    col = data.color

                    UpdateUnit( unit, OSI.GetIconForCompanion() )
                end
                break
            end
        end
    elseif DoesUnitExist( "companion" ) then
        local did  = GetActiveCompanionDefId()
        local cid  = GetCompanionCollectibleId( did )
        local comp = cid and COMPANIONS[cid] or nil
        local data = comp and OSI.GetOption( comp ) or nil
        if data then
            local show  = data.show
            local color = nil

            if show then
                if IsUnitDead( "companion" ) then
                    offset = dead.offset

                    if data.dead then
                        data  = dead
                        color = IsUnitBeingResurrected( "companion" ) and data.colrez or data.color
                        show  = true
                    end
                end

                tex = data.icon
                col = color or data.color

                UpdateUnit( "companion", OSI.GetIconForCompanion() )
            end
        end
    end

    -- render position icons
    local posIcons = OSI.GetPositionIcons()
    for _, icon in pairs( posIcons ) do
        icon.ctrl:SetHidden( true )
        if icon.use then
            if type( icon.callback ) == "function" then
                icon.callback( icon.data )
            end

            tex    = icon.data.texture
            size   = icon.data.size
            col    = icon.data.color
            offset = icon.data.offset

            UpdateUnit( nil, icon )
        end
    end

    -- handle group icons
    if IsUnitGrouped( "player" ) then
        -- update icon config
        --icon3DConfig.raid   = OSI.GetOption( "raidallow" )
        icon3DConfig.raid = false
        icon3DConfig.dead   = dead.show
        icon3DConfig.leader = OSI.GetOption( OSI.ROLE_LEAD ).show
        icon3DConfig.tank   = OSI.GetOption( OSI.ROLE_TANK ).show
        icon3DConfig.healer = OSI.GetOption( OSI.ROLE_HEAL ).show
        icon3DConfig.dps    = OSI.GetOption( OSI.ROLE_DPS ).show
        icon3DConfig.bg     = OSI.GetOption( OSI.ROLE_BG ).show
        icon3DConfig.custom = OSI.GetOption( "customuse" )
        icon3DConfig.unique = not OSI.GetOption( "ignore" )

        -- DEBUG:
        local bgdebug = ""
        if OSI.debug then
            bgdebug = "lead: |c00ff00" .. tostring( GetGroupLeaderUnitTag() ) .. "|r\n"
            bgdebug = bgdebug .. "zone: |cff00ff" .. GetUnitZone( "player" ) .. "|r id=" .. GetUnitWorldPosition( "player" ) .. " index=" .. GetCurrentMapZoneIndex() .. "\n"
        end

        -- update group icons
        for i = 1, GROUP_SIZE_MAX do    
            local unit        = "group" .. i
            local displayName = GetUnitDisplayName( unit )
            local error       = OSI.UnitErrorCheck( unit )

            -- DEBUG:
            if OSI.debug then
                bgdebug = bgdebug .. "|cff0000" .. error .. "|r |c00ff00" .. unit .. "|r |cff00ff" .. ( displayName and ( displayName .. " " ) or "" ) .. "|r" .. ( error > 0 and ERRORS[error] or "" ) .. "\n"
            end

            -- only update if no errors occured
            if error == 0 then
                -- retrieve texture, color and size
                tex, col, size, lci, offset = OSI.GetIconDataForPlayer( displayName, icon3DConfig, unit )
                -- only update if texture available
                if tex then
                    UpdateUnit( unit, OSI.GetIconForPlayer( displayName ) )
                end
            end
        end

        -- DEBUG:
        if OSI.debug then
            OSI.bgd:SetText( bgdebug )
        end
    end

    -- sort draw order
    if ztotal > 1 then
        local keys = { }
        for k in pairs( zorder ) do
            table.insert( keys, k )
        end
        table.sort( keys )

        -- adjust draw order
        for _, k in ipairs( keys ) do
            zorder[k].ctrl:SetDrawLevel( ztotal )
            ztotal = ztotal - 1
        end
    end
end

function OSI.GetIconDataForPlayer( displayName, config, unit )
    local name   = string.lower( displayName )
    local size   = OSI.GetOption( "iconsize" )
    local offset = OSI.GetOption( "offset" )
    local dead   = OSI.GetOption( OSI.ROLE_DEAD )
    local isDead = unit and IsUnitDead( unit ) or false
    local role   = nil

    -- adjust dead player offset
    if dead.useoff and isDead then
        offset = dead.offset
    end

    -- handle dead player icon with priority
    if config.dead and dead.priority and isDead then
        return dead.icon, DoesUnitHaveResurrectPending( unit ) and dead.colrdy or ( IsUnitBeingResurrected( unit ) and dead.colrez or dead.color ), size, nil, offset
    end

    -- handle mechanic icon
    if config.mechanic and OSI.mechanic and OSI.mechanic[name] then
        local mech = OSI.mechanic[name]
        if type( mech.callback ) == "function" then
            mech.data.unitTag = unit
            mech.callback( mech.data )
        end
        return mech.data.texture, mech.data.color, mech.data.size, nil, mech.data.offset + offset
    end

    -- handle raid icon
    if config.raid and OSI.raidlead and OSI.raidlead[name] then
        return OSI.raidlead[name], OSI.BASECOLOR, size, nil, offset
    end

    -- retrieve role icon
    if unit then
        local r = GetGroupMemberSelectedRole( unit )
        if config.leader and IsUnitGroupLeader( unit ) then
            role = OSI.GetOption( OSI.ROLE_LEAD )
        elseif config.tank and r == LFG_ROLE_TANK then
            role = OSI.GetOption( OSI.ROLE_TANK )
        elseif config.healer and r == LFG_ROLE_HEAL then
            role = OSI.GetOption( OSI.ROLE_HEAL )
        elseif config.dps and r == LFG_ROLE_DPS then
            role = OSI.GetOption( OSI.ROLE_DPS )
        elseif config.bg and r == LFG_ROLE_INVALID and IsActiveWorldBattleground() then
            role = OSI.GetOption( OSI.ROLE_BG )
        end
    end

    -- handle role icon with priority
    if role and role.priority then
        return role.icon, role.color, role.usesize and role.size or size, nil, offset
    end

    local reflex  = OSI.GetOption( "hodoruse" ) and LCI
    local lciStatic   = reflex and LCI.GetStatic(displayName) or nil
    local lciAnimated    = ( reflex and OSI.GetOption( "hodoranim" ) ) and LCI.GetAnimated(displayName) or nil
    local unique  = OSI.users[name]
    local special = OSI.special[name]

    -- handle custom icon
    if config.custom and special then
        return special.texture, OSI.BASECOLOR, size, nil, offset
    end

    -- handle unique or LibCustomIcons icon
    if config.unique then
        -- handle LibCustomIcons with priority
        if OSI.GetOption( "hodorprio" ) then
            if config.anim and lciAnimated then
                return lciAnimated[1], OSI.BASECOLOR, size, lciAnimated, offset
            end
            if lciStatic then
                return lciStatic, OSI.BASECOLOR, size, nil, offset
            end
        end

        -- handle unique icon
        if unique then
            return unique, OSI.BASECOLOR, size, nil, offset
        end

        -- handle LibCustomIcons
        if config.anim and lciAnimated then
            return lciAnimated[1], OSI.BASECOLOR, size, lciAnimated, offset
        end
        if lciStatic then
            return lciStatic, OSI.BASECOLOR, size, nil, offset
        end
    end

    -- handle role icon
    if role then
        return role.icon, role.color, role.usesize and role.size or size, nil, offset
    end

    -- handle dead player icon
    if config.dead and isDead then
        return dead.icon, DoesUnitHaveResurrectPending( unit ) and dead.colrdy or ( IsUnitBeingResurrected( unit ) and dead.colrez or dead.color ), size, nil, offset
    end

    return nil, OSI.BASECOLOR, size, nil, offset
end

function OSI.CreateContextMenus()
    OSI.GroupWindowContextMenu()
    OSI.FriendListContextMenu()
    OSI.GuildRosterContextMenu()
end

function OSI.AttachWindowHooks()
    OSI.GroupWindowHook()
    OSI.FriendListHook()
    OSI.GuildRosterHook()
end

function OSI.StartPolling()
    OSI.events:UnregisterForUpdate( OSI.name .. "Update" )
    OSI.events:RegisterForUpdate( OSI.name .. "Update", OSI.GetOption( "interval" ), OSI.OnUpdate )
end

function OSI.OnActivated()
    OSI.events:UnregisterForEvent( OSI.name .. "Activated", EVENT_PLAYER_ACTIVATED )

    OSI.events:RegisterForEvent( OSI.name .. "GroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, function() GROUP_LIST:RefreshData(); ZO_WorldMap_RefreshGroupPins() end )
    OSI.events:RegisterForEvent( OSI.name .. "GroupLeaderUpdate", EVENT_LEADER_UPDATE, function() GROUP_LIST:RefreshData(); ZO_WorldMap_RefreshGroupPins() end )
    OSI.events:RegisterForEvent( OSI.name .. "DeathStateChanged", EVENT_UNIT_DEATH_STATE_CHANGED, function() GROUP_LIST:RefreshData(); ZO_WorldMap_RefreshGroupPins() end )
    OSI.events:AddFilterForEvent( OSI.name .. "DeathStateChanged", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group" )

    OSI.OverloadAIGW()
    OSI.PrepareDisplayNameTable()
    OSI.CreateContextMenus()
    OSI.AttachWindowHooks()
    OSI.StartPolling()
end

function OSI.OnAddonLoaded( event, addonName )
    if addonName ~= OSI.name then return end

    ZO_CreateStringId( "SI_BINDING_NAME_OSI_TOGGLE", "Toggle 3D Icon Visibility" )

    OSI.LoadOptions()
    OSI.ChatWindowHook()
    OSI.WorldMapHook()
    OSI.CreateMenu( LAM )
    OSI.CreateUI()
    OSI.CreateUICustom()
    OSI.CreateIconPool()
    --OSI.FixLibAddonMenu( LAM )
    OSI.CacheRestoreIcons()

    -- DEPRECATED
    OSI.ResetMechanicIconSize()

    OSI.events:UnregisterForEvent( OSI.name, EVENT_ADD_ON_LOADED )
	OSI.events:RegisterForEvent( OSI.name .. "Activated", EVENT_PLAYER_ACTIVATED, OSI.OnActivated )
end

OSI.events:RegisterForEvent( OSI.name, EVENT_ADD_ON_LOADED, OSI.OnAddonLoaded )
