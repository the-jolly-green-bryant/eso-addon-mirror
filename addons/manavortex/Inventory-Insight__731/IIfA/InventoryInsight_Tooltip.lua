local LMP = LibMediaProvider

IIfA.LastActiveRowControl = nil

local function p(...)
  -- Ensure IIfA and its debug function are properly initialized
  if not IIfA or not IIfA.DebugOut then return end

  -- Ensure debug mode is enabled
  if not IIFA_DATABASE[IIfA.currentAccount].settings.bDebug then return end

  IIfA:DebugOut(...)
end

function IIfA:addStatsPopupTooltip(...)
  d("IIFA - Popup tooltip OnUpdate hit")
  d(...)
end

function IIfA:CreateTooltips()
  WINDOW_MANAGER:CreateControlFromVirtual("IIFA_ITEM_TOOLTIP", ItemTooltipTopLevel, "IIFA_ITEM_TOOLTIP")
  WINDOW_MANAGER:CreateControlFromVirtual("IIFA_POPUP_TOOLTIP", PopupTooltipTopLevel, "IIFA_POPUP_TOOLTIP")

  ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
  ZO_PreHookHandler(PopupTooltip, 'OnHide', IIfA_HideTooltip)

  ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
  ZO_PreHookHandler(ItemTooltip, 'OnHide', IIfA_HideTooltip)

  ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink)
    local accountSettings = IIFA_DATABASE[IIfA.currentAccount].settings
    if accountSettings.bDebug then
      IIfA:dm("Debug", "A hook to ZO_PopupTooltip_SetLink occured .")
      local core, display = itemLink:match("^|H([^|]+)|h(.-)|h$")
      if core then
        -- IIfA:dm("Debug", string.format("[CreateTooltips] --%s--%s--", core, (display and display ~= "" and display) or ""))
      else
        -- IIfA:dm("Debug", string.format("[CreateTooltips] --RAW--%s--", itemLink))
      end
    end

    IIfA.TooltipLink = itemLink
  end)
end

local function SetDefaultFontIfNotFound()
  local fontFound = false
  local accountSettings = IIFA_DATABASE[IIfA.currentAccount].settings
  local currentFont = accountSettings.TooltipFontFace
  local fontChoices = LMP:List(LMP.MediaType.FONT)

  -- Loop through the fontChoices to check if currentFont is found
  for _, fontName in pairs(fontChoices) do
    if fontName == currentFont then
      fontFound = true
      break
    end
  end

  -- If currentFont is not found, set it to the default value
  if not fontFound then
    accountSettings.TooltipFontFace = IIfA.defaults_account.TooltipFontFace
  end
end

-- /script d(_G["ZoFontGame"]:GetFontInfo())
function IIfA:SetTooltipFont()
  SetDefaultFontIfNotFound()

  -- Access account settings
  local accountSettings = IIFA_DATABASE[IIfA.currentAccount].settings
  local fontFace = accountSettings.TooltipFontFace
  local fontSize = tonumber(accountSettings.TooltipFontSize)
  local fontEffect = string.lower(accountSettings.TooltipFontEffect)

  -- Construct the font string
  local fontString = "%s|%d|%s"
  local font = LMP:Fetch('font', fontFace)

  -- Fallback to default font if the fetched font is not found
  if not font then
    font = LMP:Fetch('font', IIfA.defaults_account.TooltipFontFace)
  end

  -- Assign the formatted font string
  IIfA.TooltipFont = string.format(fontString, font, fontSize, fontEffect)
end

local controlTooltips = {
  ["LineShare"] = "Doubleclick an item to add link to chat.",
  ["close"] = "close",
  ["toggle"] = "toggle",
  ["Search"] = "Search item name..."
}

local function getCustomStyleIconPath(name)
  return ("IIfA/assets/icons/" .. name .. ".dds")
end

