BCUI.Panel.Initialize = function()
	if BCUI.Vars.SidebarCompanion>1 then
		if BCUI.Vars.SidebarCompanion==BCUI.Menu.AllCompanions then
			local ownedCompanions = {}
		    for i, data in pairs(BCUI.CompanionInfo) do
		        if i~="activeId" and BCUI.CompanionInfo[i].unlocked then table.insert(ownedCompanions,{
		        	icon    =BCUI.CompanionInfo[i].icon,
		        	unlocked=BCUI.CompanionInfo[i].unlocked,
		        	tooltip =BCUI.CompanionInfo[i].name,
		        	func    =function() if BCUI.Vars.SidebarCompanion~=1 then BCUI.Binds.SummonCompanion(BCUI.CompanionInfo[i]) end end,
		        	enabled =function() return BCUI.Vars.SidebarCompanion~=1 end,
		        }) end
		    end
	  		BUI.PanelAdd(ownedCompanions)
		else
			BUI.PanelAdd({
				{	
					icon	= BCUI.Vars.CompanionIcon,
					tooltip	= BCUI.Loc("Companion"),
					func	= function() BCUI.Binds.SummonCompanionByIndex(BCUI.Vars.SidebarCompanion) end,
					enabled	= function() return BCUI.Vars.SidebarCompanion~=1 end,
				}
			})
		end
	end
end