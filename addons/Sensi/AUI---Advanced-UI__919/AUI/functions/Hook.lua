function AUI.PostHook(objectTable, existingFunctionName, hookFunction)
	if not objectTable or not existingFunctionName or not hookFunction then
		return
	end

    local existingFn = objectTable[existingFunctionName]
    if existingFn ~= nil and type(existingFn) == "function" then  	
		objectTable[existingFunctionName] = function(...)					
			local existingFnReturn = existingFn(...)
			hookFunction(...)
			
			return existingFnReturn
		end
    end
end

function AUI.PreHook(objectTable, existingFunctionName, hookFunction)
	if not objectTable or not existingFunctionName or not hookFunction then
		return
	end

    local existingFn = objectTable[existingFunctionName]
    if existingFn ~= nil and type(existingFn) == "function" then  	
		objectTable[existingFunctionName] = function(...)	
			hookFunction(...)
			return existingFn(...)
		end
    end
end