AoAa = {} 
AoAa.name = "AoAa"
AoAa.activatorText = "" -- setting this up for later use
AoAa.version = 1.42
AoAa.GuiHidden = true

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

account = GetDisplayName("player")
local IDbar = ""
local IDbarnr = 0
local IDguildhall = ""
local IDguildhallnr = 0
local IDhorror = ""
local IDhorrornr = 0

function AoAa.OnAddOnLoaded(event, addOnName)
    if addOnName ~= AoAa.name then return end
    if addOnName == AoAa.name then
        ZO_CreateStringId("SI_BINDING_NAME_RUN_AOAA", GetString(SI_CWA_KEY_BINDING))        
        AoAa:Initialize()
    end
end

function AoAa:Initialize()
    
    AoAa.CreateSettingsWindow()
    
    AoAaIndicator:SetHidden(false)
    AoAa.savedVariables = ZO_SavedVars:NewAccountWide("AoAaSavedVariables", AoAa.version, nil, {})
    AoAa:RestorePosition()
    
    d("|cFFFFFFA |cFFFFFFS|cEECA2Auper |cFFFFFFU|cEECA2Aseful |cFFFFFFG|cEECA2Aadget |cFFFFFFB|cEECA2Aar by |c2DC50EGol |cEECA2Ais loaded.|r")
    
    IDbarnr = AoAa.savedVariables.House1
    IDbar = AoAa.savedVariables.House1U
    IDguildhallnr = AoAa.savedVariables.House2
    IDguildhall = AoAa.savedVariables.House2U
    IDhorrornr = AoAa.savedVariables.House3
    IDhorror = AoAa.savedVariables.House3U
    
    AoAa.GuiHidden = false

end

function AoAa.OnIndicatorMoveStop()
  AoAa.savedVariables.left = AoAaIndicator:GetLeft()
  AoAa.savedVariables.top = AoAaIndicator:GetTop()
end

function AoAa:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top 
  
  AoAaIndicator:ClearAnchors()
  AoAaIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function AoAa.WindowClick()
  AoAaIndicator:SetHidden(true)
  AoAa.GuiHidden = true
end

function AoAa.help()
  d("A Super Useful Gadget Bar.")
  d("Commands currently available:")
  d("- /sgbhelp: This helptext.")
  d("- /sgbport 1: Port to House 1.")
  d("- /sgbport 2: Port to House 2.")
  d("- /sgbport 3: Port to House 3.")
  d("- /sgbmoney: show your current valuta balance")
  d("- /sgbgui: toggle the gadgetbar")
  d("- /sgblvl: get your current level")
  d("- /sgbhorse: mount training time left")
  d("- /sgbgetid: Displays the Unique ID of the house you're in.")
  d(" - /sgblatency: Displays current ping latency.")
  d(" - /sgbfps: Displays current Frames per Second the game is running in.")
  d("-----------------------------------------------------------")
  d("How to bind a house to one of the three port-buttons:")
  d("1. Travel to the house you want to add")
  d("2. Remember the @username of the owner of the house")
  d("3. Type in chat: /sgbgetid and remember the house id")
  d("4. Go the Settings -> Addons -> A Super Useful Gadget Bar")
  d("5. Enter the @username and unique house id")
  d("6. Do a /reloadui")
  d("7. Click the button you just added the data for to port to the house")
  d("Note: You have to have permissions from the owner to port to the house")
end

function AoAa.port(activatorText)
  if activatorText == nil or activatorText == '' then
    d("Please specify to what residence you want to port. Usage: /aoaport bar")
  else
    
    AoAa.activatorText = activatorText
    if activatorText == "bar" then
        if IsInAvAZone() then
            d("You can't port while you are in Cyrodiil..")
        else
            d("Porting to " .. activatorText)
            JumpToSpecificHouse(IDbar,IDbarnr)
        end
    end   
    if activatorText == "guildhall" then
        if IsInAvAZone() then
            d("You can't port while you are in Cyrodiil..")
        else
            d("Porting to ".. activatorText)
            JumpToSpecificHouse(IDguildhall,IDguildhallnr)
        end
    end   
    if activatorText == "horror" then
        if IsInAvAZone() then
            d("You can't port while you are in Cyrodiil..")
        else
            d("Porting to " .. activatorText)
            JumpToSpecificHouse(IDhorror,IDhorrornr)
        end
    end   

  end
end

