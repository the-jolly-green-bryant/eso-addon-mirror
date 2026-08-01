local ADDON_NAME = 'GridList'

_G[ADDON_NAME] = {
	-- [1] = {}, -- SV, SavedVars
	-- [2] = {}, -- FN, functions
	-- [3] = {}, -- G, globals constants
	-- [4] = {}, -- L, localization
	-- [5] = {}, -- P, Plugins
}

local GL = GridList

-- local SV, FN = unpack(_G[ADDON_NAME])

GL.Empty = PP and PP.Empty or function() end
local empty = GL.Empty

function GL.PostHooksSetupCallback(list, mode, typeId, onCreateFn, onUpdateFn)
	local dataType = list.dataTypes[typeId]
	if not dataType then return end

    local hooks = dataType.hooks or {}

	if not dataType.hooks then
		for m = 1, 3 do
			hooks[m] = { OnCreate = empty, OnUpdate = empty }
		end

		dataType.hooks = hooks

		local pool				= dataType.pool
		local _customFactory	= pool.customFactoryBehavior
		local _setupCallback	= dataType.setupCallback

		if _customFactory then
			pool.customFactoryBehavior = function(...)
				_customFactory(...)
				hooks[list.mode].OnCreate(...)
			end
		else
			pool.customFactoryBehavior = function(...)
				hooks[list.mode].OnCreate(...)
			end
		end

		dataType.setupCallback = function(...)
			_setupCallback(...)
			hooks[list.mode].OnUpdate(...)
		end
	end

	local modeHooks = hooks[mode]
	local _OnCreate = modeHooks.OnCreate
	local _OnUpdate = modeHooks.OnUpdate

	if onCreateFn then
		modeHooks.OnCreate = _OnCreate == empty and onCreateFn or function(...)
			_OnCreate(...)
			onCreateFn(...)
		end
	end

	if onUpdateFn then
		modeHooks.OnUpdate = _OnUpdate == empty and onUpdateFn or function(...)
			_OnUpdate(...)
			onUpdateFn(...)
		end
	end
end