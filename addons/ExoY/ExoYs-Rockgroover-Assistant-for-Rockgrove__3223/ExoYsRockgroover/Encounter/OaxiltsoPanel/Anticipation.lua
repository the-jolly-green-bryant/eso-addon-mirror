Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.oaxiltso = ERG.oaxiltso or {}
local Oaxiltso = ERG.oaxiltso


function Oaxiltso.GetAnticipationDefaults()
  local defaults = ERG.anticipation.GetDefaults( Oaxiltso.GetMechanicData() )
  defaults.enrage = true
  return defaults
end

-------------
-- Updates --
-------------

function Oaxiltso.OnAnticipationPanelUpdate()
  ERG.anticipation.OnUpdate("oaxiltso", Oaxiltso.anticipation)
end

-----------------
-- Alterations --
-----------------

function Oaxiltso.AdaptAnticipationPanelAccordingToProfile()
  ERG.anticipation.OnProfileChange("oaxiltso")
end

function Oaxiltso.RebuildAnticipationPanel()
  ERG.anticipation.RebuildPanel("oaxiltso")
end

----------------
-- Initialize --
----------------

function Oaxiltso.InitializeAnticipationPanel( mechanicData )
  ERG.anticipation.Initialize("oaxiltso", mechanicData)
end

----------
-- Menu --
----------

function Oaxiltso.GetAnticipationMenu()
 return ERG.anticipation.GetMenu( "oaxiltso", Oaxiltso.GetMechanicData() )
end
