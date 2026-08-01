HowToCloudrest = HowToCloudrest or {}
local HowToCloudrest = HowToCloudrest

local sV

function HowToCloudrest.InitUI()
    sV = HowToCloudrest.savedVariables

    ----------------------------------------------------------
    --                                                      --
    --                       GENERAL                        --
    --                                                      --
    ----------------------------------------------------------

    -------------------
    --  Heavy Attacks
    -------------------
    HTC_Ha:SetHidden(true)
    HTC_Ha:ClearAnchors()
    HTC_Ha:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.HA, sV.OffsetY.HA)

    -------------------

    -------------------
    --  Rooted (Creepers Razor Thorns & Sirorias Dark Talons)
    -------------------
    HTC_Rooted:SetHidden(true)
    HTC_Rooted:ClearAnchors()
    HTC_Rooted:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Rooted, sV.OffsetY.Rooted)

    -------------------

    -------------------
    --  Mini Frame
    -------------------
    HTC_MiniFrame:SetHidden(true)
    HTC_MiniFrame:ClearAnchors()
    HTC_MiniFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.MiniFrame, sV.OffsetY.MiniFrame)

    HowToCloudrest.SetSize_MiniFrame()
    HowToCloudrest.UpdateMiniFrame()
    -------------------

    -------------------
    --  Announcement Mini Bash (Relequens Direct Current & Galenwes Glacial Spikes)
    -------------------
    HTC_Announcement_MiniBash:SetHidden(true)
    HTC_Announcement_MiniBash:ClearAnchors()
    HTC_Announcement_MiniBash:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Announcement_MiniBash, sV.OffsetY.Announcement_MiniBash)

    -------------------


    ----------------------------------------------------------
    --                                                      --
    --                      SIRORIA                         --
    --                                                      --
    ----------------------------------------------------------
    HTC_Flare:SetHidden(true)
    HTC_Flare:ClearAnchors()
    HTC_Flare:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Flare, sV.OffsetY.Flare)

    ----------------------------------------------------------
    --                                                      --
    --                      RELEQUEN                        --
    --                                                      --
    ----------------------------------------------------------

    -------------------
    --  Relequen Heavy Attack (AOE)
    -------------------
    HTC_ReleHA:SetHidden(true)
    HTC_ReleHA:ClearAnchors()
    HTC_ReleHA:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.ReleHA, sV.OffsetY.ReleHA)

    -------------------

    -------------------
    --  Relequen Overload (Barswap)
    -------------------
    HTC_OverloadTimer:SetHidden(true)
    HTC_OverloadTimer:ClearAnchors()
    HTC_OverloadTimer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Overload, sV.OffsetY.Overload)

    local c = sV.overloadColor
    HowToCloudrest.SetOverloadOverlay(c[1], c[2], c[3])
    HTC_Overload:SetHidden(true)
    -------------------

    ----------------------------------------------------------
    --                                                      --
    --                      Galenwe                         --
    --                                                      --
    ----------------------------------------------------------

    -------------------
    --  Hoarfrost
    -------------------
    HTC_Hoarfrost:SetHidden(true)
    HTC_Hoarfrost:ClearAnchors()
    HTC_Hoarfrost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Hoarfrost, sV.OffsetY.Hoarfrost)
    -------------------

    -------------------
    --  ChillingComet
    -------------------
    HTC_ChillingComet:SetHidden(true)
    HTC_ChillingComet:ClearAnchors()
    HTC_ChillingComet:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.ChillingComet, sV.OffsetY.ChillingComet)
    -------------------


    ----------------------------------------------------------
    --                                                      --
    --                        PORTAL                        --
    --                                                      --
    ----------------------------------------------------------

    -------------------
    --  Portal Frame
    -------------------
    HTC_Portal:SetHidden(true)
    HTC_Portal:ClearAnchors()
    HTC_Portal:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Portal, sV.OffsetY.Portal)

    -------------------

    HTC_Portal_Announcement:SetHidden(true)
    HTC_Portal_Announcement:ClearAnchors()
    HTC_Portal_Announcement:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Portal_Announcement, sV.OffsetY.Portal_Announcement)

    -------------------
    -- Malevolent Cores (Fires a notification when orbs are found in portal)
    -------------------
    -- Add if Malevolent Cores needs own separate UI element
    -------------------

    -------------------
    -- Olorime Spears (Fires a notification when olorime spear has been sent)
    -------------------
    -- Add if Olorime Spears needs own separate UI element
    -------------------

    ----------------------------------------------------------
    --                                                      --
    --                      Z'Maja                          --
    --                                                      --
    ----------------------------------------------------------

    -------------------
    --  Z'Maja Jumping
    -------------------
    HTC_ZmajaJump:SetHidden(true)
    HTC_ZmajaJump:ClearAnchors()
    HTC_ZmajaJump:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.ZmajaJump, sV.OffsetY.ZmajaJump)

    -------------------

    -------------------
    -- Z'Maja's Crushing Darkness Kite (Kite on you)
    -------------------
    HTC_CrushingDarkness_Kite:SetHidden(true)
    HTC_CrushingDarkness_Kite:ClearAnchors()
    HTC_CrushingDarkness_Kite:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.CrushingDarkness_Kite, sV.OffsetY.CrushingDarkness_Kite)
    
    -------------------

    -------------------
    -- Z'Maja's Crushing Darkness Next (Time till next kite)
    -------------------
    HTC_CrushingDarkness_Next:SetHidden(true)
    HTC_CrushingDarkness_Next:ClearAnchors()
    HTC_CrushingDarkness_Next:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.CrushingDarkness_Next, sV.OffsetY.CrushingDarkness_Next)
    
    -------------------

    -------------------
    -- Z'Maja's Shadow Splash interrupt (Drop from ceiling)
    -------------------
    HTC_ShadowSplash:SetHidden(true)
    HTC_ShadowSplash:ClearAnchors()
    HTC_ShadowSplash:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.ShadowSplash, sV.OffsetY.ShadowSplash)

    -------------------

    -------------------
    -- Z'Maja's Baneful Mark during execute.
    -------------------
    HTC_BanefulMark:SetHidden(true)
    HTC_BanefulMark:ClearAnchors()
    HTC_BanefulMark:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.BanefulMark, sV.OffsetY.BanefulMark)

    -------------------

    -------------------
    -- Malicious Spheres
    -------------------
    HTC_MaliciousSphere_Timer:SetHidden(true)
    HTC_MaliciousSphere_Timer:ClearAnchors()
    HTC_MaliciousSphere_Timer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.MaliciousSphere_Timer, sV.OffsetY.MaliciousSphere_Timer)

    HTC_MaliciousSphere_Announcement:SetHidden(true)
    HTC_MaliciousSphere_Announcement:ClearAnchors()
    HTC_MaliciousSphere_Announcement:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.MaliciousSphere_Announcement, sV.OffsetY.MaliciousSphere_Announcement)

    HTC_MaliciousSphere_Tracking:SetHidden(true)
    HTC_MaliciousSphere_Tracking:ClearAnchors()
    HTC_MaliciousSphere_Tracking:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.MaliciousSphere_Tracking, sV.OffsetY.MaliciousSphere_Tracking)

    -------------------

    -------------------
    -- Creepers
    -------------------
    HTC_Creeper_Announcement:SetHidden(true)
    HTC_Creeper_Announcement:ClearAnchors()
    HTC_Creeper_Announcement:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Creeper_Announcement, sV.OffsetY.Creeper_Announcement)

    -------------------
    HowToCloudrest.SetAllFontSizes()
