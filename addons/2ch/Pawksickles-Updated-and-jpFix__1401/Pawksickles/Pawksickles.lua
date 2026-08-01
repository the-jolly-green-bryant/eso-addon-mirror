local kName         = 'Pawksickles'
local Pawksickles   = {}
local EventMgr      = GetEventManager()
local CBM           = CALLBACK_MANAGER
local LMP           = LibStub( 'LibMediaProvider-1.0', true )
if ( not LMP ) then return end

function Pawksickles:OnLoaded( event, addon )
    if ( addon ~= kName ) then
        return
    end

    LMP:Register( 'font', 'esojp1',         [[EsoUI/Common/Fonts/ESO_FWNTLGUDC70-DB.ttf]]                )
    LMP:Register( 'font', 'esojp2',         [[EsoUI/Common/Fonts/ESO_FWUDC_70-M.ttf]]           )

    CBM:RegisterCallback( 'PAWKSICKLES_FONT_CHANGED', function( ... ) self:SetFont( ... ) end )
    CBM:FireCallbacks( 'PAWKSICKLES_LOADED' )
end

function Pawksickles:SetFont( object, font )
    if _G[ object ] ~= nil then
        _G[ object ]:SetFont( font )
    end
end

EventMgr:RegisterForEvent( 'Pawksickles', EVENT_ADD_ON_LOADED, function( ... ) Pawksickles:OnLoaded( ... ) end )