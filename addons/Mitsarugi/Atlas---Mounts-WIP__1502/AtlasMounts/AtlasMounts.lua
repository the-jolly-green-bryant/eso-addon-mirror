
local AtlasMounts = nil -- this may seem odd, but it sets the access level for "AtlasMounts"
local wm = GetWindowManager() -- we want to use whatever window manager the game is
local strformat = string.format -- shortcut
local round = zo_round -- shortcut
local lblCounter = nil -- set access level for the label to display our counter
local ClickedCount = 0 -- start off with the counter at 0
 
local function loadCC()
   
  AtlasMountsIcon = wm:CreateControl("AtlasMountsIcon",  AtlasWindow, CT_TEXTURE)
  AtlasMountsIcon:SetDimensions(60,60)
  AtlasMountsIcon:SetAnchor(TOPLEFT, AtlasWindow, nil, 660, 90)
  AtlasMountsIcon:SetTexture("esoui/art/treeicons/tutorial_idexicon_mounts_up.dds")
  AtlasMountsIcon:SetDrawLayer(3)

--=====================================================================================  
--Mounts Button
--=====================================================================================
  
  --Button Declaration
  local AtlasMountsIconBtn = wm:CreateControl(nil, AtlasWindow, CT_BUTTON)
  AtlasMountsIconBtn:SetAnchorFill(AtlasMountsIcon)
  AtlasMountsIconBtn:SetDimensions(25, 25)

  --Button Is Clicked
  AtlasMountsIconBtn:SetHandler("OnClicked", 
  function() 
  AtlasPlaceTitle1:SetText("Bears")
  AtlasPlaceTitle2:SetText("Camels")
  AtlasListTitleText:SetText("Mounts")
  MapPiece1:SetHidden(true)
  MapPiece2:SetHidden(true)
  MapPiece3:SetHidden(true)
  MapPiece4:SetHidden(true)
  MapPiece5:SetHidden(true)
  MapPiece6:SetHidden(true)
  MapPiece7:SetHidden(true)
  MapPiece8:SetHidden(true) 
  MapPiece9:SetHidden(true)
  AtlasMapBackGroundDummy:SetHidden(true)
  AtlasMapBackGround:SetHidden(true)
  AtlasMountsPictureTexture:SetHidden(false)
  AtlasDelvesIcon:SetHidden(true)
  AtlasGroupDelvesIcon:SetHidden(true)
  AtlasGroupDungeonsIcon:SetHidden(true)
  AtlasTrailsIcon:SetHidden(true)
  AtlasPublicDungeonsIcon:SetHidden(true)
  AtlasCrownStore:SetHidden(true)
  AtlasFastTravel:SetHidden(true)
  AtlasDungeonRankNor:SetHidden(true)
  AtlasDungeonRankVet:SetTexture("esoui/art/icons/mounticon_bear_b.dds")
  AtlasMapTitleIcon:SetHidden(true)
  AtlasMapTitle:SetHidden(true)
  AtlasMapLevel:SetText("Black Bear")
  AtlasFactionHeaderIconTexture:SetHidden(true)
  AtlasFactionHeaderRightTexture:SetTexture("AtlasDelves&Dungeons/Art/overview_scoringbg_neutral_right.dds")
  AtlasFactionHeaderLeftTexture:SetTexture("AtlasDelves&Dungeons/Art/overview_scoringbg_neutral_left.dds")
  AtlasAldmeriTexture:SetDimensions(80,110)
  AtlasDaggerfallTexture:SetDimensions(80,110)
  AtlasEbonheartTexture:SetDimensions(80,110)
  AtlasNeutralTexture:SetDimensions(80,150)
  AtlasNeutralIconTexture:SetAnchor(TOPLEFT, AtlasWindow, nil, 253, 75)
  AtlasFactionSelectedTexture:SetHidden(false)
  AtlasFactionSelectedTexture:SetAnchor(TOPLEFT, AtlasWindow, nil, 220, 35)
  AtlasPlaceName1:SetText("Black Bear")
  AtlasPlaceName2:SetText("Cave Bear")
  AtlasPlaceName3:SetText("Masked Bear")
  AtlasPlaceName4:SetText("Skeletal Bear")
  AtlasPlaceName5:SetText("Snow Bear")
  AtlasPlaceName6:SetText("Wild Hunt Bear")
  --esoui/art/store/gamepad/gp_crwn_mounts_atronachbear_1x1.dds
  
  AtlasPlaceName7:SetText("Black Camel of Ill Omen")
  AtlasPlaceName8:SetText("Hammerfell Camel")
  AtlasPlaceName9:SetText("")
  AtlasPlaceName10:SetText("")
  AtlasPlaceName11:SetText("")
  AtlasPlaceName12:SetText("")
  PlaySound(SOUNDS.MAP_PING)
  d("Hey")
  end)
   
  --Button Is Entered   
  AtlasMountsIconBtn:SetHandler("OnMouseEnter", 
  function(self)
    AtlasToolTipCreator(AtlasMountsIconBtn,"Display Mounts", true)
	AtlasMountsIcon:SetTexture("esoui/art/treeicons/tutorial_idexicon_mounts_over.dds")
  end)

  --Button Is Exited	  
  AtlasMountsIconBtn:SetHandler("OnMouseExit", 
  function(self)
    AtlasToolTipCreator(AtlasMountsIconBtn)
	AtlasMountsIcon:SetTexture("esoui/art/treeicons/tutorial_idexicon_mounts_up.dds")
  end)

--=====================================================================================  
--Mount Picture
--=====================================================================================
    
  local AtlasMountsPictureTexture = wm:CreateControl("AtlasMountsPictureTexture",  AtlasWindow, CT_TEXTURE)
  AtlasMountsPictureTexture:SetDimensions(512,512)
  AtlasMountsPictureTexture:SetAnchor(RIGHT, AtlasWindow, nil, 0, 100)
  AtlasMountsPictureTexture:SetTexture("AtlasMounts/Pictures/gp_crwn_mounts_bearblack_1x1.dds")
  AtlasMountsPictureTexture:SetDrawLayer(3)
  AtlasMountsPictureTexture:SetHidden(true)

  EVENT_MANAGER:UnregisterForEvent("Click Counter", EVENT_ADD_ON_LOADED)
 
  -- and end the init function
end
 
EVENT_MANAGER:RegisterForEvent("Click Counter", EVENT_ADD_ON_LOADED, loadCC)

 





  

