local strings = {
	SI_CBFS_UI_PREVIEW_TITLE_COMMON =	"Book Title", 
	SI_CBFS_UI_PREVIEW_BODY_COMMON =	"five dancing skooma cats jump quickly to the wizard's box.\nABCDEFGHIJKLMNOPQRSTUVWXYZ\n1234567890\n\n", 


	SI_CBFS_UI_SHOW_READER_WND_NAME =	"Preview", 
	SI_CBFS_UI_SHOW_READER_WND_TIPS =	"Preview your book font settings", 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
--	The following does not require translation. Instead, you are free to write something like a pangram that is useful for checking fonts in your language.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
	SI_CBFS_UI_PREVIEW_BODY_LOCALE =	"Six big juicy steaks sizzled in a pan as five workmen left the quarry.\n\n", 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
--	The following two are the title and text of the 'dummy' book using on the Lore Reader preview screen. 
--	You can replace these texts with something else in your language, but please take care never cause any copyright problems.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
	SI_CBFS_UI_PREVIEW_BOOK_TITLE = 	"Lorem Ipsum", 
	SI_CBFS_UI_PREVIEW_BOOK_BODY =		"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", 
}

for stringId, stringToAdd in pairs(strings) do
   ZO_CreateStringId(stringId, stringToAdd)
   SafeAddVersion(stringId, 1)
end