end

function HowToCloudrest.SetSize_MiniFrame()
  local TopRow_OffsetX = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].TopRow_OffsetX
  local TopRow_OffsetY = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].TopRow_OffsetY
  local Mini_OffsetX = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].Mini_OffsetX
  local Mini_OffsetY = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].Mini_OffsetY
  local fontSize = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].fontSize

  -- Top Row
  HTC_MiniFrame_TopRow:ClearAnchors()
  HTC_MiniFrame_TopRow:SetAnchor(TOPLEFT, HTC_MiniFrame, TOPLEFT, TopRow_OffsetX, TopRow_OffsetY)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_TopRow_Jump, fontSize - 2)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_TopRow_Bash, fontSize - 2)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_TopRow_Skill, fontSize - 2)

  -- Siroria Row
  HTC_MiniFrame_Siroria:ClearAnchors()
  HTC_MiniFrame_Siroria:SetAnchor(TOPLEFT, HTC_MiniFrame, TOPLEFT, Mini_OffsetX, Mini_OffsetY)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Siroria_Title, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Siroria_Jump, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Siroria_Bash, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Siroria_Skill, fontSize)

  -- Relequen Row
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Relequen_Title, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Relequen_Jump, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Relequen_Bash, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Relequen_Skill, fontSize)

  -- Galenwe Row
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Galenwe_Title, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Galenwe_Jump, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Galenwe_Bash, fontSize)
  HowToCloudrest.SetFontSize(HTC_MiniFrame_Galenwe_Skill, fontSize)

