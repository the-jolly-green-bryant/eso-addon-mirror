local ADDON = DefaultLanguageNinja

--------
-- in this file local use, private
--------

local waitSecs = 2

local function lazyReloadUI()
	zo_callLater(
		function()
			ReloadUI()
		end,
		waitSecs * 1000
	)
end

--------
-- in this ADDON use, protected
--------

ADDON.LoadLangCode = function(langCode, immediate)
	ADDON.develop("LoadLangCode")

	local done = nil

	local disabledOnceWhenNextReloading = ADDON.SaveData.DisabledOnceWhenNextReloading
	ADDON.SaveData.DisabledOnceWhenNextReloading = false

	if (immediate) then
		ADDON.d("update immediately.")
	else
		if (ADDON.GetElapsedSecondsFromLastAccess() < 60 * ADDON.SaveData.LoadingAfterThisMinutes) then
			ADDON.d("not elapsed enough time.")
			done = false
		end
	end

	if (done == nil) then
		local clientLangCode = string.lower(GetCVar("language.2"))

		done = false
		if (clientLangCode ~= langCode) then
			if (disabledOnceWhenNextReloading) then
				ADDON.d("disabled Once When Next Reloading.")
			else
				-- not reloadui. reloadui will be called by parent functions.
				ADDON.d("lang code will be updated.")
				SetCVar("language.2", langCode)

				done = true
			end
		else
			ADDON.d("lang code not changed.")
		end
	end

	ADDON.UpdateLastAccess()
	ADDON.UpdateLastLangCode()

	return done
end

ADDON.LoadDefaultLangCode = function(immediate)
	ADDON.develop("LoadDefaultLanguage")

	local done = false
	local defaultLangCode = ADDON.GetDefaultLangCode()
	if (defaultLangCode) then
		done = ADDON.LoadLangCode(defaultLangCode, immediate)
	else
		ADDON.develop("defaultLangCode doesn't set.")
	end

	return done
end

ADDON.LoadLangCodeAndReload = function(langCode)
	if (ADDON.LoadLangCode(langCode, true)) then
		ADDON.d("lang code updated. now reload ui.")
		ADDON.SaveData.DisabledOnceWhenNextReloading = true
		lazyReloadUI()
	end
end

ADDON.LoadDefaultLangCodeAndReload = function(immediate)
	if (ADDON.LoadDefaultLangCode(immediate)) then
		ADDON.d("lang code updated. now reload ui.")
		lazyReloadUI()
	end
end
