Cashier = {}

Cashier.name = "Cashier"
local yellowColor = ZO_ColorDef:New("EFFF00")
local redColor = ZO_ColorDef:New("f9050c")
local greenColor = ZO_ColorDef:New("00f012")
local libScroll = LibStub:GetLibrary("LibScroll")

local function Print(message, ...)
  
    if message == nil then message = redColor:Colorize("Error: ") .. "message was nil" end
    df("[%s]: %s", greenColor:Colorize(Cashier.name), message:format(...))

end

local loadMessage = "Cashier Loaded.."
Cashier.currentGold = GetCurrencyAmount(1,0)
Cashier.currentBankGold = GetCurrencyAmount(1,1)
Cashier.numberOfCharacters = 0
Cashier.variableVersion = 2
Cashier.characterName = GetUnitName("player")
Cashier.accountName = GetUnitDisplayName("player")
Cashier.windowSize = 30
Cashier.isHiddenWindow = false
Cashier.isHiddenWindowLedger = false;
local isMouseOver = false
local ledgerSizeX = 800
local ledgerSizeY = 700
Cashier.printOut = ""
Cashier.printOut2 = ""
Cashier.printOut3 = ""
Cashier.date = ""
Cashier.time = ""
Cashier.symbol = ""
Cashier.moneyDifference = 0
local bankDisplay = {}
local isPlayerOnly = false
local windowLength = 0
local _windowTable = nil
local isError = false
local _legerWindow = nil
local ledgerInput = ""

Cashier.LedgerDefault = {Display = {"No Entries Found"}, ledgerX = 800, ledgerY = 700,balance = 0,count = 0}

Cashier.Default = { name = Cashier.characterName,
                    gold = Cashier.currentGold, 
                    OffsetX = 300, 
                    OffsetY = 300,
                    version = 2 ,
                    hidden = false,
                    ledgerHidden = false,
                    ledgerOffsetX = 300,
                    ledgerOffsetY = 300,
                    isPlayerOnly = false}
                  


function Cashier:Initialize()
  
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE, self.MoneyChanged)
  
  _windowTable = CashierWindow
  _legerWindow = LedgerWindow
  
  Cashier.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CashierSavedVariables", Cashier.variableVersion, nil, Cashier.Default)  
  Cashier.savedVariablesLedger = ZO_SavedVars:NewAccountWide("LedgerSavedVariables", Cashier.variableVersion, nil, Cashier.LedgerDefault)--
  zeroBank() -- fill table empty
  checkBalance() -- checking balance
  isPlayerOnly = Cashier.savedVariables.isPlayerOnly

  ledgerSizeX = Cashier.savedVariablesLedger.ledgerX
  ledgerSizeY = Cashier.savedVariablesLedger.ledgerY

  Cashier.LoadOfflineBank()
  Cashier.setText() -- set correct Text for Label
  Cashier.LoadOfflineData()
  Cashier.ControlSettings()
 
  local scrollList = CreateScrollList()
  Cashier.scrollList:Update(Cashier.dataItems)
  
  if isError then
    documentError()
    Cashier.SaveLoc()
    Cashier.LoadOfflineBank()
    isError = false
  end
  
  EVENT_MANAGER:UnregisterForEvent(Cashier.name, EVENT_ADD_ON_LOADED)
