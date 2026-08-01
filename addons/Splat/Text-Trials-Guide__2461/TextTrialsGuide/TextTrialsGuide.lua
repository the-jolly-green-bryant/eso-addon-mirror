TTGAddon = {}
TTGAddon.name = "TextTrialsGuide"
TTGAddon.variableVersion = 3
TTGAddon.Default = {
	GuidePlacement = "Personal Chat",
	GuideColour = "|ceeeeee",
	DisplayCMDChat = true,
	CommandLength = 5,
	OffsetX = 200,
	OffsetY = 200,
	Trial = "notusedyet",
	BgWidth = 310,
	ContainerWidth = 305,
	BgHeight = 146,
	ContainerHeight = 116,
}

local stdColor = "|c82FA58"
local white = "|ceeeeee"
local blue = "|cAFD3FF"
local red = "|cff7d77"
local green = "|c77ff7a"
local yellow = "|cf1ff77"
local gray = "|cd5d1d1"
local orange = "|cFF7A00"

currentplace = "notusedyet"
currentcolour = "notusedyet"
currentCMDChat = "notusedyet"
currentcommandlength = "notusedyet"
currentTrial = "notusedyet"

function TTGAddon:SetupSettings()
  local LAM2 = LibAddonMenu2
  if not LAM2 and LibStub then LAM2 = LibStub("LibAddonMenu-2.0") end
  if not LAM2 then d("Library LibAddonMenu is missing!") return end
  local panelData = {
      type = "panel",
      name = "Text Trials Guide",
      displayName = "Text Trials Guide",
      author = "Splat, Thanks to the members of TOM Guilds",
      version = "1.2.8",
      slashCommand = "/ttg";
      registerForRefresh = true,
      website = "https://www.esoui.com/downloads/info2461-TextTrialsGuide.html",
      feedback = "https://www.esoui.com/portal.php?&id=300",
      translation = "https://www.esoui.com/portal.php?&id=300&pageid=62",
  }
  LAM2:RegisterAddonPanel("TTGAddonOptions", panelData)
  local optionsData = {
     [1] = {
	  type = "divider",
     },
     [2] = {
          type = "dropdown",
          name = GetString(TTG_AP_DD_NAME),
          tooltip = GetString(TTG_AP_DD_TOOLTIP),
	  default = GetString(TTG_AP_DD_DEFAULT),
          choices = dd_choices,
	  choicesValues = dd_choices_values,
	  scrollable = "true",
          getFunc = function() return TTGAddon.savedVariables.GuidePlacement end,
          setFunc = function(varplace)
		    TTGAddon.savedVariables.GuidePlacement = varplace
		    currentplace = varplace
		    end,
     },
     [3] = {
	  type = "divider",
     },
     [4] = {
          type = "dropdown",
          name = GetString(TTG_AP_DD2_NAME),
          tooltip = GetString(TTG_AP_DD2_TOOLTIP),
	  default = GetString(TTG_AP_DD2_DEFAULT),
          choices = dd2_choices,
	  choicesValues = dd2_choices_values,
	  scrollable = "true",
          getFunc = function() return TTGAddon.savedVariables.GuideColour end,
          setFunc = function(varcolour)
		    TTGAddon.savedVariables.GuideColour = varcolour
		    currentcolour = varcolour
		    end,
     },
     [5] = {
	  type = "divider",
     },
     [6] = {
	  type = "description",
	  text = GetString(TTG_AP_MAIN_DESC),
     },
     [7] = {
	  type = "divider",
     },
     [8] = {
          type = "description",
          text = GetString(TTG_AP_SLD_DESC),
     },
     [9] = {
          type = "slider",
          name = GetString(TTG_AP_SLD_NAME),
          min = 4,
          max = 60,
          default = 10,
          getFunc = function() return TTGAddon.savedVariables.CommandLength end,
          setFunc = function(mynewValue)
              TTGAddon.savedVariables.CommandLength = mynewValue
	      currentcommandlength = mynewValue 
		if currentTrial == "notusedyet" then
		   currentTrial = TTGAddon.savedVariables.Trial
		end
		if currentTrial == "notusedyet" then
		   bglen = (146)
		   contlen = (116)
		elseif currentTrial == "nso" then
		   if mynewValue > 29 then
	  	     bglen = ((24 * 28) + 50)
 		     contlen = ((24 * 28) + 16)
	    	   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 16)
		   end
		elseif currentTrial == "vso" then
		   if mynewValue > 37 then
	  	     bglen = ((24 * 37) + 50)
 		     contlen = ((24 * 37) + 16)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 16)
		   end
		elseif currentTrial == "naa" then
		   if mynewValue > 23 then
	  	     bglen = ((24 * 23) + 45)
 		     contlen = ((24 * 23) + 12)
		   else
                     bglen = ((24 * mynewValue) + 45)
                     contlen = ((24 * mynewValue) + 12)
		   end
		elseif currentTrial == "vaa" then
		   if mynewValue > 29 then
	  	     bglen = ((24 * 28) + 48)
 		     contlen = ((24 * 28) + 19)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nhrc" then
		   if mynewValue > 17 then
	  	     bglen = ((24 * 17) + 45)
 		     contlen = ((24 * 17) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 12)
		   end
		elseif currentTrial == "vhrc" then
		   if mynewValue > 22 then
	  	     bglen = ((24 * 22) + 45)
 		     contlen = ((24 * 22) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nmol" then
		   if mynewValue > 55 then
	  	     bglen = ((24 * 53) + 50)
 		     contlen = ((24 * 53) + 17)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "vmol" then
		   if mynewValue > 59 then
	  	     bglen = ((24 * 58) + 45)
 		     contlen = ((24 * 58) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nas" then
		   if mynewValue > 29 then
	  	     bglen = ((24 * 28) + 50)
 		     contlen = ((24 * 28) + 17)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "vas" then
		   if mynewValue > 32 then
	  	     bglen = ((24 * 31) + 50)
 		     contlen = ((24 * 31) + 17)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "ncr" then
		   if mynewValue > 13 then
	  	     bglen = ((24 * 13) + 45)
 		     contlen = ((24 * 13) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "vcr" then
		   if mynewValue > 24 then
	  	     bglen = ((24 * 24) + 45)
 		     contlen = ((24 * 24) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nhof" then
		   if mynewValue > 46 then
	  	     bglen = ((24 * 45) + 45)
 		     contlen = ((24 * 45) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "vhof" then
		   if mynewValue > 52 then
	  	     bglen = ((24 * 51) + 45)
 		     contlen = ((24 * 51) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nss" then
		   if mynewValue > 31 then
	  	     bglen = ((24 * 31) + 50)
 		     contlen = ((24 * 31) + 16)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 16)
		   end
		elseif currentTrial == "vss" then
		   if mynewValue > 42 then
	  	     bglen = ((24 * 42) + 45)
 		     contlen = ((24 * 42) + 12)
		   else
                     bglen = ((24 * mynewValue) + 48)
                     contlen = ((24 * mynewValue) + 14)
		   end
		elseif currentTrial == "nka" then
		   if mynewValue > 38 then
	  	     bglen = ((24 * 38) + 50)
 		     contlen = ((24 * 38) + 16)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 16)
		   end
		elseif currentTrial == "vka" then
		   if mynewValue > 49 then
	  	     bglen = ((24 * 49) + 45)
 		     contlen = ((24 * 49) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "nrg" then
		   if mynewValue > 38 then
	  	     bglen = ((24 * 38) + 50)
 		     contlen = ((24 * 38) + 16)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 16)
		   end
		elseif currentTrial == "vrg" then
		   if mynewValue > 53 then
	  	     bglen = ((24 * 52) + 45)
 		     contlen = ((24 * 52) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		elseif currentTrial == "vdsa" then
		   if mynewValue > 23 then
	  	     bglen = ((24 * 23) + 45)
 		     contlen = ((24 * 23) + 12)
		   else
                     bglen = ((24 * mynewValue) + 50)
                     contlen = ((24 * mynewValue) + 17)
		   end
		else
                  bglen = ((24 * mynewValue) + 50)
                  contlen = ((24 * mynewValue) + 17)
		end
              TTGAddonIndicatorBg:SetHeight(bglen)
              TTGAddonIndicatorContainer:SetHeight(contlen)
          end
        },
     [10] = {
          type = "description",
          text = GetString(TTG_AP_TOGGLE_DESC),
     },
     [11] = {
	type = "checkbox",
	name = GetString(TTG_AP_TOGGLE_NAME),
	tooltip = GetString(TTG_AP_TOGGLE_TOOLTIP),
	default = true,
	getFunc = function() return TTGAddon.savedVariables.DisplayCMDChat end,
	setFunc = function(mynewValue2) 
		TTGAddon.savedVariables.DisplayCMDChat = mynewValue2
		currentCMDChat = mynewValue2  
        end,
      },
}
  LAM2:RegisterOptionControls("TTGAddonOptions", optionsData)
end

------------ UI ELEMENTS -------------

local function HideIfVisible()
    if TTGAddon.savedVariables.hiddenUI == false then
        TTGAddonIndicator:SetHidden(true)
    end
end
 
local function ShowIfVisible()
    if TTGAddon.savedVariables.hiddenUI == false then
        TTGAddonIndicator:SetHidden(false)
    end
end

function TTGAddon:RestorePosition()
    TTGAddonIndicator:ClearAnchors()
    TTGAddonIndicator:SetHidden(TTGAddon.savedVariables.hiddenUI)
    TTGAddonIndicator:SetTopmost(true)
    TTGAddonIndicator:BringWindowToTop(true)
    TTGAddonIndicator:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        TTGAddon.savedVariables.OffsetX,
        TTGAddon.savedVariables.OffsetY
    )
end

function TTGAddon.ToggleWindow()
    if not TTGAddon.savedVariables.hiddenUI == false then
        TTGAddon.savedVariables.hiddenUI = false
        TTGAddonIndicator:SetHidden(false)
        TTGAddonIndicator:SetTopmost(true)
        TTGAddonIndicator:BringWindowToTop(true)
    else
        TTGAddon.savedVariables.hiddenUI = true
        TTGAddonIndicator:SetHidden(true)
    end
end

--------------------------------------

function TTGAddon:Initialize()
  CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions()
  SLASH_COMMANDS["/nso"] = TTGAddon.Slashnso
  SLASH_COMMANDS["/naa"] = TTGAddon.Slashnaa
  SLASH_COMMANDS["/nhrc"] = TTGAddon.Slashnhrc
  SLASH_COMMANDS["/nmol"] = TTGAddon.Slashnmol
  SLASH_COMMANDS["/nas"] = TTGAddon.Slashnas
  SLASH_COMMANDS["/ncr"] = TTGAddon.Slashncr
  SLASH_COMMANDS["/nhof"] = TTGAddon.Slashnhof
  SLASH_COMMANDS["/nss"] = TTGAddon.Slashnss
  SLASH_COMMANDS["/nka"] = TTGAddon.Slashnka
  SLASH_COMMANDS["/nrg"] = TTGAddon.Slashnrg
  SLASH_COMMANDS["/vso"] = TTGAddon.Slashvso
  SLASH_COMMANDS["/vaa"] = TTGAddon.Slashvaa
  SLASH_COMMANDS["/vhrc"] = TTGAddon.Slashvhrc
  SLASH_COMMANDS["/vmol"] = TTGAddon.Slashvmol
  SLASH_COMMANDS["/vas"] = TTGAddon.Slashvas
  SLASH_COMMANDS["/vcr"] = TTGAddon.Slashvcr
  SLASH_COMMANDS["/vhof"] = TTGAddon.Slashvhof
  SLASH_COMMANDS["/vss"] = TTGAddon.Slashvss
  SLASH_COMMANDS["/vka"] = TTGAddon.Slashvka
  SLASH_COMMANDS["/vrg"] = TTGAddon.Slashvrg
  SLASH_COMMANDS["/vdsa"] = TTGAddon.Slashvdsa
  SLASH_COMMANDS["/ttgui"] = TTGAddon.ToggleWindow
  TTGAddon.savedVariables = ZO_SavedVars:NewAccountWide("TTGSavedVariables", TTGAddon.variableVersion, nil, TTGAddon.Default)
  TTGAddon:SetupSettings()
  wheretoplace = TTGAddon.savedVariables.GuidePlacement
  colourtouse = TTGAddon.savedVariables.GuideColour
  displayCmdInChat = TTGAddon.savedVariables.DisplayCMDChat
  TTGAddon:RestorePosition()
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        ShowIfVisible()
    end)
  if TTGAddon.savedVariables.Trial ~= "notusedyet" then
      if TTGAddon.savedVariables.Trial == "nso" then
	 TTGAddon.WindowNSO()
      end
      if TTGAddon.savedVariables.Trial == "naa" then
	 TTGAddon.WindowNAA()
      end
      if TTGAddon.savedVariables.Trial == "nhrc" then
	 TTGAddon.WindowNHRC()
      end
      if TTGAddon.savedVariables.Trial == "nmol" then
	 TTGAddon.WindowNMOL()
      end
      if TTGAddon.savedVariables.Trial == "nas" then
	 TTGAddon.WindowNAS()
      end
      if TTGAddon.savedVariables.Trial == "ncr" then
	 TTGAddon.WindowNCR()
      end
      if TTGAddon.savedVariables.Trial == "nhof" then
	 TTGAddon.WindowNHOF()
      end
      if TTGAddon.savedVariables.Trial == "nss" then
	 TTGAddon.WindowNSS()
      end
      if TTGAddon.savedVariables.Trial == "nka" then
	 TTGAddon.WindowNKA()
      end
      if TTGAddon.savedVariables.Trial == "nrg" then
	 TTGAddon.WindowNRG()
      end
      if TTGAddon.savedVariables.Trial == "vso" then
	 TTGAddon.WindowVSO()
      end
      if TTGAddon.savedVariables.Trial == "vaa" then
	 TTGAddon.WindowVAA()
      end
      if TTGAddon.savedVariables.Trial == "vhrc" then
	 TTGAddon.WindowVHRC()
      end
      if TTGAddon.savedVariables.Trial == "vmol" then
	 TTGAddon.WindowVMOL()
      end
      if TTGAddon.savedVariables.Trial == "vas" then
	 TTGAddon.WindowVAS()
      end
      if TTGAddon.savedVariables.Trial == "vcr" then
	 TTGAddon.WindowVCR()
      end
      if TTGAddon.savedVariables.Trial == "vhof" then
	 TTGAddon.WindowVHOF()
      end
      if TTGAddon.savedVariables.Trial == "vss" then
	 TTGAddon.WindowVSS()
      end
      if TTGAddon.savedVariables.Trial == "vka" then
	 TTGAddon.WindowVKA()
      end
      if TTGAddon.savedVariables.Trial == "vrg" then
	 TTGAddon.WindowVRG()
      end
      if TTGAddon.savedVariables.Trial == "vdsa" then
	 TTGAddon.WindowVDSA()
      end
  else
    TTGAddonIndicatorBg:SetWidth(310)
    TTGAddonIndicatorContainer:SetWidth(305)
    TTGAddonIndicatorBg:SetHeight(146)
    TTGAddonIndicatorContainer:SetHeight(116)
    TTGAddonIndicatorData:SetText(GetString(TTG_AP_WINDOW_DEFAULT))
  end
  EVENT_MANAGER:UnregisterForEvent(TTGAddon.name, EVENT_ADD_ON_LOADED)
end

function TTGAddon.SaveLoc()
    TTGAddon.savedVariables.OffsetX = TTGAddonIndicator:GetLeft()
    TTGAddon.savedVariables.OffsetY = TTGAddonIndicator:GetTop()
end


-- SANCTUM OPHIDIA NORMAL

function TTGAddon.WindowNSO()
TTGAddonIndicatorData:SetText("/nso 1\n/nso 2\n/nso 3\n/nso 4\n/nso 5\n/nso 6\n/nso 7\n/nso 8\n/nso 9\n/nso 10\n/nso 11\n/nso 12\n/nso 13\n/nso 14\n/nso 15\n/nso 16\n/nso 17\n/nso 18\n/nso 19\n/nso 20\n/nso 21\n/nso 22\n/nso 23\n/nso 24\n/nso 25\n/nso 26\n/nso 27\n/nso 28\n/nso 29\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NSO1_D ) .. GetString( TTG_NSO2_D ) .. GetString( TTG_NSO3_D ) .. GetString( TTG_NSO4_D ) .. GetString( TTG_NSO5_D ) .. GetString( TTG_NSO6_D ) .. GetString( TTG_NSO7_D ) .. GetString( TTG_NSO8_D ) .. GetString( TTG_NSO9_D ) .. GetString( TTG_NSO10_D ) .. GetString( TTG_NSO11_D ) .. GetString( TTG_NSO12_D ) .. GetString( TTG_NSO13_D ) .. GetString( TTG_NSO14_D ) .. GetString( TTG_NSO15_D ) .. GetString( TTG_NSO16_D ) .. GetString( TTG_NSO17_D ) .. GetString( TTG_NSO18_D ) .. GetString( TTG_NSO19_D ) .. GetString( TTG_NSO20_D ) .. GetString( TTG_NSO21_D ) .. GetString( TTG_NSO22_D ) .. GetString( TTG_NSO23_D ) .. GetString( TTG_NSO24_D ) .. GetString( TTG_NSO25_D ) .. GetString( TTG_NSO26_D ) .. GetString( TTG_NSO27_D ) .. GetString( TTG_NSO28_D ) .. GetString( TTG_NSO29_D ))
TTGAddonIndicatorBg:SetWidth(310)
TTGAddonIndicatorContainer:SetWidth(305)
TTGAddon.savedVariables.BgWidth = 310
TTGAddon.savedVariables.ContainerWidth = 305
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 29 then
	   bglen = ((24 * 28) + 50)
 	   contlen = ((24 * 28) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 29 then
		       	   bglen = ((24 * 28) + 50)
		           contlen = ((24 * 28) + 16)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  		       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 16)
   	     	   TTGAddonIndicatorBg:SetHeight(bglen)
  	 		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 16)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnso(slashnumber)
TTGAddon.savedVariables.Trial = "nso"
currentTrial = "nso"
TTGAddon.WindowNSO()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NSO1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NSO2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NSO3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NSO4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NSO5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NSO6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NSO7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NSO8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NSO9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NSO10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NSO11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NSO12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NSO13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NSO14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NSO15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NSO16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NSO17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NSO18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NSO19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NSO20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NSO21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NSO22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NSO23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NSO24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NSO25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NSO26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NSO27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NSO28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NSO29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nso 1" .. green .. GetString( TTG_NSO1_D ) .. orange .. "/nso 2" .. green .. GetString( TTG_NSO2_D ) .. orange .. "/nso 3" .. green .. GetString( TTG_NSO3_D ) .. orange .. "/nso 4" .. green .. GetString( TTG_NSO4_D ) .. orange .. "/nso 5" .. green .. GetString( TTG_NSO5_D ) .. orange .. "/nso 6" .. green .. GetString( TTG_NSO6_D ) .. orange .. "/nso 7" .. green .. GetString( TTG_NSO7_D ) .. orange .. "/nso 8" .. green .. GetString( TTG_NSO8_D ) .. orange .. "/nso 9" .. green .. GetString( TTG_NSO9_D ) .. orange .. "/nso 10" .. green .. GetString( TTG_NSO10_D ) .. orange .. "/nso 11" .. green .. GetString( TTG_NSO11_D ) .. orange .. "/nso 12" .. green .. GetString( TTG_NSO12_D ) .. orange .. "/nso 13" .. green .. GetString( TTG_NSO13_D ) .. orange .. "/nso 14" .. green .. GetString( TTG_NSO14_D ) .. orange .. "/nso 15" .. green .. GetString( TTG_NSO15_D ) .. orange .. "/nso 16" .. green .. GetString( TTG_NSO16_D ) .. orange .. "/nso 17" .. green .. GetString( TTG_NSO17_D ) .. orange .. "/nso 18" .. green .. GetString( TTG_NSO18_D ) .. orange .. "/nso 19" .. green .. GetString( TTG_NSO19_D ) .. orange .. "/nso 20" .. green .. GetString( TTG_NSO20_D ) .. orange .. "/nso 21" .. green .. GetString( TTG_NSO21_D ) .. orange .. "/nso 22" .. green .. GetString( TTG_NSO22_D ) .. orange .. "/nso 23" .. green .. GetString( TTG_NSO23_D ) .. orange .. "/nso 24" .. green .. GetString( TTG_NSO24_D ) .. orange .. "/nso 25" .. green .. GetString( TTG_NSO25_D ) .. orange .. "/nso 26" .. green .. GetString( TTG_NSO26_D ) .. orange .. "/nso 27" .. green .. GetString( TTG_NSO27_D ) .. orange .. "/nso 28" .. green .. GetString( TTG_NSO28_D ) .. orange .. "/nso 29" .. green .. GetString( TTG_NSO29_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NSO1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NSO2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NSO3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NSO4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NSO5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NSO6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NSO7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NSO8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NSO9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NSO10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NSO11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NSO12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NSO13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NSO14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NSO15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NSO16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NSO17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NSO18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NSO19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NSO20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NSO21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NSO22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NSO23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NSO24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NSO25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NSO26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NSO27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NSO28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NSO29 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nso 1" .. green .. GetString( TTG_NSO1_D ) .. orange .. "/nso 2" .. green .. GetString( TTG_NSO2_D ) .. orange .. "/nso 3" .. green .. GetString( TTG_NSO3_D ) .. orange .. "/nso 4" .. green .. GetString( TTG_NSO4_D ) .. orange .. "/nso 5" .. green .. GetString( TTG_NSO5_D ) .. orange .. "/nso 6" .. green .. GetString( TTG_NSO6_D ) .. orange .. "/nso 7" .. green .. GetString( TTG_NSO7_D ) .. orange .. "/nso 8" .. green .. GetString( TTG_NSO8_D ) .. orange .. "/nso 9" .. green .. GetString( TTG_NSO9_D ) .. orange .. "/nso 10" .. green .. GetString( TTG_NSO10_D ) .. orange .. "/nso 11" .. green .. GetString( TTG_NSO11_D ) .. orange .. "/nso 12" .. green .. GetString( TTG_NSO12_D ) .. orange .. "/nso 13" .. green .. GetString( TTG_NSO13_D ) .. orange .. "/nso 14" .. green .. GetString( TTG_NSO14_D ) .. orange .. "/nso 15" .. green .. GetString( TTG_NSO15_D ) .. orange .. "/nso 16" .. green .. GetString( TTG_NSO16_D ) .. orange .. "/nso 17" .. green .. GetString( TTG_NSO17_D ) .. orange .. "/nso 18" .. green .. GetString( TTG_NSO18_D ) .. orange .. "/nso 19" .. green .. GetString( TTG_NSO19_D ) .. orange .. "/nso 20" .. green .. GetString( TTG_NSO20_D ) .. orange .. "/nso 21" .. green .. GetString( TTG_NSO21_D ) .. orange .. "/nso 22" .. green .. GetString( TTG_NSO22_D ) .. orange .. "/nso 23" .. green .. GetString( TTG_NSO23_D ) .. orange .. "/nso 24" .. green .. GetString( TTG_NSO24_D ) .. orange .. "/nso 25" .. green .. GetString( TTG_NSO25_D ) .. orange .. "/nso 26" .. green .. GetString( TTG_NSO26_D ) .. orange .. "/nso 27" .. green .. GetString( TTG_NSO27_D ) .. orange .. "/nso 28" .. green .. GetString( TTG_NSO28_D ) .. orange .. "/nso 29" .. green .. GetString( TTG_NSO29_D ))
	end
    end
  end
end


-- SANCTUM OPHIDIA VETERAN

