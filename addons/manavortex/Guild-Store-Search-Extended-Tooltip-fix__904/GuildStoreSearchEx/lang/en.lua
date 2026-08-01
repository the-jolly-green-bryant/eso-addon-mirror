function gsse.lang.sets.en()

	---Icon Strings
	gsse.lang.core.icon_template="|t16:16:%s|t" --- icon path
	gsse.lang.core.icon_template1="|t32:32:%s|t" --- icon path
	gsse.lang.core.icon_template2="|t8:8:%s|t" --- icon path
	
	gsse.lang.core.icon_gold=string.format(gsse.lang.core.icon_template,"EsoUI/Art/currency/currency_gold.dds")
	gsse.lang.core.icon_gstorecoins=string.format(gsse.lang.core.icon_template,"/esoui/art/guild/guild_tradinghouseaccess.dds")
	gsse.lang.core.icon_gstoreold=string.format(gsse.lang.core.icon_template,"/esoui/art/buttons/edit_cancel_down.dds")

	--- General Strings

	gsse.lang.core.addonName="Guild Store Search Extended";
    gsse.lang.core.coloredAddonName="|c2080D0Guild Store Search|r |cffffc0Extended|r"; --added 0.11
	
	
	----Config------
	
	gsse.lang.config_filt_markdown_lbl="Discount items by (%)"
	gsse.lang.config_filt_markdown_tip="The recommended undercut price will be reduced by the percentage set here."
	
	--- GUI -----------------
	
	gsse.lang.gui.reset_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/inventory/inventory_tabicon_junk_up.dds").."Reset"
	gsse.lang.gui.rtrv_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_trade_up.dds").."Retrieve"
	gsse.lang.gui.find_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Find Match"
	gsse.lang.gui.close_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_cancel_up.dds").."Close"
	gsse.lang.gui.searchfor_lbl="Search For:"
	gsse.lang.gui.guild_lbl="From Guild:"
	gsse.lang.gui.col_price_hdr="Total"
	gsse.lang.gui.col_unit_hdr="Each"
	
	gsse.lang.gui.main_cmd=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Guild Store Search"
	--- Dynamics
	
	gsse.lang.gui.res_label=gsse.lang.core.icon_template.." |cE0FFE0%s|r [|c%s%s|r]|cffff00 x %s|r" -- icon, guild no., color, name label, count
	gsse.lang.gui.res_price="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_unitprice="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_buy=gsse.lang.core.icon_gstorecoins.."Show"
	gsse.lang.gui.res_buy_off=gsse.lang.core.icon_gstoreold.."|ccc0000Old|r" --added 0.06
	
	local working=string.format(gsse.lang.core.icon_template1,"/esoui/art/ava/ava_resourcestatus_tabicon_production.dds")
	local complete=string.format(gsse.lang.core.icon_template1,"/esoui/art/characterwindow/sigil_stamina.dds")
	
	gsse.lang.gui.searchpause="Getting next page in %s seconds..."
	gsse.lang.gui.searchproc="Processing page..."
	gsse.lang.gui.searchready="|c00ff00Ready to search.|r"
	
	gsse.lang.gui.search=working.."Searching Guild |c00ffff%s|r, page |c00ffff%s|r" -- guild, page
	gsse.lang.gui.found=complete.."Found |c00ffff%s|r items from Guild |c00ffff%s|r" -- items, guild
	gsse.lang.gui.retrv=working.."Retrieving from Guild |c00ffff%s|r, page |c00ffff%s|r" -- guild, page
	gsse.lang.gui.foundall=complete.."Found |c00ffff%s|r items from all |c00ffffguilds|r " -- items
	gsse.lang.gui.searchStarte=working.."Starting Search..."
	gsse.lang.gui.searchBusy=working.."|cff0000Guild Store Search Ex is busy searching, please wait."
	gsse.lang.gui.searchNoGS=gsse.lang.core.icon_gstoreold.."|cff0000Guild Store must be open to retrieve results."
	
	
	gsse.lang.gui.noTradingGuilds="|cff0000There are no guild stores!|r"
	gsse.lang.gui.notATradingGuild="|cff0000Guild %s does not have a guild store!|r"
	
	gsse.lang.gui.guild_all="|c00cc00All"
	gsse.lang.gui.guild_templ="G%s: %s%s" --Guild Num, color, Guild Name
	
	gsse.lang.gui.search_summ= "%s matches. Unit Price (Max/Min/Avg/Undercut):|cff0000%s|r/|cff8000%s|r/|cfff000%s|r/|c00ff00%s|r%s" -- Max, Min, Avg, Undercut, Sell for price
	
	gsse.lang.gui.search_summsell=". Sell |cff00ff%s|r @ |cffc000%sg.|r"
	
	-- Config
    gsse.lang.config.gen_hdr="General settings" --added 0.11
	gsse.lang.config.gen_dbg_lbl="Debug Mode?"
	gsse.lang.config.gen_dbg_tip="Display debug messages?"
	gsse.lang.config.gen_dbg_warn="This will place lots of text in your chat window!"
	
	gsse.lang.config.tooltip_hdr="Tooltips" --added 0.06
	gsse.lang.config.tooltip_desc="These setting configure what data is shown in item tooltips." --added 0.06
	gsse.lang.config.tooltip_session_lbl="Show session summary?" --added 0.06
	gsse.lang.config.tooltip_session_tip="If on, this will show a summary of the item sale data found for the item in the current session.  This data is broken down by guild." --added 0.06
	gsse.lang.config.tooltip_history_lbl="Show history summary?" --added 0.06
	gsse.lang.config.tooltip_history_tip="If on, this will show a summary of the item sale data found for the item across all sessions/characters.  This data is broken down by guild." --added 0.06
	gsse.lang.config.tooltip_recom_lbl="Show recommendations?" --added 0.06
	gsse.lang.config.tooltip_recom_tip="If on, a recommendation of where and how much to sell and buy and item for." --added 0.06
	
	gsse.lang.config.lang_lbl="Language" --added 0.09
	gsse.lang.config.lang_tip="Select the language to be used. 'Auto' will use the language detected in the game." --added 0.09
	gsse.lang.config.lang_warn="You must logout or reload the UI (/reloadui) for this setting to be applied." --added 0.09
	
	
	--- Tooltips
	
	gsse.lang.gui.tt_line= "%s: |cff0000%s"..gsse.lang.core.icon_gold.."|r/|cff8000%s"..gsse.lang.core.icon_gold.."|r/|cfff000%s"..gsse.lang.core.icon_gold.."|r/|c00ff00%s"..gsse.lang.core.icon_gold.."|r" -- guild, Max, Min, Avg, Undercut -added 0.06
	gsse.lang.gui.tt_key= "Key: |cff0000Min|r/|cff8000Max|r/|cfff000Avg|r/|c00ff00Undercut|r" --added 0.06
	gsse.lang.gui.tt_all= "All" --added 0.06
	gsse.lang.gui.tt_NoHistory= "No history found." --added 0.06
	gsse.lang.gui.tt_Sell= "|c00FFFFSell|r in |c008000%s|r for |c00ff00%s|r"..gsse.lang.core.icon_gold.." [|cFF80FF%s|r] (|c00FFFF%s|r)"--added 0.06 - guild, price, qty, source
	gsse.lang.gui.tt_Buy= "|c00FFFFBuy|r from |c008000%s|r for |c00ff00%s|r"..gsse.lang.core.icon_gold.." [|cFF80FF%s|r] (|c00FFFF%s|r)"--added 0.06 - guild, price, qty, source
	gsse.lang.gui.tt_sesstlt= "|c00FFFFThis Session" --added 0.06
	gsse.lang.gui.tt_histtlt= "|c00FFFFHistorical" --added 0.06
	gsse.lang.gui.tt_histshort="hist" --added 0.06
	gsse.lang.gui.tt_sessshort="sess" --added 0.06
	gsse.lang.gui.tt_eachshort="ea." --added 0.06
	
	
	gsse.lang.core.cmdHelp={}
	gsse.lang.core.cmdHelp[1]="GSSE command lines:" --added 0.06
	gsse.lang.core.cmdHelp[2]="  - /gsse show || /gsse on - show the GSSE window." --added 0.06
	gsse.lang.core.cmdHelp[3]="  - /gsse hide || /gsse off  - hide the GSSE window." --added 0.06

	
	
end

ZO_CreateStringId("SI_BINDING_NAME_GSSE_TOGGLE", "Show/Hide GSEE")


