local kName         = 'jpfont'
local LMP = LibStub( 'LibMediaProvider-1.0' )
LMP:Register( 'font', 'MisakiGothic',[[jpfont/fonts/misaki_gothic.ttf]])
LMP:Register( 'font', 'Mona',[[jpfont/fonts/mona.ttf]])
LMP:Register( 'font', 'M+ 1p',[[jpfont/fonts/mplus-1p-regular.ttf]])
LMP:Register( 'font', '07LogoTypeGothic7',[[jpfont/fonts/LogoTypeGothic.otf]])
LMP:Register( 'font', 'AoyagiKouzan',[[jpfont/fonts/AoyagiKouzanTOTF.otf]])

function OnLoaded( event, addon )
  if ( addon ~= kName ) then
      return 
  end
end
EVENT_MANAGER:RegisterForEvent( 'jpfont', EVENT_ADD_ON_LOADED, function( ... ) OnLoaded( ... ) end )