end

function HowToCloudrest.SetAllFontSizes()
  -- General
  HowToCloudrest.SetFontSize(HTC_Ha_Label, sV.FontSize_HA)
  HowToCloudrest.SetFontSize(HTC_Rooted_Label, sV.FontSize_Rooted)
  HowToCloudrest.SetFontSize(HTC_Announcement_MiniBash_Label, sV.FontSize_BashAnnouncement)

  -- Siroria
  HowToCloudrest.SetFontSize(HTC_Flare_Label, sV.FontSize_Flare)

  -- Relequen
  HowToCloudrest.SetFontSize(HTC_ReleHA_Label, sV.FontSize_ReleHA)
  HowToCloudrest.SetFontSize(HTC_OverloadTimer_Label, sV.FontSize_Overload)

  -- Galenwe
  HowToCloudrest.SetFontSize(HTC_Hoarfrost_Label, sV.FontSize_Hoarfrost)
  HowToCloudrest.SetFontSize(HTC_ChillingComet_Label, sV.FontSize_ChillingComet)

  -- Portal
  HowToCloudrest.SetFontSize(HTC_Portal_Label, sV.FontSize_Portal)
  HowToCloudrest.SetFontSize(HTC_Portal_Announcement_Label, sV.FontSize_Portal_Announcement)

  -- Z'maja
  HowToCloudrest.SetFontSize(HTC_ZmajaJump_Label, sV.FontSize_ZmajaJump)

  HowToCloudrest.SetFontSize(HTC_CrushingDarkness_Kite_Label, sV.FontSize_CrushingDarkness_Kite)
  HowToCloudrest.SetFontSize(HTC_CrushingDarkness_Next_Label, sV.FontSize_CrushingDarkness_Next)

  HowToCloudrest.SetFontSize(HTC_ShadowSplash_Label, sV.FontSize_ShadowSplash)
  HowToCloudrest.SetFontSize(HTC_BanefulMark_Label, sV.FontSize_BanefulMark)

  HowToCloudrest.SetFontSize(HTC_MaliciousSphere_Timer_Label, sV.FontSize_MaliciousSphere_Timer)
  HowToCloudrest.SetFontSize(HTC_MaliciousSphere_Announcement_Label, sV.FontSize_MaliciousSphere_Announcement)
  
  local orb_size = sV.FontSize_MaliciousSphere_Tracking
  HTC_MaliciousSphere_Tracking_1:SetDimensions(orb_size, orb_size) -- SetDimensions(X,Y)
  HTC_MaliciousSphere_Tracking_2:SetDimensions(orb_size, orb_size) -- SetDimensions(X,Y)
  HTC_MaliciousSphere_Tracking_3:SetDimensions(orb_size, orb_size) -- SetDimensions(X,Y)

  HowToCloudrest.SetFontSize(HTC_Creeper_Announcement_Label, sV.FontSize_Creeper_Announcement)
