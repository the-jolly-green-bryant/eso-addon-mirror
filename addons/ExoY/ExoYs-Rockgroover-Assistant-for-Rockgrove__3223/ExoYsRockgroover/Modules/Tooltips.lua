Rockgroover = Rockgroover or {}
local ERG = Rockgroover

--TODO tooltips for CCA notifications

local tooltipList = {}

function ERG.InitializeTooltips()
  local mechanicId
  -- Trash
  mechanicId = ERG.trash.GetMechanicIds()
  tooltipList[mechanicId.hastedAssault] = ERG_TRASH_TT_HASTED_ASSAULT
  tooltipList[mechanicId.earthquake] = ERG_TRASH_TT_EARTHQUAKE
  tooltipList[mechanicId.extrication] = ERG_TRASH_TT_EXTRICATION

  -- Oaxiltso
  mechanicId = ERG.oaxiltso.GetMechanicIds()
  tooltipList[mechanicId.blazingBoon] = ERG_OAXILTSO_TT_BLAZING_BOON
  tooltipList[mechanicId.blazingBoonMini] = ERG_OAXILTSO_TT_BLAZING_BOON_MINI
  tooltipList[mechanicId.blisteringSmash] = ERG_OAXILTSO_TT_BLISTERING_SMASH
  tooltipList[mechanicId.magmaSludge] = ERG_OAXILTSO_TT_MAGMA_SLUDGE
  tooltipList[mechanicId.meteorCrash] = ERG_OAXILTSO_TT_METEOR_CRASH
  tooltipList[mechanicId.moltenEarth] = ERG_OAXILTSO_TT_MOLTEN_EARTH
  tooltipList[mechanicId.noxiousSludge] = ERG_OAXILTSO_TT_NOXIOUS_SLUDE
  tooltipList[mechanicId.poisoned] = ERG_OAXILTSO_TT_POISONED
  tooltipList[mechanicId.ravenousChomp] = ERG_OAXILTSO_TT_RAVENOUS_CHOMP
  tooltipList[mechanicId.savageBlitz] = ERG_OAXILTSO_TT_SAVAGE_BLITZ
  tooltipList[mechanicId.sunburst] = ERG_OAXILTSO_TT_SUNBURST



end

function ERG.GetTooltip( abilityId )
  return tooltipList[abilityId]
end