function AoAa.GuiPortToBar()
  if IsInAvAZone() then
    --d("You can't port while you are in Cyrodiil..")
  else
    --d("Porting to " .. activatorText)
    JumpToSpecificHouse(IDbar,IDbarnr)
  end
end   

function AoAa.GuiPortToGuildhall()
  if IsInAvAZone() then
    --d("You can't port while you are in Cyrodiil..")
  else
    --d("Porting to " .. activatorText)
    JumpToSpecificHouse(IDguildhall,IDguildhallnr)
  end
end  

function AoAa.GuiPortToHorror()
  if IsInAvAZone() then
    --d("You can't port while you are in Cyrodiil..")
  else
    --d("Porting to " .. activatorText)
    JumpToSpecificHouse(IDhorror,IDhorrornr)
  end
end  

function AoAa.getid()
  eyed = GetCurrentZoneHouseId()
  d("Unique ID of the house you are standing is ".. eyed)
end

function AoAa.gui()
  if AoAa.GuiHidden == true then
      AoAaIndicator:SetHidden(false)
      AoAa.GuiHidden = false
  else
      AoAaIndicator:SetHidden(true)
      AoAa.GuiHidden = true
  end
end

function AoAa.level()
  lvl = GetUnitLevel("player")
  cp = GetUnitChampionPoints("player")
  d("Your level is: ".. lvl)
  d("Your CP level is: ".. cp)
end

function AoAa.getxp()
	if IsUnitChampion("player") then
		local xp = GetPlayerChampionXP()
    d("Player CP XP is: ".. xp)
  else
	 local xp = GetUnitXP("player")
    d("Player XP is: ".. xp)
  end
end

function AoAa.getxpmax()
	if IsUnitChampion("player") then
		local ccp = GetUnitChampionPoints("player")
		if ccp < GetChampionPointsPlayerProgressionCap() then
			ccp = GetChampionPointsPlayerProgressionCap()
		end
		local maxxp = GetNumChampionXPInChampionPoint(ccp)
    d("Player Max CP XP is: ".. maxxp)
  else
		local maxxp = GetUnitXPMax("player")
    d("Player Max XP is: ".. maxxp)
  end
end