end

function HowToCloudrest.SetFontSize(label, size)
	local path = "EsoUI/Common/Fonts/univers67.otf"
    local outline = "soft-shadow-thick"
    label:SetFont(path .. "|" .. size .. "|" .. outline)
end

function HowToCloudrest.SetOverloadOverlay(r,g,b)
    HTC_Overload_TextureBot:SetGradientColors(ORIENTATION_VERTICAL, r, g, b, 0.33, 0, 0, 0, 0) --bas
    HTC_Overload_TextureLeft:SetGradientColors(ORIENTATION_HORIZONTAL, r, g, b, 0.33, 0, 0, 0, 0) --gauche
    HTC_Overload_TextureTop:SetGradientColors(ORIENTATION_VERTICAL, 0, 0, 0, 0, r, g, b, 0.33) --haut
    HTC_Overload_TextureRight:SetGradientColors(ORIENTATION_HORIZONTAL, 0, 0, 0, 0, r, g, b, 0.33) --droite
end

-- General
function HowToCloudrest.SaveLoc_HA()
	sV.OffsetX.HA = HTC_Ha:GetLeft()
	sV.OffsetY.HA = HTC_Ha:GetTop()
end

function HowToCloudrest.SaveLoc_Rooted()
	sV.OffsetX.Rooted = HTC_Rooted:GetLeft()
	sV.OffsetY.Rooted = HTC_Rooted:GetTop()
end

function HowToCloudrest.SaveLoc_Announcement_MiniBash()
	sV.OffsetX.Announcement_MiniBash = HTC_Announcement_MiniBash:GetLeft()
	sV.OffsetY.Announcement_MiniBash = HTC_Announcement_MiniBash:GetTop()
end

function HowToCloudrest.SaveLoc_MiniFrame()
	sV.OffsetX.MiniFrame = HTC_MiniFrame:GetLeft()
	sV.OffsetY.MiniFrame = HTC_MiniFrame:GetTop()
end

-- Siroria
function HowToCloudrest.SaveLoc_Flare()
	sV.OffsetX.Flare = HTC_Flare:GetLeft()
	sV.OffsetY.Flare = HTC_Flare:GetTop()
end

-- Relequen
function HowToCloudrest.SaveLoc_ReleHA()
	sV.OffsetX.ReleHA = HTC_ReleHA:GetLeft()
	sV.OffsetY.ReleHA = HTC_ReleHA:GetTop()
end

function HowToCloudrest.SaveLoc_Overload()
	sV.OffsetX.Overload = HTC_OverloadTimer:GetLeft()
	sV.OffsetY.Overload = HTC_OverloadTimer:GetTop()
end

-- Galenwe
function HowToCloudrest.SaveLoc_Hoarfrost()
  sV.OffsetX.Hoarfrost = HTC_Hoarfrost:GetLeft()
  sV.OffsetY.Hoarfrost = HTC_Hoarfrost:GetTop()
end

function HowToCloudrest.SaveLoc_ChillingComet()
  sV.OffsetX.ChillingComet = HTC_ChillingComet:GetLeft()
  sV.OffsetY.ChillingComet = HTC_ChillingComet:GetTop()
end

-- Portal
function HowToCloudrest.SaveLoc_Portal()
  sV.OffsetX.Portal = HTC_Portal:GetLeft()
  sV.OffsetY.Portal = HTC_Portal:GetTop()
end

function HowToCloudrest.SaveLoc_Portal_Announcement()
  sV.OffsetX.Portal_Announcement = HTC_Portal_Announcement:GetLeft()
  sV.OffsetY.Portal_Announcement = HTC_Portal_Announcement:GetTop()
end

-- Z'maja
function HowToCloudrest.SaveLoc_ZmajaJump()
	sV.OffsetX.ZmajaJump = HTC_ZmajaJump:GetLeft()
	sV.OffsetY.ZmajaJump = HTC_ZmajaJump:GetTop()
end

