HowToSunspire = HowToSunspire or {}
local HowToSunspire = HowToSunspire

local sV
local d
local oX
local oY

function HowToSunspire.InitUI()
  sV = HowToSunspire.savedVariables
  d  = HowToSunspire.Default
  oX = sV.OffsetX
  oY = sV.OffsetY

  Hts_Ha:SetHidden(true)
  Hts_Portal:SetHidden(true)
  Hts_Ice:SetHidden(true)
  Hts_Sweep:SetHidden(true)
  Hts_Breath:SetHidden(true)
  Hts_Laser:SetHidden(true)
  Hts_HP:SetHidden(true)
  Hts_Landing:SetHidden(true)
  Hts_Block:SetHidden(true)
  Hts_PowerfulSlam:SetHidden(true)
  -- Hts_HailOfStone:SetHidden(true)
  -- Hts_Flare:SetHidden(true)
  Hts_Spit:SetHidden(true)
  Hts_Comet:SetHidden(true)
  Hts_MeteorNames:SetHidden(true)
  Hts_Thrash:SetHidden(true)
  Hts_SoulTear:SetHidden(true)
  Hts_Atro:SetHidden(true)
  Hts_Wipe:SetHidden(true)
  Hts_Storm:SetHidden(true)
  Hts_Geyser:SetHidden(true)
  Hts_NextFlare:SetHidden(true)
  Hts_NextMeteor:SetHidden(true)
  Hts_Negate:SetHidden(true)
  Hts_Shield:SetHidden(true)
  Hts_Cata:SetHidden(true)
  Hts_Leap:SetHidden(true)
  Hts_GlacialFist:SetHidden(true)
  Hts_Stonefist:SetHidden(true)
  Hts_Ha:ClearAnchors()
  Hts_Portal:ClearAnchors()
  Hts_Ice:ClearAnchors()
  Hts_Sweep:ClearAnchors()
  Hts_Breath:ClearAnchors()
  Hts_Laser:ClearAnchors()
  Hts_HP:ClearAnchors()
  Hts_Landing:ClearAnchors()
  Hts_Block:ClearAnchors()
  Hts_PowerfulSlam:ClearAnchors()
  -- Hts_HailOfStone:ClearAnchors()
  -- Hts_Flare:ClearAnchors()
  Hts_Spit:ClearAnchors()
  Hts_Comet:ClearAnchors()
  Hts_MeteorNames:ClearAnchors()
  Hts_Thrash:ClearAnchors()
  Hts_SoulTear:ClearAnchors()
  Hts_Atro:ClearAnchors()
  Hts_Wipe:ClearAnchors()
  Hts_Storm:ClearAnchors()
  Hts_Geyser:ClearAnchors()
  Hts_NextFlare:ClearAnchors()
  Hts_NextMeteor:ClearAnchors()
  Hts_Negate:ClearAnchors()
  Hts_Shield:ClearAnchors()
  Hts_Cata:ClearAnchors()
  Hts_Leap:ClearAnchors()
  Hts_GlacialFist:ClearAnchors()
  Hts_Stonefist:ClearAnchors()

  --heavy attacks
  if oX.HA ~= d.OffsetX.HA and oY.HA ~= d.OffsetY.HA
  then Hts_Ha:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.HA, oY.HA)
  else Hts_Ha:SetAnchor(CENTER, GuiRoot, CENTER, oX.HA, oY.HA) end

  --all portal related notifications
  if oX.Portal ~= d.OffsetX.Portal and oY.Portal ~= d.OffsetY.Portal
  then Hts_Portal:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Portal, oY.Portal)
  else Hts_Portal:SetAnchor(CENTER, GuiRoot, CENTER, oX.Portal, oY.Portal) end

  --ice tomb notifications
  if oX.IceTomb ~= d.OffsetX.IceTomb and oY.IceTomb ~= d.OffsetY.IceTomb
  then Hts_Ice:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.IceTomb, oY.IceTomb)
  else Hts_Ice:SetAnchor(CENTER, GuiRoot, CENTER, oX.IceTomb, oY.IceTomb) end

  Hts_Ice.title = Hts_Ice:GetNamedChild("_Title")
  Hts_Ice.row   = {
    [1] = Hts_Ice:GetNamedChild("_Label1"),
    [2] = Hts_Ice:GetNamedChild("_Label2")
  }

  --fire sweeping breath
  if oX.SweepBreath ~= d.OffsetX.SweepBreath and oY.SweepBreath ~= d.OffsetY.SweepBreath
  then Hts_Sweep:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.SweepBreath, oY.SweepBreath)
  else Hts_Sweep:SetAnchor(CENTER, GuiRoot, CENTER, oX.SweepBreath, oY.SweepBreath) end

  --breath from all bosses
  if oX.Breath ~= d.OffsetX.Breath and oY.Breath ~= d.OffsetY.Breath
  then Hts_Breath:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Breath, oY.Breath)
  else Hts_Breath:SetAnchor(CENTER, GuiRoot, CENTER, oX.Breath, oY.Breath)
  end

  --laser beam on lokke
  if oX.LaserLokke ~= d.OffsetX.LaserLokke and oY.LaserLokke ~= d.OffsetY.LaserLokke
  then Hts_Laser:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.LaserLokke, oY.LaserLokke)
  else Hts_Laser:SetAnchor(CENTER, GuiRoot, CENTER, oX.LaserLokke, oY.LaserLokke) end

  -- % HP tracker
  if oX.HP ~= d.OffsetX.HP and oY.HP ~= d.OffsetY.HP
  then Hts_HP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.HP, oY.HP)
  else Hts_HP:SetAnchor(CENTER, GuiRoot, CENTER, oX.HP, oY.HP) end

  -- landing countdown
  if oX.Landing ~= d.OffsetX.Landing and oY.Landing ~= d.OffsetY.Landing
  then Hts_Landing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Landing, oY.Landing)
  else Hts_Landing:SetAnchor(CENTER, GuiRoot, CENTER, oX.Landing, oY.Landing) end

  --block from red cats
  if oX.Block ~= d.OffsetX.Block and oY.Block ~= d.OffsetY.Block
  then Hts_Block:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Block, oY.Block)
  else Hts_Block:SetAnchor(CENTER, GuiRoot, CENTER, oX.Block, oY.Block) end

  --block from leap
  if oX.Leap ~= d.OffsetX.Leap and oY.Leap ~= d.OffsetY.Leap
  then Hts_Leap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Leap, oY.Leap)
  else Hts_Leap:SetAnchor(CENTER, GuiRoot, CENTER, oX.Leap, oY.Leap) end

  -- Slam from Vigil Statue
  if oX.PowerfulSlam ~= d.OffsetX.PowerfulSlam and oY.PowerfulSlam ~= d.OffsetY.PowerfulSlam
  then Hts_PowerfulSlam:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.PowerfulSlam, oY.PowerfulSlam)
  else Hts_PowerfulSlam:SetAnchor(CENTER, GuiRoot, CENTER, oX.PowerfulSlam, oY.PowerfulSlam) end

  -- Channel from Vigil Statue
  -- if oX.HailOfStone ~= d.OffsetX.HailOfStone and oY.HailOfStone ~= d.OffsetY.HailOfStone then
  -- 		Hts_HailOfStone:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.HailOfStone, oY.HailOfStone)
  -- else
  -- 		Hts_HailOfStone:SetAnchor(CENTER, GuiRoot, CENTER, oX.HailOfStone, oY.HailOfStone)
  -- end

  -- LA from fire atro on Yolna
  -- if oX.Flare ~= d.OffsetX.Flare and oY.Flare ~= d.OffsetY.Flare then
  -- 		Hts_Flare:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Flare, oY.Flare)
  -- else
  -- 		Hts_Flare:SetAnchor(CENTER, GuiRoot, CENTER, oX.Flare, oY.Flare)
  -- end

  --fire spit from nahvii
  if oX.Spit ~= d.OffsetX.Spit and oY.Spit ~= d.OffsetY.Spit
  then Hts_Spit:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Spit, oY.Spit)
  else Hts_Spit:SetAnchor(CENTER, GuiRoot, CENTER, oX.Spit, oY.Spit) end

  --comet from various source
  if oX.Comet ~= d.OffsetX.Comet and oY.Comet ~= d.OffsetY.Comet
  then Hts_Comet:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Comet, oY.Comet)
  else Hts_Comet:SetAnchor(CENTER, GuiRoot, CENTER, oX.Comet, oY.Comet) end

  -- meteor directions on Nahvii
  if oX.MeteorName ~= d.OffsetX.MeteorName and oY.MeteorName ~= d.OffsetY.MeteorName
  then Hts_MeteorNames:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.MeteorName, oY.MeteorName)
  else Hts_MeteorNames:SetAnchor(CENTER, GuiRoot, CENTER, oX.MeteorName, oY.MeteorName) end

  Hts_MeteorNames.labels = {
    [1] = Hts_MeteorNames:GetNamedChild("_Label1"),
    [2] = Hts_MeteorNames:GetNamedChild("_Label2"),
    [3] = Hts_MeteorNames:GetNamedChild("_Label3")
  }
  Hts_MeteorNames.arrows = {
    [1] = Hts_MeteorNames:GetNamedChild("_Arrow_Far1"),
    [2] = Hts_MeteorNames:GetNamedChild("_Arrow_Far2"),
    [3] = Hts_MeteorNames:GetNamedChild("_Arrow_Med1"),
    [4] = Hts_MeteorNames:GetNamedChild("_Arrow_Med2"),
    [5] = Hts_MeteorNames:GetNamedChild("_Arrow_Close1"),
    [6] = Hts_MeteorNames:GetNamedChild("_Arrow_Close2")
  }
  local arrowTextures = {
    [1] = "/HowToSunspire/texture/hts_arrow_far.dds",
    [2] = "/HowToSunspire/texture/hts_arrow_far.dds",
    [3] = "/HowToSunspire/texture/hts_arrow_med_1.dds",
    [4] = "/HowToSunspire/texture/hts_arrow_med_2.dds",
    [5] = "/HowToSunspire/texture/hts_arrow_close_1.dds",
    [6] = "/HowToSunspire/texture/hts_arrow_close_2.dds"
  }

  for i = 1, 6 do
    Hts_MeteorNames.arrows[i]:SetTexture(arrowTextures[i])
  end

  --thrash from nahvii
  if oX.Thrash ~= d.OffsetX.Thrash and oY.Thrash ~= d.OffsetY.Thrash
  then Hts_Thrash:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Thrash, oY.Thrash)
  else Hts_Thrash:SetAnchor(CENTER, GuiRoot, CENTER, oX.Thrash, oY.Thrash) end

  --Soul Tear from nahvii
  if oX.SoulTear ~= d.OffsetX.SoulTear and oY.SoulTear ~= d.OffsetY.SoulTear
  then Hts_SoulTear:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.SoulTear, oY.SoulTear)
  else Hts_SoulTear:SetAnchor(CENTER, GuiRoot, CENTER, oX.SoulTear, oY.SoulTear) end

  --fire atro spawn
  if oX.Atro ~= d.OffsetX.Atro and oY.Atro ~= d.OffsetY.Atro
  then Hts_Atro:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Atro, oY.Atro)
  else Hts_Atro:SetAnchor(CENTER, GuiRoot, CENTER, oX.Atro, oY.Atro) end

  --portal wipe
  if oX.Wipe ~= d.OffsetX.Wipe and oY.Wipe ~= d.OffsetY.Wipe
  then Hts_Wipe:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Wipe, oY.Wipe)
  else Hts_Wipe:SetAnchor(CENTER, GuiRoot, CENTER, oX.Wipe, oY.Wipe) end

  --room explosion on last boss
  if oX.Storm ~= d.OffsetX.Storm and oY.Storm ~= d.OffsetY.Storm
  then Hts_Storm:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Storm, oY.Storm)
  else Hts_Storm:SetAnchor(CENTER, GuiRoot, CENTER, oX.Storm, oY.Storm) end

  --lava geyser
  if oX.Geyser ~= d.OffsetX.Geyser and oY.Geyser ~= d.OffsetY.Geyser
  then Hts_Geyser:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Geyser, oY.Geyser)
  else Hts_Geyser:SetAnchor(CENTER, GuiRoot, CENTER, oX.Geyser, oY.Geyser) end

  if oX.NextFlare ~= d.OffsetX.NextFlare and oY.NextFlare ~= d.OffsetY.NextFlare
  then Hts_NextFlare:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.NextFlare, oY.NextFlare)
  else Hts_NextFlare:SetAnchor(CENTER, GuiRoot, CENTER, oX.NextFlare, oY.NextFlare) end

  if oX.NextMeteor ~= d.OffsetX.NextMeteor and oY.NextMeteor ~= d.OffsetY.NextMeteor
  then Hts_NextMeteor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.NextMeteor, oY.NextMeteor)
  else Hts_NextMeteor:SetAnchor(CENTER, GuiRoot, CENTER, oX.NextMeteor, oY.NextMeteor) end

  if oX.Negate ~= d.OffsetX.Negate and oY.Negate ~= d.OffsetY.Negate
  then Hts_Negate:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Negate, oY.Negate)
  else Hts_Negate:SetAnchor(CENTER, GuiRoot, CENTER, oX.Negate, oY.Negate) end

  if oX.Shield ~= d.OffsetX.Shield and oY.Shield ~= d.OffsetY.Shield
  then Hts_Shield:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Shield, oY.Shield)
  else Hts_Shield:SetAnchor(CENTER, GuiRoot, CENTER, oX.Shield, oY.Shield) end

  --cataclysm
  if oX.Cata ~= d.OffsetX.Cata and oY.Cata ~= d.OffsetY.Cata
  then Hts_Cata:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Cata, oY.Cata)
  else Hts_Cata:SetAnchor(CENTER, GuiRoot, CENTER, oX.Cata, oY.Cata) end

  if oX.GlacialFist ~= d.OffsetX.GlacialFist and oY.GlacialFist ~= d.OffsetY.GlacialFist
  then Hts_GlacialFist:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.GlacialFist, oY.GlacialFist)
  else Hts_GlacialFist:SetAnchor(CENTER, GuiRoot, CENTER, oX.GlacialFist, oY.GlacialFist) end

  if oX.Stonefist ~= d.OffsetX.Stonefist and oY.Stonefist ~= d.OffsetY.Stonefist
  then Hts_Stonefist:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, oX.Stonefist, oY.Stonefist)
  else Hts_Stonefist:SetAnchor(CENTER, GuiRoot, CENTER, oX.Stonefist, oY.Stonefist) end

  -- Incoming Attacks
  HowToSunspire.SetFontSize(Hts_Ha_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Sweep_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Breath_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Block_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_PowerfulSlam_Label, sV.AlertSize)
  -- HowToSunspire.SetFontSize(Hts_HailOfStone_Label, sV.AlertSize)
  -- HowToSunspire.SetFontSize(Hts_Flare_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Spit_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Comet_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Thrash_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_SoulTear_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Geyser_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Negate_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Shield_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Leap_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_GlacialFist_Label, sV.AlertSize)
  HowToSunspire.SetFontSize(Hts_Stonefist_Label, sV.AlertSize)
  HowToSunspire.SetMeteorNameSize()

  -- Countdowns
  HowToSunspire.SetIceSize()
  HowToSunspire.SetFontSize(Hts_Portal_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Laser_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_HP_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Landing_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Atro_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Wipe_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Storm_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_NextFlare_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_NextMeteor_Label, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Cata_Label, sV.TimerSize)
