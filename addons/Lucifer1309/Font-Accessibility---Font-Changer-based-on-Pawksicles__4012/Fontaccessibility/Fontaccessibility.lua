local kName               = 'Fontaccessibility'
local Fontaccessibility   = {}
local EventMgr            = GetEventManager()
local CBM                 = CALLBACK_MANAGER
local LMP                 = LibMediaProvider
if ( not LMP ) then return end

function Fontaccessibility:OnLoaded( event, addon )
    if ( addon ~= kName ) then
        return
    end


    LMP:Register( 'font', 'DejaVu Sans',              [[fontaccessibility/fonts/dejavusans.ttf]]                )
    LMP:Register( 'font', 'DejaVu Sans Bold',         [[fontaccessibility/fonts/dejavusans-bold.ttf]]           )
    LMP:Register( 'font', 'DejaVu Sans BoldOblique',  [[fontaccessibility/fonts/dejavusans-boldoblique.ttf]]    )
    LMP:Register( 'font', 'DejaVu Sans Oblique',      [[fontaccessibility/fonts/dejavusans-oblique.ttf]]        )
    LMP:Register( 'font', 'DejaVu Sans Mono',         [[fontaccessibility/fonts/dejavusansmono.ttf]]            )
    LMP:Register( 'font', 'DejaVu Serif',             [[fontaccessibility/fonts/dejavuserif.ttf]]               )

    CBM:RegisterCallback( 'FONTACCESSIBILITY_FONT_CHANGED', function( ... ) self:SetFont( ... ) end )
    CBM:FireCallbacks( 'FONTACCESSIBILITY_LOADED' )
end

function Fontaccessibility:SetFont( object, font )
    if _G[ object ] ~= nil then
        _G[ object ]:SetFont( font )
    end
end

EventMgr:RegisterForEvent( 'Fontaccessibility', EVENT_ADD_ON_LOADED, function( ... ) Fontaccessibility:OnLoaded( ... ) end )