function HowToCloudrest.SaveLoc_CrushingDarkness_Kite()
  sV.OffsetX.CrushingDarkness_Kite = HTC_CrushingDarkness_Kite:GetLeft()
  sV.OffsetY.CrushingDarkness_Kite = HTC_CrushingDarkness_Kite:GetTop()
end

function HowToCloudrest.SaveLoc_CrushingDarkness_Next()
  sV.OffsetX.CrushingDarkness_Next = HTC_CrushingDarkness_Next:GetLeft()
  sV.OffsetY.CrushingDarkness_Next = HTC_CrushingDarkness_Next:GetTop()
end

function HowToCloudrest.SaveLoc_ShadowSplash()
  sV.OffsetX.ShadowSplash = HTC_ShadowSplash:GetLeft()
  sV.OffsetY.ShadowSplash = HTC_ShadowSplash:GetTop()
end

function HowToCloudrest.SaveLoc_BanefulMark()
  sV.OffsetX.BanefulMark = HTC_BanefulMark:GetLeft()
  sV.OffsetY.BanefulMark = HTC_BanefulMark:GetTop()
end

function HowToCloudrest.SaveLoc_MaliciousSphere_Timer()
  sV.OffsetX.MaliciousSphere_Timer = HTC_MaliciousSphere_Timer:GetLeft()
  sV.OffsetY.MaliciousSphere_Timer = HTC_MaliciousSphere_Timer:GetTop()
end

function HowToCloudrest.SaveLoc_MaliciousSphere_Announcement()
  sV.OffsetX.MaliciousSphere_Announcement = HTC_MaliciousSphere_Announcement:GetLeft()
  sV.OffsetY.MaliciousSphere_Announcement = HTC_MaliciousSphere_Announcement:GetTop()
end

function HowToCloudrest.SaveLoc_MaliciousSphere_Tracking()
  sV.OffsetX.MaliciousSphere_Tracking = HTC_MaliciousSphere_Tracking:GetLeft()
  sV.OffsetY.MaliciousSphere_Tracking = HTC_MaliciousSphere_Tracking:GetTop()
end

function HowToCloudrest.SaveLoc_Creeper_Announcement()
  sV.OffsetX.Creeper_Announcement = HTC_Creeper_Announcement:GetLeft()
  sV.OffsetY.Creeper_Announcement = HTC_Creeper_Announcement:GetTop()
end

function HowToCloudrest.SetDefaultUIValues()

  -- General
  HTC_Rooted_Label:SetText(HTC.Color.red(">>ROOTED<<"))

  HowToCloudrest.SetMiniFrameDefault()
  HTC_Announcement_MiniBash_Label:SetText(HTC.String.Announcement_ReleBash_4 .. " / " .. HTC.String.Announcement_GaleBash_4)

  -- Siroria
  HTC_Flare_Label:SetText(HTC.String.Flare .. HTC.Color.red("4.2"))

  -- Relequen
  HTC_ReleHA_Label:SetText(HTC.String.ReleHA .. HTC.Color.red("1.2"))
  HTC_OverloadTimer_Label:SetText(HTC.String.Overload_Incoming .. HTC.Color.red("1.6"))

  -- Galenwe
  HTC_Hoarfrost_Label:SetText(HTC.String.Hoarfrost_Base .. HTC.Color.red("2"))
  HTC_ChillingComet_Label:SetText(HTC.String.ChillingComet_Base .. HTC.Color.red("1.3"))

  -- Portal
  HTC_Portal_Label:SetText(HTC.String.Portal_Closed_1 .. HTC.Color.portalOne("1") .. HTC.String.Portal_Closed_2 .. HTC.Color.green("42"))
  HTC_Portal_Announcement_Label:SetText(HTC.String.Portal_Announcement_1 .. HTC.Color.portalOne("1") .. HTC.String.Portal_Announcement_2)

  -- Z'maja
  HTC_ZmajaJump_Label:SetText(HTC.String.ZMaja_Jump_Base .. HTC.Color.green("12"))

  HTC_CrushingDarkness_Kite_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Kite_Base .. HTC.Color.red("10"))
  HTC_CrushingDarkness_Next_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Next_Base .. HTC.Color.green("10"))

  HTC_ShadowSplash_Label:SetText(HTC.String.ZMaja_Bash_Cast_1)
  HTC_BanefulMark_Label:SetText(HTC.String.ZMaja_BanefulMark_Base .. HTC.Color.green("20"))

  HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Next .. HTC.Color.green("16"))
  HTC_MaliciousSphere_Announcement_Label:SetText(HTC.String.Zmaja_MaliciousSphere_OrbSpawning)
  
  HTC_MaliciousSphere_Tracking_1:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
  HTC_MaliciousSphere_Tracking_2:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
  HTC_MaliciousSphere_Tracking_3:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
  
  HTC_Creeper_Announcement_Label:SetText(HTC.String.Zmaja_CreeperSpawning)