end

function HowToSunspire.SetMeteorNameSize()
  local m = Hts_MeteorNames
  for k, label in pairs(m.labels) do
    HowToSunspire.SetFontSize(label, sV.AlertSize)
  end
  HowToSunspire.UpdateArrowSizes()
end

function HowToSunspire.UpdateArrowSizes()
  local m = Hts_MeteorNames
  local arrowRows = {
    [1] = 1,
    [2] = 1,
    [3] = 2,
    [4] = 2,
    [5] = 3,
    [6] = 3,
  }

  for i = 1, 6 do
    local size  = m.labels[arrowRows[i]]:GetTextHeight()
    local arrow = m.arrows[i]
    arrow:SetDimensions(size, size)
  end
end

function HowToSunspire.SetIceSize()
  HowToSunspire.SetFontSize(Hts_Ice_Title, sV.TimerSize)
  HowToSunspire.SetFontSize(Hts_Ice_Label1, sV.TimerSize - 5)
  HowToSunspire.SetFontSize(Hts_Ice_Label2, sV.TimerSize - 5)
end

function HowToSunspire.SetFontSize(label, size)
    local path = "EsoUI/Common/Fonts/univers67.otf"
    local outline = "soft-shadow-thick"
    label:SetFont(path .. "|" .. size .. "|" .. outline)
