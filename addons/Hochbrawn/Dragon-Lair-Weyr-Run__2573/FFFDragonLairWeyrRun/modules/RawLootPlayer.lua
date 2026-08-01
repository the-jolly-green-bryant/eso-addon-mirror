RawLootPlayer = ZO_Object:Subclass()
-- this is to be the raw loot transaction to store in saved variables
-- transaction would be updated per player and per loot item. ie quantities would increase not repeat entreies
-- when restoring these transactions would be reapplied restoring the state prior to reload or crash 
function RawLootPlayer:New(atPlayerName)
    local player = ZO_Object.New(self)
    player:Init(atPlayerName)
    return player
end

function RawLootPlayer:Init(atPlayerName)
    --self.AtPlayerName = atPlayerName
	-- create empty rawlootlist for player
    self.rawLootList = RawLootList:New()
	
end
