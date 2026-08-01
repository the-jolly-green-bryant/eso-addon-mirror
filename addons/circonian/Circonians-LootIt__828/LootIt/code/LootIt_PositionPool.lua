


--******************************************************************************--
----------------------------------------------------------------------------------
-- Cutom Position Pool Info 													--
----------------------------------------------------------------------------------
-- When I refer to position I am referring to what position an item takes in 	--
-- my main loot window. Here is an example, imagine it looks like this (items 	--
-- displayed on the screen, top down) in this order 							--
-- Position 6: free (nothing in it)												--
-- Position 5: "8 gold"															--
-- Position 4: free (nothing in it)												--
-- Position 3: "Uber sword of great power"										--
-- Position 2: "Tiny shard of glass"											--
-- Position 1: "Crappy armor made of paper"										--
--******************************************************************************--
-- Ok I admit this will probably be confusing, you'll probably be wondering 	--
-- WTF I was doing. There may have been a better way, but I couldn't think of 	--
-- one & I wasn't willing to compromise 										--
-- the way I wanted the animations to look...so it required all of this extra 	--
-- code. 																		--
----------------------------------------------------------------------------------
-- The idea of what were trying to do: 											--
----------------------------------------------------------------------------------
-- The idea is that I want items to fade in, one at a time, anchored to the 	--
-- bottom of the window (to start) and then translate up to their position 		--
-- (where they are supposed to be).	 That doesn't sound so bad, but unlike 		--
-- other addons I did not want to just keep scrolling up the window. Stacking 	--
-- more & more loot windows on top of each other...IF you continually looted a 	--
-- bunch of bodies with a bunch of items in a row...some items under neither 	--
-- may have all ready faded out and your probably thinking...big deal that's 	--
-- probably never going to happen or be extremely rare. 						--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- It was a challenge, & it was fun figuring it out ;P 							--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--[[ I got the idea from the ZO_ControlPool to create my own pool that contained all positions that are currently used (filled by an item) and then create my own pool controls to get the information I needed. I had hoped I could have used the built in ZO_ControlPool's keys, I was all ready using it to create each individual item loot window anyhow, but apparently it doesn't always use every number or always in order, so that didn't help. If there was some way to force it to do so, so I could have gotten the information I needed from it, I couldn't figure it out. If you know better, you could probably scrap all of this custom pool code, the ZO_ControlPool is all ready used to create the individual item windows
--]]
-----------------------------------------------------------------------------------
--[[ Below I briefly explain what I needed to do to solve the problem & the functions used for each part
------------------------------------------------------------------------------------
To prevent this problem I needed a way to answer the following questions:
------------------------------------------------------------------------------------
1) What is the last position in use (then the one after that is the next position free at the top of the list)?
function GetLastUsedPosition()
------------------------------------------------------------------------------------
2) How many free positions (empty, no longer have items, they faded out) are at the bottom? If the first position used is 5, that means there are 4 (the position # under it) positions free at the bottom.	
function GetFirstUsedPosition()	
------------------------------------------------------------------------------------
3a) How many free positions are in the middle? (Bottom items faded out and I put new items in the bottom positions, now there are empty positions in the middle)....can I fit the next set of loot in there? 
Which then lead to me needing to know: What is the first position free? 										--
function GetFirstFreePosition()		
																	--
3b) and what is the next position IN USE (has an item) AFTER that free position (so I could calculate how many free spots there were in the middle)?
function GetNextUsedAfter(_iPosition)																	--
------------------------------------------------------------------------------------
-- 4) When placing a "set" of loot (all loot in a single loot window) into my loot window, I WANTED to make The first item go at the top position and as items translate up the window they take lower & lower positions For several reasons..I thought it looked cooler than just putting the next loot item in the next free spot and this keeps the fadeouts for a set of loot in order, the top item will always fade out first (although its marginal) and they fade down the list...To do this required a lot more code. I cant just get the last free position & put the item there, & its not that simple Once I put the first item at the end of the list(+ number of loot items so they stack downwards)I can't use the same function to get that position any more, I no longer need the last used position+ number of loot items...so I needed to create another function to get the last free position (because I just put an item at the end of the list + number of loot items, so the one under it is the last free position. 			
function GetLastFreePosition()	
		---------------------------------------------------
Note: Not to be confused with function GetLastUsedPosition()	which I said the position after this is the free position at the TOP of the list. That may sound like the last free position, but I'm referring to the last free position still INSIDE of my list. Not going outside of my current list and creating a new higher position at the top.
------------------------------------------------------------------------------------
-- Got It ? No Problem Right ? :p																				--
------------------------------------------------------------------------------------