function AoAa.ShowToolTipBar(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Port to House nr. 1")
end

function AoAa.ShowToolTipGuildHall(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Port to House nr. 2")
end

function AoAa.ShowToolTipHorror(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Port to House nr. 3")
end

function AoAa.ShowToolTipMebers(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Bag space")
end

function AoAa.ShowToolTipGold(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Gold balance on your character")
end

function AoAa.ShowToolTipTelvar(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Telvar stones balance on your character and in bank")
end

function AoAa.ShowToolTipTC(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Transmute Crystal balance on your account")
end

function AoAa.ShowToolTipAP(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Alliance Point balance on your character")
end

function AoAa.ShowToolTipWV(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Writ Voucher balance on your character")
end

function AoAa.ShowToolTipLvl(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Current Character level")
end

function AoAa.ShowToolTipCP(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Champion Points level")
end

function AoAa.ShowToolTipM(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Mount training time left")
end

function AoAa.ShowToolTipXP(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "XP percentage left until next level")
end

function AoAa.ShowToolTipFPS(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Current FPS")
end

function AoAa.ShowToolTipLAT(self)
      InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
      SetTooltipText(InformationTooltip, "Current Ping Latency")
end


function AoAa.HideTooltip(self)
    ClearTooltip(InformationTooltip)
end

function AoAa.balance()
    telvarc = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    telvarb = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
    telvar = telvarc + telvarb
    goldc = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    goldb = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    gold = goldc + goldb
    ap = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    crystal = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    writv = GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER)
    
    lvl = GetUnitLevel("player")
    cp = GetUnitChampionPoints("player")
end

function AoAa.moneys()
    AoAa.balance()  
    d("Gold balance is " .. gold)
    d("Telvar balance is " .. telvar)
    d("Transmute Crystal balance is " .. crystal)
    d("Alliance Point balance is " .. ap)
    d("Writ vouchers balance is " .. writv)
end

function AoAa.bagspace()
    AoAa.bags()
    d("Bag slots used: " .. usedSlots)
    d("Max bag slots: " .. maxSlots)
end

function AoAa.horse()
    mounttimercli = GetTimeUntilCanBeTrained()
    if STABLE_MANAGER:IsRidingSkillMaxedOut() then
      d("Riding skills are all maxed out!") 
    else
      if mounttimercli == nil then
        d("You have no horse")
      else    
          mounttimercli = math.floor(mounttimercli / 60000)
          mountformat = FormatTimeSeconds(60 * mounttimercli, TIME_FORMAT_STYLE_CLOCK_TIME , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
          d("Time until horse training: " ..mountformat) 
      end
    end
end

function AoAa.horsetimer()
    mounttimergui = GetTimeUntilCanBeTrained()
    if STABLE_MANAGER:IsRidingSkillMaxedOut() then
      mountlbltxt = "V" 
    else
      if mounttimergui == nil then
        mountlbltxt = 0
      else    
          mounttimergui = math.floor(mounttimergui / 60000)
          mountlbltxt = FormatTimeSeconds(60 * mounttimergui, TIME_FORMAT_STYLE_CLOCK_TIME , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
      end
    end
end

function AoAa.xpperc()
	if IsUnitChampion("player") then
		gcp = GetUnitChampionPoints("player")
		if gcp < GetChampionPointsPlayerProgressionCap() then
			gcp = GetChampionPointsPlayerProgressionCap()
		end
		gmaxxp = GetNumChampionXPInChampionPoint(gcp)
  else
		gmaxxp = GetUnitXPMax("player")
  end      
	
  if IsUnitChampion("player") then
    gxp = GetPlayerChampionXP()
  else
    gxp = GetUnitXP("player")
  end  
  
  -- gxpleft = gmaxxp - gxp
  gxppercleft = (gxp/gmaxxp)*100
  gxpperc = 100 - gxppercleft
  gxpperc = math.floor(gxpperc)
  
end


function AoAa.bags()
  	usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
		-- usedSlots = maxSlots - usedSlots
end

function AoAa.research()
    bsSlots = GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_BLACKSMITHING)
    clSlots = GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_CLOTHIER)
    wwSlots = GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_WOODWORKING)
    jwSlots = GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_JEWELRYCRAFTING)
    d("MaxBlacksmithing: " .. bsSlots)
    d("MaxClothier: " .. clSlots)
    d("MaxWoodworking: " .. wwSlots)
    d("MaxJewelry: " .. jwSlots)    
end

function AoAa.commfps()
    local framerate = GetFramerate()
    countfps = math.floor(framerate)
    d("FPS: " .. countfps)
end

function AoAa.fps()
    local framerate = GetFramerate()
    countfps = math.floor(framerate)
end

function AoAa.commlatency()
    local latency = GetLatency()
    countlat = math.floor(latency)
    d("Latency: " .. countlat)
end

function AoAa.latency()
    local latency = GetLatency()
    countlat = math.floor(latency)
end



function AoAa.OnUpdate()
    AoAa.balance()
    AoAa.bags()
    AoAa.horsetimer()
    AoAa.xpperc()
    AoAa.fps()
    AoAa.latency()
    
    AoAaIndicatorGold:SetText(string.format(gold))
    AoAaIndicatorTelvar:SetText(string.format(telvar))
    AoAaIndicatorTC:SetText(string.format(crystal))
    AoAaIndicatorAP:SetText(string.format(ap))
    AoAaIndicatorWritv:SetText(string.format(writv))
    AoAaIndicatorLvl:SetText(string.format(lvl))
    AoAaIndicatorCP:SetText(string.format(cp))
    AoAaIndicatorBag:SetText(string.format(usedSlots))
    AoAaIndicatorBagTot:SetText(string.format(maxSlots))
    AoAaIndicatorMount:SetText(string.format(mountlbltxt))
    AoAaIndicatorXP:SetText(string.format(gxpperc))
    AoAaIndicatorFPS:SetText(string.format(countfps))
    AoAaIndicatorLAT:SetText(string.format(countlat))
end

function AoAa.CreateSettingsWindow()
  panelData = {
    type = "panel",
    name = "A Super Useful Gadget Bar",
    displayName = "A Super Useful Gadget Bar",
    author = "Golnebo",
    version = AoAa.version,
    slashCommand = "/sgb",
    registerForRefresh = true,
    registerForDefaults = true,
  } 
  
  cntrlOptionsPanel = LAM2:RegisterAddonPanel("AoAa_ASUGB", panelData)
  
  optionsData = {
      [1] = {
              type = "header",
              name = "House Settings",
            },
      [2] = {
              type = "description",
              text = "Please enter the data for House 1.",
      },
      [3] = {
              type = "slider",
              name = "Select Unique ID",
              tooltip = "Select the house ID.",
              min = 1,
              max = 1000,
              step = 1,
              default = 300,
              getFunc = function() return AoAa.savedVariables.House1 end,
              setFunc = function(newValue) 
                AoAa.savedVariables.House1 = newValue
                IDbarnr = newValue
                AoAa.House1(newValue, AoAa.savedVariables.House1)
              end,
      },
      [4] = {
              type = "editbox",
              name = "User ID House 1",
              tooltip = "Enter the @username for House 1.",
              getFunc = function() return AoAa.savedVariables.House1U end,
              setFunc = function(newValue) 
                  print(text)
                  AoAa.savedVariables.House1U = newValue
                  IDbar = newValue
                  AoAa.House1U(newValue, AoAa.savedVariables.House1U)
                end,
              isMultiline = false,	--boolean
              width = "half",	--or "half" (optional)
              default = "",	--(optional)
              warning = "Will need to reload the UI.",	--(optional)
      },
      [5] = {
              type = "description",
              text = "Please enter the data for House 2.",
      },
      [6] = {
              type = "slider",
              name = "Select Unique ID",
              tooltip = "Select the house ID.",
              min = 1,
              max = 1000,
              step = 1,
              default = 300,
              getFunc = function() return AoAa.savedVariables.House2 end,
              setFunc = function(newValue) 
                AoAa.savedVariables.House2 = newValue
                IDguildhallnr = newValue
                AoAa.House2(newValue, AoAa.savedVariables.House2)
              end,
      },
      [7] = {
              type = "editbox",
              name = "User ID House 2",
              tooltip = "Enter the @username for House 2.",
              getFunc = function() return AoAa.savedVariables.House2U end,
              setFunc = function(newValue) 
                  print(text)
                  AoAa.savedVariables.House2U = newValue
                  IDguildhall = newValue
                  AoAa.House2U(newValue, AoAa.savedVariables.House2U)
                end,
              isMultiline = false,	--boolean
              width = "half",	--or "half" (optional)
              default = "",	--(optional)
              warning = "Will need to reload the UI.",	--(optional)
      },     
      [8] = {
              type = "description",
              text = "Please enter the data for House 3.",
      },
      [9] = {
              type = "slider",
              name = "Select Unique ID",
              tooltip = "Select the house ID.",
              min = 1,
              max = 1000,
              step = 1,
              default = 300,
              getFunc = function() return AoAa.savedVariables.House3 end,
              setFunc = function(newValue) 
                AoAa.savedVariables.House3 = newValue
                IDhorrornr = newValue
                AoAa.House3(newValue, AoAa.savedVariables.House3)
              end,
      },
      [10] = {
              type = "editbox",
              name = "User ID House 3",
              tooltip = "Enter the @username for House 3.",
              getFunc = function() return AoAa.savedVariables.House3U end,
              setFunc = function(newValue) 
                  print(text)
                  AoAa.savedVariables.House3U = newValue
                  IDhorror = newValue
                  AoAa.House3U(newValue, AoAa.savedVariables.House3U)
                end,
              isMultiline = false,	--boolean
              width = "half",	--or "half" (optional)
              default = "",	--(optional)
              warning = "Will need to reload the UI.",	--(optional)
      },
  }
  LAM2:RegisterOptionControls("AoAa_ASUGB", optionsData)
end

SLASH_COMMANDS["/sgbhelp"] = AoAa.help
SLASH_COMMANDS["/sgbport"] = AoAa.port
SLASH_COMMANDS["/sgbgui"] = AoAa.gui
SLASH_COMMANDS["/sgbmoney"] = AoAa.moneys
SLASH_COMMANDS["/sgblvl"] = AoAa.level
SLASH_COMMANDS["/sgbgetid"] = AoAa.getid
SLASH_COMMANDS["/sgbbagspace"] = AoAa.bagspace
SLASH_COMMANDS["/sgbhorse"] = AoAa.horse
SLASH_COMMANDS["/sgbres"] = AoAa.research
SLASH_COMMANDS["/sgbxp"] = AoAa.getxp
SLASH_COMMANDS["/sgbmaxxp"] = AoAa.getxpmax
SLASH_COMMANDS["/sgbfps"] = AoAa.commfps
SLASH_COMMANDS["/sgblatency"] = AoAa.commlatency

AoAa.activatorText = "" -- setting this up for later use


EVENT_MANAGER:RegisterForEvent(AoAa.name, EVENT_ADD_ON_LOADED, AoAa.OnAddOnLoaded)