--[[ Until this is verified IIFA_CUSTOM_ICON_NONE is used when
it may be a valid style but there is no texture for it returned
by GetItemLinkInfo(). However, IIFA_CUSTOM_ICON_DO_NOT_USE means
that there was no texture or style name from GetItemLinkInfo().
]]--
IIfA.racialTextures = {
  [1] = { styleTexture = getCustomStyleIconPath("breton") }, -- Breton, breton
  [2] = { styleTexture = getCustomStyleIconPath("redguard") }, -- Redguard, redguard
  [3] = { styleTexture = getCustomStyleIconPath("orsimer") }, -- Orc, orc
  [4] = { styleTexture = getCustomStyleIconPath("dunmer") }, -- Dark Elf, darkelf
  [5] = { styleTexture = getCustomStyleIconPath("nord") }, -- Nord, nord
  [6] = { styleTexture = getCustomStyleIconPath("argonian") }, -- Argonian, argonian
  [7] = { styleTexture = getCustomStyleIconPath("altmer") }, -- High Elf, highelf
  [8] = { styleTexture = getCustomStyleIconPath("bosmer") }, -- Wood Elf, woodelf
  [9] = { styleTexture = getCustomStyleIconPath("khajit") }, -- Khajiit, khajiit
  [10] = { styleTexture = getCustomStyleIconPath("telvanni") }, -- Unique, unique
  [11] = { styleTexture = getCustomStyleIconPath("thief") }, -- Thieves Guild, thievesguild
  [12] = { styleTexture = getCustomStyleIconPath("darkbrotherhood") }, -- Dark Brotherhood, darkbrotherhood
  [13] = { styleTexture = getCustomStyleIconPath("malacath") }, -- Malacath, malacath
  [14] = { styleTexture = getCustomStyleIconPath("dwemer") }, -- Dwemer, dwemer
  [15] = { styleTexture = getCustomStyleIconPath("ancient") }, -- Ancient Elf, ancientelf
  [16] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Order of the Hour, orderofthehour
  [17] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Barbaric, barbaric
  [18] = { styleTexture = getCustomStyleIconPath("bandit") }, -- Bandit, bandit
  [19] = { styleTexture = getCustomStyleIconPath("primitive") }, -- Primal, primal
  [20] = { styleTexture = getCustomStyleIconPath("daedric") }, -- Daedric, daedric
  [21] = { styleTexture = getCustomStyleIconPath("trinimac") }, -- Trinimac, trinimac
  [22] = { styleTexture = getCustomStyleIconPath("orsimer") }, -- Ancient Orc, ancientorc
  [23] = { styleTexture = getCustomStyleIconPath("daggerfall") }, -- Daggerfall Covenant, daggerfallcovenant
  [24] = { styleTexture = getCustomStyleIconPath("ebonheart") }, -- Ebonheart Pact, ebonheartpact
  [25] = { styleTexture = getCustomStyleIconPath("ancient") }, -- Aldmeri Dominion, aldmeridominion
  [26] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Mercenary, mercenary
  [27] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Celestial, celestial
  [28] = { styleTexture = getCustomStyleIconPath("templar") }, -- Glass, glass
  [29] = { styleTexture = getCustomStyleIconPath("nightblade") }, -- Xivkyn, xivkyn
  [30] = { styleTexture = getCustomStyleIconPath("soulshriven") }, -- Soul Shriven, soulshriven
  [31] = { styleTexture = getCustomStyleIconPath("skull") }, -- Draugr, draugr
  [32] = { styleTexture = getCustomStyleIconPath("maormer") }, -- Maormer, maormer
  [33] = { styleTexture = getCustomStyleIconPath("akaviri") }, -- Akaviri, akaviri
  [34] = { styleTexture = getCustomStyleIconPath("imperial") }, -- Imperial, imperial
  [35] = { styleTexture = getCustomStyleIconPath("akaviri") }, -- Yokudan, yokudan
  [36] = { styleTexture = getCustomStyleIconPath("imperial") }, -- Universal, universal
  [37] = { styleTexture = getCustomStyleIconPath("reach") }, -- Reach Winter, reachwinter
  [38] = { styleTexture = getCustomStyleIconPath("tsaesci") }, -- Tsaesci, tsaesci
  [39] = { styleTexture = getCustomStyleIconPath("minotaur") }, -- Minotaur, minotaur
  [40] = { styleTexture = getCustomStyleIconPath("ebony") }, -- Ebony, ebony
  [41] = { styleTexture = getCustomStyleIconPath("abahswatch") }, -- Abah's Watch, abahswatch
  [42] = { styleTexture = getCustomStyleIconPath("skinchanger") }, -- Skinchanger, skinchanger
  [43] = { styleTexture = getCustomStyleIconPath("moragtong") }, -- Morag Tong, moragtong
  [44] = { styleTexture = getCustomStyleIconPath("ragada") }, -- Ra Gada, ragada
  [45] = { styleTexture = getCustomStyleIconPath("dromathra") }, -- Dro-m'Athra, dromathra
  [46] = { styleTexture = getCustomStyleIconPath("assassin") }, -- Assassins League, assassinsleague
  [47] = { styleTexture = getCustomStyleIconPath("outlaw") }, -- Outlaw, outlaw
  [48] = { styleTexture = getCustomStyleIconPath("redoran") }, -- Redoran, redoran
  [49] = { styleTexture = getCustomStyleIconPath("hlaalu") }, -- Hlaalu, hlaalu
  [50] = { styleTexture = getCustomStyleIconPath("ordinator") }, -- Militant Ordinator, militantordinator
  [51] = { styleTexture = getCustomStyleIconPath("telvanni") }, -- Telvanni, telvanni
  [52] = { styleTexture = getCustomStyleIconPath("buoyantarmiger") }, -- Buoyant Armiger, buoyantarmiger
  [53] = { styleTexture = getCustomStyleIconPath("frostcaster") }, -- Frostcaster, frostcaster
  [54] = { styleTexture = getCustomStyleIconPath("cliffracer") }, -- Ashlander, ashlander
  [55] = { styleTexture = getCustomStyleIconPath("skull_nice") }, -- Worm Cult, wormcult
  [56] = { styleTexture = getCustomStyleIconPath("kothringi") }, -- Silken Ring, silkenring
  [57] = { styleTexture = getCustomStyleIconPath("lizard") }, -- Mazzatun, mazzatun
  [58] = { styleTexture = getCustomStyleIconPath("harlequin") }, -- Grim Harlequin, grimharlequin
  [59] = { styleTexture = getCustomStyleIconPath("hollowjack") }, -- Hollowjack, hollowjack
  [60] = { styleTexture = getCustomStyleIconPath("clockwork") }, -- Refabricated, refabricated
  [61] = { styleTexture = getCustomStyleIconPath("bloodforge") }, -- Bloodforge, bloodforge
  [62] = { styleTexture = getCustomStyleIconPath("dreadhorn") }, -- Dreadhorn, dreadhorn
  [63] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [64] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [65] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Apostle, apostle
  [66] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ebonshadow, ebonshadow
  [67] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Undaunted, undaunted
  [68] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [69] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Fang Lair, fanglair
  [70] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Scalecaller, scalecaller
  [71] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Psijic Order, psijicorder
  [72] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Sapiarch, sapiarch
  [73] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Welkynar, welkynar
  [74] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dremora, dremora
  [75] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Pyandonean, pyandonean
  [76] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Divine Prosecution, divineprosecution
  [77] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Huntsman, huntsman
  [78] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Silver Dawn, silverdawn
  [79] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dead-Water, deadwater
  [80] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Honor Guard, honorguard
  [81] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Elder Argonian, elderargonian
  [82] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Coldsnap, coldsnap
  [83] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Meridian, meridian
  [84] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Anequina, anequina
  [85] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Pellitine, pellitine
  [86] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Sunspire, sunspire
  [87] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Dragon Bone, dragonbone
  [88] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [89] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Stags of Z'en, stagsofzen
  [90] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [91] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [92] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dragonguard, dragonguard
  [93] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Moongrave Fane, moongravefane
  [94] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- New Moon Priest, newmoonpriest
  [95] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Shield of Senchal, shieldofsenchal
  [96] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [97] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Icereach Coven, icereachcoven
  [98] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Pyre Watch, pyrewatch
  [99] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Swordthane, swordthane
  [100] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Blackreach Vanguard, blackreachvanguard
  [101] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ancestral Akaviri, ancestralakaviri
  [102] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ancestral Breton, ancestralbreton
  [103] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ancestral Reach, ancestralreach
  [104] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Nighthollow, nighthollow
  [105] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Arkthzand Armory, arkthzandarmory
  [106] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Wayward Guardian, waywardguardian
  [107] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- House Hexos, househexos
  [108] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Deadlands Gladiator, deadlandsgladiator
  [109] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- True-Sworn, truesworn
  [110] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Waking Flame, wakingflame
  [111] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dremora Kynreeve, dremorakynreeve
  [112] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ancient Daedric, ancientdaedric
  [113] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Black Fin Legion, blackfinlegion
  [114] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ivory Brigade, ivorybrigade
  [115] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Deadlands Gladiator, deadlandsgladiator
  [116] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Crimson Oath, crimsonoath
  [117] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Silver Rose, silverrose
  [118] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Dremora Kynreeve, dremorakynreeve
  [119] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Fargrave Guardian, fargraveguardian
  [120] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dreadsails, dreadsails
  [121] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ivory Brigade, ivorybrigade
  [122] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Sul-Xan, sulxan
  [123] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Crimson Oath, crimsonoath
  [124] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Silver Rose, silverrose
  [125] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Annihilarch's Chosen, annihilarchschosen
  [126] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Fargrave Guardian, fargraveguardian
  [127] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [128] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dreadsails, dreadsails
  [129] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Ascendant Order, ascendantorder
  [130] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Syrabanic Marine, syrabanicmarine
  [131] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Steadfast Society, steadfastsociety
  [132] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Systres Guardian, systresguardian
  [133] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Reuse Me Please, reusemeplease
  [134] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Ascendant Knight, ascendantknight
  [135] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Y'ffre's Will, yffreswill
  [136] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Drowned Mariner, drownedmariner
  [137] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Knowledge Eater, ascendantknight
  [138] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Firesong, firesong
  [139] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- House Mornard, housemornard
  [140] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Scribes of Mora, scribesofmora
  [141] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Blessed Inheritor, blessedinheritor
  [142] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Clan Dreamcarver, clandreamcarver
  [143] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Dead Keeper, deadkeeper
  [144] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Kindred's Concord, kindredsconcord
  [145] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- The Recollection, therecollection
  [146] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Blind Path Cultist, blindpathcultist
  [147] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Shardborn, shardborn
  [148] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- West Weald Legion, westwealdlegion
  [149] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Lucent Sentinel, lucentsentinel
  [150] = { styleTexture = IIFA_CUSTOM_ICON_DO_NOT_USE }, -- Unknown, Unknown
  [151] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Hircine Bloodhunter, hircinebloodhunter
  [152] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Skingrad Vedette, skingradvedette
  [153] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Exile's Revenge, exilesrevenge
  [154] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Militant Monk, militantmonk
  [155] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Stirk Fellowship, stirkfellowship
  [156] = { styleTexture = IIFA_CUSTOM_ICON_NONE }, -- Coldharbour Dominator, coldharbourdominator
  [157] = { styleTexture = IIFA_CUSTOM_ICON_USE_API }, -- Tide-Born, tideborn
}

