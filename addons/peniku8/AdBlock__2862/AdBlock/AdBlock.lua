if not AdBlock then AdBlock = {} end
local AB = AdBlock
local em = GetEventManager()

AB.name = "AdBlock"
AB.version = "1.3.7"
AB.settings = {}
AB.defaults = {
	loot = false,
	guild = false,
	crown = false,
	items = false,
	nTrial = false,
	vTrial = false,
	web = false,
	self = false,
}
  
	
	
  
	function AB.spamFilter(_, eventId, chatRoom, fromName, rawMessageText)
		
		if eventId ~= EVENT_CHAT_MESSAGE_CHANNEL then return end
		
		if not (chatRoom==0 or chatRoom==31 or chatRoom==1 or chatRoom == 32) then return end

		if GetCharacterInfo() == fromName and AB.settings.self then return end
		
		local text = zo_strlower(rawMessageText)
		
		
		
		if AB.settings.loot then
			--Check1
  		local strings1 = {":achievement:", ":collectible:", "skyreach"}
      local strings2 = {"carry", "carri", "loot", "gear", "skin", "personality", "achievement", "skyreach run"}
      local strings3 = {"wts", "sell", "want", "hire", "gold", "get", "buy"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  						for _, keyword in ipairs(strings3) do
  							if zo_strfind(text, keyword) then
  				        return true
  				      end
  				    end
  				  end
  				end
  			end
  		end
  		
  		--Check2
  		local strings1 = {":achievement:", ":collectible:"}
      local strings2 = {"wts", "sell"}
      
  		for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  		        return true
  		      end
  		    end
  		  end
  		end
		end
  	
  	
  	
		if AB.settings.guild then
  		local strings1 = {":guild:"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  			  return true
  			end
  		end
  	end
  	
  	
  	
		if AB.settings.crown then
  		local strings1 = {"crown"}
      local strings2 = {"wts", "wtb", "sell", "buy"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  				    return true
  				  end
  				end
  			end
  		end
		end
  	
  	
  	
		if AB.settings.items then
  		local strings1 = {"h1:item:", "h0:item:", "cod"}
      local strings2 = {"wts", "wtb", "wtt", "sell", "buy"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  				    return true
  				  end
  				end
  			end
  		end
		end
		
		
		
		if AB.settings.nTrial then
  		local strings1 = {"lf"}
      local strings2 = {"ntrial", "ntrail", "nhrc", "naa", "nso", "ndsa", "nmol", "nhof", "nas", "ncr", "nbrp", "nss", "nka", "nrg", "ndr", "ndsr", "nse"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  				    return true
  				  end
  				end
  			end
  		end
		end
		
		
		
		if AB.settings.vTrial then
  		local strings1 = {"lf"}
      local strings2 = {"vtrial", "vtrail", "vhrc", "vaa", "vso", "vdsa", "vmol", "vhof", "vas", "vcr", "vbrp", "vss", "vka", "vrg", "vdr", "vdsr", "vse"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				for _, keyword in ipairs(strings2) do
  					if zo_strfind(text, keyword) then
  				    return true
  				  end
  				end
  			end
  		end
		end
		
		
		
		if AB.settings.web then
  		local strings1 = {"www.", "https://", "http://"}
      
  	  for _, keyword in ipairs(strings1) do
  			if zo_strfind(text, keyword) then
  				return true
  			end
  		end
		end
		
	end




function AB.Initialize(event, addon)
	
	if addon ~= AB.name then return end
	
	em:UnregisterForEvent("AdBlockInitialize", EVENT_ADD_ON_LOADED)
	
	AB.settings = ZO_SavedVars:NewAccountWide("AdBlockSavedVars", 1, nil, AB.defaults)
  
	AB.MakeMenu()
  
	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", AB.spamFilter)
  
end

em:RegisterForEvent("AdBlockInitialize", EVENT_ADD_ON_LOADED, function(...) AB.Initialize(...) end)