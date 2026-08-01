-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	local ns	= "ImmersiveInteractions"
	local em	= EVENT_MANAGER

	function ImmersiveFunctions.AddonEnable()
		local IMF = ImmersiveFunctions

		IMF.RegisterHandlers()
		IMF.InitGameMode()
		IMF.InitXML()
		IMF.InitBindings()

		-- handle UI related mouse behavior
		ZO_PreHookHandler(ImmersiveData.handles["TargetAreaTitle"], "OnMouseUp", IMF.ForceShowText)
	end

	function ImmersiveFunctions.AddonDisable()
		local IMF = ImmersiveFunctions

		IMF.UnregisterHandlers()
		IMF.CleanUpAll()
	end

	local function init(ec, name)
		if name ~= ImmersiveData.addonInfo.name then return end
		em:UnregisterForEvent(ns, EVENT_ADD_ON_LOADED)

		local IMF = ImmersiveFunctions

		IMF.InitializeData()
		IMF.LoadSavedVariables()
		IMF.SetupControl()					-- LibAddonMenu-2.0r25

		-- check that addon isn't soft disabled
		if IMF.GetSetting("bEnabled") then
			IMF.AddonEnable()
		else
			IMF.AddonDisable()
		end
	end

	-- register entry point
	em:RegisterForEvent(ns, EVENT_ADD_ON_LOADED, init)
end