-- /script local i for i=80,100 do d(i .. " " .. GetItemStyleName(i)) end

local function GetItemStyleDetails(itemLink)
  if not IIfA:isItemLink(itemLink) then return end

  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  if not settings then return end
  if not settings.showStyleInfo then return end
  local alwaysUseStyleMaterial = settings.alwaysUseStyleMaterial

  local _, _, _, _, itemStyleId = GetItemLinkInfo(itemLink)
  if not itemStyleId then return end

  local styleName = ZO_CachedStrFormat("<<1>>", GetItemStyleName(itemStyleId))
  if not styleName or styleName == IIfA.EMPTY_STRING then return end

  -- Custom entry (may be nil)
  local customEntry = IIfA.racialTextures and IIfA.racialTextures[itemStyleId]
  local customTexture = customEntry and customEntry.styleTexture or nil

  -- DO_NOT_USE => hard stop
  if customTexture == IIFA_CUSTOM_ICON_DO_NOT_USE then return end

  -- Resolve game material icon
  local styleMaterialIcon
  local styleItemLink = GetItemStyleMaterialLink(itemStyleId, LINK_STYLE_BRACKETS)
  if styleItemLink and styleItemLink ~= IIfA.EMPTY_STRING then
    local icon = GetItemLinkInfo(styleItemLink)
    if icon and icon ~= IIfA.EMPTY_STRING then
      styleMaterialIcon = icon
    end
  end

  local customIsString = (type(customTexture) == "string" and customTexture ~= "")

  if alwaysUseStyleMaterial and styleMaterialIcon then
    return { styleName = styleName, styleTexture = styleMaterialIcon }
  end

  if customIsString then
    return { styleName = styleName, styleTexture = customTexture }
  end

  if customTexture == IIFA_CUSTOM_ICON_NONE then
    return { styleName = styleName, styleTexture = IIfA.inventoryinsight_icon }
  end

  if customTexture == IIFA_CUSTOM_ICON_USE_API and styleMaterialIcon then
    return { styleName = styleName, styleTexture = styleMaterialIcon }
  end

  -- Nothing usable
  return