end

function HowToCloudrest.SetMiniFrameDefault()

  HTC_MiniFrame_Siroria_Jump:SetText(HTC.Color.green("23"))
  HTC_MiniFrame_Siroria_Bash:SetText("-")
  HTC_MiniFrame_Siroria_Skill:SetText(HTC.Color.green("45"))

  HTC_MiniFrame_Relequen_Jump:SetText(HTC.Color.green("19"))
  HTC_MiniFrame_Relequen_Bash:SetText(HTC.Color.green("15"))
  HTC_MiniFrame_Relequen_Skill:SetText(HTC.Color.green("15"))

  HTC_MiniFrame_Galenwe_Jump:SetText(HTC.Color.green("19"))
  HTC_MiniFrame_Galenwe_Bash:SetText(HTC.Color.green("22"))
  HTC_MiniFrame_Galenwe_Skill:SetText(HTC.Color.green("22"))

  local siroShowOld = HTC.siroShow
  local releShowOld = HTC.releShow
  local galeShowOld = HTC.galeShow
  HTC.siroShow = true
  HTC.releShow = true
  HTC.galeShow = true

  HowToCloudrest.UpdateMiniFrame()

  HTC.siroShow = siroShowOld
  HTC.releShow = releShowOld
  HTC.galeShow = galeShowOld
end

