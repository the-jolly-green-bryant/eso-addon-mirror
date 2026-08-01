-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	function ImmersiveFunctions.UnregisterHandlers()
		local em = EVENT_MANAGER
		local ns = "ImmersiveInteractions"

		em:UnregisterForEvent(ns, EVENT_CHATTER_BEGIN)
		em:UnregisterForEvent(ns, EVENT_CONVERSATION_UPDATED)
		em:UnregisterForEvent(ns, EVENT_QUEST_OFFERED)
		em:UnregisterForEvent(ns, EVENT_QUEST_COMPLETE_DIALOG)
		em:UnregisterForEvent(ns, EVENT_CHATTER_END)
	end
end