end

function IIfA:AnchorFrame(tooltip, parentTooltip)
  local parentTooltipWidth = parentTooltip:GetWidth()
  tooltip:SetWidth(parentTooltipWidth)
  local tooltipWidth = tooltip:GetWidth()

  local x, y = GetUIMousePosition()
  local parentTooltipTop = parentTooltip:GetTop()
  local parentTooltipBottom = parentTooltip:GetBottom()
  local parentTooltipLeft = parentTooltip:GetLeft()
  local parentTooltipRight = parentTooltip:GetRight()

  local uiWidth, uiHeight = GuiRoot:GetDimensions()
  local tooltipHeight = tooltip:GetHeight()

  -- vertical placement check
  local spaceAbove = zo_floor(parentTooltipTop - 32)
  local spaceBelow = zo_floor(uiHeight - parentTooltipBottom)
  local tooltipAtBottom = spaceBelow >= tooltipHeight
  -- IIfA:dm("Debug", string.format(
  --   "W: %s, H: %s, CRSR-X: %s, CRSR-Y: %s, Top: %s, Bottom: %s, tooltipHeight: %s, spaceAbove: %s, spaceBelow: %s",
  --   uiWidth, uiHeight, x, y, zo_floor(parentTooltipTop -32), zo_floor(parentTooltipBottom), tooltipHeight, spaceAbove, spaceBelow))

  -- horizontal placement check
  local placeOnLeft = parentTooltipLeft >= tooltipWidth   -- enough space on left side
  -- if not enough space on left, we’ll fall back to right side

  tooltip:ClearAnchors()

  local tooltipAnchor, parentTooltipAnchor, tooltipVerticalOffset = BOTTOM, TOP, -32

  if tooltipAtBottom then
    -- below parent
    tooltipAnchor = TOP
    parentTooltipAnchor = BOTTOM
    tooltipVerticalOffset = 0
  end

  tooltip:SetAnchor(tooltipAnchor, parentTooltip, parentTooltipAnchor, 0, tooltipVerticalOffset)
end

-- do NOT local this function
function IIfA_HideTooltip(control, ...)
  local controlName
  if control and control.GetName then
    controlName = control:GetName()
    -- IIfA:dm("Warn", "[IIfA_HideTooltip]: " .. controlName)
  end
  if IIFA_DATABASE[IIfA.currentAccount].settings.bInSeparateFrame then
    if control == ItemTooltip or control == IIFA_ITEM_TOOLTIP then
      IIFA_ITEM_TOOLTIP:ClearLines()
      IIFA_ITEM_TOOLTIP:SetHidden(true)
      return
    elseif control == PopupTooltip or control == IIFA_POPUP_TOOLTIP then
      IIFA_POPUP_TOOLTIP:ClearLines()
      IIFA_POPUP_TOOLTIP:SetHidden(true)
      return
    end
  else
    if control.IIfA_TT_Ext then
      control.IIfAPool:ReleaseAllObjects()
      control.IIfA_TT_Ext = nil
      return
    end
  end
  IIfA:dm("Warn", "Shit Hit the fan!")
end

