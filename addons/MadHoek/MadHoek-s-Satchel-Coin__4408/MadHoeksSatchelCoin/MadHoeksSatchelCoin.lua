----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 										   MadHoek's Satchel & Coin (MHSBC) ESO AddOn by MadHoek 														----
---- 												-------------------------------------																	----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----    This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.												----
----    The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 	----
----    All rights reserved																																	----
----																																						----
----    You can read the full terms at https://account.elderscrollsonline.com/add-on-terms																	----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- create a namespace for MHSBC by declaring a top-level table that will hold everything else.
if MHSBC == nil then MHSBC = {} end

-- addon infos
MHSBC.name = "MadHoeksSatchelCoin"
MHSBC.version = "3.0.8"
MHSBC.savename = "MadHoeksSatchelCoinVars"
-- session-only debounce flag (avoids duplicate refresh scheduling)
MHSBC._refreshPending = false
-- session-only easter egg flag
MHSBC._invisibleEasterShown = false
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------> 
local windowCreated = false

local wm = GetWindowManager()
local em = GetEventManager()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Register the event handler function to be called to do initialization
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
em:RegisterForEvent(MHSBC.name, EVENT_ADD_ON_LOADED, function(...) MHSBC.Initialize (...) end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Helpers
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Debounced refresh (collapses burst events into 1 UI update)
function MHSBC.RequestRefresh()
    if MHSBC.data.addonready == 0 then return end
    if MHSBC._refreshPending then return end

    MHSBC._refreshPending = true
    zo_callLater(function()
        MHSBC._refreshPending = false
        MHSBC.RefreshWindow()
    end, 50) -- 50–100ms is usually enough
end

-- gold button function
function MHSBC.GoldClicked()
	local saved = MHSBC.data.savedvariables
	saved.showCurrency = not saved.showCurrency
	MHSBC.RefreshLayout()
end

-- check if everything is disabled in primary row 
function MHSBC.IsPrimaryRowVisible()
    local saved = MHSBC.data.savedvariables
    return saved.showBags or saved.showBank or saved.showGold
end

-- fallback to currency row if everything in primary row is disabled
function MHSBC.IsCurrencyRowVisibleEffective()
    local saved = MHSBC.data.savedvariables

    -- force currency row if primary row is fully hidden
    local forceCurrency = not MHSBC.IsPrimaryRowVisible()

    if (saved.showCurrency or forceCurrency) then
        return (saved.showBankGold or saved.showTelVar or saved.showAlliancePoints or saved.showWritVouchers or saved.showTradeBars)
    end

    return false
end

-- check if the user disabled everything
function MHSBC.IsEverythingDisabled()
    local saved = MHSBC.data.savedvariables
    return (not saved.showBags)
       and (not saved.showBank)
       and (not saved.showGold)
       and (not saved.showTelVar)
       and (not saved.showAlliancePoints)
       and (not saved.showWritVouchers)
       and (not saved.showTradeBars)
	   and (not saved.showBankGold)
end

-- refresh the layout of the rows and refresh the window
function MHSBC.RefreshLayout()
    if not MHSBC.window then return end
    MHSBC.ReanchorPrimaryRow()
    MHSBC.ReanchorCurrencyRow()
    MHSBC.RefreshWindow()
end

-- reanchor the individual elements of the primary row based on visibility state
function MHSBC.ReanchorPrimaryRow()
    local saved = MHSBC.data.savedvariables

    -- clear anchors for the primary row columns
    MHSBC.window.entries.column1:ClearAnchors()
    MHSBC.window.entries.column2:ClearAnchors()
    MHSBC.window.entries.column3:ClearAnchors()

    -- columns in display order
    local cols = {
        { ctrl = MHSBC.window.entries.column1, visible = saved.showBags },
        { ctrl = MHSBC.window.entries.column2, visible = saved.showBank },
        { ctrl = MHSBC.window.entries.column3, visible = saved.showGold },
    }

    -- find first visible
    local first = nil
    for i = 1, #cols do
        if cols[i].visible then first = cols[i].ctrl break end
    end

    -- if nothing is visible, just anchor them in default positions (won't matter much)
    if not first then
        MHSBC.window.entries.column1:SetAnchor(LEFT, MHSBC.window.entries, LEFT, 0, 0)
        MHSBC.window.entries.column2:SetAnchor(LEFT, MHSBC.window.entries.column1, RIGHT, saved.iconSize, 0)
        MHSBC.window.entries.column3:SetAnchor(LEFT, MHSBC.window.entries.column2, RIGHT, saved.iconSize, 0)
        return
    end

    -- anchor first visible at row start
    first:SetAnchor(LEFT, MHSBC.window.entries, LEFT, 0, 0)

    -- chain remaining visibles
    local prev = first
    for i = 1, #cols do
        local c = cols[i].ctrl
        if c ~= first and cols[i].visible then
            c:SetAnchor(LEFT, prev, RIGHT, saved.iconSize, 0)
            prev = c
        end
    end
end

-- reanchor the individual elements of the currency row based on visibility state
function MHSBC.ReanchorCurrencyRow()
    local saved = MHSBC.data.savedvariables
    local forceCurrency = not MHSBC.IsPrimaryRowVisible()
    local showCurrencyEffective = saved.showCurrency or forceCurrency

    -- always clear
	MHSBC.window.entries.column8:ClearAnchors()
    MHSBC.window.entries.column4:ClearAnchors()
    MHSBC.window.entries.column5:ClearAnchors()
    MHSBC.window.entries.column6:ClearAnchors()
    MHSBC.window.entries.column7:ClearAnchors()

    -- find the first visible currency column
    local cols = {
		{ ctrl = MHSBC.window.entries.column8, visible = showCurrencyEffective and saved.showBankGold },
        { ctrl = MHSBC.window.entries.column4, visible = showCurrencyEffective and saved.showTelVar },
        { ctrl = MHSBC.window.entries.column5, visible = showCurrencyEffective and saved.showAlliancePoints },
        { ctrl = MHSBC.window.entries.column6, visible = showCurrencyEffective and saved.showWritVouchers },
        { ctrl = MHSBC.window.entries.column7, visible = showCurrencyEffective and saved.showTradeBars },
    }

    local first = nil
    for i = 1, #cols do
        if cols[i].visible then first = cols[i].ctrl break end
    end

    -- nothing visible -> keep default anchor, doesn't matter (row hidden via insets anyway)
    if not first then
		MHSBC.window.entries.column8:SetAnchor(TOPLEFT, MHSBC.window.entries, BOTTOMLEFT, 0, -saved.iconSpace*1.5)
		MHSBC.window.entries.column4:SetAnchor(LEFT, MHSBC.window.entries.column8, RIGHT, saved.iconSize, 0)
        MHSBC.window.entries.column5:SetAnchor(LEFT, MHSBC.window.entries.column4, RIGHT, saved.iconSize, 0)
        MHSBC.window.entries.column6:SetAnchor(LEFT, MHSBC.window.entries.column5, RIGHT, saved.iconSize, 0)
        MHSBC.window.entries.column7:SetAnchor(LEFT, MHSBC.window.entries.column6, RIGHT, saved.iconSize, 0)
        return
    end

    -- anchor first visible to the row start
    first:SetAnchor(TOPLEFT, MHSBC.window.entries, BOTTOMLEFT, 0, -saved.iconSpace*1.5)

    -- chain the rest to the previous visible
    local prev = first
    for i = 1, #cols do
        local c = cols[i].ctrl
        if c ~= first and cols[i].visible then
            c:SetAnchor(LEFT, prev, RIGHT, saved.iconSize, 0)
            prev = c
        end
    end
end

-- update spaces between icon and infotext after fontsize change
function MHSBC.ReanchorColumnInternals()
    local saved = MHSBC.data.savedvariables
    if not MHSBC.window or not MHSBC.window.entries then return end

    -- Column 1
    MHSBC.window.entries.column1.label:ClearAnchors()
    MHSBC.window.entries.column1.label:SetAnchor(LEFT, MHSBC.window.entries.column1.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column1.items:ClearAnchors()
    MHSBC.window.entries.column1.items:SetAnchor(LEFT, MHSBC.window.entries.column1.label, LEFT, 0, MHSBC.window.iconSize*0.125)

    -- Column 2
    MHSBC.window.entries.column2.label:ClearAnchors()
    MHSBC.window.entries.column2.label:SetAnchor(LEFT, MHSBC.window.entries.column2.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column2.items:ClearAnchors()
    MHSBC.window.entries.column2.items:SetAnchor(LEFT, MHSBC.window.entries.column2.label, LEFT, saved.iconSpace*1.3, 0)

    -- Column 3
    MHSBC.window.entries.column3.label:ClearAnchors()
    MHSBC.window.entries.column3.label:SetAnchor(LEFT, MHSBC.window.entries.column3.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column3.items:ClearAnchors()
    MHSBC.window.entries.column3.items:SetAnchor(LEFT, MHSBC.window.entries.column3.label, LEFT, saved.iconSpace*1.5, 0)

    -- Column 4
    MHSBC.window.entries.column4.label:ClearAnchors()
    MHSBC.window.entries.column4.label:SetAnchor(LEFT, MHSBC.window.entries.column4.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column4.items:ClearAnchors()
    MHSBC.window.entries.column4.items:SetAnchor(LEFT, MHSBC.window.entries.column4.label, LEFT, saved.iconSpace*1.5, 0)

	-- Column 5
    MHSBC.window.entries.column5.label:ClearAnchors()
    MHSBC.window.entries.column5.label:SetAnchor(LEFT, MHSBC.window.entries.column5.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column5.items:ClearAnchors()
    MHSBC.window.entries.column5.items:SetAnchor(LEFT, MHSBC.window.entries.column5.label, LEFT, saved.iconSpace*1.5, 0)

	-- Column 6
    MHSBC.window.entries.column6.label:ClearAnchors()
    MHSBC.window.entries.column6.label:SetAnchor(LEFT, MHSBC.window.entries.column6.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column6.items:ClearAnchors()
    MHSBC.window.entries.column6.items:SetAnchor(LEFT, MHSBC.window.entries.column6.label, LEFT, saved.iconSpace*1.5, 0)

	-- Column 7
    MHSBC.window.entries.column7.label:ClearAnchors()
    MHSBC.window.entries.column7.label:SetAnchor(LEFT, MHSBC.window.entries.column7.icon, RIGHT, saved.iconSpace, 0)

    MHSBC.window.entries.column7.items:ClearAnchors()
    MHSBC.window.entries.column7.items:SetAnchor(LEFT, MHSBC.window.entries.column7.label, LEFT, saved.iconSpace*1.5, 0)

	-- Column 8
	MHSBC.window.entries.column8.label:ClearAnchors()
	MHSBC.window.entries.column8.label:SetAnchor(LEFT, MHSBC.window.entries.column8.icon, RIGHT, saved.iconSpace, 0)

	MHSBC.window.entries.column8.items:ClearAnchors()
	MHSBC.window.entries.column8.items:SetAnchor(LEFT, MHSBC.window.entries.column8.label, LEFT, saved.iconSpace*1.5, 0)
end

-- Set the size of the font, the icons and the spaces
function MHSBC.SetFontSize(value)
	
	local saved = MHSBC.data.savedvariables
	saved.fontSize 	 = value
	saved.iconSize 	 = value*1.389
	saved.iconSpace  = saved.iconSize*0.25
	MHSBC.window.fontSize  = value
	MHSBC.window.iconSize  = value*1.389
	MHSBC.window.iconSpace = MHSBC.window.iconSize*0.25

	MHSBC.window.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column1.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column2.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column3.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column3.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column4.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column4.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column5.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column5.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column6.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column6.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column7.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column7.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column8.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column8.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")

	MHSBC.window.entries.column1.icon:SetDimensions(MHSBC.window.iconSize, MHSBC.window.iconSize)
	MHSBC.window.entries.column2.icon:SetDimensions(MHSBC.window.iconSize, MHSBC.window.iconSize)
	MHSBC.window.entries.column3.icon:SetDimensions(MHSBC.window.iconSize*0.80, MHSBC.window.iconSize*0.80)
	MHSBC.window.entries.column3.button:SetDimensions(MHSBC.window.iconSize*0.90, MHSBC.window.iconSize*0.90)
	MHSBC.window.entries.column4.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column5.icon:SetDimensions(MHSBC.window.iconSize*0.80, MHSBC.window.iconSize*0.80)
	MHSBC.window.entries.column6.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column7.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column8.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)

	MHSBC.ReanchorColumnInternals()
	MHSBC.RefreshLayout()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Event handlers
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.OpenBankEvent(eventCode)
    MHSBC.RequestRefresh()
end

function MHSBC.CloseBankEvent(eventCode)
    MHSBC.RequestRefresh()
end

function MHSBC.InventoryEvent(bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    MHSBC.RequestRefresh()
end

function MHSBC.ItemEvent(eventCode, eventData)
    MHSBC.RequestRefresh()
end

function MHSBC.MoneyEvent(eventCode, eventData)
    MHSBC.RequestRefresh()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Initialize Addon
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.Initialize(eventCode, addOnName)

	if(addOnName == MHSBC.name) then

	em:UnregisterForEvent(MHSBC.name, EVENT_ADD_ON_LOADED)

	MHSBC.data = {
		addonready = 0,
		updated = 0,
		savedvariables = {},
		default = {
			alpha    = 0,
			fontSize = 18,
			iconSize = 25,
			iconSpace = 6.25,
			bagWarning = 5,
			bankWarning = 5,
			showBags = true,
			showBank = true,
			showGold = true,
			showTelVar = true,
			showAlliancePoints = true,
			showWritVouchers = true,
			showTradeBars = true,
			showBankGold = true,
			showCurrency = false,
			shown = true,
			locked = false,
			positionInitialized = false,
			offsetX = 0,
			offsetY = 0,
			Colors = {
				normal_R = .90,
				normal_G = .85,
				normal_B = .80,
				normal_A = 1,
				warn_R = .92,
				warn_G = .85,
				warn_B = .24,
				warn_A = 1,
				full_R = .86,
				full_G = .42,
				full_B = .39,
				full_A = 1,
			}
		}
	}

	-- create ZO_SavedVars
	MHSBC.data.savedvariables = ZO_SavedVars:NewAccountWide(MHSBC.savename, 1, nil, MHSBC.data.default)

	MHSBC.data.bag = {}
	MHSBC.data.bank = {}
	MHSBC.data.subscriber = {}

	-- check & correct saved vars
	if MHSBC.data.savedvariables.positionInitialized == nil then
    MHSBC.data.savedvariables.positionInitialized = false
	end

	if MHSBC.data.savedvariables.offsetX == nil then
		MHSBC.data.savedvariables.offsetX = MHSBC.data.default.offsetX
	end

	if MHSBC.data.savedvariables.offsetY == nil then
		MHSBC.data.savedvariables.offsetY = MHSBC.data.default.offsetY
	end

	if MHSBC.data.savedvariables.alpha         		== nil 	then MHSBC.data.savedvariables.alpha      		  = MHSBC.data.default.alpha       		  end
	if MHSBC.data.savedvariables.fontSize      		== nil 	then MHSBC.data.savedvariables.fontSize   		  = MHSBC.data.default.fontSize    		  end
	if MHSBC.data.savedvariables.iconSpace     		== nil 	then MHSBC.data.savedvariables.iconSpace  		  = MHSBC.data.default.iconSize*0.25   	  end
	if MHSBC.data.savedvariables.locked        		== nil 	then MHSBC.data.savedvariables.locked     		  = MHSBC.data.default.locked      		  end
	if MHSBC.data.savedvariables.bagWarning    		== nil 	then MHSBC.data.savedvariables.bagWarning   	  = MHSBC.data.default.bagWarning  		  end
	if MHSBC.data.savedvariables.bankWarning   		== nil 	then MHSBC.data.savedvariables.bankWarning 		  = MHSBC.data.default.bankWarning 		  end
	if MHSBC.data.savedvariables.showBags      		== nil 	then MHSBC.data.savedvariables.showBags 		  = MHSBC.data.default.showBags  		  end
	if MHSBC.data.savedvariables.showBank      		== nil 	then MHSBC.data.savedvariables.showBank 		  = MHSBC.data.default.showBank  		  end
	if MHSBC.data.savedvariables.showGold      		== nil 	then MHSBC.data.savedvariables.showGold 		  = MHSBC.data.default.showGold  		  end
	if MHSBC.data.savedvariables.showTelVar 		== nil  then MHSBC.data.savedvariables.showTelVar 		  = MHSBC.data.default.showTelVar 		  end
	if MHSBC.data.savedvariables.showAlliancePoints == nil  then MHSBC.data.savedvariables.showAlliancePoints = MHSBC.data.default.showAlliancePoints end
	if MHSBC.data.savedvariables.showWritVouchers 	== nil  then MHSBC.data.savedvariables.showWritVouchers   = MHSBC.data.default.showWritVouchers   end
	if MHSBC.data.savedvariables.showTradeBars 		== nil  then MHSBC.data.savedvariables.showTradeBars   	  = MHSBC.data.default.showTradeBars   	  end
	if MHSBC.data.savedvariables.showBankGold 		== nil 	then MHSBC.data.savedvariables.showBankGold 	  = MHSBC.data.default.showBankGold 	  end
	if MHSBC.data.savedvariables.shown         		== nil 	then MHSBC.data.savedvariables.shown 			  = MHSBC.data.default.shown 			  end
	if MHSBC.data.savedvariables.iconSize      		== nil 	then MHSBC.data.savedvariables.iconSize   		  = MHSBC.data.default.fontSize*1.389  	  end
	if MHSBC.data.savedvariables.showCurrency  		== nil 	then MHSBC.data.savedvariables.showCurrency 	  = MHSBC.data.default.showCurrency 	  end

	if (MHSBC.data.savedvariables.nameversion == nil) or (MHSBC.data.savedvariables.nameversion ~= MHSBC.version) then
		-- migration: remove obsolete saved var from older versions
		MHSBC.data.savedvariables.showEventTickets = nil

		-- mark migration/version as done
		MHSBC.data.savedvariables.nameversion = MHSBC.version
	end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	-- Colors Default
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	if MHSBC.data.savedvariables.Colors == nil then
		MHSBC.data.savedvariables.Colors = {}
	end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	-- Colors Custom
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	-- Normal Color
	if (MHSBC.data.savedvariables.Colors.normal_R   == nil) then MHSBC.data.savedvariables.Colors.normal_R  = MHSBC.data.default.Colors.normal_R end
	if (MHSBC.data.savedvariables.Colors.normal_G   == nil) then MHSBC.data.savedvariables.Colors.normal_G  = MHSBC.data.default.Colors.normal_G end
	if (MHSBC.data.savedvariables.Colors.normal_B   == nil) then MHSBC.data.savedvariables.Colors.normal_B  = MHSBC.data.default.Colors.normal_B end
	if (MHSBC.data.savedvariables.Colors.normal_A   == nil) then MHSBC.data.savedvariables.Colors.normal_A  = MHSBC.data.default.Colors.normal_A end
	-- Warning Color
	if (MHSBC.data.savedvariables.Colors.warn_R   	== nil) then MHSBC.data.savedvariables.Colors.warn_R 	= MHSBC.data.default.Colors.warn_R   end
	if (MHSBC.data.savedvariables.Colors.warn_G   	== nil) then MHSBC.data.savedvariables.Colors.warn_G 	= MHSBC.data.default.Colors.warn_G   end
	if (MHSBC.data.savedvariables.Colors.warn_B   	== nil) then MHSBC.data.savedvariables.Colors.warn_B 	= MHSBC.data.default.Colors.warn_B   end
	if (MHSBC.data.savedvariables.Colors.warn_A   	== nil) then MHSBC.data.savedvariables.Colors.warn_A 	= MHSBC.data.default.Colors.warn_A   end
	-- Full Color
	if (MHSBC.data.savedvariables.Colors.full_R   	== nil) then MHSBC.data.savedvariables.Colors.full_R 	= MHSBC.data.default.Colors.full_R   end
	if (MHSBC.data.savedvariables.Colors.full_G   	== nil) then MHSBC.data.savedvariables.Colors.full_G 	= MHSBC.data.default.Colors.full_G   end
	if (MHSBC.data.savedvariables.Colors.full_B   	== nil) then MHSBC.data.savedvariables.Colors.full_B 	= MHSBC.data.default.Colors.full_B   end
	if (MHSBC.data.savedvariables.Colors.full_A   	== nil) then MHSBC.data.savedvariables.Colors.full_A 	= MHSBC.data.default.Colors.full_A   end

	-- subscribe to gold, bank, and inventory related events
	em:RegisterForEvent(MHSBC.name, EVENT_OPEN_STORE, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_OPEN_BANK, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_CLOSE_BANK, function(...) MHSBC.CloseBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_OPEN_GUILD_BANK, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_CLOSE_GUILD_BANK, function(...) MHSBC.CloseBankEvent(...) end)
	
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, function(...) MHSBC.ItemEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) MHSBC.InventoryEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_BOUGHT_BAG_SPACE, function(...) MHSBC.ItemEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_ITEM_DESTROYED, function(...) MHSBC.ItemEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_ITEM_USED, function(...) MHSBC.ItemEvent(...) end)
	
	em:RegisterForEvent(MHSBC.name, EVENT_MONEY_UPDATE, function(...) MHSBC.MoneyEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_CURRENCY_UPDATE, function(...) MHSBC.MoneyEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_TRADE_BAR_UPDATE, function(...) MHSBC.MoneyEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_BANKED_MONEY_UPDATE, function(...) MHSBC.MoneyEvent(...) end)
		
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, function(...) MHSBC.ItemEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_INVENTORY_BOUGHT_BANK_SPACE, function(...) MHSBC.ItemEvent(...) end)
		
	em:RegisterForEvent(MHSBC.name, EVENT_STABLE_INTERACT_END, function(...) MHSBC.ItemEvent(...) end)
		
	em:RegisterForEvent(MHSBC.name, EVENT_GUILD_BANKED_MONEY_UPDATE, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_GUILD_BANK_UPDATED_QUANTITY, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_GUILD_BANK_ITEMS_READY, function(...) MHSBC.OpenBankEvent(...) end)
	em:RegisterForEvent(MHSBC.name, EVENT_GUILD_BANK_SELECTED, function(...) MHSBC.OpenBankEvent(...) end)

	em:RegisterForEvent("MadHoeksSatchelCoinStart", EVENT_PLAYER_ACTIVATED, function(...) MHSBC.OnPlayerActivated(...) end)


	MHSBC.InitializeControls()
	MHSBC.CreateMenu()

	end
end

function MHSBC.OnPlayerActivated(eventCode, addOnName)

	if not windowCreated then
		MHSBC.CreateWindow()
		local fontSize = MHSBC.data.savedvariables.fontSize
		MHSBC.SetFontSize(fontSize)
	else
		-- window was already created
	end

	if not MHSBC.data.savedvariables.positionInitialized then
		-- make sure size is correct first
		MHSBC.RefreshLayout()

		local sw = GuiRoot:GetWidth()
		local sh = GuiRoot:GetHeight()
		local ww = MHSBC.window:GetWidth()
		local wh = MHSBC.window:GetHeight()

		local x = (sw - ww) * 0.5
		local y = (sh - wh) * 0.5

		MHSBC.window:ClearAnchors()
		MHSBC.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

		MHSBC.data.savedvariables.offsetX = x
		MHSBC.data.savedvariables.offsetY = y
		MHSBC.data.savedvariables.positionInitialized = true
	end

	MHSBC.data.addonready = 1

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- MHSBC Window
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------> 
function MHSBC.CreateWindow()

	local saved = MHSBC.data.savedvariables

	-- main window
	MHSBC.window = wm:CreateTopLevelWindow("MadHoeksSatchelCoinWindow")

	MHSBC.window:SetClampedToScreen(true)
	MHSBC.window:SetClampedToScreenInsets(-saved.fontSize*0.25, -saved.fontSize*0.25, saved.fontSize*0.25, saved.fontSize*0.25) --SetClampedToScreenInsets(number left, number top, number right, number bottom) 
	MHSBC.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.offsetX, saved.offsetY)
	MHSBC.window:SetMovable(not saved.locked)
	MHSBC.window:SetHidden(not saved.shown)
	MHSBC.window:SetMouseEnabled(true)
	MHSBC.window:SetDimensions(0,0)
	MHSBC.window:SetResizeToFitDescendents(true)
	MHSBC.window:SetHandler("OnMoveStop", function()
		saved.offsetX = MHSBC.window:GetLeft()
		saved.offsetY = MHSBC.window:GetTop()
	end)
	MHSBC.window:SetDrawLayer(DL_TEXT)

	MHSBC.window.fontSize   = saved.fontSize
	MHSBC.window.iconSize   = saved.iconSize
	MHSBC.window.iconSpace  = saved.iconSpace


	-- make a container for the list entries
	MHSBC.window.entries = wm:CreateControl("MHSBCEntries", MHSBC.window, CT_CONTROL)
	MHSBC.window.entries:SetAnchor(LEFT, MHSBC.window, LEFT, 0, 0)
	MHSBC.window.entries:SetHidden(false)
	MHSBC.window.entries:SetResizeToFitDescendents(true)

	-- give it a background (backdrop)
	MHSBC.window.bg = wm:CreateControl("MHSBCBackground", MHSBC.window.entries, CT_BACKDROP)
	MHSBC.window.bg:SetAnchorFill(MHSBC.window.entries)
	MHSBC.window.bg:SetCenterColor(0, 0, 0, saved.alpha / 100)
	MHSBC.window.bg:SetEdgeColor(0, 0, 0, saved.alpha / 100)
	MHSBC.window.bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 1, 1, 0, 0)
	MHSBC.window.bg:SetInsets(-saved.fontSize*0.25, -saved.fontSize*0.25, saved.fontSize*0.25, saved.fontSize*0.25)
	MHSBC.window.bg:SetExcludeFromResizeToFitExtents(true)

	--
	MHSBC.window.entries.column1 = wm:CreateControl("MHSBCColumn1", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column1:SetAnchor(LEFT, MHSBC.window.entries, LEFT, 0, 0)
	MHSBC.window.entries.column1:SetHidden(not saved.showBags)
	MHSBC.window.entries.column1:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column1:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column1.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon1", MHSBC.window.entries.column1, CT_TEXTURE)
	MHSBC.window.entries.column1.icon :SetDimensions(MHSBC.window.iconSize, MHSBC.window.iconSize)
	MHSBC.window.entries.column1.icon :SetAnchor(LEFT, MHSBC.window.entries.column1, LEFT, 0, -MHSBC.window.iconSize*0.125)
	MHSBC.window.entries.column1.icon :SetTexture("/esoui/art/tooltips/icon_bag.dds")
	MHSBC.window.entries.column1.icon :SetHidden(not saved.showBags)

	MHSBC.window.entries.column1.label = wm:CreateControl("MHSBCColumn1Label", MHSBC.window.entries.column1.icon, CT_LABEL)
	MHSBC.window.entries.column1.label:SetAnchor(LEFT, MHSBC.window.entries.column1.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column1.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column1.label:SetColor(1, 1, 1, 1)
	local column1LastItem = MHSBC.window.entries.column1.label

	MHSBC.window.entries.column1.items = {}

	MHSBC.window.entries.column1.items = wm:CreateControl("MHSBCColumn1Item", MHSBC.window.entries.column1.label, CT_LABEL)
	MHSBC.window.entries.column1.items:SetAnchor(LEFT, column1LastItem, LEFT, 0, MHSBC.window.iconSize*0.125)
	MHSBC.window.entries.column1.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column1.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column1.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column1.items:SetText("MHSBCBag")
	column1LastItem = MHSBC.window.entries.column1.items

	--
	MHSBC.window.entries.column2 = wm:CreateControl("MHSBCColumn2", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column2:SetAnchor(LEFT, MHSBC.window.entries.column1, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column2:SetHidden(not saved.showBank)
	MHSBC.window.entries.column2:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column2:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column2.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon2", MHSBC.window.entries.column2, CT_TEXTURE)
	MHSBC.window.entries.column2.icon:SetDimensions(MHSBC.window.iconSize, MHSBC.window.iconSize)
	MHSBC.window.entries.column2.icon:SetAnchor(LEFT, MHSBC.window.entries.column2, LEFT, 0, 0)
	MHSBC.window.entries.column2.icon:SetTexture("/esoui/art/tooltips/icon_bank.dds")
	MHSBC.window.entries.column2.icon :SetHidden(not saved.showBank)

	MHSBC.window.entries.column2.label = wm:CreateControl("MHSBCColumn2Label", MHSBC.window.entries.column2.icon, CT_LABEL)
	MHSBC.window.entries.column2.label:SetAnchor(LEFT, MHSBC.window.entries.column2.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column2.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column2.label:SetColor(1, 1, 1, 1)
	local column2LastItem = MHSBC.window.entries.column2.label

	MHSBC.window.entries.column2.items = {}

	MHSBC.window.entries.column2.items = wm:CreateControl("MHSBCColumn2Item", MHSBC.window.entries.column2.label, CT_LABEL)
	MHSBC.window.entries.column2.items:SetAnchor(LEFT, column2LastItem, LEFT, saved.iconSpace*1.3, 0)
	MHSBC.window.entries.column2.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column2.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column2.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column2.items:SetText("MHSBCBank")
	column2LastItem = MHSBC.window.entries.column2.items

	--
	MHSBC.window.entries.column3 = wm:CreateControl("MHSBCColumn3", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column3:SetAnchor(LEFT, MHSBC.window.entries.column2, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column3:SetHidden(not saved.showGold)
	MHSBC.window.entries.column3:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column3:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column3.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon3", MHSBC.window.entries.column3, CT_TEXTURE)
	MHSBC.window.entries.column3.icon:SetDimensions(MHSBC.window.iconSize*0.80, MHSBC.window.iconSize*0.80)
	MHSBC.window.entries.column3.icon:SetAnchor(LEFT, MHSBC.window.entries.column3, LEFT, 0, 0)
	MHSBC.window.entries.column3.icon:SetTexture("/esoui/art/currency/currency_gold.dds")
	MHSBC.window.entries.column3.icon:SetHidden(not saved.showGold)
	MHSBC.window.entries.column3.icon:SetMouseEnabled(saved.showGold)

	MHSBC.window.entries.column3.button = wm:CreateControl("MadHoeksSatchelCoinFloatButton3", MHSBC.window.entries.column3, CT_BUTTON)
	MHSBC.window.entries.column3.button:SetDimensions(MHSBC.window.iconSize*0.90, MHSBC.window.iconSize*0.90)
	MHSBC.window.entries.column3.button:SetAnchor(LEFT, MHSBC.window.entries.column3, LEFT, 0, 0)
	MHSBC.window.entries.column3.button:SetMouseOverTexture("/esoui/art/currency/currency_gold.dds") 
	MHSBC.window.entries.column3.button:SetHidden(not saved.showGold)
	MHSBC.window.entries.column3.button:SetMouseEnabled(saved.showGold)
	MHSBC.window.entries.column3.button:SetHandler("OnClicked", MHSBC.GoldClicked)

	MHSBC.window.entries.column3.label = wm:CreateControl("MHSBCColumn3Label", MHSBC.window.entries.column3.icon, CT_LABEL)
	MHSBC.window.entries.column3.label:SetAnchor(LEFT, MHSBC.window.entries.column3.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column3.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column3.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column3.label:SetColor(1, 1, 1, 1)
	local column3LastItem = MHSBC.window.entries.column3.label

	MHSBC.window.entries.column3.items = {}

	MHSBC.window.entries.column3.items = wm:CreateControl("MHSBCColumn3Item", MHSBC.window.entries.column3.label, CT_LABEL)
	MHSBC.window.entries.column3.items:SetAnchor(LEFT, column3LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column3.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column3.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column3.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column3.items:SetText("MHSBCGold")
	column3LastItem = MHSBC.window.entries.column3.items

	--
	MHSBC.window.entries.column4 = wm:CreateControl("MHSBCcolumn4", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column4:SetAnchor(TOPLEFT, MHSBC.window.entries, BOTTOMLEFT, 0, -saved.iconSpace*1.5)
	MHSBC.window.entries.column4:SetHidden(not (saved.showCurrency and saved.showTelVar))
	MHSBC.window.entries.column4:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column4:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column4.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon4", MHSBC.window.entries.column4, CT_TEXTURE)
	MHSBC.window.entries.column4.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column4.icon:SetAnchor(LEFT, MHSBC.window.entries.column4, LEFT, 0, 0)
	MHSBC.window.entries.column4.icon:SetTexture("/esoui/art/currency/currency_telvar.dds")
	MHSBC.window.entries.column4.icon:SetHidden(not (saved.showCurrency and saved.showTelVar))

	MHSBC.window.entries.column4.label = wm:CreateControl("MHSBCcolumn4Label", MHSBC.window.entries.column4.icon, CT_LABEL)
	MHSBC.window.entries.column4.label:SetAnchor(LEFT, MHSBC.window.entries.column4.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column4.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column4.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column4.label:SetColor(1, 1, 1, 1)
	local column4LastItem = MHSBC.window.entries.column4.label

	MHSBC.window.entries.column4.items = {}

	MHSBC.window.entries.column4.items = wm:CreateControl("MHSBCcolumn4Item", MHSBC.window.entries.column4.label, CT_LABEL)
	MHSBC.window.entries.column4.items:SetAnchor(LEFT, column4LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column4.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column4.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column4.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column4.items:SetText("MHSBCTelVar")
	column4LastItem = MHSBC.window.entries.column4.items

	--
	MHSBC.window.entries.column5 = wm:CreateControl("MHSBCcolumn5", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column5:SetAnchor(LEFT, MHSBC.window.entries.column4, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column5:SetHidden(not (saved.showCurrency and saved.showAlliancePoints))
	MHSBC.window.entries.column5:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column5:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column5.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon5", MHSBC.window.entries.column5, CT_TEXTURE)
	MHSBC.window.entries.column5.icon:SetDimensions(MHSBC.window.iconSize*0.80, MHSBC.window.iconSize*0.80)
	MHSBC.window.entries.column5.icon:SetAnchor(LEFT, MHSBC.window.entries.column5, LEFT, 0, 0)
	MHSBC.window.entries.column5.icon:SetTexture("/esoui/art/currency/alliancepoints.dds")
	MHSBC.window.entries.column5.icon:SetHidden(not (saved.showCurrency and saved.showAlliancePoints))

	MHSBC.window.entries.column5.label = wm:CreateControl("MHSBCcolumn5Label", MHSBC.window.entries.column5.icon, CT_LABEL)
	MHSBC.window.entries.column5.label:SetAnchor(LEFT, MHSBC.window.entries.column5.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column5.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column5.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column5.label:SetColor(1, 1, 1, 1)
	local column5LastItem = MHSBC.window.entries.column5.label

	MHSBC.window.entries.column5.items = {}

	MHSBC.window.entries.column5.items = wm:CreateControl("MHSBCcolumn5Item", MHSBC.window.entries.column5.label, CT_LABEL)
	MHSBC.window.entries.column5.items:SetAnchor(LEFT, column5LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column5.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column5.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column5.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column5.items:SetText("MHSBCAP")
	column5LastItem = MHSBC.window.entries.column5.items

	--
	MHSBC.window.entries.column6 = wm:CreateControl("MHSBCcolumn6", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column6:SetAnchor(LEFT, MHSBC.window.entries.column5, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column6:SetHidden(not (saved.showCurrency and saved.showWritVouchers))
	MHSBC.window.entries.column6:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column6:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column6.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon6", MHSBC.window.entries.column6, CT_TEXTURE)
	MHSBC.window.entries.column6.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column6.icon:SetAnchor(LEFT, MHSBC.window.entries.column6, LEFT, 0, 0)
	MHSBC.window.entries.column6.icon:SetTexture("/esoui/art/currency/currency_writvoucher.dds")
	MHSBC.window.entries.column6.icon:SetHidden(not (saved.showCurrency and saved.showWritVouchers))

	MHSBC.window.entries.column6.label = wm:CreateControl("MHSBCcolumn6Label", MHSBC.window.entries.column6.icon, CT_LABEL)
	MHSBC.window.entries.column6.label:SetAnchor(LEFT, MHSBC.window.entries.column6.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column6.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column6.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column6.label:SetColor(1, 1, 1, 1)
	local column6LastItem = MHSBC.window.entries.column6.label

	MHSBC.window.entries.column6.items = {}

	MHSBC.window.entries.column6.items = wm:CreateControl("MHSBCcolumn6Item", MHSBC.window.entries.column6.label, CT_LABEL)
	MHSBC.window.entries.column6.items:SetAnchor(LEFT, column6LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column6.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column6.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column6.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column6.items:SetText("MHSBCWV")
	column6LastItem = MHSBC.window.entries.column6.items

	--
	MHSBC.window.entries.column7 = wm:CreateControl("MHSBCcolumn7", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column7:SetAnchor(LEFT, MHSBC.window.entries.column6, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column7:SetHidden(not (saved.showCurrency and saved.showTradeBars))
	MHSBC.window.entries.column7:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column7:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column7.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon7", MHSBC.window.entries.column7, CT_TEXTURE)
	MHSBC.window.entries.column7.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column7.icon:SetAnchor(LEFT, MHSBC.window.entries.column7, LEFT, 0, 0)
	MHSBC.window.entries.column7.icon:SetTexture("/esoui/art/currency/u49_tt_tradebars.dds")
	MHSBC.window.entries.column7.icon:SetHidden(not (saved.showCurrency and saved.showTradeBars))

	MHSBC.window.entries.column7.label = wm:CreateControl("MHSBCcolumn7Label", MHSBC.window.entries.column7.icon, CT_LABEL)
	MHSBC.window.entries.column7.label:SetAnchor(LEFT, MHSBC.window.entries.column7.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column7.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column7.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column7.label:SetColor(1, 1, 1, 1)
	local column7LastItem = MHSBC.window.entries.column7.label

	MHSBC.window.entries.column7.items = {}

	MHSBC.window.entries.column7.items = wm:CreateControl("MHSBCcolumn7Item", MHSBC.window.entries.column7.label, CT_LABEL)
	MHSBC.window.entries.column7.items:SetAnchor(LEFT, column7LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column7.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column7.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column7.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column7.items:SetText("MHSBCBars")
	column7LastItem = MHSBC.window.entries.column7.items

	--
	MHSBC.window.entries.column8 = wm:CreateControl("MHSBCcolumn8", MHSBC.window.entries, CT_CONTROL)
	MHSBC.window.entries.column8:SetAnchor(LEFT, MHSBC.window.entries.column7, RIGHT, saved.iconSize, 0)
	MHSBC.window.entries.column8:SetHidden(not (saved.showCurrency and saved.showBankGold))
	MHSBC.window.entries.column8:SetResizeToFitDescendents(true)
	MHSBC.window.entries.column8:SetResizeToFitPadding(2, 0)

	MHSBC.window.entries.column8.icon = wm:CreateControl("MadHoeksSatchelCoinFloatIcon8", MHSBC.window.entries.column8, CT_TEXTURE)
	MHSBC.window.entries.column8.icon:SetDimensions(MHSBC.window.iconSize*0.95, MHSBC.window.iconSize*0.95)
	MHSBC.window.entries.column8.icon:SetAnchor(LEFT, MHSBC.window.entries.column8, LEFT, 0, 0)
	MHSBC.window.entries.column8.icon:SetTexture("/esoui/art/currency/currency_gold.dds")
	MHSBC.window.entries.column8.icon:SetHidden(not (saved.showCurrency and saved.showBankGold))

	MHSBC.window.entries.column8.label = wm:CreateControl("MHSBCcolumn8Label", MHSBC.window.entries.column8.icon, CT_LABEL)
	MHSBC.window.entries.column8.label:SetAnchor(LEFT, MHSBC.window.entries.column8.icon, RIGHT, saved.iconSpace, 0)
	MHSBC.window.entries.column8.label:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column8.label:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column8.label:SetColor(1, 1, 1, 1)
	local column8LastItem = MHSBC.window.entries.column8.label

	MHSBC.window.entries.column8.items = {}

	MHSBC.window.entries.column8.items = wm:CreateControl("MHSBCcolumn8Item", MHSBC.window.entries.column8.label, CT_LABEL)
	MHSBC.window.entries.column8.items:SetAnchor(LEFT, column8LastItem, LEFT, saved.iconSpace*1.5, 0)
	MHSBC.window.entries.column8.items:SetFont("EsoUi/Common/Fonts/Univers57.otf|"..MHSBC.window.fontSize.."|soft-shadow-thin")
	MHSBC.window.entries.column8.items:SetColor(.9, .9, .9, 1)
	MHSBC.window.entries.column8.items:SetStyleColor(0, 0, 0, 1)
	MHSBC.window.entries.column8.items:SetText("MHSBCBankedGold")
	column8LastItem = MHSBC.window.entries.column8.items

	windowCreated = true

	--- hide the window when the compass frame gets hidden, if it's not hidden already
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) if saved.shown then MHSBC.window:SetHidden(false) end end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) if saved.shown then MHSBC.window:SetHidden(false) end end)
	end

	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) if saved.shown then MHSBC.window:SetHidden(true) end end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) if saved.shown then MHSBC.window:SetHidden(true) end end)
	end

	MHSBC.RefreshLayout()

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Refresh Window
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.RefreshWindow()

	local bagUsed, bagMax, bankUsed, bankMax, bagInfo, bankInfo, goldInfo, bankGoldInfo, telVarInfo, alliancePointsInfo, writVouchersInfo, tradeBarsInfo = MHSBC.UpdateData()
	local savedColor = MHSBC.data.savedvariables.Colors
	local saved = MHSBC.data.savedvariables

	MHSBC.window:SetMovable(not saved.locked)
	MHSBC.window:SetHidden(not saved.shown)
	
	MHSBC.window.bg:SetCenterColor(0, 0, 0, saved.alpha / 100)
	MHSBC.window.bg:SetEdgeColor(0, 0, 0, saved.alpha / 100)
	
	MHSBC.window.entries.column1:SetHidden(not saved.showBags)
	MHSBC.window.entries.column1.icon :SetHidden(not saved.showBags)
	
	MHSBC.window.entries.column2:SetHidden(not saved.showBank)
	MHSBC.window.entries.column2.icon :SetHidden(not saved.showBank)
	
	MHSBC.window.entries.column3:SetHidden(not saved.showGold)
	MHSBC.window.entries.column3.icon :SetHidden(not saved.showGold)
	-- keep gold button in sync with saved vars (important after /reloadui or relog)
	MHSBC.window.entries.column3.button:SetHidden(not saved.showGold)
	MHSBC.window.entries.column3.button:SetMouseEnabled(saved.showGold)
	MHSBC.window.entries.column3.icon:SetMouseEnabled(saved.showGold)

	local forceCurrency = not MHSBC.IsPrimaryRowVisible()
	local showCurrencyEffective = saved.showCurrency or forceCurrency

	MHSBC.window.entries.column4:SetHidden(not (showCurrencyEffective and saved.showTelVar))
	MHSBC.window.entries.column4.icon:SetHidden(not (showCurrencyEffective and saved.showTelVar))

	MHSBC.window.entries.column5:SetHidden(not (showCurrencyEffective and saved.showAlliancePoints))
	MHSBC.window.entries.column5.icon:SetHidden(not (showCurrencyEffective and saved.showAlliancePoints))

	MHSBC.window.entries.column6:SetHidden(not (showCurrencyEffective and saved.showWritVouchers))
	MHSBC.window.entries.column6.icon:SetHidden(not (showCurrencyEffective and saved.showWritVouchers))

	MHSBC.window.entries.column7:SetHidden(not (showCurrencyEffective and saved.showTradeBars))
	MHSBC.window.entries.column7.icon:SetHidden(not (showCurrencyEffective and saved.showTradeBars))

	MHSBC.window.entries.column8:SetHidden(not (showCurrencyEffective and saved.showBankGold))
	MHSBC.window.entries.column8.icon:SetHidden(not (showCurrencyEffective and saved.showBankGold))

	local anyCurrencyVisible = MHSBC.IsCurrencyRowVisibleEffective()

	if anyCurrencyVisible then
		MHSBC.window.bg:SetInsets(-saved.fontSize*0.25, saved.fontSize*0.5, saved.fontSize*0.25, saved.fontSize)
		MHSBC.window:SetClampedToScreenInsets(-saved.fontSize*0.25, saved.fontSize*0.5, saved.fontSize*0.25, saved.fontSize*0.6)
	else
		MHSBC.window.bg:SetInsets(-saved.fontSize*0.25, -saved.fontSize*0.25, saved.fontSize*0.25, saved.fontSize*0.30)
		MHSBC.window:SetClampedToScreenInsets(-saved.fontSize*0.25, -saved.fontSize*0.25, saved.fontSize*0.25, saved.fontSize*0.30)
	end

	-- Easter egg: everything disabled (all toggles off)
	if MHSBC.IsEverythingDisabled() then
		if not MHSBC._invisibleEasterShown then
			MHSBC._invisibleEasterShown = true

			local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
			params:SetText(GetString(MHSBC_EASTER_VOID))
			params:SetSound(SOUNDS.ABILITY_SKILL_UP)
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
		end
	end

	-- default text colors
	MHSBC.window.entries.column1.items:SetColor(savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A)
	MHSBC.window.entries.column2.items:SetColor(savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A)

	-- new text colors based on free space remaining
	-- Bag
	if (bagUsed == bagMax) then 
		MHSBC.window.entries.column1.items:SetColor(savedColor.full_R, savedColor.full_G, savedColor.full_B, savedColor.full_A)
	elseif (bagUsed >= (bagMax - saved.bagWarning)) then
		MHSBC.window.entries.column1.items:SetColor(savedColor.warn_R, savedColor.warn_G, savedColor.warn_B, savedColor.warn_A)
	else
		MHSBC.window.entries.column1.items:SetColor(savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A)
	end
	-- new text colors based on free space remaining
	-- Bank
	if (bankUsed >= bankMax) then
		MHSBC.window.entries.column2.items:SetColor(savedColor.full_R, savedColor.full_G, savedColor.full_B, savedColor.full_A)
	elseif (bankUsed >= (bankMax - saved.bankWarning)) then
		MHSBC.window.entries.column2.items:SetColor(savedColor.warn_R, savedColor.warn_G, savedColor.warn_B, savedColor.warn_A)
	else
		MHSBC.window.entries.column2.items:SetColor(savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A)
	end

	-- set text (Bagspace, Bankspace, Gold and the rest of the currencies)
	MHSBC.window.entries.column1.items:SetText(bagInfo)
	MHSBC.window.entries.column2.items:SetText(bankInfo)
	MHSBC.window.entries.column3.items:SetText(goldInfo)
	MHSBC.window.entries.column4.items:SetText(telVarInfo)
	MHSBC.window.entries.column5.items:SetText(alliancePointsInfo)
	MHSBC.window.entries.column6.items:SetText(writVouchersInfo)
	MHSBC.window.entries.column7.items:SetText(tradeBarsInfo)
	MHSBC.window.entries.column8.items:SetText(bankGoldInfo)

	MHSBC.window:SetHidden(ZO_CompassFrame:IsHidden() or not saved.shown)

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Collect Data
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.UpdateData()

	-- h5. Bag
	-- * BAG_BACKPACK
	-- * BAG_BANK
	-- * BAG_BUYBACK
	-- * BAG_COMPANION_WORN
	-- * BAG_FURNITURE_VAULT
	-- * BAG_GUILDBANK
	-- * BAG_HOUSE_BANK_EIGHT
	-- * BAG_HOUSE_BANK_FIVE
	-- * BAG_HOUSE_BANK_FOUR
	-- * BAG_HOUSE_BANK_NINE
	-- * BAG_HOUSE_BANK_ONE
	-- * BAG_HOUSE_BANK_SEVEN
	-- * BAG_HOUSE_BANK_SIX
	-- * BAG_HOUSE_BANK_TEN
	-- * BAG_HOUSE_BANK_THREE
	-- * BAG_HOUSE_BANK_TWO
	-- * BAG_SUBSCRIBER_BANK
	-- * BAG_VENGEANCE
	-- * BAG_VIRTUAL
	-- * BAG_WORN

	-- h5. CurrencyLocation
	-- * CURRENCY_LOCATION_ACCOUNT
	-- * CURRENCY_LOCATION_BANK
	-- * CURRENCY_LOCATION_CHARACTER
	-- * CURRENCY_LOCATION_GUILD_BANK

--	h5. CurrencyType
--	* CURT_ALLIANCE_POINTS
--	* CURT_ARCHIVAL_FORTUNES
--	* CURT_CROWNS
--	* CURT_CROWN_GEMS
--	* CURT_IMPERIAL_FRAGMENTS
--	* CURT_MONEY
--	* CURT_NONE
--	* CURT_SEALS
--	* CURT_STYLE_STONES
--	* CURT_TELVAR_STONES
--	* CURT_TOME_CHALLENGE_REROLLS
--	* CURT_TOME_POINTS
--	* CURT_TOME_POINT_CACHES
--	* CURT_TOME_TOKENS
--	* CURT_TRADE_BARS
--	* CURT_TRANSMUTE_CRYSTALS
--	* CURT_UNDAUNTED_KEYS
--	* CURT_WRIT_VOUCHERS

	local GetBagSize = GetBagSize
	local GetNumBagUsedSlots = GetNumBagUsedSlots
	local GetNumBagFreeSlots = GetNumBagFreeSlots
	local GetBagUseableSize = GetBagUseableSize
	local GetCurrentMoney = GetCurrentMoney
	local GetCarriedCurrencyAmount = GetCarriedCurrencyAmount
	local GetCurrencyAmount = GetCurrencyAmount
	local GetMaxPossibleCurrency = GetMaxPossibleCurrency

	local bagid = BAG_BACKPACK
	local bankid = BAG_BANK
	local subbankid = BAG_SUBSCRIBER_BANK

	local gold = GetCurrentMoney()
	local goldfmt = FormatIntegerWithDigitGrouping(gold,",",3);

	local telVarStones = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local telVarfmt = FormatIntegerWithDigitGrouping(telVarStones,",",3);
	local alliancePoints = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	local alliancePointfmt = FormatIntegerWithDigitGrouping(alliancePoints,",",3);
	local writVouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
	local writVoucherfmt = FormatIntegerWithDigitGrouping(writVouchers,",",3);
	local tradeBars = GetCurrencyAmount(CURT_TRADE_BARS, CURRENCY_LOCATION_ACCOUNT)
	local tradeBarsfmt = FormatIntegerWithDigitGrouping(tradeBars,",",3);
	local bankGold  = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
	local bankGoldfmt = FormatIntegerWithDigitGrouping(bankGold,",",3);

	-- Currency Colors
	local colorGold     = "|cffff24"
	local colorTelVar 	= "|c769ae4"
	local colorAP       = "|c53ca56"
	local colorWrit     = "|cffff90"

	-- normal bag
	MHSBC.data.bag = {}
	MHSBC.data.bag.id = bagid
	MHSBC.data.bag.maximum = GetBagSize(bagid)
	MHSBC.data.bag.used = GetNumBagUsedSlots(bagid)
	MHSBC.data.bag.available = GetNumBagFreeSlots(bagid)
	MHSBC.data.bag.usable = GetBagUseableSize(bagid)

	-- normal bank
	MHSBC.data.bank = {}
	MHSBC.data.bank.id = bankid
	MHSBC.data.bank.maximum=GetBagSize(bankid)
	MHSBC.data.bank.used=GetNumBagUsedSlots(bankid)
	MHSBC.data.bank.usable = GetBagUseableSize(bankid)
	MHSBC.data.bank.available = MHSBC.data.bank.usable - MHSBC.data.bank.used

	-- subscriber bank
	MHSBC.data.subscriber = {}
	MHSBC.data.subscriber.id = subbankid
	MHSBC.data.subscriber.maximum = GetBagSize(subbankid)
	MHSBC.data.subscriber.used = GetNumBagUsedSlots(subbankid)
	MHSBC.data.subscriber.usable = GetBagUseableSize(subbankid)
	MHSBC.data.subscriber.available = MHSBC.data.subscriber.usable - MHSBC.data.subscriber.used

	-- total Bag
	local bagMax = MHSBC.data.bag.maximum
	local bagUsed = MHSBC.data.bag.used

	-- total bank  
	local bankMax = MHSBC.data.bank.maximum + MHSBC.data.subscriber.usable
	MHSBC.data.bankMax = bankMax
	MHSBC.data.bankUsed = MHSBC.data.bank.used + MHSBC.data.subscriber.used
	local bankUsed = MHSBC.data.bankUsed

	-- text for the HUD window
	local goldInfo = colorGold..goldfmt.."g"
	local telVarInfo = string.format("%s%s %s", colorTelVar, telVarfmt, GetString(MHSBC_CURRENCY_TELVAR))
	local alliancePointsInfo = string.format("%s%s %s", colorAP, alliancePointfmt, GetString(MHSBC_CURRENCY_AP))
	local writVouchersInfo = string.format("%s%s %s", colorWrit, writVoucherfmt, GetString(MHSBC_CURRENCY_WRIT))
	local tradeBarsInfo = string.format("%s%s %s", colorGold, tradeBarsfmt, GetString(MHSBC_CURRENCY_BARS))
	local bankGoldInfo = string.format("%s%s %s", colorGold, bankGoldfmt.."g", GetString(MHSBC_CURRENCY_BANKGOLD))
	local bagInfo = bagUsed.." / "..bagMax
	local bankInfo = bankUsed.." / "..bankMax

	return 	bagUsed, bagMax, bankUsed, bankMax, bagInfo, bankInfo, goldInfo, bankGoldInfo, telVarInfo, alliancePointsInfo, writVouchersInfo, tradeBarsInfo
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Window Functions 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.HideMHSBC()
	MHSBC.data.savedvariables.shown = false
	MHSBC.window:SetHidden(true)
end

function MHSBC.ShowMHSBC()
	MHSBC.data.savedvariables.shown = true
	MHSBC.window:SetHidden(false)
end

function MHSBC.LockMHSBC()
	MHSBC.data.savedvariables.locked = true
	MHSBC.window:SetMovable(not MHSBC.data.savedvariables.locked)
end

function MHSBC.UnlockMHSBC()
	MHSBC.data.savedvariables.locked = false
	MHSBC.window:SetMovable(not MHSBC.data.savedvariables.locked)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Window Toggles
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Toggle window visible
function MHSBC.ToggleMHSBCWindow()
	if MHSBC.data.savedvariables.shown == false then
			MHSBC.ShowMHSBC()
			MHSBC.data.savedvariables.shown = true
		elseif MHSBC.data.savedvariables.shown == true then
			MHSBC.HideMHSBC()
			MHSBC.data.savedvariables.shown = false
	end
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHSBC.SettingsPanel)
end

-- Toggle window locked
function MHSBC.ToggleMHSBCMovable()
	if MHSBC.data.savedvariables.locked == true then
			MHSBC.UnlockMHSBC()
			MHSBC.data.savedvariables.locked = false
		elseif MHSBC.data.savedvariables.locked == false then
			MHSBC.LockMHSBC()
			MHSBC.data.savedvariables.locked = true
	end
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHSBC.SettingsPanel)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Set Default Colors
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function that will restore the default Colors
function MHSBC.SetDefaultColors()

	local savedColor = MHSBC.data.savedvariables.Colors
	local defaultColor = MHSBC.data.default.Colors

	-- Normal Color
	savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A
	=
	defaultColor.normal_R, defaultColor.normal_G, defaultColor.normal_B, defaultColor.normal_A

	-- Warning Color
	savedColor.warn_R, savedColor.warn_G, savedColor.warn_B, savedColor.warn_A
	=
	defaultColor.warn_R, defaultColor.warn_G, defaultColor.warn_B, defaultColor.warn_A

	-- Full Color
	savedColor.full_R, savedColor.full_G, savedColor.full_B, savedColor.full_A
	=
	defaultColor.full_R, defaultColor.full_G, defaultColor.full_B, defaultColor.full_A

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Keybinds & SlashCommands
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
function MHSBC.InitializeControls()

	-- String for keybind
	GetString(SI_BINDING_NAME_MHSBC_WINDOW_TOGGLE)
	GetString(SI_BINDING_NAME_MHSBC_WINDOW_MOVABLE)
	-- SLASH COMMANDS --Toggle (show/hide & lock/unlock)
	SLASH_COMMANDS["/mhsbcv"] = MHSBC.ToggleMHSBCWindow
	SLASH_COMMANDS["/mhsbcm"] = MHSBC.ToggleMHSBCMovable

end