I will try to comment the first time something occurs ONLY (not to clog up this file anymore than I all ready have) in case you dont know what it is. 																		 --
--]]
------------------------------------------------------------------------------------
-- What is the last position in use (then the one after that is the next position free at the top of the list)? 
------------------------------------------------------------------------------------
local function GetLastUsedPosition()
	local iLastUsedPos = 0
	if #LootIt.lootPositionPool > 0 then	-- If the table size is not 0 (empty) --
		-- Sort it to guarantee my positions are in order with the keys --
		-- As in last key (last item in the table) is the highest position used (stored in the table) --
		-- Note: Unless told otherwise (I do in one function below) sort, sorts on the < operator (ascending) --
		table.sort(LootIt.lootPositionPool)	
		-- So the last position used is the last item in the table --
		iLastUsedPos = LootIt.lootPositionPool[#LootIt.lootPositionPool]
	end
	return iLastUsedPos
end

------------------------------------------------------------------------------------------------------------------
-- How many free positions (empty, no longer have items, they faded out) are at the bottom? If the first 		--
-- position used is 5, that means there are 4 (the position # under it) positions free at the bottom.			--
------------------------------------------------------------------------------------------------------------------
local function GetFirstUsedPosition()
	--local iPosition = GetLastUsedPosition()
	local iPosition = 0
	
	if #LootIt.lootPositionPool > 0 then
		table.sort(LootIt.lootPositionPool)
		-- After sorting: the first position used is the first position stored in the table --
		iPosition = LootIt.lootPositionPool[1]
	end
	
	return iPosition
end

------------------------------------------------------------------------------------------------------------------
-- How many free positions are in the middle? (bottom items faded out and I put new items in the bottom 		--
-- positions, now there are empty positions in the middle....can I fit the next set of loot in there? 			--
-- Which then lead to me needing to know: What is the first position free? 										--
------------------------------------------------------------------------------------------------------------------
local function GetFirstFreePosition()
	-- If the table is empty, the first free position is 1
	if #LootIt.lootPositionPool == 0 then return 1 end
	
	table.sort(LootIt.lootPositionPool)
	local lastUsedPos = 0
	
	for i=1, #LootIt.lootPositionPool do
		lastUsedPos = i
		if i ~= LootIt.lootPositionPool[i] then
			return i
		end
	end
	-- else the table is full, return the last position + 1
	return lastUsedPos+1
end

------------------------------------------------------------------------------------------------------------------
-- What is the next position IN USE (has an item) AFTER that free position (so I could calculate 				--
-- how many free spots there were in the middle)? 																--
------------------------------------------------------------------------------------------------------------------
local function GetNextUsedAfter(_iPosition)
	local iNextPositionUsed = 0
	-- If the table is empty, the first free position is 0
	if #LootIt.lootPositionPool == 0 then return iNextPositionUsed end
	
	table.sort(LootIt.lootPositionPool)
	
	-- Loop through table: if the current position v (remeber that is reffering to a position stored in the --
	-- table, which means it is in use) is greater than _iPosition then return it. --
	-- It is the first used position after _iPosition (remeber I sorted they are in order so it is the --
	-- first one I will come to in my loop. --
	for k,v in ipairs(LootIt.lootPositionPool) do
		if v  > _iPosition then
			return v
		end
	end
	-- else there are positions in the table, and we made it through the entire table, and none of the
	-- positions in the table were greater, which means this position is the last one in the table
	-- return the given position, there is no next used position.
	return _iPosition
end

--[[
4) When placing a "set" of loot (all loot in a single loot window) into my loot window, I WANTED to make The first item go at the top position and as items translate up the window they take lower & lower positions For several reasons..I thought it looked cooler than just putting the next loot item in the next free spot and this keeps the fadeouts for a set of loot in order, the top item will always fade out first (although its marginal) and they fade down the list...To do this required a lot more code. I cant just get the last free position & put the item there, & its not that simple Once I put the first item at the end of the list(+ number of loot items so they stack downwards) I can't use the same function to get that position any more, I no longer need the last used position+ number of loot items...so I needed to create another function to get the last free position (because I just put an item at the end of the list + number of loot items, so the one under it is the last free position. 
--]]
local function GetLastFreePosition()
	-- If the table is empty, the Last free position is 1
	if #LootIt.lootPositionPool == 0 then return 1 end

	-- Sort Position #'s descending
	table.sort(LootIt.lootPositionPool, 
		function(bvalue1, bvalue2)
			if bvalue1 > bvalue2 then 
				return true
			end
		end)
	
	for i = #LootIt.lootPositionPool, 1, -1 do 
		if i ~= LootIt.lootPositionPool[i] then
			return i
		end
	end
end

function LootIt.GetWindowPositions(_tLoot)
	local iNumItems = #_tLoot
	if iNumItems < 1 then return end 
	
	local iLastUsedPosition = GetLastUsedPosition()
	local iFirstPositionUsed = GetFirstUsedPosition()
	local iFirstPositionFree = GetFirstFreePosition()
	local iNextUsedPosition = GetNextUsedAfter(iFirstPositionFree)
	local iGapSize = (iNextUsedPosition - iFirstPositionFree)
	local iLootCounter = 1
	-- +3 is padding, extra blank window spaces so the loot windows don't get to close together.
	local iLootWindowPadding = 0
	
	-- If first position used is > num items left to position there's room at the beginning of the list --
	-- or if the first used position is 0, the list is empty, so there's room at the beginning of the list --
	if ((iFirstPositionUsed > (iNumItems+iLootWindowPadding)) or (iFirstPositionUsed == 0)) then
		for k,v in pairs(_tLoot) do
			v.position = iLootCounter
			table.insert(LootIt.lootPositionPool, iLootCounter)
			iLootCounter = iLootCounter + 1
		end
		
	-- if the 1st gap in the list is big enough put them in the middle. --
	elseif (iGapSize >= (iNumItems+iLootWindowPadding))then
		for k,v in pairs(_tLoot) do
			v.position = iFirstPositionFree + iLootCounter - 1
			table.insert(LootIt.lootPositionPool, v.position)
			iLootCounter = iLootCounter + 1
		end
	-- Else place them at the end --
	else
		for k,v in pairs(_tLoot) do
			v.position = iLastUsedPosition + iLootCounter
			table.insert(LootIt.lootPositionPool, v.position)
			iLootCounter = iLootCounter + 1
		end
	end
	return _tLoot
end