end
 
 function zeroBank()   
   for i = 1, 50 do
     bankDisplay[i] = ""   
   end
   --Print("zeroBank done")
 end
 
 function documentError()   
  Cashier.GetTheDate()
  
  local banked = GetCurrencyAmount(1,1)
  
  if banked > Cashier.savedVariablesLedger.balance then
      Cashier.symbol = " Deposited "
      Cashier.moneyDifference = banked - Cashier.savedVariablesLedger.balance
      Cashier.moneyDifference = greenColor:Colorize(Cashier.moneyDifference)
    else
      Cashier.symbol = " Withdrew "
      Cashier.moneyDifference =  Cashier.savedVariablesLedger.balance - banked
      Cashier.moneyDifference = redColor:Colorize(Cashier.moneyDifference)
    end -- end if banked > Cashier.currentBankGold then

  local s = yellowColor:Colorize(Cashier.currentBankGold)
  local t = ""
  ledgerInput = "" --  Cashier.savedVariablesLedger.Display
  t = "|cf9050cBANK ERROR:|r balance corrected by " .. Cashier.moneyDifference .." on " .. tostring(Cashier.date) .. " @ " .. tostring(Cashier.time) .. ". New Bank Balance = " .. s .. "\n" --.. Cashier.savedVariablesLedger.Display
  ledgerInput = t

  Cashier.savedVariablesLedger.balance = Cashier.currentBankGold
  Cashier.CreateBankString()
  loadScrollData()
  Cashier.scrollList:Update(Cashier.dataItems)
 end
 
 function checkBalance()
   --check the balance and see if it is same as saved balance
   --Print("Current Bank = " .. Cashier.currentBankGold)
   --Print("Saved Bank = " .. Cashier.savedVariablesLedger.balance)
   if Cashier.currentBankGold ~=  Cashier.savedVariablesLedger.balance then
     Print(redColor:Colorize("ERROR: ") .. "Last recorded Bank balance was ".. yellowColor:Colorize(Cashier.savedVariablesLedger.balance) .. " current balance is " .. yellowColor:Colorize(Cashier.currentBankGold) .. ". If this is first time run the addon, disregard this message.")
     -- Print("Values not equal")
      if Cashier.savedVariables.Display ~= "No Entries Found" then
        --no previous records.
        --Print("True error")
        isError = true
      end
     
    end  
    --Print("checkBalance done")
   end
   
function CreateMainWindow()
    -- Create a top level window:
    local tlw = WINDOW_MANAGER:GetControlByName("LedgerWindow")   --    CreateTopLevelWindow("TestScrollList")
    
    tlw:SetMovable(true)
    
    return tlw
end

 -- Create the row setup callback function
function SetupDataRow(rowControl, data, scrollList)
    rowControl:SetMovable(true)
    rowControl:SetMouseEnabled(true)
    rowControl:SetText(data.name)
    rowControl:SetFont("ZoFontWinH4")
end
 
function CreateScrollList()

    local mainWindow = nil
  
         mainWindow = CreateMainWindow()
    
    -- Create the scrollData table for your scrollList
     Cashier.scrollData = {
        name = "LedgerScrollListTest",
        parent = mainWindow,
        
        width = ledgerSizeX -100,
        height = ledgerSizeY -100 ,
        rowHeight = 23,
        
        setupCallback = SetupDataRow,
    }
    Cashier.scrollList = libScroll:CreateScrollList(Cashier.scrollData)
    Cashier.scrollList:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 55, 50)

    loadScrollData()

end

function loadScrollData()
  
  Cashier.dataItems = { [1] = {name = bankDisplay[1]}, 
                          [2] = {name = bankDisplay[2]},
                          [3] = {name = bankDisplay[3]}, 
                          [4] = {name = bankDisplay[4]},
                          [5] = {name = bankDisplay[5]}, 
                          [6] = {name = bankDisplay[6]},
                          [7] = {name = bankDisplay[7]}, 
                          [8] = {name = bankDisplay[8]},
                          [9] = {name = bankDisplay[9]}, 
                          [10] = {name = bankDisplay[10]},
                          [11] = {name = bankDisplay[11]}, 
                          [12] = {name = bankDisplay[12]},
                          [13] = {name = bankDisplay[13]}, 
                          [14] = {name = bankDisplay[14]},
                          [15] = {name = bankDisplay[15]}, 
                          [16] = {name = bankDisplay[16]},
                          [17] = {name = bankDisplay[17]}, 
                          [18] = {name = bankDisplay[18]},
                          [19] = {name = bankDisplay[19]}, 
                          [20] = {name = bankDisplay[20]},
                          [21] = {name = bankDisplay[21]}, 
                          [22] = {name = bankDisplay[22]},
                          [23] = {name = bankDisplay[23]}, 
                          [24] = {name = bankDisplay[24]},
                          [25] = {name = bankDisplay[25]}, 
                          [26] = {name = bankDisplay[26]},
                          [27] = {name = bankDisplay[27]}, 
                          [28] = {name = bankDisplay[28]},
                          [29] = {name = bankDisplay[29]}, 
                          [30] = {name = bankDisplay[30]},
                          [31] = {name = bankDisplay[31]}, 
                          [32] = {name = bankDisplay[32]},
                          [33] = {name = bankDisplay[33]}, 
                          [34] = {name = bankDisplay[34]},
                          [35] = {name = bankDisplay[35]}, 
                          [36] = {name = bankDisplay[36]},
                          [37] = {name = bankDisplay[37]}, 
                          [38] = {name = bankDisplay[38]},
                          [39] = {name = bankDisplay[39]}, 
                          [40] = {name = bankDisplay[40]},
                          [41] = {name = bankDisplay[41]}, 
                          [42] = {name = bankDisplay[42]},
                          [43] = {name = bankDisplay[43]}, 
                          [44] = {name = bankDisplay[44]},
                          [45] = {name = bankDisplay[45]}, 
                          [46] = {name = bankDisplay[46]},
                          [47] = {name = bankDisplay[47]}, 
                          [48] = {name = bankDisplay[48]},
                          [49] = {name = bankDisplay[49]}, 
                          [50] = {name = bankDisplay[50]},
                         }
  
