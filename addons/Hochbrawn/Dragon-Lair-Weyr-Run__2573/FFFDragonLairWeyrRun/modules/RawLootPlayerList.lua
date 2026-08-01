RawLootPlayerList = ZO_Object:Subclass()

function RawLootPlayerList:New()
    local playerList = ZO_Object.New(self)
    playerList:Init()
    return playerList
end

function RawLootPlayerList:Init()
	self.players = {}
end

function RawLootPlayerList:RawLootPlayerList()
	return self.players
end



function RawLootPlayerList:Add(atPlayerName)
	
	-- if the atPlayerName is not in our list of items then create a new one.
	-- atPlayerName is the key and the rawlootplayer is the value
    if self.players[atPlayerName] == nil then
		-- our list of items are class items from Item.lua
        self.players[atPlayerName] = RawLootPlayer:New(atPlayerName)
    end

    local player = self.players[atPlayerName] -- item is the specific item being added
   	
	return player
end



	