-- do NOT local this function
function IIfA_TooltipOnTwitch(tooltipControl, gameDataType, ...)
  if IIFA_DATABASE[IIfA.currentAccount].settings.bInSeparateFrame then
    if gameDataType == TOOLTIP_GAME_DATA_ITEM_ICON then
      if tooltipControl == ItemTooltip then
        -- item tooltips appear where mouse is
        return IIfA:UpdateTooltip(IIFA_ITEM_TOOLTIP)
      elseif tooltipControl == PopupTooltip then
        return IIfA:UpdateTooltip(IIFA_POPUP_TOOLTIP)
      end
    end
  else
    if tooltipControl == PopupTooltip and tooltipControl.IIfA_TT_Ext then
      return
    end
    -- this is called whenever there's any data added to the in-game tooltip
    --[[
    For people who have configured the tooltip information to show in the tooltip and not in a separate frame, you can fix the issue introduced
    in Update 29 this way:

    Open InventoryInsight_Tooltip.lua
    Go to line 363
    Change TOOLTIP_GAME_DATA_MAX_VALUE to TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN

    What changed in Update 29 is that they introduced a
    new enumeration: TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION.
    So in the previous patch, when OnAddGameData was called
    with TOOLTIP_GAME_DATA_STOLEN (the previous max value),
    it would trigger the tooltip update. But in Update 29,
    the max value is now TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION,
    and OnAddGameData is never called with
    TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION for an item tooltip.

    TL;DR: IIfA assumed that TOOLTIP_GAME_DATA_MAX_VALUE would
    always be valid for an item tooltip, but ZOS broke that
    assumption by adding a data type for CP 2.0 that doesn't appear in item tooltips.

    Last edited by code65536 : 03/10/21 at 02:09 PM.
    ]]
    --Current max value 9 2021-10-31 is TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION
    --[[TODO Check whether or not TOOLTIP_GAME_DATA_MAX_VALUE
    reflects a better value now ]]--
    if gameDataType == TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN then
      --p("Tooltip On Twitch - " .. tooltipControl:GetName() .. ", " .. gameDataType)
      IIfA:UpdateTooltip(tooltipControl)
    end
  end
end

local FurnishingOverrides = {
  [118327] = { subtype_base = 118 }, -- Provisioning Station
  [118328] = { subtype_base = 118 }, -- Alchemy Station
  [118329] = { subtype_base = 118 }, -- Dye Station
  [118330] = { subtype_base = 118 }, -- Enchanting Station
  [119707] = { subtype_base = 118 }, -- Clothing Station
  [119744] = { subtype_base = 118 }, -- Woodworking Station
  [119781] = { subtype_base = 118 }, -- Blacksmithing Station
  [133576] = { subtype_base = 118 }, -- Transmute Station
  [137870] = { subtype_base = 118 }, -- Jewelry Crafting Station
  [134675] = { subtype_base = 118 }, -- Outfit Station
}

