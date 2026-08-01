PJD.debuffTrackers = {
  { name = "Immune", shortCode = "Im", color = "#FFFFFF", abilityIds = {52788} },
  { name = "Alkosh", shortCode = "AL", color = "#13E8AE", abilityIds = {75753} },
  { name = "Crusher", shortCode = "CR", color = "#FEDC00", abilityIds = {17906} },
  { name = "Major Breach", shortCode = "MB", color = "#F0A20B", abilityIds = {61743} },
  { name = "Minor Breach", shortCode = "mB", color = "#C82246", abilityIds = {61742} },
  { name = "Minor Magickasteal", shortCode = "mMg", color = "#C86E4C", abilityIds = {39100, 88401} },
  { name = "Weakening", shortCode = "WK", color = "#F6D55C", abilityIds = {17945} },
  { name = "Minor Brittle", shortCode = "mBr", color = "#83D6DE", abilityIds = {145975} },
  { name = "Minor Maim", shortCode = "mMa", color = "#C0392B", abilityIds = {61723} },
  { name = "Major Maim", shortCode = "MMa", color = "#E74C3C", abilityIds = {61725} },
  { name = "Morag Tong", shortCode = "MoT", color = "#B8E994", abilityIds = {34384} },
  { name = "Engulfing Flames", shortCode = "EF", color = "#FA8231", abilityIds = {31104} },
  { name = "Minor Vulnerability", shortCode = "mV", color = "#2ECC71", abilityIds = {79717} },
}

PJD.abilityIdLookup = {}

function PJD.BuildTauntTracker()
  if not PJD.SV.trackers["Taunt"] then return end
  local tauntLabel = CreateControl("PJD_GridTaunt", PJD_Grid, CT_LABEL)
  tauntLabel:SetFont("PJD_FontLarge")
  tauntLabel:SetText("0")
  tauntLabel:SetColor(1, 1, 1, 1)
  tauntLabel:SetAnchor(LEFT, PJD_Grid, LEFT, 40, 0)

  PJD.abilityIdLookup[38254] = "Taunt"
end

function PJD.HexToRGB(hex)
    local hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function PJD.GetDebuffPosition(index)
  local x = 115 + (55 * math.floor(index / 3))
  local y = -30 + (30 * (index % 3))

  return x, y
end

function PJD.BuildDebuffTrackers()
  PJD.BuildTauntTracker()

  local index = 0
  for _, debuff in ipairs(PJD.debuffTrackers) do
    if PJD.SV.trackers[debuff.shortCode] then
      local debuffLabel = CreateControl("PJD_Grid" .. debuff.shortCode, PJD_Grid, CT_LABEL)
      debuffLabel:SetFont("PJD_FontMedium")
      debuffLabel:SetText(debuff.shortCode)

      local r, g, b = PJD.HexToRGB(debuff.color)
      debuffLabel:SetColor(r/255, g/255, b/255, 1)

      local x, y = PJD.GetDebuffPosition(index)
      debuffLabel:SetAnchor(LEFT, PJD_Grid, LEFT, x, y)

      for _, abilityId in ipairs(debuff.abilityIds) do
        PJD.abilityIdLookup[abilityId] = debuff.shortCode
      end
      index = index + 1
    end
  end
end
