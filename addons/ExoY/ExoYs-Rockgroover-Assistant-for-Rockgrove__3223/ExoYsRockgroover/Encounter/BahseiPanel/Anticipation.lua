Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.bahsei = ERG.bahsei or {}
local Bahsei = ERG.bahsei


function Bahsei.GetAnticipationDefaults()
  local defaults = ERG.anticipation.GetDefaults( Bahsei.GetMechanicData() )
  return defaults
end

-------------
-- Updates --
-------------

function Bahsei.OnAnticipationPanelUpdate()
  ERG.anticipation.OnUpdate("bahsei", Bahsei.anticipation)
end

-----------------
-- Alterations --
-----------------

function Bahsei.AdaptAnticipationPanelAccordingToProfile()
  ERG.anticipation.OnProfileChange("bahsei")
end

function Bahsei.RebuildAnticipationPanel()
  ERG.anticipation.RebuildPanel("bahsei")
end

----------------
-- Initialize --
----------------

function Bahsei.InitializeAnticipationPanel( mechanicData )
  ERG.anticipation.Initialize("bahsei", mechanicData)
end

----------
-- Menu --
----------

function Bahsei.GetAnticipationMenu()
 return ERG.anticipation.GetMenu( "bahsei", Bahsei.GetMechanicData() )
end
