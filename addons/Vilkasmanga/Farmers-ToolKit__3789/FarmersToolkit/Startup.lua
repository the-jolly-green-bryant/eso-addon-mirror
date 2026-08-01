
-- First and foremost, we create a (local) namespace for the addon by declaring a top-level 
-- table that will hold everything else. Hopefully.
-- Note: "local FarmersToolkit" is an exception case to scoping, "local" redundant  - tnx Dolgubon

-- This is now moved to the first loaded file, currently Hints.lua
-- Invoking it here just wipes out whatever we did in Hints.lua
-- FarmersToolkit = {}
FarmersToolkit = FarmersToolkit or {}


-- As of 3/1/2025, EOS is remving vast amounts of endeavor-related functionality.
-- This will impact the FTK addon quite a bit and possibly lead to its withdrawal.
-- Before taking that step, an interim version of FTK will be attempted, one which
-- simply(?) tried to block out the now- or soon-to-be-irrelevant code.
-- Once we're thrugh the surge of changes and insulated via the flag below, 
-- FTK will get a massive code cleanup.  Or be withdrawn, we'll see.

-- Pass 1: Nullify all affected routines (Have them return null/0/etc.)
-- Pass 2: Clean up UI to not have references on screen
-- Pass 3: Remove related functions
-- Pass 4: Remove related variables (if they somehow survived the Pass 3 purge)
-- Pass 5: Clean up "help" screen / documentation
-- Pass 6: Assess code changes, determine if FTK is still value add
-- Pass 7: GO / NO-GO 

FarmersToolkit.SE_Flag = true -- If true, skip the endeavor code


-- Preface (most) chat output with these strings (one for chat, one for chat w/ FT_DBFLAG on)
FarmersToolkit.FTChat = "|cFFFF00FT: "
FarmersToolkit.FTChat_debug = "FT (Debug): "

-- Let's have a internal, not terribly documented variable called FarmersToolkit.FT_DBFLAG to help
-- with debugging but not clutter up every single screen / output
-- By default, is off (0) but could theoretically be turned on
-- via: /script FarmersToolkit.FT_DBFLAG=1 (or /ftdebug1 vs /ftdebug0)
FarmersToolkit.FT_DBFLAG=0;

-- Ok, let's start building out some structure.....
-- Define / Set total farmed variables to 0 (might be reset below)
FarmersToolkit.tvalue=0

-- Place holder for scoping, variables / functions to be defined below
	       
-- FarmersToolkit.OpenSettingsPanel = function()
-- 	d("This will be replaced")
-- end

-- Misc variables that will be more fully populated below
--

  FarmersToolkit.savedVariables = {}  -- Std "safe between session" variable set
  local LinkID -- This is used at various locations below, likely needs some cleanup
  FarmersToolkit.LastBook = "" -- This is used to see if we're reading the same book again and again
  FarmersToolkit.FPetList = {} -- This is used at various locations below, likely needs some cleanup
  FarmersToolkit.savedVariables.FPetList = {} -- For saving out identified FPetList entries

-- Post a reminder every FarmersToolkit.ReminderCount items
-- (This variable has a troubled history and should not default to 99 except for new users)
FarmersToolkit.ReminderCount=99;
FarmersToolkit.PetFrequencyCount=66;
FarmersToolkit.EndeavorWarningThreshhold=3;
FarmersToolkit.PTarget=800;

-- Trying something new here..., play a sound when certain things are found
-- Yes, I could build an array indexed by part # and just do a single
-- line look up except lua tables are stupid and I don't like them. Yet.
-- So, keep this list short, we'll spin through it on every item pickup.
-- For now.
--
-- This is in test and may die here.  I like the idea of rewarding the player for finding certain items
-- but I don't have a good way for them to "load" the list (which uses FarmersToolkit.TargetItemID which no one should
-- know off the top of their head.  I don't know how to make this a nice user-enterable item just yet.
-- However, this would also lay the foundation for setting "targets" for farmed items.  That is,
-- play sound XYZ whenever the player farms NNN of item ABC...
--
-- Update (n+1): This idea has taken root and now expanded to support a targetted "shopping list"
-- in which players can set a target value for a given item and FTK will track their progress
-- (now both in chat and on screen, see TIDCount and TIDName below.
--    As a result, the original "reward code" should be folded into the TID code.  Real Soon Now.

FarmersToolkit.TargetItemID = {}
table.insert(FarmersToolkit.TargetItemID,77591) -- Mudcrab Chitin
table.insert(FarmersToolkit.TargetItemID,775585) -- Butterfly Wing

-- -- if ( 1 > 2 ) then
-- -- -- I am tired of trying to remember where stuff is for dailies.
-- -- -- This is an attempt to fix that. We'll see how this goes...
-- -- FarmersToolkit.Hints = {}
-- -- FarmersToolkit.Hints["air atronach"]="Craglorn > SpellScar WS > Spellscar (North of WS)";
-- -- FarmersToolkit.Hints["amorphous foes 1"]="Stonefalls >  Othrenis WS > Most anywhere you see netches (bull or otherwise)";
-- -- FarmersToolkit.Hints["amorphous foes 2"]="Bal Foyen >  Most anywhere you see netches (bull or otherwise)";
-- -- FarmersToolkit.Hints["amorphous foes 3"]="West Weald >  Trader's Luck WS (SE) > Silon Mirrormoor Incursion to the east";
-- -- FarmersToolkit.Hints["barbaric foes"]="Stormhaven >  Pariah Abbey WS (middle) > Stonechewer Goblin Camp (SSW)";
-- -- FarmersToolkit.Hints["dwarven automata"]="Deshaan >  Muth Gnaar Hills WS > Lower Bthanual (delve)";
-- -- FarmersToolkit.Hints["flame atronach 1"]="Vvardenfell >  Ahld'run WS > Moongrave Fane dungeon";
-- -- FarmersToolkit.Hints["flame atronach 2"]="Reaper's March >  Willowgrove WS > South of Willowgrove";
-- -- FarmersToolkit.Hints["flesh atronach"]="MalabTor > BloodToil WS > Abamath Ruins";
-- -- FarmersToolkit.Hints["frost atronach 1"]="Craglorn > SpellScar WS > Spellscar (North of WS)";
-- -- FarmersToolkit.Hints["frost atronach 2"]="Reaper's March >  Willowgrove WS > South of Willowgrove";
-- -- FarmersToolkit.Hints["ghosts"]="Auridon >  Tanzelwil WS > Tanzelwil Ruins";
-- -- FarmersToolkit.Hints["human daedra"]="Coldharbor> Library of Dusk Wayshrine > Library of Dusk";
-- -- FarmersToolkit.Hints["iron atronach"]="The Deadlands > Wounded Crossing WS > Lava pit S of WS";
-- -- 
-- -- FarmersToolkit.Hints["skeletons"]="Northern Elsweyr >  Riverhold WS > Defense Force Outpost (directly south)";
-- -- FarmersToolkit.Hints["stone atronach"]="Northern Elsweyr >  Scar's End WS > Moongrave Fane dungeon";
-- -- FarmersToolkit.Hints["storm atronach"]="Reaper's March >  Willowgrove WS > South of Willowgrove";
-- -- FarmersToolkit.Hints["undead foes"]="Northern Elsweyr >  Riverhold WS > Defense Force Outpost (directly south)";
-- -- 
-- -- FarmersToolkit.Hints["watery foes 1"]="Craglorn >  Shada's Tear WS > Lake to the northwest (donut lake)";
-- -- FarmersToolkit.Hints["watery foes 2"]="Greenshade > Serpents Grotto WS > Rootwatch Tower (wisps count)";
-- -- 
-- -- end
-- -- -- Remove this one we confirm the Hints.lua file is being read correctly




-- Expanding on the TargetItemID idea from above, enable setting target counts for listed items in TargtItemIDCounts 
-- (The idea being you can set a target number of item # to collect per session.)
--     If the TIDCount is 0, celebrate every time (keeping original functionality)
--     If TIDCount is > 0, then it is a farming goal and should be tracked / reported / celebrated
--     If nothing should happen with respect to this item, it shouldn't be listed in the TIDCount
FarmersToolkit.TIDCount = {}
-- Prepopulate the list with one "celebration" example (mudcrab) and one "shopping" example (wings)
FarmersToolkit.TIDCount[77591]=0; -- Mudcrab Chitin
-- FarmersToolkit.TIDCount[77585]=4; -- Butterfly Wing -- If you put a value of 4 here, it will start with a target of 4
FarmersToolkit.TIDCount[77585]=0; -- Butterfly Wing

-- Load in type tracking variables
FarmersToolkit.TargetTypeCount = {}
FarmersToolkit.TargetTypeSoFar = {}

-- FarmersToolkit.TargetTypeCount["Herb"] = 20; FarmersToolkit.TargetTypeSoFar["Herb"]=0;
-- FarmersToolkit.TargetTypeCount["Potion Solvent"] = 20; FarmersToolkit.TargetTypeSoFar["Potion Solvent"]=0;

-- Complement to TID Count is the name (full link) by item #
FarmersToolkit.TIDName = {}
FarmersToolkit.TIDName[77591]="|H0:item:77591:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"; -- Mudcrab Chitin
FarmersToolkit.TIDName[77585]="|H0:item:77585:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"; -- Butterfly Wing

-- For the XP Tracker, I am not sure where to find a text representation of the reasons so will build it here
FarmersToolkit.XP_Reason = {}

FarmersToolkit.XP_Reason[0]="Killed or asssited in a kill"
FarmersToolkit.XP_Reason[1]="Quest XP";
FarmersToolkit.XP_Reason[2]="Completed a quest or POI (point of interest)"
FarmersToolkit.XP_Reason[3]="Discovered a POI (point of interest)"
FarmersToolkit.XP_Reason[4]="Command (no further info)"
FarmersToolkit.XP_Reason[5]="Keep reward (Called periodically for defending a keep)"
FarmersToolkit.XP_Reason[6]="Battleground efforts"
FarmersToolkit.XP_Reason[7]="Scripted event (Example: Daedric Ambush)"
FarmersToolkit.XP_Reason[8]="You won a medal"
FarmersToolkit.XP_Reason[9]="Progress in finesse (no further info)"
FarmersToolkit.XP_Reason[10]="Progress in picking locks (Called when unlocking a chest)"
FarmersToolkit.XP_Reason[11]="Collected a book";
FarmersToolkit.XP_Reason[12]="Collected a skill book"
FarmersToolkit.XP_Reason[13]="XP-generating action (no further info)"
FarmersToolkit.XP_Reason[14]="Skill related to Guild rep (no further info)"
FarmersToolkit.XP_Reason[15]="Skill related to AVA (no further info)"
FarmersToolkit.XP_Reason[16]="Skill related to trade skills (no further info)"
FarmersToolkit.XP_Reason[17]="XP as a reward"
FarmersToolkit.XP_Reason[18]="Achievement in trade skills"
FarmersToolkit.XP_Reason[19]="Achievement in trade skills quest"
FarmersToolkit.XP_Reason[20]="Trade skill consume (no further info)"
FarmersToolkit.XP_Reason[21]="Progress in trade skill harvesting (no further info)"
FarmersToolkit.XP_Reason[22]="Progress in trade skill recipes (no further info)"
FarmersToolkit.XP_Reason[23]="Progress in tradeskill trait work (no further info)";
FarmersToolkit.XP_Reason[24]="Overland Boss Kill (no further info)" 




-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
-- (Yes, in hindsight, something shorter like FTK would have been nice.  It is on the "cleanup" parking lot list :)
FarmersToolkit.name = "FarmersToolkit"

-- FarmersToolkit.FTVersion = "1.0-240329i" -- Internal reference only, not tied to the official LUA versioning
-- FarmersToolkit.FTVersion = "1.0-2400407j" -- Internal reference only, not tied to the official LUA versioning
-- FarmersToolkit.FTVersion = "1.0-240329ibeta" -- Internal reference only, not tied to the official LUA versioningA
-- FarmersToolkit.FTVersion = "1.0-240424j" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-240517k" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-240609l" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-240613m" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-240714n" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-240803o" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-2501415-R" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-2501415-R2" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-250526-S" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.0-250602-T" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.260115-U" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
-- FarmersToolkit.FTVersion = "1.260302-V" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI
FarmersToolkit.FTVersion = "1.260302-V2" -- Internal reference only, loosely tied to the official LUA versioning on ESOUI


--
-- Startup message.  Code commented out until better option to call is understood (suggestion per Dolgubon and Baertram)
-- zo_callLater(function() d(FarmersToolkit.FTChat .. "Hello Tamriel 2.2a!")                               end, 5000)
-- zo_callLater(function() d(FarmersToolkit.FTChat .. "|c00CC00 " .. FarmersToolkit.FTVersion .." Online|r - Use '/ft help' for more info")                end, 9000)

-- ----------------------------------------------------------------------------------------------------
--  This is a series of utils and functions - we should move this to different file (once we know how)
-- ----------------------------------------------------------------------------------------------------

-- ############# Start of Utilities and subroutines (functions)




--
-- This is just an internal handler for d("Chat...") to streamline the format and obey FarmersToolkit.FTREP
--
-- Now that I've written it, I realize this needs to be more nuanced.  You don't want to turn
-- off EVERYTHING going to chat, maybe just the reporting aspect (which is what this started out as...)
-- Also, we needed a method for handling debug statements (see FarmersToolkit.FT_DBFLAG discussion).  
-- so we know have:
--      - dft("blah") 		-- i.e.,  d for Farmers Toolkit
--      - dft_debug("blah") 	-- i.e.,  d for Farmers Toolkit if FT_DBFLAG is set (control debugging output)
--      - SetDebug(boolean) 	-- Control setting of FT_DBFLAG 
--


-- Internal version of d(....) which may just stay a simple yes/no per FTREP.  We shall see.
-- Change history 
-- 	- Improved dft per Baertram's suggestion (Thank you!)
--	- Changed buffering approach.
-- 	   So the previous dft version worked but there was a buffering probelm whe n sending large (10+ lines) 
-- 	   messages to the buffer.  It would get there but to see it, the user had to resize or change (cause a
-- 	   redraw) of the chat window.  This was ultimately (and hopefully correctly) traced back to the raising 
-- 	   of the TKG tab (if availab,le) before writing, which was nice but not required.  This new version
-- 	   (hopefully) writes to the TKF if available but without raising TKF in the process.  We shall see.

local function dft(line)
    if FarmersToolkit.FTREP ~= 1 then return end

    -- Ensure we know which tab index is the FTK tab (if it exists)
    if FarmersToolkit.FTK_Channel == nil then
        FarmersToolkit.FTK_Channel = FarmersToolkit.GetFTKChannelIndex()
    end

    local ChatSys = CHAT_SYSTEM
    local container = ChatSys and ChatSys.primaryContainer
    if not container then
        d("FTK: No chat container")
        return
    end

    local msg = FarmersToolkit.FTChat .. tostring(line)

    -- Prefer: write directly to the FTK tab buffer if it exists
    local tabIndex = FarmersToolkit.FTK_Channel
    if tabIndex
        and container.windows
        and container.windows[tabIndex]
        and container.windows[tabIndex].buffer
    then
        local buf = container.windows[tabIndex].buffer
        buf:AddMessage(msg)
        if buf.ShowLastEntry then
            buf:ShowLastEntry()
        end
        return
    end

    -- Fallback: write to the current buffer
    local buf = container.currentBuffer
    if buf and buf.AddMessage then
        buf:AddMessage(msg)
        if buf.ShowLastEntry then
            buf:ShowLastEntry()
        end
        return
    end

    -- Last resort
    d(msg)
end  -- function dft



-- Similar to dft, this is an internal version of d(....) which handles debugging statements
-- This function's output is controlled by FT_DBFLAG (and ignores FTREP)
local function dft_debug(line) 
    if ( ( FarmersToolkit.FT_DBFLAG == 1 ) and (type(line) ~= nil) )  then
	    	d(FarmersToolkit.FTChat_debug .. line);
    end
end  -- function dft
-- With that in mind, let's start off with an unpublished function (/ftdebug1, /ftdebug2) to toggle debugging statements
-- 
function FarmersToolkit.SetDebug(arg1)

	d(FarmersToolkit.FTChat .. "Debug called with: [" .. arg1 .. "]")
	d(FarmersToolkit.FTChat .. "FT_DBFLAG = [" .. type(FarmersToolkit.FT_DBFLAG) .. "]")
	if not FarmersToolkit.FT_DBFLAG then -- If the FT_DBFLAG variable exists....
		if not arg1 then -- If the arg1 variable exists....
			FarmersToolkit.FT_DBFLAG=arg1
		else 
			d("FT-SetDebug: arg1 is not defined");
		end
	else 
			d("FT-SetDebug: FT_DBFLAG was not defined");
			FarmersToolkit.FT_DBFLAG=arg1;
	end
	d(FarmersToolkit.FTChat .. "Debug returning with DBFLAG = [" .. FarmersToolkit.FT_DBFLAG .. "] at " .. os.date("%m/%d/%Y - %H:%M.%S"))
end

-- Now make this available to other files / scopes
FarmersToolkit.dft = dft
FarmersToolkit.dft_debug = dft_debug


-- Temporarily hide both screens (useful when at the bank, in stores, crafting, etc.)
function FarmersToolkit.TempHide_Shrink()

	FTAddonIndicator2:SetHidden(true)
	FTAddonIndicator:SetHidden(true)
        FarmersToolkit.UpdateFarmlist();

end -- FarmersToolkit.TempHide_Shrink


function FarmersToolkit.TempHide_Restore()
	FTAddonIndicator:SetHidden(FarmersToolkit.FTHide)
	FTAddonIndicator2:SetHidden(FarmersToolkit.FTHide2)
        FarmersToolkit.UpdateFarmlist();

end -- FarmersToolkit.TempHide_Restore

-- Temporarily hide just the Farmers LIst screen (useful when at the bank, in stores, crafting, etc.)
function FarmersToolkit.TempHide_ShrinkFL()

	FTAddonIndicator2:SetHidden(true)
	-- FTAddonIndicator:SetHidden(true)
        FarmersToolkit.UpdateFarmlist();

end -- FarmersToolkit.TempHide_ShrinkFL


function FarmersToolkit.TempHide_RestoreFL()

	FTAddonIndicator2:SetHidden(FarmersToolkit.FTHide2)
	-- FTAddonIndicator2:SetHidden(false)
	-- FTAddonIndicator:SetHidden(false)
	
        FarmersToolkit.UpdateFarmlist();

end -- FarmersToolkit.TempHide_RestoreFL

-- Attempt to change the background of some of the onscreen windows
function FarmersToolkit.SetBackgroundColor(control, r, g, b, a)
    control:SetCenterColor(r, g, b, a)
    control:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_bg_edge.dds", 16, 16)
    control:SetEdgeColor(0, 0, 0, 1)
end

-- Create a backdrop structure
-- Function to create and set the backdrop
function FarmersToolkit.CreateBackdrop(parent, backdropName, r, g, b, a)
    local backdrop = WINDOW_MANAGER:CreateControl(backdropName, parent, CT_BACKDROP)
    backdrop:SetAnchorFill(parent)
    backdrop:SetCenterColor(r, g, b, a)
    -- backdrop:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_bg_edge.dds", 16, 16)
    backdrop:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_bg_edge.dds", 4, 4)
    backdrop:SetEdgeColor(0, 0, 0, 1)
    -- I was trying to do a CSS-like padding thing here but... not successful yet
    -- backdrop:SetInsets(-10, -10, -10, -10)
    return backdrop
end

-- Control whether backdrops are shown or not

function FarmersToolkit.ResetPanelPositions(attempt)
    attempt = attempt or 1

    -- Wait until controls exist and are valid UI controls
    if not (FTAddonIndicator and FTAddonIndicator.ClearAnchors and 
            FTAddonIndicator2 and FTAddonIndicator2.ClearAnchors and 
            FTAddonIndicator2.SetAnchor) then
        if attempt <= 5 then
            dft("|cFFFF00FTK: UI not ready yet, retrying reset... (attempt " .. attempt .. ")|r")
            zo_callLater(function()
                FarmersToolkit.ResetPanelPositions(attempt + 1)
            end, 250)
        else
            dft("|cFF0000FTK: Could not reset panels (controls never became valid).|r")
        end
        return
    end

    -- Reset main inventory/dailies panel (left side)
    FTAddonIndicator:ClearAnchors()
    FTAddonIndicator:SetAnchor(TOP, GuiRoot, TOP, 0, 50)

    -- Reset farming/shopping list panel (right side, mirrored horizontally)
    -- FTAddonIndicator2:ClearAnchors()
    -- local leftOffset = (FTAddonIndicator.GetLeft and FTAddonIndicator:GetLeft()) or 0
    -- if FTAddonIndicator2.SetAnchor then
        -- FTAddonIndicator2:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -leftOffset, 50)
    -- else
        -- dft("|cFF0000FTK: Farming panel exists but cannot be moved yet.|r")
    -- end


	FTAddonIndicator2:ClearAnchors()
    	FTAddonIndicator2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 950, 50) -- pick an explicit default you like

    	-- Persist the new locations
    	if FarmersToolkit.savedVariables then
        	FarmersToolkit.OnIndicatorMoveStop()
        	FarmersToolkit.OnIndicatorMoveStop2()
    	end

    dft("|c00FF00Inventory and farming displays reset.|r")
end



-- Function to determine whether an item can be sold (there are a suprising number fo checks for this?)
function FarmersToolkit.CanAuctionItem(bagId, slotIndex)

    local debugflag=false;

    -- if (slotIndex == 176 ) then debugflag=true; end
    -- if (slotIndex == 20 ) then debugflag=true; end

    -- Check item's locked state
    local icon, stack, sellPrice, meetsUsageRequirement, ItemLocked, equipType, itemStyleId, quality = GetItemInfo(BAG_BACKPACK, slotIndex)
    local alink  = GetItemLink(bagId, slotIndex)

    -- Check if the item is locked
    local isLocked = IsItemPlayerLocked(bagId, slotIndex)
    
    -- Check if the item is bound
    local isBound = IsItemBound(bagId, slotIndex)

    -- Check if the item is stolen
    local isStolen = IsItemStolen(bagId, slotIndex)

    -- Check if the item can be sold to a vendor
    local canBeSold = not IsItemBound(bagId, slotIndex) and not IsItemStolen(bagId, slotIndex) and not IsItemPlayerLocked(bagId, slotIndex)


   if debugflag == true and alink then

	 d("== For item: " .. alink);
	 d(zo_strformat("ItemLocked is: <<1>>", ItemLocked and "true" or "false"))
	 d(zo_strformat("isLocked is: <<1>>", isLocked and "true" or "false"))
	 d(zo_strformat("isBound is: <<1>>", isBound and "true" or "false"))
	 d(zo_strformat("isStolen is: <<1>>", isStolen and "true" or "false"))
	 d(zo_strformat("canBeSold is: <<1>>", canBeSold and "true" or "false"))
  end



    -- Combine all conditions to determine if the item can be sold
    if not isLocked and not isBound and not isStolen and not ItemLocked and canBeSold then
	-- d("CAI: returning true");
        return true
    else
	-- d("CAI: returning false");
        return false
    end





end


-- Function to toggle the visibility of the backdrop
function FarmersToolkit.SetBackdrop(controlName, value)

	local avalue=true;
	if ( value=="hide") then avalue=true; end -- hide = hide = true-hide
	if ( value=="show") then avalue=false; end -- show = do not hide = false-hide

	if ( controlName == "dailyBD") then 
		if not FTAddonIndicatorLabelBackdrop2 then DelayedInit() end
		FTAddonIndicatorLabelBackdrop2:SetHidden(avalue) 
	end
	if ( controlName == "farmingBD") then 
		if not FTAddonIndicator2Farmlist2Backdrop then DelayedInit() end
		FTAddonIndicator2Farmlist2Backdrop:SetHidden(avalue) 
	end


end   -- Function to toggle the visibility of the backdrop

-- Define a delayed equivalent of the OnAddonLoaded function
function FarmersToolkit.DelayedInit()

        local Panel1List = FTAddonIndicatorLabel
        local Panel1List2 = FTAddonIndicatorLabel2

        local farmList = FTAddonIndicator2Farmlist
        local farmList2 = FTAddonIndicator2Farmlist2

	local avalue=true;

        if Panel1List then
	    FarmersToolkit.CreateBackdrop(Panel1List, "FTAddonIndicatorLabelBackdrop2", 0.3, 0.3, 0.7, 0.6)
            -- d("Label background color set")
		if ( FarmersToolkit.dailyBD ) then avalue=not FarmersToolkit.dailyBD; end
		FTAddonIndicatorLabelBackdrop2:SetHidden(avalue) 
        else
            d("FTK Error: FTAddonIndicatorPanelist1List2 is nil")
        end


	
        if farmList2 then
	    avalue=true;
	    FarmersToolkit.CreateBackdrop(farmList2, "FTAddonIndicator2Farmlist2Backdrop", 0.3, 0.3, 0.3, 0.7)
	    -- FarmersToolkit.SetLabelPadding(farmList2, 10, 10, 10, 10)  -- Set padding as needed
            -- d("farmList2 background color set")
		if ( FarmersToolkit.farmingBD ) then avalue=not FarmersToolkit.farmingBD; end
		FTAddonIndicator2Farmlist2Backdrop:SetHidden(avalue) 
        else
            d("FTK Error: FTAddonIndicator2Farmlist2 is nil")
        end

	
end
	

-- Internal version of d(....) which may just stay a simple yes/no per FTREP.  We shall see.
-- local function dft(line) 
--     if ( ( FarmersToolkit.FTREP == 1 ) and (type(line) ~= "nil") )  then
-- 	    	d(FarmersToolkit.FTChat .. line);
--     end
-- end  -- function dft


 function FarmersToolkit.pChat_ChangeTab(tabToSet)

    if ( not pChat ) then return end

	local ChatSys = CHAT_SYSTEM
        local logger = pChat.logger
        logger:Debug("pChat_ChangeTab", "To tab: " ..tostring(tabToSet))
        if type(tabToSet)~="number" then return end
        local container=ChatSys.primaryContainer 
	if not container then d("No container"); return end
        if tabToSet<1 or tabToSet>#container.windows then return end
        if container.windows[tabToSet].tab==nil then return end
        container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
        if ChatSys:IsMinimized() then
            ChatSys:Maximize()
        end
    end




function FarmersToolkit.GetFTKChannelIndex() 

local retval=nil; -- By default, go to the chat window (1)

if pChat then

local CONSTANTS = pChat.CONSTANTS

local ChatSys = CONSTANTS.CHAT_SYSTEM
        local totalTabs = ChatSys.tabPool.m_Active
        if totalTabs ~= nil and #totalTabs >= 1 then
            for idx, tmpTab in ipairs(totalTabs) do
                local tabLabel = tmpTab:GetNamedChild("Text")
		if ( tabLabel ~= nil ) then
			-- d("===================> [" .. tabLabel:GetText() .. "]");
			if ( tabLabel:GetText() == "FTK" ) then retval=idx; end
		else
			-- d("TabLabel was blank");
		end
	    end
       end

      if ( retval == nil ) then return 0 ; end -- Failsafe, something is broken if this happens
	-- d("GetFTKC returning (" .. retval .. ")");
       return retval;

else -- no PChat
	return 1;

end

end

-- Capitalize the first word of each string in a sentence (needed to keep settargettype relatively sane)
function FarmersToolkit.capitalizeWords(input)
    return input:gsub("(%a)(%w*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end





-- Let's try to redirect our output to a specific channel instead of the default.
-- (We tried, we failed, we memorialize the code until the next purge)
-- function FarmersToolkit.SendToCustomChannel(message)
--     local formattedMessage = string.format("[FTREP] %s", message)
--     CHAT_ROUTER:AddSystemMessage(formattedMessage)
-- end


-- Load (Generate) the Favorite Pet List (FPetList)
function FarmersToolkit.LoadFPetList (arg1)
	-- dft_debug("FTK.LFPL(top)> FTK.LoadFPetList called.")
	-- First and foremost, see if we have already built this list in the last... say, 5 minutes... 600 seconds
	if ( FarmersToolkit.FPet_Refresh ) then 
	  if ( (os.time() - FarmersToolkit.FPet_Refresh ) < 300 ) then  -- Don't rebuild within 5 minutes of the last call
		if ( arg1 ~= "override" ) then
			dft_debug("FTK:LoadFPetList returning early due to timing flag")
			return 
		else
			-- dft_debug("FTK:LoadFPetList continuing despite early timing flag due to " .. arg1 .. " command")
		end -- if not override
	  end -- if OS.time is close to Refresh
	end -- if Refresh event exists

	   FarmersToolkit.AvailPets ={};
	   FarmersToolkit.AvailPetNames ={};
	   FarmersToolkit.SortedPetNames ={};

	   if ( FarmersToolkit.savedVariables.FPetList ) then
	   	FarmersToolkit.FPetList = FarmersToolkit.savedVariables.FPetList;
	   else
	   	FarmersToolkit.FPetList = {}
	   end

	   local PFound=1;
	   local PAvail=1;
	   local ThisPetNum=1;
	   local ThisPetCategory=""; --  Make sure this is actually a pet collectible
	   local IsPetUsable; -- Is Pet unlocked
	   local PetName;
	   local PlainPetName;
	   local PCount=0;
	   FarmersToolkit.PetCount=0; -- Total count of available pets

	   -- New approach - use GetCollectibleInfo to learn various things:
	   --   field 1 = name (but not the link, use GetCollectibleLink(nnn, 1) for that
	   --   field 2 = Longer description (just kinda interesting, I have no clear use in mind.  Yet.)
	   --   field 5 = Whether this is unlocked.  This is what we need instead of IsCollectibleUsable
	   --   field 7 = Is the item in use 
	   --   field 8 = Is the category type.  We only want items marked 3 here (3 = vanity pet).
	   --   field 9 = A hint / background on how to use / obtain this pet.  No use for this data.  Yet.
	   --   So, in the final analysis, the steps are
	   --   1. buzz through the possible numbers (1-6000, currently)
	   --	2. if the category = 3 (COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
	   --	3. and the unlock field (junk 5, below) is true)
	   --	4. then we have a viable pet
	 
	   -- dft_debug("************************** Start of FPet Search **********: " .. os.time() )
	   for Petnum = 1, 16000 do
	      local PlainPetName, junk, junk, junk, IsPetUsable, junk, junk, ThisPetCategory, junk =GetCollectibleInfo(Petnum)

	      if ( ThisPetCategory == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) then

		PCount = PCount +1 ;
		-- dft_debug(" ===== Petnum=" .. Petnum .. ", PlainPetName = [" .. PlainPetName .. "], PCount = " .. PCount .. ", Category type = [" .. ThisPetCategory .. "] ")


		local PetLink = GetCollectibleLink(Petnum, 1)
		if ( IsPetUsable == true ) then 
			-- dft_debug("IsPetUsable is usable (unlocked) = [true]") 
		else 
			-- dft_debug("IsPetUsable is not usable (unlocked) = [false]"); 
		end

		-- Old approach:  ThisPetNum = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, Petnum)
		-- IsPetUsable = IsCollectibleUsable(ThisPetNum) -- Replaced with GetCollectibleInfo call above
		local ThisPetNum = Petnum
		local ThisPetName = GetCollectibleLink(Petnum, 1)

		if ( ThisPetName == nil ) then ThisPetName="UNKNOWN PET"; end -- Should never happen

		if ( IsPetUsable == true ) then 
			-- New approach: We need the key to be the Petnum versus an incremental counter

			FarmersToolkit.AvailPetNames[ThisPetNum]=ThisPetName;
			FarmersToolkit.SortedPetNames[PlainPetName]=ThisPetNum;
			FarmersToolkit.PetCount = FarmersToolkit.PetCount + 1;

			FarmersToolkit.AvailPets[ThisPetNum]=ThisPetName;

			-- Check to see if we have a saved vsriable setting, otherwise assume false
			if ( FarmersToolkit.savedVariables.FPetList ) then
				FarmersToolkit.FPetList[ThisPetNum]=FarmersToolkit.FPetList[ThisPetNum];
			else
				FarmersToolkit.FPetList[ThisPetNum]=false;
			end

			-- FarmersToolkit.FPetList[ThisPetNum]=false;

			PFound = PFound +1;
		else
			-- dft_debug("Collectible #" .. Petnum .. " is NOT usable.  ThisPetName=[" .. ThisPetName .. "]")
		end -- if/else PetUsable
	      end -- IF Category = Pet
	   end -- for loop

	   -- Ok, so, as this as evolved, the function of FPetList has shifted a bit and that means we've
	   -- inadvertantly introduced some noise.  Originally, FPetlist had a reason to list settings that
	   -- were set to false.  Now, those entries are becoming problematic under the new approach.  Thus,
	   -- we'll step through FPetList and remove all false entries (at least, I think that's what this does...)
	   
		for i = #FarmersToolkit.FPetList, 1, -1 do
    			if myTable[i] == false then
        			table.remove(FarmersToolkit.FPetList, i)
    			end
		end	 

	    -- And, because the "FPetList with false entries" issue seems recurrent, go ahead
	    -- and purge the saved variables list (ok, purge is too strong a verb... clean it up)
	    -- That is, now that we have just removed ll the FALSE entries from the in-memory
	    -- FPetlist, go ahead and save it to the savedVariables version as well while we are here.
	    
	    FarmersToolkit.savedVariables.FPetList = FarmersToolkit.FPetList;

 
	   --
	   -- I think I may be calling this routine too much / too many times.  It isn't as if the pet
	   -- list is going to radically change during game play.    So I am thinking of making a
	   -- timer here: only rebuild the list if it has been more than NNN seconds since the last time.
	   -- Mainly because I fear LibAddOnMenu is calling this a LOT (my fault/my coding, not the lib's doing, I am sure)
	   -- So.... let's.... try... setting a timer here at the bottom and then checking for it at the top.
	   -- (That is, rebuild only if 5 mniutes have passed or we are given an override command)
	   FarmersToolkit.FPet_Refresh=os.time();


	   -- if FarmersToolkit.savedVariables.FPetList then 
	-- 	   for k,v in FarmersToolkit.savedVariables.FPetlist do
	-- 	   	FarmersToolkit.FPetList[k] = v;
	-- 	   end
	  --  end
	-- dft_debug("FTK.LFPL(end)> FTK.LoadFPetList closing.")
end -- Load FPetList

-- There is a built in way to do this but it just comma-fies (puts commas into numbers) numbers
local function comma_value(amount)
  -- if (type(amount) == "nil" ) then d("FT-DEBUG(TypeChk): comma_value was passed a nil string") end
  if (type(amount) == "nil" ) then return 0 end
  local formatted = amount
  local k
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end
-- end of comma_value

-- This was originally a command line function but was later modified to
-- to support a GUI configuration if LibAddonMenu libraries are present.
-- Purpose: Set the font for a given label subset in a control
-- Note: There are (at least) two control structures
--     FTAddonIndicator: Controls 2-label section of Inventory and Dailies
--     FTAddonIndicator2: Controls 2-label section for the farming/shopping list
--     			  (1 label for the header, 1 label for the list)
function FarmersToolkit.SetFont(alabel,astring)

   -- Step 1: Sanity checks and debugs
   -- There is probably a sexier way to do this but...
   if ( type(astring) == "nil" ) then return end

   -- Step 2: Grab the correct control and set the font
   if ( alabel == "Farmlist" ) then
        local labelControl = FTAddonIndicator2:GetNamedChild(alabel)
   	if labelControl then
   	 	labelControl:SetFont(astring)
   	end
   elseif ( alabel == "Farmlist2" ) then
        local labelControl = FTAddonIndicator2:GetNamedChild(alabel)
   	if labelControl then
   	 	labelControl:SetFont(astring)
   	end

   else 
        local labelControl = FTAddonIndicator:GetNamedChild(alabel)

   	if labelControl then
   	 	labelControl:SetFont(astring)
   	end

   end

   -- Step 3: Save the right variables off
   --    Font L1/L2 for the labels
   --    Font F1/F2 for the farmlists
   if ( alabel == "Label" ) then
 	FarmersToolkit.FontL1=astring;
	FarmersToolkit.savedVariables.FontL1=astring;
  end

   if ( alabel == "Label2" ) then
 	FarmersToolkit.FontL2=astring;
	FarmersToolkit.savedVariables.FontL2=astring;
  end

   if ( alabel == "Farmlist" ) then -- Handle first font in farmlist (header)
 	FarmersToolkit.FontF1=astring;
	FarmersToolkit.savedVariables.FontF1=astring;
  end



   if ( alabel == "Farmlist2" ) then -- Handle second font in farmlist (actual list)
 	FarmersToolkit.FontF2=astring;
	FarmersToolkit.savedVariables.FontF2=astring;
  end

end -- function FarmersToolkit.SetFont(alabel,astring)

-- Counterpart of SetFont, just returns the presumably current Font for a given label
-- Note: The argument here must match the actual label value (i.e., defined in the XML file)
function FarmersToolkit.GetFont(alabel)

   local retval="ZoFontWinH2"; -- Have something to return if nothing is set

   -- There is probably a sexier way to do this but...
   if ( type(alabel) == "nil" ) then return end

   -- dft_debug("GetFont passed = [" .. alabel .. "]")

   local retval="NA"
   -- dft_debug("Within the LabelControl segment");

	 -- And I cannot find a way (yet!) to retrieve the current font for an object
	 -- (Probably trivial but every example / discussion leads back to SetFont...)
	 -- So, instead, we'll rely on stored variables.
	 
    if ( alabel == "Label" ) then
    	-- dft_debug("Within the LabelControl for L1 segment");
	retval="ZoFontBookTablet"; -- Have some default if nothing else is set
    	if (type(FarmersToolkit.FontL1) ~= "nil" )  then
    		retval=FarmersToolkit.FontL1;
    	elseif (type(FarmersToolkit.savedVariables.FontL1) ~= "nil" )  then
    		retval=FarmersToolkit.savedVariables.FontL1;
    	end
    end

    if ( alabel == "Label2" ) then
	   -- dft_debug("Within the LabelControl for L2 segment");
		 retval="ZoFontWinH3"; -- Have some default if nothing else is set
		 if (type(FarmersToolkit.FontL2) ~= "nil" )  then
			 	retval=FarmersToolkit.FontL2;
		elseif (type(FarmersToolkit.savedVariables.FontL2) ~= "nil" )  then
			 	retval=FarmersToolkit.savedVariables.FontL2;
		end
     end


	 if ( alabel == "Farmlist" ) then
	   -- dft_debug("Within the LabelControl for Farmlist segment");
		 retval="ZoFontWinH2"; -- Have some default if nothing else is set
		 if (type(FarmersToolkit.FontF1) ~= "nil" )  then
			 	retval=FarmersToolkit.FontF1;
		elseif (type(FarmersToolkit.savedVariables.FontF1) ~= "nil" )  then
			 	retval=FarmersToolkit.savedVariables.FontF1;
		end
	end

	 if ( alabel == "Farmlist2" ) then
	   -- dft_debug("Within the LabelControl for Farmlist2 segment");
		 retval="ZoFontWinH4"; -- Have some default if nothing else is set
		 if (type(FarmersToolkit.FontF2) ~= "nil" )  then
			 	retval=FarmersToolkit.FontF2;
		elseif (type(FarmersToolkit.savedVariables.FontF2) ~= "nil" )  then
			 	retval=FarmersToolkit.savedVariables.FontF2;
		end
	end

 --  end
   -- dft_debug("GetFont returning = [" .. retval .. "]")
   return retval
end


-- My (vain) attempt to make structured columns when the system font is proportional.  Oh well.
-- There's also work underway to test the "|u50:0:0:blah...." stuff in zo_strformat somewhere
-- in this file but spacing continues to be an elusive victory.  So far.
local function fixwidth(str, width) 

  if ( type(str) == "nil" ) then return "" end
  if ( width == 0 ) then return "" end

  local retval=string.sub(str .. "                                                                                                                   ", 1, width);
  
  return retval

end
-- end fixwidth

-- 
-- fixwidth2(str, width) - Return a padded string of "width" characters wide based on the supplied ("str") 
--   This is a slightly improved version but I'm not yet convinced it should replace fixwidth.  Yet.
-- TODO: Add "font" argument to support this calculation for something besides ZoFontChat
--
function FarmersToolkit.fixwidth2(str, width) 

   local spacechar = ".";
   -- Step 1: Determine the length of the string that was passed

   local strpix=FarmersToolkit.GetStringWidth(str,"ZoFontChat");
   local strlen1=string.len(str);

   local retval = ""

   -- Step 2: Determine the width of a _ using the standard font (We'll want to make this changeable later)
   local spacer=FarmersToolkit.GetStringWidth(spacechar, "ZoFontChat");

   -- Step 3: Determine how much space is needed for padding
   local targetpadding=math.floor(((width*spacer)-strpix)/spacer);

   -- Step 4: Format and return the string with the appropriate padding

  if ( type(str) == "nil" ) then return "" end

     local tempret=str .. " ";
     while (FarmersToolkit.GetStringWidth(tempret, "ZoFontChat") < (width*spacer) ) do 
	tempret = tempret .. spacechar;
     end
     retval = tempret;

   -- Step 5: Check results
   	
	local checkvar = FarmersToolkit.GetStringWidth(retval,"ZoFontChat");

   -- Step 6: return results

  return retval

end
-- end FarmersToolkit.fixwidth2

-- Buzz through TargetTypeCount array and look for exact and fuzzy matches
-- Return two values: 
-- 1 - Whether there was a match found (boolean)
-- 2 - If the supplied value (newItem) matched a wildcard variable, 
--     return that variable (i.e., an Aspect Runestone that matches #Runestone# will return #Runestone#
--     since that is the Type target that was matched
--     Otherwise, return the passed variable unchanged
-- (This allows the return value to be used as the index key for TrackingTypeSoFar, etc.)

function FarmersToolkit.checkTTC(newItem)
    local processItem = false
    local matchkey = newItem;
    -- dft_debug("Scanning TTC table for [" ..newItem.."]");
    -- Iterate over FarmersToolkit.TargetTypeCount to check for both exact and pattern matches
    for key, count in pairs(FarmersToolkit.TargetTypeCount) do
	    -- dft_debug("Comparing " .. key .. " (with target of " .. count .. ") against [" ..newItem .."]")
        if count > 0 then
            -- Check if the key is a pattern (contains any Lua pattern characters)
	    if key:sub(1,1) == "#" and key:sub(-1) == "#" then -- we have a #string# situation
		local pattern = key:sub(2,-2)
		-- dft_debug("Adjusted string match to be [" .. pattern .. "]")

                -- Treat key as a pattern and check if newItem matches it
                if newItem:lower():match(pattern:lower()) then
                    -- dft_debug("Pattern match found for item: " .. newItem .. " with pattern: " .. key)
		    matchkey=key
                    -- Process item as needed for pattern match
                    processItem = true
                    break  -- Exit loop if item is processed
                end
            elseif newItem == key then
                -- Exact match for the item
                -- dft_debug("Exact match found for item:" .. newItem)
                -- Process item as needed for exact match
                processItem = true
                break  -- Exit loop if item is processed
            end
        end
    end

     return processItem, matchkey
end



-- Attempt at ordered lists.  LUA.  Arrays.  Yeah.
-- These next few functions are amalgamations of various sources.
-- I'll try to retrace my steps for credit.  
-- For now: esoui.com, stackexchange, anything by K&R...
local function __genOrderedIndex( t )
    local orderedIndex = {}
    -- if (t == nil) then return end
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end
-- end __genOrderedIndex

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    -- -- print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end
-- end orderedNext

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate in order
    --
    return orderedNext, t, nil
end
-- end orderedPairs

-- This is the bulk of the inventory management / tracking system
-- (This started off innocent enough and, like Frankenstein's monster....grew)

-- local function FarmersToolkit.LootTest(number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function FarmersToolkit.LootTest(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)

-- if ( eventCode ~= 131199 ) then
-- 	dft_debug("FTK: Inside LootTest Code with a non 131199 event code!");
-- 	dft_debug("FTK.LT>> eventCode = [ " .. eventCode .. " ]");
-- 	-- dft("FTK.LT>> receivedBy = [ " .. receivedBy .. " ]");
-- 	dft_debug("FTK.LT>> itemName = [ " .. itemName .. " ]");
-- 	dft_debug("FTK.LT>> quantity = [ " .. quantity .. " ]");
-- 	dft_debug("FTK.LT>> questItemIcon = [ " .. questItemIcon .. " ]");
-- 	-- dft("FTK.LT>> self = [ " .. type(self) .. " ]");
-- 	-- dft(zo_strformat("self is: <<1>>", self and "true" or "false"))
-- 	-- dft(zo_strformat("isPickpocketLoot is: <<1>>", isPickpocketLoot and "true" or "false"))
-- 	-- dft(zo_strformat("isStolen is: <<1>>", isStolen and "true" or "false"))
-- 	--dft(zo_strformat("ItemLocked is: <<1>>", ItemLocked and "true" or "false"))
-- 	dft_debug("FTK.LT>> itemId = [ " .. itemId .. " ]");
-- end


end -- FTK.LootTest

-- This function doesn't follow my my normal naming convention so I suspect it was 
-- originally pulled from elsewhere and modified on the learning curve.   I'll try to
-- retrace this but if it looks familiar to anyone reading this, please let me know.
local function _onInventoryChanged(eventCode, bagID, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)

local newflag="false"; if IsNewItem == true then newflag="true" end
   local link  = GetItemLink(bagID, slotIndex)
   local aname = GetItemName(bagID, slotIndex)
   local count = GetSlotStackSize(bagID, slotIndex)

dft_debug("oIC Top: bagID=" .. bagID .. ", slotIndex = " .. slotIndex .. ", updateReason = " .. updateReason .. ", stackCountChange = " .. stackCountChange .. ", isNewItem = " .. newflag .. ", Sound = " .. itemSoundCategory .. ", name=" .. aname .. ", link=" .. link);

-- Trying to streamline here, we're really only interested in things that we add / gather
-- (This could probably be accomplished with an event filter....)
-- Turns out we can't do this.  There are tmies when a negative stack is relevant (selling trashure, for example_
-- So, backing this code out and giving it a rethink...
-- if ( stackCountChange < 0 ) then
	-- dft_debug("_onInventoryChange is bailing due to a negative count")
	-- return
-- end

   local xmsg = "";
   local OOIC_retval=""; -- This is the Overall On Inventory Change return value

--  Regardless what we do next, update the on-screen text with the latest - we may do this again below
--  (Might seem wasteful but this centralizes updates across multiple events.  Hopefully.)
  if (FarmersToolkit.inCombat == false ) then

       FarmersToolkit.FTK_Channel = FarmersToolkit.GetFTKChannelIndex(); -- d("================================== Set FTK Channel to be " .. FarmersToolkit.FTK_Channel);

       FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
       FarmersToolkit.UpdateFarmlist()
  end

 -- Handle changes in gold count - Technically not farming but nonetheless of interest.
   FarmersToolkit.NewGoldCount=GetCurrencyAmount(1,0);
   if (FarmersToolkit.OldGoldCount < FarmersToolkit.NewGoldCount ) then
      local DiffGoldCount=FarmersToolkit.NewGoldCount-FarmersToolkit.OldGoldCount
      FarmersToolkit.TotalGoldGain=FarmersToolkit.NewGoldCount-FarmersToolkit.StartGold
      FarmersToolkit.OldGoldCount=FarmersToolkit.NewGoldCount

      dft(comma_value(DiffGoldCount) .. " gold!  Total is now " .. comma_value(FarmersToolkit.NewGoldCount) .. ",          (session: " .. 	comma_value(FarmersToolkit.TotalGoldGain) .. ") " )
      
      -- dft_debug ("FT: +" .. comma_value(DiffGoldCount) .. " gold!  Total is now " .. comma_value(FarmersToolkit.NewGoldCount) .. ",          (session total: " .. 	comma_value(FarmersToolkit.TotalGoldGain) .. ") " )
      -- dft_debug ("FT: Started with " .. comma_value(FarmersToolkit.StartGold) .. " and now have " .. comma_value(FarmersToolkit.NewGoldCount) .. " so take credit for " .. comma_value(FarmersToolkit.TotalGoldGain) .. " so far.")
 
   end -- Goldcount if/then

   -- dft_debug("Pre bank bag check, eventcode=[" ..eventCode .."], bagid=[" .. bagID .. "], slotindex=[" ..slotIndex .. "], stackchange=[" .. stackCountChange .."]")

-- Ignore entries with a count of < 1 (less than 0, we're giving something away - but also saw some 0 entries, not sure where they are coming from but ok)
if ( stackCountChange < 1 ) then return end

-- Ignore bank transfers (2 = bank, 3 = guild bank, 6=BAG_SUBSCRIBER_BANK)
-- (There are a lot of situations we should handle [Crafting, Trading, etc.] but... this is where we are for today.)
-- Ideally, there is a source/target EVENT for bag transfers but... we'll get there.  Not critical for the moment.
--

   if ( ( bagID == BAG_BANK ) or ( bagID == BAG_GUILDBANK ) or ( bagID == BAG_SUBSCRIBER_BANK) ) then return end 

-- This started out as just curiousity.... i.e. flag if we don't currently have these in our bag
-- Now it helps distinguish "new-to-this-session" items by color (later on)
if ( count == stackCountChange ) then 
  
  -- Replenish = items we had zero of before.  
  FarmersToolkit.ReplenishedItems = FarmersToolkit.ReplenishedItems +1;

end

  -- Grab what we have in the backpack.  Resist the urge to look elsewhere.  This is a farming addon, not inventory mgmt
  local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
   
   -- DEBUG LINES (Uncomment and set debug flag if needed)
      -- dft_debug("FT: Picked up a " .. link .. " using bagId " .. bagID .. " and slot index " .. slotIndex .. " with the reason of " .. updateReason .. " and a count of " .. stackCountChange .. " and eventCode=[" .. eventCode .."] .. Bags: " .. usedSlots .. " / " .. maxSlots)
      -- dft_debug("FT: " .. link .. " +" .. stackCountChange .. " for a total of " .. comma_value(count))


--  Regardless, update the on-screen text with the latest
--  (Chances are I can stream this if Gold is the only potentially changed
--  entry here.  Will revisit)
  if (FarmersToolkit.inCombat == false ) then
       FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
       FarmersToolkit.UpdateFarmlist()
  end

   -- Now process iff stack is an addition
   local ThisDelta=0;
   if ( stackCountChange > 0 ) then
      FarmersToolkit.tvalue = FarmersToolkit.tvalue + stackCountChange 
      ThisDelta = stackCountChange;

      -- Now process the individual item(s)
      LinkID=GetItemLinkItemId(link);
	if ( type(LinkID) ~= "number" ) then dft("============ LinkID is set, HOWEVER  type is " .. type(LinkID)) end


      local ItemCheck="." -- ItemCheck is an optional data field used below

      -- If we haven't seen this item before *in this session* 
      local FirstTimeItem=false;
      if (type(FarmersToolkit.SessionCount[LinkID])) == "nil" then 
	 FirstTimeItem=true;
         FarmersToolkit.SessionCount[LinkID]=ThisDelta
	 FarmersToolkit.UniqueItems=FarmersToolkit.UniqueItems+1;
         ItemCheck="     - (Session first)";

      else 
         FarmersToolkit.SessionCount[LinkID] = FarmersToolkit.SessionCount[LinkID] + ThisDelta;

      end

      -- (If this is "new" for this session, change the color of the chatline
      if ( count == stackCountChange ) then 
	ItemCheck = " - (|c00FF00 Restock Item )|r "
      end

      -- If we are tracking this item for farming targets, Make use of TIDCheck (ala ItemCheck)
      local tlink=tonumber(LinkID);
      local TIDCheck="";
      if ( type(FarmersToolkit.TIDCount) == "nil" ) then
	-- dft_debug("ErrNote: TIDCount was nil around 974.  Initialized and moving on....")
	FarmersToolkit.TIDCount = {}
	end

      if ( type(tlink) == "nil" ) then
	-- dft_debug("ErrNote: tlink was nil around 979.  Initialized and moving on....")
	tlink = 0
	end

      -- dft_debug("Test 1: FTK:TIDCount is a type of " .. type(FarmersToolkit.TIDCount));
      -- dft_debug("Test 2: tlink is a type of " .. type(tlink));

      if ( tlink == 0 ) then -- something is amiss
	      -- dft_debug("FTK(xxx): Detected a 0-value LinkID.  LinkID type is " .. type(LinkID))
      elseif ( type(FarmersToolkit.TIDCount[tlink]) ~= "nil" ) then
	      local atarget = FarmersToolkit.TIDCount[tlink];
	      local acount = FarmersToolkit.SessionCount[tlink];
	      local farm2go = atarget - acount

	      if ( acount >=  atarget ) then -- We have met out target
		      TIDCheck = " |c00FF00 (Target of " .. atarget .. " met)|r ";
	      else 
		      TIDCheck = " |cFFFF00 (Farmed " .. acount .. " / " .. atarget .. ". To go: " .. farm2go .. ")|r "
	      end
       end

      -- Additionally, we are tracking this *type of item* for farming targets, Make use of TIDCheck (ala ItemCheck) but use the item type instead of name
      local tlink=tonumber(LinkID);

   		local link  = GetItemLink(bagID, slotIndex)
		local itemType = GetItemLinkItemType(link)
		local SpecialItemType=ZO_GetSpecializedItemTypeTextBySlot(bagID, slotIndex); 
		-- dft_debug("Type tracker for " .. tlink .. " has itemType = " .. itemType .. " and the special item type = " .. SpecialItemType);

      		if ( type(FarmersToolkit.TargetTypeCount) == "nil" ) then FarmersToolkit.TargetTypeCount = {}; end
      		if ( type(FarmersToolkit.TargetTypeSoFar) == "nil" ) then FarmersToolkit.TargetTypeSoFar = {}; end

		if ( type(SpecialItemType) == "string" ) then
			-- dft_debug("For reference, SIT is a string with the value of " .. SpecialItemType) 
		else
			-- dft_debug("For reference, SIT is a " .. type(SpecialItemType))
		end

		local has_match, match_key = FarmersToolkit.checkTTC(SpecialItemType);

		if ( match_key ~= SpecialItemType ) then 
			-- dft_debug("Note: match_key is now ["..match_key.."] after being transitioned by checkTTC call."); 
		end

      		-- if ( FarmersToolkit.TargetTypeCount[SpecialItemType] ~= nil ) and (FarmersToolkit.checkTTC(SpecialItemType) == true )then
      		-- if (FarmersToolkit.checkTTC(SpecialItemType) == true )then
      		if (has_match == true )then
	      		-- local atarget = FarmersToolkit.TargetTypeCount[SpecialItemType];
	      		local atarget = FarmersToolkit.TargetTypeCount[match_key]; -- Use match_key to handle pattern-mateched item classes

			-- If atarget isn't defined, we're likely dealing with a pattern match (so there is no specific count or target)
			   if (type(atarget) == "nil" ) then 
				-- dft_debug("within FTK:LTC, atarget was nil, setting to 0 - case 144C");
				atarget = 0; 
				end

			-- local donesofar = FarmersToolkit.TargetTypeSoFar[SpecialItemType];
			local donesofar = FarmersToolkit.TargetTypeSoFar[match_key]; -- Use match_key in case this is a partial match (set by checkTTC)


			if (type(donesofar) == "nil" ) then 
				-- FarmersToolkit.TargetTypeSoFar[SpecialItemType] = 0;
				FarmersToolkit.TargetTypeSoFar[match_key] = 0;
				donesofar=0; 
			end

			local acount = donesofar + stackCountChange;
			
	      		--local acount = FarmersToolkit.SessionCount[tlink];
	      		local farm2go = atarget - acount

			-- dft_debug("stack Count Change = " .. stackCountChange);
			
			-- FarmersToolkit.TargetTypeSoFar[SpecialItemType] = FarmersToolkit.TargetTypeSoFar[SpecialItemType] + stackCountChange; 
			FarmersToolkit.TargetTypeSoFar[match_key] = FarmersToolkit.TargetTypeSoFar[match_key] + stackCountChange; 

			-- if ( atarget > acount ) then
				-- dft_debug("I found " .. link  .. " that appears be of type [" .. SpecialItemType .."] which is being tracked for a target of " .. atarget .." of which we have " .. acount .. " and therefore " .. farm2go .. " to go?")
			-- else
				-- dft_debug("I found " .. link  .. " that appears be of type [" .. SpecialItemType .."] which was being tracked for a target of " .. atarget .." but we already have " .. acount .. " - great!" )
			-- end


			-- Handle reporting of type tracked items, if applicable
			-- local xmsg="|r|cFFA500Type Tracking|r|cFFFF00: Found [" .. link .. "] of type [" .. SpecialItemType .. "] which is being tracked."; 
			-- xmsg="|r|cFFA500Type Tracking|r|cFFFF00: Found [" .. link .. "] of type [" .. match_key .. "] which is being tracked."; 
			xmsg="|r|cFFA500Type Tracking|r|cFFFF00: Found [" .. link .. "] of tracked type [" .. match_key .. "]."; 

			if ( atarget > acount ) then 
				-- xmsg = xmsg .. " Progess made - Target is " .. atarget .. ", actual count is now " .. acount; 
				xmsg = xmsg .. " Progess! Target is " .. atarget .. ", actual count is now " .. acount; 
			elseif ( atarget > acount-stackCountChange ) then 
				xmsg = xmsg .. " Just completed! Target was " .. atarget .. ", actual count is now " .. acount; 
			else
			 	-- xmsg = "Nothing to see here" 
			 	xmsg = "" 
			end

			-- Sanity check.  This is a place holder for a future configurable variable
			-- For now, if the target has been metm, report nothing on type tracking
			-- if ( acount >= atarget ) then 
				-- xmsg = xmsg .. " No action - Target was " .. atarget .. ", actual count is " .. acount; 
				-- If the target has been met, say nothing.  This should be a configurable level of detail at some point
			-- 	xmsg = "Nothing to see here" 
			-- end
				
			-- dft("?" .. xmsg);
			-- OOIC_retval = OOIC_retval .. xmsg

		else 
			-- dft_debug("Did not see any tracking info for " .. SpecialItemType .. " entries.");
       		end





       -- Add in pricing info, if available
       local aprice=FarmersToolkit.PriceInfo(link);
       local PriceInfoString="";
       if ( aprice ~= "" ) then PriceInfoString=", " .. aprice; end

      -- Present the chatline differently if we have ItemCheck trivia to share
        if ( FirstTimeItem == true ) then -- print the line in blue

	  -- dft(zo_strformat("|c1EDDFF<<1>>|r","  +" .. stackCountChange .. " " .. link .. ", total of " .. comma_value(count) .. "         (session total: " .. comma_value(FarmersToolkit.SessionCount[LinkID]) .. " / " .. comma_value(FarmersToolkit.tvalue) .. PriceInfoString .. " ) " .. ItemCheck .. TIDCheck))
	  OOIC_retval = OOIC_retval .. zo_strformat("|c1EDDFF<<1>>|r","  +" .. stackCountChange .. " " .. link .. ", total of " .. comma_value(count) .. "         (session total: " .. comma_value(FarmersToolkit.SessionCount[LinkID]) .. " / " .. comma_value(FarmersToolkit.tvalue) .. PriceInfoString .. " ) " .. ItemCheck .. TIDCheck)

        else  -- print the line normally (might need to force a starting color here at some point?)
          -- dft(" +" .. stackCountChange .. " " .. link .. ", total of " .. comma_value(count) .. "         (session total: " .. comma_value(FarmersToolkit.SessionCount[LinkID]) .. " / " .. comma_value(FarmersToolkit.tvalue) .. PriceInfoString .. " ) " .. TIDCheck) 
          OOIC_retval = OOIC_retval .. " +" .. stackCountChange .. " " .. link .. ", total of " .. comma_value(count) .. "         (session total: " .. comma_value(FarmersToolkit.SessionCount[LinkID]) .. " / " .. comma_value(FarmersToolkit.tvalue) .. PriceInfoString .. " ) " .. TIDCheck
	 
        end

	-- Append any type tracking from above
	if ( xmsg ~= "" ) then
		OOIC_retval = OOIC_retval .. "\n" .. FarmersToolkit.FTChat .. "      " .. xmsg
	end

-- dft("FTK>OIC>Debug>1 hi. OOIC_retval=\n[" .. OOIC_retval .."]");
      -- FarmersToolkit.ReminderCount is just a visual and audio mini-celebration of farming {FarmersToolkit.ReminderCount} variables 
      -- (Ok, this was true initially.  Now... for no readily apparent reason... we may also change NC pets here)
      -- Plays a sound every {ReminderCount} items farmed.
      -- If tripped, there is a PetFrequencyCount chance of swapping pets

      -- dft_debug("(FTK.RC) FarmersToolkit.ReminderCount=[" .. FarmersToolkit.ReminderCount .. "]")

      -- If ReminderCount > 0 (meaning the player wants to have these sporadic messages)
      if (FarmersToolkit.ReminderCount > 0 ) then 
         local tcheck=math.fmod((FarmersToolkit.tvalue - stackCountChange),FarmersToolkit.ReminderCount)
          
         -- If we've tripped the ReminderCount, report it to chat
         if ( (tcheck + stackCountChange) > (FarmersToolkit.ReminderCount-1)) then
           if ( FarmersToolkit.FTREP == 1 ) then
             dft ( zo_strformat("|cB27BFF<<1>>|r", "Congrats! You've collected another " .. FarmersToolkit.ReminderCount .." items!  (TValue=" .. FarmersToolkit.tvalue .. ")") )
	     PlaySound("Achievement_Awarded")
          end

	   -- Randomly, change pets... maybe.   Percentage of swap is controlled by PetFrequencyCount (Higher =better, 100 = always)
      	   -- dft_debug("(FTK.PFC) FarmersToolkit.PetFrequencyCount=[" .. FarmersToolkit.PetFrequencyCount .. "]")
	   if ( FarmersToolkit.PetFrequencyCount == nil ) then FarmersToolkit.PetFrequencyCount=66; end
	   local RandoChanceOMatic = math.random(100);
	   -- dft_debug("Random chance number is " .. RandoChanceOMatic);
	   if ( RandoChanceOMatic < FarmersToolkit.PetFrequencyCount ) then FarmersToolkit.LaunchRandomPet() end

       end
      end

   else   
         -- dft_debug ("FT-DEBUG-a: I think this was a reduction in inventory: LinkID=[".. LinkID .. "] , stackCountChange = " .. stackCountChange  );
   end
   -- end of "if ( stackCountChange > 0 ) then..."

   -- Play a sound for certain items (currently, whatever FarmersToolkit.TargetItemID has in it) 
   -- (See previous disscussion above where FarmersToolkit.TargetItemID was defined and populated)
   -- ((This will likely change and fold into the TIDCount and TIDName structures.  Eventually.))
   -- ((( Also, I will resist the urge to play different sounds for different targets.  Coz we just don't have that cool sounds. )))
   for key, val in orderedPairs(FarmersToolkit.TargetItemID) do
     if ( LinkID == val ) then
	PlaySound("Duel_Won")
	dft("Picked up a " .. link .. ", nice job!!")
     end
   end

   -- If we have something of note...
   if ( ( link ~= "" ) and ( LinkID ~= "" ) ) then
        local alen=40 - aname.len(aname);

	if ( type(LinkID) ~= "nil") then
	   local pricedata=FarmersToolkit.PriceInfo(link);

	   if ( type(FarmersToolkit.SessionCount[LinkID]) == "nil" ) then FarmersToolkit.SessionCount[LinkID]=1; end
	    if ( pricedata ~= "" ) then
	       FarmersToolkit.FarmList[LinkID]= FarmersToolkit.fixwidth2(link,60) .. " This Session: + " .. FarmersToolkit.fixwidth2(comma_value(FarmersToolkit.SessionCount[LinkID]),20) .. " Total: " .. FarmersToolkit.fixwidth2(comma_value(count),20)  .. " " .. pricedata .. "."
	    else
	       FarmersToolkit.FarmList[LinkID]= FarmersToolkit.fixwidth2(link,60) .. " This Session: + " .. FarmersToolkit.fixwidth2(comma_value(FarmersToolkit.SessionCount[LinkID]),20) .. " Total: " .. comma_value(count)  
            end

	   FarmersToolkit.FarmListNames[LinkID]=link;

	end

   end

   -- Finish off any output here before calling the updates screens....


-- dft(".....still here....");
-- if ( type(OOIC_retval) == "string" ) then
-- dft("XX" .. OOIC_retval);
-- else
-- dft("Odd.  OOIC_retval is a " .. type(OOIC_retval))
-- dft("Odd.  xmsg is a " .. type(xmsg))
-- end
-- dft(".....closing off ....");
-- 

dft(OOIC_retval);



   	-- local aname= LocalizeString("<<1>>", link)
   	FarmersToolkit.FarmNameByLinkID[aname]=LinkID;

	-- Now update the screen
	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
        FarmersToolkit.UpdateFarmlist();
      
end

-- end of _onInventoryChanged

-- Generic call to update the screen info - Probably needs a better name, Activities can be read a couple of ways
function FarmersToolkit.UpdateActivities() 

       FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
       --FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies("Screen"))
       if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies("Screen")) end
       FarmersToolkit.UpdateFarmlist();
 
end -- Update the Screen

-- Book-specific "Update the screen" function (useful to call from EVENT manager?)
-- This was created because daily endeavours to read books wasn't updating on the screen in a timely fashion
-- (Which makes sense, most of the screen trigger updates are inventory-related)
-- function FarmersToolkit.BookActivity() 
-- Typically called from: EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_SHOW_BOOK , FarmersToolkit.BookActivity)
--
-- The documentation says the data should be coming in this order from EVENT_SHOW_BOOK
--   EVENT_SHOW_BOOK (*string* _bookTitle_, *string* _body_, *[BookMedium|#BookMedium]* _medium_, *bool* _showTitle_, *integer* _bookId_)
--
-- However, in practice, it seems closer to
--   EVENT_SHOW_BOOK (*integer* BookId, *string* bookTitle, *string* bookText, *bool* bookShowTitle, 
-- function FarmersToolkit.BookActivity(bookTitle, bookText, bookMedium, bookShowTitle, bookID) 
function FarmersToolkit.BookActivity(arg1, arg2, arg3, arg4, arg5)

	local booltxt="false";
	if ( arg5 == true ) then booltxt="true" end

	-- Based on the debugging above, let's go with the following mapping until we learn more.
	local bookID = arg1;
	local bookTitle = arg2;
	local bookText = arg3;
	local bookMedium = arg4;
	local bookShowTitle = booltxt;

	-- Debug
	-- dft("========================================================================================");
	-- dft("bookTitle = [" .. bookTitle .. "]");
	-- dft("bookText = [" .. string.len(bookText) .. " characters]");
	-- dft("bookMedium = [" .. bookMedium .. "]");
	--
	-- BookID is consistently 131499 which maps to EVENT_SHOW_BOOK (So, not a Book ID such much as an EVENT ID...)
	-- dft("bookID = [" .. bookID .. "]");
	-- dft("bookShowTitle = [" .. bookShowTitle .. "]");


	-- Somehow, we can get here without Booklist being defined, despite calls Initialize and elsewhere.
	-- If that happens, the inclination is to create Booklist and move on.  But doing so risks any existing
	-- booklists that have been gathered and, since this is an account wide setting, we risk losing a lot
	-- of "recorded reading time".  OTOH, I don't want to not record a book when it is read so.... I dunno.
	-- For now, I'll make every effort to bring in the existing Booklist and, if not, relucatntly create the list.
	-- Feels like this is not the right approach though.  Or at least there is likely a better one.
	
	-- Anyway, let's see if the Booklist construct exists first and foremost
	if ( type(FarmersToolkit.Booklist) == "nil" ) then 
		-- dft_debug("Note: WIthin BookActivity, Booklist was not set (type == nil)");
		FarmersToolkit.Booklist = FarmersToolkit.savedVariablesAcct.Booklist;
		if ( type(FarmersToolkit.Booklist) == "nil" ) then  -- if we still don't have a list....
			-- dft_debug("Warning: Initializing the Booklist inside of BookActivity");
			FarmersToolkit.Booklist = {} 
		else
			-- dft_debug("Note: Set Booklist to savedVariablesAcct.Booklist and it is not nil, proceeding....");
		end
	end

	-- By this point we have to assume FarmersToolkit.Booklist exists in some form or fashion
	
	-- dft("Processing book title: " .. bookTitle);
	-- d("       Total Books read: " .. comma_value(FarmersToolkit.Lootable["Books"])  )
	if ( FarmersToolkit.LastBook ) and ( FarmersToolkit.LastBook == bookTitle ) then
		dft ("FYI - You just read the same book again : " .. bookTitle);
	elseif
		 ( type(FarmersToolkit.Booklist[bookTitle]) == "nil") then  
			FarmersToolkit.Booklist[bookTitle]= 1;
			dft ("|c00FF00You found a new book!|r " .. bookTitle );
			FarmersToolkit.Lootable["Books"] = FarmersToolkit.Lootable["Books"] +1;
			FarmersToolkit.savedVariablesAcct.Booklist = FarmersToolkit.Booklist;
	else
       		FarmersToolkit.Lootable["Books"]=FarmersToolkit.Lootable["Books"]+1
		FarmersToolkit.Booklist[bookTitle]= FarmersToolkit.Booklist[bookTitle] +1;
		dft ("You found a book you've already read: " .. bookTitle .. " (Total read count: " .. FarmersToolkit.Booklist[bookTitle] .. ")");
		local randomMsg=FarmersToolkit.ReadingMsgs[math.random (#FarmersToolkit.ReadingMsgs) ]
		dft("  -- But remember: " .. randomMsg);
	end

	FarmersToolkit.LastBook = bookTitle;
	
       FarmersToolkit.UpdateActivities();
 
end -- Update the Screen on a book event


function FarmersToolkit.TestActivity(arg) 

	dft("FT: Test activity called: " .. arg .. ".");

end -- Update the Screen on a book event



-- Just clear out all the existing, volatile data, same as if /reloadui was called. Hopefully.
-- Note: This does not apply to the TIDCount and TIDName by design.   Those have their own
-- 	 calls for setting, saving, loading, and deleting entries.  
function FarmersToolkit.ResetLists()

	FarmersToolkit.FarmList = {}

	FarmersToolkit.FarmListNames = {}

	FarmersToolkit.FarmNameByLinkID= {}

	FarmersToolkit.SessionCount={}

	FarmersToolkit.Lootable={}
	FarmersToolkit.Lootable["Chest"]=0;
	FarmersToolkit.Lootable["Books"]=0;

	FarmersToolkit.ft_count=0;

	FarmersToolkit.BagWarnLevel=10;

	FarmersToolkit.BagPanicLevel=5;

        -- dft_debug("FT-DEBUG(Reset): BW=" .. type(FarmersToolkit.BagWarnLevel) .. ", BP=" .. type(FarmersToolkit.BagPanicLevel) .." ")

        -- FarmersToolkit.UniqueItems counts the number of unique objects we collect per session
	FarmersToolkit.UniqueItems=0;

	-- ReplenisedItems counts the number of items that we had none of before farming
	FarmersToolkit.ReplenishedItems = 0;

	-- Play a Reminder sound (and post to chat if FarmersToolkit.FTREP==1) every FarmersToolkit.ReminderCount items farmed
	FarmersToolkit.ReminderCount=102;

       FarmersToolkit.UpdateText(":-)")
       FarmersToolkit.UpdateText2("(-:")
       FarmersToolkit.UpdateFarmlist();

	-- dft("Farming Lists reset")

	FarmersToolkit.tvalue= 0;

	-- So, farmers don't battle a lot.  Usually it is just a tamed animal having a cranky day.
	-- As a result, the battles are... less than epic, shall we say.  They can be boring...  Ok...They are boring.
	-- So, let's throw some encouragement up during the battle....
	FarmersToolkit.CombatMsgs={"Shields up!\nGood Luck!!","Combat Time!","Ugh, gross!\tThe breath on this mob..."}
        table.insert(FarmersToolkit.CombatMsgs,"OMG Becky!\nLook at her Hit Points")
	table.insert(FarmersToolkit.CombatMsgs,"Don't read this\nBeat up the monster!")
	table.insert(FarmersToolkit.CombatMsgs,"Battle Strategy\nMove faster, Hit Harder")
	table.insert(FarmersToolkit.CombatMsgs,"Fight!")
	table.insert(FarmersToolkit.CombatMsgs,"Finish Him!\n(or her... or them.. whatever)")
	table.insert(FarmersToolkit.CombatMsgs,"Get Over Here!\nOr..just stay there, I have a range attack")
	table.insert(FarmersToolkit.CombatMsgs,"...I'm all outta bubble gum")
	table.insert(FarmersToolkit.CombatMsgs,"So many weapons...\nSo few mobs")
	table.insert(FarmersToolkit.CombatMsgs,"LEEEROOYYY\nJENKINS!!!!!")
	table.insert(FarmersToolkit.CombatMsgs,"It's a-me, Mario!\nHere to kicka-you butt!")
	table.insert(FarmersToolkit.CombatMsgs,"Time to make a Jill sandwich....")
	table.insert(FarmersToolkit.CombatMsgs,"Look to the east!\n(Wait, which way is east?)")
	table.insert(FarmersToolkit.CombatMsgs,"It's dangerous to go alone\nCall up your companion")
	table.insert(FarmersToolkit.CombatMsgs,"Endure and Survive");
	table.insert(FarmersToolkit.CombatMsgs,"Faith and Honor")
	table.insert(FarmersToolkit.CombatMsgs,"Faith and Honor? Nah...\nFor a fight, it is Faith and Buffy, amirite?")
	table.insert(FarmersToolkit.CombatMsgs,"This mob made fun of your mom")
	table.insert(FarmersToolkit.CombatMsgs,"Remember the bully in high school?\nVisualize....")
	table.insert(FarmersToolkit.CombatMsgs,"Do a barrel roll!")
	table.insert(FarmersToolkit.CombatMsgs,"DPS! DPS! DPS!\n(Division of Public Slaying)")
	table.insert(FarmersToolkit.CombatMsgs,"Don't look here!\nThe battle is over there!")
	table.insert(FarmersToolkit.CombatMsgs,"Less reading!\nMore hitting!")
	table.insert(FarmersToolkit.CombatMsgs,"In Discord...\neveryone can hear you scream")
	table.insert(FarmersToolkit.CombatMsgs,"You didn't get those scars falling over in church...")
	table.insert(FarmersToolkit.CombatMsgs,"Waka Waka Waka\nPacMan buff, +1 to hit")
	table.insert(FarmersToolkit.CombatMsgs,"Battle Time!\n(Did I leave the iron on?)")
	table.insert(FarmersToolkit.CombatMsgs,"Combat Time\n(I knew I shoulda taken a bio break)")
	table.insert(FarmersToolkit.CombatMsgs,"Time to be the bad guy...\n(or whatever gender, I guess)")

	-- Similarly, Farmers read a lot.  Encouraging that is a good, Levar-esque thing to do.
	FarmersToolkit.ReadingMsgs={"Reading is fun, good on you!! Look, you're even reading THIS! Amazing!!"}
        table.insert(FarmersToolkit.ReadingMsgs,"'Books were safer than other people anyway.' - Neil Gaiman, The Ocean at the End of the Lane")
  	table.insert(FarmersToolkit.ReadingMsgs,"'We live for books.' - Umberto Eco")
  	table.insert(FarmersToolkit.ReadingMsgs,"'Some like to believe it’s the book that chooses the person.' ― Carlos Ruiz Zafón")
  	table.insert(FarmersToolkit.ReadingMsgs,"'I think reading is part of the birthright of the human being' - Levar Burton, speciest")
  	table.insert(FarmersToolkit.ReadingMsgs,"'For me, literacy means freedom. For the individual and for society.' - Levar Burton")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“A reader lives a thousand lives before he dies . . . The man who never reads lives only one.'- George R.R. Martin, Level 50 Procrastinator")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“Never trust anyone who has not brought a book with them.' - Lemony Snicket")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“You can never get a cup of tea large enough or a book long enough to suit me.' - C.S. Lewis")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“‘Classic’ – a book which people praise and don’t read.' - Mark Twain")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“The more that you read, the more things you will know. The more that you learn, the more places you’ll go.' - Dr. Seuss")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“Books are a uniquely portable magic.' - Stephen King")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“The person who deserves most pity is a lonesome one on a rainy day who doesn’t know how to read.' - Benjamin Franklin")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“A room without books is like a body without a soul.' - Cicero, defniitely NOT a necromancer.  Nope.")
  	table.insert(FarmersToolkit.ReadingMsgs,"'“Beware of the person of one book.' - Thomas Aquinas")
  	table.insert(FarmersToolkit.ReadingMsgs,"'Wear the old coat and buy the new book.' - Austin Phelps")
  	table.insert(FarmersToolkit.ReadingMsgs,"“I think books are like people, in the sense that they’ll turn up in your life when you most need them.' - Emma Thompson")
  	table.insert(FarmersToolkit.ReadingMsgs,"'I guess there are never enough books.' - John Steinbeck")
	table.insert(FarmersToolkit.ReadingMsgs,"'Books.  People never really do stop loving books.' - Dr.Who")
	table.insert(FarmersToolkit.ReadingMsgs,"'A million million life forms. And silence in the library...' - Dr.Who")
	table.insert(FarmersToolkit.ReadingMsgs,"'You want weapons? We're in a library. Books are the best weapon in the world.' - Dr.Who")

	-- Let's also have reminders and hints for Companions 
	FarmersToolkit.CompanionNotesLikes = {};
	FarmersToolkit.CompanionNotesDislikes = {};
	FarmersToolkit.CompanionNotesBuffs = {};

	FarmersToolkit.CompanionNotesLikes["Mirri Elendis"]= "Reading, long walks during Fighters Guild quests, Vvardendell dailies, visiting Clockwork City/talking to Sotha Sil, showing off Daedric pets, making alcohol, FULLY looting chests, digging up antiquities, and killing goblins or snakes.\n" ;
	FarmersToolkit.CompanionNotesDislikes["Mirri Elendis"]= "Killing butterflies, torchbugs, using the Blade of Woe, or people who don't use the Oxford comma.";

	FarmersToolkit.CompanionNotesLikes["Bastian Hallix"]="Reading, long walks during Mage Guild quests, scrying for antiquities, Psijic Portals, random encounters(?!?), and killing cultists or bandits.  \n" ;
	FarmersToolkit.CompanionNotesDislikes["Bastian Hallix"]="Cooking with cheese, getting caught/evading or fleeing guards, killing innocents or domesticated animals, pickpocketing, and people who talk at the theatre.";

	FarmersToolkit.CompanionNotesLikes["Ember"]="Pickpocketing, looting theives' troves, Thieves Guild quests, killing wolves, and evading the law (or using counterfeit pardons).\n"
	FarmersToolkit.CompanionNotesDislikes["Ember"]="Getting caught or spotted doing crimes, paying bounties, fishing, people who don't fully loot chests";
	FarmersToolkit.CompanionNotesBuffs["Ember"]="No specific buffs but she does like to walk on the wild side a bit.";


	FarmersToolkit.CompanionNotesLikes["Isobel Veloise"]="Fixing things (repair kits), making things (blacksmithing, sweet foods), killing Daedra and/or Delve bosses, dueling, non-dog pets, and bingeing Hallmark movies.\n" 
	FarmersToolkit.CompanionNotesDislikes["Isobel Veloise"]="Murder, stealing, going to Outlaw/Dark Brotherhood places, or people who mispronounce her name.";
	FarmersToolkit.CompanionNotesBuffs["Isobel Veloise"]="No specific buffs but is generally a goody two-shoes even when barefoot.  But is self-aware so it isn't terribly annoying.";

	FarmersToolkit.CompanionNotesLikes["Sharp-as-Night"]="Eating, making poisons, finding treasure chest maps and heavy sacks, fishing, talking toM'aiq the Liar, and probably sleeping during the day given his name.\n";
	FarmersToolkit.CompanionNotesDislikes["Sharp-as-Night"]="Paying bounties, destroy stacks of items worth +20G, pickpockting the unrich (beggar, fisher, laborer), and people who can't park oversized trucks inside the lines."

	FarmersToolkit.CompanionNotesLikes["Ember"]="Selling or fencing purple items, winning at Tribute, harvesting runestones, killing (were)wolves, using counterfeit edicts, visiting Ourlaw refuges / Thieves Guilds, and trespassing.\n"
	FarmersToolkit.CompanionNotesDislikes["Ember"]="Getting caught or spotted doing crimes, paying bounties, fishing, the Halls of Colossus, and people who file their taxes early."

	FarmersToolkit.CompanionNotesLikes["Azandar"]="Finishing master writs, upgrading items, scrying, reading, making/drinking tea, psijic portals, mundus stones, and getting likes on social media.\n"
	FarmersToolkit.CompanionNotesDislikes["Azandar"]="Visiting Artaeum or Eyevea, picking mushrooms, giving to a beggar, playing tribute, and drinking any coffee other than Starbucks."
	FarmersToolkit.CompanionNotesBuffs["Azandar"]="No specific buffs but has skills including Quill Knight, Revitaliing Researcher, Scholar of Apocrypha, and an ego the size of [insert crude or arcane reference here].";

	FarmersToolkit.CompanionNotesLikes["Tanlorin"]="Fighter guild quests, crafting/drinking wine, Indriks(?!), successful lockpicking, picking flowers (but non nirnroot), killing daedra, and avocado toast.\n"
	FarmersToolkit.CompanionNotesDislikes["Tanlorin"]="Arteum, Eveyra, psijic portals, anything magical (lore books, mages guildhall, etc.), ninrnroot, killing Indriks or Gryphons, cold coffee or stale bagels.\n"
	FarmersToolkit.CompanionNotesBuffs["Tanlorin"]="Really likes puzzles and opening chests, so much so you will receive a boost (time, success rate) when picking chests when Tanlorin is your active companion.";

	FarmersToolkit.CompanionNotesLikes["Zerith-var"]="Daily Northern Elsweyr Defense Force, destroying dark anchors, playing Tribute or doing the daily Tribute quest, killing vampires or skeletons, and heavy sacks (don't judge)\n"
	FarmersToolkit.CompanionNotesDislikes["Zerith-var"]="Filling soul gems (Soul Gem/Soul Trap, etc.), Selling/Laundering stolen goods, murdering civilians (or using the Blade of Woe),anything with Corrupting Bloody Mara or tomato juice\n"
	FarmersToolkit.CompanionNotesBuffs["Zerith-var"]="Zerry (to his friends) really likes heavy sacks (don't judge!) and so, when equipped, heavy sacks may glow for improved detection.";

	
end
-- end of FarmersToolkit.ResetList


-- Note: FarmersToolkit.FindCollectibles was removed from the source code (V240128d)
-- Note: FarmersToolkit.ListItems was removed from the source code (V240128d)

--
-- Function to count the number of items in the table
local function tableLength(T,atype)
    -- dft_debug("tL: type="..type(atype));
    local count = 0
    local tcount = 0
    local tflag=0;
    if ( type(atype) == string ) then
	if ( atype == "true" ) then
		tflag = 1;
	end
    end

        for _ in pairs(T) do 
                count = count + 1 
		if ( tflag == 1 ) then tcount = tcount+1 ; end
        end
        return count,tcount
end

-- There is probably a way to do this more sanely but.. lua... not yet fluent.
local function searchCaseInsensitive(text, searchString)
    -- Convert both the text and search string to lowercase for case-insensitive comparison.
    local lowercaseText = string.lower(text)
    local lowercaseSearchString = string.lower(searchString)
 
    -- Use the Lua pattern matching to find the search string in the text.
    -- The pattern "%f[%a]" is used to match the start of a word, and "%f[^%a]" is used to match the end of a word.
    -- This ensures that the search string is matched as a whole word and not as part of another word.
    local pattern = "%f[%a]" .. lowercaseSearchString .. "%f[^%a]"
    local match = string.match(lowercaseText, pattern)
 
    -- If a match is found, return true. Otherwise, return false.
    if match then
        return true
    else
        return false
    end
end
-- end searchCaseInsensitive

-- Function to list out current targets (TIDCount)
-- List out current targets (TIDCount)
function FarmersToolkit.ListTargetCounts(arg1) 

	-- dft_debug("FTK:ListTargetsCount(" .. arg1 .. ") called");
	local key
	local val
	local k3 -- Debugging variable, to be removed once code is stable(r)
	local value -- Used below, needs a better name
	local target_count=0; -- Might need to move this into FarmersToolkit at some point.

        local retval_header="|cFFFF00   == Farming List ==\n|r\n";

	if ( FarmersToolkit.FLShrink == 3 ) then
        	retval_header="|cFFFF00   == Farming / Shopping Abbreviated List ==\n|r\n";
	end

	local retval="";

	local screen_result_count=0; -- How many lines could produce screen-oriented results
	local onscreen_result_count=0; -- How many lines actually produced screen-oriented results
	-- This loop originally called orderedpairs but was not actually in alphabetic order.  Needs more work.
	-- This.... wow, this is an embarrasing amount of work just to produce an alphabetic list of targets....
	local TIDNameAlpha = {};

	if ( FarmersToolkit.TIDName ~= nil ) then
	for key, val in pairs(FarmersToolkit.TIDName) do
	    if ( ( key ~= nil) and ( val ~= nil ) ) then
		local textname = GetItemLinkName(val)
		local textname2 = string.format("%-50s:%s",textname,key);
		table.insert(TIDNameAlpha, textname2);
	    end
	end
	end
        table.sort( TIDNameAlpha )
	
	 local TCounter=1;
	 for key1, val1 in orderedPairs(TIDNameAlpha) do
	 	local key=tonumber(string.sub(val1,52))
		local val=FarmersToolkit.TIDCount[key]

		screen_result_count = screen_result_count + 1;

		--Hopefully unnecessary cleanup
		key=tonumber(key);
		value=tonumber(value);
		local aname=FarmersToolkit.TIDName[key]; 		-- This is the name 
		local acount = FarmersToolkit.SessionCount[key];	-- How many do we have
		local atarget = val;					-- How many do we seek

		acount=tonumber(acount);
		atarget=tonumber(atarget);

		if ( aname == nil ) then -- we may not have farmed any yet, check to see if this is in TIDName
		    if ( FarmersToolkit.FarmListNames[key] ~= nil ) then
			aname = FarmersToolkit.FarmListNames[key]
			-- dft_debug("aname was blank, setting to TIDName entry (" .. key .. "/" .. type(key) .. "): " .. aname);
		    end
		end

		if ( acount == nil ) then -- It is possible for acount to not be set, we may have not farmed any yet
			acount=0;
		end

		if ( atarget == nil ) then -- We may not have set a target... but why would this be listed then?  Celebrate every find.

			-- dft_debug("atarget was blank, setting to default");
			atarget=0;
		end

		-- We have the variables set, let's add some logic and print results....
		-- There are three types of results, depending on the argyument passed to the function
		-- 	chat - text based result showing all targets info, suitable for presenting in chat 
		-- 	       Shwows everything: targets of 0, clickable links, long lines, etc.
		-- 	header - Just give the (screen)  header line for this group.
		-- 		 (Right now, it is a static line.  I am hoping to make it more functional.  Eventually.)
		-- 	screen - A tailored list of "currently active" shopping list items, meaning an entry
		-- 		1 - Has  a target > 0 ( is not just a celebration)
		-- 		2 - Has a count that is less than the target 
		--
		local response="";

		response = response .. " -- " .. aname .. " (" .. key .. "): ";
		response = response .. " Have " .. acount;
		
		if ( atarget == 0 ) then
			response = response .. ", will celebrate every time one is found."
		else 
			if ( acount >= atarget ) then
				response = response .. ",|c00FF00 needed " .. atarget .. ", goal met!" .. "|r"
			else
				response = response .. ", targetted " .. atarget .. "  (" .. (atarget - acount) .. " to go)"
			end
		end


		if ( arg1 == "chat" ) then
			dft(response);
		elseif ( arg1 == "header" ) then
			retval=retval_header;

		else  -- this is a screen formatted output

		    -- Trying out a "shrink" option her	e
		    if ( FarmersToolkit.FLShrink == 1 ) then
			    return "FT Shopping List Minimized"
		    end
			    
		    onscreen_result_count = onscreen_result_count + 1;

		    if ( ( atarget > 0 ) and (acount < atarget ) ) then -- only show "active" shopping list items


			if ( FarmersToolkit.FLShrink == 3 ) then
				if ( acount > 0 ) then
					-- retval = retval .. string.format(" ++ %3d. %50s: %d / %d  (%3.2f%%)\n", screen_result_count, aname, acount, atarget, ((acount / atarget ) *100) )
					retval = retval .. string.format(" ++ %3d. %50s: %d / %d  (%3.2f%%)\n", screen_result_count, aname, acount, atarget, ((acount / atarget ) *100) )
				else
					-- retval = retval .. string.format(" XX %3d. %50s: %d / %d  (%3.2f%%)\n", screen_result_count, aname, acount, atarget, ((acount / atarget ) *100) )
				end
			else
				-- retval = retval .. string.format(" -- %3d. %50s: %d / %d  (%3.2f%%)\n", screen_result_count, aname, acount, atarget, ((acount / atarget ) *100) )
				retval = retval .. string.format("\n -- %3d. %50s: %d / %d  (%3.2f%%)", screen_result_count, aname, acount, atarget, ((acount / atarget ) *100) )
			end -- else/if mode 3

		    end -- if target > 0 and count < target (actives)

		end -- else/this is screen output


	end -- end for TIDCount



	-- ow process TYPE farming results
		
	local sub_line_count = 0
	local sub_retval = ""	

	if 
		(type(FarmersToolkit.TargetTypeCount) ~= "nil") 
		and (type(FarmersToolkit.TargetTypeSoFar) ~= "nil") 
		and (type(FarmersToolkit.TIDCount) ~= "nil") 
		-- and (#retval > 50 ) -- This needs to be improved
		-- and (screen_result_count > 3 ) -- This needs to be improved

 	then
		if ( not FarmersToolkit.DebugVariable1 ) then 
			FarmersToolkit.DebugVariable1 = 1;
		else
			FarmersToolkit.DebugVariable1 = FarmersToolkit.DebugVariable1 + 1;

		end

		

		local sortedKeys = {}

    		-- Collect all keys with values greater than 0
    		for key, value in pairs(FarmersToolkit.TargetTypeCount) do
        		if value > 0 then
            		table.insert(sortedKeys, key)
        		end
    		end
		
    		-- Sort keys alphabetically
    		table.sort(sortedKeys)
	
    		-- Print each key and its value
		local active_screen_lines=0;
    		for _, key in ipairs(sortedKeys) do
			-- screen_result_count = screen_result_count +1;
        		-- dft(key .. ": " .. targetTable[key])
			local atarget = FarmersToolkit.TargetTypeCount[key]; 
			local acount = FarmersToolkit.TargetTypeSoFar[key];  if ( type(acount) == "nil" ) then acount=0 end

			if ( atarget > acount ) and ( atarget > 0 ) then
				sub_line_count = sub_line_count +1;

 			        -- Ok, decision time.  The original numbering system for farming lists had numbers to items and when an item target was met, it ws removed
				--     but the numbers themselves would stay the same.  Which was handy. 
				-- However, with the introduction of type tracking (and wildcards further complicating things), this approach isn't quitre as clean
				-- So, for now, we have three choices:
			        --     Option 1 - continue the numbers from the previous section
				--     Option 2 - restart the numbers under type tracking and just go with 1,2,3....
				--     Option 3 - Don't use numbers for the onscreen entries

			        -- Note to future self/authors.  Uncomment only one of the lines below.
				-- Option 1 line
				-- sub_retval = sub_retval .. string.format("\n|cFFA500 == %3d. %s: %d / %d  (%3.2f%%) [T]|r", sub_line_count+screen_result_count, key, acount, atarget, ((acount / atarget ) *100) )

				-- Option 2 line
				-- sub_retval = sub_retval .. string.format("\n|cFFA500 == %3d. %s: %d / %d  (%3.2f%%) [T]|r", sub_line_count+screen_result_count, key, acount, atarget, ((acount / atarget ) *100) )

				-- Option 3 line

				if ( FarmersToolkit.FLShrink == 3 ) then
					if ( acount > 0 ) then
						sub_retval = sub_retval .. string.format("\n|cFFA500 == %s: %d / %d  (%3.2f%%) [T]|r", key, acount, atarget, ((acount / atarget ) *100) )
						active_screen_lines = active_screen_lines+1;
					end
				else 
					sub_retval = sub_retval .. string.format("\n|cFFA500 == %s: %d / %d  (%3.2f%%) [T]|r", key, acount, atarget, ((acount / atarget ) *100) )
					active_screen_lines = active_screen_lines+1;
				end
			end
    		end

		-- Finally, if we have anything new from the tracking block, add it to retval now
		-- if ( ((sub_line_count > 0) or (FarmersToolkit.FLShrink == 2))  and sub_retval ~= "" ) then 
		if ( sub_retval ~= "" ) then 
			-- retval = retval .. "\n\n\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nType tracking data (Active: " .. sub_line_count .. ")" .. sub_retval 
			sub_retval = "\n\nType tracking data (Active: " .. active_screen_lines .. " of " .. sub_line_count .. ")" .. sub_retval 
		end
	end
	

	if ( arg1 == "header") then return retval end

	if ( arg1 == "screen") then 
		if ( onscreen_result_count+sub_line_count == 0 ) then -- we had no entries to report on-screen
			-- return "\n\n " .. FarmersToolkit.FTChat .. "All farming targets have been met.\n"; 
			return FarmersToolkit.FTChat ..  " All farming targets have been met.\n"; 
		else
			-- return "\n\n" .. retval -- Leave some space for the header
			retval = string.match(retval, "^(.-)\n?$") -- Trim trailing newline
			-- return "" .. retval  .. sub_retval .. " SRC: " .. screen_result_count .. " and SLC: " .. sub_line_count-- No longer need to some space for the header
			 return "" .. retval  .. sub_retval -- No longer need to some space for the header
		end
	end

	local chat_retval = ""	
	-- dft_debug("FTK:LTC>> Chat request for targets prepping: chat_retval is of type " .. type(chat_retval) .. " and arg1 = " .. arg1);
	if ( type(chat_retval) == "string") then 
		-- dft_debug("FTK:LTC(pre-chat)>> chat_retval = [" .. chat_retval .. "]") 	
	end

	if ( arg1 == "chat") and ( chat_retval == "" ) then -- if chat and nothing was built from above....

		-- dft_debug("FTK:LTC>> Chat request for targets executing");
		local sortedKeys = {} ;
	
    		-- Collect all keys with values greater than 0
    		for key, value in pairs(FarmersToolkit.TargetTypeCount) do
       			if value > 0 then
           			table.insert(sortedKeys, key)
			-- dft_debug("FTK:LTC(Chat)>> Inserting " .. key .. " into stack");
       			end
    		end
		
    		-- Sort keys alphabetically
    		table.sort(sortedKeys)

		-- Print each key and its value
   		for _, key in ipairs(sortedKeys) do
			-- screen_result_count = screen_result_count +1;
       			-- dft(key .. ": " .. targetTable[key])
			local atarget = FarmersToolkit.TargetTypeCount[key]; 
			local acount = FarmersToolkit.TargetTypeSoFar[key];  if ( type(acount) == "nil" ) then acount=0 end

			-- chat_retval = chat_retval .. "\n" .. FarmersToolkit.FTChat .. string.format(" == %3d. [TYPE] %s: %d / %d  (%3.2f%%)", screen_result_count, key, acount, atarget, ((acount / atarget ) *100) .. "|r")
			-- sub_retval = sub_retval .. string.format("\n|c80DFFF == %3d. %s: %d / %d  (%3.2f%%) [T]|r", screen_result_count, key, acount, atarget, ((acount / atarget ) *100) )
			chat_retval = chat_retval .. "\n" .. FarmersToolkit.FTChat .. string.format("|r|cFFA500 == %s (Type): %d / %d  (%3.2f%%)|r", key, acount, atarget, ((acount / atarget ) *100) )
			-- dft_debug("FTK:LTC(Chat)>> Extending chat_retval for " .. key);
    		end
	
		if ( chat_retval ~= "" ) then dft("\n" .. FarmersToolkit.FTChat .. "|r|cFFA500 Tracking by Type:|r\n" .. chat_retval) end

	end

end --  ListTargetCount


-- Setting targets is probably going to get more complicated than it is right now but the
-- following two functions are nonetheless commented out because they are not (yet?)
-- needed.  
-- The current approach sets targets via chat (though with some help from LibCustomMenu,
-- if available).  
--

-- Function to find duplicates between bags and bank slots
--

function FarmersToolkit.InvDuplicate(mincount)


-- dft("Min count as passed is " .. type(mincount));

-- Set default value to 5.  Meaning (I think) if you 
-- have 5 or fewwer items in your bag that also shows up in your 
-- bank, show them.
--
-- mincount's purpose is to show (by default) items in your bag
-- that are likely not intentional duplicates.  So, if you have
-- 20 of somethign in your bags and some in the bank, it is probably
-- intentional (food, potions, repair kits, whatever).  
--
-- I think that's what I meant to code.  Pretty sure.  Probably.
--

if ( mincount == nil ) then mincount = 5 end
mincount=tonumber(mincount);

local DupList = {}
local DupCount  = 0;

local numSlots  = 0;

local TempBagCount  = 0;
local TempBank1Count  = 0;
local TempBank2Count  = 0;

local tlink = ""
local tlink2 = ""
local tlink2 = ""
local tlink3 = ""
local TLinkID = ""

local TempBagList = {}
local TempBank1List = {}
local TempBank2List = {}

local NameBagList = {}
local NameBank1List = {}
local NameBank2List = {}

dft("Scanning backpack vs. bank for duplicate items in your bag wth a stack count of " .. mincount .." or less.");
-- Step 1: Go through BANK BAG and build a list of what we have
     	numSlots = GetBagSize(BAG_BANK)
	for bSlot = 1, numSlots do
		tlink2  = GetItemLink(BAG_BANK, bSlot)
		-- dft("Bank 1: tlink2=" .. tlink2);
		if ( tlink2 == "" ) then break end
		
		tlink3 = tlink2;
		tlink3 = string.gsub(tlink3,"|","+");
		TLinkID= string.match(tlink2, "|H%d+:item:(%d+):")
		TLinkID=tlink2; --  Use the ENTIRE STUPID LINK because ItemID is NOT unique.  smh.

		if ( TLinkID == 0 ) then break end

		-- dft("Scanning Bank 1, slot " .. bSlot .. " - Found: " .. tlink2 .. " (" .. TLinkID .. ")");

		NameBank1List[TLinkID] = tlink2;

		TempBank1Count = TempBank1Count +1 ;
		local yicon, ystack, ysellPrice, ymeetsUsageRequirement, ylocked, yequipType, yitemStyleId, yquality = GetItemInfo(BAG_BANK, bSlot)
		if type(TempBank1List[TLinkID]) ~= "nil" then 
			-- dft("Bank1: " .. bSlot .." Moving " .. TLinkID .. " / " .. tlink2 .. " from " .. TempBank1List[TLinkID] .. " up by " .. ystack .. ". Link data: " .. tlink3); 
			TempBank1List[TLinkID]=TempBank1List[TLinkID]+ystack; 
		else 
			TempBank1List[TLinkID]=ystack; 
			-- dft("Bank1: " ..bSlot .. " Setting " .. TLinkID .. " / " .. tlink2 .. " to " .. TempBank1List[TLinkID] .. " as initial ystack of " .. ystack .. ". Link data: " .. tlink3);
		end
	end
	-- dft_debug("Bank 1 scanned, " .. TempBank1Count .. " slots found.");

-- Step 2: Go through BANK SUBSCIBER to build a list of what we have
     	numSlots = GetBagSize(BAG_SUBSCRIBER_BANK)
	for bSlot = 1, numSlots do
		tlink2  = GetItemLink(BAG_SUBSCRIBER_BANK, bSlot)
		-- dft("Bank 2: tlink2=" .. tlink2);
		if ( tlink2 == "" ) then break end
		
		tlink3 = tlink2;
		tlink3 = string.gsub(tlink3,"|","+");
		-- TLinkID= string.match(tlink2, "|H%d+:item:(%d+):")
		-- TLinkID=tlink2;
		TLinkID=tlink2; --  Use the ENTIRE STUPID LINK because ItemID is NOT unique.  smh.

		if ( TLinkID == 0 ) then break end

		-- dft("Scanning Bank 2, slot " .. bSlot .. " - Found: " .. tlink2 .. " (" .. TLinkID .. ")");

		NameBank2List[TLinkID] = tlink2;

		TempBank2Count = TempBank2Count +1 ;
		local yicon, ystack, ysellPrice, ymeetsUsageRequirement, ylocked, yequipType, yitemStyleId, yquality = GetItemInfo(BAG_SUBSCRIBER_BANK, bSlot)
		if type(TempBank2List[TLinkID]) ~= "nil" then 
			--dft("Bank2 - Moving " .. TLinkID .. " / " .. tlink2 .. " from " .. TempBank2List[TLinkID] .. " up by " .. ystack .. " due to Bank2 slot " .. bSlot);
			-- dft("Bank2: " .. bSlot .." Moving " .. TLinkID .. " / " .. tlink2 .. " from " .. TempBank2List[TLinkID] .. " up by " .. ystack .. ". Link data: " .. tlink3); 
			TempBank2List[TLinkID]=TempBank2List[TLinkID]+ystack; 
		else 
			TempBank2List[TLinkID]=ystack; 
			--dft("Bank 2 - Setting " .. TLinkID .. " / " .. tlink2 .. " to " .. TempBank2List[TLinkID] .. " as initial ystack of " .. ystack .. " due to Bank2 slot " .. bSlot);
			-- dft("Bank2: " ..bSlot .. " Setting " .. TLinkID .. " / " .. tlink2 .. " to " .. TempBank2List[TLinkID] .. " as initial ystack of " .. ystack .. ". Link data: " .. tlink3);
		end
	end
	-- dft_debug("Bank 2 scanned, " .. TempBank2Count .. " slots found.");

-- Step 3: Go through backpack (BAG_BACKPACK) to build a list of what we are carrying

     	numSlots = GetBagSize(BAG_BACKPACK)
	-- dft("Bag backpack has " .. numSlots .. " slots");
	for bSlot = 1, numSlots do
		tlink2  = GetItemLink(BAG_BACKPACK, bSlot)
		-- dft("Bank 3/Backpack(" .. bSlot .. "): tlink2=[" .. tlink2 .."]");
		-- if ( tlink2 == "" ) then break end
		if ( tlink2 == "" ) then tlink2="EMPTYSLOT" end
		
		tlink3 = tlink2;
		tlink3 = string.gsub(tlink3,"|","+");
		TLinkID= string.match(tlink2, "|H%d+:item:(%d+):")
		TLinkID=tlink2; --  Use the ENTIRE STUPID LINK because ItemID is NOT unique.  smh.

		if ( TLinkID == 0 ) then dft("I am (for some reason) skipping " .. tlink2 .. " in bag slot " .. bSlot); end
		-- if ( TLinkID == 0 ) then break end

		-- dft("Scanning backpack, slot " .. bSlot .. " - Found: " .. tlink2 .. " (" .. TLinkID .. ")");

		NameBagList[TLinkID] = tlink2;

		TempBagCount = TempBagCount +1 ;
		local yicon, ystack, ysellPrice, ymeetsUsageRequirement, ylocked, yequipType, yitemStyleId, yquality = GetItemInfo(BAG_BACKPACK, bSlot)
		if type(TempBagList[TLinkID]) ~= "nil" then 
			--dft("Backpack - Moving " .. TLinkID .. " / " .. tlink2 .. " from " .. TempBagList[TLinkID] .. " up by " .. ystack .. " due to slot backpack " .. bSlot);
			-- dft("Backpack: " .. bSlot .." Moving " .. TLinkID .. " / " .. tlink2 .. " from " .. TempBagList[TLinkID] .. " up by " .. ystack .. ". Link data: " .. tlink3); 
			TempBagList[TLinkID]=TempBagList[TLinkID]+ystack; 
		else 
			TempBagList[TLinkID]=ystack; 
			--dft("Backpack - Setting " .. TLinkID .. " / " .. tlink2 .. " to " .. TempBagList[TLinkID] .. " as initial ystack of " .. ystack .. " due to backpack slot " .. bSlot);
			-- dft("Backpack: " ..bSlot .. " Setting " .. TLinkID .. " / " .. tlink2 .. " to " .. TempBagList[TLinkID] .. " as initial ystack of " .. ystack .. ". Link data: " .. tlink3);
		end
	end
	-- dft_debug("Backpack scanned, " .. TempBagCount .. " slots found.");

-- Step 4: Compare lists from 1&2 against 3, report duplicates
--

     local tVarBag=0 
     local tVarBank1=0
     local tVarBank2=0
     local TDisplay="";
     local AddendumText="";
     for key, val in orderedPairs(TempBagList) do
     	     tVarBag=0 
     	     tVarBank1=0
     	     tVarBank2=0
	      -- dft("Bag has TLinkID = " .. key .. " and a value of " .. val .. " for " .. NameBagList[key]);
	     if NameBagList[key] then 
		     -- dft("   -- Bag Name = [" .. NameBagList[key] .. "] with a count of " .. TempBagList[key]) 
		     tVarBag=TempBagList[key];
	     else 
		     -- dft("   -- Bag Name N/A (no matching entry)"); -- This should really never happen. 
	     end
	     if NameBank1List[key] then 
		     -- dft("   -- Bank1 Name = [" .. NameBank1List[key] .. "] with a count of " .. TempBank1List[key]) 
		     tVarBank1=TempBank1List[key];
	     else 
		     -- dft("   -- Bank1 Name N/A (no matching entry)"); 
	     end
	     if NameBank2List[key] then 
		     -- dft("   -- Bank2 Name = [" .. NameBank2List[key] .. "] with a count of " .. TempBank2List[key]) 
		     tVarBank2=TempBank2List[key];
	     else 
		     -- dft("   -- Bank2 Name N/A (no matching entry)"); 
	     end

	     if (
		     ( tVarBag > 0 ) -- This should always happen
		     and ( 
		     		( tVarBank1 > 0 ) -- This could happen
			or
		     		( tVarBank2 > 0 ) -- This could happen
			)
		) then
			local key2 = string.gsub(key,"|","+");

			local pattern = "^|H[01]:item" .. string.rep(":[^:]+", 14) .. ":([^:]+)"
			local str2 = string.match(key, pattern)
			local DupTxt=""

	     		if (IsItemLinkUnique(key) == true ) then 
				AddendumText = AddendumText .. "   [ " .. key .. " ] ";
				-- dft_debug("=== Skipping unique item: " .. key); 
			end

			if ( type( str2 )  == "nil" ) then str2="BLANK"; end

			local flagcheck=tonumber(str2);

			if ( flagcheck ==  65 ) then DupTxt = "  (Note: Item flag set to 65, crown item?)";
			  elseif ( flagcheck ==  129 ) then DupTxt = "  (Note: Item flag set to 129, crown item?)";
			  elseif ( tonumber(str2) > 1 ) then DupTxt = "  (Note: Item flag set to " .. str2 .. ")"; 
			end

			local banktotal=tVarBank1+tVarBank2;
			-- if ( banktotal - tVarBag >= mincount )  then 
			-- tVarBag = # of items in  your bags
			--
			-- So if the number of items in your bags is less than or equal to mincount (passed by arg or set to 1), show the list
			-- which also means if you have 5 of something in your bag but mincount = 1, it will NOT show up in the list
			-- (I'm not sure this makes sense.  I remember changing it several times.  Probably needs more thought and clarity)
			-- if ( tVarBag <= mincount )   then 
			if ( tVarBag <= mincount )  and ( IsItemLinkUnique(key) == false) then 
				-- dft("------- Potential duplicate item: " .. NameBagList[key] .. " - Backpack has " .. tVarBag .. ", Bank has " .. (tVarBank1+tVarBank2) .. " (" .. key2 .. " / " .. str2 .. ")");
				-- dft("------- Potential duplicate item: " .. NameBagList[key] .. " - Backpack has " .. tVarBag .. ".        Bank has " .. comma_value(banktotal) .. DupTxt );
				--
				TDisplay = "Bag: " .. comma_value(tVarBag) .. " / Bank: " .. comma_value(banktotal) ;
				dft("---- " .. FarmersToolkit.fixwidth2(TDisplay,40) .. "    "  .. NameBagList[key] .. " " .. DupTxt .. "")

		   		-- dft(" -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 60) ..  ": " .. FarmersToolkit.fixwidth2(val2,80) .. PriceInfoString)
				-- .. NameBagList[key] .. " - Backpack has " .. tVarBag .. ".        Bank has " .. comma_value(banktotal) .. DupTxt );
				
				DupCount = DupCount+1;
			end
             end
     end

     if (AddendumText ~= "" ) then dft("Unique duplicates (e.g., items that don't stack in the bank) that you may want to consider using, selling or destroying: " .. AddendumText); end

     if (DupCount == 0 ) then
	dft("No duplicates found, good job!  Consider expanding the surch to stacks more than " .. mincount .. "  -- /ft dupes NN     ( where NN > " .. mincount .." )");
     else 
	dft("Potential backpack slots freed up: " .. DupCount);
     end

end -- FarmersToolkit.InvDuplicates

function FarmersToolkit.ListHints ( searchterm ) 

	if ( type(searchterm) == "nil" ) then searchterm=""; end
	if ( type(FarmersToolkit.Hints) == "nil" ) then dft("Error: Hints table is blank!") return end
	
	local arg1=searchterm
	if ( arg1 ~= "" ) then
		dft("Listing known hints / locations matching [ " .. arg1 .. " ] ");
	else 
		dft("Listing known hints / locations");
	end



        for key, val in orderedPairs(FarmersToolkit.Hints) do
	  -- dft("  --- " .. FarmersToolkit.fixwidth2(key,40) .." " .. val);

	  if ( arg1 ~= "" ) then
		-- -- d("FT-DEBUG 0-A: Converting key=[" .. key .. "] and arg1 =[" .. arg1 .. "]");
		local astr=string.lower(key); 
		local tofind=string.lower(arg1);
		
		-- -- d("FT-DEBUG 0-B: Looking for [" .. tofind .. "] in [" .. astr .. "]");
		if ( string.find(astr,tofind,1,plain))  then
			dft("  --- " .. FarmersToolkit.fixwidth2(key,40) .." " .. val);
		end
	   else
		dft("  --- " .. FarmersToolkit.fixwidth2(key,40) .." " .. val);
	   end	
	end	

end

-- Function to show (a more detailed set of ) information about currently farmed items
--  This is the same as ListFarmedItems (function below) but also shows the LinkID in the output
--  (On the to do list, change the name of the function. Or merge back to the original.  Some day.  Soon.  I swear.)
function FarmersToolkit.ListFarmedItemsDebug ( farmarray ) 
     FarmersToolkit.ft_count=0;  

     local arg1=farmarray

     if ( FarmersToolkit.FTREP == 1 ) then
          dft("Farming reporting is on (turn off via /ft chatoff)");
     else 
          dft("Farming is off (turn on via /ft chaton)")
     end

     dft("Gold gained this session: " .. comma_value(FarmersToolkit.TotalGoldGain) .. ", total: " .. comma_value(FarmersToolkit.NewGoldCount))

     local f2=FarmersToolkit.FarmList;

     local fllcount=1;
     local numSlots;
     local tlink2;
     local TLinkID;
     local bSlot; -- Might be overkill here.  Loop variables may be locally scoped by definition.

     -- dft("Farmed items so far: ");



     -- Let's try something here: identify items which reside in the backpack and somewhere else
	FarmersToolkit.InvDuplicate();


     -- Finally, having built the various inventories, run through the farming list
    
     local TDisplay
     local tmpstring

     dft("Farmed items so far: ");
     for key, val in orderedPairs(FarmersToolkit.FarmNameByLinkID) do
        local val2=f2[val]; -- Need a better name and proper scoping
	FarmersToolkit.ft_count=FarmersToolkit.ft_count+1;

	-- dft_debug("FT-DEBUG 0 : arg1=(" .. arg1 .. ")    arg1 type: " .. type(arg1) .. "  key type: " .. type(key))
        -- dft_debug("FT-DEBUG 1 key=(" .. key .."): val2=[" .. val2 .. "] val=[" .. val .."]");

	-- BagFlag is at least one place this item might be (I'm not going to stress over item X in more than 1 bag.  Yet.)
	local BagFlag=" ";
	
	-- d("FTXX - Type check of TempCheck[" .. val .. "] = " .. type(TempCheck[val]))

	-- Inexplicably, some of the TempCheck entries were null.  Why? How?  No idea.  Yet.
	-- Annoying.  I think the culprit was identical-appearing keys that were sometimes int, sometimes string.
	if TempCheck and ( type(TempCheck[val])  == "number" ) then
		-- dft_debug("XXX Found a numeric TempCheck entry for " .. val .. ": " .. TempCheck[val]);
		BagFlag=" (?) ";

		if ( TempCheck[val] == 1 ) then BagFlag=" (I) "; end
		if ( TempCheck[val] == 2 ) then BagFlag=" (B) "; end
		if ( TempCheck[val] == 3 ) then BagFlag=" (Cb) "; end

		-- dft_debug("FT-X: Comparing [" .. TempCheck[val] .. "] = [" .. val  .. "]");
		-- dft_debug("I think " .. key .. " matched / is in the bagpack ")
	end


       -- Add in pricing info, if available
       local aprice=FarmersToolkit.PriceInfo(key);
       local PriceInfoString="";
       if ( aprice ~= "" ) then PriceInfoString=", " .. aprice; end

       -- dft_debug("PXXX: key=["..key.."], aprice=["..aprice.."]. PriceInfoString=["..PriceInfoString.."], val=[" .. val .."], val2=["..val2.."]")

	--  Still support keyword search (e.g., something was passed to this function as a search streng)
	if ( arg1 ~= "" ) then
		-- -- d("FT-DEBUG 0-A: Converting key=[" .. key .. "] and arg1 =[" .. arg1 .. "]");
		local astr=string.lower(key); 
		local tofind=string.lower(arg1);
		
		-- -- d("FT-DEBUG 0-B: Looking for [" .. tofind .. "] in [" .. astr .. "]");
		if ( string.find(astr,tofind,1,plain))  then
			TDisplay = val .. BagFlag
			dft(string.format(" -- Search Item # %15s: %s", TDisplay, val2))
		else
			-- -- d("Not found for [" .. val2 .. "]")
		end
	else	
		if ( type(val) ~= "number") then dft("--- val is of type " .. type(val)) end
		   TDisplay = val .. BagFlag
		   if not val2 then val2 = "[TBD]" end
		   -- dft(" -- Item # "  .. fixwidth(TDisplay, 11) ..  ": " .. val2 .. PriceInfoString) -- 
		   -- dft(" -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 60) ..  ": " .. FarmersToolkit.fixwidth2(val2,80) .. PriceInfoString)
		   -- dft(" -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 60) ..  ": " .. FarmersToolkit.fixwidth2(key,80) .. PriceInfoString)
		   -- tmpstring= " -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 30) ..  ": " .. FarmersToolkit.fixwidth2(key,60) .. "[" .. PriceInfoString .. "]"
		 


		   -- So this next step is ugly but it works (kinda theme for this whole file...)
		   -- The link is a string that is much linger than just the name so we can't pad based on that
		   -- So instead, we pad on the short/text name (key), get things formatted, then swap in the link
		   
		   -- tmpstring= " -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 30) ..  " " .. FarmersToolkit.fixwidth2(key,60) 
		   tmpstring= " -- Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 30) ..  " " .. key
		   tmpstring = string.gsub(tmpstring,key,val2);
		   -- dft("Debug.  key type=" .. type(key) .. " and va2 type = " .. type(val2));
		   dft (tmpstring .. PriceInfoString);
		   
		  -- dft(" -- XXX-Item # "  .. FarmersToolkit.fixwidth2(TDisplay, 60) ..  ": " .. FarmersToolkit.fixwidth2(key,80) .. "[" .. PriceInfoString .. " / " .. aprice .. "]")
	end

     end

     -- Check / Create a Duplicate Slot usage text
     -- if ( DupCount > 0 ) then
     -- dft("Note: Duplicate bag usage detected.  Slots potentially opened: " .. DupCount);
     -- end

     dft("Total  types farmed: " .. comma_value(FarmersToolkit.ft_count) .. ", total items: " .. comma_value(FarmersToolkit.tvalue) .. ", Unique: " .. comma_value(FarmersToolkit.UniqueItems) .. ", Replenished: " .. FarmersToolkit.ReplenishedItems );
     dft("Total Chests looted: " .. comma_value(FarmersToolkit.Lootable["Chest"]))
     dft("Total Books read: " .. comma_value(FarmersToolkit.Lootable["Books"]))

end 
-- end of FarmersToolkit.ListFarmedItemsDebug 



function FarmersToolkit.LaunchRandomPet2 (PetArgs)
     -- Generate a random index
     if ( not FarmersToolkit.FPetList) then 
	     -- dft_debug("FTK-LRP2: Calling FTK.LoadFPetList because FTK.FPetList doesn't exist?")
     	if ( not FarmersToolkit.FPetList) then 
		-- dft_debug("Confirming call that FPEtlist doesn't exit, type = " .. type(FarmersToolkit.FPetList)) 
	end
	     FarmersToolkit.LoadFPetList("override"); 
     end
     -- myTable = FarmersToolkit.FPetList;
     local randomIndex = math.random(1, tableLength(FarmersToolkit.FPetList))

                               
     -- dft_debug("FPetList table length:".. tableLength(FarmersToolkit.FPetList,"true"))
     -- dft_debug("randomIndex:" .. randomIndex)

     -- Find the corresponding numeric index
     local currentIndex = 0
     local chosenIndex = "UNSET"
     local BackupPlan=0;
     -- local chosenName
     local FoundTruePets = 0; -- Count the number of pets that are set to TRUE (have been marked favorite)
     for index, index_name in pairs(FarmersToolkit.FPetList) do
         currentIndex = currentIndex + 1
	 if ( index_name == true ) then FoundTruePets = FoundTruePets +1; end
	     -- if ( index_name == true ) then dft_debug("Comparing " .. currentIndex .. " to " .. index .. " whose value is true"); else dft_debug("Comparing " .. currentIndex .. " to " .. index .. " whose value is FALSE"); end
	     -- dft_debug("SD1: index = " .. type(index));
	     -- dft_debug("SD1: index_name = " .. type(index_name));
	     -- dft_debug("SD1: currentIndex = " .. type(currentIndex));
	     -- dft_debug("SD1: chosenIndex = " .. type(chosenIndex));
	     -- dft_debug("SD1: chosenName = " .. type(chosenName));
             if (currentIndex == randomIndex) then
		     BackupPlan = index; -- In case we have zero pets identified as favourites
		     if ( index_name ~= false)  then
                     	chosenIndex = index
		     	local junk;
		     	if ( index_name == true ) then junk=" true " else junk = " false " end
		     	-- dft_debug("Within selection loop, matched " .. index .. " to the target of " .. chosenIndex .. " and a value of " .. junk);
			break
		     else
		        -- dft_debug("Matched the randomIndex, setting BackupPlan to be " .. BackupPlan .. " (in case we need it, aka, no favourites have been found / selected.")
		     end
             end
     end

     -- If we get to this point and FoundTruePets still = 0 then we need to invoke BackupPlan
     --      (a) something is wrong because we should never have left LaunchRandomPet
     --      (b) no pets have been marked as favourites within FPetList
     --      (c) Technically, we shouldn't have FALSE entries within FPEtList but there may be some legacy instances
     --      so..... to handle this oddness.... let's revert to pre-favourite activity
	     -- dft_debug("SD1 (Post-selection): index = " .. type(index));
	     -- dft_debug("SD1 (Post-selection): index_name = " .. type(index_name));
	     -- dft_debug("SD1 (Post-selection): currentIndex = " .. type(currentIndex));
	     -- dft_debug("SD1 (Post-selection): chosenIndex = " .. type(chosenIndex));

    -- local PetNum = randomIndex;
    if ( FoundTruePets == 0 ) then
	    chosenIndex = BackupPlan;
    end
    local PetNum = chosenIndex;
     -- dft_debug("(Post-selection) Set chosenIndex to be : " .. chosenIndex)
     -- dft_debug("(Post-selection) Set PetNum to be : " .. PetNum );

    -- Retrieve the name of the randomly chosen preferred pet
    local randomlyChosenItem = FarmersToolkit.AvailPetNames[chosenIndex]

    -- Print the randomly chosen item
    -- dft_debug("Randomly chosen index:" .. chosenIndex)
    -- dft_debug("Randomly chosen item:" .. randomlyChosenItem)
    -- dft_debug("Silly notion #2: Length of FPetList = " .. tableLength(FarmersToolkit.FPetList))

    -- If we haven't found a pet by now, try the backup plan
    if ( chosenIndex == "UNSET" ) then 
	    -- chosenIndex=BackupPlan 
	  -- dft_debug("Post selection, utterly failed to find a pet, giving up.");
	  return;
    end

    -- If we don't have a backup plan, just give up silently and reconsider our plans to learn Lua...
    if ( chosenIndex == 0 ) then 	
	  -- dft_debug("Post selection, sadly failed to find a pet, giving up.");
	  return;
    end


    -- local PetInUse = IsCollectibleActive(randomlyChosenItem) -- Was Chosenindex which is wrong.  Pretty sure it is, at least 
    -- This routine is not consistent.  Or my understanding of it is not consistent.  Either way... skipping this approach
   
    if ( type(FarmersToolkit.PetInUse) == "nil" ) then FarmersToolkit.PetInUse=-1; end
    local PetInUse=false;
    if ( PetNum == FarmersToolkit.PetInUse ) then PetInUse = true; end
	
   if ( not PetInUse ) then 

    	-- Launch the pet (if we don't already have it out there)
    	UseCollectible(chosenIndex)
    	local PetLink = GetCollectibleLink(chosenIndex, 1)

    	-- dft("Suddenly, there is a rustling from within your pack! A " .. PetLink .. " (Favorite #" .. randomIndex .. ", Pet # " .. chosenIndex .. ") emerges as your random pet")
    	dft("Suddenly, there is a rustling from within your pack! \n " .. FarmersToolkit.FTChat .. "A " .. PetLink .. " emerges as your random pet! ");
    end
end



-- Try to launch a random pet  
function FarmersToolkit.LaunchRandomPet (PetArgs)

	-- If we have turned off the random pet business in the config, just exit silently
        if ( FarmersToolkit.PETREP == 0 ) then return; end  -- If we aren't set up to dothis, don't

        -- if we have Favourite Pets defined, call / use a different function
     	if ( not FarmersToolkit.FPetList) then 
	     	-- dft_debug("FTK-LRP: Calling FTK.LoadFPetList because FTK.FPetList doesn't exist?")
     		if ( not FarmersToolkit.FPetList) then 
			-- dft_debug("Confirming call that FPEtlist doesn't exit, type = " .. type(FarmersToolkit.FPetList)) 
		end
	     	FarmersToolkit.LoadFPetList(); 
     	end
	if ( tableLength(FarmersToolkit.FPetList) > 0 ) then
		-- dft_debug("Calling LaunchRandomPet2 LaunchPet2 due to length of FPetList = " .. tableLength(FarmersToolkit.FPetList))
		FarmersToolkit.LaunchRandomPet2()
		return;
	end

	if (type(PetArgs) == "nil" ) then PetArgs="" end

	-- Do this unless it has been turned off.... unless specifically requested via the "now" argument
	if ( ( FarmersToolkit.PETREP == 0 ) and ( PetArgs ~= "now") )  then return false end

	local PetCount = GetTotalUnlockedCollectiblesByCategoryType(3) -- 3 = Non-combat pets
	local PetNum -- Will be set below but needs to have scope outside the while loop so... playing it safe here.
	local RandomNumber -- Set inside the while loop but if not declared here, local scope doesn't survive to the debug statements
	local PetUsable -- This is referenced as PetAvailable but coded as PetUsable.  User feedback, ugh.

	-- So, I can't find a way to get a list of available pets.  Even in game, they seem
	-- to be strewn across a larger set of "collectibles".  The highest # I've seen to date
	-- is 4669 (Firepot Spider Melee) so, as much as I hate this approach, we're going to
	-- just randomly guess until we land on a pet.  Since this function is to choose a
	-- random pet, this approach is... almost reasonable.  But after 20 tries, we just skip it

	local SillyApproach = 1;
	local FoundPet = false;
	while ( ( SillyApproach < 20 ) and FoundPet == false) do
	
		RandomNumber = math.random(PetCount)
		PetNum = GetCollectibleIdFromType(3, RandomNumber)
		PetUsable = IsCollectibleUsable(PetNum)
		if ( PetUsable == true ) then FoundPet = true; end

		-- OK, this routine actually works without needing the SillyApproach limit
		-- If, however, there are perfromance issues in the future.... uncomment the line below
		-- SillyApproach = SillyApproach + 1; 
	end

	if ( FoundPet == false ) then
      
		-- dft_debug("FT: Failed to find a pet after 20 tries.  Find a better method!")

		return false;
	end

	local PetLink = GetCollectibleLink(PetNum, 1)

	if ( type(FarmersToolkit.PetInUse) == "nil" ) then FarmersToolkit.PetInUse=-1; end
	-- local PetInUse = IsCollectibleActive(PetNum)
	-- IsCollectibleActiove was problematic so we're swapping with a tracking variable but keeping the boolean component for bw compat
	-- local PetInUse = IsCollectibleActive(PetNum)
	local PetInUse=false;
	if ( PetNum == FarmersToolkit.PetInUse ) then PetInUse = true; end

	-- Probably can nuke this code or shift to dft_debug once pet testing is complete
	if ( FarmersToolkit.FT_DBFLAG == 1 ) then
		d("FT-PET Dump")
		d("   - Total entries in FPetList pets = " .. tableLength(FarmersToolkit.FPetList))
		d("   - Total available pets = " .. PetCount);
		d("   - RandomNumber = " .. RandomNumber );
		d("   - PetLink = " .. PetLink );
		d("   - PetCount= " .. PetCount );
	
		if ( PetUsable == true ) then d("   - Pet is available") else  d("   - Pet is not available") end
		if ( PetInUse == true ) then d("   - Pet is in use") else  d("   - Pet is not in use") end
		-- d("   - inUse = " .. PetInUse );
		d("Note: If you can see values for PetAvailable and RandomNumber, the scope survived beyond the while loop");
	end

	-- If we have the pet and it isn't already called, use/swap to the new pet and announce it.

	if ( ( IsCollectibleUsable(PetNum) == true ) and ( FarmersToolkit.PetInUse ~= Petnum ) ) then
		UseCollectible(PetNum)
		FarmersToolkit.PetInUse=PetNum;
		dft("Suddenly, there is a rustling in your pack! \nA " .. PetLink .. " emerges as your random pet")
	else
		return false;
	end


end

-- Lists out all farmed items (along with counts, totals, etc.)
function FarmersToolkit.ListFarmedItems ( arg1 ) 
     FarmersToolkit.ft_count=0;  

     local astr
     local tofind

     if ( FarmersToolkit.FTREP == 1 ) then
          dft("Farming reporting is on (turn off via /ft chatoff)");
     else 
          dft("Farming is off (turn on via /ft chaton)")
     end

     dft("Gold gained this session: " .. comma_value(FarmersToolkit.TotalGoldGain) .. ", total for " .. FarmersToolkit.currentPlayer .. ": " .. comma_value(FarmersToolkit.NewGoldCount))

    local f2=FarmersToolkit.FarmList;
    -- On the off chance we haven't farmed anything (or laoded a nil restore point)
    if (type(f2) == "nil" ) then
	    dft("Nothing yet farmed!");
	    return
    end
    table.sort(f2)

    local fllcount=1;

     if ( ( type(arg1) ~= "nil") and ( arg1 ~= "" ) ) then
     	dft("Farmed items matching [" .. arg1 .. "] so far: ");
     else
	dft("Farmed items so far: "); 
     end

     local key, val, astr, tofind;

     for key, val in orderedPairs(FarmersToolkit.FarmNameByLinkID) do
	FarmersToolkit.ft_count=FarmersToolkit.ft_count + 1
        local val2=f2[val]; -- Need a better name and proper scoping

	if ( arg1 ~= "" ) then
		-- dft_debug("FT-DEBUG 0-A: Converting key=[" .. key .. "] and arg1 =[" .. arg1 .. "]");
		astr=string.lower(key); tofind=string.lower(arg1);
		-- dft_debug("FT-DEBUG 0-B: Looking for [" .. tofind .. "] in [" .. astr .. "]");
		
		
		if ( string.find(astr,tofind,1,plain))  then
			-- d(string.format(" -- %-9s: %s", val, val2))
		  	dft( " -- " .. val2 )
		else
			-- -- dft_debug("Not found for [" .. val2 .. "]")
		end
	else	
		if not val2 then val2="[TBD 2.0]" end
		dft( " -- " .. val2 )
		-- -- d(string.format(" -- %-9s: %s", val, val2))
	end


     end
     dft("Total  types farmed: " .. comma_value(FarmersToolkit.ft_count) .. ", total items: " .. comma_value(FarmersToolkit.tvalue));
     dft("Total Chests looted: " .. comma_value(FarmersToolkit.Lootable["Chest"]))
     dft("Total Books read: " .. comma_value(FarmersToolkit.Lootable["Books"]))

end 
-- end of FarmersToolkit.ListFarmedItems


-- This just toggles whether to show results in the chat window
function FarmersToolkit.FlipReport ( cmd ) 
     -- -- d("FT DEBUG: In FR, was passed [" .. cmd .. "]")

     if ( cmd == "on" ) then
        FarmersToolkit.FTREP=1; 
   	FarmersToolkit.savedVariables.FTREP   = FarmersToolkit.FTREP ;
        dft("Turning on FT reporting.") 
     end

     if ( cmd == "off" ) then
        FarmersToolkit.FTREP=0; 
   	FarmersToolkit.savedVariables.FTREP   = FarmersToolkit.FTREP ;
        dft("Turning off FT reporting.")  
     end

end
-- end of FarmersToolkit.FlipReport 

-- This just toggles whether to show favorite friends login in the chat window
function FarmersToolkit.FlipFriends ( cmd ) 
     -- -- d("FT DEBUG: In FF, was passed [" .. cmd .. "]")

     if ( cmd == "on" ) then
        FarmersToolkit.SHOWFRIENDS=1; 
   	FarmersToolkit.savedVariables.SHOWFRIENDS   = FarmersToolkit.SHOWFRIENDS ;
        dft("Turning on friend reporting.") 
     end

     if ( cmd == "off" ) then
        FarmersToolkit.SHOWFRIENDS=0; 
   	FarmersToolkit.savedVariables.SHOWFRIENDS   = FarmersToolkit.SHOWFRIENDS ;
        dft("Turning off friend reporting.")  
     end

end
-- end of FarmersToolkit.FlipFriends 

-- This just toggles whether to randomly launch a pet at various times
function FarmersToolkit.FlipPet ( cmd ) 
     -- -- dft("FT DEBUG: In FPet, was passed [" .. cmd .. "]")

     if ( cmd == "on" ) then
        FarmersToolkit.PETREP=1; 
   	FarmersToolkit.savedVariables.PETREP   = FarmersToolkit.PETREP ;
        dft("Turning on random pet setting.") 
     end

     if ( cmd == "off" ) then
        FarmersToolkit.PETREP=0; 
   	FarmersToolkit.savedVariables.PETREP   = FarmersToolkit.PETREP ;
        dft("Turning off random pet setting.")  
     end

end
-- end of FarmersToolkit.FlipReport 

-- Trying to make an oblivion portal detector / mapper here

-- Function to calculate the distance between two points
function FarmersToolkit.CalculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Function to calculate the direction (angle in radians) between two points
function FarmersToolkit.CalculateDirection(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

-- Function to convert radians to degrees
function FarmersToolkit.RadiansToDegrees(radians)
    return radians * (180 / math.pi)
end

-- Function to convert radians to compass direction (N, NE, E, etc.)
function FarmersToolkit.GetCompassDirection(radians)
    local degrees = FarmersToolkit.RadiansToDegrees(radians)
    if degrees < 0 then degrees = degrees + 360 end
    if degrees >= 337.5 or degrees < 22.5 then
        return "N"
    elseif degrees >= 22.5 and degrees < 67.5 then
        return "NE"
    elseif degrees >= 67.5 and degrees < 112.5 then
        return "E"
    elseif degrees >= 112.5 and degrees < 157.5 then
        return "SE"
    elseif degrees >= 157.5 and degrees < 202.5 then
        return "S"
    elseif degrees >= 202.5 and degrees < 247.5 then
        return "SW"
    elseif degrees >= 247.5 and degrees < 292.5 then
        return "W"
    elseif degrees >= 292.5 and degrees < 337.5 then
        return "NW"
    end
end

-- Function to get the distance and direction to a target location
function FarmersToolkit.GetDistanceAndDirectionToTarget(targetX, targetY)
    -- Get the player's current position
    local playerX, playerY = GetMapPlayerPosition("player")
    
    -- Calculate distance to the target
    local distance = FarmersToolkit.CalculateDistance(playerX, playerY, targetX, targetY)
    
    -- Calculate direction to the target
    local directionRadians = FarmersToolkit.CalculateDirection(playerX, playerY, targetX, targetY)
    local compassDirection = FarmersToolkit.GetCompassDirection(directionRadians)
    
    -- Output the results
    d(string.format("Distance to target: %.2f", distance))
    d("Direction to target: " .. compassDirection)
end

-- Functions to manage the list of locations
-- Utility function to get the current time as a string
function FarmersToolkit.GetCurrentTime()
    return GetTimeStamp()
end

-- Functions to save/show the current location with a note

function FarmersToolkit.GetLocation()
    local zoneName = GetUnitZone("player")
    local mapName = GetMapName()
    local x, y = GetMapPlayerPosition("player")
    local currentTime = FarmersToolkit.GetCurrentTime()

    dft("Current Locations["..zoneName.."]["..mapName.."]="..x.."/"..y..", time=" .. currentTime );
    return zoneName, mapName, x, y, currentTime;
end
function FarmersToolkit.SetLocation(note)
    local zoneName = GetUnitZone("player")
    local mapName = GetMapName()
    local x, y = GetMapPlayerPosition("player")
    local currentTime = FarmersToolkit.GetCurrentTime()

    dft("Top of setloc:  ZoneName=["..zoneName.."], mapName=[" ..mapName .."], x=" .. x .. ", y=" .. y .. ", Note=[" .. note .."]");

    if not FarmersToolkit.savedVariables.Locations then
        FarmersToolkit.savedVariables.Locations = {}
	dft("Creating savedVariables.Locations array")
    end

     if not FarmersToolkit.savedVariables.Locations[zoneName] then
         FarmersToolkit.savedVariables.Locations[zoneName] = {}
	dft("Creating savedVariables.Locations[" .. zoneName .. "]");
     end

     if not FarmersToolkit.savedVariables.Locations[zoneName][mapName] then
         FarmersToolkit.savedVariables.Locations[zoneName][mapName] = {}
	dft("Creating savedVariables.Locations[" .. zoneName .. "][" .. mapName .. "]");
     end

    if ( note == "" ) then note = "(Unnamed place of interest)"; end
    dft("Adding to Locations["..zoneName.."]["..mapName.."]="..x.."/"..y..", time=" .. currentTime .. " - Note: " .. note);


    table.insert(FarmersToolkit.savedVariables.Locations[zoneName][mapName], {
        zone = zoneName,
        map = mapName,
        x = x,
        y = y,
        note = note,
        time = currentTime
    })

    d("Location saved: " .. note)
end

-- Function to show locations based on the scope (map, zone, or all)
function FarmersToolkit.ShowLocations(scope)

local mapcallcount=0;
    if type(FarmersToolkit.savedVariables.Locations) == "nil" then 
		    dft("Locations map is undefined / has not been created.");
		    return;
    end
    if scope == "all" then
        for zoneName, maps in pairs(FarmersToolkit.savedVariables.Locations) do
            dft("All-Maps Zone: " .. zoneName)
            for mapName, locations in pairs(maps) do
                FarmersToolkit.ShowMapLocations(mapName, locations)
		mapcallcount = mapcallcount +1 ;
            end
        end
    else
        local zoneName = GetUnitZone("player")
        if scope == "zone" then
            -- d("Zone: " .. zoneName)
            dft("All-Zone Zone: " .. zoneName)
            for mapName, locations in pairs(FarmersToolkit.savedVariables.Locations[zoneName] or {}) do
                FarmersToolkit.ShowMapLocations(mapName, locations)
		mapcallcount = mapcallcount +1 ;
            end
        else
            local mapName = GetMapName()
            -- d("Map: " .. mapName)
            -- d("Zone: " .. zoneName)
	    -- if ( type(FarmersToolkit.savedVariables.Locations[zoneName][mapName]) ~= "nil" ) then
	    if FarmersToolkit.savedVariables.Locations and FarmersToolkit.savedVariables.Locations[zoneName] and FarmersToolkit.savedVariables.Locations[zoneName][mapName] then
	    	dft("SML[M=" .. mapName .. ", Z="..zoneName .. " has an entry of " .. type(FarmersToolkit.savedVariables.Locations[zoneName][mapName]))
                FarmersToolkit.ShowMapLocations(mapName, FarmersToolkit.savedVariables.Locations[zoneName][mapName] or {})
		mapcallcount = mapcallcount +1 ;
	    end
        end
    end
    if ( mapcallcount == 0 ) then dft("No map locations were found to display"); end
end

-- Utility function to display locations for a specific map
function FarmersToolkit.ShowMapLocations(mapName, locations)
    --d("  Map: " .. mapName)
    dft_debug("===================== ShowMapLocation dump");
    local index=1;
    dft(" Start of location list ----------------------------");
    for _, loc in ipairs(locations) do
        -- d(string.format("    - (%.2f, %.2f) at %s: %s", loc.x, loc.y, os.date("%c", loc.time), loc.note))
        --d(string.format("%-50s - (%.2f, %.2f) in %s:%s seen at %s: [%s]", loc.note, loc.x, loc.y, loc.zone, loc.map, os.date("%c", loc.time)),loc.note)
	--dft(string.format("%50s - (%.2f, %.2f) in %s:%s at %s", loc.note, loc.x, loc.y, loc.zone, lock.map, loc.time))
	-- if ( loc.note ~= "" ) then
		dft_debug("- Note: [" .. loc.note .."]");
		dft_debug("-  Map: [" .. loc.map .."]");
		dft_debug("- Zone: [" .. loc.zone .."]");
		dft_debug("-    X: [" .. loc.x .."]" .. " Also, type is: " .. type(loc.x));
		dft_debug("-    Y: [" .. loc.y .."]" .. " Also, type is: " .. type(loc.y));
		dft_debug("-   X2: [" .. tonumber(loc.x) .."]" .. " Also, type is: " .. type(tonumber(loc.x)));
		dft_debug("-   Y2: [" .. tonumber(loc.y) .."]" .. " Also, type is: " .. type(tonumber(loc.y)));
		dft_debug("- Time: [" .. loc.time .."]" .. "Also, type is: " .. type(loc.time));
		dft_debug("--");
		-- dft("- Attempted formatting: " .. string.format("[%50s] @ %.2f x %.2f in %s:%s",loc.note, tonumber(loc.x), tonumber(loc,y), loc,map, loc.zone))
		--dft("- Attempted formatting: " .. string.format("[%50s] in %s:%s at %.2f x %.2f, last seen: %s", loc.note, loc.map, loc.zone, loc.x, loc.y, os.date("%c",loc.time)));
		-- local result= string.format("[%-50s] in %s:%s at %.2f x %.2f, last seen: %s", loc.note, loc.map, loc.zone, loc.x, loc.y, os.date("%c",loc.time));
		local result= string.format("%-5d> [%-50s] in %s:%s at %.2f x %.2f, last seen: %s", index, loc.note, loc.map, loc.zone, loc.x, loc.y, os.date("%c",loc.time));
		index=index+1;
	-- end

	dft(result);

    end
    dft(" End of location list ----------------------------");
end

-- When needed, throw up an obnoxious screen message

function FarmersToolkit.LargeDFT(message, colorHex)
    local coloredMessage = string.format("|c%s%s|r", colorHex, message)
    -- local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)
    messageParams:SetText(coloredMessage);
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    messageParams:SetLifespanMS(7000) -- Display for 7 seconds
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    -- CENTER_SCREEN_ANNOUNCE:AddMessage(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT, CSA_CATEGORY_LARGE_TEXT, coloredMessage)
end


-- Example usage
-- ShowImmediateMessage("Immediate Red Message!", "FF0000")


-- function FarmersToolkit.OnMapUpdated()
--     local numPins = GetNumMapPins()
--     dft("Detected " .. numPins .. " in area");
--     for i = 1, numPins do
--         local pinType = GetMapPinType(i)
-- 	dft(" -- Detected pin type " .. pinType);
--         if pinType == MAP_PIN_TYPE_OBLIVION_PORTAL then
--             local x, y = GetMapPinXY(i)
--             dft("************** Oblivion Portal detected at: " .. x .. ", " .. y)
--         end
--     end
-- end

-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_MAP_PINS_UPDATED, FarmersToolkit.OnMapUpdated)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_ADD_ON_LOADED, FarmersToolkit.OnAddOnLoaded)
 
-- Next, we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.

function FarmersToolkit.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == FarmersToolkit.name then
 
    FarmersToolkit:Initialize()

  end
end

-- Calculate the width of a strong in pixels based on a supplied font (typically ZoFontChat)
function FarmersToolkit.GetStringWidth(text, font)
    local control = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
    control:SetFont(font)
    control:SetText(text)
    local width = control:GetTextWidth()
    control:SetHidden(true)
    return width
end

-- Improved settarget commands to use the GUI (if LAM is available)

-- Set a target directly from an itemLink (bypasses chat)
function FarmersToolkit.SetTargetFromLink(itemLink, newTargetCount)
    if not itemLink or itemLink == "" then
        dft("FT: SetTargetFromLink() called without an item link.")
        return
    end

    newTargetCount = tonumber(newTargetCount)
    if not newTargetCount then
        dft("FT: Target value must be a number.")
        return
    end

    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then
        dft("FT: Could not resolve itemId from link.")
        return
    end

    FarmersToolkit.TIDCount[itemId] = newTargetCount
    FarmersToolkit.TIDName[itemId]  = itemLink

    dft("Set target for " .. tostring(newTargetCount) .. " to be " .. tostring(itemLink))
    FarmersToolkit.UpdateFarmlist()
end

-- Add a small GUI prompt for settarget commands

FarmersToolkit._pendingTargetLink = nil

local function EnsureFTTargetDialog()
    if FarmersToolkit._targetDialogRegistered then return end
    FarmersToolkit._targetDialogRegistered = true

    ZO_Dialogs_RegisterCustomDialog("FT_SET_TARGET_DIALOG",
    {
        title =
        {
            text = "Farmer's Toolkit"
        },
        mainText =
        {
            text = function()
                local link = FarmersToolkit._pendingTargetLink or ""
                return "Set farming target for:\n" .. link
            end
        },
        editBox =
        {
            defaultText = "0",
            maxInputCharacters = 10,
            textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
        },
        buttons =
        {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    local value = dialog:GetNamedChild("EditBox"):GetText()
                    FarmersToolkit.SetTargetFromLink(FarmersToolkit._pendingTargetLink, value)
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        }
    })
end

function FarmersToolkit.PromptSetTarget(itemLink)
    EnsureFTTargetDialog()
    FarmersToolkit._pendingTargetLink = itemLink
    ZO_Dialogs_ShowDialog("FT_SET_TARGET_DIALOG")
end












-- This is becoming a larger function than expected, was initially just a help screen though now
-- it is the core to the command line arguments.  Ideally, every command / function in FTK should
-- be accessible via "/ft something" CLI entry
function FarmersToolkit.Help(passed_args) 

   local HArgs = {}
   for word in passed_args:gmatch("%w+") do table.insert(HArgs, word) end

   -- In some instances, we'll want the unvarnished tokens
   local tokens = {}
   for word in passed_args:gmatch("%S+") do table.insert(tokens, word) end

   local CommandsProcessed=0;

   -- Drop arg1 to lowercase to handle folks that lose fights against the CAPS LOCK monster 
   local sanity = string.lower(HArgs[1]);
   HArgs[1] = sanity;
  

   if ( HArgs[1] == "ptest" ) then  -- This is temporary code for testing PChat and formatting (please ignore if not testing)

	  dft("== This is test code, please disregard unless you are working the issue(s).  Thanks.");
	  dft( zo_strformat("<time>|u129%:0:  :|u[on/off]|u286%:0:       :|uEnables or disables the time prefix" .. "\n"));
	  dft( zo_strformat("<chat>|u125%:0:  :|u[on/off]|u288%:0:       :|uShow time prefix on regular chat" .. "\n"));
	  dft( zo_strformat("Test 1: I am here and |cFF0000apple colored|r and you |u50:0::are here|r"));
	  dft( zo_strformat("Test 2: I am here and |cFF0000apple colored|r and you |u50:0::are here|r"));
	  dft( "Test 3: I am here and |cFF0000apple colored|r and you |u50:0::are here|r - via dft");
	  d  ( "Test 4: I am here and |cFF0000apple colored|r and you |u50:0::are here|r - via d");

     dft("Proof of concept");
     local out = {}
     out[#out + 1] = "/chatmessage <command> [argument]" .. "\n";
     out[#out + 1] = "<time>|u129%:0:  :|u[on/off]|u286%:0:       :|uEnables or disables the time prefix" .. "\n";
     out[#out + 1] = "<chat>|u125%:0:  :|u[on/off]|u288%:0:       :|uShow time prefix on regular chat" .. "\n";
     out[#out + 1] = "<format>|u62%:0: :|u[auto/12h/24h]|u68%:0:  :|uChanges the time format used" .. "\n";
     out[#out + 1] = "<tag>|u165%:0:   :|u[off/short/long]|u50%:0::|uControls how a message is tagged" .. "\n";
     out[#out + 1] = "<history>|u50%:0::|u[on/off]|u286%:0:       :|uRestore old chat after login" .. "\n";
     out[#out + 1] = "<age>|u147%:0:   :|u[seconds]|u200%:0:      :|uThe maximum age of restored chat" .. "\n";
     out[#out + 1] = "Example: /chatmessage tag short" .. "\n";

     d(table.concat(out,"\n"));

	 -- dft("No tests currently scheduled.");	   

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "combattimer" ) then 
	local args=tokens[2];

	if ( type(args) == "nil" ) then args = "5m"; dft("Note: No timer given for combat timer, assuming 5 minutes"); end
	if ( args == "" ) then args = "5m"; dft("Note: No timer given for combat timer, assuming 5 minutes"); end
  	local duration = 0;
	-- Handle some simple formats
	if ( string.lower(args) == "1m" ) then args="01:00"; end
	if ( string.lower(args) == "2m" ) then args="02:00"; end
	if ( string.lower(args) == "3m" ) then args="03:00"; end
	if ( string.lower(args) == "4m" ) then args="04:00"; end
	if ( string.lower(args) == "5m" ) then args="05:00"; end
	if ( string.lower(args) == "6m" ) then args="06:00"; end
	if ( string.lower(args) == "7m" ) then args="07:00"; end
	if ( string.lower(args) == "10m" ) then args="10:00"; end
	if ( string.lower(args) == "30s" ) then args="00:30"; end

	-- dft("===================== args=[" .. args .. "]");
	if ( string.lower(args) == "off" ) then duration = 0 else duration = FarmersToolkit.ParseTimeInput(args) end
	
	if ( duration == 0 ) then
		dft("Turning off auto combat timer.")
        	FTAddonTimer:SetHidden(true)
        	EVENT_MANAGER:UnregisterForUpdate("FarmersToolkitTimerUpdate")
                FarmersToolkit.CombatAutoTimer = duration
	elseif duration then
		dft("Setting auto combat timer = [" .. args .. "] .")
        	FarmersToolkit.CombatAutoTimer = duration;
        	FarmersToolkit.StartTimer(duration)
    	else
        	d("Invalid time format. Please use /ft timer MM:SS.")
    	end

	CommandsProcessed=CommandsProcessed+1;
	return

   end

   if ( HArgs[1] == "timer" ) then 

	local args=tokens[2];
	-- Handle some simple formats
	if ( string.lower(args) == "1m" ) then args="01:00"; end
	if ( string.lower(args) == "2m" ) then args="02:00"; end
	if ( string.lower(args) == "3m" ) then args="03:00"; end
	if ( string.lower(args) == "4m" ) then args="04:00"; end
	if ( string.lower(args) == "5m" ) then args="05:00"; end
	if ( string.lower(args) == "6m" ) then args="06:00"; end
	if ( string.lower(args) == "7m" ) then args="07:00"; end
	if ( string.lower(args) == "10m" ) then args="10:00"; end
	if ( string.lower(args) == "30s" ) then args="00:30"; end

    	local duration = FarmersToolkit.ParseTimeInput(args)
    	if duration then
		dft("Starting countdown timer for = [" .. args .. "]")
        	FarmersToolkit.StartTimer(duration)
    	else
        	d("Invalid time format. Please use /ft timer MM:SS.")
    	end
        -- OnSlashCommandTimer(args)
	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "hidetimer" ) then 
        -- OnSlashCommandTimer(args)
	-- 	XXXXX
           FTAddonTimer:SetHidden(true)
	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "showtimer" ) then 
        -- OnSlashCommandTimer(args)
	-- 	XXXXX
           FTAddonTimer:SetHidden(false)
	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "mt" ) then 
        -- OnSlashCommandTimer(args)
           FarmersToolkit.StartTimer(300)
	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "loc" ) then 

	local zoneName = GetUnitZone("player")
	local mapName = GetMapName()
	local x, y = GetMapPlayerPosition("player")
	local mapTileTexture = GetMapTileTexture()
	
	dft("Zone: " .. zoneName)
	dft("Map: " .. mapName)
	dft("Coordinates: (" .. x .. ", " .. y .. ")")
	dft("Map Tile Texture: " .. mapTileTexture)

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "loc2" ) then 

	local x, y = GetMapPlayerPosition("player")
	dft("tokens[2] = " .. tokens[2]);
	dft("tokens[3] = " .. tokens[3]);
	local x2 = tonumber(tokens[2]);
	local y2 = tonumber(tokens[3]);
	
	local errflag=0;

	if ( x2 > 1 ) then dft("Target X value cannot be greater than 1"); errflag=errflag+1; end
	if ( y2 > 1 ) then dft("Target Y value cannot be greater than 1"); errflag=errflag+1; end
	if ( x2 < 0 ) then dft("Target X value cannot be less than 0"); errflag=errflag+1; end
	if ( y2 < 0 ) then dft("Target Y value cannot be less than 0"); errflag=errflag+1; end

	if ( errflag > 0 ) then
		dft("Please correct the errors and try again.  Err count: " .. errflag);
	else 
		dft("You are currently at " .. x .. " / " .. y .. ".  You are trying to find " .. x2 .. " / " .. y2);

		dft(FarmersToolkit.GetDistanceAndDirectionToTarget(x2, y2));



	end

	 --

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "getloc" ) then 
	FarmersToolkit.GetLocation();
        CommandsProcessed=CommandsProcessed+1;
	return

   end
   if ( HArgs[1] == "setloc" ) then 

	local junk,tagnote =  passed_args:match("^(%S*)%s*(.-)$")
	if ( tagnote ~= "" ) then
		dft("Would set curent location to [" .. tagnote .."]");
		FarmersToolkit.SetLocation(tagnote);
	else
		dft("Blank locations are not supoprted.");
	end

        CommandsProcessed=CommandsProcessed+1;
	return
   end


   if ( HArgs[1] == "showloc" ) then 

	local arg = HArgs[2]; if not arg then arg="" end

	if arg == "all" or arg == "zone" then
            FarmersToolkit.ShowLocations(arg)
        else
            FarmersToolkit.ShowLocations("map")
        end

        CommandsProcessed=CommandsProcessed+1;
	return
   end

   if ( HArgs[1] == "testitems" ) then 

local function ListAllSpecializedItemTypes()
    local specializedItemTypes = {}

    -- Iterate over possible specialized item type IDs (assume 1 to 200 as an arbitrary range)
    for i = 1, 200 do
        local itemTypeText = GetString("SI_SPECIALIZEDITEMTYPE", i)
        if itemTypeText and itemTypeText ~= "" then
            table.insert(specializedItemTypes, itemTypeText)
        end
    end

    -- Print each specialized item type
    d("Specialized Item Types:")
    for _, itemTypeText in ipairs(specializedItemTypes) do
        d(itemTypeText)
    end
end

-- Call the function to list specialized item types
ListAllSpecializedItemTypes()


	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "chartest" ) then 

local currentXP = GetUnitXP("player")
local maxXP = GetUnitXPMax("player")
local progress = (currentXP / maxXP) * 100
d(string.format("XP Progress: %.2f%%", progress))


   for charnum = 1, GetNumCharacters() do
	local name, gender, level, class, race, alliance, charid, location=GetCharacterInfo(charnum);
	if GetCurrentCharacterId() == charid  then
		dft("For THIS character #" .. charnum .. " ***************");
	else
		dft("For character #" .. charnum );
	end
	dft("- name = [" .. name .. "]");
	dft("- name2 = [" .. GetUniqueNameForCharacter(name) .. "]");
	dft("- gender = [" .. gender .. "]");
	dft("- level = [" .. level .. "]");
	if (level < 50 ) then
		dft("- Max points for this level: " ..  GetNumExperiencePointsInLevel(level));
	end
	dft("- class = [" .. class .. "]");
	dft("- alliance = [" .. alliance .. "]");
	dft("- charid = [" .. charid .. "]");
	dft("- GetUnitXP(charid) = [" .. GetUnitXP(charid) .. "]");
	dft("- location = [" .. location .. "]");
	dft(" ");
   end

	 dft("No {other) tests currently scheduled.");	   
	 --

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end


   if ( HArgs[1] == "test" ) then 

	-- local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	-- messageParams:SetText("Choose Your Location Wisely: You have a bounty")
	-- messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	-- messageParams:SetLifespanMS(4000) -- Display for 4 seconds
	-- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)

	FarmersToolkit.LargeDFT("Choose Wisely - you have a bounty","FF0000");



	 dft("No tests currently scheduled.");	   
	 --

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "listslash" ) then 


	-- Inspired (Taken) from elenin's formum posting on ESOUI.com 11/10/24 10:56 PM
	-- for sc, _ in pairs(SLASH_COMMANDS) do d(sc) end


local function ParsePcall(message, argument)
    for line in message:gmatch("[^\r\n]+") do
        if line:find(argument) then
            -- Extract the value from the line
            local value = line:match("value = (.+)")
            if value then
                return value
            end
        end
    end
    return "No value found for the given argument."
end

local function extractPath(line)
    -- Extract the path from the line, removing the line number
    local path = line:match("^(.-):%d+")
    return path or line  -- Return the original line if no match
end

local function dumpTable(tbl)
    local groupedResults = {}

    for key, value in pairs(tbl) do
        if type(value) == "function" then
            -- Attempt to dump the function safely
            local success, funcBytecode = pcall(string.dump, value)
            if success then
                -- If the function is dumped successfully, we can ignore it for grouping
            else
                local pcalltxt = string.format("Error dumping function %s: %s", key, funcBytecode)
                local result = ParsePcall(pcalltxt, key)
                local path = extractPath(result)  -- Extract the path for grouping

		-- Trim the leading "user:" bit off for improved readaBILITY
		if path then
        		-- Remove the "user:" prefix if it exists
        		path = path:gsub("^user:", "")
    		end

                -- Group by the extracted path
                if not groupedResults[path] then
                    groupedResults[path] = {}
                end
                table.insert(groupedResults[path], key)
            end
        else
            -- Handle non-function types if necessary
            -- For now, we will just print them
            dft(string.format("Command: %s, Type: %s", key, type(value)))
        end
    end

    -- Sort and print the grouped results
    for path, commands in pairs(groupedResults) do
        -- Sort the commands alphabetically
        table.sort(commands)

        -- Print the grouped result
        dft(string.format("Source: |cFFA500%s|r", path))
        for _, command in ipairs(commands) do
            dft(string.format("  Command: |c00FF00%s|r", command))
        end
    end
end

-- Call the dump function on SLASH_COMMANDS
dft(" === Showing alphabetical list of all slash commands, grouped by source === ");
dumpTable(SLASH_COMMANDS)
dft(" === End of slash command list");



	   CommandsProcessed=CommandsProcessed+1;

	   return
   end



   if ( HArgs[1] == "testwayshrine" ) then 

	 dft("Ugly wayshrine test");
	 --

	   local Maxnum = GetNumFastTravelNodes();
	   local MapText = ""

	   local KnownWS=0;


	   for uCode=1, Maxnum do
		local uKnown, uName, uX,uY, uIcon, uIcon2, uPOI, uShown,uLocked = GetFastTravelNodeInfo(uCode);
		-- if ( string.find(uName,"Harborage",1,plain))  then 
			-- dft("=========================="); 
			-- dft("Wayshrine #" .. uCode .. " is named [" .. uName .. "] at " .. uX ..":" .. uY .. ", " ..  zo_strformat(" Known/Available is: <<1>>", uKnown and "true" or "false"))
			-- dft("--------  GetFastTravelNodeLinkedCollectibleId = " .. GetFastTravelNodeLinkedCollectibleId())
		-- end
		if uName and uName ~= "" then
			-- dft("Wayshrine #" .. uCode .. " is named [" .. uName .. "] at " .. uX ..":" .. uY .. ", " ..  zo_strformat(" Known/Available is: <<1>>", uKnown and "true" or "false"))
			-- dft("Wayshrine #" .. uCode .. " is named [" .. uName .. "] at " .. uX ..":" .. uY .. ", " ..  zo_strformat(" Known/Available is: <<1>>", uKnown and "true" or "false"))
			-- if GetMapNameByIndex(uCode) ~= "" then


			-- if ( uCode == 21 ) then
			if ( uKnown == true ) then
				local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(uCode)	
	
				local zoneId = GetZoneId(zoneIndex);

				local mapId = GetMapIdByZoneId(zoneId);

				local aMapName = GetMapNameById(mapId);

				local aZName = GetZoneNameByIndex(zoneIndex)

				if ( aMapName == aZName ) then 
					MapText = "Map/Zone = " .. aZName ;
				else 
					MapText = "Zone = [" .. aZName .. "], Map = [" .. aMapName .. "] ********";
				end

				dft("=== Wayshrine #" .. uCode .. ": " .. uName .. ", zoneIndex = " .. zoneIndex .. ", poiIndex = " .. poiIndex .. ", ZoneID = " .. zoneId .. ", mapId = " .. mapId .. ", X/Y=" .. uX .. "/" .. uY .. " @ " .. MapText);

				KnownWS = KnownWS + 1;

				-- dft("--------   GetMapNameByIndex = " ..  GetMapNameByIndex(uCode))
			end
		end
	   end

	   dft("Known Wayshrines: " .. KnownWS .. " / " .. Maxnum );
	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   if ( HArgs[1] == "gvalue" ) then 

	 dft("This is a test set of code, please use caution and don't believe anything you see here.");
	 dft("   Note: This uses the in-game value of items, future versions will use TTC if requested");
	 dft("   Note: This has a timing issue where all guilds report the same data.  However, after the initial")
	
	if ( IsGuildBankOpen() == true ) then
		for loop = 1, GetNumGuilds() do
			dft("------ Results for Guild #" .. loop ); 
			dft("Literally calling FarmersToolkit.EstimatedValue('guild'," .. loop .. ") here....")
			FarmersToolkit.EstimatedValue("guild",loop);
			dft("");
		end
	else
		dft("Cannot run this test unless a guild banker is available and open / interactive.");
	end

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end


   -- Support listing out duplicates between bags and bank

   if ( HArgs[1] == "duplicates" or HArgs[1] == "duplicate" or HArgs[1] == "showdupes" or HArgs[1] == "dupes" or HArgs[1] == "dupe") then  -- e.g how many ways can I misremember this command

	 FarmersToolkit.InvDuplicate(HArgs[2]);

	   CommandsProcessed=CommandsProcessed+1;
	   return
   end


   if ( HArgs[1] == "showbooks" or HArgs[1] == "sb" or HArgs[1] == "showbooklist" or HArgs[1] == "booklist") then 
	   local tcount = 0;
	   local templist = FarmersToolkit.Booklist;
	   local showtype=""; 

	   -- For whatever reason, trying just "if HArgs[2] then blah" throws nil errors at times.  So, I'll wimp out for now.
	   if ( type(HArgs[2]) ~= "nil" ) then showtype=HArgs[2]; end
	   if type(templist) == "nil" then 
		   -- dft_debug("SB: Force loading booklist from save account variables");
		   FarmersToolkit.Booklist = FarmersToolkit.savedVariablesAcct.Booklist;
	   	   templist = FarmersToolkit.Booklist;
	   end

	   if type(templist) == "nil" then 
		   dft("No books have been read or loaded.");
		   return
	   end

	   table.sort(templist);

	   local filter=""; local filtercount=0;

	   if ( HArgs[2] ) then 
		   filter=HArgs[2];
	   	dft("Showbook - Previously read books and count matching phrase: " .. filter);
	else
	   	dft("Showbook - Previously read books and count");
	end

     -- for atitle, acount in pairs(FarmersToolkit.Booklist) do
     -- for atitle, acount in pairs(templist) do
     for atitle, acount in orderedPairs(templist) do
	     tcount = tcount +1;
	     -- dft(FarmersToolkit.fixwidth2(atitle,80).."..: " .. acount);
	     -- dft("Read count: " .. acount .. " -- " .. atitle);
	     --
	     if ( filter ~= "" ) then
		local astr=string.lower(atitle); 
		local tofind=string.lower(filter);
		
		-- -- d("FT-DEBUG 0-B: Looking for [" .. tofind .. "] in [" .. astr .. "]");
		if ( string.find(astr,tofind,1,plain))  then
	     		dft("  + " .. atitle .. " (" .. acount .. ")" );
			filtercount=filtercount+1;
		
		end
	     else	
		-- Change: Only show the full list if requested
  	        if ( HArgs[1] == "booklist") or (showtype == "list") then
	    	    dft("  - " .. atitle .. " (" .. acount .. ")" );
 		end
	     end
     end
     	if (filtercount > 0 ) then
	   dft("Showbook - Total titles: " .. tcount .. ", Matching: " .. filtercount);
        else
	   dft("Showbook - Total titles: " .. tcount .. "    (Use /ft booklist for all titles or /ft sb phrase for keywords)");
	end
   CommandsProcessed=CommandsProcessed+1;
   return

   end


   if ( HArgs[1] == "craftbag" ) then 
	local index = {}
	local pl = {}

        local bagId     = 0;
        local slotIndex = 0;
        local stacksize = 0;
        local rawname = "";

	local ItemName  = "";
	local tlink2  = "";
	local TLinkID  = "";

	local tmpstring  = "";
	local swapin  = "";
	local akey  = "";

	local linklist = {};

	-- Optional: 2nd argument limits the list by threshhold (must have more than xyz items)
	local threshhold=2000;
	if HArgs[2] and ( tonumber(HArgs[2]) > 0 ) then
		threshhold = tonumber(HArgs[2]);
	end

	-- Optional: 3rd argument limits the number of lines reported
	local listcap=0;
	local captext="";
	if HArgs[3] and ( tonumber(HArgs[3]) > 0 ) then
		listcap = tonumber(HArgs[3]);
	end

	local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
        	--For each item in that bag
       	 for _, data in pairs(bagCache) do
            bagId     = data.bagId
            slotIndex = data.slotIndex
            stacksize = data.stackCount
            rawname = data.rawName

	    ItemName  = data.name
          
		if data.lnk then tlink2  = data.lnk else tlink2 = GetItemLink(bagId, slotIndex); end
		linklist[data.rawName]=tlink2;
		-- Looks like data.* isn't as reliably populated as originally coded
		-- dft("== Scanning " .. GetItemName(bagId, slotIndex ));
		-- if ( data.rawName ) then dft("rawName = " .. data.rawName ) else dft ("rawName not set") end
		-- if ( data.lnk ) then dft("lnk = " .. data.lnk ) else dft ("lnk not set") end
		-- if ( data.name ) then dft("name = " .. data.name ) else dft ("name not set") end
		-- if ( data.uid ) then dft("uid = " .. data.uid ) else dft ("uid not set") end
		-- dft(" ")

		-- tlink2  = GetItemLink(bagId, slotIndex)
		
		TLinkID=data.uid
		-- TLinkID=GetItemLinkItemId(tlink2);

		if ( stacksize > threshhold ) then
			-- dft("FT Stack Check: [" .. tlink2 .. "/" .. string.len(tlink2) .. "] versus [" .. ItemName .. "/" .. string.len(ItemName) .. "]: " .. comma_value(stacksize) .. " Also: UID= " .. data.uid .. " vs LinkID = " .. TLinkID)
			-- dft("FT Stack Check 1: [" .. tlink2 .. "/" .. string.len(tlink2) .. "] ");
			-- dft("FT Stack Check 2a: versus [" .. ItemName .. "/" .. string.len(ItemName) .. "] ")
			-- dft("FT Stack Check 2b: versus data.name=[" .. data.name .. "] " )
			-- dft("FT Stack Check 2c:" .. comma_value(stacksize) )
			-- dft("FT Stack Check 3: Also: UID= " .. data.uid .. " vs LinkID = " .. TLinkID)
			index[stacksize]=tlink2;
			-- pl[tlink2]=stacksize;
			 pl[data.rawName]=stacksize;
		end
	end

	-- Collect the keys in a separate array
	local keys = {}
	for key in pairs(pl) do
    		table.insert(keys, key)
	end
	
	-- Sort the keys based on the values in the table
	table.sort(keys, function(a, b)
    		return pl[a] > pl[b] -- reverse comparitor to flip sorting back to ascending
	end)
	
	-- Print the sorted keys
	if ( listcap > 0  ) then captext=" - First " .. comma_value(listcap) .. " entries."; end
	dft("-- Craftbag inventory for items worth more than " .. comma_value(threshhold) .. " G " .. comma_value(captext) );
	for i, key in ipairs(keys) do
		if (pl[key] >= threshhold ) and ( ( listcap == 0 ) or ( listcap >= i ) ) then

		-- I am working too hard to get things to line up.  The difference now is down
		-- to whether the original text is upper or lower case 
		-- ("corn flower" is more narrow that "Corn Flower" because upper case letters are wider)
		-- Yep, I'm over thinking this.  So, gonna stop.  Fow now.  I hope.
		
		   akey=key;
		   akey = akey:match("^[^%^]*") -- Just strip out ^ and anything to the right of it
		   
		   -- tmpstring= "Item Count (" .. i .. "): " .. FarmersToolkit.fixwidth2(akey,50) .. " = " .. comma_value(pl[key]) 
		   tmpstring= "Item Count (" .. i .. "): " .. comma_value(pl[key]) .. " = " .. akey 
		     if ( linklist[key]  ) then
		   -- dft ("A: " .. tmpstring);
		    --     tmpstring = string.gsub(tmpstring,key,swapin);
		         tmpstring = string.gsub(tmpstring,akey,linklist[key]);
		    --dft("Notice: key=["..key.."/" .. string.len(key) .. "] and akey=["..akey.."/" .. string.len(akey) .. "]");
		     end
		   -- dft ("X: " .. tmpstring);


		   dft (tmpstring);
		   
		
		end
	end

	-- d(string.format("Bottom  .. screen_result_count+sub_line_counttest 1: Count (%2d): %10s = %-40s!", 1, 22, "Hello"));
	-- d(string.format("Bottom test 2: Count (%2d): %10s = %-40s!", 2, 32, "Hello There"));
	-- d(string.format("Bottom test 3: Count (%2d): %10s = %-40s!", 3, 42, "           ii Well Hello There"));
	-- print "Final test";


	   CommandsProcessed=CommandsProcessed+1;
	   return
   end

   -- List out hints
   if ( HArgs[1] == "hints" ) or ( HArgs[1] == "hint" ) or ( HArgs[1] == "showhints") then
	FarmersToolkit.ListHints(HArgs[2])
	CommandsProcessed=CommandsProcessed+1;
	return
   end
   

   -- Guild store review (gsreview)
   --  Command to look through backback for items of value that may be worth sending to a guild trader
   --  Note: This function relies upon TamrielTradeCentre daat / module

   if ( HArgs[1] == "gtreview" ) or ( HArgs[1] == "gtr" ) or ( HArgs[1] == "gtrb") then


	-- By default, we're looking in the bags but let's also support an argument for scanning the bank
	local TARGET_BAG = BAG_BACKPACK
	local target_name="backpack";

	if ( HArgs[1] == "gtrb") then
		TARGET_BAG = BAG_BANK
		target_name="bank"
	end

 
     	local numSlots = GetBagSize(TARGET_BAG)
	-- dft_debug("(FTK_CSIa): Backpack (I) slots: " .. numSlots);
	

	if ( type(FarmersToolkit.PTarget) == "nil"  ) then FarmersToolkit.PTarget = 800; end

	-- Support command line option to override price target.  Allow an optional argument to the command line to set the threshhold
	local TmpPriceTarget=FarmersToolkit.PTarget;
	if type(tokens[2]) ~= "nil" then
		if ( tonumber(tokens[2]) > 0 ) then TmpPriceTarget=tonumber(tokens[2]); end
	end


     if TamrielTradeCentre then

	local reviewed=0;
	local recommended=0;
	dft(" -- Reviewing " .. target_name .." inventory for items with a possible sell price of more than " .. comma_value(TmpPriceTarget) .. " gold ");
	for bSlot = 1, numSlots do

		-- Look up item info
   		local alink  = GetItemLink(TARGET_BAG, bSlot)
		local itemType = GetItemLinkItemType(alink)
		local SpecialItemType=ZO_GetSpecializedItemTypeTextBySlot(TARGET_BAG, bSlot);

		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(TARGET_BAG, bSlot)

		locked = FarmersToolkit.CanAuctionItem(TARGET_BAG, bSlot);

		local lockflag="";
		if locked == false then 
			lockflag="F" 
		else 
			lockflag="T" 
			-- dft("Setting lockflag to " .. lockflag);
		end

		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(alink);
		local pricetarget = 0;
		local pricetext = "";
		local datapointcount = 0;

		if priceInfo then
			if priceInfo.SaleAvg and priceInfo.SaleAvg > 0 then 
				pricetarget = priceInfo.SaleAvg;
				-- pricetext = "Sales Avg: " .. comma_value(priceInfo.SaleAvg) .. " @ " .. comma_value(priceInfo.SaleEntryCount); 
				pricetext = "Based on " .. comma_value(priceInfo.SaleEntryCount) .. " TTC datapoints, the sales average price = " .. comma_value(math.floor(priceInfo.SaleAvg)) .. " gold " ; 
				datapointcount = priceInfo.SaleEntryCount;
			end
			if priceInfo.SuggestedPrice and priceInfo.SuggestedPrice > 0 then 
				pricetarget = priceInfo.SuggestedPrice;
				-- pricetext = "Suggested: " .. comma_value(priceInfo.SuggestedPrice) .. " @ " .. comma_value(priceInfo.EntryCount); 
				pricetext = "Based on " .. comma_value(priceInfo.EntryCount) .. " TTC datapoints, the suggested price = " .. comma_value(math.floor(priceInfo.SuggestedPrice)) .. " gold " ; 
				datapointcount = priceInfo.EntryCount;

			end
		end


			-- dft("checking lockflag on " .. alink .. ":  " .. lockflag);
		if ( alink ~= "" ) then reviewed = reviewed +1; end
		if ( 
			(alink ~= "" )
			and priceInfo
			and lockflag == "T"
			and stack < 5
			and datapointcount > 5
			and pricetext ~= ""
			and pricetarget >= TmpPriceTarget
		   ) then	 
			-- dft("Scanning [" .. alink .."] ("..lockflag..")" );
			if priceInfo then
				-- dft("Scanning [" .. alink .."] ("..lockflag..") SEC=" .. priceInfo.SaleEntryCount);
				dft("Consider #" .. bSlot .. ": " .. FarmersToolkit.fixwidth2(alink,90) .."     " .. pricetext);
				recommended = recommended +1;
			else
				-- dft("Scanning [" .. alink .."] ("..lockflag..") no TTC data returned.");
				
			end
		end -- if something to print
	   end -- loop
	   dft("-- GT Review complete: # of items reviewed: " .. reviewed .. ", recommended: " .. recommended)

        else
		dft("Requested function unavailable (relies upon TTC Addon data)");
	end

	   CommandsProcessed=CommandsProcessed+1;
	   return

   end -- End of GT Review


   -- Decon backpack review (gsreview)
   --  Command to look through backback for items of little value that don't have enough data points for guild trading
   --  Note: This function relies upon TamrielTradeCentre daat / module

   -- Enable potional argument "terse" to suppress "Insufficient data" output
   local terseFlag=false;  
   local TmpPriceLimit = 0;
   if ( HArgs[3] == "terse" ) then terseFlag=true; end
   if ( HArgs[2] == "terse" ) then TmpPriceLimit=800; dft("Note: cmd is \"/ft " .. HArgs[1] .. " nnn [terse]\".  Defaulting nnn to be 800 gold."); terseFlag=true; end

   if ( HArgs[1] == "rdl" ) or ( HArgs[1] == "deconlist" ) or ( HArgs[1] == "decon" ) then 
     	local numSlots = GetBagSize(BAG_BACKPACK)
	-- dft_debug("(FTK_CSIa): Backpack (I) slots: " .. numSlots);
	
	if ( type(FarmersToolkit.PTarget) == "nil"  ) then FarmersToolkit.PTarget = 800; end

	-- Support command line option to override price target.  Allow an optional argument to the command line to set the threshhold
	local TmpPriceLimit=FarmersToolkit.PTarget;
	if type(tokens[2]) ~= "nil" then
   		if ( tokens[2] == "terse" ) then 
			TmpPriceLimit=800; 
			dft("Note: cmd is \"/ft " .. HArgs[1] .. " nnn [terse]\".  Defaulting nnn to be 800 gold."); 
			terseFlag=true; 
		elseif ( tonumber(tokens[2]) > 0 ) then 
			TmpPriceLimit=tonumber(tokens[2]); 
		end
	end

     if TamrielTradeCentre then

	local reviewed=0;
	local recommended=0;

	local suggest_list={"Suggest deconstructing these items (based on the price vs. " .. comma_value(TmpPriceLimit) .. " gold)"}
	local consider_list={"Consider deconstructing these items (because no price info is available)"}

	dft(" -- Reviewing backpack inventory for deconstructible items with a possible sell price of less than " .. comma_value(TmpPriceLimit) .. " gold ");
	for bSlot = 1, numSlots do

		-- Look up item info
   		local alink  = GetItemLink(BAG_BACKPACK, bSlot)
		local itemType = GetItemLinkItemType(alink)
		local SpecialItemType=ZO_GetSpecializedItemTypeTextBySlot(BAG_BACKPACK, bSlot);

		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_BACKPACK, bSlot)
		local deconable=CanItemBeDeconstructed(BAG_BACKPACK, bSlot,NULL);

		local islocked = IsItemPlayerLocked(BAG_BACKPACK, bSlot);

		local deconflag=""; if deconable == false then deconflag="F" else deconflag="T" end
		local lockedflag=""; if islocked == false then lockedflag="F" else lockedflag="T" end

		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(alink);
		local pricetarget = 0;
		local pricetext = "";
		local datapointcount = 0;

		local TerseLine=""; -- Build a terseflag enabled line just in case that flag is set

		if ( alink ~= "" ) and deconable == true and islocked == false then
		
			-- dft_debug("===\n=== Scanning [" .. alink .. "] Decon=[" .. deconflag .. "] and locked=[" .. lockedflag .. "]");
		

			if priceInfo then
				-- dft_debug(" == PriceInfo exists");

				if priceInfo.SaleAvg then 
					-- dft_debug(" == SalesAvg: " .. priceInfo.SaleAvg); else dft_debug(" == No SalesAvg Data"); 
				end
				if priceInfo.SaleEntryCount then 
					-- dft_debug(" == SaleEntryCount: " .. priceInfo.SaleEntryCount); else dft_debug(" == No SaleEntryCount Data"); 
				end

				if priceInfo.SuggestedPrice then 
					-- dft_debug(" == SuggestedPrice: " .. priceInfo.SuggestedPrice); else dft_debug(" == No SuggestedPrice Data"); 
				end
				if priceInfo.EntryCount then 
					-- dft_debug(" == EntryCount: " .. priceInfo.EntryCount); else dft_debug(" == No EntryCount Data"); 
				end

				datapointcount = priceInfo.EntryCount;


			else 
				-- dft_debug(" == priceInfo is not available")
			end
			-- dft_debug("=== End of scan for " .. alink .. "\n");
			-- dft_debug("    \n");
		end



		if priceInfo and deconable == true and islocked == false then
			pricetext = "Insufficient price datapoints (" .. datapointcount .." vs. 5) for evaluating trade vs. decon viability.";
			TerseLine="";
			if priceInfo.SaleAvg and priceInfo.SaleAvg > 0 then 
				pricetarget = priceInfo.SaleAvg;
				-- pricetext = "Sales Avg: " .. comma_value(priceInfo.SaleAvg) .. " @ " .. comma_value(priceInfo.SaleEntryCount); 
				pricetext = "Based on " .. comma_value(priceInfo.SaleEntryCount) .. " TTC datapoints, the Sales average price = " .. comma_value(math.floor(priceInfo.SaleAvg)) .. " gold " ; 
				datapointcount = priceInfo.SaleEntryCount;
				-- dft("Inside of priceinfo for [" .. alink .. "] SEC = " .. datapointcount .. " and avf = " .. pricetarget);
				TerseLine=pricetext;
			else
				pricetext = "Insufficient price data (no reliable SaleAvg data) for evaluating trade vs. decon viability.";
				TerseLine="";
			end

			-- if priceInfo.SuggestedPrice and priceInfo.SuggestedPrice > 0 then 
			if priceInfo.SuggestedPrice and priceInfo.SuggestedPrice > 0 and priceInfo.EntryCount > datapointcount then 
				pricetarget = priceInfo.SuggestedPrice;
				-- pricetext = "Suggested: " .. comma_value(priceInfo.SuggestedPrice) .. " @ " .. comma_value(priceInfo.EntryCount); 
				pricetext = "Based on " .. comma_value(priceInfo.EntryCount) .. " TTC datapoints, the suggested price = " .. comma_value(math.floor(priceInfo.SuggestedPrice)) .. " gold " ; 
				TerseLine=pricetext;
				datapointcount = priceInfo.EntryCount;
				-- dft("Inside of priceinfo:SUG for [" .. alink .. "] SUG price = " .. priceInfo.SuggestedPrice .. " and DPC now = " .. datapointcount);

			end
		else -- We have no priceinfo so.... keep looking
			-- pricetext = "The decon flag is set to " .. deconflag .. ", and locked flag = " .. lockedflag;
			pricetext = "No price data available for trading.";
			TerseLine="";
		end

		if (
			(alink ~= "" ) 
			and deconable == true
			and datapointcount < 6
		) then
		end

		if ( alink ~= "" ) then reviewed = reviewed +1; end

		-- dft_debug(" -- before the if/then decision for " .. alink .. ": stack="..stack..", datapoint="..datapointcount..", pricetarget="..pricetarget..", TPL=".. TmpPriceLimit..", locked=" .. lockedflag .. " and decon=" .. deconflag);

		if ( 
			(alink ~= "" )
			and stack < 10
			-- and datapointcount < 6
			and pricetext ~= ""
			and islocked == false
			and deconable == true
			and pricetarget <= TmpPriceLimit
		   ) then	 

			if ( pricetext == "No price data available for trading." ) then
				-- dft(" == Consider decon [" .. alink .. "] " .. pricetext );
				-- consider_list[#consider_list +1] = " == Consider decon [" .. alink .. "] " .. pricetext ;
				consider_list[#consider_list +1] = " == [ " .. alink .. " ] " .. pricetext ;
			else 
				-- dft(" == Suggest decon [" .. alink .. "] " .. pricetext );
				-- suggest_list[#suggest_list +1] = " == Suggest decon [" .. alink .. "] " .. pricetext ;
				if ( terseFlag == true ) and (TerseLine ~= "") then suggest_list[#suggest_list +1] = " == [ " .. alink .. " ] " .. TerseLine ; end
				if ( terseFlag == false ) then suggest_list[#suggest_list +1] = " == [ " .. alink .. " ] " .. pricetext ; end
			end
			recommended=recommended+1;


		else -- if nothing to print
		   if ( deconable == true ) then
			-- dft_debug(" == Nothing to print for [" .. alink .. "] based on Decon="..deconflag..", locked="..lockedflag .. ", stack=" .. stack .. " < 10, datapointcount=" .. datapointcount .. " (versus < 6), pricetext=[" .. pricetext .. "]");
		   end
		    
		end -- if something to print
	   end -- loop

           -- Okay, lets print things out, listing the suggested ones first.  
	   -- (Someday, it would be nice to list the alphabetically but we're printing links and table.sort doesn't handle that well... or at all)
           for _, value in ipairs(suggest_list) do
		dft(value);
	   end

	   if terseFlag == false then
             for _, value in ipairs(consider_list) do
		dft(value);
	     end
           end
	   
	   dft("-- Decon review complete: # of items reviewed: " .. reviewed .. ", recommended: " .. recommended)

        else
		dft("Requested function unavailable (relies upon TTC Addon data)");
	end

	   CommandsProcessed=CommandsProcessed+1;
	   return

   end -- End of Decon Review

   if ( HArgs[1] == "resettypetarget" ) 
   or ( HArgs[1] == "resettypetargets" ) 
   then 

	   FarmersToolkit.TargetTypeSoFar = {}
      	   FarmersToolkit.UpdateFarmlist()
	   CommandsProcessed=CommandsProcessed+1;
	   return

   end -- End of reset type target count

   if ( HArgs[1] == "settypetarget" ) then 
	   local alink=HArgs[2];
	   local ItemID = tonumber(HArgs[4]);

-- Example usage
-- dft("Debug: tokens = " .. type(tokens))

   local case_passed_args = FarmersToolkit.capitalizeWords(passed_args);

    local cmd, itemFullname, targetNumber = case_passed_args:match("^(%S+)%s+(.-)%s+(%S+)$") 

	-- Check for a special case here, player may be asking to delete (versus set to 0)
   	if ( HArgs[#HArgs] == "delete" ) then -- We're being asked to remove an item, not make it 0 
      		FarmersToolkit.TargetTypeCount[itemFullname]=nil;
      		FarmersToolkit.UpdateFarmlist()
		dft("Removed " .. itemFullname .. " from the farming type target list.");
		return
	end


-- dft("Debug: t1 = " .. type(t1))
-- dft("Debug: itemFullname = " .. type(itemFullname))
-- dft("Debug: targetNumberOrDelete = " .. type(targetNumber))
-- dft("Debug: passed_args = " .. type(passed_args))
-- dft("Debug: passed_args = [" .. passed_args .. "]")

 if itemDescription and targetNumberOrDelete then
     dft("Item Fullname: " .. itemFullname)
     dft("Target: " .. targetNumber)
 end

	   local newTargetCount = tonumber(targetNumber); -- Last token on line is the actual target value

	   -- dft("Called settypetarget: itemFullname = [" .. itemFullname .."] and newTargetCount = [" .. newTargetCount .. "]")

	   if ( newTargetCount == nil ) then -- We didn't get a number from the last token...
		dft("Error: Could not parse numeric value from settypetarget command.")
		return;
	   end

	   -- dft_debug("TEST: alink = [" .. alink .. "] and maps to ItemID = " .. ItemID )

	   if ( type(FarmersToolkit.TargetTypeCount) == "nil" ) then FarmersToolkit.TargetTypeCount = {} end
           FarmersToolkit.TargetTypeCount[itemFullname]=newTargetCount;
	   -- dft_debug("Set type target of " .. newTargetCount .. " for " .. itemFullname .. " into TargetTypeCount[" .. alink .. "] and TargetTypeCOunt[same] = [" .. FarmersToolkit.TargetTypeCount[itemFullname] .. "] where itemFullname of type a " .. type(itemFullname));
	   dft("Set type target for " .. itemFullname .. " to be " .. newTargetCount );

       	   FarmersToolkit.UpdateFarmlist()
	   return;
   end

   -- set the target # of items to farm (settarget [item] NNN)
   if ( HArgs[1] == "settarget" ) then 
	   local alink=HArgs[2];
	   local ItemID = tonumber(HArgs[4]);

	   -- We could grab the text name from the HArgs list but we'd rather have the full, linkable name
	   -- local aname = HArgs[#HArgs - 1]; -- Next to Last token on line is the actual target name
	   local aname = tokens[2] -- grab entire link from passed_args, not the HArgs divided set

	   local newTargetCount = tonumber(HArgs[#HArgs]); -- Last token on line is the actual target value

	   if ( newTargetCount == nil ) then -- We didn't get a number from the last token...
	   	-- Check for a special case here, player may be asking to delete (versus set to 0)
	   	if ( HArgs[#HArgs] == "delete" ) then -- We're being asked to remove an item, not make it 0 
           		FarmersToolkit.TIDCount[ItemID]=nil;
	   		FarmersToolkit.TIDName[ItemID] = nil;
       	   		FarmersToolkit.UpdateFarmlist()
			dft("Removed " .. aname .. " from the farming target list.");
		else
			dft("Error: Could not parse numeric value from settarget command.")
		end
		return;
	   end
		

	   -- dft_debug("TEST: alink = [" .. alink .. "] and maps to ItemID = " .. ItemID )

           FarmersToolkit.TIDCount[ItemID]=newTargetCount;
	   FarmersToolkit.TIDName[ItemID] = aname;
	   -- dft_debug("Set target of " .. newTargetCount .. " for " .. aname .. " into TIDNAME[" .. ItemID .. "] and TIDCount[same] = [" .. FarmersToolkit.TIDCount[ItemID] .. "] where ItemID is a " .. type(ItemID));
	   dft("Set target for " .. newTargetCount .. " to be " .. aname );

       	   FarmersToolkit.UpdateFarmlist()
	   return;
   end

   -- List the set of targets to be farmed
   if (
        ( HArgs[1] == "listtargets" ) 
        or ( HArgs[1] == "showtargets" ) 
        or ( HArgs[1] == "showtargetlist" ) 

	) then 
	   dft("Showing current farming shopping list ");
	   FarmersToolkit.ListTargetCounts("chat");
	   return;
   end

   -- Save off current set of targets (this is distinct from the savedata command, by design)
   if ( 
	   ( HArgs[1] == "savetarget" ) 
	   or ( HArgs[1] == "savetargets" ) 
      ) then

	FarmersToolkit.SaveTargetlist()
	dft("(Experimental): Current farming targets saved. ");
	dft("(Experimental): Use /ft loadtargets to restore ");
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Load previously saved set of targets, replace any existing set
   if (
	   ( HArgs[1] == "loadtargets" ) 
	   or ( HArgs[1] == "loadtarget" ) 
      ) then

	FarmersToolkit.LoadTargetlist()
	dft("(Experimental): Current farming target data replaced by previously saved data ");
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Save off current sets of data (farmed items, names, etc.  Essentially everything saveable except farming targets)
   if ( HArgs[1] == "savedata" ) then

	FarmersToolkit.SaveFarmlist()
	dft("(Experimental): Current farming reports saved. (" .. comma_value(FarmersToolkit.tvalue) .." items)")
	dft("(Experimental): Use /ft loaddata to restore or /ftreset followed by /ft savedata to zero out saved data")
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Load non-farming-list data 
   if ( HArgs[1] == "loaddata" ) then

	FarmersToolkit.LoadFarmlist()
	dft("(Experimental): Current farming session data replaced by previously saved data (Items: " .. comma_value(FarmersToolkit.tvalue) .. ")")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Display stats on farmed items
   if ( HArgs[1] == "stats" ) then

	FarmersToolkit.FarmingStats()
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Display more complete data on farmed items 
   if ( HArgs[1] == "fullstats" ) then

	FarmersToolkit.FarmingStats("detail")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show current companion rapport.  One of the first functions in this addon.
   if ( HArgs[1] == "showrap" ) then
	FarmersToolkit.ShowCompanionRapport("byrequest")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show all companions' rapport.  
   if ( HArgs[1] == "showallrap" ) or ( HArgs[1] == "showrappall") then
	FarmersToolkit.ListCompanionRapport("byrequest")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show current gold counts.
   if ( HArgs[1] == "gold" ) then

	dft("Gold gained this session: " .. comma_value(FarmersToolkit.TotalGoldGain) .. ", total: " .. comma_value(FarmersToolkit.NewGoldCount)) 
	return
   end

   -- Show farming list
   if ( HArgs[1] == "fl" ) or ( HArgs[1] == "farmlist" ) then

	if ( type(HArgs[2]) ~= "nil" ) then 
		FarmersToolkit.ListFarmedItems(HArgs[2])
	else
		FarmersToolkit.ListFarmedItems("")
	end
	
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Show farming list
   if ( HArgs[1] == "ver" ) or ( HArgs[1] == "version" ) then

	dft("You are running Farmers Toolkit Addon, version " .. FarmersToolkit.FTVersion);	
	CommandsProcessed=CommandsProcessed+1;
	return
   end




   -- Show bank duplicates 
   if ( HArgs[1] == "duplicates" ) then

	FarmersToolkit.ListFarmedItemsDebug("show_bank_duplicates") -- This is misleading, it just needs to be a string that will never match fl2
	
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show unique inventory (nbag) entries 
   if ( HArgs[1] == "bagdetails" ) then

	FarmersToolkit.CountOtherItems("detail") -- This is misleading, it just needs to be a string that will never match fl2
	
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show more detailed farming list
   if ( HArgs[1] == "fl2" ) then

	if ( type(HArgs[2]) ~= "nil" ) then 
		FarmersToolkit.ListFarmedItemsDebug(HArgs[2])
	else
		FarmersToolkit.ListFarmedItemsDebug("")
	end
	
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show latest news
   if ( HArgs[1] == "news" ) then

	local ChatStr = FarmersToolkit.DailyProgress("Chat")
	dft("|c26F7FDET - Latest Updates (as of version " .. FarmersToolkit.FTVersion .. "):\n")
	dft("--------------------------");
	dft("FarmersToolkit  - New commands:\n")
	dft("   /ft news - This screen!")
        dft("   /ft gtreview or /ft gtr - List items in backpack that may be worth sending to guild traders.");
        dft("   /ft gtrb - List items in bank that may be worth sending to guild traders.");
        dft("   /ft deconlist or /ft rdl - Review decond list - show suggested deconstructable items.");
        dft("   /ft craftbag [threshhold] [max entries] - Show craftbag by inventory counts.");
    	dft("   /ft showcompchat - Show companion-related comments in chat (likes dislikes, rapport, etc.)");
    	dft("   /ft hidecompchat - Suppress companion-related comments in chat");
	dft("   /ft fl2 has been improved")
	dft("       - Now shows whether item is in your backback (I), bank (B) or Craftbag (Cb)")
	dft("       - Will include pricing info if available (ZOS or TTC if available")
	dft("       - Also shows bank duplicates if called with a string that won't match anything");
	dft("   /ft duplicates - Show list of bank itms duplicated in bagpack (or vice versa)");
	dft("   /ft sb - Show list of book titles you have read.  Also supports title search: /ft sb string-to-search-for");
	dft("   /ft favpets - Show list of pets marked as favorites (for /ft petnow, etc.)")
	dft(" ")
    	dft(" --------------- Farming Targeting / Shopping list commands  ------------")
    	dft(" -- /ft settarget [Item] nn - Assign [item] a farming target of nn")
    	dft(" --       - [item] is a linked item (e.g., left click on an item, use 'Link in chat')");
    	dft(" --       - You can also right click in your inventory and choose ");
    	dft(" --         'Set Farming target in chat' if LibCustomMenu is available.");
    	dft(" -- /ft settarget [Item] delete - Delete [Item] from target list.");
    	dft("          - Recall, setting to 0 makes it a celebration-only entry");
    	dft(" -- You can also set targets by item type (weapon, raw material, herb, etc.)")
    	dft(" -- /ft setTypeTarget [Item] nn - Assign type of items [item] a farming target of nn")
    	dft("          - command is can be all lower case, just used capitals for clarity here");
    	dft(" -- /ft setTypeTarget [Item] delete - Delete [Item] from target types list.");
    	dft(" -- /ft showtargets - Show current list of targeted items, counts, and goals");
    	dft(" -- /ft savetargets - Save current list of targeted items and goals");
    	dft(" -- /ft loadtargets - Load current list of targeted items and goals");
    	dft(" -- /ft showfarmlist - Display current non-zero, unmet farming targets on screen");
    	dft(" -- /ft hidefarmlist - Stop displaying non-zero, unmet farming targets on screen");
    	dft(" -- ")
	dft("   /ft peton - Turns on randomly selecting a new (non-combat) pet")
	dft("   /ft petoff - Turns off randomly selecting a new (non-combat) pet")
	dft("   /ft petnow - Randomly selects a new (non-combat) pet")
	dft("   /ft dailies - Shows current status on daily and weekly endeavors")
	dft("       On-screen data also shows a subet of active and one-step endeavors")
	dft("	  until dailies are complete.  One-step endeavors are binary quests: ")
	dft("       Like 'Earn 1 ticket' or 'Kill 1 Player' or 'Destroy one Geyser'")
	dft("   ")

	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- show updates to dailies (endeavours) either in chat (DailyProgress("chat")  or on screen (DailyProgress("screen")
   if ( HArgs[1] == "dailies" ) then

        if ( FarmersToolkit.SE_Flag ) then 
		-- dft("|c89CFF0Daily and Weekly Endeavors were removed by EOS in March of 2026.\n" .. ChatStr)
		dft("|c89CFF0Daily and Weekly Endeavors were removed by EOS in March of 2026.\n")

	else 
		local ChatStr = FarmersToolkit.DailyProgress("Chat")
		dft("|c89CFF0Daily and Weekly Endeavors:\n" .. ChatStr)


	end

	CommandsProcessed=CommandsProcessed+1;
	return
   end

 -- Zero out in memory info (save farming shopping list) and save (zero out, aka nuke) saved variables as well
 if ( HArgs[1] == "nukedata" ) then

	FarmersToolkit.ResetLists()
	FarmersToolkit.SaveFarmlist()
	dft("(Experimental): Current farming session data zeroed out as well as previously saved farming reports.")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

-- Handle screen presence on and off
-- FarmersToolkit.FlipReport ("on")

   if ( HArgs[1] == "show" ) then

	FTAddonIndicator:SetHidden(false) -- hidden false = screen on
	FarmersToolkit.FTHide=false;
	FarmersToolkit.savedVariables.FTHide = FarmersToolkit.FTHide;
	dft("(Config): Turning screen panel ON. (To turn off, use '/ft hide')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

  -- Hide farming totals (off screen)
  if ( HArgs[1] == "hide" ) then

	FTAddonIndicator:SetHidden(true) -- hidden true = screen off
	FarmersToolkit.FTHide=true;
	FarmersToolkit.savedVariables.FTHide = FarmersToolkit.FTHide;
	dft("(Config): Turning screen panel OFF. To turn on, use '/ft show'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show the farming / shopping list on screen
   if ( HArgs[1] == "showfarmlist" ) then

	FTAddonIndicator2:SetHidden(false) -- hidden false = screen on
	FarmersToolkit.FTHide2=false;
	FarmersToolkit.savedVariables.FTHide2 = FarmersToolkit.FTHide2;
	dft("(Config): Turning farming list panel ON. (To turn off, use '/ft hidefarmlist')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Don't show the farming / shopping list on screen
  if ( HArgs[1] == "hidefarmlist" ) then

	FTAddonIndicator2:SetHidden(true) -- hidden true = screen off
	FarmersToolkit.FTHide2=true;
	FarmersToolkit.savedVariables.FTHide2 = FarmersToolkit.FTHide2;
	dft("(Config): Turning farming list panel OFF. To turn on, use '/ft showfarmlist'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show the inventory details on screen
   if ( HArgs[1] == "showinvdetails" ) then
	FarmersToolkit.InvDetails=true;
	FarmersToolkit.savedVariables.InvDetails = FarmersToolkit.InvDetails;
	dft("(Config): Turning invntory details ON. (To turn off, use '/ft hideinvdetails')")
	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Don't show the inventory details on screen
  if ( HArgs[1] == "hideinvdetails" ) then
	FarmersToolkit.InvDetails=false;
	FarmersToolkit.savedVariables.InvDetails = FarmersToolkit.InvDetails;
	dft("(Config): Turning inventory details OFF. To turn on, use '/ft showinvdetails'")
	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show farming backdrop 
   if ( HArgs[1] == "farmingBD" ) then
	FarmersToolkit.FLBackdrop=true;
	FarmersToolkit.savedVariables.FLBackdrop = FarmersToolkit.FLBackdrop;
	dft("(Config): Turning farming backdrop ON. (To turn off, use '/ft hidefarmingbackdrop')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show dailies backdrop 
   if ( HArgs[1] == "dailyBD" ) then
	FarmersToolkit.DLBackdrop=true;
	FarmersToolkit.savedVariables.DLBackdrop = FarmersToolkit.DLBackdrop;
	dft("(Config): Turning farming backdrop ON. (To turn off, use '/ft hidedailybackdrop')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Show price details 
   if ( HArgs[1] == "showpricedetails" ) then
	FarmersToolkit.priceDetails=true;
	FarmersToolkit.savedVariables.priceDetails = FarmersToolkit.priceDetails;
	dft("(Config): Turning price details ON. (To turn off, use '/ft hidepricedetails')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Don't show price details
  if ( HArgs[1] == "hidepricedetails" ) then
	FarmersToolkit.priceDetails=false;
	FarmersToolkit.savedVariables.priceDetails = FarmersToolkit.priceDetails;
	dft("(Config): Turning price details OFF. To turn on, use '/ft showpricedetails'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Show companion-related suggestions in chat 
   if ( HArgs[1] == "showcompchat" ) then
	FarmersToolkit.CompanionComments=true;
	FarmersToolkit.savedVariables.CompanionComments = FarmersToolkit.CompanionComments;
	dft("(Config): Turning companion chat ON. (To turn off, use '/ft hidecompchat')")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Don't show companion-related suggestions in chat
  if ( HArgs[1] == "hidecompchat" ) then
	FarmersToolkit.CompanionComments=false;
	FarmersToolkit.savedVariables.CompanionComments = FarmersToolkit.CompanionComments;
	dft("(Config): Turning companion chats OFF. To turn on, use '/ft showcompchat'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end












   -- Turn on farming reports in chat
   if ( HArgs[1] == "chaton" ) then

	FarmersToolkit.FlipReport ("on")
	dft("(Config): Turning chat output ON. To turn off, use '/ft chatoff'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Turn off farming rpeorts in chat
  if ( HArgs[1] == "chatoff" ) then

	dft("(Config): Turning chat output OFF. To turn on, use '/ft chaton'")
	FarmersToolkit.FlipReport ("off")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Turn on friend reports in chat
   if ( HArgs[1] == "friendon" ) then

	FarmersToolkit.FlipFriends("on")
	dft("(Config): Turning friend reporting ON. To turn off, use '/ft friendoff'")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Turn off friend reports in chat
  if ( HArgs[1] == "friendoff" ) then

	dft("(Config): Turning friend reporting OFF. To turn on, use '/ft friendon'")
	FarmersToolkit.FlipFriends("off")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Turn on random pet swaps
   -- Turn on random pet swaps
   if ( HArgs[1] == "peton" ) then

	FarmersToolkit.FlipPet ("on")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Swap in a random pet now
   if ( HArgs[1] == "petnow" ) then

	FarmersToolkit.LaunchRandomPet("now")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show favorite pets
   if (
	   ( HArgs[1] == "favpets" ) or
	   ( HArgs[1] == "fpets" ) or
	   ( HArgs[1] == "fpet" ) or
   	   ( HArgs[1] == "favepets" ) 
      ) then

      	   FarmersToolkit.LoadFPetList("override");
	   local disp_value={};
	   local fcount=0;
	   -- I loathe this alphabetic sorting hack but I don't see a lot of people having lua table success otherwise
	   -- for key,val in orderedPairs(FarmersToolkit.FPetList) do
	   for keyX,valX in orderedPairs(FarmersToolkit.SortedPetNames) do
		local key=valX;
		local val=FarmersToolkit.FPetList[key];

		if ( val == true ) then 
			fcount = fcount + 1;
			-- dft_debug(key .. "= " .. key .. " and is set to TRUE " .. " (and key is a " .. type(key) .. ")")
			if ( FarmersToolkit.AvailPetNames[key] ) then
				-- dft_debug(key .. "= " .. FarmersToolkit.AvailPetNames[key] .. " and is set to TRUE " .. " (and key is a " .. type(key) .. ")")
				-- dft(" === " .. FarmersToolkit.AvailPetNames[key])
				disp_value[#disp_value+1] = " === " .. FarmersToolkit.AvailPetNames[key] ;
			end
	        else
			-- dft_debug(key .. "= " .. FarmersToolkit.AvailPetNames[key] .. " and is set to FALSE ")
		end
	   end

	   if ( fcount == 0 ) then
	   	dft("No pets have been marked as favorites, will draw from " .. tableLength(FarmersToolkit.FPetList) .. " available pets.");
	   else
	   	-- dft(disp_value);
		-- table.sort(disp_value);
	   	dft("== List of Favorited Pets")
		for x,y in pairs(disp_value) do
			-- dft(x ..": " .. y)
			dft(y)
		end
	   	dft("Total count of favorited pets: " .. fcount);
	   end

	CommandsProcessed=CommandsProcessed+1;
	return
   end



   -- Turn off random pet swaps
  if ( HArgs[1] == "petoff" ) then

	FarmersToolkit.FlipPet ("off")
	CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Show the name of the current pet
   if ( ( HArgs[1] == "showpet" ) or ( HArgs[1] == "whatpet" ) ) then

	   local petId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)

	   if petId and petId ~= 0 then
	         local petName = GetCollectibleName(petId)
	        dft("Current active pet: " .. petName)
	else
	        dft("No active pet (or they've run off....)");
	end
	CommandsProcessed=CommandsProcessed+1;
	return
   end


   -- Force the daily gift to update  (in case things get confused)
  if ( HArgs[1] == "forcedailyupdate" ) then

	FarmersToolkit.UpdateDailyGift();
	dft("Daily gift indicator updated as if you had claimed today's gift");
	CommandsProcessed=CommandsProcessed+1;
	return
   end









   if ( ( HArgs[1] == "resetpanels" ) or ( HArgs[1] == "panelsreset" ) ) then
	-- FTAddonIndicator:ClearAnchors(); FTAddonIndicator:SetAnchor(TOP, GuiRoot, TOP, 0, 50)
	FarmersToolkit.ResetPanelPositions();
	dft("Reset Inventory window to default location")
   end



   -- Show a data dump of variables / current values
   if ( ( HArgs[1] == "showvars" ) or ( HArgs[1] == "showvar" ) ) then

    if (FarmersToolkit.FTREP == 0 ) then -- We have been asked to show variables but reporting is turned off.
	    d(FarmersToolkit.FTChat .. "(Warning): Chat reporting has been turned off, cannot show variables.  Use '/ft chaton' to turn reporting on");
    end

    CommandsProcessed=CommandsProcessed+1;
    dft("Farmers Toolkit Help Menu - Show Variables" )
    dft("=================================================")
        dft("   --- Chat window variables ---")
	-- -- dft("  Chat line reporting is " .. FarmersToolkit.FTREP )

        if ( FarmersToolkit.FTREP == 1 ) then
          dft("  - Farming reports are on (turn off via /ft chatoff) " );
        else 
          dft("  - Farming reports are off (turn on via /ft chaton) " )
        end

        if ( FarmersToolkit.PETREP == 1 ) then
          dft("  - Pet randomization is on (turn off via /ft petoff)");
        else 
          dft("  - Pet randomization is off (turn on via /ft peton)")
        end

	if ( FarmersToolkit.FTHide ~= nil ) then
		if (FarmersToolkit.FTHide == true )  then dft("  - On-screen reports are off. (turn on via '/ft show')") end
		if (FarmersToolkit.FTHide == false ) then dft("  - On-screen reports are on. (turn off via '/ft hide')") end
	else
		dft("FarmersToolkit.FTHide is not set.")
	end

	if ( FarmersToolkit.CompanionComments ~= nil ) then
		if (FarmersToolkit.CompanionComments == true ) then dft("  - Companion chat messages are on. (turn off via '/ft hidecompchat')") end
		if (FarmersToolkit.CompanionComments == false )  then dft("  - Companion chat messages are off. (turn on via '/ft showcompchat')") end
	else
		dft("FarmersToolkit.CompanionComments is not set.")
	end

        if ( FarmersToolkit.SHOWFREINDS == 1 ) then
          dft("  - Friend reports are on (turn off via /ft friendoff) " );
        else 
          dft("  - Friend reports are off (turn on via /ft friendon) " )
        end

	if ( type(FarmersToolkit.FT_DBFLAG)=="number") then
	   if ( FarmersToolkit.FT_DBFLAG > 0 ) then
		dft("  - Debugging is on, set to :" .. FarmersToolkit.FT_DBFLAG)
	   end
	end

		
	dft(".\n")
        dft("   --- Inventory variables ---")
	dft("    BagWarnLevel = [ " .. FarmersToolkit.BagWarnLevel .. " ] - Warn when open slots < this number")
	dft("    BagPanicLevel = [ " .. FarmersToolkit.BagPanicLevel .. " ] - Panic (red text) when open slots < this number")
        dft("    Reminder = [ " .. FarmersToolkit.ReminderCount .. " ] - Play a sound every 'ReminderCount' items farmed")
        dft("    Pet Frequency = [ " .. FarmersToolkit.PetFrequencyCount .. " ] - This is the percent chance of a petswap for each Reminder items")
	dft(".\n")
	dft("   --- Reference variables ---")
	dft("       Items farmed: " .. comma_value(FarmersToolkit.tvalue));
        dft("       Unique types farmed: " .. comma_value(FarmersToolkit.UniqueItems));
	dft("       Total chests farmed: " .. comma_value(FarmersToolkit.Lootable["Chest"]))
	dft("       Total books read: " .. comma_value(FarmersToolkit.Lootable["Books"]))
	dft("       Total Restocked Items: " .. comma_value(FarmersToolkit.ReplenishedItems))
        dft("       Endeavor Warning Threshhold: " .. FarmersToolkit.EndeavorWarningThreshhold .. " - This is the # of hours before warning about endeavors expiring")
        dft("       Price Threshhold = [ " .. FarmersToolkit.PTarget .. " ]  - This is the lowest price value to recommend for the guild store");
  -- dft(zo_strformat(os.time() .. "> Combat state: actual check is: <<1>>", IsUnitInCombat("player") and "true" or "false"))

		   	
        if  ( FarmersToolkit.CombatAutoTimer) and ( FarmersToolkit.CombatAutoTimer > 0 ) then
		dft("       CombatAutoTimer = [ " .. FarmersToolkit.CombatAutoTimer .. " seconds ]  - This automatically starts a countdown timer after a battle completes. (0=Off)");
	else
		dft("       CombatAutoTimer = 0 (Off)  - This automatically starts a countdown timer after a battle completes. (0=Off)");
	end

 	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	dft("       Max inventory = " .. maxSlots );

	-- This can be turned back on but user-facing output is now available via /ft dailies
	dft(".\n")
	dft("   --- Daily Gift variables ---")
	FarmersToolkit.DailyGifts("show")

	-- If and only if (iff) this library is available, add some functionality / guidance
 	if pChat then
		-- dft_debug(".\n")
        	-- dft_debug("   --- Debug variables for pChat ---")
	else
		-- dft_debug("   --- Note: pChat addon was NOT detected. --- ");
	end
	-- If and only if (iff) this library is available, add some functionality / guidance
 	if LibAddonMenu2 then
		-- dft_debug(".\n")
        	-- dft_debug("   --- Debug variables for LibAddonMenu2---")

		-- if ( FarmersToolkit.FontL1 ) then dft_debug("    L1 Font variable (live) " .. FarmersToolkit.FontL1); else dft_debug("L1 Font variable (live) not set.") end
		-- if ( FarmersToolkit.savedVariables.FontL1 ) then dft_debug("    L1 Font variable (saved) " .. FarmersToolkit.savedVariables.FontL1); else dft_debug("L1 Font variable (saved) not set.") end

		-- if ( FarmersToolkit.FontL2 ) then dft_debug("    L2 Font variable (live) " .. FarmersToolkit.FontL2); else dft_debug("L2 Font variable (live) not set.") end
		-- if ( FarmersToolkit.savedVariables.FontL2 ) then dft_debug("    L2 Font variable (saved) " .. FarmersToolkit.savedVariables.FontL2); else dft_debug("L2 Font variable (saved) not set.") end

		dft(".\n")
	end

	-- Report status of backdrops
        if ( FarmersToolkit.dailyBD == false ) then
          dft("  - Daily activities backdrop screen is off  " );
        else 
          dft("  - Daily activities backdrop screen is on  " );
        end

        if ( FarmersToolkit.farmingBD == false ) then
          dft("  - Farming target backdrop screen is off  " );
        else 
          dft("  - Farming target backdrop screen is on  " );
        end

        dft("== End of FT showvars. Contact @vilkasmanga for updates / suggestions.")
     return
   end


   -- Set / change the frequency of celebrating NN items being farmed (also the trigger for random pets, if applicable)
   if ( HArgs[1] == "reminder" ) then
	if ( HArgs[2] ~= "" ) then
           local x=tonumber(HArgs[2])
	   if ( x > 0 ) then
           	FarmersToolkit.ReminderCount=x;
   	   	FarmersToolkit.savedVariables.ReminderCount   = FarmersToolkit.ReminderCount ;
	   	dft("Set Reminder to fire every " .. comma_value(FarmersToolkit.ReminderCount) .. " items");
 	   else 
	   	dft("Reminder unchanged (cannot set to  " .. comma_value(x) .. " items)");
	   end
	end
        CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Set / change the endeavour warning threshhold (# of hours left before an endeavor times out)
   if ( HArgs[1] == "ewl" ) then
	if ( HArgs[2] ~= "" ) then
           local x=tonumber(HArgs[2])
	   if ( x > 0 ) then
		if ( x > 100 ) then x = 100; end -- This shouldn't happen but.... humans.
           	FarmersToolkit.EndeavorWarningThreshhold=x;
   	   	FarmersToolkit.savedVariables.EndeavorWarningThreshhold   = FarmersToolkit.EndeavorWarningThreshhold ;
	   	dft("Set endeavour timeout warning level be " .. comma_value(FarmersToolkit.EndeavorWarningThreshhold) .. " hours");
		FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
 	   else 
	   	dft("Pet endeavour warning level unchanged (cannot set to  " .. comma_value(x) .. " hours)");
	   end
	end
        CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Set / change the percentage chance of a pet swap
   if ( HArgs[1] == "petfrequency" ) then
	if ( HArgs[2] ~= "" ) then
           local x=tonumber(HArgs[2])
	   if ( x > 0 ) then
		if ( x > 100 ) then x = 100; end -- This shouldn't happen but.... humans.
           	FarmersToolkit.PetFrequencyCount=x;
   	   	FarmersToolkit.savedVariables.PetFrequencyCount   = FarmersToolkit.PetFrequencyCount ;
	   	dft("Set Pet swap every Reminder items to be a " .. comma_value(FarmersToolkit.PetFrequencyCount) .. " percent chance");
 	   else 
	   	dft("Pet Frequency unchanged (cannot set to  " .. comma_value(x) .. " items)");
	   end
	end
        CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Set / change the price target threshhold
   if ( HArgs[1] == "setpricetarget" ) then
	if ( HArgs[2] ~= "" ) then
           local x=tonumber(HArgs[2])
	   if ( x > 0 ) then
           	FarmersToolkit.PTarget=x;
   	   	FarmersToolkit.savedVariables.PTarget   = FarmersToolkit.PTarget ;
	   	dft("Set price target be " .. comma_value(FarmersToolkit.PTarget) .. " gold");
 	   else 
	   	dft("Price Target unchanged (cannot set to  " .. comma_value(x) .. " gold)");
	   end
	end
        CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Adjust bag warning level
   if ( HArgs[1] == "bagwarn" ) then
	   local newWarn
	if ( HArgs[2] ~= "" ) then
           local x=HArgs[2]
           if ( ( string.match(passed_args,"percent")) or ( string.match(passed_args,"%%")) ) then
	      local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
              local anum=tonumber(x);
	      local newWarn=math.floor((x/100) * maxSlots);
              dft("Note - Detected a percentage-based request so adjusting BagWarn to be " .. x .. " percent of " .. maxSlots )
            else
		newWarn = tonumber(HArgs[2])
            end

	    if ( newWarn < FarmersToolkit.BagPanicLevel ) then
                dft("(Config): |CFF0000 Error |r: Cannot set Warn level (" .. newWarn ..") below Panic Level (" .. FarmersToolkit.BagPanicLevel .. ")")
            else
		FarmersToolkit.BagWarnLevel = newWarn
		dft("(Config): Changed free inventory bag count Warn level to [" .. FarmersToolkit.BagWarnLevel .. "]")
	    end

	end
	FarmersToolkit.savedVariables.BagWarnLevel = FarmersToolkit.BagWarnLevel
        FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())

        CommandsProcessed=CommandsProcessed+1;
	return
   end

   -- Adjust bag panic level
   if ( HArgs[1] == "bagpanic" ) then

	local newPanic

	if ( HArgs[2] ~= "" ) then
           local x=HArgs[2]
           if ( ( string.match(passed_args,"percent")) or ( string.match(passed_args,"%%")) ) then
	      local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
              
              local anum=tonumber(x);
	      local newPanic=math.floor((x/100) * maxSlots);
              dft("Note - Detected a percentage-based request so adjusting BagPanic to be " .. x .. " percent of " .. maxSlots )
            else
		newPanic = tonumber(HArgs[2])
            end

	    if ( newPanic > FarmersToolkit.BagWarnLevel ) then
                dft("(Config): |CFF0000 Error |r: Cannot set Panic level (" .. newWarn ..") above Warn Level (" .. FarmersToolkit.BagWarnLevel .. ")")
            else
		FarmersToolkit.BagPanicLevel = newPanic
		dft("(Config): Changed free inventory bag count Panic level to [" .. FarmersToolkit.BagPanicLevel .. "]")
	    end

	end


	FarmersToolkit.savedVariables.BagPanicLevel = FarmersToolkit.BagPanicLevel
        FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())

        CommandsProcessed=CommandsProcessed+1;
	return


   end

    -- Style note.  We're using d(...) instead of dft(....) here.  It just looks better.
    -- But also, dft could suppress output if FarmersToolkit.FTREP says to and this is a help
    -- screen so.... don't hide the help screen when people might be looking
    -- for help on how to unhide things that the helpscreen describes.

    -- dft("Help starts here");
    dft("FT Help Menu - Version " .. FarmersToolkit.FTVersion )
    d("============")
    d(" -- /fthelp - This menu")
    d(" --------------- Farming Reporting commands  ------------")
    d(" -- /ft duplicates or /ft showdupes - List items that are both in the backpack and in the bank");
    d(" -- /ft gtreview or /ft gtr - List items that may be worth sending to guild traders.");
    d(" -- /ft gtrb - Same as gtreview but shows bank items instead of inventory/bags");
    d(" -- /ft deconlist [terse] or /ft rdl - show suggested deconstructable items. Terse=only shows items with known values.");
    d(" -- /ft showcompchat - Show companion-related comments in chat (likes dislikes, rapport, etc.)");
    d(" -- /ft hidecompchat - Suppress companion-related comments in chat");
    d(" -- /ft craftbag [threshhold] [max entries] - Show craftbag by inventory counts.");
    d(" --    Optional: [threshhold] - Set the minumum stack count to show, defaults to 2,000");
    d(" --    Optional: [max entries] - Limit the list to no more than [max entries] lines");
    d(" -- /ftfarmlist - List out items farmed this session")
    d(" --    Optional: etfarmlist [search] will only show matching entries.")
    d(" -- /ft fl - Same as /ftfarmlist")
    d(" -- /ft fl2 - Extended version of /ftfl")
    d(" --     - Shows unique number for farmed items")
    d(" --     - Additionally shows if item is in inventory (I), Bank (B), or CRaft bag (Cb)");
    d(" -- /ftcount - Show quick count of items farmed") 
    d(" -- /ft stats - Show a quick (and useless) summary of items farmed") 
    d(" -- /ft fullstats - Show detailed (and even more useless) stats about farmed items")
    d(" -- /ft gold - Show quick snapshot of gold gained this session")
    d(" -- /ftreset - Reset all farming lists and counts for this session") 
    d(" -- ")
    d(" --------------- Farming Configuration commands  ------------")
    d(" -- /ft chaton - Turn on FT Reporting in chat")
    d(" -- /ft chatoff - Turn off FT Reporting in chat")
    d(" -- /ft peton - Turn on launching a random pet at various times")
    d(" -- /ft petoff - Turn off launching a random pet at various times")
    d(" -- /ft petnow - Selects a random pet")
    d(" -- /ft favepets - Show current favorite pets");
    d(" -- /ft show- Turn on FT Reporting on screen")
    d(" -- /ft hide - Turn off FT Reporting on screen")
    d(" -- /ft [show|hide]pricedetails - Control whether price data is shown with farming details in chat");
    d(" -- /ft bagwarn XX - Set open slot warning (yellow text) level to be XX")
    d(" --      Example: '/ft bagwarn 22' - Set open slot level to be 22")
    d(" --      Example: '/ft bagwarn 30 %' - Set open slot to be 30% of total bag space")
    d(" -- /ft bagpanic - Set open slot panic (red text) to be XX")
    d(" --      Note: Follows format described above in bagwarn")
    d(" -- /ft reminder XX - Play a sound every XX items farmed")
    d(" -- ")
    d(" --------------- Farming Targeting / Shopping list commands  ------------")
    d(" -- /ft settarget [Item] nn - Assign [item] a farming target of nn")
    d(" --       - [item] is a linked item (e.g., left click on an item, use 'Link in chat')");
    d(" --       - You can also right click in your inventory and choose ");
    d(" --         'Set Farming target in chat' if LibCustomMenu is available.");
    d(" -- /ft settarget [Item] delete - Delete [Item] from target list.");
    d("          - Recall, setting to 0 makes it a celebration-only entry");
    d(" -- /ft settarget [Item] delete - Delete [Item] from target list.");
    d("          - Recall, setting to 0 makes it a celebration-only entry");
    d(" -- /ft listtargets (also: showtargets or showtargetlist) - display target list");
    d(" -- You can also set targets by item type (weapon, raw material, herb, etc.)")
    d(" -- /ft setTypeTarget [Item] nn - Assign type of items [item] a farming target of nn")
    d("          - command is can be all lower case, just used capitals for clarity here");
    d(" -- /ft setTypeTarget [Item] delete - Delete [Item] from target types list.");
    d(" -- /ft showtargets - Show current list of targeted items, counts, and goals");
    d(" -- /ft savetargets - Save current list of targeted items and goals");
    d(" -- /ft loadtargets - Load current list of targeted items and goals");
    d(" -- /ft showfarmlist - Display current non-zero, unmet farming targets on screen");
    d(" -- /ft hidefarmlist - Stop displaying non-zero, unmet farming targets on screen");
    d(" -- ")
    d(" --------------- Inventory related commands ------------")
    d(" -- /ft bagdetails - Show how FTK codes certain items in your bag (paperwork, stolen, script, etc.)")
    d(" -- ")
    d(" --------------- Daily / Weekly Endeavor commands ------------")
    d(" -- /ft dailies - Show current list / progress of available daily and weely endeavors")
    d(" --     - Grey = not started, Yellow = In progress, Green= Complete")
    d(" -- /ft forcedailyupdate - force the daily gift update (in case things get confused)");
    d(" -- ")
    d(" --------------- Companion related commands ------------")
    d(" -- /showrap - Show current companion's rapport level")
    d(" -- /showallrap - Show all companions' rapport level (Companion must have been summoned at least once)")
    d(" -- /sr - same as /showrep")
    d(" -- /ft [show|hide]compchat - Toggle showing companion chats");
    d(" -- ")
    d(" --------------- Book commands ------------")
    d(" -- /ft showbooks [filter] - List out read / known books with optional [filter] (also: /ft sb|showbooklist|booklist)");
    d(" -- ")
    d(" --------------- Timer commands ------------")
    d(" -- /ft timer mm:ss - Put up an on-screen countdown timer");
    d(" -- /ft mt - Put up a 5 minute timer");
    d(" -- /ft [hide/show]timer - toggle on-screen countdown presence");
    d(" -- /ft combattimer mm:ss - Automatially start a countdown timer for mm:ss at the end of combat")
    d(" --       (Useful for farming mobs that have a specific respawn time.  Ex: /ft combattimer 5m")
    d(" --       To turn off, set timer to 0 or just issue: /ft combattimer off");
    d(" -- ")
    d(" --------------- Truly Misc commands ------------")
    d(" -- /ft friend[on|off] - Toggle showing when friends are on (when they come/go, when you change zones, etc.)");
    d(" -- ")
    d(" --------------- Experimental commands ------------")
    d(" -- /ft savedata - Save out current farming report")
    d(" -- /ft loaddata - Load previously saved farming data (replaces current farming data)")
    d(" -- /ft nukedata - Zeroes out current farming reports as well as saved data report")
    d(" -- /ft listslash  - List all registered / commands (across all addons)");
    d(" -- ")
    d(" --------------- Experimental location commands ------------")
    d(" -- /ft loc - Show location data");
    d(" -- /ft loc2 - Show location data in a different way");
    d(" -- /ft getloc [xxx] - Find location data for [xxx]");
    d(" -- /ft setloc [xxx] - Record current location data as [xxx]");
    d(" -- /ft showloc [all|zone] - List known locations for [xxx] or just the current map");
    d(" -- /ft testwayshrine  - List all (known?) wayshrines with obscure location data");

    d("== End of list.  Contact @vilkasmanga for updates / suggestions.")

    
    -- There was a leak in the code above where commands were getting executed despite a return, thus CommandsProcessed.
    -- Now, we'll use that to note whether we were passed an argument that wasn't already processed (and, supposedly,
    -- returned)
    if ( ( HArgs[1] ~= "" ) and ( CommandsProcessed == 0 ) and ( string.lower(HArgs[1]) ~= "help" )  and ( type(HArgs[1]) ~= "nil") ) then
	    	dft("Unrecognized command: [" .. HArgs[1] .. "]")
    end
end
-- end of FarmersToolkit.Help


-- Odd request to have "estimated value of items" in a bank (general posting by november1983)
-- Seems odd but figured it was worth a shot

function FarmersToolkit.EstimatedValue(bank,arg) 

	-- dft_debug("Top of FTK:EV> Bank=["..bank.."], arg=["..arg.."]")
	
	local Container = BAG_BACKPACK; -- By default
	local ContainerName="Backpack";

	local TotalValue=0;
	local TotalItemCount=0;
	local AvgValue=0;

	local GuildBankNum=0;
	local GuildBankName="";

	if ( bank == "bank" ) then
		Container = BAG_BANK; -- By default
		ContainerName="Bank";
	end

	if ( bank == "sbank" ) then
		Container = BAG_SUBSCRIBER_BANK; -- By default
		ContainerName="Subscriber Bank";
	end

	if ( bank == "guild" ) then
		Container = BAG_GUILDBANK; -- By default
		GuildBankNum=GetGuildId(arg); -- Look up guild id by # given by call, 1 = 1st guild, 2 = 2nd, etc.
		GuildBankName=GetGuildName(GuildBankNum); -- Look up guild name by Guild ID # 
		ContainerName="Guild Bank for [" .. GuildBankName .. "] (Your guild #" .. arg .." maps to Guild #" .. GuildBankNum .. ")";
		dft("Preliminary setup for guild bank scan suppostedly targets Guild Bank #" .. GuildBankNum .. " which is index # " .. arg .. " for the guild " .. GuildBankName);
		SelectGuildBank(GuildBankNum);

	end


	if ( bank == "test" ) then
		Container =arg
		ContainerName="Guild Bank on Demand";

	end

     	local numSlots = GetBagSize(Container)

	-- dft_debug("Scanning " .. ContainerName .. " -- Number of slots =" .. numSlots)

	if ( bank == "guild" ) then -- process these differently
		local tname=GuildBankName;

		if ( IsGuildBankOpen() == false ) then
			dft("Error - Cannot scan guild bank unless the guild banker is open, sorry.")
			return;
		end

		if ( tname == "" ) then
			dft("Error - Cannot scan guild bank (Name = blank) - bad index maybe? Argument given was [" .. arg .. "]");
			return;
		end

		dft("Launching guild scanner for ["..GuildBankName.."], Guild # " ..GuildBankNum .. ", spaces = " .. numSlots);

		SelectGuildBank(GuildBankNum);
		 if ( GetSelectedGuildBankId() ) then dft("DBG - Good news! Assigned bank ID: " .. GetSelectedGuildBankId() .. "!"); else dft("DBG - Bad news :(   Select Guild Bank (" .. GuildBankNum .. ") returned nil....") end

	    	local bankCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)

		-- dft("Post assignment of bankcache is type " .. type(bankCache) .. " and the guildname is [" .. tname .. "] (#" .. arg ..")")

		-- dft("Start of bankCache scan");

		local GbankIDTest=GetSelectedGuildBankId();

		if ( GbankID ) then
			-- dft_debug("Sanity check - selected Guild Bank ID = [" ..  GetSelectedGuildBankId() .. "]");
		else
			-- dft_debug("Failed sanity check, GetSelectedGuildBankId called returns a nil value despite selecting #" .. GuildBankNum);
		end

		-- This code is based on Garkin's ESOUI posting of 2/25/15 and may/may nto be relevent/correct fir current versions
     		local numSlots = GetBagSize(BAG_GUILDBANK)
    		for slotIndex, slotData in pairs(bankCache) do --using pairs instead of ipairs, because there could be missing slotIndexes (empty slots)
			-- local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(Container, bSlot)
        		-- d(slotData.rawName) --raw name: "rice mash"
        		-- d(slotData.name)  --formated name: "Rice Mash"
        		-- d(slotData.nameWithQuantity) --formated name with quantity: "Rice Mash (60)"

			-- d("Slot index=" .. slotIndex .. ", slotData = " .. type(slotData));
			--
			--
			-- dft_debug("   GBank #" .. GuildBankNum .. ": " .. slotData.name .. ": Count = " .. slotData.stackCount .. ", Value=" .. slotData.stackSellPrice)
			TotalItemCount=TotalItemCount + slotData.stackCount;
			TotalValue = TotalValue + (slotData.stackCount * slotData.stackSellPrice)
    		end
		-- dft("End of bankCache scan");
		-- dft("Start of manual bank scan");

		if ( TotalValue == 0 ) then -- the previous scan failed for some reason
	   		for bSlot = 1, numSlots do
				local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_GUILDBANK, bSlot)
				local GName=GetItemName(BAG_GUILDBANK, bSlot);

					if ( stack > 0 ) then
						dft("GBank scan #" .. bSlot ..": " .. GName .. " = " .. stack .. " @ " .. sellPrice .. " each " );
						TotalItemCount=TotalItemCount + count;
						TotalValue = TotalValue + (count * sellPrice)
					end
	    		end
	    		dft("End of manual bank scan");
		end

	else
	   for bSlot = 1, numSlots do
		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(Container, bSlot)

		for bSlot = 1, numSlots do
			TotalItemCount=TotalItemCount + stack
			TotalValue = TotalValue + (stack * sellPrice)
		end
	    end
	end

	if ( TotalValue > 0 ) then
		AvgValue = string.format("%.2f", TotalValue / TotalItemCount )
		dft("Total items in " .. comma_value(GuildBankName) ..": " .. comma_value(TotalItemCount) .. " -- Total Value = " .. comma_value(TotalValue) .. " -- Average: " .. AvgValue .. " Gold per item")
	else
		dft("Somehow TotalValue = " .. TotalValue);
	end

end --Function EstimatedValue


-- Quickly scan the backpack and count stolen things 
function FarmersToolkit.CountOtherItems(arg1)
     	local numSlots = GetBagSize(BAG_BACKPACK)
	-- dft_debug("(FTK_CSIa): Backpack (I) slots: " .. numSlots);

	local LootCount=0;
	local TreasureCount=0;
	local MuseumCount=0;
	local FurnCount=0;
	local CompanionItemCount=0;
	local ContainerCount=0;
	local PaperCount=0;
	local RecipeCount=0;
	local ScriptCount=0;
	local MapCount=0;

	local TotalValue = 0
	local TotalItemCount = 0

	local showdetails=false;
	if ( arg1 == "details") or ( arg1 == "detail" ) then showdetails=true; end
	if ( showdetails) then dft(" == Details for other items displayed below.") ;  end


	-- So, observed behavior: An item may be stolen *and* a treasure, which caused the on-screen report
	-- to appear to list an item twice (that is, this routine would return Treasure = 1 and Stolden = 1
	-- for a single item.)  Since the goal of this routine is to help with bag space management, listing
	-- somethinhg "twice" is counter to that goal.  So.. re-write!
	--
	-- Now, if something is stolen, then the stolen count is increased and nothing else will be considered
	-- (Thus, while technically a treasure, a stolen state "trumps" an items' type).  Though I have never
	-- seen one, this same logic extends to companion items, so if there is a stolen companion item, it will
	-- just be listed as stolen, not a companion item.
	--
	-- There is no right answer here, just need to make sure it is clear in the documentation

	for bSlot = 1, numSlots do

		-- Look up item info
   		local link  = GetItemLink(BAG_BACKPACK, bSlot)
		local itemType = GetItemLinkItemType(link)
		local SpecialItemType=ZO_GetSpecializedItemTypeTextBySlot(BAG_BACKPACK, bSlot);


		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_BACKPACK, bSlot)

		TotalItemCount=TotalItemCount + stack

		TotalValue = TotalValue + (stack * sellPrice)
        

		-- First and foremost, check to see if this is a stolen item
		if ( IsItemStolen(BAG_BACKPACK, bSlot) == true ) then 
			-- dft_debug("IsItemStolen("..BAG_BACKPACK..", "..bSlot..") = " .. link .. " is marked as TRUE.... adjusting LootCount (" .. LootCount ..") by 1");
			if ( arg1 == "stolen") or ( arg1 == "loot" ) then 
				dft("IsItemStolen("..BAG_BACKPACK..", "..bSlot..") = " .. link .. " is marked as TRUE.... adjusting LootCount (" .. LootCount ..") by 1");
			end
			if ( showdetails) then dft("Note: " .. link .. " is marked as Stolen") ;  end
			LootCount=LootCount+1; 
		else 

			-- Check to see if this is a "useless" item (which I define as something taking up bag space for no immediately good reason)
			-- local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_BACKPACK, bSlot)

	 -- dft_debug("Bag " .. BAG_BACKPACK .. ", Slot " .. bSlot .. " contains [" .. link .. "], an equipType of " .. equipType .. ", an item of type #" .. itemType .. ", an itemstyleID of " .. itemStyleId .. ", ZOS=" .. SpecialItemType );

			if ( itemType == 56 ) then 
				TreasureCount = TreasureCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as Treasure") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as Treasure") ;  end
			end -- Type 56 = Treasure

			if ( itemType == 48 ) then 
				TreasureCount = TreasureCount +1 ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as Treasure") ;  end
				-- dft_debug("Tagging " .. link .. " as Treasure") ; 
			end -- Type 48 = Trash

			if ( itemType == 18 ) or ( itemType == 70 ) then 
				ContainerCount = ContainerCount +1 ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as a Container") ;  end
				-- dft_debug("Tagging " .. link .. " as Container") ; 
			end -- Type 18 = ContainerCount

			-- Handle specialized cases (Monster trophies, Museum pieces)
			if (
				( SpecialItemType == "Monster Trophy" )
				or ( SpecialItemType == "Rare Fish" )
			   ) then 
				TreasureCount = TreasureCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as Monster Trophy") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as Treasure ") ;  end
			end -- Type 34 = ITEM_TYPE_DISPLAY_CATEGORY_TROPHY isn't specific enough, we need the extra definition from ZO_GSITTBS above
	
			if ( SpecialItemType == "Museum Piece" ) then 
				MuseumCount = MuseumCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as Museum Piece") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as a Museum Piece") ;  end
			end -- Type 34 = ITEM_TYPE_DISPLAY_CATEGORY_TROPHY isn't specific enough, we need the extra definition from ZO_GSITTBS above
	
			if ( SpecialItemType == "Furnishing" ) then 
				FurnCount = FurnCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as Furniture Piece") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as Furniture") ;  end
			end -- 

			if ( 
		              ( SpecialItemType == "Treasure Map" ) 
		              or ( SpecialItemType == "Survey Report" ) 
			   ) then 
				MapCount = MapCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as a map") ; 
				-- if ( showdetails) then dft("Note: " .. link .. " is marked as a map") ;  end
			end -- 

			if (
			    ( SpecialItemType == "Food Recipe" ) 
			    or ( SpecialItemType == "Drink Recipe" ) 
			    or ( SpecialItemType == "Recipe Fragment" ) 
			    or ( SpecialItemType == "Furnishing Praxis" ) 
			    or ( SpecialItemType == "Furnishing Design" ) 
			    or ( SpecialItemType == "Furnishing Pattern" ) 
			    or ( SpecialItemType == "Furnishing Blueprint" ) 

			   ) then 
				RecipeCount = RecipeCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as recipe") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as recipe") ;  end
			end -- 

			if (
			    ( SpecialItemType == "Master Writ" ) 
			    or ( SpecialItemType == "Scroll" ) 
			    or ( SpecialItemType == "Motif Book" ) 
			    or ( SpecialItemType == "Motif Chapter" ) 
			    or ( SpecialItemType == "Style Page" ) 

			   ) then 
				PaperCount = PaperCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as paperwork") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as paperwork") ;  end
			end -- 

			if (
			    ( SpecialItemType == "Affix Script" ) 
			    or ( SpecialItemType == "Focus Script" ) 
			    or ( SpecialItemType == "Signature Script" ) 
			   ) then 
				ScriptCount = ScriptCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as a script") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as script") ;  end
			end -- 

			if ( SpecialItemType == "Lighting" ) then 
				FurnCount = FurnCount +1 ; 
				-- dft_debug("Tagging " .. link .. " as Furniture Piece (though it is marked as Lighting)") ; 
				if ( showdetails) then dft("Note: " .. link .. " is marked as Furniture") ;  end
			end -- The ZO command returns lighting even though it is also marked furnishing.  *shrug*
	
			-- Not sure if Trophys shuld be counted here, leaving commented out for now
			-- Research suggests not: lots of things are marked trophy but are not useless items
			-- (Survey reports, Museum pieces, (some) recipes, Toys, etc.  I think I'll skip this for now.
			-- Uncomment the line below and turn on debugging if you are curious.
			-- if ( itemType == 5 ) then  dft_debug("Tagging " .. link .. " as a Trophy (but not adjusting counts)") ; end -- Type 5 = Trophy
			-- if ( itemType == 5 ) then TreasureCount = TreasureCount +1 ; end -- Type 5 = Trophy
	
	
			-- Ugly hack but look for the phrase "Companion's" in the name and bump up CpCount accordingly
			-- (If anyone knows of a "IsItemCompanionGear" call, please enlighten me)
			--
			-- Also, technically, I should wrap this up in an if/then from above (much like the "if stolen, that's it" approach above)
			-- but I'm banking on (famous last words) there not being a "companion" version of treasures or trash
			if ( string.find(string.lower(icon),"companion",1,true))  then CompanionItemCount = CompanionItemCount+ 1; end

		end

	end
        local AvgValue = string.format("%.2f", TotalValue / TotalItemCount )
	-- dft_debug("Total items in Backpack: " .. TotalItemCount .. ", Total Value = " .. TotalValue .. ", Average: " .. AvgValue)

	-- dft_debug("(FTK:CSIb): Returning Stolen (" .. LootCount .. "), Treasure=(" .. TreasureCount .. "), Companion = (" .. CompanionItemCount .. "), Container = (" .. ContainerCount .. "), Furn = (" .. FurnCount .. "), Paper = (" .. PaperCount .. "), Maps = (" .. MapCount .. "), Recipes = (" .. RecipeCount .. ")")
	 
	return LootCount, TreasureCount, CompanionItemCount, ContainerCount, MuseumCount, FurnCount, PaperCount, MapCount,RecipeCount,ScriptCount
end

function FarmersToolkit.OnPlayerCombatState(event, inCombat)
  -- The ~= operator is "not equal to" in Lua.

  -- dft(zo_strformat(os.time() .. "> Combat state: inCombat is: <<1>>", value and "true" or "false"))
  -- dft(zo_strformat(os.time() .. "> Combat state: actual check is: <<1>>", IsUnitInCombat("player") and "true" or "false"))

  -- if inCombat == false and FarmersToolkit.inCombat == true then -- We have just left battle
  if IsUnitInCombat("player") == false and FarmersToolkit.inCombat == true then -- We have just left battle

	local curlevel= GetUnitLevel("player") ;
	if (  curlevel < 50 ) then 
      		-- FarmersToolkit.UpdateDailies();
        	FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
		-- dft("Called to update the screen, FYI");
		end
	






	if ( FarmersToolkit.CombatAutoTimer  and FarmersToolkit.CombatAutoTimer > 0 ) then
		-- Note: In large boss fights. this may happen multiple times (during pauses/downtimes)
		-- So, we won't annoucne it here and we'll suppress the countdown timer until we are
		-- *completely* out of combat.  So, a tad inefficient but nothing too serious.  I hope.
		-- (If it is really bad, one of the Old Wise ones [Baer] will gently smack me up side the head, I suspect)
		-- dft("Auto-restarting time for " .. FarmersToolkit.CombatAutoTimer);
		FarmersToolkit.StartTimer(FarmersToolkit.CombatAutoTimer)
	-- else if (FarmersToolkit.TimerDUration > 0 ) then
		-- Turn timer back on / make visible
	-- 	FTAddOnTimer.SetHidden(false);
	  --   end
	  end
  end
  if inCombat ~= FarmersToolkit.inCombat then
    -- The player's state has changed. Update the stored state...
    FarmersToolkit.inCombat = inCombat
 
   -- Structure left in place, just in case.
   if (inCombat == true ) then
	 -- -- d("OPCS DEBUG 1: inCombat is true");
   else
	 -- -- d("OPCS DEBUG 1: inCombat is false");

   end

    -- -- FTAddonIndicator:SetHidden(not inCombat)
    FTAddonIndicator:SetHidden(FarmersToolkit.FTHide) -- Whatever FarmersToolkit.FTHide is set to, per defaults and commands
    FTAddonIndicator2:SetHidden(FarmersToolkit.FTHide2) -- Whatever FarmersToolkit.FTHide2 is set to, per defaults and commands

    if inCombat then
      -- -- d("Entering combat.")

      FarmersToolkit.SetTextColor("red")
      -- Get a random message
      local randomMsg=FarmersToolkit.CombatMsgs[math.random (#FarmersToolkit.CombatMsgs) ]
      FarmersToolkit.UpdateText(randomMsg)
	      
    else
      -- -- d("Exiting combat.")
      
      FarmersToolkit.SetTextColor("yellow")
      FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())

      FarmersToolkit.DailyProgress("chat");

    end

  end -- if inCombat changed
end  -- function itself
-- end of FarmersToolkit.OnPlayerCombatState

-- This function is helpful when displays are in minimized or suppressed states
-- since it changes the color of teh text based on status (bags running low, for example)
function FarmersToolkit.SetTextColor(acolor)

local labelControl = FTAddonIndicator:GetNamedChild("Label")

    if labelControl then
       	if (acolor == "red") then
      	    labelControl:SetColor(255,0,0,1.0)
	end
	if (acolor == "yellow") then
      	    labelControl:SetColor(255,255,0,1.0)
	end
	if (acolor == "green") then
      	    labelControl:SetColor(0,255,0,1.0)
	end
	if (acolor == "blue") then
      	    labelControl:SetColor(0,0,255,1.0)
	end
    end

end

function FarmersToolkit.LockpickSuccess(event)
		
	local interactionData = {}

		interactionData.action, interactionData.name, interactionData.blockedNode, interactionData.isOwned = GetGameCameraInteractableActionInfo()

	-- Bug report 2/11/24 by AZhdeen: 
	-- user:/AddOns/FarmersToolkit/Startup.lua:1910: operator + is not supported for nil + number
	-- Fix: Add code to handle FarmersToolkit.Lootable[interactionData.name] being nil (because interactionData.name may not be "Chest")
	-- So, the fix is to hard-code "Chest" whenever using FarmersToolkit.Lootable["Chest"] ( and not rely on interactionData.name)
	-- dft_debug("LockpickSuccess called, name = " .. interactionData.name);
         if (type(interactionData.name) ~= "nil" ) then
           if ( type(FarmersToolkit.Lootable["Chest"]) == "nil" ) then
	      FarmersToolkit.Lootable["Chest"]=1;
	   else
	      FarmersToolkit.Lootable["Chest"]=FarmersToolkit.Lootable["Chest"]+1
	   end
         end
end

-- Handle on-screen updates of on-screen texts
function FarmersToolkit.UpdateText(astring)
   local labelControl = FTAddonIndicator:GetNamedChild("Label")

-- Handle color changing based on available slots -- not the best logical location but...

   local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
   local openSlots = maxSlots - usedSlots

   -- d("FT-DEBUG(UT1): openSlots = [" .. openSlots .. "], BW=" .. type(FarmersToolkit.BagWarnLevel) .. ", BP=" .. type(FarmersToolkit.BagPanicLevel) .." ")
   local OKTOGO=0; -- Every so often, something goes wonky.  Leaving this in to help detect it (see "possession" message, below)
   if ( type(FarmersToolkit.BagWarnLevel) ~= "nil"  ) then 
	-- d("FT-DEBUG(UTI): Warn=[" .. FarmersToolkit.BagWarnLevel .. "]") 
        OKTOGO=OKTOGO +1
   end
   if ( type(FarmersToolkit.BagPanicLevel) ~= "nil"  ) then 
	-- d("FT-DEBUG(UTI): Panic=[" .. FarmersToolkit.BagPanicLevel .. "]") 
	OKTOGO = OKTOGO +1 
   end

  -- This should probably be handled with ZO_strformat but... I didn't know about that then...
 if (OKTOGO == 2 ) then
   if ( openSlots < FarmersToolkit.BagWarnLevel ) then FarmersToolkit.SetTextColor("yellow") end
   if ( openSlots < FarmersToolkit.BagPanicLevel ) then FarmersToolkit.SetTextColor("red") end
   if ( openSlots >= FarmersToolkit.BagWarnLevel ) then FarmersToolkit.SetTextColor("green") end
 else 
    dft_debug("FT-DEBUG: Something is wrong with the possessed variables FarmersToolkit.BagWarnLevel and FarmersToolkit.BagPanicLevel.  Again.  OKTOGO=[" .. OKTOGO .."]")
 end

 local inCombat = IsUnitInCombat("player")
 if ( inCombat ) then FarmersToolkit.SetTextColor("red") end

	if labelControl then
   	 labelControl:SetText(astring)
	end
end

-- Update 2nd line
function FarmersToolkit.UpdateText2OLDJUNKVERSION(astring)
   local labelControl = FTAddonIndicator:GetNamedChild("Label2")

   -- d("FT-DEBUG(UT1): openSlots = [" .. openSlots .. "]")

   local inCombat = IsUnitInCombat("player")
   if ( inCombat ) then FarmersToolkit.SetTextColor("red") end

   if labelControl then
   	 labelControl:SetText(astring)
   end
end

function FarmersToolkit.UpdateText2(astring)
   local labelControl = FTAddonIndicator:GetNamedChild("Label2")

   local inCombat = IsUnitInCombat("player")
   if ( inCombat ) then FarmersToolkit.SetTextColor("red") end

   if labelControl then
     if ( FarmersToolkit.SE_Flag ) then
       labelControl:SetText("")
       labelControl:SetHidden(true)
     else
       labelControl:SetHidden(false)
       labelControl:SetText(astring)
     end
   end
end


-- Update (appearance of) FarmList  (Header and text)
function FarmersToolkit.UpdateFarmlist(astring)

	-- dft_debug("Entered UpdateFarmlist (UF)");
	if ( FarmersToolkit.FTHide2 == true ) then
		-- dft_debug("(UF): FTHide2 is TRUE")
	else
		-- dft_debug("(UF): FTHide2 is FALSE")
	end

   -- First, check to see if the screen is on and if not, bounce
   if ( FarmersToolkit.FTHide2 == true ) then return end

   -- Next, update the header
   local labelControl = FTAddonIndicator2:GetNamedChild("Farmlist")

   local header_string=FarmersToolkit.ListTargetCounts("header");
   if labelControl then
   	 labelControl:SetText(header_string)
	 -- dft_debug("UF): Set header string to [ " .. header_string .. "]")
   end

   -- Next, update the body (text)
   local labelControl2 = FTAddonIndicator2:GetNamedChild("Farmlist2")
   local text_string=FarmersToolkit.ListTargetCounts("screen");
   if labelControl2 then
   	 labelControl2:SetText(text_string)
   end
end


-- Return daily quest/activity info in formatted string (for chat or screen, depending on retType) 
-- retType = Screen or chat (or if not Screen)
function FarmersToolkit.DailyProgress(retType)

   -- Specific code in light of EOS's shift away from endeavors
   if ( FarmersToolkit.SE_Flag ) then
     -- local retval="Endeavors removed 3/1/26";
     local retval="";
     return retval
   end





	local numActivities = GetNumTimedActivities()
	local DailyTimeWarning=""
	local ADailyNumber = 2; -- This will be any of the lua index returns for a daily endeavour (set below)
	local AWeeklyNumber = 2; -- This will be any of the lua index returns for a weekly endeavour (set below)
	

	local Retval_Screen =" |c1EDDFFRecommended endeavors: " .. DailyTimeWarning .. "\r\n" -- Return a string suitable for on-screen status

	if FarmersToolkit.IVShrink and ( ( FarmersToolkit.IVShrink == 3 ) or ( FarmersToolkit.IVShrink == 2 ) ) then -- if we are in compressed presentation mode
		Retval_Screen =" |c1EDDFFActive endeavors: " .. DailyTimeWarning .. "\r\n" -- Return a string suitable for on-screen status
	end

	local   Retval_Chat = "" -- Return a string suitable for printing in chat
	local   Retval_ScreenD = "" -- Group Daily Endeavors together
	local   Retval_ScreenW = "" -- Group Weekly Endeavors together
	local   Retval_ScreenT = "" -- Terse combination of ACTIVE Daily or weekly endeavors

	if type(retType) == nil then retType="Chat" end

	-- Now calculate how many are actually done....
	local DoneDailies = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_DAILY)
	local DoneWeeklies = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)

	local BestDaily=0; 
	local BestDailyCount=0; 
	local BestDailyIndex=99;

	local BestWeekly=0;
	local BestWeeklyCount=0;
	local BestWeeklyIndex=99

  	for index = 1, numActivities do
		local RewID, RewAmt=GetTimedActivityRewardInfo(index,1);
		local RewID2, RewAmt2=GetTimedActivityRewardInfo(index,2);

		local SomeValue = RewAmt*10000+RewAmt2; -- Assumes RewAmt will never be > 9999 in value

		if (GetTimedActivityType(index) == 1 ) then -- This is a weekly
			if ( SomeValue > BestWeekly ) then 
				BestWeekly = SomeValue; 
				BestWeeklyCount = 0; 
				-- dft_debug("Set index " .. index .. " to be new best weekly due to score being: " .. SomeValue); 
			end
			if ( SomeValue == BestWeekly ) then BestWeeklyCount = BestWeeklyCount +1; end
			if ( BestWeekly > 0 ) and ( BestWeekly == SomeValue) then
				if (BestWeeklyCount == 1 ) then -- if we've found a "best", record the index
					BestWeeklyIndex=index; 
				else
					BestWeeklyIndex=0;-- if we've found more than one "best", zero out the index
				end
			end
			-- dft_debug("Found a weekly (" .. index .. ") where the score is " .. SomeValue .. " and the count is now " .. BestWeeklyCount .. ", Index = " .. index .. " vs. BestWeeklyIndex = " .. BestWeeklyIndex);


		else  -- this is a daily
			if ( SomeValue > BestDaily ) then 
				BestDaily = SomeValue; 
				BestDailyCount = 0; 
				-- dft_debug("Set index " .. index .. " to be new best daily due to score being: " .. SomeValue); 
			end
			if ( SomeValue == BestDaily ) then BestDailyCount = BestDailyCount +1; end
			if ( BestDaily > 0 ) and ( BestDaily == SomeValue ) then
				if (BestDailyCount == 1 ) then -- if we've found a "best", record the index
					BestDailyIndex=index; 
				else
					BestDailyIndex=0;-- if we've found more than one "best", zero out the index
				end
			end
			-- dft_debug("Found a daily (" .. index .. ") where the score is " .. SomeValue .. " and the count is now " .. BestDailyCount .. ", Index = " .. index .. " vs. BestDailyIndex = " .. BestDailyIndex);

		end

	end


	-- dft_debug("DEBUG: Best Daily = " .. BestDaily .. " and The count is " .. BestDailyCount .. " and the BestDailyIndex is set to " .. BestDailyIndex);
	-- dft_debug("DEBUG: Best Weekly = " .. BestWeekly .. " and The count is " .. BestWeeklyCount .. " and the BestWeeklyIndex is set to " .. BestWeeklyIndex);

	local rewardType 
  	for index = 1, numActivities do
		local EA_Max= GetTimedActivityMaxProgress(index)
		local EA_SoFar = GetTimedActivityProgress(index)
		local EA_Difficulty = GetTimedActivityDifficulty(index)

		local RewID, RewAmt=GetTimedActivityRewardInfo(index,1);
		local RewID2, RewAmt2=GetTimedActivityRewardInfo(index,2);

		local TextColor="CCCCCC" -- Default to white
		if ( EA_Difficulty > 3 ) then -- This is a difficult one, paint it blue by default
				TextColor="9999FF"
		end
		if ( EA_SoFar > 0 ) then 
			TextColor="FFFF00" -- yellow if active
			if ( EA_SoFar == EA_Max ) then 
				TextColor="00FF00"  -- green b/c we're done	
			end 
		end
		
		rewardType = GetRewardType(RewID) -- Only used for debugging, apparently

		 -- One of the upgrades corrupted the reward tracking, somehow returned a table.  
		 -- Stopped happening after a patch tho so... we'll keep this code here but commented out
		 -- as a sort of superstitous protection against that bugs return
		 --
		 -- dft_debug("---- Start");
		 -- dft_debug("loop index= " .. index .. ", RewardID = " .. RewID .. ", RewardAmt = " ..RewAmt .. ", RewardType = " .. rewardType );
		 -- dft_debug("Reward type type = " .. type(GetRewardType(RewID)));
		 -- dft_debug("Reward RewID = " .. RewID);
		 -- dft_debug("RewardAmt = " .. RewAmt);
		 -- dft_debug("Reward RewAmt Currency Type " .. GetAddCurrencyRewardInfo(RewID));
		 -- dft_debug("Reward RewID2 = " .. RewID2);
		 -- dft_debug("Reward RewAmt2 = " .. RewAmt2);
		 -- dft_debug("Reward RewAmt2 Currency Type " .. GetAddCurrencyRewardInfo(RewID2));

		 -- dft_debug("Currency type for reward #2: " .. ZO_Currency_FormatPlatform(GetAddCurrencyRewardInfo(RewID2), RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) );
		 -- dft_debug("---- End\n");

		-- Optionally, flag the "best" endeavour if one (and only one) is better than the rest
		local BestDFlag="";
		local BestWFlag="";
		if ( index == BestDailyIndex ) then BestDFlag=" (|c00FF00* Best daily *|r)"; end
		if ( index == BestWeeklyIndex ) then BestWFlag=" (|c00FF00* Best Weekly *|r)"; end

		-- Attempt to show the reward amount.  Not sure if this is gonna work or not.
		-- Also, I seem to be hard coding some values here on RewID & RewID2.  I can't recall why.  Probably not needed.  
		-- Will clean that up Real Soon Now (tm)
		-- Also, this code assumes (safely, currently), that the first reward are seals and the second (RewID2) won't be
		local RewardInfo="";
		if ( ( RewID == 2873 ) and ( RewAmt > 0 ) ) then -- Handle SEALS
			 -- RewardInfo =" " .. RewAmt .. " seals";
			RewardInfo ="" .. ZO_Currency_FormatPlatform(CURT_ENDEAVOR_SEALS, RewAmt, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. "|r |c" .. TextColor .. " seals"   
		end

		-- If there is a second entry for rewards (Should I code for a third value?  Nah.... that's what updates are for....)
		if ( ( RewID2 == 2818 ) and ( RewAmt2 > 0 ) ) then -- Handle XP
			-- RewardInfo =" (" .. RewAmt2 .. ") XP";
			-- RewardInfo = RewardInfo .. " + " .. RewAmt2 .. " XP ";
			-- RewardInfo ="" .. ZO_Currency_FormatPlatform(CURT_NONE, RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " XP Points"  
			-- RewardInfo = RewardInfo .. " + " .. RewAmt2 .. "|t24:24:/esoui/art/loot/loot_xp.dds|t XP ";
			RewardInfo = RewardInfo .. ",  " .. RewAmt2 .. " |cFFFF00 XP |r" 
		end
		-- RewardInfo = RewardInfo .. " |r";
		--
		-- If there is a second entry for rewards (UNdaunted keys)
		if ( ( RewID2 == 2849 ) and ( RewAmt2 > 0 ) ) then -- Handle Undaunted keys
			-- RewardInfo =" (" .. RewAmt2 .. ") XP";
			-- RewardInfo = RewardInfo .. " + " .. RewAmt2 .. " XP ";
			-- RewardInfo ="" .. ZO_Currency_FormatPlatform(CURT_NONE, RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " XP Points"  
			-- RewardInfo = RewardInfo .. " + " .. RewAmt2 .. "|t24:24:/esoui/art/loot/loot_xp.dds|t XP ";
			-- RewardInfo = RewardInfo .. " + " .. RewAmt2 .. ZO_Currency_FormatPlatform(CURT_UNDAUNTED_KEYS, RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " "  
			RewardInfo = RewardInfo .. ",  " .. ZO_Currency_FormatPlatform(CURT_UNDAUNTED_KEYS, RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " |cCCCCCC Undaunted key(s)|r"  
		end
		-- RewardInfo = RewardInfo .. " |r";

		if ((  RewID2 == 2808 ) and ( RewAmt2 > 0 ) ) then -- Handle GOLD
			-- RewardInfo =" (" .. RewAmt .. ") Gold |t16:16:EsoUI/Art/currency/currency_gold.dds|t" 
			RewardInfo = RewardInfo .. ",  " .. ZO_Currency_FormatPlatform(CURT_MONEY, RewAmt2, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " gold"  
		end

		if ((  RewID == 0000 ) and ( RewAmt > 0 ) ) then
			-- RewardInfo =" (" .. RewAmt .. ") Gold |t16:16:EsoUI/Art/currency/currency_gold.dds|t" 
			RewardInfo ="" .. ZO_Currency_FormatPlatform(CURT_MONEY, RewAmt, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. " gold"  
		end
		local EType="D" -- May be reset below
		if (GetTimedActivityType(index) == 1 ) then
			AWeeklyNumber = index; -- We just need some Weekly number for the index for the timing question below
			EType="W"
		else
			ADailyNumber = index; -- We just need some daily number for the index for the timing question below
		end

		-- Build a return string suitable for an abbreviated onscreen update of active or binary endeavours
		-- In this case if we (1) have started it (EA_SoFar > 0), we haven't finished it (EA_SoFar = EA_Max) 
		-- or it is just a 1-step endeavour (EA_Max == 1) then add it to the screen's string to show

		-- dft_debug("index=" .. index .. ", Etype = " .. EType .. ", EA_Sofar=" .. EA_SoFar .. ", EA_Max=" .. EA_Max .. ", RewardAmt = " .. RewAmt ..", ReqID=" .. RewID .. ", DTAF4(" .. index .. ") = " ..GetTimedActivityDifficulty(index));
		if ((( EA_SoFar > 0 ) or ( EA_Max == 1 ) or (GetTimedActivityDifficulty(index) < 40)) and ( EA_SoFar ~= EA_Max) ) then -- We have activity or we have a 1-off

			if ( 
				( ( DoneWeeklies == 0 ) and ( EType == "W" ) ) 
			or 
				( ( DoneDailies ~= 3 ) and ( EType == "D" ) )

		 	) then

				-- Retval_Screen= Retval_Screen .. zo_strformat("|cFFFFFFET-Endeavor #" .. index .. " [" .. EType .."]:|r |c" .. TextColor .. " (" .. EA_SoFar .. " / " .. EA_Max .. "):" ..  GetTimedActivityName(index)  .. " |r\n" )
				if ( EType == "W") then
					-- Retval_ScreenW= Retval_ScreenW .. zo_strformat("|cFFFFFF" .. GetTimedActivityName(index)  .. " (" .. EType .."):|r |c" .. TextColor .. "(" .. EA_SoFar .. " / " .. EA_Max .. ")|r\n" )
					Retval_ScreenW= Retval_ScreenW .. zo_strformat(" |c" .. TextColor .. EType .. " - " .. GetTimedActivityName(index)  .. " (" .. RewardInfo .."): (" .. EA_SoFar .. " / " .. EA_Max .. ")|r " .. BestWFlag .. "\n" )
				else 
					-- Retval_ScreenD= Retval_ScreenD .. zo_strformat("|cFFFFFF" .. GetTimedActivityName(index)  .. " (" .. EType .."):|r |c" .. TextColor .. "(" .. EA_SoFar .. " / " .. EA_Max .. ")|r\n" )
					Retval_ScreenD= Retval_ScreenD .. zo_strformat(" |c" .. TextColor .. EType .. " - " .. GetTimedActivityName(index)  .. " (" .. RewardInfo .."): (" .. EA_SoFar .. " / " .. EA_Max .. ")|r " .. BestDFlag .. "\n" )
				end
		
			end
		end


		-- Post-loop, check to see if we need to warn about an impending dailiy timeout

		
		-- As the functionality has expanded, this variable name should have been revised from
		-- daily to being something more like "RemainingTimeForEndeavors" but... here we are.
		local DailyTimeWarning="";

		-- At some point, maybe we will make the # of hours remaining a configurable variable
		-- (or better, one or daily and one for weekly)  but then again, I may be over thinking
		-- the actual popularity / usefulness of this so... for now.... I will compromise with
		-- myself nd just make it a single, settable variable (side note: what variable isn't?)
		local EndeavorWarningThreshhold=3;
		if ( type(FarmersToolkit.EndeavorWarningThreshhold) ~= nil ) then
			EndeavorWarningThreshhold=FarmersToolkit.EndeavorWarningThreshhold;
		end

		local TimeLeftInDaily =   GetTimedActivityTimeRemainingSeconds( ADailyNumber) / (60*60);
		local TimeLeftInWeekly =   GetTimedActivityTimeRemainingSeconds( AWeeklyNumber) / (60*60);

		-- dft_debug("FTK:DP(EndeavorStats) Time left in daily (in hours) = [" ..  TimeLeftInDaily .. "]");
		-- dft_debug("FTK:DP(EndeavorStats) Time left in weekly (in hours) = [" ..  TimeLeftInWeekly .. "]");

		local DailyHours = 0;
		local DailyMins = 0;

		local WeeklyHours = 0;
		local WeeklyMins = 0;
		-- Only warn for dailies if we're within 3 hours (I should make this configurable) and we haven't finished our 3 dailies
		if ( ( DoneDailies < 3 ) and ( TimeLeftInDaily < EndeavorWarningThreshhold ) ) then -- < 3 hours and not done (i.e., DoneDailies < 3)
			DailyHours=math.floor(TimeLeftInDaily);
			DailyMins=math.floor((TimeLeftInDaily-DailyHours)*60);
			DailyTimeWarning =   string.format("%s:%02d hours(s) left in daily endeavors", DailyHours, DailyMins)
		end

		-- Only warn for weeklies if we're within 3 hours (I should make this configurable) and we haven't finished our 1 weekly endeavor
		if ( ( DoneWeeklies < 2 ) and ( TimeLeftInWeekly < EndeavorWarningThreshhold ) ) then -- < thresshold hours and not done (i.e., DoneWeeklies <  1)
			WeeklyHours=math.floor(TimeLeftInWeekly);
			WeeklyMins=math.floor((TimeLeftInWeekly-WeeklyHours)*60);
			if ( DailyTimeWarning == "" ) then
				DailyTimeWarning =   string.format("%s:%02d hours(s) left in weekly endeavors", WeeklyHours, WeeklyMins)
			else
				DailyTimeWarning =   DailyTimeWarning .. string.format(", %s:%02d hours(s) left in weekly endeavors", WeeklyHours, WeeklyMins)
			end
		end
		-- dft_debug("FTK:DP(EndeavorStats) Time left in daily (Hrs/Min) = [" ..  DailyHours .. ":" .. DailyMins  .. "]");
		-- dft_debug("FTK:DP(EndeavorStats) Time left in weekly (Hrs/Min) = [" ..  WeeklyHours .. ":" .. WeeklyMins  .. "]");
		--
	
		if ( DailyTimeWarning ~= "" ) then -- Just looks better in yellow for some reason
			DailyTimeWarning = "|cFFFF00" .. DailyTimeWarning .. "|r ";
		end

		-- Adjust to handle screen vs screenterse
		Retval_Screen =" |c1EDDFFRecommended endeavors: " .. DailyTimeWarning .. "\r\n" -- Return a string suitable for on-screen status
		if FarmersToolkit.IVShrink and ( ( FarmersToolkit.IVShrink == 3 ) or ( FarmersToolkit.IVShrink == 2 ) ) then -- if we are in compressed presentation mode
			Retval_Screen =" |c1EDDFFActive endeavors: " .. DailyTimeWarning .. "|r\r\n" -- Return a string suitable for on-screen status
		end

		-- Report results to chat
		Retval_Chat=Retval_Chat .. zo_strformat("FT-Endeavor #" .. index .. " [" .. EType .."/" .. GetTimedActivityDifficulty(index) .."/".. RewardInfo .. "]: (" .. EA_SoFar .. " / " .. EA_Max .. "): |c" .. TextColor ..  GetTimedActivityName(index)  .. " |r " .. BestDFlag .. "\n" )
		
		-- Build Terse line as needed
		if (EType == "D") and ( EA_SoFar > 0 ) and ( EA_SoFar < EA_Max) and ( DoneDailies < 3) then
			-- Retval_ScreenT=Retval_ScreenT .. zo_strformat(" ++ D#" .. index .. " [" .. EType .."/" .. GetTimedActivityDifficulty(index) .."/".. RewardInfo .. "]: (" .. EA_SoFar .. " / " .. EA_Max .. "): |c" .. TextColor ..  GetTimedActivityName(index)  .. " |r\n" )
			Retval_ScreenT=Retval_ScreenT .. zo_strformat(" ++ D#" .. index .. ": |c" .. TextColor .. EA_SoFar .. " / " .. EA_Max .. " -- " ..  GetTimedActivityName(index)  .. " |r\n" .. BestDFlag )
		end


		if (EType == "W") and ( EA_SoFar > 0 ) and ( EA_SoFar < EA_Max) and ( DoneWeeklies < 1 ) then
			-- Retval_ScreenT=Retval_ScreenT .. zo_strformat(" ++ W#" .. index .. " [" .. EType .."/" .. GetTimedActivityDifficulty(index) .."/".. RewardInfo .. "]: (" .. EA_SoFar .. " / " .. EA_Max .. "): |c" .. TextColor ..  GetTimedActivityName(index)  .. " |r\n" )
			-- Retval_ScreenT=Retval_ScreenT .. zo_strformat(" ++ W#" .. index .. " [" .. EType .."/" .. GetTimedActivityDifficulty(index) .."/".. RewardInfo .. "]: (" .. EA_SoFar .. " / " .. EA_Max .. "): |c" .. TextColor ..  GetTimedActivityName(index)  .. " |r\n" )
			Retval_ScreenT=Retval_ScreenT .. zo_strformat(" ++ W#" .. index .. ": |c" .. TextColor .. EA_SoFar .. " / " .. EA_Max .. " -- " ..  GetTimedActivityName(index)  .. " |r\n"  .. BestWFlag)
		end

	end -- do loop

	if ( retType == "Screen") then
		if ( (DoneDailies < 3 ) or ( DoneWeeklies < 1 ) ) then
			-- return  Retval_Screen .. Retval_ScreenD .. Retval_ScreenW .. Retval_ScreenT
			return  Retval_Screen .. Retval_ScreenD .. Retval_ScreenW 
		else
			return ""; -- Return nothing since everything is done
		end
	end

	if ( retType == "ScreenTerse") then
		if ( (DoneDailies < 3 ) or ( DoneWeeklies < 1 ) ) then
			-- return  Retval_Screen .. Retval_ScreenD .. Retval_ScreenW .. Retval_ScreenT
			return  Retval_Screen .. Retval_ScreenT
		else
			return "All endeavors complete." -- Return this since everything is done
		end
	end

	-- Otherwise
		return Retval_Chat 
	
end

-- Update the daily gift and then the screen
-- NOTE: DO NOT CALL THIS DIRECTLY, it should ONLY be called from the event that indicates the daily gift has been received
function FarmersToolkit.UpdateDailyGift()

	local DGS_DOM = os.date("%d"); -- Get the day of the month
	FarmersToolkit.savedVariablesAcct.LastDailyDate = DGS_DOM; -- Save it out

	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
        -- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
        if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
       	FarmersToolkit.UpdateFarmlist()
end

-- I hate this solution.  But I don't see a GetDailyGiftStatus command anywhere so...
function FarmersToolkit.CheckDailyGift()

	local checkDG=FarmersToolkit.savedVariablesAcct.LastDailyDate;
	if (checkDG==nil) then return 99; end

	local TodaysDOM= os.date("%d"); -- Get the day of the month

	if (TodaysDOM == checkDG ) then 	
		-- d("FT-DEBUG(CDG): Return one b/c the dates matched.")
		return 1 
	else 
		-- d("FT-DEBUG(CDG): Returning 0 because the dates did NOT match.")
		return 0 
	end
end

-- Update the screen
function FarmersToolkit.UpdateDailies()
	
	local retval=""

   -- Specific code in light of EOS's shift away from endeavors
   if ( FarmersToolkit.SE_Flag ) then
     -- local retval="Endeavors removed 3/1/26";
     return retval
   end
	-- Tons of local variables here, remnants of trying to solve the
	-- "Did I get the daily gift" without relying on a "saved yesterday" variable
	-- This is still an (annoyiong) active work in progress because I haven't
	-- figured out how to detect/determine daily gift status.  Yet.
	--

	local DGS_Available 
	local DGS_Done 
	local DGS_Time 
 	local DGS_DOM 
	local DGS_ToGo 
	local DGDetail
	local DailyClaimed
	local DailyClaimedColor
	local LastDOM
	local Dcolor
	local Wcolor
	local Tcolor
	local TimeLeftInDaily=0

	-- local dailiesCompleted = FarmersToolkit.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_DAILY)
  	-- local weekliesCompleted = FarmersToolkit.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)

        local dailiesCompleted = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_DAILY)
	local dailieslimit = GetTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_DAILY)


	local weekliesCompleted = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
	local weeklieslimit = GetTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_WEEKLY)

	if ( dailiesCompleted == dailieslimit ) then Dcolor="|c00FF00|" end
	if ( dailiesCompleted < dailieslimit ) then Dcolor="|cfce938|" end
	if ( dailiesCompleted == 0 ) then Dcolor="|cDCDCDC|" end

	if ( weekliesCompleted == weeklieslimit ) then Wcolor="|c00FF00|" end
	if ( weekliesCompleted < weeklieslimit ) then Wcolor="|cfce938|" end
	if ( weekliesCompleted == 0 ) then Wcolor="|cDCDCDC|" end

	DGS_Available =   GetNumRewardsInCurrentDailyLoginMonth() ;
	DGS_Done =  GetDailyLoginNumRewardsClaimedInMonth() ;
	DGS_ToGo = DGS_Available - DGS_Done;
	DGS_Time = string.format("%.2f", GetTimeUntilNextDailyLoginRewardClaimS() / (60*60));

 	DGS_DOM = os.date("%d");

	DGS_ToGo = DGS_Available - DGS_DOM;  -- Number of days claimed based on today's date


	-- Attempt to account for missing days

	DailyClaimed = "??"
	DailyClaimedColor = "CCCCCC"

        -- Really annoying error message when first starting up that has no consequence or purpose in life other than to peeve me off	
	-- if type(FarmersToolkit.savedVariablesAcct.LastDailyDate) ~= "nil" then LastDOM=FarmersToolkit.savedVariablesAcct.LastDailyDate; end
	-- if type(FarmersToolkit.savedVariablesAcct) ~= "nil" then LastDOM=FarmersToolkit.savedVariablesAcct.LastDailyDate; end
	if FarmersToolkit.savedVariablesAcct then LastDOM=FarmersToolkit.savedVariablesAcct.LastDailyDate; end

	DGDetail="";

	if (LastDOM == nil) then 
		DailyClaimed = "FF2222" 
		LastDOM=0;
	end
	if (LastDOM == DGS_DOM ) then 
		DailyClaimedColor = "00FF00" 
		DailyClaimed="Y";
	end
	if (LastDOM ~= DGS_DOM ) then 
		DailyClaimedColor = "FF2222" 
		DailyClaimed="N"
		DGDetail = " [ " .. DGS_Done .. " down, " .. DGS_ToGo .." to go (" .. DGS_DOM .. " / " .. DGS_Available .."), next up: " .. DGS_Time  .. " hours ] |r" ; 
	end

	-- Getting picky now...
	if ( ( dailiesCompleted == dailieslimit) and ( weekliesCompleted == weeklieslimit ) and ( LastDOM == DGS_DOM) ) then
		Tcolor = "00FF00";
	else 
		Tcolor = "FFFF00";
	end

	local extrainfo="";
	local curlevel= GetUnitLevel("player") ;
	local level_progress = 0;
	if ( curlevel < 50 ) then
		level_progress = string.format("%.2f%% ", ((GetUnitXP("player") / GetUnitXPMax("player")) * 100)) 
		-- dft("Level = " .. level_progress)
		extrainfo = extrainfo ..  "       |cFFFF00Level " .. curlevel .. " progress: " .. level_progress  .. "|r"
		-- dft_debug("Set extrainfo = [" .. extrainfo .. "]")
	end
        retval= ("|c" .. Tcolor .. "xEndeavors / Gifts:|r " .. Dcolor .. " DE:" .. dailiesCompleted .. "|r, " .. Wcolor .. " WE: " .. weekliesCompleted  .. "|r , |c" .. DailyClaimedColor .." DG:" .. DailyClaimed .. "|r " .. DGDetail .. extrainfo)

	return retval

end
-- end of function FarmersToolkit.UpdateDailies()

function FarmersToolkit.DailyGifts(cmd)

	-- These are similar to the local vars list from UpdateDailies
	-- This logic should be solved, cleaned, and moved to a common function.

	local DGS_Available 
	local DGS_Done 
	local DGS_ToGo 
	local DGS_Time 
 	local DGS_DOM 

	-- local dailiesCompleted = FarmersToolkit.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_DAILY)

	DGS_Available =   GetNumRewardsInCurrentDailyLoginMonth() ;
	DGS_Done =  GetDailyLoginNumRewardsClaimedInMonth() ;
	DGS_Time = string.format("%.2f", GetTimeUntilNextDailyLoginRewardClaimS() / (60*60));

 	DGS_DOM = os.date("%d");

	DGS_ToGo = DGS_Available - DGS_DOM;

   if (cmd == "show" ) then

	dft("Daily Gift Variable(s):")

	-- DGS variable cleanup is underway.  Once complete, this can probably be removed
	-- or switched to use dft_debug altho this is cleaner/faster and avoids dft_debug overhead (even when off)
	if ( FarmersToolkit.FT_DBFLAG == 1 ) then
		dft("-- FT-DEBUG (DG):")
		dft("-- In-Development Debugging Variables")
		dft("   -- DGS_Available (called): " .. DGS_Available )
		dft("   -- DGS_Done (called): " .. DGS_Done )
		dft("   -- DGS_DOM (called): " .. DGS_DOM )
		dft("   -- DGS_ToGo (Avail - DOM): " .. DGS_ToGo )
	end

	if ( FarmersToolkit.savedVariablesAcct.LastDailyDate == nil ) then
		dft("   -- Last Daily Date has not been defined / saved.")
	else 
		dft("   -- Last Daily Date (saved): " .. FarmersToolkit.savedVariablesAcct.LastDailyDate)
	end
	
   end -- end if cmd=show

end -- end function FarmersToolkit.DailyGifts(cmd)


-- Display stats on farmed items.  This has no actual use or valdity but seemed like a good idea at the time.
function FarmersToolkit.FarmingStats(astring)
 
   if ( astring == nil) then astring = "" end
   -- -- dft("FT-FS1: Top of Farming Stats (" .. astring ..")")
 
	local UniqueStat=" ";
	if ( FarmersToolkit.tvalue > 0 ) then UniqueStat= " (" .. string.format("%.3f", (FarmersToolkit.UniqueItems / FarmersToolkit.tvalue) * 100) .. "%)" end

	local ReplenishedStat=" ";
	if ( FarmersToolkit.tvalue > 0 ) then ReplenishedStat= " (" .. string.format("%.3f", (FarmersToolkit.ReplenishedItems / FarmersToolkit.tvalue) * 100) .. "%)" end

	local ChestStat=" ";
	if ( FarmersToolkit.tvalue > 0 ) then ChestStat= " (" .. string.format("%.3f", (FarmersToolkit.Lootable["Chest"] / FarmersToolkit.tvalue) * 100) .. "%)" end

	d("\n")
	d("FT: Farming Statistics (Overview)")
	d("=================================")
	d(" ")
	d("   --- General numbers ---")
	d("       Items farmed: " .. comma_value(FarmersToolkit.tvalue));
        d("       Unique types farmed: " .. comma_value(FarmersToolkit.UniqueItems));
	d("       Total Chests farmed: " .. comma_value(FarmersToolkit.Lootable["Chest"])  .. ChestStat)
	d("       Total Restocked Items: " .. comma_value(FarmersToolkit.ReplenishedItems) .. ReplenishedStat)
	d("       Total Unique Items: " .. comma_value(FarmersToolkit.UniqueItems) .. UniqueStat)
	d("       Total Books read: " .. comma_value(FarmersToolkit.Lootable["Books"])  )

 	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)

    if ( astring == "detail") then

	d(" ")
	d("   --- Items by the numbers ---")

      local f2=FarmersToolkit.FarmList;
      for key, val in orderedPairs(FarmersToolkit.FarmNameByLinkID) do
        local val2=f2[val];
	local Scount = FarmersToolkit.SessionCount[val];
	local count = GetSlotStackSize(bagID, slotIndex)
	
	if ( Scount > 1 ) then -- We only want to run stats on things we have more than one of ... for breveity
		-- d("FT-DEBUG (Stats) key (name) =(" .. key ..") ");
		-- d("FT-DEBUG (Stats) val (linkID) = (" .. val ..") ");
		-- d("FT-DEBUG (Stats) val2 (string?) = (" .. val2 ..") ");
		-- d("FT-DEBUG (Stats) Scount (# this session) = (" .. Scount ..") ");

		-- d("FT-DEBUG 0 : arg1=(" .. arg1 .. ")    arg1 type: " .. type(arg1) .. "  key type: " .. type(key))
        	-- d("FT-DEBUG 1 key=(" .. key .."): val2=[" .. val2 .. "] val=[" .. val .."]");
		-- d("FT-DEBUG (Stats) 1 key=(" .. key .."): val2=[" .. val2 .. "] val=[" .. val .. "]");

		-- d("FT: -- " .. val2 .. " ( " .. string.format("%.3f", (Scount / FarmersToolkit.tvalue) * 100) .. "%)" );
		dft(" -- " .. val2 .. " ( " .. string.format("%.3f", (Scount / FarmersToolkit.tvalue) * 100) .. "%)" );

	end -- If Scount > 1

      end -- for loop

    end -- if detailed requested


end -- end of Farming Stats function

-- function FarmersToolkit.UpdateXPTracker(arg_unit, arg_CXP, arg_MaxXP, arg_reason, arg5)
function FarmersToolkit.UpdateXPTracker(eventCode, unitTag, currentExp, maxExp, reason) 

-- dft_debug("UXPT Top(" .. math.random(100,999) .. "/" .. os.time() .. ")> ec=[" .. eventCode .. "] unit=[" .. unitTag .. "] CXP=[" .. currentExp .. "] MXP=[" .. maxExp .. " reason=[" .. reason .. "]");


	-- EVENT will fire twice if in a group, unitTag tells whether it is GroupX or player.
	-- We only want player-specific event data (otherwise things appear to get run twice)
	-- Also, reason= -1 entries tend to be redundant (there are separate EVENT calls that are more appropos)
	if unitTag ~= "player"  or reason == -1 then 
        	-- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
                if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
		return 
	end

	-- dft_debug("Top of UXPT, passed the reason check but reason = " .. reason .. " (of type " .. type(reason) .. ")")
	-- Similarly, we wony want to report data for players under level 50
	local curlevel= GetUnitLevel("player") ;
	if curlevel > 49 then return end

	-- Debug code, commented out for efficiency but left in for prudence
	-- dft_debug("XPTracker called");
	-- dft_debug("   -  eventCode = [" .. eventCode .. "]")
	-- dft_debug("   -    unitTag = [" .. unitTag .. "]")
	-- dft_debug("   - currentExp = [" .. currentExp .. "]")
	-- dft_debug("   -     maxExp = [" .. maxExp .. "]")
	-- dft_debug("   -     reason = [" .. reason .. "]")


	local msg="You earned XP for that!";

	local earnedXP=0;
	local skipflag=0;
	if (FarmersToolkit.CurrentXP) then

                earnedXP= currentExp - FarmersToolkit.CurrentXP;

		if earnedXP > 0 then
		 	msg="Earned  " ..  earnedXP .. " XP. "
		end
	end

-- dft_debug("UXPT Mid-1 (" .. math.random(100,999) .. "/" .. os.time() .. ")> earnedXP=[" .. earnedXP .. "] msg=[" .. msg .. "] ");

	if ( reason > 0 ) and FarmersToolkit.XP_Reason[reason] then -- There is a chance for a 0 or -1 return value case of "no info" 
								    -- And there appear to be new numebrs (25+) that are not documented.... 
								    -- so, handle / check for blanks
		-- dft("reason(text) = [" .. FarmersToolkit.XP_Reason[reason] .. "]")
		msg = msg .. " [" .. FarmersToolkit.XP_Reason[reason] .. "]"
	else 
		msg = msg .. " [ Reason: " .. reason .. " ]"
	end

	if (FarmersToolkit.CurrentXP) then
		local yy = math.floor((maxExp - FarmersToolkit.CurrentXP) / ( currentExp - FarmersToolkit.CurrentXP))
		-- dft("You got XP!  Do that " ..  yy .. " more time(s) to get to the next level!")
		if ( yy < 0 ) then -- they just leveled
			msg = msg .. " You leveled up, congrats!"
		elseif yy == 0 and skipflag == 0 then
			msg = msg .. " Do that again and you will level up!"
		elseif yy > 0 and skipflag == 0 then
			msg = msg .. " Do that " ..  yy .. " more time(s) to level up."
		end
-- dft_debug("UXPT Mid-2 (" .. math.random(100,999) .. "/" .. os.time() .. ")> yy=[" .. yy .. "] msg=[" .. msg .. "] ");
	end


	-- Alternate way to detect leveling (not sure this works 100% of the time)
-- def_debug("CPX= " .. currentExp .. " vs MaxExp = " .. maxExp);
	if ( currentExp > maxExp ) then -- we have leveled?
			msg = " You leveled up, congrats!"
	end






	local level_progress = string.format("%.2f%% ", ((GetUnitXP("player") /                                  GetUnitXPMax("player")) * 100)) 
	-- dft("You just gained XP!  Current value is: " ..  GetUnitXP("player")  .. "  and reported max XP is " .. GetUnitXPMax("player") .. " resulting in a percentage : " .. level_progress)
	msg = msg .. " ( You are " .. level_progress .. " through level " .. curlevel .." )"

	if ( msg ~= "" ) then dft("|r|cFFA500 XP Tracker:|r " .. msg ) end
	-- dft(msg)


	FarmersToolkit.CurrentXP=currentExp;


	-- Update the screen
        -- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
        if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end

end -- end of FarmersToolkit.XPTracker

-- Poorly named function, it actually updates the inventory slots reported on screen / in chat
-- It doesn't touch inventory so much as compare open slots to Warning and Panic levels
-- and color code on-screen messages accordingly.
function FarmersToolkit.UpdateInventory()
	
	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	local retval=""
	local StolenCount=0;
	local StolenCount2=0;
	local CpCount=0;
	local CpCount2=0;
	local MpCount=0;		-- Museum count
	local MpCount2=0;
	local FnCount=0;		-- Furniture Count
	local FnCount2=0;
	local TreashCount=0;		-- Trash and treasures
	local TreashCount2=0;
	local ContainerCount=0;
	local ContainerCount2=0;

	local PCount=0;			-- Paperwork count
	local PCount2=0;

	local RCount=0;			-- Recipe count
	local RCount2=0;

	local ScCount=0;			-- Script count
	local ScCount2=0;

	local MapCount=0;		-- Map count
	local MapCount2=0;

	local BDecay=0;
	local BountyCount="";

	if ( FarmersToolkit.SE_Flag ) then
        	local dailiesCompleted = 0
        	local weekliesCompleted = 0
	else
		local weekliesCompleted = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
		local weekliesCompleted = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
	end


	-- If not green, add a string in to show current bag slot limits
	local BagStatus=""; -- Assume everything is fine
	if ( (maxSlots - usedSlots) < FarmersToolkit.BagWarnLevel ) then BagStatus=" [W@ " .. FarmersToolkit.BagWarnLevel .. "]"; end
	if ( (maxSlots - usedSlots) < FarmersToolkit.BagPanicLevel ) then BagStatus=" [P@ " .. FarmersToolkit.BagPanicLevel .. "]"; end

	-- Check for / report stolen items (SCount) treasure/trash items (TCount, combined), Compaion Items (CompCount), Containers (ContCount)
	--- return from LootCount, TreasureCount, CompanionItemCount, ContainerCount, MuseumCount, FurnCount, PaperCount, MapCount
	local SCount, TCount, CompCount, ContCount, MCount, FCount, PaperCount, MapCountNum, RecipeCount, ScriptCount = FarmersToolkit.CountOtherItems()

	-- dft_debug("FTK:COI returned S: " .. SCount .. ", T= " .. TCount .. ", Cp= " .. CompCount);
	 -- dft_debug("FTK:COI returned F: " .. FCount .. ", M= " .. MCount .. ", Cp= " .. CompCount, ", R=" .. RCount);
	  -- dft("FTK:COI returned F: " .. FCount .. ", M= " .. MCount .. ", Cp= " .. CompCount, ", R=" .. RCount .. ", S=" .. ScriptCount);

	-- Handle Stolen item reporting
	if ( SCount > 0 ) then
		StolenCount = ", |cFF0000Stolen: " .. SCount .. "|r";
		StolenCount2 = ", |cFF0000S: " .. SCount .. "|r";
	else 
		StolenCount = ""
		StolenCount2 = ""
	end


	-- Handle Treasures item reporting
	if ( TCount > 0 ) then
		TreashCount = ", |cFA9C1BTrashure: " .. TCount .. "|r";
		TreashCount2 = ", |cFA9C1BT: " .. TCount .. "|r";
	else 
		TreashCount = ""
		TreashCount2 = ""
	end

	-- Handle Treasures item reporting
	-- Probably need a different / better color here, stealing from treasure for now
 	if ( CompCount > 0 ) then
		CpCount = ", |cFA9C1BCompGear: " .. CompCount .. "|r";
		CpCount2 = ", |cFA9C1BCp: " .. CompCount .. "|r";
	else 
		CpCount = ""
		CpCount2 = ""
	end

	-- Handle MuseumPieces item reporting
	-- Probably need a different / better color here, stealing from treasure for now
 	if ( MCount > 0 ) then
		-- MpCount = ", |cFA9C1BMuseum: " .. MCount .. "|r";
		-- MpCount2 = ", |cFA9C1BMp: " .. MCount .. "|r";
		MpCount = ", |cFFFF00Museum: " .. MCount .. "|r";
		MpCount2 = ", |cFFFF00Mp: " .. MCount .. "|r";
	else 
		MpCount = ""
		MpCount2 = ""
	end

	-- Handle FurnPieces item reporting
	-- Probably need a different / better color here, stealing from treasure for now
 	if ( FCount > 0 ) then
		-- MpCount = ", |cFA9C1BMuseum: " .. FCount .. "|r";
		-- MpCount2 = ", |cFA9C1BMp: " .. FCount .. "|r";
		FnCount = ", |cFFFF00Furn: " .. FCount .. "|r";
		FnCount2 = ", |cFFFF00F: " .. FCount .. "|r";
	else 
		FnCount = ""
		FnCount2 = ""
	end

	-- Handle Containers item reporting
	-- Probably need a different / better color here, stealing from treasure for now
 	if ( ContCount > 0 ) then
		ContainerCount = ", |c7fffd4Containers: " .. ContCount .. "|r";
		ContainerCount2 = ", |c7fffd4Cn: " .. ContCount .. "|r";
	else 
		ContainerCount = ""
		ContainerCount2 = ""
	end


	-- Handle MapCount item reporting
 	if ( MapCountNum > 0 ) then
		MapCount = ", |c00ff00Maps: " .. MapCountNum .. "|r";
		MapCount2 = ", |c00ff00Map: " .. MapCountNum .. "|r";
	else 
		MapCount = ""
		MapCount2 = ""
	end

	-- Handle paperwork item reporting
 	if ( PaperCount > 0 ) then
		PCount = ", |c00ff00Paperwork: " .. PaperCount .. "|r";
		PCount2 = ", |c00ff00Pw: " .. PaperCount .. "|r";
	else 
		PCount = ""
		PCount2 = ""
	end

	-- Handle recipe item reporting
 	if ( RecipeCount > 0 ) then
		RCount = ", |c00ff00Recipes: " .. RecipeCount .. "|r";
		RCount2 = ", |c00ff00R: " .. RecipeCount .. "|r";
	else 
		RCount = ""
		RCount2 = ""
	end

	-- Handle script item reporting
 	if ( ScriptCount > 0 ) then
		ScCount = ", |c00ff00Scripts: " .. ScriptCount .. "|r";
		ScCount2 = ", |c00ff00Sc: " .. ScriptCount .. "|r";
	else 
		ScCount = ""
		ScCount2 = ""
	end


	-- Here's some ugly logic.  If the user requested to NOT show these details, despite having laboriously calculated and created them above....yeah.
	if ( FarmersToolkit.InvDetails == false ) then
		-- This essentially supresses reporting of slots usage for companion gear, museum pieces, furniture, trash/treasure, stolen items, paper items and maps/surveys
		CpCount=""; MpCount=""; FnCount=""; TreashCount=""; ContainerCount=""; StolenCount = ""; PCount=""; MapCount=""; RCount="";
		CpCount2=""; MpCount2=""; FnCount2=""; TreashCount2=""; ContainerCount2=""; StolenCount2=""; PCount2=""; MapCount2=""; RCount2="";ScCount="";

		
	end




        -- Add in extra lines outside of ()s if there is a bounty
	local BUnits = "minutes";
        if (GetFullBountyPayoffAmount()>0) then
                local BDecay = string.format("%.1f", GetSecondsUntilBountyDecaysToZero() / 60);
		if ( ( GetSecondsUntilBountyDecaysToZero() / 60)  > 120 ) then
                	BDecay = string.format("%.1f", GetSecondsUntilBountyDecaysToZero() / (60*60));
			BUnits = "hours (seriously?!)";
		end

                BountyCount = "\n|cFF5B00BOUNTY: " .. GetFullBountyPayoffAmount() .. "|r  (" .. BDecay .. " " .. BUnits .. " to go)";
		-- dft_debug("FT:Debug(Bounty): Bounty Count = [ " .. BountyCount .. "]")
        else
                BountyCount=""
        end

	if ( FarmersToolkit.IVShrink == 2 ) then
		retval=retval .. ("Farming Summary: (" .. (maxSlots - usedSlots) .. " / " .. maxSlots .. BagStatus .. " ) -- Tot: " .. comma_value(FarmersToolkit.tvalue) .. " (U: " .. comma_value(FarmersToolkit.UniqueItems) .. ", R: " .. comma_value(FarmersToolkit.ReplenishedItems) .. ", C: " .. comma_value(FarmersToolkit.Lootable["Chest"]) .. ", B: " .. comma_value(FarmersToolkit.Lootable["Books"]) .. ")\n" .. CpCount2 .. MpCount2 .. FnCount2 .. TreashCount2  .. ContainerCount2 .. StolenCount2 .. PCount2 .. MapCount2 .. RCount2 .. ScCount2 .. BountyCount )

	 	-- Clean up leading comma, if needed
		retval = string.gsub(retval, "\n,", "\n")
		retval = string.gsub(retval, "\n ,", "\n")
		
	elseif ( FarmersToolkit.IVShrink == 3 ) then
		retval=retval .. ("Farming Summary: (" .. (maxSlots - usedSlots) .. " / " .. maxSlots .. BagStatus .. " ) -- Tot: " .. comma_value(FarmersToolkit.tvalue) .. " (U: " .. comma_value(FarmersToolkit.UniqueItems) .. ", R: " .. comma_value(FarmersToolkit.ReplenishedItems) .. ", C: " .. comma_value(FarmersToolkit.Lootable["Chest"]) .. ", B: " .. comma_value(FarmersToolkit.Lootable["Books"]) .. ")\n" .. CpCount2 .. MpCount2 .. FnCount2 .. TreashCount2  .. ContainerCount2 .. StolenCount2 .. PCount2 .. MapCount2 .. RCount2 .. ScCount2 .. BountyCount )

		retval=retval .. "\n\n" .. FarmersToolkit.DailyProgress("ScreenTerse")

	 	-- Clean up leading comma, if needed
		retval = string.gsub(retval, "\n,", "\n")
		retval = string.gsub(retval, "\n ,", "\n")
		


	elseif ( FarmersToolkit.IVShrink == 4 ) then

		retval="Inventory details temporarily suppressed - click icon above to expand";

	else
		-- retval=retval .. ("Farming (Open: " .. (maxSlots - usedSlots) .. " / " .. maxSlots .. BagStatus .. " ):  Total: " .. comma_value(FarmersToolkit.tvalue) .. " (Unique: " .. comma_value(FarmersToolkit.UniqueItems) .. ", Restocked: " .. comma_value(FarmersToolkit.ReplenishedItems) .. ", Chests: " .. comma_value(FarmersToolkit.Lootable["Chest"]) .. ", Books: " .. comma_value(FarmersToolkit.Lootable["Books"]) .. ")\n"  )
		--
		
		retval=retval .. (" Farming (Open: " .. (maxSlots - usedSlots) .. " / " .. maxSlots .. BagStatus .. " ):  Total: " .. comma_value(FarmersToolkit.tvalue) .. " (Unique: " .. comma_value(FarmersToolkit.UniqueItems) .. ", Restocked: " .. comma_value(FarmersToolkit.ReplenishedItems) .. ", Chests: " .. comma_value(FarmersToolkit.Lootable["Chest"]) .. ", Books: " .. comma_value(FarmersToolkit.Lootable["Books"]) .. ")" )
		if ( ( CpCount .. MpCount .. FnCount .. TreashCount .. ContainerCount .. StolenCount .. MapCount .. PCount .. RCount ) ~= "" ) then
			retval=retval .. ("\n Also" .. CpCount .. MpCount .. FnCount .. TreashCount .. ContainerCount .. PCount .. MapCount .. RCount .. ScCount .. StolenCount )
		end
		retval = retval .. BountyCount;

		local tvar= FarmersToolkit.DailyProgress("Screen")
		if ( tvar ~= "" ) then
			retval=retval .. "\n\n" .. tvar
		end
	end

	return retval

end

-- The OnIndicatorMoveStop routiones are being replaced with a more robust solution
-- The older versions will be replaced in 2 revs.

function FarmersToolkit.OnIndicatorMoveStop()
    local sv = FarmersToolkit.savedVariables
    if not sv then return end

    local point, relTo, relPoint, offX, offY = FTAddonIndicator:GetAnchor(0)

    sv.anchorPoint = point
    sv.anchorRelPt = relPoint
    sv.anchorOffX  = offX
    sv.anchorOffY  = offY

    -- Keep old fields too (optional but safest during rollout)
    sv.left = FTAddonIndicator:GetLeft()
    sv.top  = FTAddonIndicator:GetTop()
end


function FarmersToolkit.OnIndicatorMoveStop2()
    local sv = FarmersToolkit.savedVariables
    if not sv then return end
    if not FTAddonIndicator2 then return end

    -- New, stable format: store anchor offsets + points
    local point, relTo, relPoint, offX, offY = FTAddonIndicator2:GetAnchor(0)

    sv.anchorPoint2 = point
    sv.anchorRelPt2 = relPoint
    sv.anchorOffX2  = offX
    sv.anchorOffY2  = offY

    -- Backward-compat fields (keep these during rollout)
    sv.left2 = FTAddonIndicator2:GetLeft()
    sv.top2  = FTAddonIndicator2:GetTop()
end


        		
function FarmersToolkit.FListConfigButton(arg1) 

	 -- dft("FTK.FLCB Called with ag1=[" .. arg1 .. "]");

	if ( arg1 == "FlistShrink") then
		local FLText="Minimized"; 
		if ( FarmersToolkit.FLShrink == nil ) then FarmersToolkit.FLShrink=2; end
		-- FarmersToolkit.FLShrink = math.abs( 1 - FarmersToolkit.FLShrink)
		FarmersToolkit.FLShrink = 1 + ( FarmersToolkit.FLShrink % 3)
		if (FarmersToolkit.FLShrink==2) then FLText="Regular"; elseif (FarmersToolkit.FLShrink==3) then FLText="Abbreviated"; end
		dft("Setting Farming List display to " .. FarmersToolkit.FLShrink .. " - " .. FLText);
		FarmersToolkit.savedVariables.FLShrink = FarmersToolkit.FLShrink;
		FarmersToolkit.UpdateFarmlist()
	end

	if ( arg1 == "FlistConfig") then
  		-- local panelName = "FarmersToolkitSettingsPanel" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!
  		local panelName = "FarmersToolkitOptions" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!
		-- dft_debug("Launching config panel for " .. panelName)
		dft("Opening config panel by request")
		-- FarmersToolkit.OpenSettingsPanel(panelName);
		FarmersToolkit.OpenSettingsPanel();
		-- FarmersToolkit.OpenSettingsPanel(FarmersToolkit.LAMpanel)
	end

	if ( arg1 == "InvShrink") then
		if ( FarmersToolkit.IVShrink == nil ) then FarmersToolkit.IVShrink=1; end
		FarmersToolkit.IVShrink = 1 + ( FarmersToolkit.IVShrink % 4)
		dft("Setting Inventory display to mode " .. FarmersToolkit.IVShrink);
       		FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
	end

	if ( arg1 == "InvConfig") then
  		-- local panelName = "FarmersToolkitSettingsPanel" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!
  		local panelName = "FarmersToolkitOptions" 
		-- dft_debug("Launching config panel for " .. panelName)
		dft("Opening config panel by request")
		-- FarmersToolkit.OpenSettingsPanel(panelName);
		FarmersToolkit.OpenSettingsPanel();
		-- FarmersToolkit.OpenSettingsPanel(FarmersToolkit.LAMpanel)
	end

end

-- Replaces current (previous) restore functions with guarded versions

local function IsNum(x) return type(x) == "number" end

function FarmersToolkit.RestorePosition()
    local sv = FarmersToolkit.savedVariables
    if not sv or not FTAddonIndicator then return end

    -- Prefer new format ONLY if all required fields are valid
    if IsNum(sv.anchorOffX) and IsNum(sv.anchorOffY)
       and IsNum(sv.anchorPoint) and IsNum(sv.anchorRelPt) then

        FTAddonIndicator:ClearAnchors()
        FTAddonIndicator:SetAnchor(sv.anchorPoint, GuiRoot, sv.anchorRelPt, sv.anchorOffX, sv.anchorOffY)
        return
    end

    -- Fallback: old format
    if IsNum(sv.left) and IsNum(sv.top) then
        FTAddonIndicator:ClearAnchors()
        FTAddonIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left, sv.top)

        -- Optional one-time migration to new format (safe values only)
        sv.anchorPoint = TOPLEFT
        sv.anchorRelPt = TOPLEFT
        sv.anchorOffX  = sv.left
        sv.anchorOffY  = sv.top
    end
end




function FarmersToolkit.RestorePosition2()
    local sv = FarmersToolkit.savedVariables
    if not sv or not FTAddonIndicator2 then return end

    if IsNum(sv.anchorOffX2) and IsNum(sv.anchorOffY2)
       and IsNum(sv.anchorPoint2) and IsNum(sv.anchorRelPt2) then

        FTAddonIndicator2:ClearAnchors()
        FTAddonIndicator2:SetAnchor(sv.anchorPoint2, GuiRoot, sv.anchorRelPt2, sv.anchorOffX2, sv.anchorOffY2)
        return
    end

    if IsNum(sv.left2) and IsNum(sv.top2) then
        FTAddonIndicator2:ClearAnchors()
        FTAddonIndicator2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left2, sv.top2)

        sv.anchorPoint2 = TOPLEFT
        sv.anchorRelPt2 = TOPLEFT
        sv.anchorOffX2  = sv.left2
        sv.anchorOffY2  = sv.top2
    end
end





function FarmersToolkit.SaveTargetlist()
   FarmersToolkit.savedVariables.TIDCount = FarmersToolkit.TIDCount;
   FarmersToolkit.savedVariables.TIDName = FarmersToolkit.TIDName;
   
   FarmersToolkit.savedVariables.TargetTypeCount = FarmersToolkit.TargetTypeCount;
end -- FarmersToolkit.SaveTargetlist


function FarmersToolkit.LoadTargetlist()

   FarmersToolkit.TIDCount = FarmersToolkit.savedVariables.TIDCount;
   FarmersToolkit.TargetTypeCount = FarmersToolkit.savedVariables.TargetTypeCount ;
	-- Handle first-time-ever (or corruped SV file) instances
	if ( type(FarmersToolkit.TargetTypeCount) == "nil" ) then FarmersToolkit.TargetTypeCount = {} end

   FarmersToolkit.TIDName = FarmersToolkit.savedVariables.TIDName ;
	-- Handle first-time-ever (or corruped SV file) instances
	if ( type(FarmersToolkit.TIDName) == "nil" ) then FarmersToolkit.TIDName = {} end

  -- Now update things 
	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
        -- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
        if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
       	FarmersToolkit.UpdateFarmlist()

end -- FarmersToolkit.LoadFarmList


-- Dangerous ideas below - the essence of the addon is to retain only session based data but .... let's see where this goes.
-- The ability to "save / restore" previous sessions is interesting in a few ways, despite being counter to the 
-- initial "session farming" idea

function FarmersToolkit.SaveFarmlist()
   FarmersToolkit.savedVariables.FarmList = FarmersToolkit.FarmList;
   FarmersToolkit.savedVariables.FarmNameByLinkID = FarmersToolkit.FarmNameByLinkID;
   
   FarmersToolkit.savedVariables.ReplenishedItems  = FarmersToolkit.ReplenishedItems ;
   FarmersToolkit.savedVariables.UniqueItems  = FarmersToolkit.UniqueItems;

   FarmersToolkit.savedVariables.SessionCount  = FarmersToolkit.SessionCount ;

   FarmersToolkit.savedVariables.Lootable  = FarmersToolkit.Lootable ;

   FarmersToolkit.savedVariables.tvalue   = FarmersToolkit.tvalue  ;

   FarmersToolkit.savedVariables.FTREP   = FarmersToolkit.FTREP ;
   FarmersToolkit.savedVariables.SHOWFRIENDS   = FarmersToolkit.SHOWFRIENDS ;

   FarmersToolkit.savedVariables.PETREP   = FarmersToolkit.PETREP ;  -- Enable / Disable random pet launch

   FarmersToolkit.savedVariables.ft_count  = FarmersToolkit.ft_count;

   FarmersToolkit.savedVariables.ReminderCount   = FarmersToolkit.ReminderCount; 
   FarmersToolkit.savedVariables.PetFrequencyCount   = FarmersToolkit.PetFrequencyCount; 
   FarmersToolkit.savedVariables.EndeavorWarningThreshhold   = FarmersToolkit.EndeavorWarningThreshhold; 
   FarmersToolkit.savedVariables.PTarget   = FarmersToolkit.PTarget; 
   -- Chasing a bug, leave this out for now
   -- FarmersToolkit.savedVariablesAcct.Booklist = FarmersToolkit.Booklist;


end -- FarmersToolkit.SaveFarmList

function FarmersToolkit.LoadFarmlist()
   FarmersToolkit.FarmList = FarmersToolkit.savedVariables.FarmList;  

   FarmersToolkit.FarmNameByLinkID= FarmersToolkit.savedVariables.FarmNameByLinkID ;

   FarmersToolkit.ReplenishedItems = FarmersToolkit.savedVariables.ReplenishedItems; if (type(FarmersToolkit.ReplenishedItems) == "nil") then FarmersToolkit.ReplenishedItems = 0; end

   FarmersToolkit.UniqueItems= FarmersToolkit.savedVariables.UniqueItems;		if (type(FarmersToolkit.UniqueItems) == "nil") then FarmersToolkit.UniqueItems = 0; end

   FarmersToolkit.SessionCount = FarmersToolkit.savedVariables.SessionCount ;	if (type(FarmersToolkit.SessionCount) == "nil") then FarmersToolkit.SessionCount = {}; end

   FarmersToolkit.Lootable = FarmersToolkit.savedVariables.Lootable ;		if (type(FarmersToolkit.Lootable) == "nil") then FarmersToolkit.Lootable = {}; end
		
	if (type(FarmersToolkit.Lootable["Chest"]) == "nil") then FarmersToolkit.Lootable["Chest"] = 0; end
	if (type(FarmersToolkit.Lootable["Books"]) == "nil") then FarmersToolkit.Lootable["Books"] = 0; end
	-- Actually, maybe books shouldn't carry over from one session to the next ..... trying this out
	FarmersToolkit.Lootable["Books"] = 0; 

   FarmersToolkit.tvalue = FarmersToolkit.savedVariables.tvalue ;			if (type(FarmersToolkit.tvalue) == "nil") then FarmersToolkit.tvalue = 0; end

   FarmersToolkit.FTREP = FarmersToolkit.savedVariables.FTREP ;     			if (type(FarmersToolkit.FTREP) == "nil") then FarmersToolkit.FTREP = 1; end
   FarmersToolkit.FLShrink = FarmersToolkit.savedVariables.FLShrink ;     			if (type(FarmersToolkit.FLShrink) == "nil") then FarmersToolkit.FLShrink = 1; end

   FarmersToolkit.SHOWFRIENDS = FarmersToolkit.savedVariables.SHOWFRIENDS; 		if (type(FarmersToolkit.SHOWFRIENDS) == "nil") then FarmersToolkit.SHOWFRIENDS = 1; end

   FarmersToolkit.PETREP = FarmersToolkit.savedVariables.PETREP ;     			if (type(FarmersToolkit.PETREP) == "nil") then FarmersToolkit.PETREP = 0; end

   FarmersToolkit.ft_count = FarmersToolkit.savedVariables.ft_count;			if (type(FarmersToolkit.ft_count) == "nil") then FarmersToolkit.ft_count = 0; end

   FarmersToolkit.ReminderCount = FarmersToolkit.savedVariables.ReminderCount;	if (type(FarmersToolkit.ReminderCount) == "nil") then FarmersToolkit.ReminderCount = 101; end
   FarmersToolkit.EndeavorWarningThreshhold = FarmersToolkit.savedVariables.EndeavorWarningThreshhold;	if (type(FarmersToolkit.EndeavorWarningThreshhold) == "nil") then FarmersToolkit.EndeavorWarningThreshhold = 3.3; end

   -- FarmersToolkit.Booklist = FarmersToolkit.savedVariablesAcct.Booklist;
	   if ( type(FarmersToolkit.savedVariablesAcct.Booklist) ~= "nil") then
	   	FarmersToolkit.Booklist = FarmersToolkit.savedVariablesAcct.Booklist;
	   else
		   dft("Initializing booklist, none found in saved variables");
	   	FarmersToolkit.Booklist = {}
	   end

  -- Now update things 
	FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
        -- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
        if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
       	FarmersToolkit.UpdateFarmlist()

end -- FarmersToolkit.LoadFarmList

function FarmersToolkit.WayshrineActions()

	-- d("I think you are considering travelling....")

	local response="";

	local FT_Companion= GetCompanionName(GetActiveCompanionDefId())
	local FT_Clean_Name=FT_Companion:gsub("%^.","");
	if ( FT_Companion ) then
 
		if (FT_Clean_Name == "Azandar" ) then
			response=FT_Clean_Name .. " quitely chants, \"Please not Slytherin, please not Artaeum, please not Eveyea....\"";
			-- dft_debug("1- Assigned a phrase based on " .. FT_Clean_Name .. ": " .. response);
		end
		if (FT_Clean_Name == "Ember" ) then
			response=FT_Clean_Name .. " mutters, \"Remember, no Halls of Colossus for me, please.\"";
			-- dft_debug("2- Assigned a phrase based on " .. FT_Clean_Name .. ": " .. response);
		end

		if (FT_Clean_Name == "Mirri Elendis" ) then
			response=FT_Clean_Name .. " whispers, \"Clockwork City is lovely this time of year.... just sayin'\"";
			-- dft_debug("3- Assigned a phrase based on " .. FT_Clean_Name .. ": " .. response);
		end

		-- FarmersToolkit.CompanionNotesDislikes["Isobel Veloise"]="Murder, stealing, going to Outlaw/Dark Brotherhood places, or people who mispronounce her name.";
		if (FT_Clean_Name == "Isobel Veloise" ) then
			response=FT_Clean_Name .. " says, \"Let's find some nice non-criminal place this time.\"";
			-- dft_debug("4- Assigned a phrase based on " .. FT_Clean_Name .. ": " .. response);
		end
	end



	if ( response ~= "" ) and ( FarmersToolkit.CompanionComments == true ) then 
		dft(response); 
	end

	-- Remind / Warn us if we have a bounty
        local CurBounty=GetFullBountyPayoffAmount();
	if ( CurBounty > 0 ) then
		FarmersToolkit.LargeDFT("Choose Wisely - you have a bounty ("..comma_value(CurBounty).." G)","FF0000");
		dft("|cFF2222Don't forget, you have a bounty! ("..comma_value(CurBounty).." G)|r If you are travelling, consider going home or Artaeum or some guard-free place....");
	end

	return ;



end -- Wayshrine Actions

function FarmersToolkit.OnTributeEvent(eventCode, GFS, eventType)

    dft("Detected a tribute event.  eventCode = [" .. eventCode .. "] and eventType = [" .. eventType .. "]  and GFS = [" .. GFS .."]");

    if ( GFS == 0 ) then -- Hide things
	FarmersToolkit.TempHide_Restore();
    else
	FarmersToolkit.TempHide_Shrink();
    end

--    if eventType == "ACTIVATED" then
--        -- dft("Your companion has been summoned!")
--	FarmersToolkit.ShowCompanionRapport();
----	
 --   elseif eventType == "CHANGED" then
--	local CurRap = GetActiveCompanionRapport();
--	local FT_Companion= GetCompanionName(GetActiveCompanionDefId())
--	local FT_Clean_Name=FT_Companion:gsub("%^.","");
 --       dft("New rapport score for " .. FT_Clean_Name .. ": " .. CurRap .. ".")
--	FarmersToolkit.ShowCompanionRapport("changed");
--	
 --   elseif eventType == "DEACTIVATED" then
  --      -- dft("Your companion has been dismissed!")
   -- end

end

function FarmersToolkit.OnCompanionEvent(eventCode, eventType)

    if eventType == "ACTIVATED" then
        -- dft("Your companion has been summoned!")
	FarmersToolkit.ShowCompanionRapport();
	
    elseif eventType == "CHANGED" then
	local CurRap = GetActiveCompanionRapport();
	local FT_Companion= GetCompanionName(GetActiveCompanionDefId())
	local FT_Clean_Name=FT_Companion:gsub("%^.","");
        dft("New rapport score for " .. FT_Clean_Name .. ": " .. CurRap .. ".")
	FarmersToolkit.ShowCompanionRapport("changed");
	
    elseif eventType == "DEACTIVATED" then
        -- dft("Your companion has been dismissed!")
    end

end

function FarmersToolkit.ListCompanionRapport()

    local companionRapport = FarmersToolkit.savedVariables.CompanionRapport
    if ( not companionRapport ) then 
	dft("You currently have no companion history.  Summon at least one before running this command.")
	return
    end

    local sortedCompanions = {}

	
    -- Collect companions into a sortable table
    for companionName, rapport in pairs(companionRapport) do
	if rapport > 0 then
        	table.insert(sortedCompanions, { name = companionName, score = rapport })
	end
    end

    -- Sort the companions by their rapport score
    table.sort(sortedCompanions, function(a, b)
        return a.score < b.score
    end)

    -- Display sorted results
    if ( #sortedCompanions > 0 ) then
    	dft("Known companion rapport scores (lowest first):");
    	for _, companion in ipairs(sortedCompanions) do
        	if companion.score > 0 then 
			dft(string.format("==     %s Rapport: %s", FarmersToolkit.fixwidth2(companion.name,50), comma_value(tonumber(companion.score)))) 
		end
    	end
    	-- Display the total count
    	dft(string.format("Total known companions: %d             (If some are missing, summon them to automatically add them to this list)", #sortedCompanions))
    else 
	dft("Cannot show complete companions rapport list - no companion history is available.  Summon at least one and retry this command.")
    end

end



function FarmersToolkit.ShowCompanionRapport(arg)

	local aretval="";
	local CNotes = "";
	local FT_Companion= GetCompanionName(GetActiveCompanionDefId())
	local FT_Clean_Name=FT_Companion:gsub("%^.","");

	local CurRap = GetActiveCompanionRapport();
	local MaxRap = GetMaximumRapport();

	if CurRap == 0 then -- We have no active companion
		dft("(Cannot show rapport - No active companion found)");
		return 
	end 


	dft_debug("CurRap = " .. CurRap .. ", FT_C = " .. FT_Companion);
	-- Record rapport scores 
	-- This has the flaw of only recording to savedVariables 
	-- A better approach may be to load savedVariables into a "live" array 
	-- For now, we will run as is to see if this is of any use.  The initial goal is to list out all the companion scores
	-- by lowest rapport to see who should be called up for daily/non-specific activities just to grow rapport 
	if not FarmersToolkit.savedVariables.CompanionRapport then FarmersToolkit.savedVariables.CompanionRapport = {} end
	FarmersToolkit.savedVariables.CompanionRapport[FT_Clean_Name]=CurRap;

	if ( arg == "changed" ) then return end

	if ( (type(FarmersToolkit.CompanionNotesLikes[FT_Clean_Name]) ~= "nil")  and ( CurRap < MaxRap ) or ( arg == "byrequest") ) then 
		CNotes = CNotes .. "\n --- Likes: " .. FarmersToolkit.CompanionNotesLikes[FT_Clean_Name] 
		-- dft_debug("Setting CNote Likes for " .. FT_Companion .. " / " .. FT_Clean_Name .. " to be: " .. CNotes);
	end

	if FarmersToolkit.CompanionNotesDislikes[FT_Clean_Name] then
		CNotes = CNotes .. "\n --- Dislikes: " .. FarmersToolkit.CompanionNotesDislikes[FT_Clean_Name] 
		-- dft_debug("Setting CNote Dislikes for " .. FT_Companion .. " / " .. FT_Clean_Name .. " to be: " .. CNotes);
	end

	if FarmersToolkit.CompanionNotesBuffs[FT_Clean_Name] then
		CNotes = CNotes .. "\n --- Buffs/Notes: " .. FarmersToolkit.CompanionNotesBuffs[FT_Clean_Name] 
		-- dft_debug("Setting CNote Buffiline for " .. FT_Companion .. " / " .. FT_Clean_Name .. " to be: " .. CNotes);
	end

	-- dft_debug("FTK:SCR> Comp = [" .. FT_Clean_Name .. "]: CurRap=" .. CurRap .. "/" .. MaxRap .. ", CNotes=[" .. CNotes .. "]");

	if ( FT_Companion ~= "" ) then
		-- aretval= string.gsub(GetCompanionName(GetActiveCompanionDefId()),"[%p%c%s][MF] %s","") .. " has a rapport level of " .. CurRap .. " / " .. MaxRap   .. string.format(".   (%3.1f%% rapport)",((CurRap/MaxRap)*100))
		aretval= FT_Clean_Name .. " has a rapport level of " .. CurRap .. " / " .. MaxRap   .. string.format(".   (%3.1f%% rapport)",((CurRap/MaxRap)*100))
		if (CNotes ~= "" ) then
			aretval= aretval .. CNotes;
		end
	else 
		aretval="No companion is active."; 
	end;

	if ( ( FarmersToolkit.CompanionComments ) and ( FarmersToolkit.CompanionComments == true ) ) or ( arg == "byrequest") then
		dft(aretval); 
	end

	return true;
	-- return arteval;

end

function FarmersToolkit.WelcomePlayer(_,initial)

	-- One of these may or may not be called by the EVENT but the function could be called by other, non-EVENT sources so... 
	-- handle various cases
	-- This is in development.  Because I don't understand it.  Yet.
	local ZoneName = GetPlayerActiveZoneName();
	local LocationName = GetPlayerLocationName();
	local Locality = LocationName .. " (" .. ZoneName ..") ";
	if ( LocationName == ZoneName ) then 
		Locality = LocationName ;
	end

	-- I'm not convinced it is working as expected, e.g. "Welcome" on first login, "Welcome back" on subsequent refreshes
	-- And it also started showing up multiple times at once.  I'm close to removing this code.  Nostalgia is the only reason
	-- not to - this was one of the first commands of the AddOn.
	if initial then
		dft(zo_strformat("Hello |cB27BFF<<1>>|r!" .. "      You are in " .. Locality .. " with " .. comma_value(FarmersToolkit.StartGold) .. " gold in your backpack.", FarmersToolkit.currentPlayer))                        
		FarmersToolkit.OnLineFriends("short");
	else 
		dft(zo_strformat("Welcome |cB27BFF<<1>>|r!" .. "      You are in " .. Locality .. ", you have " .. comma_value(FarmersToolkit.StartGold) .. " gold in your backpack.", FarmersToolkit.currentPlayer))                        
	end
end

-- Create a function to launch a series of timed updates to handle lack of a bounty change EVENT firing as bounties decrease
--
function FarmersToolkit.BountyCheck()
	
        local CurBounty=GetFullBountyPayoffAmount();
	local identifier="FarmersToolkit-BountyCheck";

	-- In case this is the first time we've been called this session...
	if ( type(FarmersToolkit.BountyValue) == "nil" ) then 
		FarmersToolkit.BountyValue=0;
	end
	
	if ( CurBounty  == 0 ) then  -- We have no bounty, whew!
		if ( FarmersToolkit.BountyValue > 0 ) then -- We may have a outstanding timer event tho
			EVENT_MANAGER:UnregisterForUpdate(identifier)
		end

		FarmersToolkit.BountyValue = 0; -- Zero out internal counter / tracker
		FarmersToolkit.UpdateActivities(); -- Update the screen
		-- dft_debug("BountyCheck indicates you are safe as of " .. os.time() .. "!");
		dft("Bounty appears cleared, cancelling timers - happy hunting.");
	else 
		if ( ( FarmersToolkit.BountyValue == 0 ) and ( CurBounty > 0 ) ) then -- This is the onset of a bounty
			dft("Bounty detected (" .. CurBounty .. "), updates posted to screen until cleared.");
		end
		FarmersToolkit.UpdateActivities();
		FarmersToolkit.BountyValue=CurBounty;
		-- dft_debug("BountyCheck = " .. CurBounty .. ", timer set for 15 seconds as of " .. os.time());
		EVENT_MANAGER:UnregisterForUpdate(identifier)  -- Just in case
		EVENT_MANAGER:RegisterForUpdate(identifier, 15000, FarmersToolkit.BountyCheck)
	end



end -- FarmersToolkit.BountyCheck


-- Create a function to launch a series of timed updates to handle lack of a bounty change EVENT firing as bounties decrease
--
function FarmersToolkit.OnLineFriends(disptype)
	   local NumFriends=GetNumFriends();
	   local PCount=0;
	   if ( NumFriends > 0 ) then
	   	-- dft("-- Scanning for friends");
	   end
	   for pnum = 1, NumFriends do
		   local PName, FNote, FStatus, FOnline=GetFriendInfo(pnum);
		   if ( FStatus ~= PLAYER_STATUS_OFFLINE) then
		   	dft(PName .. " is online. " ..FNote);
			PCount = PCount + 1;
		   else
		        if ( disptype == "detail" ) then
			   local TimeAgo = FOnline / 60; local FUnit = "mins";
			   if ( TimeAgo > 60 ) then TimeAgo = TimeAgo / 60; FUnit = "hours"; end
			   if ( TimeAgo > 24 ) then TimeAgo = TimeAgo / 24; FUnit = "days"; end
			   TimeAgo = string.format("%.2f", TimeAgo )
			   dft(PName .. " is not online (Code: " .. FStatus ..")  Last seen " .. TimeAgo .. " " .. FUnit .. " ago");
		        end
		   end
	   end
	   if ( NumFriends > 0 ) then
	   	-- dft("-- Online friends: " .. PCount .. " / " .. NumFriends);
	   end
	   --dft("No tests currently scheduled.");	   
end -- FTK.OnLineFriends

-- Add a command for an on-screen timer
function FarmersToolkit.ParseTimeInput(timeString)
    local minutes, seconds = timeString:match("^(%d+):(%d+)$")
    if minutes and seconds then
        return tonumber(minutes) * 60 + tonumber(seconds)
    else
        return nil
    end
end

local function UpdateTimerLabel()
    local remainingTime = FarmersToolkit.timerEndTime - GetTimeStamp()

    -- Stop showing the timer during battle!
    if IsUnitInCombat("player") == true then
        FTAddonTimer:SetHidden(true)
	return
    end


    if remainingTime <= 0 then
	dft("Ending countdown timer. ");
	PlaySound("LevelUp")
        FTAddonTimer:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("FarmersToolkitTimerUpdate")
    else
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        FTAddonTimerTimerLabel:SetText(string.format("|cFFFF00Countdown: %02d:%02d|r", minutes, seconds ))
        FTAddonTimer:SetHidden(false)
    end
end

function FarmersToolkit.StartTimer(duration)
    FarmersToolkit.timerEndTime = GetTimeStamp() + duration
    FTAddonTimer:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate("FarmersToolkitTimerUpdate", 1000, UpdateTimerLabel)
end

-- local function OnSlashCommandTimer(args)
--     local duration = FarmersToolkit.ParseTimeInput(args)
--     if duration then
--         FarmersToolkit.StartTimer(duration)
--     else
--         d("Invalid time format. Please use /ft timer MM:SS.")
--     end
-- end

-- SLASH_COMMANDS["/ft"] = function(cmd)
--     local command, args = cmd:match("^(%S*)%s*(.-)$")
--     if command == "timer" then
--         OnSlashCommandTimer(args)
--     else
--         d("Unknown command. Use /ft timer MM:SS.")
--     end
-- end



-- Not sure where this is going...
function FarmersToolkit.ClientInteract(clientString)
    if ( clientString ~= 131079 ) then
	dft("Hmm... looks like someone is interacting with " .. clientString .. " (" .. type(clientString) .. ")" )
    end
end


-- ############# End of utilities and subroutines (functions)

SLASH_COMMANDS["/ft"] = FarmersToolkit.Help 

SLASH_COMMANDS["/ftcount"] = function() dft("# of items you have have collected this session:" .. comma_value(FarmersToolkit.tvalue) .. " !") end

SLASH_COMMANDS["/ftgold"] = function() dft("Gold gained this session: " .. comma_value(FarmersToolkit.TotalGoldGain) .. ", total in bags: " .. comma_value(FarmersToolkit.NewGoldCount)) end

SLASH_COMMANDS["/ftfl"] = FarmersToolkit.ListFarmedItems

SLASH_COMMANDS["/ftfl2"] = FarmersToolkit.ListFarmedItemsDebug

SLASH_COMMANDS["/ftfarmlist"] = FarmersToolkit.ListFarmedItems

SLASH_COMMANDS["/ftoff"] = function() FarmersToolkit.FlipReport ("off") end

SLASH_COMMANDS["/fton"] = function() FarmersToolkit.FlipReport ("on") end

SLASH_COMMANDS["/fttop10"] = function() FarmersToolkit.Help ("craftbag 0 10") end

SLASH_COMMANDS["/ftreset"] = FarmersToolkit.ResetLists

SLASH_COMMANDS["/ftdg"] = function() FarmersToolkit.DailyGifts ("show") end

SLASH_COMMANDS["/fthelp"] = FarmersToolkit.Help

SLASH_COMMANDS["/fthelp2"] = FarmersToolkit.Help

SLASH_COMMANDS["/ft news"] = function() FarmersToolkit.Help ("news") end

SLASH_COMMANDS["/ftdebug1"] = function() FarmersToolkit.SetDebug (1) end

SLASH_COMMANDS["/ftdebug0"] = function() FarmersToolkit.SetDebug (0) end

SLASH_COMMANDS["/ft stats"] = function() FarmersToolkit.FarmingStats("plain") end

SLASH_COMMANDS["/ft fullstats"] = function() FarmersToolkit.FarmingStats("detail") end

-- #### Probably should remove these after making sure the /ft xxx equivalent works (/et sr, /et showrap, etc.)

SLASH_COMMANDS["/petoff"] = function() FarmersToolkit.FlipPet ("off") end

SLASH_COMMANDS["/peton"] = function() FarmersToolkit.FlipPet ("on") end

SLASH_COMMANDS["/petnow"] = function() FarmersToolkit.LaunchRandomPet("now") end
--
SLASH_COMMANDS["/showrap2"] = function() d(GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()) end

-- SLASH_COMMANDS["/sr"] = function() d(GetActiveCompanionDefId() .. " = " .. GetMaximumRapport() .. " for " .. GetCompanionName(GetActiveCompanionDefId()) ) end

SLASH_COMMANDS["/sr"] = function() d( "SR@FT: " ..   string.gsub(GetCompanionName(GetActiveCompanionDefId()),"[%p%c%s][MF]","") .. " has a rapport level of " .. GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()  ) end

SLASH_COMMANDS["/showrap"] = function() d( "SR@FT: " ..   string.gsub(GetCompanionName(GetActiveCompanionDefId()),"[%p%c%s][MF]","") .. " has a rapport level of " .. GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()  ) end


-- ############# End of SLASH_COMMAND block


-- ############# Set up variables, data structures, default values, etc.

-- These should be replaced with a call to the reset function, honestly

FarmersToolkit.ResetLists()

-- Cleaning up the DailyClaimed, commenting this out for now, should remove in next round if no one screams
-- local DailyClaimed ="N"; -- Assume not.  No need to save this variable off, it is generated using daily data

FarmersToolkit.FTHide = false; -- By default, show it.  We'll revisit this during variable loading

FarmersToolkit.FarmList = {}

FarmersToolkit.FarmNameByLinkID= {}

FarmersToolkit.SessionCount={}

FarmersToolkit.Lootable={} 
 
FarmersToolkit.Lootable["Chest"]=0
FarmersToolkit.Lootable["Books"]=0

FarmersToolkit.ReminderCount=101;
FarmersToolkit.PetFrequencyCount=65;
FarmersToolkit.PTarget=800;

FarmersToolkit.ft_count=0;
FarmersToolkit.FTREP=1; 
FarmersToolkit.FLShrink=2; 
FarmersToolkit.SHOWFRIENDS=1; 
FarmersToolkit.PETREP=0;
FarmersToolkit.FTHide = false;
FarmersToolkit.InvDetails = true;
FarmersToolkit.priceDetails = true;
FarmersToolkit.CompanionComments = true;
FarmersToolkit.farmingBD = false; 
FarmersToolkit.dailyBD = false; 

FarmersToolkit.TotalGoldGain=0
FarmersToolkit.NewGoldCount=0

FarmersToolkit.StartGold=GetCurrencyAmount(1,0)
FarmersToolkit.OldGoldCount=FarmersToolkit.StartGold

FarmersToolkit.currentPlayer = GetUnitName("player")
FarmersToolkit.FName=zo_strformat("|cB27BFF<<1>>|r", FarmersToolkit.currentPlayer)


-- Replace this with WelcomePlayer()
-- zo_callLater(function()     d(zo_strformat("Welcome Back |cB27BFF<<1>>|r!" .. "      You are starting off with " .. comma_value(FarmersToolkit.StartGold) .. " gold in your inventory.", FarmersToolkit.currentPlayer))                        end, 6000)
--
--
--

FarmersToolkit.inCombat = IsUnitInCombat("player")

-- Finally, we'll register our event handler function to be called when the proper event occurs.

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_ADD_ON_LOADED, FarmersToolkit.OnAddOnLoaded)


EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
EVENT_MANAGER:AddFilterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)


EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_LOOT_RECEIVED, FarmersToolkit.LootTest)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_LOCKPICK_SUCCESS, FarmersToolkit.LockpickSuccess)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE , FarmersToolkit.UpdateInventory)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_HOUSING_FURNITURE_MOVED , FarmersToolkit.UpdateActivities)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_HOUSING_FURNITURE_REMOVED , FarmersToolkit.UpdateActivities)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_HOUSING_FURNITURE_PLACED , FarmersToolkit.UpdateActivities)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_SHOW_BOOK , FarmersToolkit.BookActivity)

if ( not FarmersToolkit.SE_Flag) then
	EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, FarmersToolkit.UpdateActivities)
end

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_PLAYER_ACTIVATED, FarmersToolkit.WelcomePlayer)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, FarmersToolkit.OnLineFriends)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED , FarmersToolkit.BountyCheck)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_JUSTICE_INFAMY_UPDATED , FarmersToolkit.BountyCheck)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_JUSTICE_NO_LONGER_KOS , FarmersToolkit.BountyCheck)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_OPEN_BANK , FarmersToolkit.TempHide_Shrink)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_CLOSE_BANK , FarmersToolkit.TempHide_Restore)

-- Hide addon screens when playing tribute (they get in the way)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_TRIBUTE_MATCH_START , FarmersToolkit.TempHide_Shrink)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_TRIBUTE_MATCH_END , FarmersToolkit.TempHide_Restore)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE , FarmersToolkit.TributeHadler)
EVENT_MANAGER:RegisterForEvent("FarmersToolkit", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, function(eventCode, GFS) FarmersToolkit.OnTributeEvent(eventCode, GFS, "CHANGED") end)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_OPEN_STORE , FarmersToolkit.TempHide_ShrinkFL)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_CLOSE_STORE , FarmersToolkit.TempHide_RestoreFL)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_OPEN_TRADING_HOUSE , FarmersToolkit.TempHide_Shrink)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_CLOSE_TRADING_HOUSE , FarmersToolkit.TempHide_Restore)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_CRAFTING_STATION_INTERACT , FarmersToolkit.TempHide_ShrinkFL)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_END_CRAFTING_STATION_INTERACT , FarmersToolkit.TempHide_RestoreFL)

-- Need to review these (and other) options for better performance / control.  Definitely a WIP area here.
-- EVENT_MANAGER:RegisterForEvent("ISD", EVENT_INVENTORY_SINGLE_SLOT_UPDATE , FarmersToolkit.UpdateInventory)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_INVENTORY_FULL_UPDATE, _onInventoryChanged)
-- EVENT_MANAGER:AddFilterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
-- EVENT_MANAGER:AddFilterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
-- EVENT_MANAGER:AddFilterForEvent(FarmersToolkit.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

if ( not FarmersToolkit.SE_Flag) then
	EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_DAILY_LOGIN_REWARDS_CLAIMED, FarmersToolkit.UpdateDailyGift)
end

-- Update screen when XP changes
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name,  EVENT_EXPERIENCE_UPDATE , FarmersToolkit.UpdateInventory)
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name,  EVENT_EXPERIENCE_UPDATE , FarmersToolkit.UpdateXPTracker)

EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_START_FAST_TRAVEL_INTERACTION, FarmersToolkit.WayshrineActions)

-- Register for both companion events (original code only had functionality for summoning)
-- EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_COMPANION_ACTIVATED, FarmersToolkit.ShowCompanionRapport)
EVENT_MANAGER:RegisterForEvent("FarmersToolkit", EVENT_COMPANION_ACTIVATED, function(eventCode) FarmersToolkit.OnCompanionEvent(eventCode, "ACTIVATED") end)
EVENT_MANAGER:RegisterForEvent("FarmersToolkit", EVENT_COMPANION_DEACTIVATED, function(eventCode) FarmersToolkit.OnCompanionEvent(eventCode, "DEACTIVATED") end)
EVENT_MANAGER:RegisterForEvent("FarmersToolkit", EVENT_COMPANION_RAPPORT_UPDATE, function(eventCode) FarmersToolkit.OnCompanionEvent(eventCode, "CHANGED") end)



EVENT_MANAGER:RegisterForEvent("FarmersToolkit", EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == "FarmersToolkit" then
        FarmersToolkit.timerEndTime = 0
        FTAddonTimer:SetHidden(true)
    end
end)

-- Honestly, have no idea what this might be used for, just stumbled across it and decided it deserved some code
EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_CLIENT_INTERACT_RESULT, FarmersToolkit.ClientInteract)

-- Next we create a function that will initialize our addon
function FarmersToolkit:Initialize()

-- Attempt to register a callback to hide menus when collections is open (since there isnt' an EVENT for this)
COLLECTIONS_BOOK_SCENE:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWING then
        FarmersToolkit.TempHide_Shrink()
        FarmersToolkit.TempHide_ShrinkFL()
    elseif newState == SCENE_HIDDEN then
        FarmersToolkit.TempHide_Restore()
        FarmersToolkit.TempHide_RestoreFL()
    end
end)

-- Try to move all the containers to the back in case of overlaps
FTAddonIndicator:SetDrawTier(DT_LOW)
FTAddonIndicator:SetDrawLayer(DL_BACKGROUND)
FTAddonIndicator:SetDrawLevel(0)

FTAddonIndicator2:SetDrawTier(DT_LOW)
FTAddonIndicator2:SetDrawLayer(DL_BACKGROUND)
FTAddonIndicator2:SetDrawLevel(0)


-- Set FTK Channel
FarmersToolkit.FTK_Channel = FarmersToolkit.GetFTKChannelIndex(); d("================================== Set FTK Channel to be " .. FarmersToolkit.FTK_Channel);


FarmersToolkit.inCombat = IsUnitInCombat("player")
-- Was Broken when placed elsewhere in this file : Checking type on argument callback failed in ScriptEventManagerRegisterForEventLua
   EVENT_MANAGER:RegisterForEvent(FarmersToolkit.name, EVENT_PLAYER_COMBAT_STATE, FarmersToolkit.OnPlayerCombatState)
 
   -- Test setting this here versus up top
   FarmersToolkit.FT_DBFLAG=0;

-- Future concern, this is not yet multi-limgual, localized, or server sensitive.
-- Instead of nil you can also use GetWorldName() to save the SV server dependent
-- FarmersToolkit.savedVariables = ZO_SavedVars:NewCharacterIdSettings("FTAddonSavedVariables", 1, nil, {}) 

-- Mine and Restore Favorite Pet list
FarmersToolkit.LoadFPetList("override") -- Override during initiaization, shouldn't be needed but... better safe...
 -- This should now be handled as part of the LoadFPetList function
 -- FarmersToolkit.FPetList = FarmersToolkit.savedVariables.FPetList;

-- Restore onscreen placement
  FarmersToolkit.savedVariables = ZO_SavedVars:NewCharacterIdSettings("FTAddonSavedVariables", 1, nil, {})
  FarmersToolkit.savedVariablesAcct = ZO_SavedVars:NewAccountWide("FTAddonSavedVariablesAcct", 1, nil, {})

-- Capture last setting of FarmersToolkit.FTHide (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.FTHide ~= nil )  then 
	FarmersToolkit.FTHide = FarmersToolkit.savedVariables.FTHide;
	FTAddonIndicator:SetHidden(FarmersToolkit.FTHide) 
end

-- Capture last setting of FarmersToolkit.FTHide2 (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.FTHide2 ~= nil )  then 
	FarmersToolkit.FTHide2 = FarmersToolkit.savedVariables.FTHide2;
	FTAddonIndicator2:SetHidden(FarmersToolkit.FTHide2) 
end

-- Capture last setting of FarmersToolkit.InvDetails (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.InvDetails ~= nil )  then 
	FarmersToolkit.InvDetails = FarmersToolkit.savedVariables.InvDetails;
end

-- Capture last setting of FarmersToolkit.dailyBD (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.dailyBD ~= nil )  then 
	FarmersToolkit.dailyBD = FarmersToolkit.savedVariables.dailyBD;
end

-- Capture last setting of FarmersToolkit.farmingBD (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.farmingBD ~= nil )  then 
	FarmersToolkit.farmingBD = FarmersToolkit.savedVariables.farmingBD;
end

-- Capture last setting of FarmersToolkit.priceDetails (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.priceDetails ~= nil )  then 
	FarmersToolkit.priceDetails = FarmersToolkit.savedVariables.priceDetails;
end

-- Capture last setting of FarmersToolkit.CompanionComments (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.CompanionComments ~= nil )  then 
	FarmersToolkit.CompanionComments = FarmersToolkit.savedVariables.CompanionComments;
end

-- Capture last setting of FarmersToolkit.EndeavorWarningThreshhold (This and similar lines must come aftersavedVariables has been initialized)
if (FarmersToolkit.savedVariables.EndeavorWarningThreshhold ~= nil )  then 
	FarmersToolkit.EndeavorWarningThreshhold = FarmersToolkit.savedVariables.EndeavorWarningThreshhold;
end


-- Capture last setting of FarmersToolkit.LoadTargetOnLogin (This and similar lines must come aftersavedVariables has been initialized)
FarmersToolkit.LoadTargetOnLogin=false;
if (FarmersToolkit.savedVariables.LoadTargetOnLogin ~= nil )  then 
	FarmersToolkit.LoadTargetOnLogin = FarmersToolkit.savedVariables.LoadTargetOnLogin;

	-- Also remember to actually load the targets if requested....
	if ( FarmersToolkit.LoadTargetOnLogin == true ) then 
		FarmersToolkit.LoadTargetlist()
	end
end

-- restore Reporting and Pet settings

  FarmersToolkit.PETREP  = tonumber(FarmersToolkit.savedVariables.PETREP)	
	if (type(FarmersToolkit.PETREP) == "nil" ) then FarmersToolkit.PETREP=0; end

  FarmersToolkit.FTREP = tonumber(FarmersToolkit.savedVariables.FTREP)		
	if (type(FarmersToolkit.FTREP) == "nil" ) then FarmersToolkit.FTREP=1; end

  FarmersToolkit.FLShrink = tonumber(FarmersToolkit.savedVariables.FLShrink)		
	if (type(FarmersToolkit.FLShrink) == "nil" ) then FarmersToolkit.FLShrink=2; end

  FarmersToolkit.SHOWFRIENDS = tonumber(FarmersToolkit.savedVariables.SHOWFRIENDS)		
	if (type(FarmersToolkit.SHOWFRIENDS) == "nil" ) then FarmersToolkit.SHOWFRIENDS=1; end

-- restore bag warning limits
  FarmersToolkit.BagWarnLevel  = tonumber(FarmersToolkit.savedVariables.BagWarnLevel)
  FarmersToolkit.BagPanicLevel = tonumber(FarmersToolkit.savedVariables.BagPanicLevel)

  if (type(FarmersToolkit.BagWarnLevel) == "nil" ) then 
	-- -- dft("FT-Debug: BWL is nil after Saved variable read, probably the first time the addon is being used. Resetting to 25")
	FarmersToolkit.BagWarnLevel=25 
  end

  if (type(FarmersToolkit.BagPanicLevel) == "nil" ) then 
	-- -- dft("FT-Debug: BPL is nil after Saved variable read,probably the first time the addon is being used.  Resetting to 10")
	FarmersToolkit.BagPanicLevel=10 
  end

 -- Restore font sizes of on screen (if available)
  FarmersToolkit.FontL1 = FarmersToolkit.savedVariables.FontL1
  if ( type(FarmersToolkit.FontL1) == "nil" ) then FarmersToolkit.L1="ZoFontWinH3"; end
  FarmersToolkit.SetFont("Label", FarmersToolkit.FontL1);
	-- if (type(FarmersToolkit.FontL1) == "nil" ) then FarmersToolkit.FontL1=1; end

  FarmersToolkit.FontL2 = FarmersToolkit.savedVariables.FontL2
  if ( type(FarmersToolkit.FontL2) == "nil" ) then FarmersToolkit.L2="ZoFontBookSkinTitle"; end
  FarmersToolkit.SetFont("Label2", FarmersToolkit.FontL2);
	-- if (type(FarmersToolkit.FontL2) == "nil" ) then FarmersToolkit.FontL2=1; end

  FarmersToolkit.FontF1 = FarmersToolkit.savedVariables.FontF1
  if ( type(FarmersToolkit.FontF1) == "nil" ) then FarmersToolkit.F1="ZoFontWinH2"; end
  FarmersToolkit.SetFont("Farmlist", FarmersToolkit.FontF1);
	-- if (type(FarmersToolkit.FontF1) == "nil" ) then FarmersToolkit.FontF1=1; end

  FarmersToolkit.FontF2 = FarmersToolkit.savedVariables.FontF2
  if ( type(FarmersToolkit.FontF2) == "nil" ) then FarmersToolkit.FontF2="ZoFontWinH4"; end
  FarmersToolkit.SetFont("Farmlist2", FarmersToolkit.FontF2);
	-- if (type(FarmersToolkit.FontF2) == "nil" ) then FarmersToolkit.FontF2=1; end


  if (  FarmersToolkit.BagWarnLevel == "" ) then FarmersToolkit.BagWarnLevel=11 end
  if ( FarmersToolkit.BagPanicLevel == "" ) then FarmersToolkit.BagPanicLevel = 6 end

  -- Restore Reminder count settings
  -- FarmersToolkit.ReminderCount  = tonumber(FarmersToolkit.savedVariables.ReminderCount)
  --

  --  FarmersToolkit.ReminderCount = FarmersToolkit.savedVariables.ReminderCount;	if (type(FarmersToolkit.ReminderCount) == "nil") then FarmersToolkit.ReminderCount = 111; end
   if ( type(FarmersToolkit.savedVariables.ReminderCount) ~= "nil" ) then
  	FarmersToolkit.ReminderCount  = FarmersToolkit.savedVariables.ReminderCount
  end
  if ( type(FarmersToolkit.ReminderCount) == "nil" ) then FarmersToolkit.ReminderCount=107 end
  if ( FarmersToolkit.ReminderCount == 0 ) then FarmersToolkit.ReminderCount = 108 end

  --  FarmersToolkit.PetFrequencyCount = FarmersToolkit.savedVariables.PetFrequencyCount;	if (type(FarmersToolkit.PetFrequencyCount) == "nil") then FarmersToolkit.PetFrequencyCount = 66; end
   if ( type(FarmersToolkit.savedVariables.PetFrequencyCount) ~= "nil" ) then
  	FarmersToolkit.PetFrequencyCount  = FarmersToolkit.savedVariables.PetFrequencyCount
  end
  if ( type(FarmersToolkit.PetFrequencyCount) == "nil" ) then FarmersToolkit.PetFrequencyCount=66 end
  if ( FarmersToolkit.PetFrequencyCount == 0 ) then FarmersToolkit.PetFrequencyCount = 66 end

  --  FarmersToolkit.PTarget = FarmersToolkit.savedVariables.PTarget;	if (type(FarmersToolkit.PTarget) == "nil") then FarmersToolkit.PTarget = 800; end
   if ( type(FarmersToolkit.savedVariables.PTarget) ~= "nil" ) then
  	FarmersToolkit.PTarget  = FarmersToolkit.savedVariables.PTarget
  end
  if ( type(FarmersToolkit.PTarget) == "nil" ) then FarmersToolkit.PTarget=800 end
  if ( FarmersToolkit.PTarget == 0 ) then FarmersToolkit.PTarget = 800 end

  -- Restore position
  FarmersToolkit.RestorePosition()
  FarmersToolkit.RestorePosition2()

  -- Load up initial data even though it should all be zeroes
  FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
  -- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
  if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
  FarmersToolkit.UpdateFarmlist()

zo_callLater(function() FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())  end, 5000)
  if ( FarmersToolkit.SE_Flag ) then 
	zo_callLater(function() FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())  end, 9000)
  end
zo_callLater(function() FarmersToolkit.UpdateFarmlist() end, 11000)
zo_callLater(function() FarmersToolkit.LoadFPetList("override") end, 13000)

-- Call BountyCheck just in case we're logging in with an existing bounty
FarmersToolkit.BountyCheck();
-- FarmersToolkit.BountyCheck();

-- Attempt to set background colors (this is way more work than it should be)

        -- local farmList = FTAddonIndicator2Farmlist
        -- local farmList2 = FTAddonIndicator2Farmlist2

        -- FarmersToolkit.SetBackgroundColor(farmList, 0.8, 0.8, 0.8, 1) -- Set to light grey background
        -- FarmersToolkit.SetBackgroundColor(farmList2, 0.8, 0.8, 0.8, 1) -- Set to light grey background
	-- zo_callLater(FarmersToolkit.DelayedInit())
	FarmersToolkit.DelayedInit()


  -- ...but we don't have anything else to initialize yet. We'll come back to this.
  -- end of FarmersToolkit:Initialize
end

-- #############################################################################################

-- Load in viable font selections for on-screen options (this possibly should be within the LAM module?)
--
local FontList = { "ZoFontWinH1", "ZoFontWinH2", "ZoFontWinH3", "ZoFontWinH4", "ZoFontWinH5", "ZoFontWinH3SoftShadowThin", "ZoFontWinT1", "ZoFontWinT2",
"ZoFontGame", "ZoFontGameMedium", "ZoFontGameBold", "ZoFontGameOutline", "ZoFontGameShadow", "ZoFontKeyboard28ThickOutline", "ZoFontKeyboard24ThickOutline",
"ZoFontKeyboard18ThickOutline", "ZoFontGameSmall", "ZoFontGameLarge", "ZoFontGameLargeBold", "ZoFontGameLargeBoldShadow", "ZoFontHeader", "ZoFontHeader2",
"ZoFontHeader3", "ZoFontHeader4", "ZoFontHeaderNoShadow", "ZoFontCallout", "ZoFontCallout2", "ZoFontCallout3", "ZoFontEdit", "ZoFontEdit20NoShadow", "ZoFontChat",
"ZoFontEditChat", "ZoFontWindowTitle", "ZoFontWindowSubtitle", "ZoFontTooltipTitle", "ZoFontTooltipSubtitle", "ZoFontAnnounce", "ZoFontAnnounceMessage",
"ZoFontAnnounceMedium", "ZoFontAnnounceLarge", "ZoFontAnnounceLargeNoShadow", "ZoFontCenterScreenAnnounceLarge", "ZoFontCenterScreenAnnounceSmall", "ZoFontAlert",
"ZoFontConversationName", "ZoFontConversationText", "ZoFontConversationOption", "ZoFontConversationQuestReward", "ZoFontKeybindStripKey", "ZoFontKeybindStripDescription",
"ZoFontDialogKeybindDescription", "ZoInteractionPrompt", "ZoFontCreditsHeader", "ZoFontCreditsText", "ZoFontSubtitleText", "ZoMarketAnnouncementCalloutFont",
"ZoFontBookPaper", "ZoFontBookSkin", "ZoFontBookRubbing", "ZoFontBookLetter", "ZoFontBookNote", "ZoFontBookScroll", "ZoFontBookTablet", "ZoFontBookMetal",
"ZoFontBookPaperTitle", "ZoFontBookSkinTitle", "ZoFontBookRubbingTitle", "ZoFontBookLetterTitle", "ZoFontBookNoteTitle", "ZoFontBookScrollTitle", "ZoFontBookTabletTitle",
"ZoFontBookMetalTitle" }


 -- Iff this library is available, add in functionality - completely optional (the impacted routines are adjusted above)

 d("Hi, this is bugeroo.  Never gonna tell you where I am.")
if pChat then
	d(FarmersToolkit.FTChat .. "-- Detected pChat library - excellent! One moment while FarmersToolkit adds additional functionality");
else
	d("No pChat addon found, so sad.")
end

 -- Iff this library is available, add in functionality - completely optional
 local LAM = LibAddonMenu2
 if LAM then
	 -- This message gets lost in the startup, as in I'm not sure it is firing / able to be seen.  zo_callater may help but.... more work to come here
  	d(FarmersToolkit.FTChat .. "-- Detected LibAddonMenu library - excellent! One moment while FarmersToolkit adds additional functionality");
  	local saveData = FarmersToolkit.savedVariables  -- TODO this should be a reference to your actual saved variables table
  	-- local panelName = "FarmersToolkitSettingsPanel" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!
  	local panelName = "FarmersToolkitOptions" 
     	
	local FT_LAM = {}

	local anum=1;

	local retnum; -- Used in various places below
	local retvalue; -- Used in various places below

	function FT_LAM.SetBoolean(avar, avalue) 

		local setValue = 0;
		if ( avalue == true ) then setValue=1; end

		if ( avar == "chat" ) then
			if (setValue==1 ) then dft("Turning ON farm reporting in chat"); else dft("Turning OFF farm reporting in chat") end
			FarmersToolkit.FTREP=setValue;
   	   		FarmersToolkit.savedVariables.FTREP   = FarmersToolkit.FTREP ;
		elseif ( avar == "screen" ) then
			-- Turns out FTHide is a true/false and not a 1/0 so use avalue instead of setValue
			-- avalue=true --> ON
			if ( avalue==true) then 
				-- So, show (aka, do not hide) the screen (FTHide = False)
				FarmersToolkit.FTHide=false;
   	   			FarmersToolkit.savedVariables.FTHide   = FarmersToolkit.FTHide ;
				FTAddonIndicator:SetHidden(false) -- hidden false = screen on
				dft("Turning ON screen reporting "); 
			end
			if ( avalue==false) then 
				-- So, hide (aka, do not show) the screen (FTHide = true)
				FarmersToolkit.FTHide=true;
   	   			FarmersToolkit.savedVariables.FTHide   = FarmersToolkit.FTHide ;
				FTAddonIndicator:SetHidden(true) -- hidden false = screen on
				dft("Turning OFF screen reporting "); 
			end

		elseif ( avar == "farmlist" ) then
			-- Recall that FTHide2 is a true/false and not a 1/0 so use avalue instead of setValue
			-- avalue=true --> ON
			if ( avalue==true) then 
				-- So, show (aka, do not hide) the screen (FTHide2 = False)
				FarmersToolkit.FTHide2=false;
   	   			FarmersToolkit.savedVariables.FTHide2   = FarmersToolkit.FTHide2 ;
				FTAddonIndicator2:SetHidden(false) -- hidden false = screen on
				dft("Turning ON farmlist reporting "); 
			end
			if ( avalue==false) then 
				-- So, hide (aka, do not show) the screen (FTHide2 = true)
				FarmersToolkit.FTHide2=true;
   	   			FarmersToolkit.savedVariables.FTHide2   = FarmersToolkit.FTHide2 ;
				FTAddonIndicator2:SetHidden(true) -- hidden false = screen on
				dft("Turning OFF farm reporting "); 
			end

		elseif ( avar == "targets" ) then
			-- Recall that LoadTargetOnLogin is a true/false and not a 1/0 so use avalue instead of setValue
			-- avalue=true --> ON
			if ( avalue==true) then 
				FarmersToolkit.LoadTargetOnLogin=true;
   	   			FarmersToolkit.savedVariables.LoadTargetOnLogin   = FarmersToolkit.LoadTargetOnLogin ;
				dft("Turning ON automatic loading of target list upon login "); 
			end
			if ( avalue==false) then 
				FarmersToolkit.LoadTargetOnLogin=false;
   	   			FarmersToolkit.savedVariables.LoadTargetOnLogin   = FarmersToolkit.LoadTargetOnLogin ;
				dft("Turning OFF automatic loading of target list upon login "); 
			end

		elseif ( avar == "pet" ) then
			FarmersToolkit.PETREP=setValue;
   	   		FarmersToolkit.savedVariables.PETREP   = FarmersToolkit.PETREP ;
			-- d("-- Setting pet (PTREP) to " .. setValue .. " for pet (PETREP) ");
			if (setValue==1 ) then dft("Turning ON pet swapping "); else dft("Turning OFF pet swapping") end

		elseif ( avar == "invdetails" ) then
			if ( avalue==true) then 
   	   			FarmersToolkit.InvDetails = true;
   	   			FarmersToolkit.savedVariables.InvDetails   = FarmersToolkit.InvDetails ;
				dft("Turning ON inventory details option "); 
       				FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end
			if ( avalue==false) then 
				FarmersToolkit.InvDetails=false;
   	   			FarmersToolkit.savedVariables.InvDetails   = FarmersToolkit.InvDetails ;
				dft("Turning OFF inventory details option "); 
       				FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end

		elseif ( avar == "farmingBD" ) then
			if ( avalue==true) then 
   	   			FarmersToolkit.farmingBD = true;
   	   			FarmersToolkit.savedVariables.farmingBD   = FarmersToolkit.farmingBD ;
				dft("Turning ON farming window backdrop option "); 
       				FarmersToolkit.SetBackdrop("farmingBD","show")
			end
			if ( avalue==false) then 
				FarmersToolkit.farmingBD=false;
   	   			FarmersToolkit.savedVariables.farmingBD   = FarmersToolkit.farmingBD ;
				dft("Turning OFF farming window backdrop option "); 
       				FarmersToolkit.SetBackdrop("farmingBD","hide")
			end

		elseif ( avar == "dailyBD" ) then
			if ( avalue==true) then 
   	   			FarmersToolkit.dailyBD = true;
   	   			FarmersToolkit.savedVariables.dailyBD   = FarmersToolkit.dailyBD ;
				dft("Turning ON daily window backdrop option "); 
       				FarmersToolkit.SetBackdrop("dailyBD","show")
			end
			if ( avalue==false) then 
				FarmersToolkit.dailyBD=false;
   	   			FarmersToolkit.savedVariables.dailyBD   = FarmersToolkit.dailyBD ;
				dft("Turning OFF daily window backdrop option "); 
       				FarmersToolkit.SetBackdrop("dailyBD","hide")
			end

		elseif ( avar == "pricedetails" ) then
			if ( avalue==true) then 
   	   			FarmersToolkit.priceDetails = true;
   	   			FarmersToolkit.savedVariables.priceDetails   = FarmersToolkit.priceDetails ;
				dft("Turning ON price details option "); 
       				FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end
			if ( avalue==false) then 
				FarmersToolkit.priceDetails=false;
   	   			FarmersToolkit.savedVariables.priceDetails   = FarmersToolkit.priceDetails ;
				dft("Turning OFF price details option "); 
       				FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end
		elseif ( avar == "compchat" ) then
			if ( avalue==true) then 
   	   			FarmersToolkit.CompanionComments = true;
   	   			FarmersToolkit.savedVariables.CompanionComments   = FarmersToolkit.CompanionComments ;
				dft("Turning ON companion chat comments "); 
       				-- FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end
			if ( avalue==false) then 
				FarmersToolkit.CompanionComments=false;
   	   			FarmersToolkit.savedVariables.CompanionComments   = FarmersToolkit.CompanionComments ;
				dft("Turning OFF companion chat comments "); 
       				-- FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
			end

		elseif ( avar == "showfriends" ) then
			if (setValue==1 ) then dft("Turning ON friend reporting in chat"); else dft("Turning OFF friend reporting in chat") end
			FarmersToolkit.SHOWFRIENDS=setValue;
   	   		FarmersToolkit.savedVariables.SHOWFRIENDS   = FarmersToolkit.SHOWFRIENDS ;
			retnum=FarmersToolkit.SHOWFRIENDS;
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
		elseif ( avar == "XX" ) then
			retnum=55;
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
			-- d("-- Would return " .. retnum .. " for PetFrequency ");
			-- dft("Adjusting pet frequency configuration");
		else 
			retnum=99;
		end
		return(true);


	end

	-- Return value of FPetList if defined, false otherwise
	function FT_LAM.GetFPetValue(avar) 
		-- dft_debug("GetFPetValue called with avar= " .. avar);
		-- FarmersToolkit.LoadFPetList ()
		 local retval=false;
		 if ( type(FarmersToolkit.FPetList[avar]) ~= nil  ) then 
	 		retval= FarmersToolkit.FPetList[avar];
		end
		return retval;
	end

	-- Set value of FPetList 
	function FT_LAM.SetFPetValue(avar,avalue) 
		if (avalue==true) then
			-- dft_debug("SetFPValue called with avalue=TRUE, avar=" .. avar);
			FarmersToolkit.FPetList[avar]=avalue;
			FarmersToolkit.savedVariables.FPetList=FarmersToolkit.FPetList; -- specifying the index key didn't work
		else
			-- dft_debug("SetFPValue called with avalue=FALSE, avar=" .. avar);
			FarmersToolkit.FPetList[avar]=nil;
			FarmersToolkit.savedVariables.FPetList=FarmersToolkit.FPetList; -- specifying the index key didn't work
		end
		return true;
	end

	function FT_LAM.GetBoolean(avar) 

		-- Need to review "retnum" vs "retvalue" ... retnum may be obsolete
		local retnum=0;
		
		local retvalue=false; 
		if ( avar == "chat" ) then
			retnum=FarmersToolkit.FTREP;
			-- d("-- Would retun " .. retnum .. " for chat/FTREP " .. FarmersToolkit.FTREP);
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
		elseif ( avar == "screen" ) then
			-- retnum=FarmersToolkit.FTHide;
			retnum=44;
			retnum=FarmersToolkit.FTHide;
			--
			-- Also, FTHide is the opposite of what is being asked for here.
			-- FTHide is "should I hide the on screen info" so true = hide the screen
			-- This config asks "should I show the config" so true = yes, show the screen
			-- I could rename the question but the current setup is more natural so...
			-- we will code around it.  FTHide will stay as intended, we'll just
			-- make the adjustments for the GUI here.
			retvalue = not FarmersToolkit.FTHide;
		elseif ( avar == "farmlist" ) then -- Same logic as FTHide above
			retnum=88;
			retvalue = not FarmersToolkit.FTHide2;
		elseif ( avar == "pet" ) then
			retnum=FarmersToolkit.PETREP;
			-- d("-- Would retun " .. retnum .. " for pet/PETREP " .. FarmersToolkit.PETREP);
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
		elseif ( avar == "targets" ) then
			-- d("-- Would retun " .. retnum .. " for LoadTargetOnLogin ");
			-- if ( retnum == 1 ) then retvalue=true else retvalue = false end
			retvalue = FarmersToolkit.LoadTargetOnLogin;
		elseif ( avar == "invdetails" ) then
			retvalue = FarmersToolkit.InvDetails;
		elseif ( avar == "pricedetails" ) then
			retvalue = FarmersToolkit.priceDetails;
		elseif ( avar == "compchat" ) then
			retvalue = FarmersToolkit.CompanionComments;
		elseif ( avar == "farmingBD" ) then
			retvalue = FarmersToolkit.farmingBD;
		elseif ( avar == "dailyBD" ) then
			retvalue = FarmersToolkit.dailyBD;
		elseif ( avar == "XX" ) then
			retnum=55;
			-- d("-- Would retun " .. retnum .. " for PetFrequency ");
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
		elseif ( avar == "showfriends" ) then
			retnum=FarmersToolkit.SHOWFRIENDS;
			-- d("-- Would retun " .. retnum .. " for chat/FTREP " .. FarmersToolkit.FTREP);
			if ( retnum == 1 ) then retvalue=true else retvalue = false end
		else 
			retnum=99; -- We should never see this value.
		end
		return retvalue
	end -- FT_LAM.GetBoolean


	function FT_LAM.SetNumeric(avar, anum) 

		if ( avar == "BW" ) then
			FarmersToolkit.BagWarnLevel=anum;
   	   		FarmersToolkit.savedVariables.BagWarnLevel   = FarmersToolkit.BagWarnLevel ;
			dft("(Config): Changed free inventory bag count Warn level to [" .. FarmersToolkit.BagWarnLevel .. "]")

		elseif ( avar == "BP" ) then
			FarmersToolkit.BagPanicLevel=anum;
   	   		FarmersToolkit.savedVariables.BagPanicLevel   = FarmersToolkit.BagPanicLevel ;
			dft("(Config): Changed free inventory bag count Panic level to [" .. FarmersToolkit.BagPanicLevel .. "]")
		elseif ( avar == "RC" ) then
			FarmersToolkit.ReminderCount=anum;
   	   		FarmersToolkit.savedVariables.ReminderCount   = FarmersToolkit.ReminderCount ;
			dft("(Config): Changed reminder count level to [" .. FarmersToolkit.ReminderCount .. "]")
		elseif ( avar == "PFC" ) then
			FarmersToolkit.PetFrequencyCount=anum;
   	   		FarmersToolkit.savedVariables.PetFrequencyCount   = FarmersToolkit.PetFrequencyCount ;
			dft("(Config): Changed PetFrequencyCount count level to [" .. FarmersToolkit.PetFrequencyCount .. "]")
		elseif ( avar == "EWL" ) then
			FarmersToolkit.EndeavorWarningThreshhold=anum;
   	   		FarmersToolkit.savedVariables.EndeavorWarningThreshhold   = FarmersToolkit.EndeavorWarningThreshhold ;
			dft("(Config): Changed EndeavorWarningThreshhold count level to [" .. FarmersToolkit.EndeavorWarningThreshhold .. "]")
		elseif ( avar == "SPT" ) then
			FarmersToolkit.PTarget=anum;
   	   		FarmersToolkit.savedVariables.PTarget   = FarmersToolkit.PTarget ;
			dft("(Config): Changed Price Target to [" .. FarmersToolkit.PTarget .. "]")


		elseif ( avar == "XX" ) then -- placeholder, should never actually get here
			retnum=888;
		else 
			retnum=99;
		end

       		FarmersToolkit.UpdateText(FarmersToolkit.UpdateInventory())
       		-- FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies())
  	        if ( FarmersToolkit.SE_Flag ) then FarmersToolkit.UpdateText2(FarmersToolkit.UpdateDailies()) end
   		FarmersToolkit.UpdateFarmlist()

		return true
	end

	function FT_LAM.GetNumeric(avar) 
		local retnum=11;
		if ( avar == "BW" ) then
			retnum=FarmersToolkit.BagWarnLevel;
		elseif ( avar == "BP" ) then
			retnum=FarmersToolkit.BagPanicLevel;
		elseif ( avar == "RC" ) then
			retnum=FarmersToolkit.ReminderCount;
		elseif ( avar == "PFC" ) then
			retnum=FarmersToolkit.PetFrequencyCount;
		elseif ( avar == "SPT" ) then
			retnum=FarmersToolkit.PTarget;
		elseif ( avar == "EWL" ) then
			if ( FarmersToolkit.EndeavorWarningThreshhold ) then
				retnum=FarmersToolkit.EndeavorWarningThreshhold;
			else 
				FarmersToolkit.EndeavorWarningThreshhold=3;
   	   			FarmersToolkit.savedVariables.EndeavorWarningThreshhold   = FarmersToolkit.EndeavorWarningThreshhold ;
				retnum=FarmersToolkit.EndeavorWarningThreshhold;
			end
		elseif ( avar == "XX" ) then
			retnum=888;
		else 
			retnum=99;
		end
		return (retnum)
	end

     	local panelData = {
       		type = "panel",
       		name = "Farmers Toolkit",
       		author = "Vilkasmanga",
       		version = FarmersToolkit.FTVersion;
		displayName = "Farmers Toolkit Configurations",
		registerForRefresh = true,	
    	}


    	-- local panel = LAM:RegisterAddonPanel(panelName, panelData)
	-- We were getting a timeout warning "panel regsitered before AddOn loaded" so....
	-- Commented out for 2026
	-- zo_callLater(function() FarmersToolkit.AMpanel = LAM:RegisterAddonPanel(panelName, panelData) d("FT: LibAddonMenu detected - GUI configuration available (See: Settings, Add-on, FarmersTookit).") end, 9000)

  	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)

	local optionsData = {}

	FarmersToolkit.LoadFPetList ("override") -- Make sure we've built a list of pets
	local MaxPet=tableLength(FarmersToolkit.SortedPetNames); -- We will step through this table below
		             
		optionsData[1] = {
			type= "submenu",
			name=string.format("|c00FF00Reporting controls|r "),
			tooltip="Settings that control reporting (in chat, on screen, etc.)",
			controls = {

				[1] = {
	                 		type = "dropdown",
	                 		name = "Font selection for Daily task (top line) ",
	                 		tooltip = "Change the font (size) for daily tasks (top line)",
			 		setFunc = function(value) FarmersToolkit.SetFont("Label2",value) end,
			 		-- getFunc = function() return FarmersToolkit.GetFont("Label2") end,
			 		getFunc = function() return FarmersToolkit.GetFont("Label2") end,
					scrollable = true,
					choices = FontList,

		      		}, -- Menu option 1

				[2] = {
	                 		type = "dropdown",
	                 		name = "Font selection for Inventory status (second line) ",
	                 		tooltip = "Change the font (size) for inventory summary line (second line)",
			 		setFunc = function(value) FarmersToolkit.SetFont("Label",value) end,
			 		getFunc = function() return FarmersToolkit.GetFont("Label") end,
					scrollable = true,
					choices = FontList,

		      		},

				[3] = { -- Farmlist Header font
	                 		type = "dropdown",
	                 		name = "Font selection for Farming Targets (header). ",
	                 		tooltip = "Change the font (size) for tracking farming targets.",
			 		setFunc = function(value) FarmersToolkit.SetFont("Farmlist",value) end,
			 		-- getFunc = function() return FarmersToolkit.GetFont("Farmlist") end,
			 		getFunc = function() return FarmersToolkit.GetFont("Farmlist") end,
					scrollable = true,
					choices = FontList,
					-- disabled = true,

		      		}, -- Menu option 3

				[4] = { -- Farmlist text font
	                 		type = "dropdown",
	                 		name = "Font selection for Farming Targets (list text). ",
	                 		tooltip = "Change the font (size) for tracking farming targets.",
			 		setFunc = function(value) FarmersToolkit.SetFont("Farmlist2",value) end,
			 		-- getFunc = function() return FarmersToolkit.GetFont("Farmlist2") end,
			 		getFunc = function() return FarmersToolkit.GetFont("Farmlist2") end,
					scrollable = true,
					choices = FontList,
					-- disabled = true,

		      		}, -- Menu option 3

				[5] = {
	                 		type = "header",
	                 		name = string.format("|c00FF00On screen / In Chat controls|r"),
		      		},

				[6] = {
	                 		type = "checkbox",
	                 		name = "Chat Reporting",
	                 		tooltip = "Turn on/off FT's farming reporting into the chat window.",
			 		getFunc = function() return FT_LAM.GetBoolean("chat") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("chat",value) end,
		      		},

				[7] = {
	                 		type = "checkbox",
	                 		name = "Screen Reporting",
	                 		tooltip = "Turn on/off FT's inventory / endeavor tracking appearing on the screen.",
			 		getFunc = function() return FT_LAM.GetBoolean("screen") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("screen",value) end,
		      		},

				[8] = {
	                 		type = "checkbox",
	                 		name = "Farming target reporting",
	                 		tooltip = "Turn on/off FT's farming / shopping list appearing on the screen.",
			 		getFunc = function() return FT_LAM.GetBoolean("farmlist") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("farmlist",value) end,
					-- disabled = true,
		      		},
				[9] = {
	                 		type = "checkbox",
	                 		name = "Detailed inventory reporting",
	                 		tooltip = "Turn on/off FT's inventory details (maps, motifs, furniture, etc.) appearing on the screen.",
			 		getFunc = function() return FT_LAM.GetBoolean("invdetails") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("invdetails",value) end,
					-- disabled = true,
		      		},
				[10] = {
	                 		type = "checkbox",
	                 		name = "Price reporting in chat",
	                 		tooltip = "Turn on/off FT's pricing details (using TTC if available, else ZOS) appearing in chat.",
			 		getFunc = function() return FT_LAM.GetBoolean("pricedetails") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("pricedetails",value) end,
					-- disabled = true,
		      		},
				[11] = {
	                 		type = "checkbox",
	                 		name = "Companion-related comments in chat",
	                 		tooltip = "Turn on/off add-on comments in chat concerning companions.",
			 		getFunc = function() return FT_LAM.GetBoolean("compchat") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("compchat",value) end,
					-- disabled = true,
		      		},
				[12] = {
	                 		type = "checkbox",
	                 		name = "Backdrop for daily tasks",
	                 		tooltip = "Turn on/off a semi-transparent background (may improve readability)",
			 		getFunc = function() return FT_LAM.GetBoolean("dailyBD") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("dailyBD",value) end,
					-- disabled = true,
		      		},
				[13] = {
	                 		type = "checkbox",
	                 		name = "Backdrop for farming targets",
	                 		tooltip = "Turn on/off a semi-transparent background (may improve readability)",
			 		getFunc = function() return FT_LAM.GetBoolean("farmingBD") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("farmingBD",value) end,
					-- disabled = true,
		      		},




			    }, -- submenu controls
		      } -- optionsData 1

		optionsData[2] = {
			type= "submenu",
			name=string.format("|c00FF00Inventory controls|r "),
			tooltip="Settings that control inventory info with a a numeric value",
			controls = {
				[1] = { 
					type = "slider", 
					name = string.format("|cFFFF00Warning|r level for Backpack's Free/Open Space"), 
					tooltip = "Minimum number of open slots before showing a warning (yellow text).", 
					min = FarmersToolkit.BagPanicLevel,
					max =  maxSlots,
					getFunc = function() return FT_LAM.GetNumeric("BW") end, 
					setFunc = function(value) FT_LAM.SetNumeric("BW",value) end,
		      		},
				[2] = {
					type = "slider", 
					name = string.format("|cFF0000Panic|r level for Backpack's Free/Open Space"), 
					tooltip = "Minimum number of open slots before showing a panic (red text).", 
					min = 0,
					max =  maxSlots,
					getFunc = function() return FT_LAM.GetNumeric("BP") end, 
					setFunc = function(value) FT_LAM.SetNumeric("BP",value) end,
		      		},

		      }
		 }

		optionsData[3] = {
			type= "submenu",
			name=string.format("|c00FF00Miscellaneous behaviors|r "),
			tooltip="Settings that control the addon's additional behavior during farming: celebrations every NNN items, random pet swaps, etc.",
			controls = {
				[1] = {
	                 		type = "checkbox",
	                 		name = "Load saved targets on login/refresh",
	                 		tooltip = "Essentially, execute '/ft loadtargets' on login or reloadui",
			 		getFunc = function() return FT_LAM.GetBoolean("targets") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("targets",value) end,
				},
				[2] = {
					type = "slider", 
					name = "Reminder Count",
					tooltip = "Celebrate farming after every ReminderCount # of items farmed",
					min = 0,
					max = 500,
					getFunc = function() return FT_LAM.GetNumeric("RC") end, 
					setFunc = function(value) FT_LAM.SetNumeric("RC",value) end,
				},
				[3] = {
					type = "slider", 
					name = "Endeavor Warning Limit (hrs)",
					tooltip = "Throw up a warning when endeavors have less than [this number] hours remaining",
					min = 0,
					max = 12,
					getFunc = function() return FT_LAM.GetNumeric("EWL") end, 
					setFunc = function(value) FT_LAM.SetNumeric("EWL",value) end,
				},
				[4] = {
	                 		type = "header",
	                 		-- name = string.format("|c00FF00On screen / In Chat controls|r"),
	                 		name = "",
		      		},
				[5] = {
	                 		type = "checkbox",
	                 		name = "Random pet swapping",
	                 		tooltip = "Turn on/off FT's random pet selection ",
			 		getFunc = function() return FT_LAM.GetBoolean("pet") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("pet",value) end,
				},


				[6] = {
					type = "slider", 
					name = "Pet Frequency - (if PetSwap is active)",
					tooltip = "Determine the frequency of pet swap for each ReminderCount",
					min = 0,
					max =  100,
					getFunc = function() return FT_LAM.GetNumeric("PFC") end, 
					setFunc = function(value) FT_LAM.SetNumeric("PFC",value) end,
					-- disabled = true,
		      		},


				[7] = {
					type = "button", 
					name = "Gimme a random pet!",
					tooltip = "Don't think, don't wait - I wanna pet...NNOOW!!!!",
					func = function() FarmersToolkit.LaunchRandomPet("now") end,
				      },

				[8] = {
					type = "slider", 
					name = "Price Target - (Prefers TCC AddOn)",
					tooltip = "Set the price target for recommending an item be sent to guild traders",
					min = 500,
					max =  100000,
					step = 250,
					getFunc = function() return FT_LAM.GetNumeric("SPT") end, 
					setFunc = function(value) FT_LAM.SetNumeric("SPT",value) end,
					-- disabled = true,
		      		},
				[9] = {
	                 		type = "checkbox",
	                 		name = "Favorited friends announcements",
	                 		tooltip = "Be reminded of which favorited friends are online - useful if that list is small (<10)",
			 		getFunc = function() return FT_LAM.GetBoolean("showfriends") end,
			 		setFunc = function(value) FT_LAM.SetBoolean("showfriends",value) end,
				},

				[10] = {
    					type = "button",
    					name = "Reset Panel Positions",
    					tooltip = "Reposition the inventory and farming panels to their default locations.",
    					func = function() FarmersToolkit.ResetPanelPositions() end,
    					width = "full",
					},


		      }
		 }

		optionsData[4] = {
			type= "submenu",
			name=string.format("|c00FF00 Pet List / Favorite Pets|r"),
			tooltip="Choose which pets (favorites) that can be used for random swaps. (Optional)",
			controls = {},
			disabled = false;
			--
		}

		 local loopcount=0;

		 local ODCount=4;
		 local loop2=0;
	   	 for key,val in orderedPairs(FarmersToolkit.SortedPetNames) do
			 -- Recall, we're stepping through SortedPetNames which is array[name]=Petnum so 
			 -- we need to swap key and val around a bit
			 -- dft_debug("ZZZ: val=[" .. val .."]")
			 		
			-- local PetName = GetCollectibleLink(key, 1)
			 loopcount =loopcount + 1;
			 loop2 = loop2 + 1;

			 -- dft_debug("Calling GCBLink(" .. val .. ",1)");

			if ( val > 0 ) then -- We're getting 0 entries at some point, protect the menus until we resolve
			
		 	   local PetName = GetCollectibleLink(val, 1)
	   	           optionsData[ODCount].controls[loop2] = {
	                  		type = "checkbox",
	                  		-- name = "X[" .. ODCount .. ":" .. loopcount .. "=" .. loop2 .. "/" .. val .. "]:"..PetName,
	                  		-- name = "OD[" ..ODCount .. "].controls[" .. loop2 .. "]: loopcount=" .. loopcount .. ", val=" .. val .. ", Petname=" .. PetName,
	                  		-- tooltip = "Marking ON means: set " .. PetName .. " (Pet #" .. val .. ") as a favorite random pet ",
					--
	                  		name = loop2 .. ": " .. PetName,
	                  		tooltip = "Marking ON means: set " .. PetName .. " as a favorite random pet ",
			  		 getFunc = function() return FT_LAM.GetFPetValue(val) end,
			  		setFunc = function(value) FT_LAM.SetFPetValue(val,value) end,
			 	}
		        else 
				dft_debug("Warning: val = " .. val .. " out of AvailPets for some reason.  key = " .. key)
			end
		end

	-- Newer code to delay the LAM call based on warnings during the initial load (from LAM)
	zo_callLater(function()

    		-- One-time guard (prevents double registration)
    		if FarmersToolkit._lamRegistered then return end
    		FarmersToolkit._lamRegistered = true
	
		-- This is probably redunant, commenting it out for now	
    		-- local LAM = LibAddonMenu2
    		-- if not LAM then return end

    		-- LAM:RegisterAddonPanel("FarmersToolkitOptions", panelData)
		-- panelName="FarmersToolkitOptions";
    		-- LAM:RegisterOptionControls(panelName, optionsData)

		-- Instance to call and load Options panel
    		-- FarmersToolkit.OpenSettingsPanel = function()
        	--		LAM:OpenToPanel("FarmersToolkitOptions")
    		-- end

		local lamPanel = LAM:RegisterAddonPanel("FarmersToolkitOptions", panelData)
		LAM:RegisterOptionControls("FarmersToolkitOptions", optionsData)
		
		FarmersToolkit.OpenSettingsPanel = function()
    				LAM:OpenToPanel(lamPanel)
		end


	end, 0)





	-- LAM:RegisterAddonPanel("FarmersToolkitOptions", panelData)

    	-- LAM:RegisterOptionControls(panelName, optionsData)

	-- Attempt to put in a hook to open settings panel via a function
	-- Honestly, I stole this from another AddOn but everyone has the exact same code
	-- making me think it is eitehr a trivial call or everyone is living off of copy/paste
	-- here.  I am firmly in the latter camp.  If it works.


        -- Commenting out because OI think it is superseded by the above call.... but leaving in
	-- because I'm not 100% sure about that.
        -- FarmersToolkit.OpenSettingsPanel = function()
	--           LAM:OpenToPanel(FarmersToolkit.LAMpanel)
	-- end
  else 
    	dft("-- Did not detect LibAddonMenu library - configurations should be made through the command line (ft /help for more info)")

  end -- if LibAddonMenu2 available


  -- Next project (GUI TARGETS), set targets from tooltip
  -- General approach:
  -- 1 - Create a /ft settarget ITEM_NUM count (done)
  -- 2 - Create a mouse over right click on an item capablity (kinda done, inventory only - not sure why not everywhere.  Yet.)
  -- 3 - When clicked, send custom text to chat via  CHAT_SYSTEM.textEntry:Open(message) -- Done but still feels ugly
  -- 4 - Set up tracking using existing infrastructure (done, for the most part)
  --

  -- if library addon available, add some functionality - completely optional
  if LibCustomMenu then
	  dft("Detected LibCustomMenu - Excellent! Adding functionality: right-click inventory to set farming goals");

	  local FTK_LCM = LibCustomMenu

	  function FarmersToolkit.SetFT (abagId, aSlotId)
   		local link  = GetItemLink(abagId, aSlotId)
   		local aname = GetItemName(abagId, aSlotId)
      		local LinkID=GetItemLinkItemId(link);
   		-- local count = GetSlotStackSize(abagId, aSlotId)
		
	  	-- dft_debug("link=[" .. link ..")" );
	  	-- dft_debug("aname=[" .. aname ..")" );

	  	-- dft_debug("Test function confirmed for [" .. LinkID .. "]")
		-- dft_debug("Received reference to a bag (" .. abagId .. ") ");
		-- dft_debug("...and a slot (" .. aSlotId .. ")" );

		-- There is probably a better way to do this but asking via chat also works
		-- Ideally, this would pop up a GUI in the config screen to let them type in a #
		-- but I have no idea how to do that.  Yet.
		local amessage = "/ft settarget " .. link .. "      "
		CHAT_SYSTEM.textEntry:Open(amessage)
	  end

	  function FarmersToolkit.SetFTT (abagId, aSlotId)
   		-- local link  = GetItemLink(abagId, aSlotId)
		local SpecialItemType=ZO_GetSpecializedItemTypeTextBySlot(abagId, aSlotId); 
   		-- local aname = GetItemName(abagId, aSlotId)
      		-- local LinkID=GetItemLinkItemId(link);
   		-- local count = GetSlotStackSize(abagId, aSlotId)
		
		-- but I have no idea how to do that.  Yet.
		local amessage = "/ft settypetarget " .. SpecialItemType .. "      "
		CHAT_SYSTEM.textEntry:Open(amessage)
	  end



-- Top

local function FT_TryGetItemLinkFromContext(control, slotActions)
    -- 1) Classic inventory slot
    if control and ZO_Inventory_GetBagAndIndex then
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(control)
        if bagId and slotIndex then
            return GetItemLink(bagId, slotIndex)
        end
    end

    -- 2) Many lists store data on the control's dataEntry
    if control and control.dataEntry and control.dataEntry.data then
        local data = control.dataEntry.data
        if data.bagId and data.slotIndex then
            return GetItemLink(data.bagId, data.slotIndex)
        end
        if data.itemLink and data.itemLink ~= "" then
            return data.itemLink
        end
        if data.link and data.link ~= "" then
            return data.link
        end
    end

    -- 3) Some context systems pass a structure with an itemLink
    if slotActions then
        if slotActions.itemLink and slotActions.itemLink ~= "" then
            return slotActions.itemLink
        end
        if slotActions.GetItemLink then
            local ok, link = pcall(slotActions.GetItemLink, slotActions)
            if ok and link and link ~= "" then
                return link
            end
        end
    end

    return nil
end

local function FT_InstallChatLinkTargetMenu()
    if FarmersToolkit._chatLinkHookInstalled then return end
    FarmersToolkit._chatLinkHookInstalled = true

    -- PostHook instead of overwrite: avoids conflicts with TTC / PriceTooltipNote / others
    ZO_PostHook("ZO_LinkHandler_OnLinkMouseUp", function(link, button, control)
        -- ESO: 2 = right-click
        if button ~= 2 then return end
        if not link or link == "" then return end

        -- Guard in case API/global differs in some environments
        local isItem = false
        if ZO_LinkHandler_GetLinkType then
            isItem = (ZO_LinkHandler_GetLinkType(link) == "item")
        else
            -- fallback: crude but safe
            isItem = link:find("|H%d:item:") ~= nil
        end
        if not isItem then return end

        -- If your target function isn't available yet, don't add a broken menu item
        if type(FarmersToolkit.PromptSetTarget) ~= "function" then return end

        ClearMenu()
        AddCustomMenuItem("Set Farming Target...", function()
            FarmersToolkit.PromptSetTarget(link)
        end)
        ShowMenu(control)
    end)
end


-- Call this once during addon initialization
FT_InstallChatLinkTargetMenu()


local function AddMenuEntry(control, slotActions)
    local itemLink = FT_TryGetItemLinkFromContext(control, slotActions)
    if not itemLink then return end

    AddCustomMenuItem("Set Farming Target...", function()
        FarmersToolkit.PromptSetTarget(itemLink)
    end)

    -- Optional: keep the oldat-based approach as a fallback / power-user option
    -- AddCustomMenuItem("Set Farming Target in chat", function()
    --     CHAT_SYSTEM.textEntry:Open("/ft settarget " .. itemLink .. "      ")
    -- end)
end

FTK_LCM:RegisterContextMenu(AddMenuEntry, FTK_LCM.CATEGORY_LATE)

-- Bottom


	  local function AddMenuEntry(inventorySlot, slotActions)
		      
 	  	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
		       
	  	if bagId and slotIndex then 
		  	-- AddCustomMenuItem("Set Farming Target in chat", function()       FarmersToolkit.SetFT(bagId, slotIndex) end)
		  	AddCustomMenuItem("Set Farming Type Target in chat", function() FarmersToolkit.SetFTT(bagId, slotIndex) end)
	  	end
	  end
	
	FTK_LCM:RegisterContextMenu(AddMenuEntry, FTK_LCM.CATEGORY_LATE)

	zo_callLater(function() d("FT: LibCustomMenu detected - GUI adjustments available (See: Settings, Add-on, FarmersTookit, Goals).") end, 9000)

end -- if LibCustomMenu 

  if TamrielTradeCentre then
	  dft("Detected TamrielTradeCentre - Excellent! Pricing data is available in chat if you choose.");
  end

-- Provide pricing via TTC data if Addon is present.  
-- Returns vary depending on available data
--    If TTC data is present
--    	If EntryCount > Threshhold, put " C~ #" to end of pricing info
--    	If SalesEntryCount > Threshhold, put " S~ #" to end of pricing info
--    	if Sales Average data is available, use it and mark as "TTC-avg"
--    	if Suggested Price data is available, use it and mark as "TTC-sug"
--    else if ZOS data is available and > 0, use it
function FarmersToolkit.PriceInfo(alink) 

     local retval = "";

     -- This is just a local var for now, it may become more useful over time (and thus a configurable var)
     local ThreshHold = 10; -- How many listings do we need before we erport the number of listings...

     if ( FarmersToolkit.priceDetails == false ) then return retval; end

     if TamrielTradeCentre then
	   local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(alink);
	   if ( type(priceInfo) ~= "nil" ) then -- We have received data from TTC!
		local unitStr=" G/each";
		if ( type(priceInfo.EntryCount) ~= "nil" ) then -- If we have enough data points
			if (priceInfo.EntryCount > ThreshHold ) then
				unitStr=" G (" .. comma_value(priceInfo.EntryCount) .. " entries)"; 
			end
		end
		if ( type(priceInfo.SaleEntryCount) ~= "nil" ) then -- If we have Sales data, use it instead
			if (priceInfo.SaleEntryCount > ThreshHold ) then
				unitStr=" G (" .. comma_value(priceInfo.SaleEntryCount) .. " sales)"; 
			end
		end
		if ( type(priceInfo.SaleAvg) ~= "nil" ) then
	   		-- dft_debug("TTC Returned SA datastructure = " .. type(priceInfo.SaleAvg) );
	   		-- dft_debug("TTC Returned SA price: " .. priceInfo.SaleAvg);
			retval = "TTC-avg: " .. comma_value(math.floor(priceInfo.SaleAvg)) .. unitStr;
		end
		if ( type(priceInfo.SuggestedPrice) ~= "nil" ) then
	   		-- dft_debug("TTC Returned SP datastructure = " .. type(priceInfo.SuggestedPrice) );
	   		-- dft_debug("TTC Returned SP price: " .. priceInfo.SuggestedPrice);
			retval = "TTC-sug: " .. comma_value(math.floor(priceInfo.SuggestedPrice)) .. unitStr;
		end
           end
     end

     if ( retval == "" ) then -- We have no data so default to ZOS
	     local icon, sellPrice, meetsUR, EQT, StyleID = GetItemLinkInfo(alink);
	   	-- dft_debug("ZOS Returned datastructure = " .. type(sellPrice) );
	   	-- dft_debug("ZOS Returned price: " .. sellPrice);
		if ( sellPrice > 0 ) then retval = "ZOS: " .. comma_value(sellPrice) .. " G/each"; end
     end
     return retval;

end -- FarmersToolkit.PriceInfo