end

function Cashier.OnAddOnLoaded(event, addonName)
  
	-- Start the addon
	if addonName == Cashier.name then
	Cashier:Initialize()
	end

end

function Cashier.mouseOver()
  if not isMouseOver then  
  --CHAT_SYSTEM:AddMessage("Hover")
  CashierWindowTextShow:SetHidden(true)
  CashierWindowTextShow2:SetHidden(false)
  isMouseOver = true;
  end
end

function Cashier.mouseOverLedger()
  if not isMouseOver then  
  --CHAT_SYSTEM:AddMessage("Hover")
  CashierWindowTextShow3:SetHidden(true)
  CashierWindowTextShow4:SetHidden(false)
  isMouseOver = true;
  end
end

function Cashier.mouseNotOver()
  if isMouseOver then
  --CHAT_SYSTEM:AddMessage("Not Hover")
  CashierWindowTextShow:SetHidden(false)
  CashierWindowTextShow2:SetHidden(true)
  isMouseOver = false;
  end
end

function Cashier.mouseNotOverLedger()
  if isMouseOver then
  --CHAT_SYSTEM:AddMessage("Not Hover")
  CashierWindowTextShow3:SetHidden(false)
  CashierWindowTextShow4:SetHidden(true)
  isMouseOver = false;
  end
end

function Cashier.setTextClicked()
  --CHAT_SYSTEM:AddMessage("Button Clicked")
  isPlayerOnly = not isPlayerOnly 
  Cashier.savedVariables.isPlayerOnly = not Cashier.savedVariables.isPlayerOnly  
  local change = tonumber(Cashier.variableVersion) + 1
  Cashier.variableVersion = change 
  Cashier.setText()
  Cashier.LoadOfflineData()
  end

function Cashier.setText()
  
  if isPlayerOnly then
    CashierWindowTextShow:SetText("Self")
    CashierWindowTextShow2:SetText("Self")
  else
    CashierWindowTextShow:SetText("All")
    CashierWindowTextShow2:SetText("All")
  end  
end

function displayWindow()
  CashierWindow:SetDimensions( 300, windowLength)
  CashierWindowBackdrop:SetDimensions( 300, windowLength)
  CashierWindowEntry:SetDimensions( 300, windowLength)
  CashierWindowEntry2:SetDimensions( 300, windowLength)
  CashierWindowEntry3:SetDimensions( 300, windowLength)
  CashierWindowLabel:SetText("Cashier")
  _windowTable:SetHidden(Cashier.savedVariables.hidden)
  
  CashierWindow:ClearAnchors()
  CashierWindow:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT, Cashier.savedVariables.OffsetX,Cashier.savedVariables.OffsetY)
  
  end

function displayLedgerWindow()

  LedgerWindow:SetDimensions( ledgerSizeX, ledgerSizeY)
  LedgerWindowBackdrop:SetDimensions( ledgerSizeX, ledgerSizeY)
  LedgerWindowBackdrop2:SetDimensions( ledgerSizeX, ledgerSizeY)

  LedgerWindowLabel:SetText("Cashier Ledger")
  
  if Cashier.savedVariables.ledgerHidden ~= nil then
    Cashier.isHiddenWindowLedger = Cashier.savedVariables.ledgerHidden
  end
  
  LedgerWindow:SetHidden(Cashier.isHiddenWindowLedger)
  
  LedgerWindow:ClearAnchors()
  LedgerWindow:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT, Cashier.savedVariables.ledgerOffsetX,Cashier.savedVariables.ledgerOffsetY)
  