local IDX = {
  TEXT = 1, -- (returned but we don't use)
  LINK_STYLE = 2,
  TYPE = 3, -- ITEM_LINK_TYPE = "item", COLLECTIBLE_LINK_TYPE = "collectible"
  ITEM_ID = 4, -- wiki 1
  SUBTYPE = 5, -- wiki 2
  INTERNAL_LVL = 6, -- wiki 3
  ENCHANT_ID = 7, -- wiki 4
  ENCHANT_SUB = 8, -- wiki 5
  ENCHANT_LVL = 9, -- wiki 6
  WRIT1_OR_TRANS = 10, -- wiki 7
  WRIT2 = 11, -- wiki 8
  WRIT3 = 12, -- wiki 9
  WRIT4 = 13, -- wiki 10
  WRIT5 = 14, -- wiki 11
  WRIT6 = 15, -- wiki 12
  UNUSED_13 = 16, -- wiki 13
  UNUSED_14 = 17, -- wiki 14
  FLAGS = 18, -- wiki 15
  ITEM_STYLE = 19, -- wiki 16
  CRAFTED = 20, -- wiki 17
  BOUND = 21, -- wiki 18
  STOLEN = 22, -- wiki 19
  CHARGES = 23, -- wiki 20
  POTION_OR_RWR = 24, -- wiki 21 (PotionEffect or WritReward)
}

-- Convenience aliases & bounds
IDX.FIRST = IDX.ITEM_ID
IDX.LAST = IDX.POTION_OR_RWR
IDX.LEVEL = IDX.INTERNAL_LVL     -- readability alias

local function ParseFields(itemLink)
  local f = { ZO_LinkHandler_ParseLink(itemLink) }
  return f
end

local function EnsureString(v)
  if v == nil then return "0" end
  if type(v) == "number" then return tostring(v) end
  if v == "" then return "0" end
  return v
end

local function BuildItemLinkFromFields(f)
  local out = {}
  for i = IDX.FIRST, IDX.LAST do
    out[#out + 1] = EnsureString(f[i])
  end
  return ("|H1:item:%s|h|h"):format(table.concat(out, ":"))
end

-- /script d(IIfA:SetCrafted("|H1:item:43542:366:50:0:0:0:0:0:0:0:0:0:0:0:0:5:0:0:0:10000:0|h|h"))
function IIfA:SetCrafted(itemLink)
  local f = ParseFields(itemLink)
  f[IDX.CRAFTED] = "1"
  return BuildItemLinkFromFields(f)
end

function IIfA:SetLinkStyle(itemLink, style)
  local f = ParseFields(itemLink)
  f[IDX.LINK_STYLE] = EnsureString(style or LINK_STYLE_DEFAULT)
  return BuildItemLinkFromFields(f)
end

function IIfA:SetLevelAndSubType(itemLink)
  local f = ParseFields(itemLink)
  if not f then return itemLink end

  local q = tonumber(GetItemLinkDisplayQuality(itemLink)) or 0
  local l = tonumber(GetItemLinkRequiredLevel(itemLink)) or 0

  local itemId = tonumber(f[IDX.ITEM_ID])
  local ov = itemId and FurnishingOverrides and FurnishingOverrides[itemId]

  if ov and ov.subtype_base then
    -- Use furnishing override: subtype = base + quality + level
    f[IDX.SUBTYPE] = tostring(ov.subtype_base + q + l)
  else
    -- Default behavior
    f[IDX.SUBTYPE] = tostring(q + l)
  end

  f[IDX.LEVEL] = l
  return BuildItemLinkFromFields(f)
end

function IIfA:CheckLevelAndSubType(itemLink)
  local f = ParseFields(itemLink)
  local hasNoLevel = tonumber(f[IDX.LEVEL]) == nil or tonumber(f[IDX.LEVEL]) == 0
  local hasNoSubType = tonumber(f[IDX.SUBTYPE]) == nil or tonumber(f[IDX.SUBTYPE]) == 0

  if hasNoLevel and hasNoSubType then
    return self:SetLevelAndSubType(itemLink)
  end
  return itemLink
end

function IIfA:getMouseoverLink()
  -- IIfA:dm("Debug", "getMouseoverLink")
  local mouseOverControl = moc()
  if not mouseOverControl then return end
  local mouseOverControlParent
  local mouseOverControlGrandparent
  local mocOwner

  if mouseOverControl.GetParent then mouseOverControlParent = mouseOverControl:GetParent() end
  if mouseOverControlParent and mouseOverControlParent.GetParent then mouseOverControlGrandparent = mouseOverControlParent:GetParent() end
  if mouseOverControl and mouseOverControl.GetOwningWindow then mocOwner = mouseOverControl:GetOwningWindow() end

  local mocName = mouseOverControl:GetName()
  local mocParentName
  local mocGPName
  local mocOwnerName

  if mouseOverControlParent then mocParentName = mouseOverControlParent:GetName() end
  if mouseOverControlGrandparent then mocGPName = mouseOverControlGrandparent:GetName() end
  if mocOwner then mocOwnerName = mocOwner:GetName() end

  -- do we show IIfA info?
  local accountSettings = IIFA_DATABASE[IIfA.currentAccount].settings
  if accountSettings.showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_NEVER) or
    (accountSettings.showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_IIFA) and mocParentName ~= "IIFA_GUI_ListHolder") then
    return nil
  end

  local hasDataEntryData = mouseOverControl and mouseOverControl.dataEntry and mouseOverControl.dataEntry.data
  local hasParentData = mouseOverControlParent and mouseOverControlParent.data
  local hasMocData = mouseOverControl and mouseOverControl.data

  -- New: collect the link and (optionally) a post-processing tag, then return once at the end.
  local itemLink = nil
  local postProcessTag = nil  -- set inside branches when we want extra handling later

  if mocParentName == 'ZO_CraftBagListContents' or
    mocParentName == 'ZO_PlayerInventoryListContents' or
    mocParentName == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_QuickSlot_Keyboard_TopLevelListContents' or
    mocParentName == 'ZO_PlayerBankBackpackContents' or
    mocParentName == 'ZO_GuildBankBackpackContents' or
    mocParentName == 'ZO_HouseBankBackpackContents' or
    mocParentName == 'ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpackContents' or
    mocParentName == 'ZO_CompanionEquipment_Panel_KeyboardListContents' then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    itemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_FurnitureVaultListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    itemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_BRACKETS)
    postProcessTag = "furniture_vault"

  elseif mocOwnerName == "ZO_HousingFurniturePlacementPanel_KeyboardTopLevel" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if rowData and rowData.bagId and rowData.slotIndex then
      itemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_BRACKETS)
    end

  elseif mocParentName == "ZO_Character" then
    -- is worn item
    itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_CompanionCharacterWindow_Keyboard_TopLevel" then
    -- is worn item
    itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_LootAlphaContainerListContents" then
    -- is loot item
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    itemLink = GetLootItemLink(rowData.lootId, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_BuyBackListContents" then
    -- is buyback item
    itemLink = GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_StoreWindowListContents" then
    -- is store item
    -- Note: store can include crafting stations; we’ll decide how to adjust after we get the link.
    itemLink = GetStoreItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)
    postProcessTag = "store"

  elseif mocParentName == 'ZO_MailInboxMessageAttachments' then
    -- MAIL_INBOX:GetOpenMailId() is the id64 of the mail
    itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), mouseOverControl.id, LINK_STYLE_BRACKETS)

  elseif mocParentName == 'ZO_MailSendAttachments' then
    itemLink = GetMailQueuedAttachmentLink(mouseOverControl.id, LINK_STYLE_BRACKETS)

    -- following 4 if's derived directly from MasterMerchant
  elseif mocOwnerName == 'MasterMerchantWindow' or
    mocOwnerName == 'MasterMerchantGuildWindow' or
    mocOwnerName == 'MasterMerchantPurchaseWindow' or
    mocOwnerName == 'MasterMerchantListingWindow' or
    mocOwnerName == 'MasterMerchantFilterByNameWindow' or
    mocOwnerName == 'MasterMerchantReportsWindow' then
    if mouseOverControl.GetText then
      itemLink = mouseOverControl:GetText()
      postProcessTag = "master_merchant"
    end

  elseif mocParentName == "IIFA_GUI_ListHolder" then
    -- Prefer the row’s itemLink; fallback to TooltipLink if not present.
    if mouseOverControl.itemLink and IIfA:isItemLink(mouseOverControl.itemLink) then
      itemLink = mouseOverControl.itemLink
    elseif IIfA.TooltipLink and IIfA:isItemLink(IIfA.TooltipLink) then
      itemLink = IIfA.TooltipLink
    end

  elseif mocParentName == "FurCGui_ListHolder" then
    if mouseOverControl.itemLink and IIfA:isItemLink(mouseOverControl.itemLink) then
      itemLink = mouseOverControl.itemLink
    end
    postProcessTag = "furc"

  elseif mocParentName == "ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    itemLink = GetTradingHouseSearchResultItemLink(rowData.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_TradingHousePostedItemsListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    itemLink = GetTradingHouseListingItemLink(rowData.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == 'DolgubonSetCrafterWindowMaterialListListContents' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data[1]
    if not rowData then return end
    itemLink = rowData.Name

  elseif mocGPName == "CraftingQueueScrollListContents" then
    if not hasParentData then return end
    local rowData = mouseOverControlParent.data[1]
    local rowDataLink = rowData.Link
    if not rowDataLink then return end
    itemLink = IIfA:SetCrafted(rowDataLink)

  elseif mocParentName == "ZO_InteractWindowRewardArea" then
    -- is reward item
    itemLink = GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

  elseif mocOwnerName == 'CraftStoreFixed_Cook' or
    mocOwnerName == 'CraftStoreFixed_Rune' or
    mocOwnerName == 'CraftStoreFixed_Blueprint_Window' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    itemLink = rowData.link

  elseif mocOwnerName == 'ZO_ClaimLevelUpRewardsScreen_Keyboard' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    itemLink = rowData.itemLink

    --[[TODO verified to here ]]--
  else
    if accountSettings and accountSettings.bDebug then
      IIfA:dm("Debug", string.format(
        "IIfA:getMouseoverLink Unhandled\n  moc=%s\n  parent=%s\n  grandparent=%s\n  owner=%s",
        tostring(mocName), tostring(mocParentName), tostring(mocGPName), tostring(mocOwnerName)
      ))
    end
    return nil
  end

  if itemLink then
    if accountSettings and accountSettings.bDebug then
      local core, display = itemLink:match("^|H([^|]+)|h(.-)|h$")
      local dashed = core and string.format("--%s--%s--", core, (display and display ~= "" and display) or "") or string.format("--%s--", itemLink)
      IIfA:dm("Debug", "[getMouseoverLink]" .. dashed)
    end

    if postProcessTag == "furniture_vault" then
      itemLink = IIfA:CheckLevelAndSubType(itemLink)

    elseif postProcessTag == "store" then
      itemLink = IIfA:CheckLevelAndSubType(itemLink)

    elseif postProcessTag == "furc" then
      itemLink = IIfA:CheckLevelAndSubType(itemLink)
    end
    if postProcessTag == "master_merchant" then
      itemLink = IIfA:SetLinkStyle(itemLink, LINK_STYLE_BRACKETS)
    end
    -- IIfA:dm("Debug", "[getMouseoverLink] return value: " .. itemLink)
    return itemLink
  end

  -- IIfA:dm("Warn", "The itemlink was nil: " .. tostring(itemLink))
  return nil
