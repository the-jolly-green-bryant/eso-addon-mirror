AUI_PRE_HOOK_SKIP_EXISTING_FUNCTION = -1

function AUI.PostHook(objectTable, existingFunctionName, hookFunction)
	if not objectTable or not existingFunctionName or not hookFunction then
		return
	end

    local existingFn = objectTable[existingFunctionName]
    if existingFn ~= nil and type(existingFn) == "function" then  	
		objectTable[existingFunctionName] = function(...)					
			existingFn(...)
			hookFunction(...)
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
			local ret = hookFunction(...)
			if not ret or ret ~= AUI_PRE_HOOK_SKIP_EXISTING_FUNCTION then
				return existingFn(...)
			end
		end
    end
end