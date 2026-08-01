Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.xalvakka = ERG.xalvakka or {}
local Xalvakka = ERG.xalvakka


function Xalvakka.GetAnticipationDefaults()
  local defaults = ERG.anticipation.GetDefaults( Xalvakka.GetMechanicData() )
  defaults.enrage = true
  return defaults
end

-------------
-- Updates --
-------------

function Xalvakka.OnAnticipationPanelUpdate()
  ERG.anticipation.OnUpdate("xalvakka", Xalvakka.anticipation)
end

-----------------
-- Alterations --
-----------------

function Xalvakka.AdaptAnticipationPanelAccordingToProfile()
  ERG.anticipation.OnProfileChange("xalvakka")
end

function Xalvakka.RebuildAnticipationPanel()
  ERG.anticipation.RebuildPanel("xalvakka")
end

----------------
-- Initialize --
----------------

function Xalvakka.InitializeAnticipationPanel( mechanicData )
  ERG.anticipation.Initialize("xalvakka", mechanicData)
end

----------
-- Menu --
----------

function Xalvakka.GetAnticipationMenu()
 return ERG.anticipation.GetMenu( "xalvakka", Xalvakka.GetMechanicData() )
end