function TTGAddon.WindowVSO()
TTGAddonIndicatorData:SetText("/vso 1\n/vso 2\n/vso 3\n/vso 4\n/vso 5\n/vso 6\n/vso 7\n/vso 8\n/vso 9\n/vso 10\n/vso 11\n/vso 12\n/vso 13\n/vso 14\n/vso 15\n/vso 16\n/vso 17\n/vso 18\n/vso 19\n/vso 20\n/vso 21\n/vso 22\n/vso 23\n/vso 24\n/vso 25\n/vso 26\n/vso 27\n/vso 28\n/vso 29\n/vso 30\n/vso 31\n/vso 32\n/vso 33\n/vso 34\n/vso 35\n/vso 36\n/vso 37\n/vso 38\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VSO1_D ) .. GetString( TTG_VSO2_D ) .. GetString( TTG_VSO3_D ) .. GetString( TTG_VSO4_D ) .. GetString( TTG_VSO5_D ) .. GetString( TTG_VSO6_D ) .. GetString( TTG_VSO7_D ) .. GetString( TTG_VSO8_D ) .. GetString( TTG_VSO9_D ) .. GetString( TTG_VSO10_D ) .. GetString( TTG_VSO11_D ) .. GetString( TTG_VSO12_D ) .. GetString( TTG_VSO13_D ) .. GetString( TTG_VSO14_D ) .. GetString( TTG_VSO15_D ) .. GetString( TTG_VSO16_D ) .. GetString( TTG_VSO17_D ) .. GetString( TTG_VSO18_D ) .. GetString( TTG_VSO19_D ) .. GetString( TTG_VSO20_D ) .. GetString( TTG_VSO21_D ) .. GetString( TTG_VSO22_D ) .. GetString( TTG_VSO23_D ) .. GetString( TTG_VSO24_D ) .. GetString( TTG_VSO25_D ) .. GetString( TTG_VSO26_D ) .. GetString( TTG_VSO27_D ) .. GetString( TTG_VSO28_D ) .. GetString( TTG_VSO29_D ) .. GetString( TTG_VSO30_D ) .. GetString( TTG_VSO31_D ) .. GetString( TTG_VSO32_D ) .. GetString( TTG_VSO33_D ) .. GetString( TTG_VSO34_D ) .. GetString( TTG_VSO35_D ) .. GetString( TTG_VSO36_D ) .. GetString( TTG_VSO37_D ) .. GetString( TTG_VSO38_D ))
TTGAddonIndicatorBg:SetWidth(310)
TTGAddonIndicatorContainer:SetWidth(305)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 37 then
	   bglen = ((24 * 37) + 50)
 	   contlen = ((24 * 37) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 37 then
		       	   bglen = ((24 * 37) + 50)
		           contlen = ((24 * 37) + 16)
		       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
 		       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 16)
 		       	   TTGAddonIndicatorBg:SetHeight(bglen)
  	 		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end	
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 16)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvso(slashnumber)
TTGAddon.savedVariables.Trial = "vso"
currentTrial = "vso"
TTGAddon.WindowVSO()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VSO1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VSO2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VSO3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VSO4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VSO5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VSO6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VSO7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VSO8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VSO9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VSO10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VSO11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VSO12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VSO13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VSO14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VSO15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VSO16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VSO17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VSO18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VSO19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VSO20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VSO21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VSO22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VSO23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VSO24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VSO25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VSO26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VSO27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VSO28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VSO29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VSO30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VSO31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VSO32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VSO33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VSO34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VSO35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VSO36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VSO37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VSO38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vso 1" .. green .. GetString( TTG_VSO1_D ) .. orange .. "/vso 2" .. green .. GetString( TTG_VSO2_D ) .. orange .. "/vso 3" .. green .. GetString( TTG_VSO3_D ) .. orange .. "/vso 4" .. green .. GetString( TTG_VSO4_D ) .. orange .. "/vso 5" .. green .. GetString( TTG_VSO5_D ) .. orange .. "/vso 6" .. green .. GetString( TTG_VSO6_D ) .. orange .. "/vso 7" .. green .. GetString( TTG_VSO7_D ) .. orange .. "/vso 8" .. green .. GetString( TTG_VSO8_D ) .. orange .. "/vso 9" .. green .. GetString( TTG_VSO9_D ) .. orange .. "/vso 10" .. green .. GetString( TTG_VSO10_D ) .. orange .. "/vso 11" .. green .. GetString( TTG_VSO11_D ) .. orange .. "/vso 12" .. green .. GetString( TTG_VSO12_D ) .. orange .. "/vso 13" .. green .. GetString( TTG_VSO13_D ) .. orange .. "/vso 14" .. green .. GetString( TTG_VSO14_D ) .. orange .. "/vso 15" .. green .. GetString( TTG_VSO15_D ) .. orange .. "/vso 16" .. green .. GetString( TTG_VSO16_D ) .. orange .. "/vso 17" .. green .. GetString( TTG_VSO17_D ) .. orange .. "/vso 18" .. green .. GetString( TTG_VSO18_D ) .. orange .. "/vso 19" .. green .. GetString( TTG_VSO19_D ) .. orange .. "/vso 20" .. green .. GetString( TTG_VSO20_D ) .. orange .. "/vso 21" .. green .. GetString( TTG_VSO21_D ) .. orange .. "/vso 22" .. green .. GetString( TTG_VSO22_D ) .. orange .. "/vso 23" .. green .. GetString( TTG_VSO23_D ) .. orange .. "/vso 24" .. green .. GetString( TTG_VSO24_D ) .. orange .. "/vso 25" .. green .. GetString( TTG_VSO25_D ) .. orange .. "/vso 26" .. green .. GetString( TTG_VSO26_D ) .. orange .. "/vso 27" .. green .. GetString( TTG_VSO27_D ) .. orange .. "/vso 28" .. green .. GetString( TTG_VSO28_D ) .. orange .. "/vso 29" .. green .. GetString( TTG_VSO29_D ) .. orange .. "/vso 30" .. green .. GetString( TTG_VSO30_D ))
     d(orange .. "/vso 31" .. green .. GetString( TTG_VSO31_D ) .. orange .. "/vso 32" .. green .. GetString( TTG_VSO32_D ) .. orange .. "/vso 33" .. green .. GetString( TTG_VSO33_D ) .. orange .. "/vso 34" .. green .. GetString( TTG_VSO34_D ) .. orange .. "/vso 35" .. green .. GetString( TTG_VSO35_D ) .. orange .. "/vso 36" .. green .. GetString( TTG_VSO36_D ) .. orange .. "/vso 37" .. green .. GetString( TTG_VSO37_D ) .. orange .. "/vso 38" .. green .. GetString( TTG_VSO38_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VSO1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VSO2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VSO3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VSO4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VSO5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VSO6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VSO7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VSO8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VSO9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VSO10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VSO11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VSO12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VSO13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VSO14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VSO15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VSO16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VSO17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VSO18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VSO19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VSO20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VSO21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VSO22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VSO23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VSO24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VSO25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VSO26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VSO27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VSO28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VSO29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VSO30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VSO31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VSO32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VSO33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VSO34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VSO35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VSO36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VSO37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VSO38 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vso 1" .. green .. GetString( TTG_VSO1_D ) .. orange .. "/vso 2" .. green .. GetString( TTG_VSO2_D ) .. orange .. "/vso 3" .. green .. GetString( TTG_VSO3_D ) .. orange .. "/vso 4" .. green .. GetString( TTG_VSO4_D ) .. orange .. "/vso 5" .. green .. GetString( TTG_VSO5_D ) .. orange .. "/vso 6" .. green .. GetString( TTG_VSO6_D ) .. orange .. "/vso 7" .. green .. GetString( TTG_VSO7_D ) .. orange .. "/vso 8" .. green .. GetString( TTG_VSO8_D ) .. orange .. "/vso 9" .. green .. GetString( TTG_VSO9_D ) .. orange .. "/vso 10" .. green .. GetString( TTG_VSO10_D ) .. orange .. "/vso 11" .. green .. GetString( TTG_VSO11_D ) .. orange .. "/vso 12" .. green .. GetString( TTG_VSO12_D ) .. orange .. "/vso 13" .. green .. GetString( TTG_VSO13_D ) .. orange .. "/vso 14" .. green .. GetString( TTG_VSO14_D ) .. orange .. "/vso 15" .. green .. GetString( TTG_VSO15_D ) .. orange .. "/vso 16" .. green .. GetString( TTG_VSO16_D ) .. orange .. "/vso 17" .. green .. GetString( TTG_VSO17_D ) .. orange .. "/vso 18" .. green .. GetString( TTG_VSO18_D ) .. orange .. "/vso 19" .. green .. GetString( TTG_VSO19_D ) .. orange .. "/vso 20" .. green .. GetString( TTG_VSO20_D ) .. orange .. "/vso 21" .. green .. GetString( TTG_VSO21_D ) .. orange .. "/vso 22" .. green .. GetString( TTG_VSO22_D ) .. orange .. "/vso 23" .. green .. GetString( TTG_VSO23_D ) .. orange .. "/vso 24" .. green .. GetString( TTG_VSO24_D ) .. orange .. "/vso 25" .. green .. GetString( TTG_VSO25_D ) .. orange .. "/vso 26" .. green .. GetString( TTG_VSO26_D ) .. orange .. "/vso 27" .. green .. GetString( TTG_VSO27_D ) .. orange .. "/vso 28" .. green .. GetString( TTG_VSO28_D ) .. orange .. "/vso 29" .. green .. GetString( TTG_VSO29_D ) .. orange .. "/vso 30" .. green .. GetString( TTG_VSO30_D ))
     d(orange .. "/vso 31" .. green .. GetString( TTG_VSO31_D ) .. orange .. "/vso 32" .. green .. GetString( TTG_VSO32_D ) .. orange .. "/vso 33" .. green .. GetString( TTG_VSO33_D ) .. orange .. "/vso 34" .. green .. GetString( TTG_VSO34_D ) .. orange .. "/vso 35" .. green .. GetString( TTG_VSO35_D ) .. orange .. "/vso 36" .. green .. GetString( TTG_VSO36_D ) .. orange .. "/vso 37" .. green .. GetString( TTG_VSO37_D ) .. orange .. "/vso 38" .. green .. GetString( TTG_VSO38_D ))
	end
    end
  end
end


-- AETHRIAN ARCHIVE NORMAL

function TTGAddon.WindowNAA()
TTGAddonIndicatorData:SetText("/naa 1\n/naa 2\n/naa 3\n/naa 4\n/naa 5\n/naa 6\n/naa 7\n/naa 8\n/naa 9\n/naa 10\n/naa 11\n/naa 12\n/naa 13\n/naa 14\n/naa 15\n/naa 16\n/naa 17\n/naa 18\n/naa 19\n/naa 20\n/naa 21\n/naa 22\n/naa 23\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NAA1_D ) .. GetString( TTG_NAA2_D ) .. GetString( TTG_NAA3_D ) .. GetString( TTG_NAA4_D ) .. GetString( TTG_NAA5_D ) .. GetString( TTG_NAA6_D ) .. GetString( TTG_NAA7_D ) .. GetString( TTG_NAA8_D ) .. GetString( TTG_NAA9_D ) .. GetString( TTG_NAA10_D ) .. GetString( TTG_NAA11_D ) .. GetString( TTG_NAA12_D ) .. GetString( TTG_NAA13_D ) .. GetString( TTG_NAA14_D ) .. GetString( TTG_NAA15_D ) .. GetString( TTG_NAA16_D ) .. GetString( TTG_NAA17_D ) .. GetString( TTG_NAA18_D ) .. GetString( TTG_NAA19_D ) .. GetString( TTG_NAA20_D ) .. GetString( TTG_NAA21_D ) .. GetString( TTG_NAA22_D ) .. GetString( TTG_NAA23_D ))
TTGAddonIndicatorBg:SetWidth(350)
TTGAddonIndicatorContainer:SetWidth(345)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 23 then
	   bglen = ((24 * 23) + 45)
 	   contlen = ((24 * 23) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 45)
 	   contlen = ((24 * currentcommandlength) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 23 then
		       	   bglen = ((24 * 23) + 45)
		           contlen = ((24 * 23) + 12)
 		       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 45)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 12)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 45)
           contlen = ((24 * 5) + 12)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnaa(slashnumber)
TTGAddon.savedVariables.Trial = "naa"
currentTrial = "naa"
TTGAddon.WindowNAA()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text =  wheretoplace .. " " .. GetString( TTG_NAA23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
    d(white .. GetString( TTG_AC ) .. orange .. "/naa 1" .. green .. GetString( TTG_NAA1_D ) .. orange .. "/naa 2" .. green .. GetString( TTG_NAA2_D ) .. orange .. "/naa 3" .. green .. GetString( TTG_NAA3_D ) .. orange .. "/naa 4" .. green .. GetString( TTG_NAA4_D ) .. orange .. "/naa 5" .. green .. GetString( TTG_NAA5_D ) .. orange .. "/naa 6" .. green .. GetString( TTG_NAA6_D ) .. orange .. "/naa 7" .. green .. GetString( TTG_NAA7_D ) .. orange .. "/naa 8" .. green .. GetString( TTG_NAA8_D ) .. orange .. "/naa 9" .. green .. GetString( TTG_NAA9_D ) .. orange .. "/naa 10" .. green .. GetString( TTG_NAA10_D ) .. orange .. "/naa 11" .. green .. GetString( TTG_NAA11_D ) .. orange .. "/naa 12" .. green .. GetString( TTG_NAA12_D ) .. orange .. "/naa 13" .. green .. GetString( TTG_NAA13_D ) .. orange .. "/naa 14" .. green .. GetString( TTG_NAA14_D ) .. orange .. "/naa 15" .. green .. GetString( TTG_NAA15_D ) .. orange .. "/naa 16" .. green .. GetString( TTG_NAA16_D ) .. orange .. "/naa 17" .. green .. GetString( TTG_NAA17_D ) .. orange .. "/naa 18" .. green .. GetString( TTG_NAA18_D ) .. orange .. "/naa 19" .. green .. GetString( TTG_NAA19_D ) .. orange .. "/naa 20" .. green .. GetString( TTG_NAA20_D ) .. orange .. "/naa 21" .. green .. GetString( TTG_NAA21_D ) .. orange .. "/naa 22" .. green .. GetString( TTG_NAA22_D ) .. orange .. "/naa 23" .. green .. GetString( TTG_NAA23_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NAA1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NAA2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NAA3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NAA4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NAA5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NAA6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NAA7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NAA8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NAA9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NAA10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NAA11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NAA12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NAA13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NAA14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NAA15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NAA16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NAA17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NAA18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NAA19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NAA20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NAA21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NAA22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NAA23 ))
    else
	if displayCmdInChat == true then
    d(white .. GetString( TTG_AC ) .. orange .. "/naa 1" .. green .. GetString( TTG_NAA1_D ) .. orange .. "/naa 2" .. green .. GetString( TTG_NAA2_D ) .. orange .. "/naa 3" .. green .. GetString( TTG_NAA3_D ) .. orange .. "/naa 4" .. green .. GetString( TTG_NAA4_D ) .. orange .. "/naa 5" .. green .. GetString( TTG_NAA5_D ) .. orange .. "/naa 6" .. green .. GetString( TTG_NAA6_D ) .. orange .. "/naa 7" .. green .. GetString( TTG_NAA7_D ) .. orange .. "/naa 8" .. green .. GetString( TTG_NAA8_D ) .. orange .. "/naa 9" .. green .. GetString( TTG_NAA9_D ) .. orange .. "/naa 10" .. green .. GetString( TTG_NAA10_D ) .. orange .. "/naa 11" .. green .. GetString( TTG_NAA11_D ) .. orange .. "/naa 12" .. green .. GetString( TTG_NAA12_D ) .. orange .. "/naa 13" .. green .. GetString( TTG_NAA13_D ) .. orange .. "/naa 14" .. green .. GetString( TTG_NAA14_D ) .. orange .. "/naa 15" .. green .. GetString( TTG_NAA15_D ) .. orange .. "/naa 16" .. green .. GetString( TTG_NAA16_D ) .. orange .. "/naa 17" .. green .. GetString( TTG_NAA17_D ) .. orange .. "/naa 18" .. green .. GetString( TTG_NAA18_D ) .. orange .. "/naa 19" .. green .. GetString( TTG_NAA19_D ) .. orange .. "/naa 20" .. green .. GetString( TTG_NAA20_D ) .. orange .. "/naa 21" .. green .. GetString( TTG_NAA21_D ) .. orange .. "/naa 22" .. green .. GetString( TTG_NAA22_D ) .. orange .. "/naa 23" .. green .. GetString( TTG_NAA23_D ))
	end
    end
  end
end


-- AETHRIAN ARCHIVE VETERAN

function TTGAddon.WindowVAA()
TTGAddonIndicatorData:SetText("/vaa 1\n/vaa 2\n/vaa 3\n/vaa 4\n/vaa 5\n/vaa 6\n/vaa 7\n/vaa 8\n/vaa 9\n/vaa 10\n/vaa 11\n/vaa 12\n/vaa 13\n/vaa 14\n/vaa 15\n/vaa 16\n/vaa 17\n/vaa 18\n/vaa 19\n/vaa 20\n/vaa 21\n/vaa 22\n/vaa 23\n/vaa 24\n/vaa 25\n/vaa 26\n/vaa 27\n/vaa 28\n/vaa 29\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VAA1_D ) .. GetString( TTG_VAA2_D ) .. GetString( TTG_VAA3_D ) .. GetString( TTG_VAA4_D ) .. GetString( TTG_VAA5_D ) .. GetString( TTG_VAA6_D ) .. GetString( TTG_VAA7_D ) .. GetString( TTG_VAA8_D ) .. GetString( TTG_VAA9_D ) .. GetString( TTG_VAA10_D ) .. GetString( TTG_VAA11_D ) .. GetString( TTG_VAA12_D ) .. GetString( TTG_VAA13_D ) .. GetString( TTG_VAA14_D ) .. GetString( TTG_VAA15_D ) .. GetString( TTG_VAA16_D ) .. GetString( TTG_VAA17_D ) .. GetString( TTG_VAA18_D ) .. GetString( TTG_VAA19_D ) .. GetString( TTG_VAA20_D ) .. GetString( TTG_VAA21_D ) .. GetString( TTG_VAA22_D ) .. GetString( TTG_VAA23_D ) .. GetString( TTG_VAA24_D ) .. GetString( TTG_VAA25_D ) .. GetString( TTG_VAA26_D ) .. GetString( TTG_VAA27_D ) .. GetString( TTG_VAA28_D ) .. GetString( TTG_VAA29_D ))
TTGAddonIndicatorBg:SetWidth(380)
TTGAddonIndicatorContainer:SetWidth(375)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 29 then
	   bglen = ((24 * 28) + 48)
 	   contlen = ((24 * 28) + 19)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 29 then
		       	   bglen = ((24 * 28) + 48)
		           contlen = ((24 * 28) + 19)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvaa(slashnumber)
TTGAddon.savedVariables.Trial = "vaa"
currentTrial = "vaa"
TTGAddon.WindowVAA()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA28)
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text =  wheretoplace .. " " .. GetString( TTG_VAA29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
    d(white .. GetString( TTG_AC ) .. orange .. "/vaa 1" .. green .. GetString( TTG_VAA1_D ) .. orange .. "/vaa 2" .. green .. GetString( TTG_VAA2_D ) .. orange .. "/vaa 3" .. green .. GetString( TTG_VAA3_D ) .. orange .. "/vaa 4" .. green .. GetString( TTG_VAA4_D ) .. orange .. "/vaa 5" .. green .. GetString( TTG_VAA5_D ) .. orange .. "/vaa 6" .. green .. GetString( TTG_VAA6_D ) .. orange .. "/vaa 7" .. green .. GetString( TTG_VAA7_D ) .. orange .. "/vaa 8" .. green .. GetString( TTG_VAA8_D ) .. orange .. "/vaa 9" .. green .. GetString( TTG_VAA9_D ) .. orange .. "/vaa 10" .. green .. GetString( TTG_VAA10_D ) .. orange .. "/vaa 11" .. green .. GetString( TTG_VAA11_D ) .. orange .. "/vaa 12" .. green .. GetString( TTG_VAA12_D ) .. orange .. "/vaa 13" .. green .. GetString( TTG_VAA13_D ) .. orange .. "/vaa 14" .. green .. GetString( TTG_VAA14_D ) .. orange .. "/vaa 15" .. green .. GetString( TTG_VAA15_D ) .. orange .. "/vaa 16" .. green .. GetString( TTG_VAA16_D ) .. orange .. "/vaa 17" .. green .. GetString( TTG_VAA17_D ) .. orange .. "/vaa 18" .. green .. GetString( TTG_VAA18_D ) .. orange .. "/vaa 19" .. green .. GetString( TTG_VAA19_D ) .. orange .. "/vaa 20" .. green .. GetString( TTG_VAA20_D ) .. orange .. "/vaa 21" .. green .. GetString( TTG_VAA21_D ) .. orange .. "/vaa 22" .. green .. GetString( TTG_VAA22_D ) .. orange .. "/vaa 23" .. green .. GetString( TTG_VAA23_D ) .. orange .. "/vaa 24" .. green .. GetString( TTG_VAA24_D ) .. orange .. "/vaa 25" .. green .. GetString( TTG_VAA25_D ) .. orange .. "/vaa 26" .. green .. GetString( TTG_VAA26_D ) .. orange .. "/vaa 27" .. green .. GetString( TTG_VAA27_D ) .. orange .. "/vaa 28" .. green .. GetString( TTG_VAA28_D ) .. orange .. "/vaa 29" .. green .. GetString( TTG_VAA29_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VAA1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VAA2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VAA3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VAA4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VAA5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VAA6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VAA7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VAA8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VAA9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VAA10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VAA11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VAA12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VAA13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VAA14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VAA15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VAA16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VAA17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VAA18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VAA19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VAA20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VAA21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VAA22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VAA23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VAA24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VAA25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VAA26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VAA27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VAA28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VAA29 ))
    else
	if displayCmdInChat == true then
    d(white .. GetString( TTG_AC ) .. orange .. "/vaa 1" .. green .. GetString( TTG_VAA1_D ) .. orange .. "/vaa 2" .. green .. GetString( TTG_VAA2_D ) .. orange .. "/vaa 3" .. green .. GetString( TTG_VAA3_D ) .. orange .. "/vaa 4" .. green .. GetString( TTG_VAA4_D ) .. orange .. "/vaa 5" .. green .. GetString( TTG_VAA5_D ) .. orange .. "/vaa 6" .. green .. GetString( TTG_VAA6_D ) .. orange .. "/vaa 7" .. green .. GetString( TTG_VAA7_D ) .. orange .. "/vaa 8" .. green .. GetString( TTG_VAA8_D ) .. orange .. "/vaa 9" .. green .. GetString( TTG_VAA9_D ) .. orange .. "/vaa 10" .. green .. GetString( TTG_VAA10_D ) .. orange .. "/vaa 11" .. green .. GetString( TTG_VAA11_D ) .. orange .. "/vaa 12" .. green .. GetString( TTG_VAA12_D ) .. orange .. "/vaa 13" .. green .. GetString( TTG_VAA13_D ) .. orange .. "/vaa 14" .. green .. GetString( TTG_VAA14_D ) .. orange .. "/vaa 15" .. green .. GetString( TTG_VAA15_D ) .. orange .. "/vaa 16" .. green .. GetString( TTG_VAA16_D ) .. orange .. "/vaa 17" .. green .. GetString( TTG_VAA17_D ) .. orange .. "/vaa 18" .. green .. GetString( TTG_VAA18_D ) .. orange .. "/vaa 19" .. green .. GetString( TTG_VAA19_D ) .. orange .. "/vaa 20" .. green .. GetString( TTG_VAA20_D ) .. orange .. "/vaa 21" .. green .. GetString( TTG_VAA21_D ) .. orange .. "/vaa 22" .. green .. GetString( TTG_VAA22_D ) .. orange .. "/vaa 23" .. green .. GetString( TTG_VAA23_D ) .. orange .. "/vaa 24" .. green .. GetString( TTG_VAA24_D ) .. orange .. "/vaa 25" .. green .. GetString( TTG_VAA25_D ) .. orange .. "/vaa 26" .. green .. GetString( TTG_VAA26_D ) .. orange .. "/vaa 27" .. green .. GetString( TTG_VAA27_D ) .. orange .. "/vaa 28" .. green .. GetString( TTG_VAA28_D ) .. orange .. "/vaa 29" .. green .. GetString( TTG_VAA29_D ))
	end
    end
  end
end


-- HEL RA CITADEL NORMAL

function TTGAddon.WindowNHRC()
TTGAddonIndicatorData:SetText("/nhrc 1\n/nhrc 2\n/nhrc 3\n/nhrc 4\n/nhrc 5\n/nhrc 6\n/nhrc 7\n/nhrc 8\n/nhrc 9\n/nhrc 10\n/nhrc 11\n/nhrc 12\n/nhrc 13\n/nhrc 14\n/nhrc 15\n/nhrc 16\n/nhrc 17\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NHRC1_D ) .. GetString( TTG_NHRC2_D ) .. GetString( TTG_NHRC3_D ) .. GetString( TTG_NHRC4_D ) .. GetString( TTG_NHRC5_D ) .. GetString( TTG_NHRC6_D ) .. GetString( TTG_NHRC7_D ) .. GetString( TTG_NHRC8_D ) .. GetString( TTG_NHRC9_D ) .. GetString( TTG_NHRC10_D ) .. GetString( TTG_NHRC11_D ) .. GetString( TTG_NHRC12_D ) .. GetString( TTG_NHRC13_D ) .. GetString( TTG_NHRC14_D ) .. GetString( TTG_NHRC15_D ) .. GetString( TTG_NHRC16_D ) .. GetString( TTG_NHRC17_D ))
TTGAddonIndicatorBg:SetWidth(305)
TTGAddonIndicatorContainer:SetWidth(300)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 17 then
	   bglen = ((24 * 17) + 45)
 	   contlen = ((24 * 17) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 17 then
		       	   bglen = ((24 * 17) + 45)
		           contlen = ((24 * 17) + 12)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnhrc(slashnumber)
TTGAddon.savedVariables.Trial = "nhrc"
currentTrial = "nhrc"
TTGAddon.WindowNHRC()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
     if slashnumber == "1" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC1 )
        ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
        text =  wheretoplace .. " " .. GetString( TTG_NHRC17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nhrc 1" .. green .. GetString( TTG_NHRC1_D ) .. orange .. "/nhrc 2" .. green .. GetString( TTG_NHRC2_D ) .. orange .. "/nhrc 3" .. green .. GetString( TTG_NHRC3_D ) .. orange .. "/nhrc 4" .. green .. GetString( TTG_NHRC4_D ) .. orange .. "/nhrc 5" .. green .. GetString( TTG_NHRC5_D ) .. orange .. "/nhrc 6" .. green .. GetString( TTG_NHRC6_D ) .. orange .. "/nhrc 7" .. green .. GetString( TTG_NHRC7_D ) .. orange .. "/nhrc 8" .. green .. GetString( TTG_NHRC8_D ) .. orange .. "/nhrc 9" .. green .. GetString( TTG_NHRC9_D ) .. orange .. "/nhrc 10" .. green .. GetString( TTG_NHRC10_D ) .. orange .. "/nhrc 11" .. green .. GetString( TTG_NHRC11_D ) .. orange .. "/nhrc 12" .. green .. GetString( TTG_NHRC12_D ) .. orange .. "/nhrc 13" .. green .. GetString( TTG_NHRC13_D ) .. orange .. "/nhrc 14" .. green .. GetString( TTG_NHRC14_D ) .. orange .. "/nhrc 15" .. green .. GetString( TTG_NHRC15_D ) .. orange .. "/nhrc 16" .. green .. GetString( TTG_NHRC16_D ) .. orange .. "/nhrc 17" .. green .. GetString( TTG_NHRC17_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NHRC1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NHRC2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NHRC3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NHRC4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NHRC5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NHRC6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NHRC7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NHRC8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NHRC9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NHRC10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NHRC11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NHRC12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NHRC13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NHRC14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NHRC15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NHRC16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NHRC17 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nhrc 1" .. green .. GetString( TTG_NHRC1_D ) .. orange .. "/nhrc 2" .. green .. GetString( TTG_NHRC2_D ) .. orange .. "/nhrc 3" .. green .. GetString( TTG_NHRC3_D ) .. orange .. "/nhrc 4" .. green .. GetString( TTG_NHRC4_D ) .. orange .. "/nhrc 5" .. green .. GetString( TTG_NHRC5_D ) .. orange .. "/nhrc 6" .. green .. GetString( TTG_NHRC6_D ) .. orange .. "/nhrc 7" .. green .. GetString( TTG_NHRC7_D ) .. orange .. "/nhrc 8" .. green .. GetString( TTG_NHRC8_D ) .. orange .. "/nhrc 9" .. green .. GetString( TTG_NHRC9_D ) .. orange .. "/nhrc 10" .. green .. GetString( TTG_NHRC10_D ) .. orange .. "/nhrc 11" .. green .. GetString( TTG_NHRC11_D ) .. orange .. "/nhrc 12" .. green .. GetString( TTG_NHRC12_D ) .. orange .. "/nhrc 13" .. green .. GetString( TTG_NHRC13_D ) .. orange .. "/nhrc 14" .. green .. GetString( TTG_NHRC14_D ) .. orange .. "/nhrc 15" .. green .. GetString( TTG_NHRC15_D ) .. orange .. "/nhrc 16" .. green .. GetString( TTG_NHRC16_D ) .. orange .. "/nhrc 17" .. green .. GetString( TTG_NHRC17_D ))
	end
    end
  end
end


-- HEL RA CITADEL VETERAN

function TTGAddon.WindowVHRC()
TTGAddonIndicatorData:SetText("/vhrc 1\n/vhrc 2\n/vhrc 3\n/vhrc 4\n/vhrc 5\n/vhrc 6\n/vhrc 7\n/vhrc 8\n/vhrc 9\n/vhrc 10\n/vhrc 11\n/vhrc 12\n/vhrc 13\n/vhrc 14\n/vhrc 15\n/vhrc 16\n/vhrc 17\n/vhrc 18\n/vhrc 19\n/vhrc 20\n/vhrc 21\n/vhrc 22\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VHRC1_D ) .. GetString( TTG_VHRC2_D ) .. GetString( TTG_VHRC3_D ) .. GetString( TTG_VHRC4_D ) .. GetString( TTG_VHRC5_D ) .. GetString( TTG_VHRC6_D ) .. GetString( TTG_VHRC7_D ) .. GetString( TTG_VHRC8_D ) .. GetString( TTG_VHRC9_D ) .. GetString( TTG_VHRC10_D ) .. GetString( TTG_VHRC11_D ) .. GetString( TTG_VHRC12_D ) .. GetString( TTG_VHRC13_D ) .. GetString( TTG_VHRC14_D ) .. GetString( TTG_VHRC15_D ) .. GetString( TTG_VHRC16_D ) .. GetString( TTG_VHRC17_D ) .. GetString( TTG_VHRC18_D ) .. GetString( TTG_VHRC19_D ) .. GetString( TTG_VHRC20_D ) .. GetString( TTG_VHRC21_D ) .. GetString( TTG_VHRC22_D ))
TTGAddonIndicatorBg:SetWidth(370)
TTGAddonIndicatorContainer:SetWidth(365)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 22 then
	   bglen = ((24 * 22) + 45)
 	   contlen = ((24 * 22) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 22 then
		       	   bglen = ((24 * 22) + 45)
		           contlen = ((24 * 22) + 12)
 		       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
 	 	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvhrc(slashnumber)
TTGAddon.savedVariables.Trial = "vhrc"
currentTrial = "vhrc"
TTGAddon.WindowVHRC()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
     if slashnumber == "1" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC1 )
        ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
        text =  wheretoplace .. " " .. GetString( TTG_VHRC22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vhrc 1" .. green .. GetString( TTG_VHRC1_D ) .. orange .. "/vhrc 2" .. green .. GetString( TTG_VHRC2_D ) .. orange .. "/vhrc 3" .. green .. GetString( TTG_VHRC3_D ) .. orange .. "/vhrc 4" .. green .. GetString( TTG_VHRC4_D ) .. orange .. "/vhrc 5" .. green .. GetString( TTG_VHRC5_D ) .. orange .. "/vhrc 6" .. green .. GetString( TTG_VHRC6_D ) .. orange .. "/vhrc 7" .. green .. GetString( TTG_VHRC7_D ) .. orange .. "/vhrc 8" .. green .. GetString( TTG_VHRC8_D ) .. orange .. "/vhrc 9" .. green .. GetString( TTG_VHRC9_D ) .. orange .. "/vhrc 10" .. green .. GetString( TTG_VHRC10_D ) .. orange .. "/vhrc 11" .. green .. GetString( TTG_VHRC11_D ) .. orange .. "/vhrc 12" .. green .. GetString( TTG_VHRC12_D ) .. orange .. "/vhrc 13" .. green .. GetString( TTG_VHRC13_D ) .. orange .. "/vhrc 14" .. green .. GetString( TTG_VHRC14_D ) .. orange .. "/vhrc 15" .. green .. GetString( TTG_VHRC15_D ) .. orange .. "/vhrc 16" .. green .. GetString( TTG_VHRC16_D ) .. orange .. "/vhrc 17" .. green .. GetString( TTG_VHRC17_D ) .. orange .. "/vhrc 18" .. green .. GetString( TTG_VHRC18_D ) .. orange .. "/vhrc 19" .. green .. GetString( TTG_VHRC19_D ) .. orange .. "/vhrc 20" .. green .. GetString( TTG_VHRC20_D ) .. orange .. "/vhrc 21" .. green .. GetString( TTG_VHRC21_D ) .. orange .. "/vhrc 22" .. green .. GetString( TTG_VHRC22_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VHRC1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VHRC2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VHRC3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VHRC4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VHRC5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VHRC6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VHRC7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VHRC8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VHRC9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VHRC10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VHRC11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VHRC12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VHRC13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VHRC14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VHRC15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VHRC16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VHRC17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VHRC18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VHRC19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VHRC20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VHRC21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VHRC22 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vhrc 1" .. green .. GetString( TTG_VHRC1_D ) .. orange .. "/vhrc 2" .. green .. GetString( TTG_VHRC2_D ) .. orange .. "/vhrc 3" .. green .. GetString( TTG_VHRC3_D ) .. orange .. "/vhrc 4" .. green .. GetString( TTG_VHRC4_D ) .. orange .. "/vhrc 5" .. green .. GetString( TTG_VHRC5_D ) .. orange .. "/vhrc 6" .. green .. GetString( TTG_VHRC6_D ) .. orange .. "/vhrc 7" .. green .. GetString( TTG_VHRC7_D ) .. orange .. "/vhrc 8" .. green .. GetString( TTG_VHRC8_D ) .. orange .. "/vhrc 9" .. green .. GetString( TTG_VHRC9_D ) .. orange .. "/vhrc 10" .. green .. GetString( TTG_VHRC10_D ) .. orange .. "/vhrc 11" .. green .. GetString( TTG_VHRC11_D ) .. orange .. "/vhrc 12" .. green .. GetString( TTG_VHRC12_D ) .. orange .. "/vhrc 13" .. green .. GetString( TTG_VHRC13_D ) .. orange .. "/vhrc 14" .. green .. GetString( TTG_VHRC14_D ) .. orange .. "/vhrc 15" .. green .. GetString( TTG_VHRC15_D ) .. orange .. "/vhrc 16" .. green .. GetString( TTG_VHRC16_D ) .. orange .. "/vhrc 17" .. green .. GetString( TTG_VHRC17_D ) .. orange .. "/vhrc 18" .. green .. GetString( TTG_VHRC18_D ) .. orange .. "/vhrc 19" .. green .. GetString( TTG_VHRC19_D ) .. orange .. "/vhrc 20" .. green .. GetString( TTG_VHRC20_D ) .. orange .. "/vhrc 21" .. green .. GetString( TTG_VHRC21_D ) .. orange .. "/vhrc 22" .. green .. GetString( TTG_VHRC22_D ))
	end
    end
  end
end



-- MAW OF LORKHAJ NORMAL

function TTGAddon.WindowNMOL()
TTGAddonIndicatorData:SetText("/nmol 1\n/nmol 2\n/nmol 3\n/nmol 4\n/nmol 5\n/nmol 6\n/nmol 7\n/nmol 8\n/nmol 9\n/nmol 10\n/nmol 11\n/nmol 12\n/nmol 13\n/nmol 14\n/nmol 15\n/nmol 16\n/nmol 17\n/nmol 18\n/nmol 19\n/nmol 20\n/nmol 21\n/nmol 22\n/nmol 23\n/nmol 24\n/nmol 25\n/nmol 26\n/nmol 27\n/nmol 28\n/nmol 29\n/nmol 30\n/nmol 31\n/nmol 32\n/nmol 33\n/nmol 34\n/nmol 35\n/nmol 36\n/nmol 37\n/nmol 38\n/nmol 39\n/nmol 40\n/nmol 41\n/nmol 42\n/nmol 43\n/nmol 44\n/nmol 45\n/nmol 46\n/nmol 47\n/nmol 48\n/nmol 49\n/nmol 50\n/nmol 51\n/nmol 52\n/nmol 53\n/nmol 54\n/nmol 55\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NMOL1_D ) .. GetString( TTG_NMOL2_D ) .. GetString( TTG_NMOL3_D ) .. GetString( TTG_NMOL4_D ) .. GetString( TTG_NMOL5_D ) .. GetString( TTG_NMOL6_D ) .. GetString( TTG_NMOL7_D ) .. GetString( TTG_NMOL8_D ) .. GetString( TTG_NMOL9_D ) .. GetString( TTG_NMOL10_D ) .. GetString( TTG_NMOL11_D ) .. GetString( TTG_NMOL12_D ) .. GetString( TTG_NMOL13_D ) .. GetString( TTG_NMOL14_D ) .. GetString( TTG_NMOL15_D ) .. GetString( TTG_NMOL16_D ) .. GetString( TTG_NMOL17_D ) .. GetString( TTG_NMOL18_D ) .. GetString( TTG_NMOL19_D ) .. GetString( TTG_NMOL20_D ) .. GetString( TTG_NMOL21_D ) .. GetString( TTG_NMOL22_D ) .. GetString( TTG_NMOL23_D ) .. GetString( TTG_NMOL24_D ) .. GetString( TTG_NMOL25_D ) .. GetString( TTG_NMOL26_D ) .. GetString( TTG_NMOL27_D ) .. GetString( TTG_NMOL28_D ) .. GetString( TTG_NMOL29_D ) .. GetString( TTG_NMOL30_D ) .. GetString( TTG_NMOL31_D ) .. GetString( TTG_NMOL32_D ) .. GetString( TTG_NMOL33_D ) .. GetString( TTG_NMOL34_D ) .. GetString( TTG_NMOL35_D ) .. GetString( TTG_NMOL36_D ) .. GetString( TTG_NMOL37_D ) .. GetString( TTG_NMOL38_D ) .. GetString( TTG_NMOL39_D ) .. GetString( TTG_NMOL40_D ) .. GetString( TTG_NMOL41_D ) .. GetString( TTG_NMOL42_D ) .. GetString( TTG_NMOL43_D ) .. GetString( TTG_NMOL44_D ) .. GetString( TTG_NMOL45_D ) .. GetString( TTG_NMOL46_D ) .. GetString( TTG_NMOL47_D ) .. GetString( TTG_NMOL48_D ) .. GetString( TTG_NMOL49_D ) .. GetString( TTG_NMOL50_D ) .. GetString( TTG_NMOL51_D ) .. GetString( TTG_NMOL52_D ) .. GetString( TTG_NMOL53_D ) .. GetString( TTG_NMOL54_D ) .. GetString( TTG_NMOL55_D ))
TTGAddonIndicatorBg:SetWidth(450)
TTGAddonIndicatorContainer:SetWidth(445)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 55 then
	   bglen = ((24 * 53) + 50)
 	   contlen = ((24 * 53) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength >055 then
		       	   bglen = ((24 * 53) + 50)
		           contlen = ((24 * 53) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnmol(slashnumber)
TTGAddon.savedVariables.Trial = "nmol"
currentTrial = "nmol"
TTGAddon.WindowNMOL()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "48" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL48 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "49" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL49 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "50" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL50 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "51" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL51 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "52" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL52 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "53" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL53 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "54" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL54 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "55" then
      text = wheretoplace .. " " .. GetString( TTG_NMOL55 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nmol 1" .. green .. GetString( TTG_NMOL1_D ) .. orange .. "/nmol 2" .. green .. GetString( TTG_NMOL2_D ) .. orange .. "/nmol 3" .. green .. GetString( TTG_NMOL3_D ) .. orange .. "/nmol 4" .. green .. GetString( TTG_NMOL4_D ) .. orange .. "/nmol 5" .. green .. GetString( TTG_NMOL5_D ) .. orange .. "/nmol 6" .. green .. GetString( TTG_NMOL6_D ) .. orange .. "/nmol 7" .. green .. GetString( TTG_NMOL7_D ) .. orange .. "/nmol 8" .. green .. GetString( TTG_NMOL8_D ) .. orange .. "/nmol 9" .. green .. GetString( TTG_NMOL9_D ) .. orange .. "/nmol 10" .. green .. GetString( TTG_NMOL10_D ) .. orange .. "/nmol 11" .. green .. GetString( TTG_NMOL11_D ) .. orange .. "/nmol 12" .. green .. GetString( TTG_NMOL12_D ) .. orange .. "/nmol 13" .. green .. GetString( TTG_NMOL13_D ) .. orange .. "/nmol 14" .. green .. GetString( TTG_NMOL14_D ) .. orange .. "/nmol 15" .. green .. GetString( TTG_NMOL15_D ) .. orange .. "/nmol 16" .. green .. GetString( TTG_NMOL16_D ) .. orange .. "/nmol 17" .. green .. GetString( TTG_NMOL17_D ) .. orange .. "/nmol 18" .. green .. GetString( TTG_NMOL18_D ) .. orange .. "/nmol 19" .. green .. GetString( TTG_NMOL19_D ) .. orange .. "/nmol 20" .. green .. GetString( TTG_NMOL20_D ) .. orange .. "/nmol 21" .. green .. GetString( TTG_NMOL21_D ) .. orange .. "/nmol 22" .. green .. GetString( TTG_NMOL22_D ) .. orange .. "/nmol 23" .. green .. GetString( TTG_NMOL23_D ) .. orange .. "/nmol 24" .. green .. GetString( TTG_NMOL24_D ) .. orange .. "/nmol 25" .. green .. GetString( TTG_NMOL25_D ) .. orange .. "/nmol 26" .. green .. GetString( TTG_NMOL26_D ) .. orange .. "/nmol 27" .. green .. GetString( TTG_NMOL27_D ) .. orange .. "/nmol 28" .. green .. GetString( TTG_NMOL28_D ) .. orange .. "/nmol 29" .. green .. GetString( TTG_NMOL29_D ) .. orange .. "/nmol 30" .. green .. GetString( TTG_NMOL30_D ))
      d(orange .. "/nmol 31" .. green .. GetString( TTG_NMOL31_D ) .. orange .. "/nmol 32" .. green .. GetString( TTG_NMOL32_D ) .. orange .. "/nmol 33" .. green .. GetString( TTG_NMOL33_D ) .. orange .. "/nmol 34" .. green .. GetString( TTG_NMOL34_D ) .. orange .. "/nmol 35" .. green .. GetString( TTG_NMOL35_D ) .. orange .. "/nmol 36" .. green .. GetString( TTG_NMOL36_D ) .. orange .. "/nmol 37" .. green .. GetString( TTG_NMOL37_D ) .. orange .. "/nmol 38" .. green .. GetString( TTG_NMOL38_D ) .. orange .. "/nmol 39" .. green .. GetString( TTG_NMOL39_D ) .. orange .. "/nmol 40" .. green .. GetString( TTG_NMOL40_D ) .. orange .. "/nmol 41" .. green .. GetString( TTG_NMOL41_D ) .. orange .. "/nmol 42" .. green .. GetString( TTG_NMOL42_D ) .. orange .. "/nmol 43" .. green .. GetString( TTG_NMOL43_D ) .. orange .. "/nmol 44" .. green .. GetString( TTG_NMOL44_D ) .. orange .. "/nmol 45" .. green .. GetString( TTG_NMOL45_D ) .. orange .. "/nmol 46" .. green .. GetString( TTG_NMOL46_D ) .. orange .. "/nmol 47" .. green .. GetString( TTG_NMOL47_D ) .. orange .. "/nmol 48" .. green .. GetString( TTG_NMOL48_D ) .. orange .. "/nmol 49" .. green .. GetString( TTG_NMOL49_D ) .. orange .. "/nmol 50" .. green .. GetString( TTG_NMOL50_D ) .. orange .. "/nmol 51" .. green .. GetString( TTG_NMOL51_D ) .. orange .. "/nmol 52" .. green .. GetString( TTG_NMOL52_D ) .. orange .. "/nmol 53" .. green .. GetString( TTG_NMOL53_D ) .. orange .. "/nmol 54" .. green .. GetString( TTG_NMOL54_D ) .. orange .. "/nmol 55" .. green .. GetString( TTG_NMOL55_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NMOL1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NMOL2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NMOL3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NMOL4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NMOL5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NMOL6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NMOL7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NMOL8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NMOL9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NMOL10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NMOL11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NMOL12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NMOL13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NMOL14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NMOL15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NMOL16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NMOL17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NMOL18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NMOL19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NMOL20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NMOL21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NMOL22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NMOL23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NMOL24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NMOL25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NMOL26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NMOL27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NMOL28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NMOL29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_NMOL30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_NMOL31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_NMOL32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_NMOL33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_NMOL34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_NMOL35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_NMOL36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_NMOL37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_NMOL38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_NMOL39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_NMOL40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_NMOL41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_NMOL42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_NMOL43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_NMOL44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_NMOL45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_NMOL46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_NMOL47 ))
    elseif slashnumber == "48" then
      d(colourtouse .. GetString( TTG_NMOL48 ))
    elseif slashnumber == "49" then
      d(colourtouse .. GetString( TTG_NMOL49 ))
    elseif slashnumber == "50" then
      d(colourtouse .. GetString( TTG_NMOL50 ))
    elseif slashnumber == "51" then
      d(colourtouse .. GetString( TTG_NMOL51 ))
    elseif slashnumber == "52" then
      d(colourtouse .. GetString( TTG_NMOL52 ))
    elseif slashnumber == "53" then
      d(colourtouse .. GetString( TTG_NMOL53 ))
    elseif slashnumber == "54" then
      d(colourtouse .. GetString( TTG_NMOL54 ))
    elseif slashnumber == "55" then
      d(colourtouse .. GetString( TTG_NMOL55 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nmol 1" .. green .. GetString( TTG_NMOL1_D ) .. orange .. "/nmol 2" .. green .. GetString( TTG_NMOL2_D ) .. orange .. "/nmol 3" .. green .. GetString( TTG_NMOL3_D ) .. orange .. "/nmol 4" .. green .. GetString( TTG_NMOL4_D ) .. orange .. "/nmol 5" .. green .. GetString( TTG_NMOL5_D ) .. orange .. "/nmol 6" .. green .. GetString( TTG_NMOL6_D ) .. orange .. "/nmol 7" .. green .. GetString( TTG_NMOL7_D ) .. orange .. "/nmol 8" .. green .. GetString( TTG_NMOL8_D ) .. orange .. "/nmol 9" .. green .. GetString( TTG_NMOL9_D ) .. orange .. "/nmol 10" .. green .. GetString( TTG_NMOL10_D ) .. orange .. "/nmol 11" .. green .. GetString( TTG_NMOL11_D ) .. orange .. "/nmol 12" .. green .. GetString( TTG_NMOL12_D ) .. orange .. "/nmol 13" .. green .. GetString( TTG_NMOL13_D ) .. orange .. "/nmol 14" .. green .. GetString( TTG_NMOL14_D ) .. orange .. "/nmol 15" .. green .. GetString( TTG_NMOL15_D ) .. orange .. "/nmol 16" .. green .. GetString( TTG_NMOL16_D ) .. orange .. "/nmol 17" .. green .. GetString( TTG_NMOL17_D ) .. orange .. "/nmol 18" .. green .. GetString( TTG_NMOL18_D ) .. orange .. "/nmol 19" .. green .. GetString( TTG_NMOL19_D ) .. orange .. "/nmol 20" .. green .. GetString( TTG_NMOL20_D ) .. orange .. "/nmol 21" .. green .. GetString( TTG_NMOL21_D ) .. orange .. "/nmol 22" .. green .. GetString( TTG_NMOL22_D ) .. orange .. "/nmol 23" .. green .. GetString( TTG_NMOL23_D ) .. orange .. "/nmol 24" .. green .. GetString( TTG_NMOL24_D ) .. orange .. "/nmol 25" .. green .. GetString( TTG_NMOL25_D ) .. orange .. "/nmol 26" .. green .. GetString( TTG_NMOL26_D ) .. orange .. "/nmol 27" .. green .. GetString( TTG_NMOL27_D ) .. orange .. "/nmol 28" .. green .. GetString( TTG_NMOL28_D ) .. orange .. "/nmol 29" .. green .. GetString( TTG_NMOL29_D ) .. orange .. "/nmol 30" .. green .. GetString( TTG_NMOL30_D ))
      d(orange .. "/nmol 31" .. green .. GetString( TTG_NMOL31_D ) .. orange .. "/nmol 32" .. green .. GetString( TTG_NMOL32_D ) .. orange .. "/nmol 33" .. green .. GetString( TTG_NMOL33_D ) .. orange .. "/nmol 34" .. green .. GetString( TTG_NMOL34_D ) .. orange .. "/nmol 35" .. green .. GetString( TTG_NMOL35_D ) .. orange .. "/nmol 36" .. green .. GetString( TTG_NMOL36_D ) .. orange .. "/nmol 37" .. green .. GetString( TTG_NMOL37_D ) .. orange .. "/nmol 38" .. green .. GetString( TTG_NMOL38_D ) .. orange .. "/nmol 39" .. green .. GetString( TTG_NMOL39_D ) .. orange .. "/nmol 40" .. green .. GetString( TTG_NMOL40_D ) .. orange .. "/nmol 41" .. green .. GetString( TTG_NMOL41_D ) .. orange .. "/nmol 42" .. green .. GetString( TTG_NMOL42_D ) .. orange .. "/nmol 43" .. green .. GetString( TTG_NMOL43_D ) .. orange .. "/nmol 44" .. green .. GetString( TTG_NMOL44_D ) .. orange .. "/nmol 45" .. green .. GetString( TTG_NMOL45_D ) .. orange .. "/nmol 46" .. green .. GetString( TTG_NMOL46_D ) .. orange .. "/nmol 47" .. green .. GetString( TTG_NMOL47_D ) .. orange .. "/nmol 48" .. green .. GetString( TTG_NMOL48_D ) .. orange .. "/nmol 49" .. green .. GetString( TTG_NMOL49_D ) .. orange .. "/nmol 50" .. green .. GetString( TTG_NMOL50_D ) .. orange .. "/nmol 51" .. green .. GetString( TTG_NMOL51_D ) .. orange .. "/nmol 52" .. green .. GetString( TTG_NMOL52_D ) .. orange .. "/nmol 53" .. green .. GetString( TTG_NMOL53_D ) .. orange .. "/nmol 54" .. green .. GetString( TTG_NMOL54_D ) .. orange .. "/nmol 55" .. green .. GetString( TTG_NMOL55_D ))
	end
    end
  end
end


-- MAW OF LORKHAJ VETERAN

function TTGAddon.WindowVMOL()
TTGAddonIndicatorData:SetText("/vmol 1\n/vmol 2\n/vmol 3\n/vmol 4\n/vmol 5\n/vmol 6\n/vmol 7\n/vmol 8\n/vmol 9\n/vmol 10\n/vmol 11\n/vmol 12\n/vmol 13\n/vmol 14\n/vmol 15\n/vmol 16\n/vmol 17\n/vmol 18\n/vmol 19\n/vmol 20\n/vmol 21\n/vmol 22\n/vmol 23\n/vmol 24\n/vmol 25\n/vmol 26\n/vmol 27\n/vmol 28\n/vmol 29\n/vmol 30\n/vmol 31\n/vmol 32\n/vmol 33\n/vmol 34\n/vmol 35\n/vmol 36\n/vmol 37\n/vmol 38\n/vmol 39\n/vmol 40\n/vmol 41\n/vmol 42\n/vmol 43\n/vmol 44\n/vmol 45\n/vmol 46\n/vmol 47\n/vmol 48\n/vmol 49\n/vmol 50\n/vmol 51\n/vmol 52\n/vmol 53\n/vmol 54\n/vmol 55\n/vmol 56\n/vmol 57\n/vmol 58\n/vmol 59\n/vmol 60\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VMOL1_D ) .. GetString( TTG_VMOL2_D ) .. GetString( TTG_VMOL3_D ) .. GetString( TTG_VMOL4_D ) .. GetString( TTG_VMOL5_D ) .. GetString( TTG_VMOL6_D ) .. GetString( TTG_VMOL7_D ) .. GetString( TTG_VMOL8_D ) .. GetString( TTG_VMOL9_D ) .. GetString( TTG_VMOL10_D ) .. GetString( TTG_VMOL11_D ) .. GetString( TTG_VMOL12_D ) .. GetString( TTG_VMOL13_D ) .. GetString( TTG_VMOL14_D ) .. GetString( TTG_VMOL15_D ) .. GetString( TTG_VMOL16_D ) .. GetString( TTG_VMOL17_D ) .. GetString( TTG_VMOL18_D ) .. GetString( TTG_VMOL19_D ) .. GetString( TTG_VMOL20_D ) .. GetString( TTG_VMOL21_D ) .. GetString( TTG_VMOL22_D ) .. GetString( TTG_VMOL23_D ) .. GetString( TTG_VMOL24_D ) .. GetString( TTG_VMOL25_D ) .. GetString( TTG_VMOL26_D ) .. GetString( TTG_VMOL27_D ) .. GetString( TTG_VMOL28_D ) .. GetString( TTG_VMOL29_D ) .. GetString( TTG_VMOL30_D ) .. GetString( TTG_VMOL31_D ) .. GetString( TTG_VMOL32_D ) .. GetString( TTG_VMOL33_D ) .. GetString( TTG_VMOL34_D ) .. GetString( TTG_VMOL35_D ) .. GetString( TTG_VMOL36_D ) .. GetString( TTG_VMOL37_D ) .. GetString( TTG_VMOL38_D ) .. GetString( TTG_VMOL39_D ) .. GetString( TTG_VMOL40_D ) .. GetString( TTG_VMOL41_D ) .. GetString( TTG_VMOL42_D ) .. GetString( TTG_VMOL43_D ) .. GetString( TTG_VMOL44_D ) .. GetString( TTG_VMOL45_D ) .. GetString( TTG_VMOL46_D ) .. GetString( TTG_VMOL47_D ) .. GetString( TTG_VMOL48_D ) .. GetString( TTG_VMOL49_D ) .. GetString( TTG_VMOL50_D ) .. GetString( TTG_VMOL51_D ) .. GetString( TTG_VMOL52_D ) .. GetString( TTG_VMOL53_D ) .. GetString( TTG_VMOL54_D ) .. GetString( TTG_VMOL55_D ) .. GetString( TTG_VMOL56_D ) .. GetString( TTG_VMOL57_D ) .. GetString( TTG_VMOL58_D ) .. GetString( TTG_VMOL59_D ) .. GetString( TTG_VMOL60_D ))
TTGAddonIndicatorBg:SetWidth(450)
TTGAddonIndicatorContainer:SetWidth(445)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 58 then
	   bglen = ((24 * 58) + 45)
 	   contlen = ((24 * 58) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 58 then
	  	     	   bglen = ((24 * 58) + 45)
		           contlen = ((24 * 58) + 12)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvmol(slashnumber)
TTGAddon.savedVariables.Trial = "vmol"
currentTrial = "vmol"
TTGAddon.WindowVMOL()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "48" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL48 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "49" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL49 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "50" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL50 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "51" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL51 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "52" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL52 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "53" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL53 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "54" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL54 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "55" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL55 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "56" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL56 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "57" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL57 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "58" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL58 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "59" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL59 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "60" then
      text = wheretoplace .. " " .. GetString( TTG_VMOL60 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vmol 1" .. green .. GetString( TTG_VMOL1_D ) .. orange .. "/vmol 2" .. green .. GetString( TTG_VMOL2_D ) .. orange .. "/vmol 3" .. green .. GetString( TTG_VMOL3_D ) .. orange .. "/vmol 4" .. green .. GetString( TTG_VMOL4_D ) .. orange .. "/vmol 5" .. green .. GetString( TTG_VMOL5_D ) .. orange .. "/vmol 6" .. green .. GetString( TTG_VMOL6_D ) .. orange .. "/vmol 7" .. green .. GetString( TTG_VMOL7_D ) .. orange .. "/vmol 8" .. green .. GetString( TTG_VMOL8_D ) .. orange .. "/vmol 9" .. green .. GetString( TTG_VMOL9_D ) .. orange .. "/vmol 10" .. green .. GetString( TTG_VMOL10_D ) .. orange .. "/vmol 11" .. green .. GetString( TTG_VMOL11_D ) .. orange .. "/vmol 12" .. green .. GetString( TTG_VMOL12_D ) .. orange .. "/vmol 13" .. green .. GetString( TTG_VMOL13_D ) .. orange .. "/vmol 14" .. green .. GetString( TTG_VMOL14_D ) .. orange .. "/vmol 15" .. green .. GetString( TTG_VMOL15_D ) .. orange .. "/vmol 16" .. green .. GetString( TTG_VMOL16_D ) .. orange .. "/vmol 17" .. green .. GetString( TTG_VMOL17_D ) .. orange .. "/vmol 18" .. green .. GetString( TTG_VMOL18_D ) .. orange .. "/vmol 19" .. green .. GetString( TTG_VMOL19_D ) .. orange .. "/vmol 20" .. green .. GetString( TTG_VMOL20_D ) .. orange .. "/vmol 21" .. green .. GetString( TTG_VMOL21_D ) .. orange .. "/vmol 22" .. green .. GetString( TTG_VMOL22_D ) .. orange .. "/vmol 23" .. green .. GetString( TTG_VMOL23_D ) .. orange .. "/vmol 24" .. green .. GetString( TTG_VMOL24_D ) .. orange .. "/vmol 25" .. green .. GetString( TTG_VMOL25_D ) .. orange .. "/vmol 26" .. green .. GetString( TTG_VMOL26_D ) .. orange .. "/vmol 27" .. green .. GetString( TTG_VMOL27_D ) .. orange .. "/vmol 28" .. green .. GetString( TTG_VMOL28_D ) .. orange .. "/vmol 29" .. green .. GetString( TTG_VMOL29_D ))
      d(orange .. "/vmol 30" .. green .. GetString( TTG_VMOL30_D ) .. orange .. "/vmol 31" .. green .. GetString( TTG_VMOL31_D ) .. orange .. "/vmol 32" .. green .. GetString( TTG_VMOL32_D ) .. orange .. "/vmol 33" .. green .. GetString( TTG_VMOL33_D ) .. orange .. "/vmol 34" .. green .. GetString( TTG_VMOL34_D ) .. orange .. "/vmol 35" .. green .. GetString( TTG_VMOL35_D ) .. orange .. "/vmol 36" .. green .. GetString( TTG_VMOL36_D ) .. orange .. "/vmol 37" .. green .. GetString( TTG_VMOL37_D ) .. orange .. "/vmol 38" .. green .. GetString( TTG_VMOL38_D ) .. orange .. "/vmol 39" .. green .. GetString( TTG_VMOL39_D ) .. orange .. "/vmol 40" .. green .. GetString( TTG_VMOL40_D ) .. orange .. "/vmol 41" .. green .. GetString( TTG_VMOL41_D ) .. orange .. "/vmol 42" .. green .. GetString( TTG_VMOL42_D ) .. orange .. "/vmol 43" .. green .. GetString( TTG_VMOL43_D ) .. orange .. "/vmol 44" .. green .. GetString( TTG_VMOL44_D ) .. orange .. "/vmol 45" .. green .. GetString( TTG_VMOL45_D ) .. orange .. "/vmol 46" .. green .. GetString( TTG_VMOL46_D ) .. orange .. "/vmol 47" .. green .. GetString( TTG_VMOL47_D ) .. orange .. "/vmol 48" .. green .. GetString( TTG_VMOL48_D ) .. orange .. "/vmol 49" .. green .. GetString( TTG_VMOL49_D ) .. orange .. "/vmol 50" .. green .. GetString( TTG_VMOL50_D ) .. orange .. "/vmol 51" .. green .. GetString( TTG_VMOL51_D ) .. orange .. "/vmol 52" .. green .. GetString( TTG_VMOL52_D ) .. orange .. "/vmol 53" .. green .. GetString( TTG_VMOL53_D ) .. orange .. "/vmol 54" .. green .. GetString( TTG_VMOL54_D ) .. orange .. "/vmol 55" .. green .. GetString( TTG_VMOL55_D ) .. orange .. "/vmol 56" .. green .. GetString( TTG_VMOL56_D ) .. orange .. "/vmol 57" .. green .. GetString( TTG_VMOL57_D ))
d(orange .. "/vmol 58" .. green .. GetString( TTG_VMOL58_D ) .. orange .. "/vmol 59" .. green .. GetString( TTG_VMOL59_D ) .. orange .. "/vmol 60" .. green .. GetString( TTG_VMOL60_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VMOL1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VMOL2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VMOL3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VMOL4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VMOL5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VMOL6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VMOL7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VMOL8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VMOL9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VMOL10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VMOL11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VMOL12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VMOL13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VMOL14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VMOL15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VMOL16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VMOL17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VMOL18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VMOL19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VMOL20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VMOL21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VMOL22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VMOL23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VMOL24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VMOL25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VMOL26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VMOL27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VMOL28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VMOL29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VMOL30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VMOL31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VMOL32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VMOL33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VMOL34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VMOL35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VMOL36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VMOL37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VMOL38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_VMOL39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_VMOL40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_VMOL41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_VMOL42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_VMOL43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_VMOL44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_VMOL45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_VMOL46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_VMOL47 ))
    elseif slashnumber == "48" then
      d(colourtouse .. GetString( TTG_VMOL48 ))
    elseif slashnumber == "49" then
      d(colourtouse .. GetString( TTG_VMOL49 ))
    elseif slashnumber == "50" then
      d(colourtouse .. GetString( TTG_VMOL50 ))
    elseif slashnumber == "51" then
      d(colourtouse .. GetString( TTG_VMOL51 ))
    elseif slashnumber == "52" then
      d(colourtouse .. GetString( TTG_VMOL52 ))
    elseif slashnumber == "53" then
      d(colourtouse .. GetString( TTG_VMOL53 ))
    elseif slashnumber == "54" then
      d(colourtouse .. GetString( TTG_VMOL54 ))
    elseif slashnumber == "55" then
      d(colourtouse .. GetString( TTG_VMOL55 ))
    elseif slashnumber == "56" then
      d(colourtouse .. GetString( TTG_VMOL56 ))
    elseif slashnumber == "57" then
      d(colourtouse .. GetString( TTG_VMOL57 ))
    elseif slashnumber == "58" then
      d(colourtouse .. GetString( TTG_VMOL58 ))
    elseif slashnumber == "59" then
      d(colourtouse .. GetString( TTG_VMOL59 ))
    elseif slashnumber == "60" then
      d(colourtouse .. GetString( TTG_VMOL60 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vmol 1" .. green .. GetString( TTG_VMOL1_D ) .. orange .. "/vmol 2" .. green .. GetString( TTG_VMOL2_D ) .. orange .. "/vmol 3" .. green .. GetString( TTG_VMOL3_D ) .. orange .. "/vmol 4" .. green .. GetString( TTG_VMOL4_D ) .. orange .. "/vmol 5" .. green .. GetString( TTG_VMOL5_D ) .. orange .. "/vmol 6" .. green .. GetString( TTG_VMOL6_D ) .. orange .. "/vmol 7" .. green .. GetString( TTG_VMOL7_D ) .. orange .. "/vmol 8" .. green .. GetString( TTG_VMOL8_D ) .. orange .. "/vmol 9" .. green .. GetString( TTG_VMOL9_D ) .. orange .. "/vmol 10" .. green .. GetString( TTG_VMOL10_D ) .. orange .. "/vmol 11" .. green .. GetString( TTG_VMOL11_D ) .. orange .. "/vmol 12" .. green .. GetString( TTG_VMOL12_D ) .. orange .. "/vmol 13" .. green .. GetString( TTG_VMOL13_D ) .. orange .. "/vmol 14" .. green .. GetString( TTG_VMOL14_D ) .. orange .. "/vmol 15" .. green .. GetString( TTG_VMOL15_D ) .. orange .. "/vmol 16" .. green .. GetString( TTG_VMOL16_D ) .. orange .. "/vmol 17" .. green .. GetString( TTG_VMOL17_D ) .. orange .. "/vmol 18" .. green .. GetString( TTG_VMOL18_D ) .. orange .. "/vmol 19" .. green .. GetString( TTG_VMOL19_D ) .. orange .. "/vmol 20" .. green .. GetString( TTG_VMOL20_D ) .. orange .. "/vmol 21" .. green .. GetString( TTG_VMOL21_D ) .. orange .. "/vmol 22" .. green .. GetString( TTG_VMOL22_D ) .. orange .. "/vmol 23" .. green .. GetString( TTG_VMOL23_D ) .. orange .. "/vmol 24" .. green .. GetString( TTG_VMOL24_D ) .. orange .. "/vmol 25" .. green .. GetString( TTG_VMOL25_D ) .. orange .. "/vmol 26" .. green .. GetString( TTG_VMOL26_D ) .. orange .. "/vmol 27" .. green .. GetString( TTG_VMOL27_D ) .. orange .. "/vmol 28" .. green .. GetString( TTG_VMOL28_D ) .. orange .. "/vmol 29" .. green .. GetString( TTG_VMOL29_D ))
      d(orange .. "/vmol 30" .. green .. GetString( TTG_VMOL30_D ) .. orange .. "/vmol 31" .. green .. GetString( TTG_VMOL31_D ) .. orange .. "/vmol 32" .. green .. GetString( TTG_VMOL32_D ) .. orange .. "/vmol 33" .. green .. GetString( TTG_VMOL33_D ) .. orange .. "/vmol 34" .. green .. GetString( TTG_VMOL34_D ) .. orange .. "/vmol 35" .. green .. GetString( TTG_VMOL35_D ) .. orange .. "/vmol 36" .. green .. GetString( TTG_VMOL36_D ) .. orange .. "/vmol 37" .. green .. GetString( TTG_VMOL37_D ) .. orange .. "/vmol 38" .. green .. GetString( TTG_VMOL38_D ) .. orange .. "/vmol 39" .. green .. GetString( TTG_VMOL39_D ) .. orange .. "/vmol 40" .. green .. GetString( TTG_VMOL40_D ) .. orange .. "/vmol 41" .. green .. GetString( TTG_VMOL41_D ) .. orange .. "/vmol 42" .. green .. GetString( TTG_VMOL42_D ) .. orange .. "/vmol 43" .. green .. GetString( TTG_VMOL43_D ) .. orange .. "/vmol 44" .. green .. GetString( TTG_VMOL44_D ) .. orange .. "/vmol 45" .. green .. GetString( TTG_VMOL45_D ) .. orange .. "/vmol 46" .. green .. GetString( TTG_VMOL46_D ) .. orange .. "/vmol 47" .. green .. GetString( TTG_VMOL47_D ) .. orange .. "/vmol 48" .. green .. GetString( TTG_VMOL48_D ) .. orange .. "/vmol 49" .. green .. GetString( TTG_VMOL49_D ) .. orange .. "/vmol 50" .. green .. GetString( TTG_VMOL50_D ) .. orange .. "/vmol 51" .. green .. GetString( TTG_VMOL51_D ) .. orange .. "/vmol 52" .. green .. GetString( TTG_VMOL52_D ) .. orange .. "/vmol 53" .. green .. GetString( TTG_VMOL53_D ) .. orange .. "/vmol 54" .. green .. GetString( TTG_VMOL54_D ) .. orange .. "/vmol 55" .. green .. GetString( TTG_VMOL55_D ) .. orange .. "/vmol 56" .. green .. GetString( TTG_VMOL56_D ) .. orange .. "/vmol 57" .. green .. GetString( TTG_VMOL57_D ))
d(orange .. "/vmol 58" .. green .. GetString( TTG_VMOL58_D ) .. orange .. "/vmol 59" .. green .. GetString( TTG_VMOL59_D ) .. orange .. "/vmol 60" .. green .. GetString( TTG_VMOL60_D ))
	end
    end
  end
end


-- ASYLUM SANCTORIUM NORMAL

function TTGAddon.WindowNAS()
TTGAddonIndicatorData:SetText("/nas 1\n/nas 2\n/nas 3\n/nas 4\n/nas 5\n/nas 6\n/nas 7\n/nas 8\n/nas 9\n/nas 10\n/nas 11\n/nas 12\n/nas 13\n/nas 14\n/nas 15\n/nas 16\n/nas 17\n/nas 18\n/nas 19\n/nas 20\n/nas 21\n/nas 22\n/nas 23\n/nas 24\n/nas 25\n/nas 26\n/nas 27\n/nas 28\n/nas 29\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NAS1_D ) .. GetString( TTG_NAS2_D ) .. GetString( TTG_NAS3_D ) .. GetString( TTG_NAS4_D ) .. GetString( TTG_NAS5_D ) .. GetString( TTG_NAS6_D ) .. GetString( TTG_NAS7_D ) .. GetString( TTG_NAS8_D ) .. GetString( TTG_NAS9_D ) .. GetString( TTG_NAS10_D ) .. GetString( TTG_NAS11_D ) .. GetString( TTG_NAS12_D ) .. GetString( TTG_NAS13_D ) .. GetString( TTG_NAS14_D ) .. GetString( TTG_NAS15_D ) .. GetString( TTG_NAS16_D ) .. GetString( TTG_NAS17_D ) .. GetString( TTG_NAS18_D ) .. GetString( TTG_NAS19_D ) .. GetString( TTG_NAS20_D ) .. GetString( TTG_NAS21_D ) .. GetString( TTG_NAS22_D ) .. GetString( TTG_NAS23_D ) .. GetString( TTG_NAS24_D ) .. GetString( TTG_NAS25_D ) .. GetString( TTG_NAS26_D ) .. GetString( TTG_NAS27_D ) .. GetString( TTG_NAS28_D ) .. GetString( TTG_NAS29_D ))
TTGAddonIndicatorBg:SetWidth(500)
TTGAddonIndicatorContainer:SetWidth(495)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 29 then
	   bglen = ((24 * 28) + 50)
 	   contlen = ((24 * 28) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 29 then
		       	   bglen = ((24 * 28) + 50)
		           contlen = ((24 * 28) + 17)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  	       		   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
 	 	      	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnas(slashnumber)
TTGAddon.savedVariables.Trial = "nas"
currentTrial = "nas"
TTGAddon.WindowNAS()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NAS1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NAS2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NAS3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NAS4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NAS5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NAS6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NAS7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NAS8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NAS9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NAS10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NAS11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NAS12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NAS13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NAS14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NAS15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NAS16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NAS17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NAS18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NAS19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NAS20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NAS21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NAS22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NAS23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NAS24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NAS25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NAS26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NAS27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NAS28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NAS29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nas 1" .. green .. GetString( TTG_NAS1_D ) .. orange .. "/nas 2" .. green .. GetString( TTG_NAS2_D ) .. orange .. "/nas 3" .. green .. GetString( TTG_NAS3_D ) .. orange .. "/nas 4" .. green .. GetString( TTG_NAS4_D ) .. orange .. "/nas 5" .. green .. GetString( TTG_NAS5_D ) .. orange .. "/nas 6" .. green .. GetString( TTG_NAS6_D ) .. orange .. "/nas 7" .. green .. GetString( TTG_NAS7_D ) .. orange .. "/nas 8" .. green .. GetString( TTG_NAS8_D ) .. orange .. "/nas 9" .. green .. GetString( TTG_NAS9_D ) .. orange .. "/nas 10" .. green .. GetString( TTG_NAS10_D ) .. orange .. "/nas 11" .. green .. GetString( TTG_NAS11_D ) .. orange .. "/nas 12" .. green .. GetString( TTG_NAS12_D ) .. orange .. "/nas 13" .. green .. GetString( TTG_NAS13_D ) .. orange .. "/nas 14" .. green .. GetString( TTG_NAS14_D ) .. orange .. "/nas 15" .. green .. GetString( TTG_NAS15_D ) .. orange .. "/nas 16" .. green .. GetString( TTG_NAS16_D ) .. orange .. "/nas 17" .. green .. GetString( TTG_NAS17_D ) .. orange .. "/nas 18" .. green .. GetString( TTG_NAS18_D ) .. orange .. "/nas 19" .. green .. GetString( TTG_NAS19_D ) .. orange .. "/nas 20" .. green .. GetString( TTG_NAS20_D ) .. orange .. "/nas 21" .. green .. GetString( TTG_NAS21_D ) .. orange .. "/nas 22" .. green .. GetString( TTG_NAS22_D ) .. orange .. "/nas 23" .. green .. GetString( TTG_NAS23_D ) .. orange .. "/nas 24" .. green .. GetString( TTG_NAS24_D ) .. orange .. "/nas 25" .. green .. GetString( TTG_NAS25_D ) .. orange .. "/nas 26" .. green .. GetString( TTG_NAS26_D ) .. orange .. "/nas 27" .. green .. GetString( TTG_NAS27_D ) .. orange .. "/nas 28" .. green .. GetString( TTG_NAS28_D ) .. orange .. "/nas 29" .. green .. GetString( TTG_NAS29_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NAS1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NAS2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NAS3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NAS4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NAS5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NAS6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NAS7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NAS8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NAS9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NAS10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NAS11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NAS12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NAS13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NAS14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NAS15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NAS16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NAS17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NAS18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NAS19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NAS20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NAS21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NAS22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NAS23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NAS24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NAS25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NAS26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NAS27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NAS28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NAS29 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nas 1" .. green .. GetString( TTG_NAS1_D ) .. orange .. "/nas 2" .. green .. GetString( TTG_NAS2_D ) .. orange .. "/nas 3" .. green .. GetString( TTG_NAS3_D ) .. orange .. "/nas 4" .. green .. GetString( TTG_NAS4_D ) .. orange .. "/nas 5" .. green .. GetString( TTG_NAS5_D ) .. orange .. "/nas 6" .. green .. GetString( TTG_NAS6_D ) .. orange .. "/nas 7" .. green .. GetString( TTG_NAS7_D ) .. orange .. "/nas 8" .. green .. GetString( TTG_NAS8_D ) .. orange .. "/nas 9" .. green .. GetString( TTG_NAS9_D ) .. orange .. "/nas 10" .. green .. GetString( TTG_NAS10_D ) .. orange .. "/nas 11" .. green .. GetString( TTG_NAS11_D ) .. orange .. "/nas 12" .. green .. GetString( TTG_NAS12_D ) .. orange .. "/nas 13" .. green .. GetString( TTG_NAS13_D ) .. orange .. "/nas 14" .. green .. GetString( TTG_NAS14_D ) .. orange .. "/nas 15" .. green .. GetString( TTG_NAS15_D ) .. orange .. "/nas 16" .. green .. GetString( TTG_NAS16_D ) .. orange .. "/nas 17" .. green .. GetString( TTG_NAS17_D ) .. orange .. "/nas 18" .. green .. GetString( TTG_NAS18_D ) .. orange .. "/nas 19" .. green .. GetString( TTG_NAS19_D ) .. orange .. "/nas 20" .. green .. GetString( TTG_NAS20_D ) .. orange .. "/nas 21" .. green .. GetString( TTG_NAS21_D ) .. orange .. "/nas 22" .. green .. GetString( TTG_NAS22_D ) .. orange .. "/nas 23" .. green .. GetString( TTG_NAS23_D ) .. orange .. "/nas 24" .. green .. GetString( TTG_NAS24_D ) .. orange .. "/nas 25" .. green .. GetString( TTG_NAS25_D ) .. orange .. "/nas 26" .. green .. GetString( TTG_NAS26_D ) .. orange .. "/nas 27" .. green .. GetString( TTG_NAS27_D ) .. orange .. "/nas 28" .. green .. GetString( TTG_NAS28_D ) .. orange .. "/nas 29" .. green .. GetString( TTG_NAS29_D ))
	end
    end
  end
end

-- ASYLUM SANCTORIUM VETERAN

function TTGAddon.WindowVAS()
TTGAddonIndicatorData:SetText("/vas 1\n/vas 2\n/vas 3\n/vas 4\n/vas 5\n/vas 6\n/vas 7\n/vas 8\n/vas 9\n/vas 10\n/vas 11\n/vas 12\n/vas 13\n/vas 14\n/vas 15\n/vas 16\n/vas 17\n/vas 18\n/vas 19\n/vas 20\n/vas 21\n/vas 22\n/vas 23\n/vas 24\n/vas 25\n/vas 26\n/vas 27\n/vas 28\n/vas 29\n/vas 30\n/vas 31\n/vas 32\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VAS1_D ) .. GetString( TTG_VAS2_D ) .. GetString( TTG_VAS3_D ) .. GetString( TTG_VAS4_D ) .. GetString( TTG_VAS5_D ) .. GetString( TTG_VAS6_D ) .. GetString( TTG_VAS7_D ) .. GetString( TTG_VAS8_D ) .. GetString( TTG_VAS9_D ) .. GetString( TTG_VAS10_D ) .. GetString( TTG_VAS11_D ) .. GetString( TTG_VAS12_D ) .. GetString( TTG_VAS13_D ) .. GetString( TTG_VAS14_D ) .. GetString( TTG_VAS15_D ) .. GetString( TTG_VAS16_D ) .. GetString( TTG_VAS17_D ) .. GetString( TTG_VAS18_D ) .. GetString( TTG_VAS19_D ) .. GetString( TTG_VAS20_D ) .. GetString( TTG_VAS21_D ) .. GetString( TTG_VAS22_D ) .. GetString( TTG_VAS23_D ) .. GetString( TTG_VAS24_D ) .. GetString( TTG_VAS25_D ) .. GetString( TTG_VAS26_D ) .. GetString( TTG_VAS27_D ) .. GetString( TTG_VAS28_D ) .. GetString( TTG_VAS29_D ) .. GetString( TTG_VAS30_D ) .. GetString( TTG_VAS31_D ) .. GetString( TTG_VAS32_D ))
TTGAddonIndicatorBg:SetWidth(500)
TTGAddonIndicatorContainer:SetWidth(495)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 32 then
	   bglen = ((24 * 31) + 50)
 	   contlen = ((24 * 31) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 32 then
		       	   bglen = ((24 * 31) + 50)
		           contlen = ((24 * 31) + 17)
 		       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
 	 	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvas(slashnumber)
TTGAddon.savedVariables.Trial = "vas"
currentTrial = "vas"
TTGAddon.WindowVAS()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VAS1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VAS2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VAS3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VAS4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VAS5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VAS6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VAS7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VAS8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VAS9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VAS10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VAS11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VAS12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VAS13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VAS14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VAS15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VAS16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VAS17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VAS18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VAS19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VAS20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VAS21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VAS22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VAS23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VAS24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VAS25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VAS26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VAS27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VAS28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VAS29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VAS30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VAS31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VAS32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vas 1" .. green .. GetString( TTG_VAS1_D ) .. orange .. "/vas 2" .. green .. GetString( TTG_VAS2_D ) .. orange .. "/vas 3" .. green .. GetString( TTG_VAS3_D ) .. orange .. "/vas 4" .. green .. GetString( TTG_VAS4_D ) .. orange .. "/vas 5" .. green .. GetString( TTG_VAS5_D ) .. orange .. "/vas 6" .. green .. GetString( TTG_VAS6_D ) .. orange .. "/vas 7" .. green .. GetString( TTG_VAS7_D ) .. orange .. "/vas 8" .. green .. GetString( TTG_VAS8_D ) .. orange .. "/vas 9" .. green .. GetString( TTG_VAS9_D ) .. orange .. "/vas 10" .. green .. GetString( TTG_VAS10_D ) .. orange .. "/vas 11" .. green .. GetString( TTG_VAS11_D ) .. orange .. "/vas 12" .. green .. GetString( TTG_VAS12_D ) .. orange .. "/vas 13" .. green .. GetString( TTG_VAS13_D ) .. orange .. "/vas 14" .. green .. GetString( TTG_VAS14_D ) .. orange .. "/vas 15" .. green .. GetString( TTG_VAS15_D ) .. orange .. "/vas 16" .. green .. GetString( TTG_VAS16_D ) .. orange .. "/vas 17" .. green .. GetString( TTG_VAS17_D ) .. orange .. "/vas 18" .. green .. GetString( TTG_VAS18_D ) .. orange .. "/vas 19" .. green .. GetString( TTG_VAS19_D ) .. orange .. "/vas 20" .. green .. GetString( TTG_VAS20_D ) .. orange .. "/vas 21" .. green .. GetString( TTG_VAS21_D ) .. orange .. "/vas 22" .. green .. GetString( TTG_VAS22_D ) .. orange .. "/vas 23" .. green .. GetString( TTG_VAS23_D ) .. orange .. "/vas 24" .. green .. GetString( TTG_VAS24_D ) .. orange .. "/vas 25" .. green .. GetString( TTG_VAS25_D ) .. orange .. "/vas 26" .. green .. GetString( TTG_VAS26_D ) .. orange .. "/vas 27" .. green .. GetString( TTG_VAS27_D ) .. orange .. "/vas 28" .. green .. GetString( TTG_VAS28_D ) .. orange .. "/vas 29" .. green .. GetString( TTG_VAS29_D ))
      d(white .. GetString( TTG_AC ) .. orange .. "/vas 30" .. green .. GetString( TTG_VAS30_D ) .. orange .. "/vas 31" .. green .. GetString( TTG_VAS31_D ) .. orange .. "/vas 32" .. green .. GetString( TTG_VAS32_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VAS1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VAS2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VAS3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VAS4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VAS5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VAS6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VAS7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VAS8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VAS9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VAS10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VAS11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VAS12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VAS13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VAS14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VAS15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VAS16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VAS17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VAS18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VAS19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VAS20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VAS21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VAS22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VAS23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VAS24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VAS25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VAS26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VAS27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VAS28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VAS29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VAS30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VAS31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VAS32 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vas 1" .. green .. GetString( TTG_VAS1_D ) .. orange .. "/vas 2" .. green .. GetString( TTG_VAS2_D ) .. orange .. "/vas 3" .. green .. GetString( TTG_VAS3_D ) .. orange .. "/vas 4" .. green .. GetString( TTG_VAS4_D ) .. orange .. "/vas 5" .. green .. GetString( TTG_VAS5_D ) .. orange .. "/vas 6" .. green .. GetString( TTG_VAS6_D ) .. orange .. "/vas 7" .. green .. GetString( TTG_VAS7_D ) .. orange .. "/vas 8" .. green .. GetString( TTG_VAS8_D ) .. orange .. "/vas 9" .. green .. GetString( TTG_VAS9_D ) .. orange .. "/vas 10" .. green .. GetString( TTG_VAS10_D ) .. orange .. "/vas 11" .. green .. GetString( TTG_VAS11_D ) .. orange .. "/vas 12" .. green .. GetString( TTG_VAS12_D ) .. orange .. "/vas 13" .. green .. GetString( TTG_VAS13_D ) .. orange .. "/vas 14" .. green .. GetString( TTG_VAS14_D ) .. orange .. "/vas 15" .. green .. GetString( TTG_VAS15_D ) .. orange .. "/vas 16" .. green .. GetString( TTG_VAS16_D ) .. orange .. "/vas 17" .. green .. GetString( TTG_VAS17_D ) .. orange .. "/vas 18" .. green .. GetString( TTG_VAS18_D ) .. orange .. "/vas 19" .. green .. GetString( TTG_VAS19_D ) .. orange .. "/vas 20" .. green .. GetString( TTG_VAS20_D ) .. orange .. "/vas 21" .. green .. GetString( TTG_VAS21_D ) .. orange .. "/vas 22" .. green .. GetString( TTG_VAS22_D ) .. orange .. "/vas 23" .. green .. GetString( TTG_VAS23_D ) .. orange .. "/vas 24" .. green .. GetString( TTG_VAS24_D ) .. orange .. "/vas 25" .. green .. GetString( TTG_VAS25_D ) .. orange .. "/vas 26" .. green .. GetString( TTG_VAS26_D ) .. orange .. "/vas 27" .. green .. GetString( TTG_VAS27_D ) .. orange .. "/vas 28" .. green .. GetString( TTG_VAS28_D ) .. orange .. "/vas 29" .. green .. GetString( TTG_VAS29_D ))
      d(orange .. "/vas 30" .. green .. GetString( TTG_VAS30_D ) .. orange .. "/vas 31" .. green .. GetString( TTG_VAS31_D ) .. orange .. "/vas 32" .. green .. GetString( TTG_VAS32_D ))
	end
    end
  end
end


-- CLOUDREST NORMAL

function TTGAddon.WindowNCR()
TTGAddonIndicatorData:SetText("/ncr 1\n/ncr 2\n/ncr 3\n/ncr 4\n/ncr 5\n/ncr 6\n/ncr 7\n/ncr 8\n/ncr 9\n/ncr 10\n/ncr 11\n/ncr 12\n/ncr 13\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NCR1_D ) .. GetString( TTG_NCR2_D ) .. GetString( TTG_NCR3_D ) .. GetString( TTG_NCR4_D ) .. GetString( TTG_NCR5_D ) .. GetString( TTG_NCR6_D ) .. GetString( TTG_NCR7_D ) .. GetString( TTG_NCR8_D ) .. GetString( TTG_NCR9_D ) .. GetString( TTG_NCR10_D ) .. GetString( TTG_NCR11_D ) .. GetString( TTG_NCR12_D ) .. GetString( TTG_NCR13_D ))
TTGAddonIndicatorBg:SetWidth(410)
TTGAddonIndicatorContainer:SetWidth(405)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 13 then
	   bglen = ((24 * 13) + 45)
 	   contlen = ((24 * 13) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 13 then
		       	   bglen = ((24 * 13) + 45)
		           contlen = ((24 * 13) + 12)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashncr(slashnumber)
TTGAddon.savedVariables.Trial = "ncr"
currentTrial = "ncr"
TTGAddon.WindowNCR()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NCR1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NCR2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NCR3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NCR4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NCR5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NCR6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NCR7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NCR8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NCR9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NCR10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NCR11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NCR12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NCR13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/ncr 1" .. green .. GetString( TTG_NCR1_D ) .. orange .. "/ncr 2" .. green .. GetString( TTG_NCR2_D ) .. orange .. "/ncr 3" .. green .. GetString( TTG_NCR3_D ) .. orange .. "/ncr 4" .. green .. GetString( TTG_NCR4_D ) .. orange .. "/ncr 5" .. green .. GetString( TTG_NCR5_D ) .. orange .. "/ncr 6" .. green .. GetString( TTG_NCR6_D ) .. orange .. "/ncr 7" .. green .. GetString( TTG_NCR7_D ) .. orange .. "/ncr 8" .. green .. GetString( TTG_NCR8_D ) .. orange .. "/ncr 9" .. green .. GetString( TTG_NCR9_D ) .. orange .. "/ncr 10" .. green .. GetString( TTG_NCR10_D ) .. orange .. "/ncr 11" .. green .. GetString( TTG_NCR11_D ) .. orange .. "/ncr 12" .. green .. GetString( TTG_NCR12_D ) .. orange .. "/ncr 13" .. green .. GetString( TTG_NCR13_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NCR1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NCR2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NCR3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NCR4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NCR5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NCR6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NCR7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NCR8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NCR9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NCR10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NCR11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NCR12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NCR13 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/ncr 1" .. green .. GetString( TTG_NCR1_D ) .. orange .. "/ncr 2" .. green .. GetString( TTG_NCR2_D ) .. orange .. "/ncr 3" .. green .. GetString( TTG_NCR3_D ) .. orange .. "/ncr 4" .. green .. GetString( TTG_NCR4_D ) .. orange .. "/ncr 5" .. green .. GetString( TTG_NCR5_D ) .. orange .. "/ncr 6" .. green .. GetString( TTG_NCR6_D ) .. orange .. "/ncr 7" .. green .. GetString( TTG_NCR7_D ) .. orange .. "/ncr 8" .. green .. GetString( TTG_NCR8_D ) .. orange .. "/ncr 9" .. green .. GetString( TTG_NCR9_D ) .. orange .. "/ncr 10" .. green .. GetString( TTG_NCR10_D ) .. orange .. "/ncr 11" .. green .. GetString( TTG_NCR11_D ) .. orange .. "/ncr 12" .. green .. GetString( TTG_NCR12_D ) .. orange .. "/ncr 13" .. green .. GetString( TTG_NCR13_D ))
	end
    end
  end
end

-- CLOUDREST NORMAL VETERAN

function TTGAddon.WindowVCR()
TTGAddonIndicatorData:SetText("/vcr 1\n/vcr 2\n/vcr 3\n/vcr 4\n/vcr 5\n/vcr 6\n/vcr 7\n/vcr 8\n/vcr 9\n/vcr 10\n/vcr 11\n/vcr 12\n/vcr 13\n/vcr 14\n/vcr 15\n/vcr 16\n/vcr 17\n/vcr 18\n/vcr 19\n/vcr 20\n/vcr 21\n/vcr 22\n/vcr 23\n/vcr 24\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VCR1_D ) .. GetString( TTG_VCR2_D ) .. GetString( TTG_VCR3_D ) .. GetString( TTG_VCR4_D ) .. GetString( TTG_VCR5_D ) .. GetString( TTG_VCR6_D ) .. GetString( TTG_VCR7_D ) .. GetString( TTG_VCR8_D ) .. GetString( TTG_VCR9_D ) .. GetString( TTG_VCR10_D ) .. GetString( TTG_VCR11_D ) .. GetString( TTG_VCR12_D ) .. GetString( TTG_VCR13_D ) .. GetString( TTG_VCR14_D ) .. GetString( TTG_VCR15_D ) .. GetString( TTG_VCR16_D ) .. GetString( TTG_VCR17_D ) .. GetString( TTG_VCR18_D ) .. GetString( TTG_VCR19_D ) .. GetString( TTG_VCR20_D ) .. GetString( TTG_VCR21_D ) .. GetString( TTG_VCR22_D ) .. GetString( TTG_VCR23_D ) .. GetString( TTG_VCR24_D ))
TTGAddonIndicatorBg:SetWidth(410)
TTGAddonIndicatorContainer:SetWidth(405)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 24 then
	   bglen = ((24 * 24) + 45)
 	   contlen = ((24 * 24) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 24 then
		       	   bglen = ((24 * 24) + 45)
		           contlen = ((24 * 24) + 12)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvcr(slashnumber)
TTGAddon.savedVariables.Trial = "vcr"
currentTrial = "vcr"
TTGAddon.WindowVCR()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VCR1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VCR2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VCR3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VCR4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VCR5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VCR6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VCR7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VCR8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VCR9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VCR10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VCR11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VCR12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VCR13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VCR14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VCR15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VCR16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VCR17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VCR18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VCR19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VCR20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VCR21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VCR22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VCR23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VCR24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vcr 1" .. green .. GetString( TTG_VCR1_D ) .. orange .. "/vcr 2" .. green .. GetString( TTG_VCR2_D ) .. orange .. "/vcr 3" .. green .. GetString( TTG_VCR3_D ) .. orange .. "/vcr 4" .. green .. GetString( TTG_VCR4_D ) .. orange .. "/vcr 5" .. green .. GetString( TTG_VCR5_D ) .. orange .. "/vcr 6" .. green .. GetString( TTG_VCR6_D ) .. orange .. "/vcr 7" .. green .. GetString( TTG_VCR7_D ) .. orange .. "/vcr 8" .. green .. GetString( TTG_VCR8_D ) .. orange .. "/vcr 9" .. green .. GetString( TTG_VCR9_D ) .. orange .. "/vcr 10" .. green .. GetString( TTG_VCR10_D ) .. orange .. "/vcr 11" .. green .. GetString( TTG_VCR11_D ) .. orange .. "/vcr 12" .. green .. GetString( TTG_VCR12_D ) .. orange .. "/vcr 13" .. green .. GetString( TTG_VCR13_D ) .. orange .. "/vcr 14" .. green .. GetString( TTG_VCR14_D ) .. orange .. "/vcr 15" .. green .. GetString( TTG_VCR15_D ) .. orange .. "/vcr 16" .. green .. GetString( TTG_VCR16_D ) .. orange .. "/vcr 17" .. green .. GetString( TTG_VCR17_D ) .. orange .. "/vcr 18" .. green .. GetString( TTG_VCR18_D ) .. orange .. "/vcr 19" .. green .. GetString( TTG_VCR19_D ) .. orange .. "/vcr 20" .. green .. GetString( TTG_VCR20_D ) .. orange .. "/vcr 21" .. green .. GetString( TTG_VCR21_D ) .. orange .. "/vcr 22" .. green .. GetString( TTG_VCR22_D ) .. orange .. "/vcr 23" .. green .. GetString( TTG_VCR23_D ) .. orange .. "/vcr 24" .. green .. GetString( TTG_VCR24_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VCR1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VCR2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VCR3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VCR4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VCR5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VCR6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VCR7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VCR8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VCR9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VCR10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VCR11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VCR12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VCR13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VCR14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VCR15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VCR16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VCR17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VCR18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VCR19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VCR20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VCR21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VCR22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VCR23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VCR24 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vcr 1" .. green .. GetString( TTG_VCR1_D ) .. orange .. "/vcr 2" .. green .. GetString( TTG_VCR2_D ) .. orange .. "/vcr 3" .. green .. GetString( TTG_VCR3_D ) .. orange .. "/vcr 4" .. green .. GetString( TTG_VCR4_D ) .. orange .. "/vcr 5" .. green .. GetString( TTG_VCR5_D ) .. orange .. "/vcr 6" .. green .. GetString( TTG_VCR6_D ) .. orange .. "/vcr 7" .. green .. GetString( TTG_VCR7_D ) .. orange .. "/vcr 8" .. green .. GetString( TTG_VCR8_D ) .. orange .. "/vcr 9" .. green .. GetString( TTG_VCR9_D ) .. orange .. "/vcr 10" .. green .. GetString( TTG_VCR10_D ) .. orange .. "/vcr 11" .. green .. GetString( TTG_VCR11_D ) .. orange .. "/vcr 12" .. green .. GetString( TTG_VCR12_D ) .. orange .. "/vcr 13" .. green .. GetString( TTG_VCR13_D ) .. orange .. "/vcr 14" .. green .. GetString( TTG_VCR14_D ) .. orange .. "/vcr 15" .. green .. GetString( TTG_VCR15_D ) .. orange .. "/vcr 16" .. green .. GetString( TTG_VCR16_D ) .. orange .. "/vcr 17" .. green .. GetString( TTG_VCR17_D ) .. orange .. "/vcr 18" .. green .. GetString( TTG_VCR18_D ) .. orange .. "/vcr 19" .. green .. GetString( TTG_VCR19_D ) .. orange .. "/vcr 20" .. green .. GetString( TTG_VCR20_D ) .. orange .. "/vcr 21" .. green .. GetString( TTG_VCR21_D ) .. orange .. "/vcr 22" .. green .. GetString( TTG_VCR22_D ) .. orange .. "/vcr 23" .. green .. GetString( TTG_VCR23_D ) .. orange .. "/vcr 24" .. green .. GetString( TTG_VCR24_D ))
	end
    end
  end
end


-- HALLS OF FABRICATION NORMAL

function TTGAddon.WindowNHOF()
TTGAddonIndicatorData:SetText("/nhof 1\n/nhof 2\n/nhof 3\n/nhof 4\n/nhof 5\n/nhof 6\n/nhof 7\n/nhof 8\n/nhof 9\n/nhof 10\n/nhof 11\n/nhof 12\n/nhof 13\n/nhof 14\n/nhof 15\n/nhof 16\n/nhof 17\n/nhof 18\n/nhof 19\n/nhof 20\n/nhof 21\n/nhof 22\n/nhof 23\n/nhof 24\n/nhof 25\n/nhof 26\n/nhof 27\n/nhof 28\n/nhof 29\n/nhof 30\n/nhof 31\n/nhof 32\n/nhof 33\n/nhof 34\n/nhof 35\n/nhof 36\n/nhof 37\n/nhof 38\n/nhof 39\n/nhof 40\n/nhof 41\n/nhof 42\n/nhof 43\n/nhof 44\n/nhof 45\n/nhof 46\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NHOF1_D ) .. GetString( TTG_NHOF2_D ) .. GetString( TTG_NHOF3_D ) .. GetString( TTG_NHOF4_D ) .. GetString( TTG_NHOF5_D ) .. GetString( TTG_NHOF6_D ) .. GetString( TTG_NHOF7_D ) .. GetString( TTG_NHOF8_D ) .. GetString( TTG_NHOF9_D ) .. GetString( TTG_NHOF10_D ) .. GetString( TTG_NHOF11_D ) .. GetString( TTG_NHOF12_D ) .. GetString( TTG_NHOF13_D ) .. GetString( TTG_NHOF14_D ) .. GetString( TTG_NHOF15_D ) .. GetString( TTG_NHOF16_D ) .. GetString( TTG_NHOF17_D ) .. GetString( TTG_NHOF18_D ) .. GetString( TTG_NHOF19_D ) .. GetString( TTG_NHOF20_D ) .. GetString( TTG_NHOF21_D ) .. GetString( TTG_NHOF22_D ) .. GetString( TTG_NHOF23_D ) .. GetString( TTG_NHOF24_D ) .. GetString( TTG_NHOF25_D ) .. GetString( TTG_NHOF26_D ) .. GetString( TTG_NHOF27_D ) .. GetString( TTG_NHOF28_D ) .. GetString( TTG_NHOF29_D ) .. GetString( TTG_NHOF30_D ) .. GetString( TTG_NHOF31_D ) .. GetString( TTG_NHOF32_D ) .. GetString( TTG_NHOF33_D ) .. GetString( TTG_NHOF34_D ) .. GetString( TTG_NHOF35_D ) .. GetString( TTG_NHOF36_D ) .. GetString( TTG_NHOF37_D ) .. GetString( TTG_NHOF38_D ) .. GetString( TTG_NHOF39_D ) .. GetString( TTG_NHOF40_D ) .. GetString( TTG_NHOF41_D ) .. GetString( TTG_NHOF42_D ) .. GetString( TTG_NHOF43_D ) .. GetString( TTG_NHOF44_D ) .. GetString( TTG_NHOF45_D ) .. GetString( TTG_NHOF46_D ))
TTGAddonIndicatorBg:SetWidth(390)
TTGAddonIndicatorContainer:SetWidth(385)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 46 then
	   bglen = ((24 * 45) + 45)
 	   contlen = ((24 * 45) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 46 then
		       	   bglen = ((24 * 45) + 45)
		           contlen = ((24 * 45) + 12)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
 	 	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnhof(slashnumber)
TTGAddon.savedVariables.Trial = "nhof"
currentTrial = "nhof"
TTGAddon.WindowNHOF()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_NHOF46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nhof 1" .. green .. GetString( TTG_NHOF1_D ) .. orange .. "/nhof 2" .. green .. GetString( TTG_NHOF2_D ) .. orange .. "/nhof 3" .. green .. GetString( TTG_NHOF3_D ) .. orange .. "/nhof 4" .. green .. GetString( TTG_NHOF4_D ) .. orange .. "/nhof 5" .. green .. GetString( TTG_NHOF5_D ) .. orange .. "/nhof 6" .. green .. GetString( TTG_NHOF6_D ) .. orange .. "/nhof 7" .. green .. GetString( TTG_NHOF7_D ) .. orange .. "/nhof 8" .. green .. GetString( TTG_NHOF8_D ) .. orange .. "/nhof 9" .. green .. GetString( TTG_NHOF9_D ) .. orange .. "/nhof 10" .. green .. GetString( TTG_NHOF10_D ) .. orange .. "/nhof 11" .. green .. GetString( TTG_NHOF11_D ) .. orange .. "/nhof 12" .. green .. GetString( TTG_NHOF12_D ) .. orange .. "/nhof 13" .. green .. GetString( TTG_NHOF13_D ) .. orange .. "/nhof 14" .. green .. GetString( TTG_NHOF14_D ) .. orange .. "/nhof 15" .. green .. GetString( TTG_NHOF15_D ) .. orange .. "/nhof 16" .. green .. GetString( TTG_NHOF16_D ) .. orange .. "/nhof 17" .. green .. GetString( TTG_NHOF17_D ) .. orange .. "/nhof 18" .. green .. GetString( TTG_NHOF18_D ) .. orange .. "/nhof 19" .. green .. GetString( TTG_NHOF19_D ) .. orange .. "/nhof 20" .. green .. GetString( TTG_NHOF20_D ) .. orange .. "/nhof 21" .. green .. GetString( TTG_NHOF21_D ) .. orange .. "/nhof 22" .. green .. GetString( TTG_NHOF22_D ) .. orange .. "/nhof 23" .. green .. GetString( TTG_NHOF23_D ) .. orange .. "/nhof 24" .. green .. GetString( TTG_NHOF24_D ) .. orange .. "/nhof 25" .. green .. GetString( TTG_NHOF25_D ) .. orange .. "/nhof 26" .. green .. GetString( TTG_NHOF26_D ) .. orange .. "/nhof 27" .. green .. GetString( TTG_NHOF27_D ) .. orange .. "/nhof 28" .. green .. GetString( TTG_NHOF28_D ) .. orange .. "/nhof 29" .. green .. GetString( TTG_NHOF29_D ))
      d(orange .. "/nhof 30" .. green .. GetString( TTG_NHOF30_D ) .. orange .. "/nhof 31" .. green .. GetString( TTG_NHOF31_D ) .. orange .. "/nhof 32" .. green .. GetString( TTG_NHOF32_D ) .. orange .. "/nhof 33" .. green .. GetString( TTG_NHOF33_D ) .. orange .. "/nhof 34" .. green .. GetString( TTG_NHOF34_D ) .. orange .. "/nhof 35" .. green .. GetString( TTG_NHOF35_D ) .. orange .. "/nhof 36" .. green .. GetString( TTG_NHOF36_D ) .. orange .. "/nhof 37" .. green .. GetString( TTG_NHOF37_D ) .. orange .. "/nhof 38" .. green .. GetString( TTG_NHOF38_D ) .. orange .. "/nhof 39" .. green .. GetString( TTG_NHOF39_D ) .. orange .. "/nhof 40" .. green .. GetString( TTG_NHOF40_D ) .. orange .. "/nhof 41" .. green .. GetString( TTG_NHOF41_D ) .. orange .. "/nhof 42" .. green .. GetString( TTG_NHOF42_D ) .. orange .. "/nhof 43" .. green .. GetString( TTG_NHOF43_D ) .. orange .. "/nhof 44" .. green .. GetString( TTG_NHOF44_D ) .. orange .. "/nhof 45" .. green .. GetString( TTG_NHOF45_D ) .. orange .. "/nhof 46" .. green .. GetString( TTG_NHOF46_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NHOF1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NHOF2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NHOF3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NHOF4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NHOF5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NHOF6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NHOF7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NHOF8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NHOF9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NHOF10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NHOF11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NHOF12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NHOF13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NHOF14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NHOF15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NHOF16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NHOF17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NHOF18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NHOF19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NHOF20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NHOF21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NHOF22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NHOF23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NHOF24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NHOF25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NHOF26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NHOF27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NHOF28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NHOF29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_NHOF30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_NHOF31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_NHOF32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_NHOF33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_NHOF34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_NHOF35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_NHOF36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_NHOF37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_NHOF38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_NHOF39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_NHOF40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_NHOF41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_NHOF42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_NHOF43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_NHOF44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_NHOF45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_NHOF46 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nhof 1" .. green .. GetString( TTG_NHOF1_D ) .. orange .. "/nhof 2" .. green .. GetString( TTG_NHOF2_D ) .. orange .. "/nhof 3" .. green .. GetString( TTG_NHOF3_D ) .. orange .. "/nhof 4" .. green .. GetString( TTG_NHOF4_D ) .. orange .. "/nhof 5" .. green .. GetString( TTG_NHOF5_D ) .. orange .. "/nhof 6" .. green .. GetString( TTG_NHOF6_D ) .. orange .. "/nhof 7" .. green .. GetString( TTG_NHOF7_D ) .. orange .. "/nhof 8" .. green .. GetString( TTG_NHOF8_D ) .. orange .. "/nhof 9" .. green .. GetString( TTG_NHOF9_D ) .. orange .. "/nhof 10" .. green .. GetString( TTG_NHOF10_D ) .. orange .. "/nhof 11" .. green .. GetString( TTG_NHOF11_D ) .. orange .. "/nhof 12" .. green .. GetString( TTG_NHOF12_D ) .. orange .. "/nhof 13" .. green .. GetString( TTG_NHOF13_D ) .. orange .. "/nhof 14" .. green .. GetString( TTG_NHOF14_D ) .. orange .. "/nhof 15" .. green .. GetString( TTG_NHOF15_D ) .. orange .. "/nhof 16" .. green .. GetString( TTG_NHOF16_D ) .. orange .. "/nhof 17" .. green .. GetString( TTG_NHOF17_D ) .. orange .. "/nhof 18" .. green .. GetString( TTG_NHOF18_D ) .. orange .. "/nhof 19" .. green .. GetString( TTG_NHOF19_D ) .. orange .. "/nhof 20" .. green .. GetString( TTG_NHOF20_D ) .. orange .. "/nhof 21" .. green .. GetString( TTG_NHOF21_D ) .. orange .. "/nhof 22" .. green .. GetString( TTG_NHOF22_D ) .. orange .. "/nhof 23" .. green .. GetString( TTG_NHOF23_D ) .. orange .. "/nhof 24" .. green .. GetString( TTG_NHOF24_D ) .. orange .. "/nhof 25" .. green .. GetString( TTG_NHOF25_D ) .. orange .. "/nhof 26" .. green .. GetString( TTG_NHOF26_D ) .. orange .. "/nhof 27" .. green .. GetString( TTG_NHOF27_D ) .. orange .. "/nhof 28" .. green .. GetString( TTG_NHOF28_D ) .. orange .. "/nhof 29" .. green .. GetString( TTG_NHOF29_D ))
      d(orange .. "/nhof 30" .. green .. GetString( TTG_NHOF30_D ) .. orange .. "/nhof 31" .. green .. GetString( TTG_NHOF31_D ) .. orange .. "/nhof 32" .. green .. GetString( TTG_NHOF32_D ) .. orange .. "/nhof 33" .. green .. GetString( TTG_NHOF33_D ) .. orange .. "/nhof 34" .. green .. GetString( TTG_NHOF34_D ) .. orange .. "/nhof 35" .. green .. GetString( TTG_NHOF35_D ) .. orange .. "/nhof 36" .. green .. GetString( TTG_NHOF36_D ) .. orange .. "/nhof 37" .. green .. GetString( TTG_NHOF37_D ) .. orange .. "/nhof 38" .. green .. GetString( TTG_NHOF38_D ) .. orange .. "/nhof 39" .. green .. GetString( TTG_NHOF39_D ) .. orange .. "/nhof 40" .. green .. GetString( TTG_NHOF40_D ) .. orange .. "/nhof 41" .. green .. GetString( TTG_NHOF41_D ) .. orange .. "/nhof 42" .. green .. GetString( TTG_NHOF42_D ) .. orange .. "/nhof 43" .. green .. GetString( TTG_NHOF43_D ) .. orange .. "/nhof 44" .. green .. GetString( TTG_NHOF44_D ) .. orange .. "/nhof 45" .. green .. GetString( TTG_NHOF45_D ) .. orange .. "/nhof 46" .. green .. GetString( TTG_NHOF46_D ))
	end
    end
  end
end

-- HALLS OF FABRICATION VETERAN

function TTGAddon.WindowVHOF()
TTGAddonIndicatorData:SetText("/vhof 1\n/vhof 2\n/vhof 3\n/vhof 4\n/vhof 5\n/vhof 6\n/vhof 7\n/vhof 8\n/vhof 9\n/vhof 10\n/vhof 11\n/vhof 12\n/vhof 13\n/vhof 14\n/vhof 15\n/vhof 16\n/vhof 17\n/vhof 18\n/vhof 19\n/vhof 20\n/vhof 21\n/vhof 22\n/vhof 23\n/vhof 24\n/vhof 25\n/vhof 26\n/vhof 27\n/vhof 28\n/vhof 29\n/vhof 30\n/vhof 31\n/vhof 32\n/vhof 33\n/vhof 34\n/vhof 35\n/vhof 36\n/vhof 37\n/vhof 38\n/vhof 39\n/vhof 40\n/vhof 41\n/vhof 42\n/vhof 43\n/vhof 44\n/vhof 45\n/vhof 46\n/vhof 47\n/vhof 48\n/vhof 49\n/vhof 50\n/vhof 51\n/vhof 52\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VHOF1_D ) .. GetString( TTG_VHOF2_D ) .. GetString( TTG_VHOF3_D ) .. GetString( TTG_VHOF4_D ) .. GetString( TTG_VHOF5_D ) .. GetString( TTG_VHOF6_D ) .. GetString( TTG_VHOF7_D ) .. GetString( TTG_VHOF8_D ) .. GetString( TTG_VHOF9_D ) .. GetString( TTG_VHOF10_D ) .. GetString( TTG_VHOF11_D ) .. GetString( TTG_VHOF12_D ) .. GetString( TTG_VHOF13_D ) .. GetString( TTG_VHOF14_D ) .. GetString( TTG_VHOF15_D ) .. GetString( TTG_VHOF16_D ) .. GetString( TTG_VHOF17_D ) .. GetString( TTG_VHOF18_D ) .. GetString( TTG_VHOF19_D ) .. GetString( TTG_VHOF20_D ) .. GetString( TTG_VHOF21_D ) .. GetString( TTG_VHOF22_D ) .. GetString( TTG_VHOF23_D ) .. GetString( TTG_VHOF24_D ) .. GetString( TTG_VHOF25_D ) .. GetString( TTG_VHOF26_D ) .. GetString( TTG_VHOF27_D ) .. GetString( TTG_VHOF28_D ) .. GetString( TTG_VHOF29_D ) .. GetString( TTG_VHOF30_D ) .. GetString( TTG_VHOF31_D ) .. GetString( TTG_VHOF32_D ) .. GetString( TTG_VHOF33_D ) .. GetString( TTG_VHOF34_D ) .. GetString( TTG_VHOF35_D ) .. GetString( TTG_VHOF36_D ) .. GetString( TTG_VHOF37_D ) .. GetString( TTG_VHOF38_D ) .. GetString( TTG_VHOF39_D ) .. GetString( TTG_VHOF40_D ) .. GetString( TTG_VHOF41_D ) .. GetString( TTG_VHOF42_D ) .. GetString( TTG_VHOF43_D ) .. GetString( TTG_VHOF44_D ) .. GetString( TTG_VHOF45_D ) .. GetString( TTG_VHOF46_D ) .. GetString( TTG_VHOF47_D ) .. GetString( TTG_VHOF48_D ) .. GetString( TTG_VHOF49_D ) .. GetString( TTG_VHOF50_D ) .. GetString( TTG_VHOF51_D ) .. GetString( TTG_VHOF52_D ))
TTGAddonIndicatorBg:SetWidth(390)
TTGAddonIndicatorContainer:SetWidth(385)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 52 then
	   bglen = ((24 * 51) + 45)
 	   contlen = ((24 * 51) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 5)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 52 then
		       	   bglen = ((24 * 51) + 45)
		           contlen = ((24 * 51) + 12)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  	       		   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvhof(slashnumber)
TTGAddon.savedVariables.Trial = "vhof"
currentTrial = "vhof"
TTGAddon.WindowVHOF()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "48" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF48 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "49" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF49 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "50" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF50 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "51" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF51 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "52" then
      text = wheretoplace .. " " .. GetString( TTG_VHOF52 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vhof 1" .. green .. GetString( TTG_VHOF1_D ) .. orange .. "/vhof 2" .. green .. GetString( TTG_VHOF2_D ) .. orange .. "/vhof 3" .. green .. GetString( TTG_VHOF3_D ) .. orange .. "/vhof 4" .. green .. GetString( TTG_VHOF4_D ) .. orange .. "/vhof 5" .. green .. GetString( TTG_VHOF5_D ) .. orange .. "/vhof 6" .. green .. GetString( TTG_VHOF6_D ) .. orange .. "/vhof 7" .. green .. GetString( TTG_VHOF7_D ) .. orange .. "/vhof 8" .. green .. GetString( TTG_VHOF8_D ) .. orange .. "/vhof 9" .. green .. GetString( TTG_VHOF9_D ) .. orange .. "/vhof 10" .. green .. GetString( TTG_VHOF10_D ) .. orange .. "/vhof 11" .. green .. GetString( TTG_VHOF11_D ) .. orange .. "/vhof 12" .. green .. GetString( TTG_VHOF12_D ) .. orange .. "/vhof 13" .. green .. GetString( TTG_VHOF13_D ) .. orange .. "/vhof 14" .. green .. GetString( TTG_VHOF14_D ) .. orange .. "/vhof 15" .. green .. GetString( TTG_VHOF15_D ) .. orange .. "/vhof 16" .. green .. GetString( TTG_VHOF16_D ) .. orange .. "/vhof 17" .. green .. GetString( TTG_VHOF17_D ) .. orange .. "/vhof 18" .. green .. GetString( TTG_VHOF18_D ) .. orange .. "/vhof 19" .. green .. GetString( TTG_VHOF19_D ) .. orange .. "/vhof 20" .. green .. GetString( TTG_VHOF20_D ) .. orange .. "/vhof 21" .. green .. GetString( TTG_VHOF21_D ) .. orange .. "/vhof 22" .. green .. GetString( TTG_VHOF22_D ) .. orange .. "/vhof 23" .. green .. GetString( TTG_VHOF23_D ) .. orange .. "/vhof 24" .. green .. GetString( TTG_VHOF24_D ) .. orange .. "/vhof 25" .. green .. GetString( TTG_VHOF25_D ) .. orange .. "/vhof 26" .. green .. GetString( TTG_VHOF26_D ) .. orange .. "/vhof 27" .. green .. GetString( TTG_VHOF27_D ) .. orange .. "/vhof 28" .. green .. GetString( TTG_VHOF28_D ) .. orange .. "/vhof 29" .. green .. GetString( TTG_VHOF29_D ))
      d(orange .. "/vhof 30" .. green .. GetString( TTG_VHOF30_D ) .. orange .. "/vhof 31" .. green .. GetString( TTG_VHOF31_D ) .. orange .. "/vhof 32" .. green .. GetString( TTG_VHOF32_D ) .. orange .. "/vhof 33" .. green .. GetString( TTG_VHOF33_D ) .. orange .. "/vhof 34" .. green .. GetString( TTG_VHOF34_D ) .. orange .. "/vhof 35" .. green .. GetString( TTG_VHOF35_D ) .. orange .. "/vhof 36" .. green .. GetString( TTG_VHOF36_D ) .. orange .. "/vhof 37" .. green .. GetString( TTG_VHOF37_D ) .. orange .. "/vhof 38" .. green .. GetString( TTG_VHOF38_D ) .. orange .. "/vhof 39" .. green .. GetString( TTG_VHOF39_D ) .. orange .. "/vhof 40" .. green .. GetString( TTG_VHOF40_D ) .. orange .. "/vhof 41" .. green .. GetString( TTG_VHOF41_D ) .. orange .. "/vhof 42" .. green .. GetString( TTG_VHOF42_D ) .. orange .. "/vhof 43" .. green .. GetString( TTG_VHOF43_D ) .. orange .. "/vhof 44" .. green .. GetString( TTG_VHOF44_D ) .. orange .. "/vhof 45" .. green .. GetString( TTG_VHOF45_D ) .. orange .. "/vhof 46" .. green .. GetString( TTG_VHOF46_D ) .. orange .. "/vhof 47" .. green .. GetString( TTG_VHOF47_D ) .. orange .. "/vhof 48" .. green .. GetString( TTG_VHOF48_D ) .. orange .. "/vhof 49" .. green .. GetString( TTG_VHOF49_D ) .. orange .. "/vhof 50" .. green .. GetString( TTG_VHOF50_D ) .. orange .. "/vhof 51" .. green .. GetString( TTG_VHOF51_D ) .. orange .. "/vhof 52" .. green .. GetString( TTG_VHOF52_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VHOF1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VHOF2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VHOF3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VHOF4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VHOF5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VHOF6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VHOF7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VHOF8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VHOF9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VHOF10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VHOF11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VHOF12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VHOF13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VHOF14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VHOF15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VHOF16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VHOF17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VHOF18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VHOF19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VHOF20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VHOF21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VHOF22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VHOF23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VHOF24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VHOF25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VHOF26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VHOF27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VHOF28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VHOF29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VHOF30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VHOF31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VHOF32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VHOF33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VHOF34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VHOF35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VHOF36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VHOF37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VHOF38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_VHOF39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_VHOF40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_VHOF41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_VHOF42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_VHOF43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_VHOF44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_VHOF45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_VHOF46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_VHOF47 ))
    elseif slashnumber == "48" then
      d(colourtouse .. GetString( TTG_VHOF48 ))
    elseif slashnumber == "49" then
      d(colourtouse .. GetString( TTG_VHOF49 ))
    elseif slashnumber == "50" then
      d(colourtouse .. GetString( TTG_VHOF50 ))
    elseif slashnumber == "51" then
      d(colourtouse .. GetString( TTG_VHOF51 ))
    elseif slashnumber == "52" then
      d(colourtouse .. GetString( TTG_VHOF52 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vhof 1" .. green .. GetString( TTG_VHOF1_D ) .. orange .. "/vhof 2" .. green .. GetString( TTG_VHOF2_D ) .. orange .. "/vhof 3" .. green .. GetString( TTG_VHOF3_D ) .. orange .. "/vhof 4" .. green .. GetString( TTG_VHOF4_D ) .. orange .. "/vhof 5" .. green .. GetString( TTG_VHOF5_D ) .. orange .. "/vhof 6" .. green .. GetString( TTG_VHOF6_D ) .. orange .. "/vhof 7" .. green .. GetString( TTG_VHOF7_D ) .. orange .. "/vhof 8" .. green .. GetString( TTG_VHOF8_D ) .. orange .. "/vhof 9" .. green .. GetString( TTG_VHOF9_D ) .. orange .. "/vhof 10" .. green .. GetString( TTG_VHOF10_D ) .. orange .. "/vhof 11" .. green .. GetString( TTG_VHOF11_D ) .. orange .. "/vhof 12" .. green .. GetString( TTG_VHOF12_D ) .. orange .. "/vhof 13" .. green .. GetString( TTG_VHOF13_D ) .. orange .. "/vhof 14" .. green .. GetString( TTG_VHOF14_D ) .. orange .. "/vhof 15" .. green .. GetString( TTG_VHOF15_D ) .. orange .. "/vhof 16" .. green .. GetString( TTG_VHOF16_D ) .. orange .. "/vhof 17" .. green .. GetString( TTG_VHOF17_D ) .. orange .. "/vhof 18" .. green .. GetString( TTG_VHOF18_D ) .. orange .. "/vhof 19" .. green .. GetString( TTG_VHOF19_D ) .. orange .. "/vhof 20" .. green .. GetString( TTG_VHOF20_D ) .. orange .. "/vhof 21" .. green .. GetString( TTG_VHOF21_D ) .. orange .. "/vhof 22" .. green .. GetString( TTG_VHOF22_D ) .. orange .. "/vhof 23" .. green .. GetString( TTG_VHOF23_D ) .. orange .. "/vhof 24" .. green .. GetString( TTG_VHOF24_D ) .. orange .. "/vhof 25" .. green .. GetString( TTG_VHOF25_D ) .. orange .. "/vhof 26" .. green .. GetString( TTG_VHOF26_D ) .. orange .. "/vhof 27" .. green .. GetString( TTG_VHOF27_D ) .. orange .. "/vhof 28" .. green .. GetString( TTG_VHOF28_D ) .. orange .. "/vhof 29" .. green .. GetString( TTG_VHOF29_D ))
      d(orange .. "/vhof 30" .. green .. GetString( TTG_VHOF30_D ) .. orange .. "/vhof 31" .. green .. GetString( TTG_VHOF31_D ) .. orange .. "/vhof 32" .. green .. GetString( TTG_VHOF32_D ) .. orange .. "/vhof 33" .. green .. GetString( TTG_VHOF33_D ) .. orange .. "/vhof 34" .. green .. GetString( TTG_VHOF34_D ) .. orange .. "/vhof 35" .. green .. GetString( TTG_VHOF35_D ) .. orange .. "/vhof 36" .. green .. GetString( TTG_VHOF36_D ) .. orange .. "/vhof 37" .. green .. GetString( TTG_VHOF37_D ) .. orange .. "/vhof 38" .. green .. GetString( TTG_VHOF38_D ) .. orange .. "/vhof 39" .. green .. GetString( TTG_VHOF39_D ) .. orange .. "/vhof 40" .. green .. GetString( TTG_VHOF40_D ) .. orange .. "/vhof 41" .. green .. GetString( TTG_VHOF41_D ) .. orange .. "/vhof 42" .. green .. GetString( TTG_VHOF42_D ) .. orange .. "/vhof 43" .. green .. GetString( TTG_VHOF43_D ) .. orange .. "/vhof 44" .. green .. GetString( TTG_VHOF44_D ) .. orange .. "/vhof 45" .. green .. GetString( TTG_VHOF45_D ) .. orange .. "/vhof 46" .. green .. GetString( TTG_VHOF46_D ) .. orange .. "/vhof 47" .. green .. GetString( TTG_VHOF47_D ) .. orange .. "/vhof 48" .. green .. GetString( TTG_VHOF48_D ) .. orange .. "/vhof 49" .. green .. GetString( TTG_VHOF49_D ) .. orange .. "/vhof 50" .. green .. GetString( TTG_VHOF50_D ) .. orange .. "/vhof 51" .. green .. GetString( TTG_VHOF51_D ) .. orange .. "/vhof 52" .. green .. GetString( TTG_VHOF52_D ))
	end
    end
  end
end

-- SUNSPIRE NORMAL

function TTGAddon.WindowNSS()
TTGAddonIndicatorData:SetText("/nss 1\n/nss 2\n/nss 3\n/nss 4\n/nss 5\n/nss 6\n/nss 7\n/nss 8\n/nss 9\n/nss 10\n/nss 11\n/nss 12\n/nss 13\n/nss 14\n/nss 15\n/nss 16\n/nss 17\n/nss 18\n/nss 19\n/nss 20\n/nss 21\n/nss 22\n/nss 23\n/nss 24\n/nss 25\n/nss 26\n/nss 27\n/nss 28\n/nss 29\n/nss 30\n/nss 31\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NSS1_D ) .. GetString( TTG_NSS2_D ) .. GetString( TTG_NSS3_D ) .. GetString( TTG_NSS4_D ) .. GetString( TTG_NSS5_D ) .. GetString( TTG_NSS6_D ) .. GetString( TTG_NSS7_D ) .. GetString( TTG_NSS8_D ) .. GetString( TTG_NSS9_D ) .. GetString( TTG_NSS10_D ) .. GetString( TTG_NSS11_D ) .. GetString( TTG_NSS12_D ) .. GetString( TTG_NSS13_D ) .. GetString( TTG_NSS14_D ) .. GetString( TTG_NSS15_D ) .. GetString( TTG_NSS16_D ) .. GetString( TTG_NSS17_D ) .. GetString( TTG_NSS18_D ) .. GetString( TTG_NSS19_D ) .. GetString( TTG_NSS20_D ) .. GetString( TTG_NSS21_D ) .. GetString( TTG_NSS22_D ) .. GetString( TTG_NSS23_D ) .. GetString( TTG_NSS24_D ) .. GetString( TTG_NSS25_D ) .. GetString( TTG_NSS26_D ) .. GetString( TTG_NSS27_D ) .. GetString( TTG_NSS28_D ) .. GetString( TTG_NSS29_D ) .. GetString( TTG_NSS30_D ) .. GetString( TTG_NSS31_D ))
TTGAddonIndicatorBg:SetWidth(415)
TTGAddonIndicatorContainer:SetWidth(410)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 31 then
	   bglen = ((24 * 31) + 50)
 	   contlen = ((24 * 31) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 31 then
		       	   bglen = ((24 * 31) + 50)
		           contlen = ((24 * 31) + 16)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 16)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 16)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnss(slashnumber)
TTGAddon.savedVariables.Trial = "nss"
currentTrial = "nss"
TTGAddon.WindowNSS()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NSS1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NSS2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NSS3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NSS4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NSS5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NSS6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NSS7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NSS8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NSS9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NSS10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NSS11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NSS12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NSS13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NSS14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NSS15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NSS16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NSS17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NSS18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NSS19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NSS20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NSS21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NSS22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NSS23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NSS24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NSS25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NSS26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NSS27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NSS28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NSS29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_NSS30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_NSS31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)

    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nss 1" .. green .. GetString( TTG_NSS1_D ) .. orange .. "/nss 2" .. green .. GetString( TTG_NSS2_D ) .. orange .. "/nss 3" .. green .. GetString( TTG_NSS3_D ) .. orange .. "/nss 4" .. green .. GetString( TTG_NSS4_D ) .. orange .. "/nss 5" .. green .. GetString( TTG_NSS5_D ) .. orange .. "/nss 6" .. green .. GetString( TTG_NSS6_D ) .. orange .. "/nss 7" .. green .. GetString( TTG_NSS7_D ) .. orange .. "/nss 8" .. green .. GetString( TTG_NSS8_D ) .. orange .. "/nss 9" .. green .. GetString( TTG_NSS9_D ) .. orange .. "/nss 10" .. green .. GetString( TTG_NSS10_D ) .. orange .. "/nss 11" .. green .. GetString( TTG_NSS11_D ) .. orange .. "/nss 12" .. green .. GetString( TTG_NSS12_D ) .. orange .. "/nss 13" .. green .. GetString( TTG_NSS13_D ) .. orange .. "/nss 14" .. green .. GetString( TTG_NSS14_D ) .. orange .. "/nss 15" .. green .. GetString( TTG_NSS15_D ) .. orange .. "/nss 16" .. green .. GetString( TTG_NSS16_D ) .. orange .. "/nss 17" .. green .. GetString( TTG_NSS17_D ) .. orange .. "/nss 18" .. green .. GetString( TTG_NSS18_D ) .. orange .. "/nss 19" .. green .. GetString( TTG_NSS19_D ) .. orange .. "/nss 20" .. green .. GetString( TTG_NSS20_D ) .. orange .. "/nss 21" .. green .. GetString( TTG_NSS21_D ) .. orange .. "/nss 22" .. green .. GetString( TTG_NSS22_D ) .. orange .. "/nss 23" .. green .. GetString( TTG_NSS23_D ) .. orange .. "/nss 24" .. green .. GetString( TTG_NSS24_D ) .. orange .. "/nss 25" .. green .. GetString( TTG_NSS25_D ) .. orange .. "/nss 26" .. green .. GetString( TTG_NSS26_D ) .. orange .. "/nss 27" .. green .. GetString( TTG_NSS27_D ) .. orange .. "/nss 28" .. green .. GetString( TTG_NSS28_D ) .. orange .. "/nss 29" .. green .. GetString( TTG_NSS29_D ))
      d(orange .. "/nss 30" .. green .. GetString( TTG_NSS30_D ) .. orange .. "/nss 31" .. green .. GetString( TTG_NSS31_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NSS1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NSS2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NSS3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NSS4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NSS5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NSS6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NSS7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NSS8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NSS9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NSS10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NSS11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NSS12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NSS13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NSS14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NSS15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NSS16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NSS17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NSS18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NSS19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NSS20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NSS21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NSS22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NSS23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NSS24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NSS25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NSS26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NSS27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NSS28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NSS29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_NSS30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_NSS31 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nss 1" .. green .. GetString( TTG_NSS1_D ) .. orange .. "/nss 2" .. green .. GetString( TTG_NSS2_D ) .. orange .. "/nss 3" .. green .. GetString( TTG_NSS3_D ) .. orange .. "/nss 4" .. green .. GetString( TTG_NSS4_D ) .. orange .. "/nss 5" .. green .. GetString( TTG_NSS5_D ) .. orange .. "/nss 6" .. green .. GetString( TTG_NSS6_D ) .. orange .. "/nss 7" .. green .. GetString( TTG_NSS7_D ) .. orange .. "/nss 8" .. green .. GetString( TTG_NSS8_D ) .. orange .. "/nss 9" .. green .. GetString( TTG_NSS9_D ) .. orange .. "/nss 10" .. green .. GetString( TTG_NSS10_D ) .. orange .. "/nss 11" .. green .. GetString( TTG_NSS11_D ) .. orange .. "/nss 12" .. green .. GetString( TTG_NSS12_D ) .. orange .. "/nss 13" .. green .. GetString( TTG_NSS13_D ) .. orange .. "/nss 14" .. green .. GetString( TTG_NSS14_D ) .. orange .. "/nss 15" .. green .. GetString( TTG_NSS15_D ) .. orange .. "/nss 16" .. green .. GetString( TTG_NSS16_D ) .. orange .. "/nss 17" .. green .. GetString( TTG_NSS17_D ) .. orange .. "/nss 18" .. green .. GetString( TTG_NSS18_D ) .. orange .. "/nss 19" .. green .. GetString( TTG_NSS19_D ) .. orange .. "/nss 20" .. green .. GetString( TTG_NSS20_D ) .. orange .. "/nss 21" .. green .. GetString( TTG_NSS21_D ) .. orange .. "/nss 22" .. green .. GetString( TTG_NSS22_D ) .. orange .. "/nss 23" .. green .. GetString( TTG_NSS23_D ) .. orange .. "/nss 24" .. green .. GetString( TTG_NSS24_D ) .. orange .. "/nss 25" .. green .. GetString( TTG_NSS25_D ) .. orange .. "/nss 26" .. green .. GetString( TTG_NSS26_D ) .. orange .. "/nss 27" .. green .. GetString( TTG_NSS27_D ) .. orange .. "/nss 28" .. green .. GetString( TTG_NSS28_D ) .. orange .. "/nss 29" .. green .. GetString( TTG_NSS29_D ))
      d(orange .. "/nss 30" .. green .. GetString( TTG_NSS30_D ) .. orange .. "/nss 31" .. green .. GetString( TTG_NSS31_D ))
	end
    end
  end
end

-- SUNSPIRE VETERAN

function TTGAddon.WindowVSS()
TTGAddonIndicatorData:SetText("/vss 1\n/vss 2\n/vss 3\n/vss 4\n/vss 5\n/vss 6\n/vss 7\n/vss 8\n/vss 9\n/vss 10\n/vss 11\n/vss 12\n/vss 13\n/vss 14\n/vss 15\n/vss 16\n/vss 17\n/vss 18\n/vss 19\n/vss 20\n/vss 21\n/vss 22\n/vss 23\n/vss 24\n/vss 25\n/vss 26\n/vss 27\n/vss 28\n/vss 29\n/vss 30\n/vss 31\n/vss 32\n/vss 33\n/vss 34\n/vss 35\n/vss 36\n/vss 37\n/vss 38\n/vss 39\n/vss 40\n/vss 41\n/vss 42\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VSS1_D ) .. GetString( TTG_VSS2_D ) .. GetString( TTG_VSS3_D ) .. GetString( TTG_VSS4_D ) .. GetString( TTG_VSS5_D ) .. GetString( TTG_VSS6_D ) .. GetString( TTG_VSS7_D ) .. GetString( TTG_VSS8_D ) .. GetString( TTG_VSS9_D ) .. GetString( TTG_VSS10_D ) .. GetString( TTG_VSS11_D ) .. GetString( TTG_VSS12_D ) .. GetString( TTG_VSS13_D ) .. GetString( TTG_VSS14_D ) .. GetString( TTG_VSS15_D ) .. GetString( TTG_VSS16_D ) .. GetString( TTG_VSS17_D ) .. GetString( TTG_VSS18_D ) .. GetString( TTG_VSS19_D ) .. GetString( TTG_VSS20_D ) .. GetString( TTG_VSS21_D ) .. GetString( TTG_VSS22_D ) .. GetString( TTG_VSS23_D ) .. GetString( TTG_VSS24_D ) .. GetString( TTG_VSS25_D ) .. GetString( TTG_VSS26_D ) .. GetString( TTG_VSS27_D ) .. GetString( TTG_VSS28_D ) .. GetString( TTG_VSS29_D ) .. GetString( TTG_VSS30_D ) .. GetString( TTG_VSS31_D ) .. GetString( TTG_VSS32_D ) .. GetString( TTG_VSS33_D ) .. GetString( TTG_VSS34_D ) .. GetString( TTG_VSS35_D ) .. GetString( TTG_VSS36_D ) .. GetString( TTG_VSS37_D ) .. GetString( TTG_VSS38_D ) .. GetString( TTG_VSS39_D ) .. GetString( TTG_VSS40_D ) .. GetString( TTG_VSS41_D ) .. GetString( TTG_VSS42_D ))
TTGAddonIndicatorBg:SetWidth(415)
TTGAddonIndicatorContainer:SetWidth(410)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 42 then
	   bglen = ((24 * 42) + 45)
 	   contlen = ((24 * 42) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 48)
 	   contlen = ((24 * currentcommandlength) + 14)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 42 then
		       	   bglen = ((24 * 42) + 45)
		           contlen = ((24 * 42) + 12)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 48)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 14)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvss(slashnumber)
TTGAddon.savedVariables.Trial = "vss"
currentTrial = "vss"
TTGAddon.WindowVSS()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VSS1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VSS2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VSS3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VSS4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VSS5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VSS6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VSS7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VSS8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VSS9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VSS10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VSS11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VSS12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VSS13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VSS14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VSS15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VSS16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VSS17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VSS18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VSS19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VSS20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VSS21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VSS22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VSS23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VSS24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VSS25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VSS26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VSS27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VSS28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VSS29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VSS30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VSS31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VSS32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VSS33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VSS34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VSS35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VSS36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VSS37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VSS38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_VSS39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_VSS40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_VSS41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_VSS42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vss 1" .. green .. GetString( TTG_VSS1_D ) .. orange .. "/vss 2" .. green .. GetString( TTG_VSS2_D ) .. orange .. "/vss 3" .. green .. GetString( TTG_VSS3_D ) .. orange .. "/vss 4" .. green .. GetString( TTG_VSS4_D ) .. orange .. "/vss 5" .. green .. GetString( TTG_VSS5_D ) .. orange .. "/vss 6" .. green .. GetString( TTG_VSS6_D ) .. orange .. "/vss 7" .. green .. GetString( TTG_VSS7_D ) .. orange .. "/vss 8" .. green .. GetString( TTG_VSS8_D ) .. orange .. "/vss 9" .. green .. GetString( TTG_VSS9_D ) .. orange .. "/vss 10" .. green .. GetString( TTG_VSS10_D ) .. orange .. "/vss 11" .. green .. GetString( TTG_VSS11_D ) .. orange .. "/vss 12" .. green .. GetString( TTG_VSS12_D ) .. orange .. "/vss 13" .. green .. GetString( TTG_VSS13_D ) .. orange .. "/vss 14" .. green .. GetString( TTG_VSS14_D ) .. orange .. "/vss 15" .. green .. GetString( TTG_VSS15_D ) .. orange .. "/vss 16" .. green .. GetString( TTG_VSS16_D ) .. orange .. "/vss 17" .. green .. GetString( TTG_VSS17_D ) .. orange .. "/vss 18" .. green .. GetString( TTG_VSS18_D ) .. orange .. "/vss 19" .. green .. GetString( TTG_VSS19_D ) .. orange .. "/vss 20" .. green .. GetString( TTG_VSS20_D ) .. orange .. "/vss 21" .. green .. GetString( TTG_VSS21_D ) .. orange .. "/vss 22" .. green .. GetString( TTG_VSS22_D ) .. orange .. "/vss 23" .. green .. GetString( TTG_VSS23_D ) .. orange .. "/vss 24" .. green .. GetString( TTG_VSS24_D ) .. orange .. "/vss 25" .. green .. GetString( TTG_VSS25_D ) .. orange .. "/vss 26" .. green .. GetString( TTG_VSS26_D ) .. orange .. "/vss 27" .. green .. GetString( TTG_VSS27_D ) .. orange .. "/vss 28" .. green .. GetString( TTG_VSS28_D ) .. orange .. "/vss 29" .. green .. GetString( TTG_VSS29_D ))
      d(orange .. "/vss 30" .. green .. GetString( TTG_VSS30_D ) .. orange .. "/vss 31" .. green .. GetString( TTG_VSS31_D ) .. orange .. "/vss 32" .. green .. GetString( TTG_VSS32_D ) .. orange .. "/vss 33" .. green .. GetString( TTG_VSS33_D ) .. orange .. "/vss 34" .. green .. GetString( TTG_VSS34_D ) .. orange .. "/vss 35" .. green .. GetString( TTG_VSS35_D ) .. orange .. "/vss 36" .. green .. GetString( TTG_VSS36_D ) .. orange .. "/vss 37" .. green .. GetString( TTG_VSS37_D ) .. orange .. "/vss 38" .. green .. GetString( TTG_VSS38_D ) .. orange .. "/vss 39" .. green .. GetString( TTG_VSS39_D ) .. orange .. "/vss 40" .. green .. GetString( TTG_VSS40_D ) .. orange .. "/vss 41" .. green .. GetString( TTG_VSS41_D ) .. orange .. "/vss 42" .. green .. GetString( TTG_VSS42_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VSS1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VSS2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VSS3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VSS4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VSS5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VSS6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VSS7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VSS8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VSS9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VSS10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VSS11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VSS12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VSS13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VSS14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VSS15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VSS16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VSS17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VSS18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VSS19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VSS20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VSS21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VSS22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VSS23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VSS24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VSS25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VSS26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VSS27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VSS28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VSS29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VSS30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VSS31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VSS32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VSS33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VSS34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VSS35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VSS36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VSS37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VSS38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_VSS39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_VSS40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_VSS41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_VSS42 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vss 1" .. green .. GetString( TTG_VSS1_D ) .. orange .. "/vss 2" .. green .. GetString( TTG_VSS2_D ) .. orange .. "/vss 3" .. green .. GetString( TTG_VSS3_D ) .. orange .. "/vss 4" .. green .. GetString( TTG_VSS4_D ) .. orange .. "/vss 5" .. green .. GetString( TTG_VSS5_D ) .. orange .. "/vss 6" .. green .. GetString( TTG_VSS6_D ) .. orange .. "/vss 7" .. green .. GetString( TTG_VSS7_D ) .. orange .. "/vss 8" .. green .. GetString( TTG_VSS8_D ) .. orange .. "/vss 9" .. green .. GetString( TTG_VSS9_D ) .. orange .. "/vss 10" .. green .. GetString( TTG_VSS10_D ) .. orange .. "/vss 11" .. green .. GetString( TTG_VSS11_D ) .. orange .. "/vss 12" .. green .. GetString( TTG_VSS12_D ) .. orange .. "/vss 13" .. green .. GetString( TTG_VSS13_D ) .. orange .. "/vss 14" .. green .. GetString( TTG_VSS14_D ) .. orange .. "/vss 15" .. green .. GetString( TTG_VSS15_D ) .. orange .. "/vss 16" .. green .. GetString( TTG_VSS16_D ) .. orange .. "/vss 17" .. green .. GetString( TTG_VSS17_D ) .. orange .. "/vss 18" .. green .. GetString( TTG_VSS18_D ) .. orange .. "/vss 19" .. green .. GetString( TTG_VSS19_D ) .. orange .. "/vss 20" .. green .. GetString( TTG_VSS20_D ) .. orange .. "/vss 21" .. green .. GetString( TTG_VSS21_D ) .. orange .. "/vss 22" .. green .. GetString( TTG_VSS22_D ) .. orange .. "/vss 23" .. green .. GetString( TTG_VSS23_D ) .. orange .. "/vss 24" .. green .. GetString( TTG_VSS24_D ) .. orange .. "/vss 25" .. green .. GetString( TTG_VSS25_D ) .. orange .. "/vss 26" .. green .. GetString( TTG_VSS26_D ) .. orange .. "/vss 27" .. green .. GetString( TTG_VSS27_D ) .. orange .. "/vss 28" .. green .. GetString( TTG_VSS28_D ) .. orange .. "/vss 29" .. green .. GetString( TTG_VSS29_D ))
      d(orange .. "/vss 30" .. green .. GetString( TTG_VSS30_D ) .. orange .. "/vss 31" .. green .. GetString( TTG_VSS31_D ) .. orange .. "/vss 32" .. green .. GetString( TTG_VSS32_D ) .. orange .. "/vss 33" .. green .. GetString( TTG_VSS33_D ) .. orange .. "/vss 34" .. green .. GetString( TTG_VSS34_D ) .. orange .. "/vss 35" .. green .. GetString( TTG_VSS35_D ) .. orange .. "/vss 36" .. green .. GetString( TTG_VSS36_D ) .. orange .. "/vss 37" .. green .. GetString( TTG_VSS37_D ) .. orange .. "/vss 38" .. green .. GetString( TTG_VSS38_D ) .. orange .. "/vss 39" .. green .. GetString( TTG_VSS39_D ) .. orange .. "/vss 40" .. green .. GetString( TTG_VSS40_D ) .. orange .. "/vss 41" .. green .. GetString( TTG_VSS41_D ) .. orange .. "/vss 42" .. green .. GetString( TTG_VSS42_D ))
	end
    end
  end
end

-- KYNES AEGIS NORMAL

function TTGAddon.WindowNKA()
TTGAddonIndicatorData:SetText("/nka 1\n/nka 2\n/nka 3\n/nka 4\n/nka 5\n/nka 6\n/nka 7\n/nka 8\n/nka 9\n/nka 10\n/nka 11\n/nka 12\n/nka 13\n/nka 14\n/nka 15\n/nka 16\n/nka 17\n/nka 18\n/nka 19\n/nka 20\n/nka 21\n/nka 22\n/nka 23\n/nka 24\n/nka 25\n/nka 26\n/nka 27\n/nka 28\n/nka 29\n/nka 30\n/nka 31\n/nka 32\n/nka 33\n/nka 34\n/nka 35\n/nka 36\n/nka 37\n/nka 38\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NKA1_D ) .. GetString( TTG_NKA2_D ) .. GetString( TTG_NKA3_D ) .. GetString( TTG_NKA4_D ) .. GetString( TTG_NKA5_D ) .. GetString( TTG_NKA6_D ) .. GetString( TTG_NKA7_D ) .. GetString( TTG_NKA8_D ) .. GetString( TTG_NKA9_D ) .. GetString( TTG_NKA10_D ) .. GetString( TTG_NKA11_D ) .. GetString( TTG_NKA12_D ) .. GetString( TTG_NKA13_D ) .. GetString( TTG_NKA14_D ) .. GetString( TTG_NKA15_D ) .. GetString( TTG_NKA16_D ) .. GetString( TTG_NKA17_D ) .. GetString( TTG_NKA18_D ) .. GetString( TTG_NKA19_D ) .. GetString( TTG_NKA20_D ) .. GetString( TTG_NKA21_D ) .. GetString( TTG_NKA22_D ) .. GetString( TTG_NKA23_D ) .. GetString( TTG_NKA24_D ) .. GetString( TTG_NKA25_D ) .. GetString( TTG_NKA26_D ) .. GetString( TTG_NKA27_D ) .. GetString( TTG_NKA28_D ) .. GetString( TTG_NKA29_D ) .. GetString( TTG_NKA30_D ) .. GetString( TTG_NKA31_D ) .. GetString( TTG_NKA32_D ) .. GetString( TTG_NKA33_D ) .. GetString( TTG_NKA34_D ) .. GetString( TTG_NKA35_D ) .. GetString( TTG_NKA36_D ) .. GetString( TTG_NKA37_D ) .. GetString( TTG_NKA38_D ))
TTGAddonIndicatorBg:SetWidth(390)
TTGAddonIndicatorContainer:SetWidth(385)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 38 then
	   bglen = ((24 * 38) + 50)
 	   contlen = ((24 * 38) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 16)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 42 then
		       	   bglen = ((24 * 38) + 50)
		           contlen = ((24 * 38) + 16)
	 	       	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
	  	       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 16)
	        	   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 16)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnka(slashnumber)
TTGAddon.savedVariables.Trial = "nka"
currentTrial = "nka"
TTGAddon.WindowNKA()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NKA1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NKA2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NKA3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NKA4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NKA5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NKA6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NKA7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NKA8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NKA9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NKA10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NKA11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NKA12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NKA13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NKA14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NKA15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NKA16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NKA17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NKA18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NKA19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NKA20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NKA21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NKA22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NKA23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NKA24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NKA25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NKA26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NKA27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NKA28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NKA29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_NKA30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_NKA31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_NKA32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_NKA33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_NKA34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_NKA35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_NKA36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_NKA37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_NKA38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nka 1" .. green .. GetString( TTG_NKA1_D ) .. orange .. "/nka 2" .. green .. GetString( TTG_NKA2_D ) .. orange .. "/nka 3" .. green .. GetString( TTG_NKA3_D ) .. orange .. "/nka 4" .. green .. GetString( TTG_NKA4_D ) .. orange .. "/nka 5" .. green .. GetString( TTG_NKA5_D ) .. orange .. "/nka 6" .. green .. GetString( TTG_NKA6_D ) .. orange .. "/nka 7" .. green .. GetString( TTG_NKA7_D ) .. orange .. "/nka 8" .. green .. GetString( TTG_NKA8_D ) .. orange .. "/nka 9" .. green .. GetString( TTG_NKA9_D ) .. orange .. "/nka 10" .. green .. GetString( TTG_NKA10_D ) .. orange .. "/nka 11" .. green .. GetString( TTG_NKA11_D ) .. orange .. "/nka 12" .. green .. GetString( TTG_NKA12_D ) .. orange .. "/nka 13" .. green .. GetString( TTG_NKA13_D ) .. orange .. "/nka 14" .. green .. GetString( TTG_NKA14_D ) .. orange .. "/nka 15" .. green .. GetString( TTG_NKA15_D ) .. orange .. "/nka 16" .. green .. GetString( TTG_NKA16_D ) .. orange .. "/nka 17" .. green .. GetString( TTG_NKA17_D ) .. orange .. "/nka 18" .. green .. GetString( TTG_NKA18_D ) .. orange .. "/nka 19" .. green .. GetString( TTG_NKA19_D ) .. orange .. "/nka 20" .. green .. GetString( TTG_NKA20_D ) .. orange .. "/nka 21" .. green .. GetString( TTG_NKA21_D ) .. orange .. "/nka 22" .. green .. GetString( TTG_NKA22_D ) .. orange .. "/nka 23" .. green .. GetString( TTG_NKA23_D ) .. orange .. "/nka 24" .. green .. GetString( TTG_NKA24_D ) .. orange .. "/nka 25" .. green .. GetString( TTG_NKA25_D ) .. orange .. "/nka 26" .. green .. GetString( TTG_NKA26_D ) .. orange .. "/nka 27" .. green .. GetString( TTG_NKA27_D ) .. orange .. "/nka 28" .. green .. GetString( TTG_NKA28_D ) .. orange .. "/nka 29" .. green .. GetString( TTG_NKA29_D ))
      d(orange .. "/nka 30" .. green .. GetString( TTG_NKA30_D ) .. orange .. "/nka 31" .. green .. GetString( TTG_NKA31_D ) .. orange .. "/nka 32" .. green .. GetString( TTG_NKA32_D ) .. orange .. "/nka 33" .. green .. GetString( TTG_NKA33_D ) .. orange .. "/nka 34" .. green .. GetString( TTG_NKA34_D ) .. orange .. "/nka 35" .. green .. GetString( TTG_NKA35_D ) .. orange .. "/nka 36" .. green .. GetString( TTG_NKA36_D ) .. orange .. "/nka 37" .. green .. GetString( TTG_NKA37_D ) .. orange .. "/nka 38" .. green .. GetString( TTG_NKA38_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NKA1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NKA2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NKA3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NKA4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NKA5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NKA6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NKA7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NKA8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NKA9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NKA10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NKA11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NKA12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NKA13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NKA14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NKA15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NKA16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NKA17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NKA18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NKA19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NKA20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NKA21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NKA22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NKA23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NKA24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NKA25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NKA26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NKA27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NKA28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NKA29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_NKA30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_NKA31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_NKA32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_NKA33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_NKA34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_NKA35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_NKA36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_NKA37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_NKA38 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nka 1" .. green .. GetString( TTG_NKA1_D ) .. orange .. "/nka 2" .. green .. GetString( TTG_NKA2_D ) .. orange .. "/nka 3" .. green .. GetString( TTG_NKA3_D ) .. orange .. "/nka 4" .. green .. GetString( TTG_NKA4_D ) .. orange .. "/nka 5" .. green .. GetString( TTG_NKA5_D ) .. orange .. "/nka 6" .. green .. GetString( TTG_NKA6_D ) .. orange .. "/nka 7" .. green .. GetString( TTG_NKA7_D ) .. orange .. "/nka 8" .. green .. GetString( TTG_NKA8_D ) .. orange .. "/nka 9" .. green .. GetString( TTG_NKA9_D ) .. orange .. "/nka 10" .. green .. GetString( TTG_NKA10_D ) .. orange .. "/nka 11" .. green .. GetString( TTG_NKA11_D ) .. orange .. "/nka 12" .. green .. GetString( TTG_NKA12_D ) .. orange .. "/nka 13" .. green .. GetString( TTG_NKA13_D ) .. orange .. "/nka 14" .. green .. GetString( TTG_NKA14_D ) .. orange .. "/nka 15" .. green .. GetString( TTG_NKA15_D ) .. orange .. "/nka 16" .. green .. GetString( TTG_NKA16_D ) .. orange .. "/nka 17" .. green .. GetString( TTG_NKA17_D ) .. orange .. "/nka 18" .. green .. GetString( TTG_NKA18_D ) .. orange .. "/nka 19" .. green .. GetString( TTG_NKA19_D ) .. orange .. "/nka 20" .. green .. GetString( TTG_NKA20_D ) .. orange .. "/nka 21" .. green .. GetString( TTG_NKA21_D ) .. orange .. "/nka 22" .. green .. GetString( TTG_NKA22_D ) .. orange .. "/nka 23" .. green .. GetString( TTG_NKA23_D ) .. orange .. "/nka 24" .. green .. GetString( TTG_NKA24_D ) .. orange .. "/nka 25" .. green .. GetString( TTG_NKA25_D ) .. orange .. "/nka 26" .. green .. GetString( TTG_NKA26_D ) .. orange .. "/nka 27" .. green .. GetString( TTG_NKA27_D ) .. orange .. "/nka 28" .. green .. GetString( TTG_NKA28_D ) .. orange .. "/nka 29" .. green .. GetString( TTG_NKA29_D ))
      d(orange .. "/nka 30" .. green .. GetString( TTG_NKA30_D ) .. orange .. "/nka 31" .. green .. GetString( TTG_NKA31_D ) .. orange .. "/nka 32" .. green .. GetString( TTG_NKA32_D ) .. orange .. "/nka 33" .. green .. GetString( TTG_NKA33_D ) .. orange .. "/nka 34" .. green .. GetString( TTG_NKA34_D ) .. orange .. "/nka 35" .. green .. GetString( TTG_NKA35_D ) .. orange .. "/nka 36" .. green .. GetString( TTG_NKA36_D ) .. orange .. "/nka 37" .. green .. GetString( TTG_NKA37_D ) .. orange .. "/nka 38" .. green .. GetString( TTG_NKA38_D ))
	end
    end
  end
end

-- KYNES AEGIS VETERAN

function TTGAddon.WindowVKA()
TTGAddonIndicatorData:SetText("/vka 1\n/vka 2\n/vka 3\n/vka 4\n/vka 5\n/vka 6\n/vka 7\n/vka 8\n/vka 9\n/vka 10\n/vka 11\n/vka 12\n/vka 13\n/vka 14\n/vka 15\n/vka 16\n/vka 17\n/vka 18\n/vka 19\n/vka 20\n/vka 21\n/vka 22\n/vka 23\n/vka 24\n/vka 25\n/vka 26\n/vka 27\n/vka 28\n/vka 29\n/vka 30\n/vka 31\n/vka 32\n/vka 33\n/vka 34\n/vka 35\n/vka 36\n/vka 37\n/vka 38\n/vka 39\n/vka 40\n/vka 41\n/vka 42\n/vka 43\n/vka 44\n/vka 45\n/vka 46\n/vka 47\n/vka 48\n/vka 49\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VKA1_D ) .. GetString( TTG_VKA2_D ) .. GetString( TTG_VKA3_D ) .. GetString( TTG_VKA4_D ) .. GetString( TTG_VKA5_D ) .. GetString( TTG_VKA6_D ) .. GetString( TTG_VKA7_D ) .. GetString( TTG_VKA8_D ) .. GetString( TTG_VKA9_D ) .. GetString( TTG_VKA10_D ) .. GetString( TTG_VKA11_D ) .. GetString( TTG_VKA12_D ) .. GetString( TTG_VKA13_D ) .. GetString( TTG_VKA14_D ) .. GetString( TTG_VKA15_D ) .. GetString( TTG_VKA16_D ) .. GetString( TTG_VKA17_D ) .. GetString( TTG_VKA18_D ) .. GetString( TTG_VKA19_D ) .. GetString( TTG_VKA20_D ) .. GetString( TTG_VKA21_D ) .. GetString( TTG_VKA22_D ) .. GetString( TTG_VKA23_D ) .. GetString( TTG_VKA24_D ) .. GetString( TTG_VKA25_D ) .. GetString( TTG_VKA26_D ) .. GetString( TTG_VKA27_D ) .. GetString( TTG_VKA28_D ) .. GetString( TTG_VKA29_D ) .. GetString( TTG_VKA30_D ) .. GetString( TTG_VKA31_D ) .. GetString( TTG_VKA32_D ) .. GetString( TTG_VKA33_D ) .. GetString( TTG_VKA34_D ) .. GetString( TTG_VKA35_D ) .. GetString( TTG_VKA36_D ) .. GetString( TTG_VKA37_D ) .. GetString( TTG_VKA38_D ) .. GetString( TTG_VKA39_D ) .. GetString( TTG_VKA40_D ) .. GetString( TTG_VKA41_D ) .. GetString( TTG_VKA42_D ) .. GetString( TTG_VKA43_D ) .. GetString( TTG_VKA44_D ) .. GetString( TTG_VKA45_D ) .. GetString( TTG_VKA46_D ) .. GetString( TTG_VKA47_D ) .. GetString( TTG_VKA48_D ) .. GetString( TTG_VKA49_D ))
TTGAddonIndicatorBg:SetWidth(390)
TTGAddonIndicatorContainer:SetWidth(385)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 49 then
	   bglen = ((24 * 49) + 45)
 	   contlen = ((24 * 49) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 49 then
		       	   bglen = ((24 * 49) + 45)
		           contlen = ((24 * 49) + 12)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  	       		   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvka(slashnumber)
TTGAddon.savedVariables.Trial = "vka"
currentTrial = "vka"
TTGAddon.WindowVKA()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VKA1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VKA2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VKA3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VKA4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VKA5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VKA6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VKA7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VKA8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VKA9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VKA10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VKA11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VKA12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VKA13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VKA14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VKA15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VKA16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VKA17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VKA18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VKA19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VKA20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VKA21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VKA22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VKA23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VKA24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VKA25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VKA26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VKA27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VKA28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VKA29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VKA30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VKA31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VKA32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VKA33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VKA34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VKA35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VKA36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VKA37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VKA38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_VKA39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_VKA40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_VKA41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_VKA42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_VKA43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_VKA44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_VKA45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_VKA46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_VKA47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "48" then
      text = wheretoplace .. " " .. GetString( TTG_VKA48 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "49" then
      text = wheretoplace .. " " .. GetString( TTG_VKA49 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vka 1" .. green .. GetString( TTG_VKA1_D ) .. orange .. "/vka 2" .. green .. GetString( TTG_VKA2_D ) .. orange .. "/vka 3" .. green .. GetString( TTG_VKA3_D ) .. orange .. "/vka 4" .. green .. GetString( TTG_VKA4_D ) .. orange .. "/vka 5" .. green .. GetString( TTG_VKA5_D ) .. orange .. "/vka 6" .. green .. GetString( TTG_VKA6_D ) .. orange .. "/vka 7" .. green .. GetString( TTG_VKA7_D ) .. orange .. "/vka 8" .. green .. GetString( TTG_VKA8_D ) .. orange .. "/vka 9" .. green .. GetString( TTG_VKA9_D ) .. orange .. "/vka 10" .. green .. GetString( TTG_VKA10_D ) .. orange .. "/vka 11" .. green .. GetString( TTG_VKA11_D ) .. orange .. "/vka 12" .. green .. GetString( TTG_VKA12_D ) .. orange .. "/vka 13" .. green .. GetString( TTG_VKA13_D ) .. orange .. "/vka 14" .. green .. GetString( TTG_VKA14_D ) .. orange .. "/vka 15" .. green .. GetString( TTG_VKA15_D ) .. orange .. "/vka 16" .. green .. GetString( TTG_VKA16_D ) .. orange .. "/vka 17" .. green .. GetString( TTG_VKA17_D ) .. orange .. "/vka 18" .. green .. GetString( TTG_VKA18_D ) .. orange .. "/vka 19" .. green .. GetString( TTG_VKA19_D ) .. orange .. "/vka 20" .. green .. GetString( TTG_VKA20_D ) .. orange .. "/vka 21" .. green .. GetString( TTG_VKA21_D ) .. orange .. "/vka 22" .. green .. GetString( TTG_VKA22_D ) .. orange .. "/vka 23" .. green .. GetString( TTG_VKA23_D ) .. orange .. "/vka 24" .. green .. GetString( TTG_VKA24_D ) .. orange .. "/vka 25" .. green .. GetString( TTG_VKA25_D ) .. orange .. "/vka 26" .. green .. GetString( TTG_VKA26_D ) .. orange .. "/vka 27" .. green .. GetString( TTG_VKA27_D ) .. orange .. "/vka 28" .. green .. GetString( TTG_VKA28_D ) .. orange .. "/vka 29" .. green .. GetString( TTG_VKA29_D ))
      d(orange .. "/vka 30" .. green .. GetString( TTG_VKA30_D ) .. orange .. "/vka 31" .. green .. GetString( TTG_VKA31_D ) .. orange .. "/vka 32" .. green .. GetString( TTG_VKA32_D ) .. orange .. "/vka 33" .. green .. GetString( TTG_VKA33_D ) .. orange .. "/vka 34" .. green .. GetString( TTG_VKA34_D ) .. orange .. "/vka 35" .. green .. GetString( TTG_VKA35_D ) .. orange .. "/vka 36" .. green .. GetString( TTG_VKA36_D ) .. orange .. "/vka 37" .. green .. GetString( TTG_VKA37_D ) .. orange .. "/vka 38" .. green .. GetString( TTG_VKA38_D ) .. orange .. "/vka 39" .. green .. GetString( TTG_VKA39_D ) .. orange .. "/vka 40" .. green .. GetString( TTG_VKA40_D ) .. orange .. "/vka 41" .. green .. GetString( TTG_VKA41_D ) .. orange .. "/vka 42" .. green .. GetString( TTG_VKA42_D ) .. orange .. "/vka 43" .. green .. GetString( TTG_VKA43_D ) .. orange .. "/vka 44" .. green .. GetString( TTG_VKA44_D ) .. orange .. "/vka 45" .. green .. GetString( TTG_VKA45_D ) .. orange .. "/vka 46" .. green .. GetString( TTG_VKA46_D ) .. orange .. "/vka 47" .. green .. GetString( TTG_VKA47_D ) .. orange .. "/vka 48" .. green .. GetString( TTG_VKA48_D ) .. orange .. "/vka 49" .. green .. GetString( TTG_VKA49_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VKA1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VKA2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VKA3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VKA4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VKA5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VKA6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VKA7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VKA8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VKA9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VKA10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VKA11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VKA12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VKA13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VKA14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VKA15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VKA16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VKA17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VKA18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VKA19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VKA20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VKA21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VKA22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VKA23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VKA24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VKA25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VKA26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VKA27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VKA28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VKA29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VKA30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VKA31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VKA32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VKA33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VKA34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VKA35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VKA36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VKA37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VKA38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_VKA39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_VKA40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_VKA41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_VKA42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_VKA43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_VKA44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_VKA45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_VKA46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_VKA47 ))
    elseif slashnumber == "48" then
      d(colourtouse .. GetString( TTG_VKA48 ))
    elseif slashnumber == "49" then
      d(colourtouse .. GetString( TTG_VKA49 ))

    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vka 1" .. green .. GetString( TTG_VKA1_D ) .. orange .. "/vka 2" .. green .. GetString( TTG_VKA2_D ) .. orange .. "/vka 3" .. green .. GetString( TTG_VKA3_D ) .. orange .. "/vka 4" .. green .. GetString( TTG_VKA4_D ) .. orange .. "/vka 5" .. green .. GetString( TTG_VKA5_D ) .. orange .. "/vka 6" .. green .. GetString( TTG_VKA6_D ) .. orange .. "/vka 7" .. green .. GetString( TTG_VKA7_D ) .. orange .. "/vka 8" .. green .. GetString( TTG_VKA8_D ) .. orange .. "/vka 9" .. green .. GetString( TTG_VKA9_D ) .. orange .. "/vka 10" .. green .. GetString( TTG_VKA10_D ) .. orange .. "/vka 11" .. green .. GetString( TTG_VKA11_D ) .. orange .. "/vka 12" .. green .. GetString( TTG_VKA12_D ) .. orange .. "/vka 13" .. green .. GetString( TTG_VKA13_D ) .. orange .. "/vka 14" .. green .. GetString( TTG_VKA14_D ) .. orange .. "/vka 15" .. green .. GetString( TTG_VKA15_D ) .. orange .. "/vka 16" .. green .. GetString( TTG_VKA16_D ) .. orange .. "/vka 17" .. green .. GetString( TTG_VKA17_D ) .. orange .. "/vka 18" .. green .. GetString( TTG_VKA18_D ) .. orange .. "/vka 19" .. green .. GetString( TTG_VKA19_D ) .. orange .. "/vka 20" .. green .. GetString( TTG_VKA20_D ) .. orange .. "/vka 21" .. green .. GetString( TTG_VKA21_D ) .. orange .. "/vka 22" .. green .. GetString( TTG_VKA22_D ) .. orange .. "/vka 23" .. green .. GetString( TTG_VKA23_D ) .. orange .. "/vka 24" .. green .. GetString( TTG_VKA24_D ) .. orange .. "/vka 25" .. green .. GetString( TTG_VKA25_D ) .. orange .. "/vka 26" .. green .. GetString( TTG_VKA26_D ) .. orange .. "/vka 27" .. green .. GetString( TTG_VKA27_D ) .. orange .. "/vka 28" .. green .. GetString( TTG_VKA28_D ) .. orange .. "/vka 29" .. green .. GetString( TTG_VKA29_D ))
      d(orange .. "/vka 30" .. green .. GetString( TTG_VKA30_D ) .. orange .. "/vka 31" .. green .. GetString( TTG_VKA31_D ) .. orange .. "/vka 32" .. green .. GetString( TTG_VKA32_D ) .. orange .. "/vka 33" .. green .. GetString( TTG_VKA33_D ) .. orange .. "/vka 34" .. green .. GetString( TTG_VKA34_D ) .. orange .. "/vka 35" .. green .. GetString( TTG_VKA35_D ) .. orange .. "/vka 36" .. green .. GetString( TTG_VKA36_D ) .. orange .. "/vka 37" .. green .. GetString( TTG_VKA37_D ) .. orange .. "/vka 38" .. green .. GetString( TTG_VKA38_D ) .. orange .. "/vka 39" .. green .. GetString( TTG_VKA39_D ) .. orange .. "/vka 40" .. green .. GetString( TTG_VKA40_D ) .. orange .. "/vka 41" .. green .. GetString( TTG_VKA41_D ) .. orange .. "/vka 42" .. green .. GetString( TTG_VKA42_D ) .. orange .. "/vka 43" .. green .. GetString( TTG_VKA43_D ) .. orange .. "/vka 44" .. green .. GetString( TTG_VKA44_D ) .. orange .. "/vka 45" .. green .. GetString( TTG_VKA45_D ) .. orange .. "/vka 46" .. green .. GetString( TTG_VKA46_D ) .. orange .. "/vka 47" .. green .. GetString( TTG_VKA47_D ) .. orange .. "/vka 48" .. green .. GetString( TTG_VKA48_D ) .. orange .. "/vka 49" .. green .. GetString( TTG_VKA49_D ))
	end
    end
  end
end


-- ROCKGROVE NORMAL

function TTGAddon.WindowNRG()
TTGAddonIndicatorData:SetText("/nrg 1\n/nrg 2\n/nrg 3\n/nrg 4\n/nrg 5\n/nrg 6\n/nrg 7\n/nrg 8\n/nrg 9\n/nrg 10\n/nrg 11\n/nrg 12\n/nrg 13\n/nrg 14\n/nrg 15\n/nrg 16\n/nrg 17\n/nrg 18\n/nrg 19\n/nrg 20\n/nrg 21\n/nrg 22\n/nrg 23\n/nrg 24\n/nrg 25\n/nrg 26\n/nrg 27\n/nrg 28\n/nrg 29\n/nrg 30\n/nrg 31\n/nrg 32\n/nrg 33\n/nrg 34\n/nrg 35\n/nrg 36\n/nrg 37\n/nrg 38\n/nrg 39\n/nrg 40\n/nrg 41\n/nrg 42\n/nrg 43\n/nrg 44\n/nrg 45\n/nrg 46\n/nrg 47\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_NRG1_D ) .. GetString( TTG_NRG2_D ) .. GetString( TTG_NRG3_D ) .. GetString( TTG_NRG4_D ) .. GetString( TTG_NRG5_D ) .. GetString( TTG_NRG6_D ) .. GetString( TTG_NRG7_D ) .. GetString( TTG_NRG8_D ) .. GetString( TTG_NRG9_D ) .. GetString( TTG_NRG10_D ) .. GetString( TTG_NRG11_D ) .. GetString( TTG_NRG12_D ) .. GetString( TTG_NRG13_D ) .. GetString( TTG_NRG14_D ) .. GetString( TTG_NRG15_D ) .. GetString( TTG_NRG16_D ) .. GetString( TTG_NRG17_D ) .. GetString( TTG_NRG18_D ) .. GetString( TTG_NRG19_D ) .. GetString( TTG_NRG20_D ) .. GetString( TTG_NRG21_D ) .. GetString( TTG_NRG22_D ) .. GetString( TTG_NRG23_D ) .. GetString( TTG_NRG24_D ) .. GetString( TTG_NRG25_D ) .. GetString( TTG_NRG26_D ) .. GetString( TTG_NRG27_D ) .. GetString( TTG_NRG28_D ) .. GetString( TTG_NRG29_D ) .. GetString( TTG_NRG30_D ) .. GetString( TTG_NRG31_D ) .. GetString( TTG_NRG32_D ) .. GetString( TTG_NRG33_D ) .. GetString( TTG_NRG34_D ) .. GetString( TTG_NRG35_D ) .. GetString( TTG_NRG36_D ) .. GetString( TTG_NRG37_D ) .. GetString( TTG_NRG38_D ) .. GetString( TTG_NRG39_D ) .. GetString( TTG_NRG40_D ) .. GetString( TTG_NRG41_D ) .. GetString( TTG_NRG42_D ) .. GetString( TTG_NRG43_D ) .. GetString( TTG_NRG44_D ) .. GetString( TTG_NRG45_D ) .. GetString( TTG_NRG46_D ) .. GetString( TTG_NRG47_D ))
TTGAddonIndicatorBg:SetWidth(435)
TTGAddonIndicatorContainer:SetWidth(430)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 47 then
	   bglen = ((24 * 46) + 45)
 	   contlen = ((24 * 46) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 47 then
		       	   bglen = ((24 * 46) + 45)
		           contlen = ((24 * 46) + 12)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  	       		   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashnrg(slashnumber)
TTGAddon.savedVariables.Trial = "nrg"
currentTrial = "nrg"
TTGAddon.WindowNRG()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_NRG1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_NRG2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_NRG3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_NRG4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_NRG5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_NRG6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_NRG7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_NRG8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_NRG9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_NRG10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_NRG11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_NRG12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_NRG13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_NRG14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_NRG15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_NRG16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_NRG17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_NRG18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_NRG19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_NRG20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_NRG21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_NRG22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_NRG23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_NRG24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_NRG25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_NRG26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_NRG27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_NRG28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_NRG29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_NRG30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_NRG31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_NRG32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_NRG33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_NRG34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_NRG35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_NRG36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_NRG37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_NRG38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_NRG39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_NRG40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_NRG41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_NRG42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_NRG43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_NRG44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_NRG45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_NRG46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_NRG47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nrg 1" .. green .. GetString( TTG_NRG1_D ) .. orange .. "/nrg 2" .. green .. GetString( TTG_NRG2_D ) .. orange .. "/nrg 3" .. green .. GetString( TTG_NRG3_D ) .. orange .. "/nrg 4" .. green .. GetString( TTG_NRG4_D ) .. orange .. "/nrg 5" .. green .. GetString( TTG_NRG5_D ) .. orange .. "/nrg 6" .. green .. GetString( TTG_NRG6_D ) .. orange .. "/nrg 7" .. green .. GetString( TTG_NRG7_D ) .. orange .. "/nrg 8" .. green .. GetString( TTG_NRG8_D ) .. orange .. "/nrg 9" .. green .. GetString( TTG_NRG9_D ) .. orange .. "/nrg 10" .. green .. GetString( TTG_NRG10_D ) .. orange .. "/nrg 11" .. green .. GetString( TTG_NRG11_D ) .. orange .. "/nrg 12" .. green .. GetString( TTG_NRG12_D ) .. orange .. "/nrg 13" .. green .. GetString( TTG_NRG13_D ) .. orange .. "/nrg 14" .. green .. GetString( TTG_NRG14_D ) .. orange .. "/nrg 15" .. green .. GetString( TTG_NRG15_D ) .. orange .. "/nrg 16" .. green .. GetString( TTG_NRG16_D ) .. orange .. "/nrg 17" .. green .. GetString( TTG_NRG17_D ) .. orange .. "/nrg 18" .. green .. GetString( TTG_NRG18_D ) .. orange .. "/nrg 19" .. green .. GetString( TTG_NRG19_D ) .. orange .. "/nrg 20" .. green .. GetString( TTG_NRG20_D ) .. orange .. "/nrg 21" .. green .. GetString( TTG_NRG21_D ) .. orange .. "/nrg 22" .. green .. GetString( TTG_NRG22_D ) .. orange .. "/nrg 23" .. green .. GetString( TTG_NRG23_D ) .. orange .. "/nrg 24" .. green .. GetString( TTG_NRG24_D ) .. orange .. "/nrg 25" .. green .. GetString( TTG_NRG25_D ) .. orange .. "/nrg 26" .. green .. GetString( TTG_NRG26_D ) .. orange .. "/nrg 27" .. green .. GetString( TTG_NRG27_D ) .. orange .. "/nrg 28" .. green .. GetString( TTG_NRG28_D ) .. orange .. "/nrg 29" .. green .. GetString( TTG_NRG29_D ))
      d(orange .. "/nrg 30" .. green .. GetString( TTG_NRG30_D ) .. orange .. "/nrg 31" .. green .. GetString( TTG_NRG31_D ) .. orange .. "/nrg 32" .. green .. GetString( TTG_NRG32_D ) .. orange .. "/nrg 33" .. green .. GetString( TTG_NRG33_D ) .. orange .. "/nrg 34" .. green .. GetString( TTG_NRG34_D ) .. orange .. "/nrg 35" .. green .. GetString( TTG_NRG35_D ) .. orange .. "/nrg 36" .. green .. GetString( TTG_NRG36_D ) .. orange .. "/nrg 37" .. green .. GetString( TTG_NRG37_D ) .. orange .. "/nrg 38" .. green .. GetString( TTG_NRG38_D ) .. orange .. "/nrg 39" .. green .. GetString( TTG_NRG39_D ) .. orange .. "/nrg 40" .. green .. GetString( TTG_NRG40_D ) .. orange .. "/nrg 41" .. green .. GetString( TTG_NRG41_D ) .. orange .. "/nrg 42" .. green .. GetString( TTG_NRG42_D ) .. orange .. "/nrg 43" .. green .. GetString( TTG_NRG43_D ) .. orange .. "/nrg 44" .. green .. GetString( TTG_NRG44_D ) .. orange .. "/nrg 45" .. green .. GetString( TTG_NRG45_D ) .. orange .. "/nrg 46" .. green .. GetString( TTG_NRG46_D ) .. orange .. "/nrg 47" .. green .. GetString( TTG_NRG47_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_NRG1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_NRG2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_NRG3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_NRG4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_NRG5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_NRG6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_NRG7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_NRG8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_NRG9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_NRG10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_NRG11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_NRG12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_NRG13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_NRG14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_NRG15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_NRG16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_NRG17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_NRG18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_NRG19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_NRG20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_NRG21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_NRG22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_NRG23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_NRG24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_NRG25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_NRG26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_NRG27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_NRG28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_NRG29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_NRG30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_NRG31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_NRG32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_NRG33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_NRG34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_NRG35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_NRG36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_NRG37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_NRG38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_NRG39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_NRG40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_NRG41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_NRG42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_NRG43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_NRG44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_NRG45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_NRG46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_NRG47 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/nrg 1" .. green .. GetString( TTG_NRG1_D ) .. orange .. "/nrg 2" .. green .. GetString( TTG_NRG2_D ) .. orange .. "/nrg 3" .. green .. GetString( TTG_NRG3_D ) .. orange .. "/nrg 4" .. green .. GetString( TTG_NRG4_D ) .. orange .. "/nrg 5" .. green .. GetString( TTG_NRG5_D ) .. orange .. "/nrg 6" .. green .. GetString( TTG_NRG6_D ) .. orange .. "/nrg 7" .. green .. GetString( TTG_NRG7_D ) .. orange .. "/nrg 8" .. green .. GetString( TTG_NRG8_D ) .. orange .. "/nrg 9" .. green .. GetString( TTG_NRG9_D ) .. orange .. "/nrg 10" .. green .. GetString( TTG_NRG10_D ) .. orange .. "/nrg 11" .. green .. GetString( TTG_NRG11_D ) .. orange .. "/nrg 12" .. green .. GetString( TTG_NRG12_D ) .. orange .. "/nrg 13" .. green .. GetString( TTG_NRG13_D ) .. orange .. "/nrg 14" .. green .. GetString( TTG_NRG14_D ) .. orange .. "/nrg 15" .. green .. GetString( TTG_NRG15_D ) .. orange .. "/nrg 16" .. green .. GetString( TTG_NRG16_D ) .. orange .. "/nrg 17" .. green .. GetString( TTG_NRG17_D ) .. orange .. "/nrg 18" .. green .. GetString( TTG_NRG18_D ) .. orange .. "/nrg 19" .. green .. GetString( TTG_NRG19_D ) .. orange .. "/nrg 20" .. green .. GetString( TTG_NRG20_D ) .. orange .. "/nrg 21" .. green .. GetString( TTG_NRG21_D ) .. orange .. "/nrg 22" .. green .. GetString( TTG_NRG22_D ) .. orange .. "/nrg 23" .. green .. GetString( TTG_NRG23_D ) .. orange .. "/nrg 24" .. green .. GetString( TTG_NRG24_D ) .. orange .. "/nrg 25" .. green .. GetString( TTG_NRG25_D ) .. orange .. "/nrg 26" .. green .. GetString( TTG_NRG26_D ) .. orange .. "/nrg 27" .. green .. GetString( TTG_NRG27_D ) .. orange .. "/nrg 28" .. green .. GetString( TTG_NRG28_D ) .. orange .. "/nrg 29" .. green .. GetString( TTG_NRG29_D ))
      d(orange .. "/nrg 30" .. green .. GetString( TTG_NRG30_D ) .. orange .. "/nrg 31" .. green .. GetString( TTG_NRG31_D ) .. orange .. "/nrg 32" .. green .. GetString( TTG_NRG32_D ) .. orange .. "/nrg 33" .. green .. GetString( TTG_NRG33_D ) .. orange .. "/nrg 34" .. green .. GetString( TTG_NRG34_D ) .. orange .. "/nrg 35" .. green .. GetString( TTG_NRG35_D ) .. orange .. "/nrg 36" .. green .. GetString( TTG_NRG36_D ) .. orange .. "/nrg 37" .. green .. GetString( TTG_NRG37_D ) .. orange .. "/nrg 38" .. green .. GetString( TTG_NRG38_D ) .. orange .. "/nrg 39" .. green .. GetString( TTG_NRG39_D ) .. orange .. "/nrg 40" .. green .. GetString( TTG_NRG40_D ) .. orange .. "/nrg 41" .. green .. GetString( TTG_NRG41_D ) .. orange .. "/nrg 42" .. green .. GetString( TTG_NRG42_D ) .. orange .. "/nrg 43" .. green .. GetString( TTG_NRG43_D ) .. orange .. "/nrg 44" .. green .. GetString( TTG_NRG44_D ) .. orange .. "/nrg 45" .. green .. GetString( TTG_NRG45_D ) .. orange .. "/nrg 46" .. green .. GetString( TTG_NRG46_D ) .. orange .. "/nrg 47" .. green .. GetString( TTG_NRG47_D ))
	end
    end
  end
end

-- ROCKGROVE VETERAN

function TTGAddon.WindowVRG()
TTGAddonIndicatorData:SetText("/vrg 1\n/vrg 2\n/vrg 3\n/vrg 4\n/vrg 5\n/vrg 6\n/vrg 7\n/vrg 8\n/vrg 9\n/vrg 10\n/vrg 11\n/vrg 12\n/vrg 13\n/vrg 14\n/vrg 15\n/vrg 16\n/vrg 17\n/vrg 18\n/vrg 19\n/vrg 20\n/vrg 21\n/vrg 22\n/vrg 23\n/vrg 24\n/vrg 25\n/vrg 26\n/vrg 27\n/vrg 28\n/vrg 29\n/vrg 30\n/vrg 31\n/vrg 32\n/vrg 33\n/vrg 34\n/vrg 35\n/vrg 36\n/vrg 37\n/vrg 38\n/vrg 39\n/vrg 40\n/vrg 41\n/vrg 42\n/vrg 43\n/vrg 44\n/vrg 45\n/vrg 46\n/vrg 47\n/vrg 48\n/vrg 49\n/vrg 50\n/vrg 51\n/vrg 52\n/vrg 53\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VRG1_D ) .. GetString( TTG_VRG2_D ) .. GetString( TTG_VRG3_D ) .. GetString( TTG_VRG4_D ) .. GetString( TTG_VRG5_D ) .. GetString( TTG_VRG6_D ) .. GetString( TTG_VRG7_D ) .. GetString( TTG_VRG8_D ) .. GetString( TTG_VRG9_D ) .. GetString( TTG_VRG10_D ) .. GetString( TTG_VRG11_D ) .. GetString( TTG_VRG12_D ) .. GetString( TTG_VRG13_D ) .. GetString( TTG_VRG14_D ) .. GetString( TTG_VRG15_D ) .. GetString( TTG_VRG16_D ) .. GetString( TTG_VRG17_D ) .. GetString( TTG_VRG18_D ) .. GetString( TTG_VRG19_D ) .. GetString( TTG_VRG20_D ) .. GetString( TTG_VRG21_D ) .. GetString( TTG_VRG22_D ) .. GetString( TTG_VRG23_D ) .. GetString( TTG_VRG24_D ) .. GetString( TTG_VRG25_D ) .. GetString( TTG_VRG26_D ) .. GetString( TTG_VRG27_D ) .. GetString( TTG_VRG28_D ) .. GetString( TTG_VRG29_D ) .. GetString( TTG_VRG30_D ) .. GetString( TTG_VRG31_D ) .. GetString( TTG_VRG32_D ) .. GetString( TTG_VRG33_D ) .. GetString( TTG_VRG34_D ) .. GetString( TTG_VRG35_D ) .. GetString( TTG_VRG36_D ) .. GetString( TTG_VRG37_D ) .. GetString( TTG_VRG38_D ) .. GetString( TTG_VRG39_D ) .. GetString( TTG_VRG40_D ) .. GetString( TTG_VRG41_D ) .. GetString( TTG_VRG42_D ) .. GetString( TTG_VRG43_D ) .. GetString( TTG_VRG44_D ) .. GetString( TTG_VRG45_D ) .. GetString( TTG_VRG46_D ) .. GetString( TTG_VRG47_D ) .. GetString( TTG_VRG48_D ) .. GetString( TTG_VRG49_D ) .. GetString( TTG_VRG50_D ) .. GetString( TTG_VRG51_D ) .. GetString( TTG_VRG52_D ) .. GetString( TTG_VRG53_D ))
TTGAddonIndicatorBg:SetWidth(435)
TTGAddonIndicatorContainer:SetWidth(430)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 53 then
	   bglen = ((24 * 52) + 45)
 	   contlen = ((24 * 52) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 53 then
		       	   bglen = ((24 * 52) + 45)
		           contlen = ((24 * 52) + 12)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
	   		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
  	       		   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
        		   TTGAddonIndicatorBg:SetHeight(bglen)
   			   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 17)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvrg(slashnumber)
TTGAddon.savedVariables.Trial = "vrg"
currentTrial = "vrg"
TTGAddon.WindowVRG()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VRG1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VRG2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VRG3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VRG4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VRG5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VRG6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VRG7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VRG8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VRG9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VRG10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VRG11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VRG12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VRG13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VRG14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VRG15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VRG16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VRG17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VRG18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VRG19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VRG20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VRG21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VRG22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VRG23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "24" then
      text = wheretoplace .. " " .. GetString( TTG_VRG24 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "25" then
      text = wheretoplace .. " " .. GetString( TTG_VRG25 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "26" then
      text = wheretoplace .. " " .. GetString( TTG_VRG26 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "27" then
      text = wheretoplace .. " " .. GetString( TTG_VRG27 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "28" then
      text = wheretoplace .. " " .. GetString( TTG_VRG28 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "29" then
      text = wheretoplace .. " " .. GetString( TTG_VRG29 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "30" then
      text = wheretoplace .. " " .. GetString( TTG_VRG30 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "31" then
      text = wheretoplace .. " " .. GetString( TTG_VRG31 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "32" then
      text = wheretoplace .. " " .. GetString( TTG_VRG32 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "33" then
      text = wheretoplace .. " " .. GetString( TTG_VRG33 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "34" then
      text = wheretoplace .. " " .. GetString( TTG_VRG34 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "35" then
      text = wheretoplace .. " " .. GetString( TTG_VRG35 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "36" then
      text = wheretoplace .. " " .. GetString( TTG_VRG36 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "37" then
      text = wheretoplace .. " " .. GetString( TTG_VRG37 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "38" then
      text = wheretoplace .. " " .. GetString( TTG_VRG38 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "39" then
      text = wheretoplace .. " " .. GetString( TTG_VRG39 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "40" then
      text = wheretoplace .. " " .. GetString( TTG_VRG40 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "41" then
      text = wheretoplace .. " " .. GetString( TTG_VRG41 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "42" then
      text = wheretoplace .. " " .. GetString( TTG_VRG42 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "43" then
      text = wheretoplace .. " " .. GetString( TTG_VRG43 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "44" then
      text = wheretoplace .. " " .. GetString( TTG_VRG44 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "45" then
      text = wheretoplace .. " " .. GetString( TTG_VRG45 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "46" then
      text = wheretoplace .. " " .. GetString( TTG_VRG46 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "47" then
      text = wheretoplace .. " " .. GetString( TTG_VRG47 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "48" then
      text = wheretoplace .. " " .. GetString( TTG_VRG48 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "49" then
      text = wheretoplace .. " " .. GetString( TTG_VRG49 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "50" then
      text = wheretoplace .. " " .. GetString( TTG_VRG50 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "51" then
      text = wheretoplace .. " " .. GetString( TTG_VRG51 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "52" then
      text = wheretoplace .. " " .. GetString( TTG_VRG52 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "53" then
      text = wheretoplace .. " " .. GetString( TTG_VRG53 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vrg 1" .. green .. GetString( TTG_VRG1_D ) .. orange .. "/vrg 2" .. green .. GetString( TTG_VRG2_D ) .. orange .. "/vrg 3" .. green .. GetString( TTG_VRG3_D ) .. orange .. "/vrg 4" .. green .. GetString( TTG_VRG4_D ) .. orange .. "/vrg 5" .. green .. GetString( TTG_VRG5_D ) .. orange .. "/vrg 6" .. green .. GetString( TTG_VRG6_D ) .. orange .. "/vrg 7" .. green .. GetString( TTG_VRG7_D ) .. orange .. "/vrg 8" .. green .. GetString( TTG_VRG8_D ) .. orange .. "/vrg 9" .. green .. GetString( TTG_VRG9_D ) .. orange .. "/vrg 10" .. green .. GetString( TTG_VRG10_D ) .. orange .. "/vrg 11" .. green .. GetString( TTG_VRG11_D ) .. orange .. "/vrg 12" .. green .. GetString( TTG_VRG12_D ) .. orange .. "/vrg 13" .. green .. GetString( TTG_VRG13_D ) .. orange .. "/vrg 14" .. green .. GetString( TTG_VRG14_D ) .. orange .. "/vrg 15" .. green .. GetString( TTG_VRG15_D ) .. orange .. "/vrg 16" .. green .. GetString( TTG_VRG16_D ) .. orange .. "/vrg 17" .. green .. GetString( TTG_VRG17_D ) .. orange .. "/vrg 18" .. green .. GetString( TTG_VRG18_D ) .. orange .. "/vrg 19" .. green .. GetString( TTG_VRG19_D ) .. orange .. "/vrg 20" .. green .. GetString( TTG_VRG20_D ) .. orange .. "/vrg 21" .. green .. GetString( TTG_VRG21_D ) .. orange .. "/vrg 22" .. green .. GetString( TTG_VRG22_D ) .. orange .. "/vrg 23" .. green .. GetString( TTG_VRG23_D ) .. orange .. "/vrg 24" .. green .. GetString( TTG_VRG24_D ) .. orange .. "/vrg 25" .. green .. GetString( TTG_VRG25_D ) .. orange .. "/vrg 26" .. green .. GetString( TTG_VRG26_D ) .. orange .. "/vrg 27" .. green .. GetString( TTG_VRG27_D ) .. orange .. "/vrg 28" .. green .. GetString( TTG_VRG28_D ) .. orange .. "/vrg 29" .. green .. GetString( TTG_VRG29_D ))
      d(orange .. "/vrg 30" .. green .. GetString( TTG_VRG30_D ) .. orange .. "/vrg 31" .. green .. GetString( TTG_VRG31_D ) .. orange .. "/vrg 32" .. green .. GetString( TTG_VRG32_D ) .. orange .. "/vrg 33" .. green .. GetString( TTG_VRG33_D ) .. orange .. "/vrg 34" .. green .. GetString( TTG_VRG34_D ) .. orange .. "/vrg 35" .. green .. GetString( TTG_VRG35_D ) .. orange .. "/vrg 36" .. green .. GetString( TTG_VRG36_D ) .. orange .. "/vrg 37" .. green .. GetString( TTG_VRG37_D ) .. orange .. "/vrg 38" .. green .. GetString( TTG_VRG38_D ) .. orange .. "/vrg 39" .. green .. GetString( TTG_VRG39_D ) .. orange .. "/vrg 40" .. green .. GetString( TTG_VRG40_D ) .. orange .. "/vrg 41" .. green .. GetString( TTG_VRG41_D ) .. orange .. "/vrg 42" .. green .. GetString( TTG_VRG42_D ) .. orange .. "/vrg 43" .. green .. GetString( TTG_VRG43_D ) .. orange .. "/vrg 44" .. green .. GetString( TTG_VRG44_D ) .. orange .. "/vrg 45" .. green .. GetString( TTG_VRG45_D ) .. orange .. "/vrg 46" .. green .. GetString( TTG_VRG46_D ) .. orange .. "/vrg 47" .. green .. GetString( TTG_VRG47_D ) .. orange .. "/vrg 48" .. green .. GetString( TTG_VRG48_D ) .. orange .. "/vrg 49" .. green .. GetString( TTG_VRG49_D ) .. orange .. "/vrg 50" .. green .. GetString( TTG_VRG50_D ) .. orange .. "/vrg 51" .. green .. GetString( TTG_VRG51_D ) .. orange .. "/vrg 52" .. green .. GetString( TTG_VRG52_D ) .. orange .. "/vrg 53" .. green .. GetString( TTG_VRG53_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VRG1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VRG2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VRG3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VRG4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VRG5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VRG6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VRG7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VRG8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VRG9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VRG10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VRG11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VRG12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VRG13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VRG14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VRG15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VRG16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VRG17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VRG18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VRG19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VRG20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VRG21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VRG22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VRG23 ))
    elseif slashnumber == "24" then
      d(colourtouse .. GetString( TTG_VRG24 ))
    elseif slashnumber == "25" then
      d(colourtouse .. GetString( TTG_VRG25 ))
    elseif slashnumber == "26" then
      d(colourtouse .. GetString( TTG_VRG26 ))
    elseif slashnumber == "27" then
      d(colourtouse .. GetString( TTG_VRG27 ))
    elseif slashnumber == "28" then
      d(colourtouse .. GetString( TTG_VRG28 ))
    elseif slashnumber == "29" then
      d(colourtouse .. GetString( TTG_VRG29 ))
    elseif slashnumber == "30" then
      d(colourtouse .. GetString( TTG_VRG30 ))
    elseif slashnumber == "31" then
      d(colourtouse .. GetString( TTG_VRG31 ))
    elseif slashnumber == "32" then
      d(colourtouse .. GetString( TTG_VRG32 ))
    elseif slashnumber == "33" then
      d(colourtouse .. GetString( TTG_VRG33 ))
    elseif slashnumber == "34" then
      d(colourtouse .. GetString( TTG_VRG34 ))
    elseif slashnumber == "35" then
      d(colourtouse .. GetString( TTG_VRG35 ))
    elseif slashnumber == "36" then
      d(colourtouse .. GetString( TTG_VRG36 ))
    elseif slashnumber == "37" then
      d(colourtouse .. GetString( TTG_VRG37 ))
    elseif slashnumber == "38" then
      d(colourtouse .. GetString( TTG_VRG38 ))
    elseif slashnumber == "39" then
      d(colourtouse .. GetString( TTG_VRG39 ))
    elseif slashnumber == "40" then
      d(colourtouse .. GetString( TTG_VRG40 ))
    elseif slashnumber == "41" then
      d(colourtouse .. GetString( TTG_VRG41 ))
    elseif slashnumber == "42" then
      d(colourtouse .. GetString( TTG_VRG42 ))
    elseif slashnumber == "43" then
      d(colourtouse .. GetString( TTG_VRG43 ))
    elseif slashnumber == "44" then
      d(colourtouse .. GetString( TTG_VRG44 ))
    elseif slashnumber == "45" then
      d(colourtouse .. GetString( TTG_VRG45 ))
    elseif slashnumber == "46" then
      d(colourtouse .. GetString( TTG_VRG46 ))
    elseif slashnumber == "47" then
      d(colourtouse .. GetString( TTG_VRG47 ))
    elseif slashnumber == "48" then
      d(colourtouse .. GetString( TTG_VRG48 ))
    elseif slashnumber == "49" then
      d(colourtouse .. GetString( TTG_VRG49 ))
    elseif slashnumber == "50" then
      d(colourtouse .. GetString( TTG_VRG50 ))
    elseif slashnumber == "51" then
      d(colourtouse .. GetString( TTG_VRG51 ))
    elseif slashnumber == "52" then
      d(colourtouse .. GetString( TTG_VRG52 ))
    elseif slashnumber == "53" then
      d(colourtouse .. GetString( TTG_VRG53 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vrg 1" .. green .. GetString( TTG_VRG1_D ) .. orange .. "/vrg 2" .. green .. GetString( TTG_VRG2_D ) .. orange .. "/vrg 3" .. green .. GetString( TTG_VRG3_D ) .. orange .. "/vrg 4" .. green .. GetString( TTG_VRG4_D ) .. orange .. "/vrg 5" .. green .. GetString( TTG_VRG5_D ) .. orange .. "/vrg 6" .. green .. GetString( TTG_VRG6_D ) .. orange .. "/vrg 7" .. green .. GetString( TTG_VRG7_D ) .. orange .. "/vrg 8" .. green .. GetString( TTG_VRG8_D ) .. orange .. "/vrg 9" .. green .. GetString( TTG_VRG9_D ) .. orange .. "/vrg 10" .. green .. GetString( TTG_VRG10_D ) .. orange .. "/vrg 11" .. green .. GetString( TTG_VRG11_D ) .. orange .. "/vrg 12" .. green .. GetString( TTG_VRG12_D ) .. orange .. "/vrg 13" .. green .. GetString( TTG_VRG13_D ) .. orange .. "/vrg 14" .. green .. GetString( TTG_VRG14_D ) .. orange .. "/vrg 15" .. green .. GetString( TTG_VRG15_D ) .. orange .. "/vrg 16" .. green .. GetString( TTG_VRG16_D ) .. orange .. "/vrg 17" .. green .. GetString( TTG_VRG17_D ) .. orange .. "/vrg 18" .. green .. GetString( TTG_VRG18_D ) .. orange .. "/vrg 19" .. green .. GetString( TTG_VRG19_D ) .. orange .. "/vrg 20" .. green .. GetString( TTG_VRG20_D ) .. orange .. "/vrg 21" .. green .. GetString( TTG_VRG21_D ) .. orange .. "/vrg 22" .. green .. GetString( TTG_VRG22_D ) .. orange .. "/vrg 23" .. green .. GetString( TTG_VRG23_D ) .. orange .. "/vrg 24" .. green .. GetString( TTG_VRG24_D ) .. orange .. "/vrg 25" .. green .. GetString( TTG_VRG25_D ) .. orange .. "/vrg 26" .. green .. GetString( TTG_VRG26_D ) .. orange .. "/vrg 27" .. green .. GetString( TTG_VRG27_D ) .. orange .. "/vrg 28" .. green .. GetString( TTG_VRG28_D ) .. orange .. "/vrg 29" .. green .. GetString( TTG_VRG29_D ))
      d(orange .. "/vrg 30" .. green .. GetString( TTG_VRG30_D ) .. orange .. "/vrg 31" .. green .. GetString( TTG_VRG31_D ) .. orange .. "/vrg 32" .. green .. GetString( TTG_VRG32_D ) .. orange .. "/vrg 33" .. green .. GetString( TTG_VRG33_D ) .. orange .. "/vrg 34" .. green .. GetString( TTG_VRG34_D ) .. orange .. "/vrg 35" .. green .. GetString( TTG_VRG35_D ) .. orange .. "/vrg 36" .. green .. GetString( TTG_VRG36_D ) .. orange .. "/vrg 37" .. green .. GetString( TTG_VRG37_D ) .. orange .. "/vrg 38" .. green .. GetString( TTG_VRG38_D ) .. orange .. "/vrg 39" .. green .. GetString( TTG_VRG39_D ) .. orange .. "/vrg 40" .. green .. GetString( TTG_VRG40_D ) .. orange .. "/vrg 41" .. green .. GetString( TTG_VRG41_D ) .. orange .. "/vrg 42" .. green .. GetString( TTG_VRG42_D ) .. orange .. "/vrg 43" .. green .. GetString( TTG_VRG43_D ) .. orange .. "/vrg 44" .. green .. GetString( TTG_VRG44_D ) .. orange .. "/vrg 45" .. green .. GetString( TTG_VRG45_D ) .. orange .. "/vrg 46" .. green .. GetString( TTG_VRG46_D ) .. orange .. "/vrg 47" .. green .. GetString( TTG_VRG47_D ) .. orange .. "/vrg 48" .. green .. GetString( TTG_VRG48_D ) .. orange .. "/vrg 49" .. green .. GetString( TTG_VRG49_D ) .. orange .. "/vrg 50" .. green .. GetString( TTG_VRG50_D ) .. orange .. "/vrg 51" .. green .. GetString( TTG_VRG51_D ) .. orange .. "/vrg 52" .. green .. GetString( TTG_VRG52_D ) .. orange .. "/vrg 53" .. green .. GetString( TTG_VRG53_D ))
	end
    end
  end
end



-- DRAGONSTAR ARENA VETERAN

function TTGAddon.WindowVDSA()
TTGAddonIndicatorData:SetText("/vdsa 1\n/vdsa 2\n/vdsa 3\n/vdsa 4\n/vdsa 5\n/vdsa 6\n/vdsa 7\n/vdsa 8\n/vdsa 9\n/vdsa 10\n/vdsa 11\n/vdsa 12\n/vdsa 13\n/vdsa 14\n/vdsa 15\n/vdsa 16\n/vdsa 17\n/vdsa 18\n/vdsa 19\n/vdsa 20\n/vdsa 21\n/vdsa 22\n/vdsa 23\n")
TTGAddonIndicatorData2:SetText(GetString( TTG_VDSA1_D ) .. GetString( TTG_VDSA2_D ) .. GetString( TTG_VDSA3_D ) .. GetString( TTG_VDSA4_D ) .. GetString( TTG_VDSA5_D ) .. GetString( TTG_VDSA6_D ) .. GetString( TTG_VDSA7_D ) .. GetString( TTG_VDSA8_D ) .. GetString( TTG_VDSA9_D ) .. GetString( TTG_VDSA10_D ) .. GetString( TTG_VDSA11_D ) .. GetString( TTG_VDSA12_D ) .. GetString( TTG_VDSA13_D ) .. GetString( TTG_VDSA14_D ) .. GetString( TTG_VDSA15_D ) .. GetString( TTG_VDSA16_D ) .. GetString( TTG_VDSA17_D ) .. GetString( TTG_VDSA18_D ) .. GetString( TTG_VDSA19_D ) .. GetString( TTG_VDSA20_D ) .. GetString( TTG_VDSA21_D ) .. GetString( TTG_VDSA22_D ) .. GetString( TTG_VDSA23_D ))
TTGAddonIndicatorBg:SetWidth(400)
TTGAddonIndicatorContainer:SetWidth(395)
  if currentcommandlength ~= "notusedyet" then
	if currentcommandlength > 23 then
	   bglen = ((24 * 23) + 45)
 	   contlen = ((24 * 23) + 12)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	else
	   bglen = ((24 * currentcommandlength) + 50)
 	   contlen = ((24 * currentcommandlength) + 17)
 	   TTGAddonIndicatorBg:SetHeight(bglen)
 	   TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  else
	if currentcommandlength == "notusedyet" then
		if TTGAddon.savedVariables.CommandLength ~= 5 then
			if TTGAddon.savedVariables.CommandLength > 23 then
		       	   bglen = ((24 * 23) + 45)
		           contlen = ((24 * 23) + 12)
		       	   TTGAddonIndicatorBg:SetHeight(bglen)
 	  		   TTGAddonIndicatorContainer:SetHeight(contlen)
			else
 		       	   bglen = ((24 * TTGAddon.savedVariables.CommandLength) + 50)
		           contlen = ((24 * TTGAddon.savedVariables.CommandLength) + 17)
 		       	   TTGAddonIndicatorBg:SetHeight(bglen)
  	 		   TTGAddonIndicatorContainer:SetHeight(contlen)
			end
		end	
	else
	   bglen = ((24 * 5) + 50)
           contlen = ((24 * 5) + 16)
           TTGAddonIndicatorBg:SetHeight(bglen)
           TTGAddonIndicatorContainer:SetHeight(contlen)
	end
  end
end

function TTGAddon.Slashvdsa(slashnumber)
TTGAddon.savedVariables.Trial = "vdsa"
currentTrial = "vdsa"
TTGAddon.WindowVDSA()
  if currentplace ~= "notusedyet" then
     wheretoplace = currentplace
     end
  if currentcolour ~= "notusedyet" then
     colourtouse = currentcolour
     end
  if currentCMDChat ~= "notusedyet" then
     displayCmdInChat = currentCMDChat
     end
  if wheretoplace ~= "Personal Chat" then
    if slashnumber == "1" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA1 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "2" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA2 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "3" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA3 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "4" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA4 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "5" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA5 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "6" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA6 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "7" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA7 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "8" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA8 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "9" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA9 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "10" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA10 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "11" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA11 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "12" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA12 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "13" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA13 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "14" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA14 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "15" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA15 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "16" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA16 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "17" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA17 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "18" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA18 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "19" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA19 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "20" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA20 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "21" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA21 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "22" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA22 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    elseif slashnumber == "23" then
      text = wheretoplace .. " " .. GetString( TTG_VDSA23 )
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vdsa 1" .. green .. GetString( TTG_VDSA1_D ) .. orange .. "/vdsa 2" .. green .. GetString( TTG_VDSA2_D ) .. orange .. "/vdsa 3" .. green .. GetString( TTG_VDSA3_D ) .. orange .. "/vdsa 4" .. green .. GetString( TTG_VDSA4_D ) .. orange .. "/vdsa 5" .. green .. GetString( TTG_VDSA5_D ) .. orange .. "/vdsa 6" .. green .. GetString( TTG_VDSA6_D ) .. orange .. "/vdsa 7" .. green .. GetString( TTG_VDSA7_D ) .. orange .. "/vdsa 8" .. green .. GetString( TTG_VDSA8_D ) .. orange .. "/vdsa 9" .. green .. GetString( TTG_VDSA9_D ) .. orange .. "/vdsa 10" .. green .. GetString( TTG_VDSA10_D ) .. orange .. "/vdsa 11" .. green .. GetString( TTG_VDSA11_D ) .. orange .. "/vdsa 12" .. green .. GetString( TTG_VDSA12_D ) .. orange .. "/vdsa 13" .. green .. GetString( TTG_VDSA13_D ) .. orange .. "/vdsa 14" .. green .. GetString( TTG_VDSA14_D ) .. orange .. "/vdsa 15" .. green .. GetString( TTG_VDSA15_D ) .. orange .. "/vdsa 16" .. green .. GetString( TTG_VDSA16_D ) .. orange .. "/vdsa 17" .. green .. GetString( TTG_VDSA17_D ) .. orange .. "/vdsa 18" .. green .. GetString( TTG_VDSA18_D ) .. orange .. "/vdsa 19" .. green .. GetString( TTG_VDSA19_D ) .. orange .. "/vdsa 20" .. green .. GetString( TTG_VDSA20_D ) .. orange .. "/vdsa 21" .. green .. GetString( TTG_VDSA21_D ) .. orange .. "/vdsa 22" .. green .. GetString( TTG_VDSA22_D ) .. orange .. "/vdsa 23" .. green .. GetString( TTG_VDSA23_D ))
	end
    end
  else
    if slashnumber == "1" then
      d(colourtouse .. GetString( TTG_VDSA1 ))
    elseif slashnumber == "2" then
      d(colourtouse .. GetString( TTG_VDSA2 ))
    elseif slashnumber == "3" then
      d(colourtouse .. GetString( TTG_VDSA3 ))
    elseif slashnumber == "4" then
      d(colourtouse .. GetString( TTG_VDSA4 ))
    elseif slashnumber == "5" then
      d(colourtouse .. GetString( TTG_VDSA5 ))
    elseif slashnumber == "6" then
      d(colourtouse .. GetString( TTG_VDSA6 ))
    elseif slashnumber == "7" then
      d(colourtouse .. GetString( TTG_VDSA7 ))
    elseif slashnumber == "8" then
      d(colourtouse .. GetString( TTG_VDSA8 ))
    elseif slashnumber == "9" then
      d(colourtouse .. GetString( TTG_VDSA9 ))
    elseif slashnumber == "10" then
      d(colourtouse .. GetString( TTG_VDSA10 ))
    elseif slashnumber == "11" then
      d(colourtouse .. GetString( TTG_VDSA11 ))
    elseif slashnumber == "12" then
      d(colourtouse .. GetString( TTG_VDSA12 ))
    elseif slashnumber == "13" then
      d(colourtouse .. GetString( TTG_VDSA13 ))
    elseif slashnumber == "14" then
      d(colourtouse .. GetString( TTG_VDSA14 ))
    elseif slashnumber == "15" then
      d(colourtouse .. GetString( TTG_VDSA15 ))
    elseif slashnumber == "16" then
      d(colourtouse .. GetString( TTG_VDSA16 ))
    elseif slashnumber == "17" then
      d(colourtouse .. GetString( TTG_VDSA17 ))
    elseif slashnumber == "18" then
      d(colourtouse .. GetString( TTG_VDSA18 ))
    elseif slashnumber == "19" then
      d(colourtouse .. GetString( TTG_VDSA19 ))
    elseif slashnumber == "20" then
      d(colourtouse .. GetString( TTG_VDSA20 ))
    elseif slashnumber == "21" then
      d(colourtouse .. GetString( TTG_VDSA21 ))
    elseif slashnumber == "22" then
      d(colourtouse .. GetString( TTG_VDSA22 ))
    elseif slashnumber == "23" then
      d(colourtouse .. GetString( TTG_VDSA23 ))
    else
	if displayCmdInChat == true then
      d(white .. GetString( TTG_AC ) .. orange .. "/vdsa 1" .. green .. GetString( TTG_VDSA1_D ) .. orange .. "/vdsa 2" .. green .. GetString( TTG_VDSA2_D ) .. orange .. "/vdsa 3" .. green .. GetString( TTG_VDSA3_D ) .. orange .. "/vdsa 4" .. green .. GetString( TTG_VDSA4_D ) .. orange .. "/vdsa 5" .. green .. GetString( TTG_VDSA5_D ) .. orange .. "/vdsa 6" .. green .. GetString( TTG_VDSA6_D ) .. orange .. "/vdsa 7" .. green .. GetString( TTG_VDSA7_D ) .. orange .. "/vdsa 8" .. green .. GetString( TTG_VDSA8_D ) .. orange .. "/vdsa 9" .. green .. GetString( TTG_VDSA9_D ) .. orange .. "/vdsa 10" .. green .. GetString( TTG_VDSA10_D ) .. orange .. "/vdsa 11" .. green .. GetString( TTG_VDSA11_D ) .. orange .. "/vdsa 12" .. green .. GetString( TTG_VDSA12_D ) .. orange .. "/vdsa 13" .. green .. GetString( TTG_VDSA13_D ) .. orange .. "/vdsa 14" .. green .. GetString( TTG_VDSA14_D ) .. orange .. "/vdsa 15" .. green .. GetString( TTG_VDSA15_D ) .. orange .. "/vdsa 16" .. green .. GetString( TTG_VDSA16_D ) .. orange .. "/vdsa 17" .. green .. GetString( TTG_VDSA17_D ) .. orange .. "/vdsa 18" .. green .. GetString( TTG_VDSA18_D ) .. orange .. "/vdsa 19" .. green .. GetString( TTG_VDSA19_D ) .. orange .. "/vdsa 20" .. green .. GetString( TTG_VDSA20_D ) .. orange .. "/vdsa 21" .. green .. GetString( TTG_VDSA21_D ) .. orange .. "/vdsa 22" .. green .. GetString( TTG_VDSA22_D ) .. orange .. "/vdsa 23" .. green .. GetString( TTG_VDSA23_D ))
	end
    end
  end
end

function TTGAddon.OnAddOnLoaded(event, addonName)
  if addonName == TTGAddon.name then
    TTGAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(TTGAddon.name, EVENT_ADD_ON_LOADED, TTGAddon.OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_TEXT_TRIALS_GUIDE_TOGGLE_WINDOW", "Toggle Window")
ZO_CreateStringId("SI_BINDING_NAME_TEXT_TRIALS_GUIDE_SETTINGS_MENU", "Settings Menu")