end

function Cashier.LoadOfflineBank()
  
  --load the saved file
  loadLedgerText()
  
  displayLedgerWindow()
  --Print("Cashier.LoadOfflineBank done")
end

function resetLedgerData()

  Cashier.variableVersion = Cashier.variableVersion + 1
  Cashier.savedVariablesLedger.count = 0
  
  ZO_ClearTable(Cashier.savedVariablesLedger.Display) 
  Cashier.savedVariablesLedger.Display[1] = "No Entries Found"
  
  Cashier.savedVariablesLedger.version = Cashier.variableVersion
  ReloadUI("ingame")
end

function loadLedgerText()
  
  local c = 1
  
  for k,v in pairs (Cashier.savedVariablesLedger.Display) do
      bankDisplay[c] = Cashier.savedVariablesLedger.Display[k]
      c = c + 1
  end
  
end

function Cashier.CreateBankString()
  --check how many entries are in current bankString
  --Print("CreateBankString Test")
  
  local c = 0

  for k,v in pairs(Cashier.savedVariablesLedger.Display) do
  --Print("line = " .. Cashier.savedVariablesLedger.Test[c])
  --bankDisplay[c] = Cashier.savedVariablesLedger.Display[k]
  c = c + 1
  end
  
  if ledgerInput ~= "" then
    if c == 1 and Cashier.savedVariablesLedger.Display[1] == "No Entries Found" then
      Cashier.savedVariablesLedger.Display[1] = ledgerInput 
    else
      table.insert(Cashier.savedVariablesLedger.Display, 1, ledgerInput)
       c = c + 1
    end
  end
  
  --Check to make sure the list is not more then 50 
  if c > 50 then
    --we must delete a record.
    Print("|cf9050cERROR:|r" .. " Too many records. Deleting oldest record.")
    table.remove(Cashier.savedVariablesLedger.Display, c)
    c = c - 1
  end
  
  --load the bankDisplay back up.
  for i = 1, c  do
    bankDisplay[i] = Cashier.savedVariablesLedger.Display[i]
  end
  
end

function Cashier.LoadOfflineData()

  --Load the offline characters
  local sv = CashierSavedVariables["Default"][GetDisplayName()]
  Cashier.numberOfCharacters = 1
  --update the display for current character
  Cashier.printOut = GetUnitName("player")
  Cashier.printOut2 = "="
  Cashier.printOut3 = GetCurrencyAmount(1,0)
  
  if isPlayerOnly == nil then
  isPlayerOnly = Cashier.savedVariables.isPlayerOnly
  end

  if not isPlayerOnly then
  Cashier.numberOfCharacters = -1 -- reset counter.
  for id , key in pairs(sv) do

  Cashier.numberOfCharacters = Cashier.numberOfCharacters + 1 -- getting size that the window needs to be
  local n,c
  n = key["name"]
  c = key["gold"]

  if key["name"] ~= Cashier.characterName then
    Cashier.printOut =  Cashier.printOut .."\n" .. n
    Cashier.printOut2 = Cashier.printOut2 .. "\n" .. "="
    Cashier.printOut3 = Cashier.printOut3 .. "\n" .. c   
    
  end -- end if key["name"] != Cashier.characterName then
end -- end for id , key in pairs(sv) do
end -- end  if not isPlayerOnly then
  CashierWindowEntry:SetText(Cashier.printOut) -- Send display string to window
  CashierWindowEntry2:SetText(Cashier.printOut2)
  CashierWindowEntry3:SetText(Cashier.printOut3)  
  windowLength = Cashier.numberOfCharacters * Cashier.windowSize
  
  displayWindow()
  
  end -- end function Cashier.LoadOfflineData()

