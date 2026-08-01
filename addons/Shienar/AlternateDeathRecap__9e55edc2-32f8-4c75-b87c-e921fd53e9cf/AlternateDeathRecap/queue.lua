ADR = ADR or {}

ADR.attackList = {
	data = {},
	front = 1,
	back = 0,
	size = 0,
}

function ADR.Reset()
	ADR.attackList = {
		data = {},
		front = 1,
		back = 0,
		maxAttacks = function() return ADR.savedVariables.maxAttacks end,
		size = 0,
	}
end

function ADR.DequeueAttack()
	if ADR.attackList.size == 0 then return nil end
	
	local attack = ADR.attackList.data[ADR.attackList.front]
	ADR.attackList.size = ADR.attackList.size - 1
	ADR.attackList.data[ADR.attackList.front] = nil
	ADR.attackList.front = (ADR.attackList.front%ADR.savedVariables.maxAttacks) + 1
	
	return attack
end

function ADR.EnqueueAttack(attack)
	while ADR.attackList.size >= ADR.savedVariables.maxAttacks do
		ADR.DequeueAttack()
	end
	
	ADR.attackList.size = ADR.attackList.size + 1
	ADR.attackList.back = (ADR.attackList.back%ADR.savedVariables.maxAttacks) + 1
	ADR.attackList.data[ADR.attackList.back] = attack
end

function ADR.Peek()
	if ADR.attackList.size == 0 then return nil end
	
	return ADR.attackList.data[ADR.attackList.front]
end

--[[
Create a copy of the queue that the code in the main file will read from.
Doesn't modify the original queue.
Format.
	Smaller indexes: Oldest Attack
	Highest Index: Newest Attack
]]
function ADR.GetOrderedList()
	local returnedList = {}
	local returnedListIndex = 1
	local currentQueueIndex = ADR.attackList.front
	
	for i = 1, ADR.attackList.size do
		returnedList[returnedListIndex] = ADR.attackList.data[currentQueueIndex]
		returnedListIndex = returnedListIndex + 1
		currentQueueIndex = (currentQueueIndex%ADR.savedVariables.maxAttacks) + 1
	end
	
	return returnedList
end