end

function HowToSunspire.SaveLoc_HA()
  oX.HA = Hts_Ha:GetLeft()
  oY.HA = Hts_Ha:GetTop()
end

function HowToSunspire.SaveLoc_Sweep()
  oX.SweepBreath = Hts_Sweep:GetLeft()
  oY.SweepBreath = Hts_Sweep:GetTop()
end

function HowToSunspire.SaveLoc_Breath()
  oX.Breath = Hts_Breath:GetLeft()
  oY.Breath = Hts_Breath:GetTop()
end

function HowToSunspire.SaveLoc_Block()
  oX.Block = Hts_Block:GetLeft()
  oY.Block = Hts_Block:GetTop()
end

function HowToSunspire.SaveLoc_Leap()
  oX.Leap = Hts_Leap:GetLeft()
  oY.Leap = Hts_Leap:GetTop()
end

function HowToSunspire.SaveLoc_PowerfulSlam()
  oX.PowerfulSlam = Hts_PowerfulSlam:GetLeft()
  oY.PowerfulSlam = Hts_PowerfulSlam:GetTop()
end

-- function HowToSunspire.SaveLoc_HailOfStone()
-- 	oX.HailOfStone = Hts_HailOfStone:GetLeft()
-- 	oY.HailOfStone = Hts_HailOfStone:GetTop()
-- end

