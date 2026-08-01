--///////////////////////////////////////////////////////////////////////////////
--Debug

function DA.log(x)
	if (DA.savedVariables.Debug) then
		d("|cAAAAAA["..x.."]|r")
	end
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--Utility functions

function DA.tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-------------------------------------------------------

function DA.GetNearestIndex(table, numberToCompareTo)
	local smallestSoFar, smallestIndex
    for key, value in ipairs(table) do
	--if not smallestSoFar or (math.abs(numberToCompareTo - value.amount) < smallestSoFar) then
		--	smallestSoFar = math.abs(numberToCompareTo - value.amount)
		if not smallestSoFar or (math.abs(numberToCompareTo - value) < smallestSoFar) then
			smallestSoFar = math.abs(numberToCompareTo - value)
			smallestIndex = key
		end
    end
    --return smallestIndex, table[smallestIndex]
	return smallestIndex
end