function Cashier.MoneyChanged(eventCode, newMoney, oldMoney, reason)

  Cashier.currentGold = newMoney --update amount of money to saved variable
  Cashier.savedVariables.gold = newMoney  
  Cashier.LoadOfflineData()  
  Cashier.moneyDifference = 0
  
  --checking if money deposited or withdraw from bank
  local banked = GetCurrencyAmount(1,1)
  
  if banked ~= Cashier.currentBankGold then
    if banked > Cashier.currentBankGold then
      Cashier.symbol = " Deposited "
      Cashier.moneyDifference = banked - Cashier.currentBankGold
      Cashier.moneyDifference = greenColor:Colorize(Cashier.moneyDifference)
    else
      Cashier.symbol = " Withdrew "
      Cashier.moneyDifference =  Cashier.currentBankGold - banked
      Cashier.moneyDifference = redColor:Colorize(Cashier.moneyDifference)
    end -- end if banked > Cashier.currentBankGold then

    Cashier.currentBankGold = banked
    Cashier.BankMoneyChanged()
  end -- end if banked ~= Cashier.currentBankGold then

end

function Cashier.BankMoneyChanged()
  Cashier.GetTheDate()  
  local s = yellowColor:Colorize(Cashier.currentBankGold)
  --Print("inside Cashier.BankMoneyChanged time  = " .. Cashier.time)
  ledgerInput = Cashier.characterName .. " " .. tostring( Cashier.symbol) .. " " .. tostring( Cashier.moneyDifference) .. " gold on " .. Cashier.date .. " @ " .. tostring(Cashier.time) .. ". New Bank Balance = " .. s

  Cashier.savedVariablesLedger.balance = Cashier.currentBankGold
  Cashier.CreateBankString()
  loadScrollData()
  Cashier.scrollList:Update(Cashier.dataItems)
  --reset ledgerInput
  ledgerInput = ""
  end
 
function Cashier.GetTheDate()
  --Getting date
  local date = GetDate()
  local dt = tostring( date) -- convert date to string
  local printDate = dt.sub(dt,5,-3) .. "/" .. dt.sub(dt,7,-1) .. "/" .. dt.sub(dt,1,-5) -- formating date to be read.
  Cashier.date = printDate
 
 --Getting time
  date = GetFormattedTime()
  dt = tostring( date)
  if dt.len(dt) == 5 then dt = "0" .. dt end
  printDate = dt.sub(dt,1,-5) .. ":" .. dt.sub(dt,3,-3)
  Cashier.time = printDate
  end


function Cashier.SaveLoc()
	--Increase the version number the dat will be saved to datafile after ui reload
  local change = tonumber(Cashier.variableVersion) + 1
  Cashier.variableVersion = change  
  Cashier.savedVariables.OffsetX = CashierWindow:GetLeft()
	Cashier.savedVariables.OffsetY = CashierWindow:GetTop()
  Cashier.savedVariables.ledgerOffsetX = LedgerWindow:GetLeft()
  Cashier.savedVariables.ledgerOffsetY = LedgerWindow:GetTop()
  Cashier.savedVariablesLedger.ledgerX = ledgerSizeX
  Cashier.savedVariablesLedger.ledgerY = ledgerSizeY
  
  Cashier.savedVariables.version = Cashier.variableVersion
  --Print("Running SaveLoc()")
end

ZO_CreateStringId("SI_BINDING_NAME_CASHIERBUTTON", "Show/Hide Cashier Window")
ZO_CreateStringId("SI_BINDING_NAME_CASHIERBUTTON2", "Show/Hide Cashier Ledger Window")

function Cashier.ShowLedger()
  
  if Cashier.isHiddenWindowLedger then
    Cashier.isHiddenWindowLedger = false
    LedgerWindow:SetHidden(false)
    Print("Ledger Has Been Displayed")
  else
   Cashier.isHiddenWindowLedger = true  
   LedgerWindow:SetHidden(true)
   Print("Ledger Has Been Hidden")
  end
  
  local change = tonumber(Cashier.variableVersion) + 1
  Cashier.variableVersion = change
  Cashier.savedVariables.version = Cashier.variableVersion
  Cashier.savedVariables.ledgerHidden = Cashier.isHiddenWindowLedger
  end

