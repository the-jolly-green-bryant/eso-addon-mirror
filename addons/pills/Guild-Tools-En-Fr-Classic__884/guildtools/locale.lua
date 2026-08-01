--Author      : LintyDruid
--Localisation Control


-- use English as the base
guildtools.lang.sets.en()

function guildtools.lang.Set()
	
	local language = GetCVar("language.2")

	
	if (language== nil or language=="en") then  -- No language or en
		guildtools.lang.refresh()
		return;
	end
	
	
	
	if (language=="fr") then  -- fr
		guildtools.lang.sets.fr()
		guildtools.lang.refresh()
		return;
	end

	if (language=="de") then  -- fr
		guildtools.lang.sets.de()
		guildtools.lang.refresh()
		return;
	end
	
	guildtools.lang.refresh()
	
end

function guildtools.lang.refresh()

	
	


	
end
