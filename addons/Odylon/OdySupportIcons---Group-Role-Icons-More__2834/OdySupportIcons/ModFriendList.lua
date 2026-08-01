local flConfig = {
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
    ["anim"]     = true,
}

local function FriendListStopAnimation( anim )
    if anim then
        anim.gfx = nil

        if anim.timeline:IsPlaying() then
            anim.timeline:Stop()
        end
    end
end

function OSI.FriendListContextMenu()
    local LCM = LibCustomMenu 
    local function AddItem(data)
        local name = string.lower( data.displayName )
        if OSI.special[name] and OSI.special[name].texture ~= OSI.users[name] then
            AddCustomMenuItem( "Change Custom Icon", function() OSI.ChooseCustomIconForUnit( name ) end)
            AddCustomMenuItem( "Remove Custom Icon", function() OSI.RemoveCustomIconFromUnit( name ) end)
        else
            AddCustomMenuItem( "Assign Custom Icon", function() OSI.ChooseCustomIconForUnit( name ) end)
        end
    end
    LCM:RegisterFriendsListContextMenu(AddItem, LCM.CATEGORY_LATE)  
end

function OSI.FriendListHook()
    -- show custom icons in friends list
    local setupEntry = FRIENDS_LIST_MANAGER.SetupEntry
    function FRIENDS_LIST_MANAGER:SetupEntry( control, data, selected )
        setupEntry( self, control, data, selected )

        flConfig.custom = OSI.GetOption( "fluse" )
        flConfig.unique = OSI.GetOption( "flunique" )

        local tex, col, _, hodor = OSI.GetIconDataForPlayer( data.displayName, flConfig, nil )
        local icon               = control:GetNamedChild( "StatusIcon" )
        local status             = icon:GetNamedChild( "Overlay" )
        local anim               = control.animData

        if tex then
            if not status then
                status = icon:CreateControl( icon:GetName() .. "Overlay", CT_TEXTURE )
                status:ClearAnchors()
                status:SetParent( icon )
                status:SetAnchor( TOPLEFT, icon, TOPLEFT, 2, 2 )
                status:SetDimensions( icon:GetWidth() - 4, icon:GetHeight() - 4 )
                status:SetDrawLayer( 1 )
            end

            status:SetHidden( false )
            status:SetTexture( tex )
            status:SetDesaturation( data.online and 0 or 1 )
            status:SetColor( col[1], col[2], col[3], 1 )

            icon:SetDrawLayer( 2 )
            icon:SetTexture( OSI.STATUS[OSI.GetOption( "flstatus" ) and data.status or PLAYER_STATUS_OFFLINE] )

            if hodor then
                if not anim then
                    local timeline = ANIMATION_MANAGER:CreateTimeline()
                    timeline:SetPlaybackType( ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY )
                    timeline:SetHandler( "OnStop", function() status:SetTextureCoords( 0, 1, 0, 1 ) end )

                    anim = {
                        ["timeline"] = timeline,
                        ["ctrl"]     = timeline:InsertAnimation( ANIMATION_TEXTURE, status ),
                        ["gfx"]      = nil,
                    }
                    
                    control.animData = anim
                end

                if anim.gfx ~= tex then
                    anim.gfx = tex

                    anim.ctrl:SetImageData( hodor[2], hodor[3] )
                    anim.ctrl:SetFramerate( hodor[4] )
                    anim.timeline:PlayFromStart()
                end
            else
                FriendListStopAnimation( anim )
            end
        else
            FriendListStopAnimation( anim )

            if status then
                status:SetHidden( true )
            end
        end
    end
end