-------------------
--  Update MiniFrame (Redraws the MiniFrame depending on the settings selected and what minis are alive)
-------------------
function HowToCloudrest.UpdateMiniFrame()
  local Mini_OffsetX = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].Mini_OffsetX
  local Mini_OffsetY = HowToCloudrest.Default.Sizes_MiniFrame[sV.Size_MiniFrame].Mini_OffsetY

  -- Draw the Jump column in the Mini Frame if it's enabled.
  if sV.Enable.MiniJump then
      HTC_MiniFrame_TopRow_Jump:SetHidden(false)
      HTC_MiniFrame_Siroria_Jump:SetHidden(false)
      HTC_MiniFrame_Relequen_Jump:SetHidden(false)
      HTC_MiniFrame_Galenwe_Jump:SetHidden(false)

      HTC_MiniFrame_TopRow_Bash:ClearAnchors()
      HTC_MiniFrame_TopRow_Bash:SetAnchor(TOPLEFT, HTC_MiniFrame_TopRow_Jump, TOPRIGHT, 10, 0)

      HTC_MiniFrame_TopRow_Skill:ClearAnchors()
      HTC_MiniFrame_TopRow_Skill:SetAnchor(TOPLEFT, HTC_MiniFrame_TopRow_Jump, TOPRIGHT, 10, 0)
  else
      HTC_MiniFrame_TopRow_Jump:SetHidden(true)
      HTC_MiniFrame_Siroria_Jump:SetHidden(true)
      HTC_MiniFrame_Relequen_Jump:SetHidden(true)
      HTC_MiniFrame_Galenwe_Jump:SetHidden(true)

      HTC_MiniFrame_TopRow_Bash:ClearAnchors()
      HTC_MiniFrame_TopRow_Bash:SetAnchor(TOPLEFT, HTC_MiniFrame_TopRow, TOPLEFT, 0, 0)

      HTC_MiniFrame_TopRow_Skill:ClearAnchors()
      HTC_MiniFrame_TopRow_Skill:SetAnchor(TOPLEFT, HTC_MiniFrame_TopRow, TOPLEFT, 0, 0)
  end

  -- Draw the Bash column in the Mini Frame if it's enabled.
  if sV.Enable.MiniBash then
      HTC_MiniFrame_TopRow_Bash:SetHidden(false)
      HTC_MiniFrame_Siroria_Bash:SetHidden(false)
      HTC_MiniFrame_Relequen_Bash:SetHidden(false)
      HTC_MiniFrame_Galenwe_Bash:SetHidden(false)

      HTC_MiniFrame_TopRow_Skill:ClearAnchors()
      HTC_MiniFrame_TopRow_Skill:SetAnchor(TOPLEFT, HTC_MiniFrame_TopRow_Bash, TOPRIGHT, 10, 0)
  else
      HTC_MiniFrame_TopRow_Bash:SetHidden(true)
      HTC_MiniFrame_Siroria_Bash:SetHidden(true)
      HTC_MiniFrame_Relequen_Bash:SetHidden(true)
      HTC_MiniFrame_Galenwe_Bash:SetHidden(true)
  end

  -- Draw the Skill column in the Mini Frame if it's enabled.
  if sV.Enable.MiniSkill then
      HTC_MiniFrame_TopRow_Skill:SetHidden(false)
      HTC_MiniFrame_Siroria_Skill:SetHidden(false)
      HTC_MiniFrame_Relequen_Skill:SetHidden(false)
      HTC_MiniFrame_Galenwe_Skill:SetHidden(false)
  else
      HTC_MiniFrame_TopRow_Skill:SetHidden(true)
      HTC_MiniFrame_Siroria_Skill:SetHidden(true)
      HTC_MiniFrame_Relequen_Skill:SetHidden(true)
      HTC_MiniFrame_Galenwe_Skill:SetHidden(true)
  end

  -- Draw Siroria row if she's alive and active in the encounter.
  if HTC.siroShow then
      HTC_MiniFrame_Siroria:SetHidden(false)

      HTC_MiniFrame_Siroria:ClearAnchors()
      HTC_MiniFrame_Siroria:SetAnchor(TOPLEFT, HTC_MiniFrame, TOPLEFT, Mini_OffsetX, Mini_OffsetY)
      HTC_MiniFrame_Siroria_Jump:ClearAnchors()
      HTC_MiniFrame_Siroria_Jump:SetAnchor(TOP, HTC_MiniFrame_TopRow_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Siroria_Bash:ClearAnchors()
      HTC_MiniFrame_Siroria_Bash:SetAnchor(TOP, HTC_MiniFrame_TopRow_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Siroria_Skill:ClearAnchors()
      HTC_MiniFrame_Siroria_Skill:SetAnchor(TOP, HTC_MiniFrame_TopRow_Skill, BOTTOM, 0, 0)

      HTC_MiniFrame_Relequen:ClearAnchors()
      HTC_MiniFrame_Relequen:SetAnchor(TOPLEFT, HTC_MiniFrame_Siroria, BOTTOMLEFT, 0, 0)
      HTC_MiniFrame_Relequen_Jump:ClearAnchors()
      HTC_MiniFrame_Relequen_Jump:SetAnchor(TOP, HTC_MiniFrame_Siroria_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Relequen_Bash:ClearAnchors()
      HTC_MiniFrame_Relequen_Bash:SetAnchor(TOP, HTC_MiniFrame_Siroria_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Relequen_Skill:ClearAnchors()
      HTC_MiniFrame_Relequen_Skill:SetAnchor(TOP, HTC_MiniFrame_Siroria_Skill, BOTTOM, 0, 0)

      HTC_MiniFrame_Galenwe:ClearAnchors()
      HTC_MiniFrame_Galenwe:SetAnchor(TOPLEFT, HTC_MiniFrame_Siroria, BOTTOMLEFT, 0, 0)
      HTC_MiniFrame_Galenwe_Jump:ClearAnchors()
      HTC_MiniFrame_Galenwe_Jump:SetAnchor(TOP, HTC_MiniFrame_Siroria_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Bash:ClearAnchors()
      HTC_MiniFrame_Galenwe_Bash:SetAnchor(TOP, HTC_MiniFrame_Siroria_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Skill:ClearAnchors()
      HTC_MiniFrame_Galenwe_Skill:SetAnchor(TOP, HTC_MiniFrame_Siroria_Skill, BOTTOM, 0, 0)
  else
      HTC_MiniFrame_Siroria:SetHidden(true)

      HTC_MiniFrame_Relequen:ClearAnchors()
      HTC_MiniFrame_Relequen:SetAnchor(TOPLEFT, HTC_MiniFrame, TOPLEFT, Mini_OffsetX, Mini_OffsetY)
      HTC_MiniFrame_Relequen_Jump:ClearAnchors()
      HTC_MiniFrame_Relequen_Jump:SetAnchor(TOP, HTC_MiniFrame_TopRow_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Relequen_Bash:ClearAnchors()
      HTC_MiniFrame_Relequen_Bash:SetAnchor(TOP, HTC_MiniFrame_TopRow_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Relequen_Skill:ClearAnchors()
      HTC_MiniFrame_Relequen_Skill:SetAnchor(TOP, HTC_MiniFrame_TopRow_Skill, BOTTOM, 0, 0)

      HTC_MiniFrame_Galenwe:ClearAnchors()
      HTC_MiniFrame_Galenwe:SetAnchor(TOPLEFT, HTC_MiniFrame, TOPLEFT, Mini_OffsetX, Mini_OffsetY)
      HTC_MiniFrame_Galenwe_Jump:ClearAnchors()
      HTC_MiniFrame_Galenwe_Jump:SetAnchor(TOP, HTC_MiniFrame_TopRow_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Bash:ClearAnchors()
      HTC_MiniFrame_Galenwe_Bash:SetAnchor(TOP, HTC_MiniFrame_TopRow_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Skill:ClearAnchors()
      HTC_MiniFrame_Galenwe_Skill:SetAnchor(TOP, HTC_MiniFrame_TopRow_Skill, BOTTOM, 0, 0)
  end

  -- Draw Relequen row if he's alive and active in the encounter.
  if HTC.releShow then
      HTC_MiniFrame_Relequen:SetHidden(false)

      HTC_MiniFrame_Galenwe:ClearAnchors()
      HTC_MiniFrame_Galenwe:SetAnchor(TOPLEFT, HTC_MiniFrame_Relequen, BOTTOMLEFT, 0, 0)
      HTC_MiniFrame_Galenwe_Jump:ClearAnchors()
      HTC_MiniFrame_Galenwe_Jump:SetAnchor(TOP, HTC_MiniFrame_Relequen_Jump, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Bash:ClearAnchors()
      HTC_MiniFrame_Galenwe_Bash:SetAnchor(TOP, HTC_MiniFrame_Relequen_Bash, BOTTOM, 0, 0)
      HTC_MiniFrame_Galenwe_Skill:ClearAnchors()
      HTC_MiniFrame_Galenwe_Skill:SetAnchor(TOP, HTC_MiniFrame_Relequen_Skill, BOTTOM, 0, 0)
  else
      HTC_MiniFrame_Relequen:SetHidden(true)
  end

  -- Draw Galenwe row if he's alive and active in the encounter.
  if HTC.galeShow then
      HTC_MiniFrame_Galenwe:SetHidden(false)
  else
      HTC_MiniFrame_Galenwe:SetHidden(true)
  end

  if not HTC_MiniFrame:IsHidden() then
      HTC_MiniFrame:SetHidden(true)
      HTC_MiniFrame:SetHidden(false)
  end

end