-- function HowToSunspire.SaveLoc_Flare()
-- 	oX.Flare = Hts_Flare:GetLeft()
-- 	oY.Flare = Hts_Flare:GetTop()
-- end

function HowToSunspire.SaveLoc_Spit()
  oX.Spit = Hts_Spit:GetLeft()
  oY.Spit = Hts_Spit:GetTop()
end

function HowToSunspire.SaveLoc_Comet()
  oX.Comet = Hts_Comet:GetLeft()
  oY.Comet = Hts_Comet:GetTop()
end

function HowToSunspire.SaveLoc_MeteorNames()
  oX.MeteorName = Hts_MeteorNames:GetLeft()
  oY.MeteorName = Hts_MeteorNames:GetTop()
end

function HowToSunspire.SaveLoc_Thrash()
  oX.Thrash = Hts_Thrash:GetLeft()
  oY.Thrash = Hts_Thrash:GetTop()
end

function HowToSunspire.SaveLoc_SoulTear()
  oX.SoulTear = Hts_SoulTear:GetLeft()
  oY.SoulTear = Hts_SoulTear:GetTop()
end

function HowToSunspire.SaveLoc_Geyser()
  oX.Geyser = Hts_Geyser:GetLeft()
  oY.Geyser = Hts_Geyser:GetTop()