function Cashier.Show()
  
  if Cashier.isHiddenWindow then
    Cashier.isHiddenWindow = false
    _windowTable:SetHidden(false)
    Print("Cashier Has Been Displayed")
  else
   Cashier.isHiddenWindow = true  
   _windowTable:SetHidden(true)
   Print("Cashier Has Been Hidden")
  end
  
  local change = tonumber(Cashier.variableVersion) + 1
  Cashier.variableVersion = change
  Cashier.savedVariables.version = Cashier.variableVersion
  Cashier.savedVariables.hidden = Cashier.isHiddenWindow
  
    end

function Cashier.SlashCommand()

  Cashier.Show()
  
end

function Cashier.ControlSettings()
    
    local panelData = {
    type = "panel",
    name = "Cashier",
    displayName = "|c00f012Cashier|r",
    author = "Tarlac",
    version = Cashier.version,
    slashCommand = "/cashiersettings",	--(optional) will register a keybind to open to this panel
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
}
    
    local optionsTable = {

    [1] = {
                type = "checkbox",
                name = "Show/Hide Cashier Window",
                tooltip = "This setting will display or hide the Cashier Window",
                getFunc = function() return not Cashier.isHiddenWindow end,
                setFunc = function(value) Cashier.Show() end,
                default = true,
            },  
    [2] = {
                type = "checkbox",
                name = "Show/Hide Ledger Window",
                tooltip = "This setting will display or hide the Ledger Window",
                getFunc = function() return not Cashier.isHiddenLedgerWindow end,
                setFunc = function(value) Cashier.ShowLedger() end,
                default = true,
            },
    [3] = {
                type = "slider",
                name = "Ledger Window Width",
                tooltip = "Adjust the Ledger Window Width\nWill require you to |cf9050cMANUALLY|r reloadui",
                min = 300,
                max = 1000,
                getFunc = function() return ledgerSizeX end,
                setFunc = function(value) ledgerSizeX = tonumber(value) Cashier.SaveLoc() Cashier.LoadOfflineBank() end,
                width = "half",	--or "half" (optional)
                default = 800,	--(optional)
        },
    [4] = {
                type = "slider",
                name = "Ledger Window Height",
                tooltip = "Adjust the Ledger Window Height\nWill require you to |cf9050cMANUALLY|r reloadui",
                min = 150,
                max = 1000,
                getFunc = function() return ledgerSizeY end,
                setFunc = function(value) ledgerSizeY = tonumber(value) Cashier.SaveLoc() Cashier.LoadOfflineBank() end,
                width = "half",	--or "half" (optional)
                default = 700,	--(optional)
        },
    [5] = {
                type = "button",
                name = "Reset Ledger",
                tooltip = "Reset Ledger DataBase -- Will restart UI",
                func = function() resetLedgerData() end,
                warning = "Will need to reload the UI.",	--(optional)
    },
       
}

    local LAM2 = LibStub("LibAddonMenu-2.0")

    LAM2:RegisterAddonPanel("CashierSettings", panelData) 
    LAM2:RegisterOptionControls("CashierSettings", optionsTable)

    end


HUD_FRAGMENT:RegisterCallback("StateChange",  function(oldState, newState)
--[[ possible states are:
                SCENE_FRAGMENT_SHOWN = "shown"
                SCENE_FRAGMENT_HIDDEN = "hidden"
                SCENE_FRAGMENT_SHOWING = "showing"
                SCENE_FRAGMENT_HIDING = "hiding"
            ]]--
  if newState == SCENE_FRAGMENT_SHOWN then
    if Cashier.savedVariables.hidden ~= true or false then
      Cashier.savedVariables.hidden = false
    end
    if Cashier.savedVariables.ledgerHidden ~= true or false then      
      Cashier.savedVariables.ledgerHidden = true
    end
    _windowTable:SetHidden(Cashier.savedVariables.hidden)
   _legerWindow:SetHidden(Cashier.savedVariables.ledgerHidden)
  elseif newState == SCENE_FRAGMENT_HIDING then
    _windowTable:SetHidden(true)
    _legerWindow:SetHidden(true)
  end
end )-- function

EVENT_MANAGER:RegisterForEvent(Cashier.name, EVENT_ADD_ON_LOADED, Cashier.OnAddOnLoaded)
SLASH_COMMANDS["/cashier"] = function() Cashier.SlashCommand()  end

Print(loadMessage)