DSDB = {}
DSDB.name = "DescendantsDisplayBar"
--------------------------------------------------------------------------------
-- GLOBAL VARIABLES
--------------------------------------------------------------------------------
DSDB.locked = true
--------------------------------------------------------------------------------
-- LOCAL VARIABLES
--------------------------------------------------------------------------------
local sceneHud = SCENE_MANAGER:GetScene("hud")
local sceneHudUi = SCENE_MANAGER:GetScene("hudui")
local colors = {
    RED         = { r = 1    , g = 0    , b = 0    },
    GREEN       = { r = 0    , g = 1    , b = 0    },
    BLUE        = { r = 0    , g = 0    , b = 1    },
    YELLOW      = { r = 1    , g = 1    , b = 0    },
    WHITE       = { r = 1    , g = 1    , b = 1    },
    BLACK       = { r = 0    , g = 0    , b = 0    },
    GRAY        = { r = 0.5  , g = 0.5  , b = 0.5  },
}
--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS TO UPDATE THE TEXT AND COLOR OF CURRENCYS
--------------------------------------------------------------------------------
local function updateTradeBars()
	local tradebars = GetCurrencyAmount(CURT_TRADE_BARS,CURRENCY_LOCATION_ACCOUNT)
	local color = colors.WHITE
	DSDB.ticket.Label:SetText(tradebars)
	DSDB.ticket.Label:SetColor( color.r, color.g, color.b, 1 )
end

local function updateInventory()
	local color = colors.WHITE
	DSDB.inventory.Label:SetText(GetNumBagUsedSlots(BAG_BACKPACK).."/"..GetBagSize(BAG_BACKPACK))
	if (GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK) ) <= 10 then
		color = colors.RED
	end
	DSDB.inventory.Label:SetColor( color.r, color.g, color.b, 1 )
end

local function updateBank()
	local color = colors.WHITE
	local totBankSlots = 0
	if IsESOPlusSubscriber() then
		totBankSlots = GetBagSize(BAG_SUBSCRIBER_BANK)+GetBagSize(BAG_BANK)
	else
		totBankSlots = GetBagSize(BAG_BANK)
	end
	local usedBankSlots = GetNumBagUsedSlots(BAG_BANK)+GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
	DSDB.bank.Label:SetText(usedBankSlots.."/"..totBankSlots)
	if usedBankSlots >= (0.9*totBankSlots) then
		color = colors.RED
	end
	DSDB.bank.Label:SetColor( color.r, color.g, color.b, 1 )
end

local function updateCurrencys()
	DSDB.transmute.Label:SetText(GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT))
	DSDB.key.Label:SetText(GetCurrencyAmount(CURT_UNDAUNTED_KEYS,CURRENCY_LOCATION_ACCOUNT))
	DSDB.gold.Label:SetText(GetCurrencyAmount(CURT_MONEY,CURRENCY_LOCATION_CHARACTER))
	updateTradeBars()
end
--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS TO HIDE THE ADD ON IN EVERY MENU
--------------------------------------------------------------------------------
local function sceneChange(oldState, newState)
    if (newState == SCENE_SHOWN) then
        DSDB.cMainWindow:SetHidden(false)
    elseif (newState == SCENE_HIDDEN) then
        DSDB.cMainWindow:SetHidden(true)
    end
end
--------------------------------------------------------------------------------
-- UPDATE BAR INFO EVERY 1 SEC
--------------------------------------------------------------------------------
function DSDB.UpdateSec()
    -- Update time
   DSDB.Time.Label:SetText( GetTimeString() )

    -- Update fps
    local fps = GetFramerate()
    local color = colors.GREEN
	if fps < 50 then
		color = colors.YELLOW
	else if fps < 30 then
		color = colors.RED
		end
    end
    DSDB.fps.Label:SetText( string.format( "%d fps", fps ) )
    DSDB.fps.Label:SetColor( color.r, color.g, color.b, 1 )
end
--------------------------------------------------------------------------------
-- UPDATE BAR INFO EVERY 15 SEC
--------------------------------------------------------------------------------
function DSDB.Update15Sec()
    -- Update latency
    local ping = GetLatency()
    local color = colors.RED
	
    if ping < 100 then
        color = colors.GREEN
        
	else if ping < 200 then
		color = colors.YELLOW
		end
    end
    DSDB.ping.Label:SetText( string.format( "%d ms", ping ) )
    DSDB.ping.Label:SetColor( color.r, color.g, color.b, 1 )