end

function HowToSunspire.SaveLoc_Negate()
  oX.Negate = Hts_Negate:GetLeft()
  oY.Negate = Hts_Negate:GetTop()
end

function HowToSunspire.SaveLoc_Shield()
  oX.Shield = Hts_Shield:GetLeft()
  oY.Shield = Hts_Shield:GetTop()
end

function HowToSunspire.SaveLoc_Portal()
  oX.Portal = Hts_Portal:GetLeft()
  oY.Portal = Hts_Portal:GetTop()
end

function HowToSunspire.SaveLoc_Ice()
  oX.IceTomb = Hts_Ice:GetLeft()
  oY.IceTomb = Hts_Ice:GetTop()
end

function HowToSunspire.SaveLoc_Laser()
  oX.LaserLokke = Hts_Laser:GetLeft()
  oY.LaserLokke = Hts_Laser:GetTop()
end

function HowToSunspire.SaveLoc_HP()
  oX.HP = Hts_HP:GetLeft()
  oY.HP = Hts_HP:GetTop()
end

function HowToSunspire.SaveLoc_Landing()
  oX.Landing = Hts_Landing:GetLeft()
  oY.Landing = Hts_Landing:GetTop()
end

function HowToSunspire.SaveLoc_Atro()
  oX.Atro = Hts_Atro:GetLeft()
  oY.Atro = Hts_Atro:GetTop()
end

function HowToSunspire.SaveLoc_Wipe()
  oX.Wipe = Hts_Wipe:GetLeft()
  oY.Wipe = Hts_Wipe:GetTop()
end

function HowToSunspire.SaveLoc_Storm()
  oX.Storm = Hts_Storm:GetLeft()
  oY.Storm = Hts_Storm:GetTop()
end

function HowToSunspire.SaveLoc_NextFlare()
  oX.NextFlare = Hts_NextFlare:GetLeft()
  oY.NextFlare = Hts_NextFlare:GetTop()
end

function HowToSunspire.SaveLoc_NextMeteor()
  oX.NextMeteor = Hts_NextMeteor:GetLeft()
  oY.NextMeteor = Hts_NextMeteor:GetTop()
end

function HowToSunspire.SaveLoc_Cata()
  oX.Cata = Hts_Cata:GetLeft()
  oY.Cata = Hts_Cata:GetTop()
end

function HowToSunspire.SaveLoc_GlacialFist()
  oX.Fist = Hts_GlacialFist:GetLeft()
  oY.Fist = Hts_GlacialFist:GetTop()
end

function HowToSunspire.SaveLoc_Stonefist()
  oX.Fist = Hts_Stonefist:GetLeft()
  oY.Fist = Hts_Stonefist:GetTop()
end