end

function IIfA:getLastLink(tooltip)
  local ret = nil
  if IIFA_DATABASE[IIfA.currentAccount].settings.bInSeparateFrame then
    if tooltip == IIFA_POPUP_TOOLTIP then
      ret = IIfA.TooltipLink
    elseif tooltip == IIFA_ITEM_TOOLTIP then
      ret = self:getMouseoverLink()
    end
  else
    if tooltip == PopupTooltip then
      ret = IIfA.TooltipLink    -- this gets set on the prehook of PopupTooltip:SetLink
    elseif tooltip == ItemTooltip then
      ret = self:getMouseoverLink()
      IIfA.TooltipLink = ret    -- make sure it's set right always
    end
  end

  local debugLink
  if (not ret) then
    if not IIfA.LastActiveRowControl then
      debugLink = ret
      if debugLink ~= nil then
        debugLink = debugLink:gsub("^|H", "--"):gsub("|h$", "--")
      else
        debugLink = nil
      end
      IIfA:dm("Warn", "[getLastLink] no LastActiveRowControl: " .. tostring(debugLink))
      return ret
    end
    ret = IIfA.LastActiveRowControl:GetText()
    IIfA:dm("Debug", "[getLastLink] no ret, used GetText")
  end

  debugLink = ret
  if debugLink ~= nil then
    debugLink = debugLink:gsub("^|H", "--"):gsub("|h$", "--")
  else
    debugLink = nil
  end
  IIfA:dm("Warn", "[getLastLink] ret: " .. tostring(debugLink))
  return ret
end

local function AddLocationEntriesToTooltip(tooltip, queryResults)
  for location, locationData in pairs(queryResults.locations) do
    local textOut
    if locationData.name == nil or locationData.itemsFound == nil then
      textOut = 'Error occurred'
    else
      textOut = ZO_CachedStrFormat("<<1>> x <<2>>", locationData.name, locationData.itemsFound)
    end
    if locationData.worn or locationData.wornCompanion then
      textOut = ZO_CachedStrFormat("<<1>> *", textOut)
    end
    if locationData.bagLoc == BAG_BACKPACK then
      textOut = IIfA.colorHandlerToon:Colorize(textOut)
    elseif locationData.bagLoc == BAG_BANK then
      textOut = IIfA.colorHandlerBank:Colorize(textOut)
    elseif locationData.bagLoc == BAG_COMPANION_WORN then
      textOut = IIfA.colorHandlerCompanion:Colorize(textOut)
    elseif locationData.bagLoc == BAG_FURNITURE_VAULT then
      textOut = IIfA.colorHandlerHouse:Colorize(textOut)
    elseif locationData.bagLoc == BAG_GUILDBANK then
      textOut = IIfA.colorHandlerGBank:Colorize(textOut)
    elseif locationData.bagLoc == BAG_HOUSE_BANK_ONE then
      textOut = IIfA.colorHandlerHouseChest:Colorize(textOut)
    elseif locationData.bagLoc == IIFA_HOUSING_BAG_LOCATION then
      textOut = IIfA.colorHandlerHouse:Colorize(textOut)
    elseif locationData.bagLoc == BAG_VIRTUAL then
      textOut = IIfA.colorHandlerCraftBag:Colorize(textOut)
    end
    tooltip:AddLine(textOut, IIfA.TooltipFont)
  end
