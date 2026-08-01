--
-- Just another Bug eater 
-- V.1.0 @Zand3rs PC[EU]

noBUGS={}
noBUGS.name = "noBUGS"
local temp=0
function noBUGS.OnAddOnLoaded(event, addonName) 
  if (temp==0) then ZO_UIErrors_ToggleSupressDialog() 
    temp=1 
  end
end
EVENT_MANAGER:RegisterForEvent(noBUGS.name, EVENT_ADD_ON_LOADED, noBUGS.OnAddOnLoaded)