local strings = {
	SI_PBSNPC_EXPLANATION = "The game draws the overhead nametag itself, so the order of the title, character name and <guild> lines cannot be changed by an add-on. What can be changed is the font: size, face and outline.",

	SI_PBSNPC_ENABLED = "Custom nametag font",
	SI_PBSNPC_ENABLED_TOOLTIP = "Apply the font below to the names above characters' heads. Turn this off to hand the game's own font straight back.",

	SI_PBSNPC_SIZE = "Text size",
	SI_PBSNPC_SIZE_TOOLTIP = "Size of the text above characters' heads.",

	SI_PBSNPC_FACE = "Typeface",
	SI_PBSNPC_FACE_TOOLTIP = "Which of the game's own faces to use. Changing to a face the client has not loaded yet reloads the interface -- the game has to build the font, and that is unavoidable. Text size and outline never reload. Default keeps the face the game picked, which is also the safest choice in every language. Only faces the UI already has loaded are offered: any other has to be built when it is set, and on console that build is billed to the pool add-ons share and crashes the add-on. Several entries resolve to the same file in some languages -- in Japanese, Interface (medium), Interface (bold) and Console (light) are one gothic face.",
	SI_PBSNPC_FACE_DEFAULT = "Default",
	SI_PBSNPC_FACE_GAMEPAD_MEDIUM = "Console (medium)",
	SI_PBSNPC_FACE_GAMEPAD_BOLD = "Console (bold)",
	SI_PBSNPC_FACE_GAMEPAD_LIGHT = "Console (light)",
	SI_PBSNPC_FACE_MEDIUM = "Interface (medium)",
	SI_PBSNPC_FACE_BOLD = "Interface (bold)",

	SI_PBSNPC_STYLE = "Outline",
	SI_PBSNPC_STYLE_TOOLTIP = "How the text is separated from the scenery behind it. A thicker outline stays readable against bright ground. WARNING: outline styles make the client build outline glyphs, and the game's own source puts that at about 100 MB for a CJK font -- the same size as the whole memory pool console add-ons share. If the game becomes unstable, leave this on Default.",
	SI_PBSNPC_STYLE_DEFAULT = "Default",
	SI_PBSNPC_STYLE_NORMAL = "None",
	SI_PBSNPC_STYLE_SHADOW = "Shadow",
	SI_PBSNPC_STYLE_SOFT_SHADOW_THIN = "Soft shadow (thin)",
	SI_PBSNPC_STYLE_SOFT_SHADOW_THICK = "Soft shadow (thick)",
	SI_PBSNPC_STYLE_OUTLINE = "Outline",
	SI_PBSNPC_STYLE_OUTLINE_THICK = "Outline (thick)",
	SI_PBSNPC_STYLE_OUTLINE_SHADOW = "Outline and shadow",

	SI_PBSNPC_REAPPLY_FACE = "Keep typeface after loading screens",
	SI_PBSNPC_REAPPLY_FACE_TOOLTIP = "The client drops the nameplate font at every loading screen, so it has to be written again after each one. Writing the size back is free; writing the typeface and outline back makes the client build the font again, and on console that is billed to the 100 MB pool every add-on shares -- measured to kill the add-on within a few zone changes. Off: the typeface and outline last until the next loading screen, then only your text size is kept. On: they are kept too, at that risk.",
	SI_PBSNPC_RESET = "Reset",
	SI_PBSNPC_RESET_TOOLTIP = "Put every setting above back to its default.",
	SI_PBSNPC_RESET_BUTTON = "Reset",

	SI_PBSNPC_GAME_SETTINGS_HINT = "Whether the title line and the <guild> line appear at all is the game's own setting, under Settings > Nameplates (Show Title / Show Guild). An add-on cannot change those, so set them there.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