end

function IIfA:UpdateTooltip(tooltip)
  -- Early return if tooltip should not be shown
  -- IIfA:dm("Debug", "UpdateTooltip: " .. tooltip:GetName())
  local mocParent = moc():GetParent()
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  local showToolTipWhen = settings.showToolTipWhen
  local neverShowTooltip = showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_NEVER)
  local showOnlyIIfA = showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_IIFA) and mocParent and mocParent:GetName() ~= "IIFA_GUI_ListHolder"

  if neverShowTooltip or showOnlyIIfA then
    return
  end

  -- Fetch item link and query results
  local itemLink = self:getLastLink(tooltip)
  if not itemLink then
    return
  end
  -- IIfA:dm("Debug", "[UpdateTooltip]" .. itemLink)

  -- Get style details
  local itemStyleDetails = GetItemStyleDetails(itemLink)
  local identifiedStyleTexture = (itemStyleDetails and itemStyleDetails.styleTexture ~= "" and itemStyleDetails.styleTexture) or IIfA.EMPTY_STRING
  local identifiedStyleName = (itemStyleDetails and itemStyleDetails.styleName ~= "" and itemStyleDetails.styleName) or IIfA.EMPTY_STRING

  -- Decide if there's nothing to show
  local queryResults = IIfA:QueryAccountInventory(itemLink)
  local noResults = (not queryResults) or (not queryResults.locations) or (#queryResults.locations == 0)
  if noResults then
    -- IIfA:dm("Debug", "[UpdateTooltip] No Results, Tooltip Frame Hiding: " .. tooltip:GetName())
    IIfA_HideTooltip(tooltip)
    return
  end

  local debugLink = itemLink
  if debugLink ~= nil then
    debugLink = "[UpdateTooltip]" .. debugLink:gsub("^|H", "--"):gsub("|h$", "--")
  end

  -- Separate frame handling starts here
  -- Variables for style icon and label
  local styleIcon, styleLabel
  if settings.bInSeparateFrame then
    local parentTooltip = nil
    if tooltip == IIFA_POPUP_TOOLTIP then parentTooltip = PopupTooltip end
    if tooltip == IIFA_ITEM_TOOLTIP then parentTooltip = ItemTooltip end

    tooltip:ClearLines()
    tooltip:SetHeight(0)

    styleIcon = tooltip:GetNamedChild("_StyleIcon")
    styleLabel = tooltip:GetNamedChild("_StyleLabel")
    if identifiedStyleName ~= IIfA.EMPTY_STRING then
      tooltip:AddLine(" ")

      styleIcon:SetTexture(identifiedStyleTexture)
      styleLabel:SetText(identifiedStyleName)

      styleIcon:SetHidden(false)
      styleLabel:SetHidden(false)
    else
      styleIcon:SetHidden(true)
      styleLabel:SetHidden(true)
    end

    if queryResults then
      if #queryResults.locations > 0 then
        if identifiedStyleName ~= IIfA.EMPTY_STRING then
          ZO_Tooltip_AddDivider(tooltip)
        end
        AddLocationEntriesToTooltip(tooltip, queryResults)
      else
        -- IIfA:dm("Debug", "No Query Results from #queryResults for: " .. debugLink)
      end
    else
      -- IIfA:dm("Debug", "No Query Results for: " .. debugLink)
    end

    -- SetHidden will be true when identifiedStyleName is empty
    IIfA:AnchorFrame(tooltip, parentTooltip)
    tooltip:SetHidden(false)
  else
    -- Only add/show the style info if it has style
    if identifiedStyleName ~= IIfA.EMPTY_STRING then
      if tooltip.IIfAPool == nil then
        tooltip.IIfAPool = ZO_ControlPool:New("IIFA_TT_Template", tooltip, "IIFA_TT_Ext")
      end

      if tooltip.IIfAPool then
        tooltip.IIfA_TT_Ext = tooltip.IIfAPool:AcquireObject()
        tooltip.IIfA_TT_Ext:SetWidth(tooltip:GetWidth())
      end

      if tooltip.IIfA_TT_Ext then
        ZO_Tooltip_AddDivider(tooltip)
        tooltip:AddControl(tooltip.IIfA_TT_Ext)
        tooltip.IIfA_TT_Ext:SetAnchor(TOP)

        -- Update the style icon and label
        styleIcon = tooltip.IIfA_TT_Ext:GetNamedChild("_StyleIcon")
        styleLabel = tooltip.IIfA_TT_Ext:GetNamedChild("_StyleLabel")
        styleIcon:SetTexture(identifiedStyleTexture)
        styleLabel:SetText(identifiedStyleName)
      end
    end

    if (queryResults) then
      if #queryResults.locations > 0 then
        ZO_Tooltip_AddDivider(tooltip)
        AddLocationEntriesToTooltip(tooltip, queryResults)
      end
    end
  end
end