end

--------------------------------------------------------------------------------
-- UPDATE BAR INFO EVERY MINUTE
--------------------------------------------------------------------------------
function DSDB.UpdateMin()
	updateTradeBars()
	updateBank()
	updateInventory()
end
--------------------------------------------------------------------------------
-- RESTORE POSITION WHERE THE USER PUT THE BAR
--------------------------------------------------------------------------------
function DSDB:RestorePosition()
  local left = DSDB.savedVariables.left or 300
  local top = DSDB.savedVariables.top or 10
 
  DSDB.cMainWindow:ClearAnchors()
  DSDB.cMainWindow:SetAnchor(TOPLEFT, GuiRoot, nil, left , top)
end

function DSDB.OnIndicatorMoveStop()
  DSDB.savedVariables.left = DSDB.cMainWindow:GetLeft()
  DSDB.savedVariables.top = DSDB.cMainWindow:GetTop()
end
--------------------------------------------------------------------------------
-- INITIALIZE THE ADDON
--------------------------------------------------------------------------------
function DSDB:Initialize()
	EVENT_MANAGER:RegisterForEvent(self.name)
	--------------------------------------------------------------------------------
	-- LOAD SAVED VARIABLE
	self.savedVariables = ZO_SavedVars:NewAccountWide("DSDBSavedVariables", 2, nil, {}, GetWorldName())
	DSDB.locked = self.savedVariables.locked
	--------------------------------------------------------------------------------
	-- TRIGGER WINDOW CREATION IN DescendantsDisplayBarUI.LUA
	DSDB.CreateMainWindowControl()
	--------------------------------------------------------------------------------
	-- RESTORE WINDOW POSITION AND ADD HANDLER FOR SAVING THE POSITION
	self:RestorePosition()
	DSDB.cMainWindow:SetHandler("OnMoveStop", function(self) DSDB.OnIndicatorMoveStop()  end) 
	--------------------------------------------------------------------------------
	-- RUN THE FUNCTIONS THAT AFTERWARDS ARE UPDATED EVERY 15/60 SEC 
	DSDB.Update15Sec()
	DSDB.UpdateMin()
	--------------------------------------------------------------------------------
	-- GENERATE THE ADDON SETTINGS WITH LIBADDONMENU (DESCENDANTSDISPLAYBARSETTINGS.LUA)
	if LibAddonMenu2 then
		DSDB.setupSettings()
	end
	--------------------------------------------------------------------------------
	-- REGISTER THE THREE FUNCTIONS FOR REGULAR BAR UPDATES
	EVENT_MANAGER:RegisterForUpdate( DSDB.name .. "sec" , 1000,  DSDB.UpdateSec )
    EVENT_MANAGER:RegisterForUpdate( DSDB.name .. "15sec" , 15000, DSDB.Update15Sec )
    EVENT_MANAGER:RegisterForUpdate( DSDB.name .. "min" , 60000, DSDB.UpdateMin )
	--------------------------------------------------------------------------------
	-- REGISTER AUTOMATIC UPDATES FOR BANK SPACE CHANGES
	EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_INVENTORY_BOUGHT_BANK_SPACE, updateBank)
	EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_CLOSE_BANK, updateBank)
	--------------------------------------------------------------------------------
	-- REGISTER AUTOMATIC UPDATES FOR INVENTORY SPACE CHANGES	
	EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_INVENTORY_BOUGHT_BAG_SPACE, updateInventory)
	EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, updateInventory)
	--------------------------------------------------------------------------------
	-- REGISTER AUTOMATIC UPDATES FOR CUREENCY CHANGES	
	EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_CURRENCY_UPDATE, updateCurrencys)	
	--------------------------------------------------------------------------------
	-- UNREGISTER FOR THE ADDON LOAD EVENT
	EVENT_MANAGER:UnregisterForEvent(DSDB.name, EVENT_ADD_ON_LOADED)
end

function DSDB.OnAddOnLoaded(event, addonName)

  if addonName == DSDB.name then
    DSDB:Initialize()
  end
  sceneHud:RegisterCallback("StateChange", sceneChange)
  sceneHudUi:RegisterCallback("StateChange", sceneChange)
end
 

EVENT_MANAGER:RegisterForEvent(DSDB.name, EVENT_ADD_ON_LOADED, DSDB.OnAddOnLoaded)