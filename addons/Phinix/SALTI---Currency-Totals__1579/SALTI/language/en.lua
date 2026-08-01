local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
-- 
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
	L.SALTI_Title					= "SALTI (Currency Totals)"
	L.SALTI_PTitle					= "SALTI - Currency Totals"
	L.SALTI_GOpts					= "Global options"
	L.SALTI_COpts					= "Character status"
	L.SALTI_CCTrack					= "Track Character Currency"
	L.SALTI_CCTrackD				= "Track the current character\'s Gold, AP, Writ Vouchers, and Telvar Stones. Turning this off deletes this character\'s saved currency data."
	L.SALTI_TRACKWARN				= "WARNING: Will automatically reload the UI!"
	L.SALTI_IWPos					= "Use Independent Position"
	L.SALTI_IWPosD					= "When enabled, the location of the popup currency tooltip will be wherever the hotkey-toggled window was last positioned. Set a keybind or type /salti to show/hide SALTI to configure the window position."
	L.SALTI_SACIcon					= "Show Alliance/Class Icon"
	L.SALTI_SACIconD				= "Shows a colored icon next to each tracked character\'s name indicating their Class and the Alliance they belong to."
	L.SALTI_SGC						= "Show Global Currency"
	L.SALTI_SGCD					= "Display the summary of account-wide currencies under the standard totals."
	L.SALTI_GCS						= "Global Currency Spacing"
	L.SALTI_GCSD					= "Widen or shorten the space between Global Currency items."
	L.SALTI_ALPHAN					= "Alphabetize Name List"
	L.SALTI_ALPHAND					= "When enabled the tracked character currency list will be alphabetized. Otherwise the list of characters matches the order of your characters on the login screen."
	L.SALTI_SGBGold					= "Show Guild Bank Gold"
	L.SALTI_SGBGoldD				= "Show the summary of gold stored in your current guild banks in the gold summary tooltip (must visit each guild bank to populate/update gold values)."
	L.SALTI_DCChar					= "Delete Character\'s Data:"
	L.SALTI_DELETE					= "DELETE"
	L.SALTI_CDELD					= "Remove selected character from the tracking database. If you remove a still-existing character here, they will be automatically set to not track. Log in as the character and re-enable tracking under Character Options to re-add them to the database."

-- General Strings
	L.SALTI_BTotal					= "Banked:"
	L.SALTI_ATotal					= "Account Totals:"
	L.SALTI_SOURCE					= "SOURCE"
	L.SALTI_CGlobal					= "Global Totals:"
	L.SALTI_DBUpdate				= "SALTI database was reset this version.\nPlease log into each character to rebuild."
	L.SALTI_ETHeader				= "event tickets"

-- Icon Strings
--	L.SALTI_GOLD					= "|t16:16:/esoui/art/currency/gold_mipmap.dds|t"
	L.SALTI_GOLD					= "|t16:16:/esoui/art/currency/currency_gold.dds|t"
--	L.SALTI_TV						= "|t24:24:/esoui/art/currency/telvar_mipmap.dds|t"
	L.SALTI_TV						= "|t24:24:/esoui/art/hud/telvar_meter_currency.dds|t"
	L.SALTI_AP						= "|t16:16:/esoui/art/currency/alliancepoints_mipmap.dds|t"
--	L.SALTI_AP						= "|t16:16:/esoui/art/currency/alliancepoints.dds|t"
	L.SALTI_WV						= "|t16:16:/esoui/art/currency/writvoucher_mipmap.dds|t"
--	L.SALTI_WV						= "|t16:16:/esoui/art/icons/icon_writvoucher.dds|t"
	L.SALTI_CROWNS					= "|t16:16:/esoui/art/currency/crowns_mipmap.dds|t"
	L.SALTI_ESEALS					= "|t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
	L.SALTI_CGEMS					= "|t16:16:/esoui/art/currency/crowngem_mipmap.dds|t"
	L.SALTI_UKEYS					= "|t16:16:/esoui/art/currency/undauntedkey_mipmap.dds|t"
--	L.SALTI_UKEYS					= "|t16:16:/esoui/art/icons/undaunted_gold_key_01.dds|t"
	L.SALTI_AFORTUNES				= "|t16:16:/esoui/art/currency/archivalfragments_mipmaps.dds|t"
	L.SALTI_IFRAGMENTS				= "|t16:16:/esoui/art/currency/currency_imperial_trophy_key_mipmap.dds|t"
	L.SALTI_TGEMS					= "|t16:16:/esoui/art/currency/currency_seedcrystal_mipmap.dds|t"
--	L.SALTI_ETICKETS				= "|t16:16:/esoui/art/currency/currency_eventticket.dds|t"
	L.SALTI_ETICKETS				= "|t16:16:/esoui/art/currency/icon_eventticket_loot.dds|t"
	L.SALTI_OUTFIT					= "|t16:16:/esoui/art/currency/token_clothing_mipmap.dds|t"
--	L.SALTI_OUTFIT					= "|t16:16:/esoui/art/currency/token_clothing_16.dds|t"
	--L.SALTI_GOLD					= "|t24:24:/esoui/art/icons/item_generic_coinbag.dds|t"
	--L.SALTI_TV					= "|t24:24:/esoui/art/icons/icon_telvarstone.dds|t"
	--L.SALTI_AP					= "|t24:24:/esoui/art/icons/icon_alliancepoints.dds|t"


------------------------------------------------------------------------------------------------------------------

function SALTI:GetLanguage() -- default language, will be the return unless overwritten
	return L
end
