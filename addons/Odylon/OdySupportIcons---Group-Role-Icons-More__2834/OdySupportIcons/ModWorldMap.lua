local wmConfig = {
    ["dead"]     = false,
    ["mechanic"] = false,
    ["raid"]     = false,
    ["leader"]   = false,
    ["tank"]     = false,
    ["healer"]   = false,
    ["dps"]      = false,
    ["bg"]       = false,
    ["custom"]   = false,
    ["unique"]   = false,
    ["anim"]     = false,
}

local function WorldMapStopAnimation( anim )
    if anim then
        anim.gfx = nil

        if anim.timeline:IsPlaying() then
            anim.timeline:Stop()
        end
    end
end

local function WorldMapResetPin( pin, icon, parent, anim )
    if pin.wasAltered then
        pin.wasAltered = false
                        
        icon:ClearAnchors()
        icon:SetAnchorFill( parent )

        WorldMapStopAnimation( anim )
    end
end

function OSI.WorldMapHook()
    local pinmanager = ZO_WorldMap_GetPinManager()
    local createpin  = pinmanager.CreatePin
    pinmanager.CreatePin = function( ... )
        local pin = createpin( ... )
        if pin then
            local icon = pin.backgroundControl
            if icon then
                local parent = icon:GetParent()
                local anim   = pin.animData

                if pin:IsGroup() then
                    wmConfig.raid   = OSI.GetOption( "raidallow" )
                    wmConfig.dead   = OSI.GetOption( "wmdead" )
                    wmConfig.leader = OSI.GetOption( "wmroles" )
                    wmConfig.tank   = OSI.GetOption( "wmroles" )
                    wmConfig.healer = OSI.GetOption( "wmroles" )
                    wmConfig.dps    = OSI.GetOption( "wmroles" )
                    wmConfig.bg     = OSI.GetOption( "wmroles" )
                    wmConfig.custom = OSI.GetOption( "wmuse" )
                    wmConfig.unique = OSI.GetOption( "wmunique" )

                    local tag                = pin:GetUnitTag()
                    local unit               = GetUnitDisplayName( tag ) 
                    local tex, col, _, hodor = OSI.GetIconDataForPlayer( unit, wmConfig, tag )
                    local wmsize             = OSI.GetOption( "wmsize" )

                    if tex and not pin.m_PinTag.isBreadcrumb then
                        pin.wasAltered = true

                        icon:ClearAnchors()
                        icon:SetAnchor( CENTER, parent, CENTER, 0, 0 )
                        icon:SetDimensions( wmsize, wmsize )
                        icon:SetColor( col[1], col[2], col[3], 1 )
                        icon:SetTexture( tex )

                        if hodor then
                            if not anim then
                                local timeline = ANIMATION_MANAGER:CreateTimeline()
                                timeline:SetPlaybackType( ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY )
                                timeline:SetHandler( "OnStop", function() icon:SetTextureCoords( 0, 1, 0, 1 ) end )
            
                                anim = {
                                    ["timeline"] = timeline,
                                    ["ctrl"]     = timeline:InsertAnimation( ANIMATION_TEXTURE, icon ),
                                    ["gfx"]      = nil,
                                }
                                
                                pin.animData = anim
                            end
            
                            if anim.gfx ~= tex then
                                anim.gfx = tex
            
                                anim.ctrl:SetImageData( hodor[2], hodor[3] )
                                anim.ctrl:SetFramerate( hodor[4] )
                                anim.timeline:PlayFromStart()
                            end
                        else
                            WorldMapStopAnimation( anim )
                        end
                    else
                        WorldMapResetPin( pin, icon, parent, anim )
                    end
                else
                    WorldMapResetPin( pin, icon, parent, anim )
                end
            end
        end
        return pin
    end
end