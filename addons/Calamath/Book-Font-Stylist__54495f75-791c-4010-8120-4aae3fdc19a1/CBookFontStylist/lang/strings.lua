local strings = {
	-- Formatter
	SI_CBFS_UI_TAB_HEADER_FORMATTER =	"<<1>> :", 

	SI_CBFS_BOOK_MEDIUM0 =		"Unknown Book", 
	SI_CBFS_BOOK_MEDIUM1 =		"Yellowed Paper Book", 
	SI_CBFS_BOOK_MEDIUM2 =		"Animal Skin Book", 
	SI_CBFS_BOOK_MEDIUM3 =		"Rubbing Book", 
	SI_CBFS_BOOK_MEDIUM4 =		"Letter", 
	SI_CBFS_BOOK_MEDIUM5 =		"Note", 
	SI_CBFS_BOOK_MEDIUM6 =		"Scroll", 
	SI_CBFS_BOOK_MEDIUM7 =		"Stone Tablet", 
	SI_CBFS_BOOK_MEDIUM8 =		"Dwemer Book", 
	SI_CBFS_BOOK_MEDIUM9 =		"Dwemer Page", 
	SI_CBFS_BOOK_MEDIUM10 =		"Wood Elven Scroll", 
	SI_CBFS_BOOK_MEDIUM11 =		"Bloody Paper Book", 
	SI_CBFS_BOOK_MEDIUM1001 =	"Antiquity Codex", 

	SI_CBFS_FONT_STYLE0 =		"normal", 
	SI_CBFS_FONT_STYLE1 =		"shadow", 
	SI_CBFS_FONT_STYLE2 =		"outline", 
	SI_CBFS_FONT_STYLE3 =		"thick-outline", 
	SI_CBFS_FONT_STYLE4 =		"soft-shadow-thin", 
	SI_CBFS_FONT_STYLE5 =		"soft-shadow-thick", 
	SI_CBFS_FONT_STYLE6 =		"outline-shadow", 
	SI_CBFS_FONT_STYLE7 =		"outline-shadow-thick", 

	SI_CBFS_UI_PANEL_HEADER_TEXT =		"This add-on allows you to adjust the typeface of several in-game reading materials. Settings are saved per language mode and applied across your entire account.", 
	SI_CBFS_UI_BMID_SELECT_MENU =		"Select Book Medium", 
	SI_CBFS_UI_BMID_SELECT_MENU_TIPS =	"First, please select the type of book medium you want to configure.", 
	SI_CBFS_UI_BODYFONT_FACE_MENU = 	"Body Font Face", 
	SI_CBFS_UI_BODYFONT_SIZE_MENU = 	"Body Font Size", 
	SI_CBFS_UI_BODYFONT_STYLE_MENU =	"Body Font Style", 
	SI_CBFS_UI_TITLE_FONT_FACE_MENU =	"Title Font Face", 
	SI_CBFS_UI_TITLE_FONT_SIZE_MENU =	"Title Font Size", 
	SI_CBFS_UI_TITLE_FONT_STYLE_MENU =	"Title Font Style", 
	SI_CBFS_UI_FONT_FACE_MENU_TIPS =	"Specify your prefered font face.", 
	SI_CBFS_UI_FONT_SIZE_MENU_TIPS =	"Specify your prefered font size.", 
	SI_CBFS_UI_FONT_STYLE_MENU_TIPS =	"Specify your prefered font style.", 
	SI_CBFS_UI_LOAD_DEFAULT_FONT_NAME = "Default Font", 
	SI_CBFS_UI_LOAD_DEFAULT_FONT_TIPS = "Restore settings on this medium to the in-game default font. The default font depends on whether you are in gamepad mode.", 
}

for stringId, stringToAdd in pairs(strings) do
   ZO_CreateStringId(stringId, stringToAdd)
   SafeAddVersion(stringId, 1)
end
