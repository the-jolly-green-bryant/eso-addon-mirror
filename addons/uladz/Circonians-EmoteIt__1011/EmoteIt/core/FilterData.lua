
EmoteIt = EmoteIt or {}

ZO_CreateStringId("SI_BINDING_NAME_EMOTEIT_BTN_FAVORITES", "Favorite Emotes")
ZO_CreateStringId("SI_BINDING_NAME_EMOTEIT_BTN_ALL", "All Emotes")
ZO_CreateStringId("SI_BINDING_NAME_EMOTEIT_BTN_SCRIPTS", "All Triggers")


function EmoteIt_ChangePanel(self, button)
	local categoryId 	= self.m_object:GetDescriptor()
	
	EmoteIt:UpdateMainListByCategory(categoryId)
end

EmoteIt.filterData = {
	[1] = {
		normal 			= "EmoteIt/textures/Slash.dds",
		pressed 		= "EmoteIt/textures/Slash_Pressed.dds",
		highlight	 	= "EmoteIt/textures/Slash_Over.dds",
		disabled		= "EmoteIt/textures/Slash.dds",
		tooltip		 	= SI_BINDING_NAME_EMOTEIT_BTN_ALL,
		descriptor		= EMOTEIT_CATEGORY_ALL,
		panel			= "slashCommands",
		callback	 	= ChangePanel,
	},
	[2] = {
		normal 			= "EmoteIt/textures/Favorites.dds",
		pressed 		= "EmoteIt/textures/Favorites_Pressed.dds",
		highlight	 	= "EmoteIt/textures/Favorites_Over.dds",
		disabled		= "EmoteIt/textures/Favorites.dds",
		tooltip		 	= SI_BINDING_NAME_EMOTEIT_BTN_FAVORITES,
		descriptor		= EMOTEIT_CATEGORY_FAVORITES,
		panel			= "favorites",
		callback	 	= ChangePanel,
	},
	[3] = {
		normal 			= "EmoteIt/textures/Script.dds",
		pressed 		= "EmoteIt/textures/Script_Pressed.dds",
		highlight	 	= "EmoteIt/textures/Script_Over.dds",
		disabled		= "EmoteIt/textures/Script.dds",
		tooltip		 	= SI_BINDING_NAME_EMOTEIT_BTN_SCRIPTS,
		descriptor		= EMOTEIT_CATEGORY_TRIGGERS,
		panel			= "scripts",
		callback	 	= ChangePanel,
	},
}
