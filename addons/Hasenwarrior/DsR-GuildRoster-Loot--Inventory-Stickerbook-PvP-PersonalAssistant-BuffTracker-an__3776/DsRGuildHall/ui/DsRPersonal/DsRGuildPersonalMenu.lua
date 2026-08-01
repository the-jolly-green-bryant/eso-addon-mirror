-- Create namespace
DsRGuildPersonalMenu = {}
local DsRGuildPersonalMenu = DsRGuildPersonalMenu  or {}

DsRGuildPersonalMenu.name = "DsRGuildPersonalMenu"

local LAM = LibAddonMenu2
local cm  = CALLBACK_MANAGER
local wm  = WINDOW_MANAGER

local DsRIcon = DsRglobals:HolidayIconLoad()

local MenuOptionsGen,MenuPanelGen,MenuHandlersGen={},{},{}
local MenuOptionsBank,MenuPanelBank,MenuHandlersBank={},{},{}
local MenuOptionsBankAvA,MenuPanelBankAvA,MenuHandlersBankAvA={},{},{}
local MenuOptionsJunk,MenuPanelJunk,MenuHandlersJunk={},{},{}
local MenuOptionsConsumer,MenuPanelConsumer,MenuHandlersConsumer={},{},{}
local MenuOptionsRepair,MenuPanelRepair,MenuHandlersRepair={},{},{}
local MenuOptionsAvAshop,MenuPanelAvAshop,MenuHandlersAvAshop={},{},{}
local SettingsGen,SettingsTEMP,SettingsTEMPAvA,SettingsJunk,SettingsConsumer,SettingsRepair,SettingsAvAshop={},{},{},{},{},{},{}

-------------------------------------------------------------------------------------------------------------------------------------------------
local currentChar = GetUnitName("player")

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ActCharAlliance(charNum)
    local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
    if alliance == 1 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds", 40, 40)
    elseif alliance == 2 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds", 40, 40)
    elseif alliance == 3 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds", 40, 40)
    end
    return alliance, Icon
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetAllCharOptions(savVarsOpt, val)
    for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"][savVarsOpt] = val
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetAllCharOptions2(savVarsOpt, val)
    for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][savVarsOpt] = val
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetAllCharOptions3(savVarsOpt, val)
    for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][savVarsOpt] = val
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function BankAssistantSettingsGEN()
    table.insert(SettingsTEMP, {type="description",name="DsRGuildPersonal_BankingDefaultMenuAttention1",})
    table.insert(SettingsTEMP, {type="description",name="DsRGuildPersonal_BankingDefaultMenuAttention2",})
    table.insert(SettingsTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyCurrency",})
    table.insert(SettingsTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyGold",warning="ReloadUiWarn1",
                                getFunc=function() return "0" end,
                                setFunc=function(val) SetAllCharOptions("Gold", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="editbox",name="DsRGuildPersonal_CurrencySchrieb",warning="ReloadUiWarn1",
                                getFunc=function() return "0" end,
                                setFunc=function(val) SetAllCharOptions("writvoucher", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyAP",warning="ReloadUiWarn1",
                                getFunc=function() return "0" end,
                                setFunc=function(val) SetAllCharOptions("AP", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyTelVar",warning="ReloadUiWarn1",
                                getFunc=function() return "0" end,
                                setFunc=function(val) SetAllCharOptions("TelVar", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyLockPickGem",})
    table.insert(SettingsTEMP, {type="checkbox",name=GetString(DsRGuildPersonal_SoulGem),warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions2(ITEMTYPE_SOUL_GEM, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning="ReloadUiWarn1",
								getFunc=function() return "200" end,
								setFunc=function(val) SetAllCharOptions("SliderSoulgem", val) DsR.UI.ReloadUIButton() end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name=GetString(DsRGuildPersonal_SoulGemEmpty),warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions2(SPECIALIZED_ITEMTYPE_SOUL_GEM, val) DsR.UI.ReloadUIButton() end,})
    table.insert(SettingsTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning="ReloadUiWarn1",
								getFunc=function() return "200" end,
								setFunc=function(val) SetAllCharOptions("SliderSoulgemEmpty", val) DsR.UI.ReloadUIButton() end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name=zo_iconFormat("/esoui/art/icons/lockpick.dds", 26, 26) ..  GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions2(ITEMTYPE_LOCKPICK, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning="ReloadUiWarn1",
								getFunc=function() return "200" end,
								setFunc=function(val) SetAllCharOptions("SliderLockPick", val) DsR.UI.ReloadUIButton() end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_Repairkit",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions2(ITEMTYPE_TOOL, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning="ReloadUiWarn1",
								getFunc=function() return "200" end,
								setFunc=function(val) SetAllCharOptions("SliderTool", val) DsR.UI.ReloadUIButton() end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyMapRecipe",})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/treasuremap_witchesfestival.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) .. GetString(DsRGuildPersonal_SurveyUnkown),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/justice_stolen_map_001.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP) .. GetString(DsRGuildPersonal_TreasureUnkown),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/master_writ-newlife.dds", 26, 26) ..  GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT) .. GetString(DsRGuildPersonal_MasterUnkown),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(ITEMTYPE_MASTER_WRIT, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/notes_004.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/quest_stonehuskfragment.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/crafting_metals_dwarven_scrap.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT),warning="ReloadUiWarn1",
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRPersonal_MOVE_IGNORE end,
                                setFunc	 =function(val) SetAllCharOptions3(SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT, val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="description",name="",})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeALL",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoRecipeAll", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_scribing.dds", 26, 26) .. "|c00CDCD" .. GetString(SI_QUESTTYPE18),})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoScribingKnown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoScribingUnknown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/event_newlifefestival_2016_recipe.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE),})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoRecipeKnown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoRecipeUnknown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/crafting_planfurniture_alchemy3.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_RECIPECRAFTINGSYSTEM", RECIPE_CRAFTING_SYSTEM_ENCHANTING_SCHEMATICS),})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoBlueprintKnown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoBlueprintUnknown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/quest_book_001.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK) .. " / " .. zo_iconFormat("/esoui/art/icons/quest_letter_002.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER) .. " / " .. zo_iconFormat("/esoui/art/icons/quest_summerset_completed_report.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE),})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoStileKnown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoStileUnknown", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyPvPSubmenu",})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPMerite",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoPvPMeride", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPMarke",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoPvPMarke", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPBeweis",warning="ReloadUiWarn1",
                                getFunc=function() return false end,
                                setFunc=function(val) SetAllCharOptions("DepoPvPBeweis", val) DsR.UI.ReloadUIButton() end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})

    return 	SettingsTEMP[1],  SettingsTEMP[2],  SettingsTEMP[3],  SettingsTEMP[4],  SettingsTEMP[5],  SettingsTEMP[6],  SettingsTEMP[7],  SettingsTEMP[8],  SettingsTEMP[9],  SettingsTEMP[10],
            SettingsTEMP[11], SettingsTEMP[12], SettingsTEMP[13], SettingsTEMP[14], SettingsTEMP[15], SettingsTEMP[16], SettingsTEMP[17], SettingsTEMP[18], SettingsTEMP[19], SettingsTEMP[20],
            SettingsTEMP[21], SettingsTEMP[22], SettingsTEMP[23], SettingsTEMP[24], SettingsTEMP[25], SettingsTEMP[26], SettingsTEMP[27], SettingsTEMP[28], SettingsTEMP[29], SettingsTEMP[30],
            SettingsTEMP[31], SettingsTEMP[32], SettingsTEMP[33], SettingsTEMP[34], SettingsTEMP[35], SettingsTEMP[36], SettingsTEMP[37], SettingsTEMP[38], SettingsTEMP[39], SettingsTEMP[40],
            SettingsTEMP[41], SettingsTEMP[42], SettingsTEMP[43], SettingsTEMP[44], SettingsTEMP[45], SettingsTEMP[46], SettingsTEMP[47], SettingsTEMP[48], SettingsTEMP[49], SettingsTEMP[50],
            SettingsTEMP[51], SettingsTEMP[52], SettingsTEMP[53], SettingsTEMP[54]
end

local function BankAssistantSettingsCHAR(CharName)
    local CHARnameTEMP = "SettingsTEMP"..CharName
    local CHARnameTEMP = {}
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyCurrency",})
    table.insert(CHARnameTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyGold",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["Gold"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["Gold"] = string.lower(val) end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="editbox",name="DsRGuildPersonal_CurrencySchrieb",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["writvoucher"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["writvoucher"] = string.lower(val) end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyAP",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["AP"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["AP"] = string.lower(val) end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="editbox",name="DsRGuildPersonal_CurrencyTelVar",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["TelVar"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["TelVar"] = string.lower(val) end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyLockPickGem",})
    table.insert(CHARnameTEMP, {type="checkbox",name=GetString(DsRGuildPersonal_SoulGem),warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning=false,
								getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderSoulgem"] end,
								setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderSoulgem"] = val end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name=GetString(DsRGuildPersonal_SoulGemEmpty),warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning=false,
								getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderSoulgemEmpty"] end,
								setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderSoulgemEmpty"] = val end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name=zo_iconFormat("/esoui/art/icons/lockpick.dds", 26, 26) ..  GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning=false,
								getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderLockPick"] end,
								setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderLockPick"] = val end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_Repairkit",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="slider",name="DsRGuildPersonal_CurrencyAmount",warning=false,
								getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderTool"] end,
								setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["SliderTool"] = val end,
								min=0,max=1000,step=1,
                                disabled=function() return not DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL] end,})
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyMapRecipe",})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/treasuremap_witchesfestival.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) .. GetString(DsRGuildPersonal_SurveyUnkown),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/justice_stolen_map_001.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP) .. GetString(DsRGuildPersonal_TreasureUnkown),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/master_writ-newlife.dds", 26, 26) ..  GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT) .. GetString(DsRGuildPersonal_MasterUnkown),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/notes_004.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/quest_stonehuskfragment.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/icons/crafting_metals_dwarven_scrap.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT),
                                choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="description",name="",})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeALL",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,
                                setFunc=function(val) 
                                            DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] = val
                                            if val then
                                                DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoScribingKnown"]   = false
                                                DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeKnown"]     = false
                                                DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoBlueprintKnown"]  = false
                                                DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoStileKnown"]      = false
                                            end
                                        end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_scribing.dds", 26, 26) .. "|c00CDCD" .. GetString(SI_QUESTTYPE18),})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoScribingKnown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoScribingKnown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoScribingUnknown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoScribingUnknown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/event_newlifefestival_2016_recipe.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE),})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeKnown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeKnown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeUnknown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeUnknown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/crafting_planfurniture_alchemy3.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_RECIPECRAFTINGSYSTEM", RECIPE_CRAFTING_SYSTEM_ENCHANTING_SCHEMATICS),})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoBlueprintKnown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoBlueprintKnown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoBlueprintUnknown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoBlueprintUnknown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="subheader",name=zo_iconFormat("/esoui/art/icons/quest_book_001.dds", 26, 26) .. "|c00CDCD" .. GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK) .. " / " .. zo_iconFormat("/esoui/art/icons/quest_letter_002.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER) .. " / " .. zo_iconFormat("/esoui/art/icons/quest_summerset_completed_report.dds", 26, 26) ..  GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE),})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeKnown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoStileKnown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoStileKnown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyRecipeUnknown",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoStileUnknown"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoStileUnknown"] = val end,
                                disabled=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] end,})
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_CurrencyPvPSubmenu",})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPMerite",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPMeride"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPMeride"] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPMarke",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPMarke"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPMarke"] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_CurrencyPvPBeweis",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPBeweis"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoPvPBeweis"] = val end,
                                disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})

    return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
            CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
            CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
            CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
            CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50],
            CHARnameTEMP[51], CHARnameTEMP[52], CHARnameTEMP[53], CHARnameTEMP[54]
end

local function BankAvAAssistantSettingsCHAR(CharName)
    local CHARnameTEMP = "SettingsTEMP"..CharName
    local CHARnameTEMP = {}

    local alliance, Icon = ActCharAlliance(CharNum)
    local siegeItems     = DsRGuildPersonalGlobals.SiegeWeapons[ActCharAlliance(CharNum)]

    for key, value in ipairs(siegeItems) do
        local itemLink         = "|H0:item:"..value.itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        local itemName         = GetItemLinkName(itemLink)
        local itemIcon         = GetItemLinkIcon(itemLink)
        local itemIconText     = zo_iconTextFormat(itemIcon, 26, 26, " ")
        local itemNameText     = LocalizeString("<<1>>", itemName)
        local itemquality      = GetItemLinkQuality(itemLink)
        local itemqualityColor = GetItemQualityColor(itemquality)
        local colorItem        = zo_strformat("|c<<1>>", itemqualityColor:ToHex())    

        table.insert(CHARnameTEMP, {type="dropdown",name=itemIconText .. colorItem .. itemNameText,
                                    choices	 ={DsRPersonal_MOVE_IGNORE, DsRPersonal_MOVE_DEPOSIT, DsRPersonal_MOVE_WITHDRAW},
                                    getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName] end,
                                    setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["BankingAvA"]["depo"..value.settingName] = val end,
                                    disabled =function() return not DsRGuildPersonal.ACCconfig.BankingAvAOnOff end,})
    end

    return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
            CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
            CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
            CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
            CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50]
end

local function BankJunkAssistantSettingsCHAR(CharName)
    local CHARnameTEMP = "SettingsTEMP"..CharName
    local CHARnameTEMP = {}

    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_MenueJunkJunk",})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_JunkPlunder",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["PlunderToJunk"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["PlunderToJunk"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_JunkPrey",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["PleyToJunk"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["PleyToJunk"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name=zo_iconFormat("/esoui/art/inventory/inventory_trait_ornate_icon.dds", 26, 26) .. GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE),warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["OrnateToJunk"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["OrnateToJunk"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_JunkArmorWeaponNoTrait",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["NoTraitToJunk"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["NoTraitToJunk"] = val end,})
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_MenueJunkDeconstruct",})
    table.insert(CHARnameTEMP, {type="checkbox",name=zo_iconFormat("/esoui/art/inventory/inventory_trait_intricate_icon.dds", 26, 26) .. GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE) .. GetString(DsRGuildPersonal_DeconstructAlways),warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["IndricateToDecon"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["IndricateToDecon"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_DeconstructNoTrait",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconNoTrait"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconNoTrait"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_DeconstructJunk",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconJunk"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconJunk"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_DeconstructSetItem",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconSetItems"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconSetItems"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_DeconstructCrafted",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconCrafted"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconCrafted"] = val end,})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_DeconstructReconstr",warning=false,default=true,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconReconstr"]  end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconReconstr"] = val end,})
    table.insert(CHARnameTEMP, {type="subheader",name="DsRGuildPersonal_DeconstructDescQuali",})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds", 26, 26) .. GetString(DsRGuildPersonal_Glyphe) .. GetString(DsRGuildPersonal_DeconstructWithorBelow),
                                choices	 ={DsR_Quality_NONE, DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconGlyphe"] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconGlyphe"] = val end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/inventory/inventory_tabicon_armor_up.dds", 26, 26) .. GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR) .. GetString(DsRGuildPersonal_DeconstructWithorBelow),
                                choices	 ={DsR_Quality_NONE, DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconArmor"] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconArmor"] = val end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/inventory/inventory_tabicon_weapons_up.dds", 26, 26) .. GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON) .. GetString(DsRGuildPersonal_DeconstructWithorBelow),
                                choices	 ={DsR_Quality_NONE, DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconWeapon"] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconWeapon"] = val end,})
    table.insert(CHARnameTEMP, {type="dropdown",name=zo_iconFormat("/esoui/art/crafting/jewelry_tabicon_icon_up.dds", 26, 26) .. GetString(DsRGuildPersonal_Jewelry) .. GetString(DsRGuildPersonal_DeconstructWithorBelow),
                                choices	 ={DsR_Quality_NONE, DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
                                getFunc	 =function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconJewelry"] end,
                                setFunc	 =function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["DeconJewelry"] = val end,})

    return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
            CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
            CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
            CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
            CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50]
end

local function BankConsumerAssistantSettingsGEN()
    local SettingsTEMP = {}
   
    table.insert(SettingsTEMP, {type="description",name="DsRGuildPersonal_ConsumeInterval",})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeBuffFoodONOff",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderfoodOnOff end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderfoodOnOff = val end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeBuffFoodfalse",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderfoodfalse end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderfoodfalse = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderfoodOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name="DsRGuildPersonal_ConsumeBuffFoodMinTime",
                                choices	 ={"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
                                getFunc	 =function() return DsRGuildLoot.sV.DsRReminderBuffFoodMinTime end,
                                setFunc	 =function(val) DsRGuildLoot.sV.DsRReminderBuffFoodMinTime = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderfoodOnOff end,})
    table.insert(SettingsTEMP, {type="description",name="",})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeXPONOff",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderxpOnOff end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderxpOnOff = val end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeXPfalse",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderxpfalse end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderxpfalse = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderxpOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name="DsRGuildPersonal_ConsumeXPMinTime",
                                choices	 ={"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
                                getFunc	 =function() return DsRGuildLoot.sV.DsRReminderxpMinTime end,
                                setFunc	 =function(val) DsRGuildLoot.sV.DsRReminderxpMinTime = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderxpOnOff end,})
    table.insert(SettingsTEMP, {type="description",name="",})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeAPONOff",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderapOnOff end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderapOnOff = val end,})
    table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeAPfalse",warning=false,
                                getFunc=function() return DsRGuildLoot.sV.DsRReminderapfalse end,
                                setFunc=function(val) DsRGuildLoot.sV.DsRReminderapfalse = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderapOnOff end,})
    table.insert(SettingsTEMP, {type="dropdown",name="DsRGuildPersonal_ConsumeAPMinTime",
                                choices	 ={"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
                                getFunc	 =function() return DsRGuildLoot.sV.DsRReminderapMinTime end,
                                setFunc	 =function(val) DsRGuildLoot.sV.DsRReminderapMinTime = val end,
                                disabled=function() return not DsRGuildLoot.sV.DsRReminderapOnOff end,})

    return 	SettingsTEMP[1],  SettingsTEMP[2],  SettingsTEMP[3],  SettingsTEMP[4],  SettingsTEMP[5],  SettingsTEMP[6],  SettingsTEMP[7],  SettingsTEMP[8],  SettingsTEMP[9],  SettingsTEMP[10],
            SettingsTEMP[11], SettingsTEMP[12], SettingsTEMP[13], SettingsTEMP[14], SettingsTEMP[15], SettingsTEMP[16], SettingsTEMP[17], SettingsTEMP[18], SettingsTEMP[19], SettingsTEMP[20],
            SettingsTEMP[21], SettingsTEMP[22], SettingsTEMP[23], SettingsTEMP[24], SettingsTEMP[25], SettingsTEMP[26], SettingsTEMP[27], SettingsTEMP[28], SettingsTEMP[29], SettingsTEMP[30],
            SettingsTEMP[31], SettingsTEMP[32], SettingsTEMP[33], SettingsTEMP[34], SettingsTEMP[35], SettingsTEMP[36], SettingsTEMP[37], SettingsTEMP[38], SettingsTEMP[39], SettingsTEMP[40],
            SettingsTEMP[41], SettingsTEMP[42], SettingsTEMP[43], SettingsTEMP[44], SettingsTEMP[45], SettingsTEMP[46], SettingsTEMP[47], SettingsTEMP[48], SettingsTEMP[49], SettingsTEMP[50]
end

local function BankConsumerAssistantSettingsCHAR(CharName)
    local CHARnameTEMP = "SettingsTEMP"..CharName
    local CHARnameTEMP = {}

    table.insert(CHARnameTEMP, {type="slider",name="DsRGuildPersonal_ConsumeAutoEat",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoEatTime"] or "0" end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoEatTime"] = val end,
                                min=0,max=15,step=1,default=5,})
    table.insert(CHARnameTEMP, {type="description",name=GetString(DsRGuildPersonal_ConsumeAutoEatTyp) .. zo_strformat(SI_TOOLTIP_ITEM_NAME, DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoEatTyp"]),})
    table.insert(CHARnameTEMP, {type="description",name="",})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeAutoXP",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoXPOnOff"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoXPOnOff"] = val end,})
    table.insert(CHARnameTEMP, {type="description",name=GetString(DsRGuildPersonal_ConsumeAutoEatXPAP) .. zo_strformat(SI_TOOLTIP_ITEM_NAME, DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoEatXP"]),})
    table.insert(CHARnameTEMP, {type="description",name="",})
    table.insert(CHARnameTEMP, {type="checkbox",name="DsRGuildPersonal_ConsumeAutoAP",warning=false,
                                getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoAPOnOff"] end,
                                setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoAPOnOff"] = val end,})
    table.insert(CHARnameTEMP, {type="description",name=GetString(DsRGuildPersonal_ConsumeAutoEatXPAP) .. zo_strformat(SI_TOOLTIP_ITEM_NAME, DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["DeconJunk"]["ConsumeAutoEatAP"]),})

    return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
            CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
            CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
            CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
            CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50]
end

local function BankRepairAssistantSettingsCHAR(CharName, CharNum)
    local CHARnameTEMP = "SettingsTEMP"..CharName
    local CHARnameTEMP = {}

    local siegeItems = DsRGuildPersonalGlobals.SiegeWeapons[ActCharAlliance(CharNum)]

    for key, value in ipairs(siegeItems) do
        local itemLink         = "|H0:item:"..value.itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        local icon             = GetItemLinkIcon(itemLink)
        local itemquality      = GetItemLinkQuality(itemLink)
        local itemqualityColor = GetItemQualityColor(itemquality)
        local colorItem        = zo_strformat("|c<<1>>", itemqualityColor:ToHex())

        local AP   = DsRGuildPersonal.getFormattedCurrency(value.AP, CURT_ALLIANCE_POINTS, true)
        if value.gold then
            gold = DsRGuildPersonal.getFormattedCurrency(value.gold, CURT_MONEY, true)
        else
            gold = 0
        end
        if value.itemId == 141731 or value.itemId == 29533 or value.itemId == 29535 or value.itemId == 29534 then
            table.insert(CHARnameTEMP, {type="slider",name=zo_iconFormat(icon, 26, 26) .. colorItem .. string.format(GetItemLinkName(itemLink):gsub("%^.+", "")) .. "   (|c00ff00" .. AP .. "|r)",warning=false,
                                        getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] end,
                                        setFunc=function(val) DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] = val end,
                                        min=0,max=50,step=1,})
        elseif value.itemId == 204483 or value.itemId == 30359 then
            table.insert(CHARnameTEMP, {type="slider",name=zo_iconFormat(icon, 26, 26) .. colorItem .. string.format(GetItemLinkName(itemLink):gsub("%^.+", "")) .. "   (|c00ff00" .. AP .. "|r)",
                                        getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] end,
                                        setFunc=function(val)
                                                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] = val
                                                    if val > 0 and value.gold then
                                                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] = 0
                                                    end
                                                end,
                                        min=0,max=400,step=1,})
            if value.gold then                                     
                table.insert(CHARnameTEMP, {type="slider",name=zo_iconFormat(icon, 26, 26) .. colorItem .. string.format(GetItemLinkName(itemLink):gsub("%^.+", "")) .. "   (|cFFD700" .. value.gold .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 20, 20) .. "|r)",
                                            getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] end,
                                            setFunc=function(val)
                                                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] = val 
                                                        if val > 0 then
                                                            DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] = 0
                                                        end
                                                    end,
                                            min=0,max=400,step=1,})
            end
        else
            table.insert(CHARnameTEMP, {type="slider",name=zo_iconFormat(icon, 26, 26) .. colorItem .. string.format(GetItemLinkName(itemLink):gsub("%^.+", "")) .. "   (|c00ff00" .. AP .. "|r)",
                                        getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] end,
                                        setFunc=function(val)
                                                    DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] = val
                                                    if val > 0 and value.gold then
                                                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] = 0
                                                    end
                                                end,
                                        min=0,max=100,step=1,})
            if value.gold then
                table.insert(CHARnameTEMP, {type="slider",name=zo_iconFormat(icon, 26, 26) .. colorItem .. string.format(GetItemLinkName(itemLink):gsub("%^.+", "")) .. "   (|cFFD700" .. value.gold .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 20, 20) .. "|r)",
                                            getFunc=function() return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] end,
                                            setFunc=function(val)
                                                        DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName.."Gold"] = val
                                                        if val > 0 then
                                                            DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["SiegeMaster"]["buy"..value.settingName] = 0
                                                        end
                                                    end,
                                            min=0,max=100,step=1,})
            end
        end
    end

    return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
            CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
            CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
            CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
            CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50]
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMenu:SetupMenueSettings()
-- MENU NEW
    local DsRMenu=DsR and DsR.InternalMenu

    for i = 1, 6 do
        if i == 1 then
            local MenuPanelBank={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd12.|r |t26:26:/esoui/art/icons/mapkey/mapkey_bank.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssBank,
                displayName =(DsRMenu and "|c9fb6cd12.|r |t26:26:/esoui/art/icons/mapkey/mapkey_bank.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssBank,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }
            local MenuOptionsBank={}

            table.insert(MenuOptionsBank, {type="description",name="DsRGuildPersonal_General",})
            table.insert(MenuOptionsBank, {type="checkbox",name="DsRGuildPersonal_CurrencyUse",warning="ReloadUiWarn1",
                                            getFunc=function() return DsRGuildPersonal.ACCconfig.CurrencyOnOff end,
                                            setFunc=function(val) DsRGuildPersonal.ACCconfig.CurrencyOnOff = val DsR.UI.ReloadUIButton() end,})
            table.insert(MenuOptionsBank, {type="checkbox",name="DsRGuildPersonal_BankingStack",warning=false,
                                            getFunc=function() return DsRGuildPersonal.ACCconfig.AutoStack end,
                                            setFunc=function(val) DsRGuildPersonal.ACCconfig.AutoStack = val end,
                                            disabled=function() return not DsRGuildPersonal.ACCconfig.CurrencyOnOff end,})
            table.insert(MenuOptionsBank, {type="attention",name="DsRGuildPersonal_GeneralAttention1",})
            table.insert(MenuOptionsBank, {type="description",name="DsRGuildPersonal_GeneralAttention2",})
            table.insert(MenuOptionsBank, {type="submenu",name="DsRGuildPersonal_BankingDefaultMenu",controls={BankAssistantSettingsGEN()}})
            
            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local Char = DsRglobals:CharDetails(CharName, CharNum)
                table.insert(MenuOptionsBank, {type="submenu",name=tostring(Char),controls={BankAssistantSettingsCHAR(CharName)}})
            end

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelBank_1", MenuPanelBank)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelBank_1", MenuOptionsBank) 
        elseif i == 2 then
            local MenuPanelBankAvA={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd13.|r |t26:26:/esoui/art/icons/mapkey/mapkey_bank.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssBankAvA,
                displayName =(DsRMenu and "|c9fb6cd13.|r |t26:26:/esoui/art/icons/mapkey/mapkey_bank.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssBankAvA,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }
            local MenuOptionsBankAvA={}

            table.insert(MenuOptionsBankAvA, {type="description",name="DsRGuildPersonal_General",})
            table.insert(MenuOptionsBankAvA, {type="checkbox",name="DsRGuildPersonal_BankingAvAUse",warning="ReloadUiWarn1",
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.BankingAvAOnOff end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.BankingAvAOnOff = val DsR.UI.ReloadUIButton() end,})

            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local Char = DsRglobals:CharDetails(CharName, CharNum)
                -- local Char = ActChar(CharName, CharNum)
                table.insert(MenuOptionsBankAvA, {type="submenu",name=tostring(Char),controls={BankAvAAssistantSettingsCHAR(CharName)}})
            end

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelBankAvA_1", MenuPanelBankAvA)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelBankAvA_1", MenuOptionsBankAvA) 
        elseif i == 3 then
            local MenuPanelJunk={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd14.|r |t26:26:/esoui/art/inventory/inventory_tabicon_junk_up.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssJunk,
                displayName =(DsRMenu and "|c9fb6cd14.|r |t26:26:/esoui/art/inventory/inventory_tabicon_junk_up.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssJunk,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }
            local MenuOptionsJunk={}

            table.insert(MenuOptionsJunk, {type="checkbox",name="DsRGuildPersonal_JunkUse",warning="ReloadUiWarn1",
                                            getFunc=function() return DsRGuildPersonal.ACCconfig.JunkOnOff end,
                                            setFunc=function(val) DsRGuildPersonal.ACCconfig.JunkOnOff = val DsR.UI.ReloadUIButton() end,})
            table.insert(MenuOptionsJunk, {type="checkbox",name="DsRGuildPersonal_JunkSell",warning=false,
                                            getFunc=function() return DsRGuildPersonal.ACCconfig.JunkSellOnOff end,
                                            setFunc=function(val) DsRGuildPersonal.ACCconfig.JunkSellOnOff = val end,})
            table.insert(MenuOptionsJunk, {type="checkbox",name="DsRGuildPersonal_DeconstructUse",warning=false,
                                            getFunc=function() return DsRGuildPersonal.ACCconfig.DeconstructOnOff end,
                                            setFunc=function(val) DsRGuildPersonal.ACCconfig.DeconstructOnOff = val end,})

            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local Char = DsRglobals:CharDetails(CharName, CharNum)
                -- local Char = ActChar(CharName, CharNum)
                table.insert(MenuOptionsJunk, {type="submenu",name=tostring(Char),controls={BankJunkAssistantSettingsCHAR(CharName)}})
            end

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelJunk_1", MenuPanelJunk)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelJunk_1", MenuOptionsJunk) 
        elseif i == 4 then
            local MenuPanelConsumer={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd15.|r |t26:26:/esoui/art/icons/justice_stolen_food_001.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssConsumer,
                displayName =(DsRMenu and "|c9fb6cd15.|r |t26:26:/esoui/art/icons/justice_stolen_food_001.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssConsumer,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }
            local MenuOptionsConsumer={}

            table.insert(MenuOptionsConsumer, {type="description",name="DsRGuildPersonal_ConsumeInfo1",})
            table.insert(MenuOptionsConsumer, {type="description",name="DsRGuildPersonal_ConsumeInfo2",})
            table.insert(MenuOptionsConsumer, {type="checkbox",name="DsRGuildPersonal_ConsumeOnOff",warning="ReloadUiWarn1",
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.ConsumeOnOff end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.ConsumeOnOff = val DsR.UI.ReloadUIButton() end,})
            table.insert(MenuOptionsConsumer, {type="submenu",name="DsRGuildPersonal_ConsumeACCSettings",controls={BankConsumerAssistantSettingsGEN()}})

            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local Char = DsRglobals:CharDetails(CharName, CharNum)
                -- local Char = ActChar(CharName, CharNum)
                table.insert(MenuOptionsConsumer, {type="submenu",name=tostring(Char),controls={BankConsumerAssistantSettingsCHAR(CharName)}})
            end

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelConsumer_1", MenuPanelConsumer)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelConsumer_1", MenuOptionsConsumer) 
        elseif i == 5 then
            local MenuPanelRepair={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd16.|r |t26:26:/esoui/art/icons/ava_siege_weapon_004.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssAvAshop,
                displayName =(DsRMenu and "|c9fb6cd16.|r |t26:26:/esoui/art/icons/ava_siege_weapon_004.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssAvAshop,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }
            local MenuOptionsRepair={}

            table.insert(MenuOptionsRepair, {type="checkbox",name="DsRGuildPersonal_AvAShopUse",warning="ReloadUiWarn1",
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.AvAShoppingOnOff end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.AvAShoppingOnOff = val DsR.UI.ReloadUIButton() end,})
            table.insert(MenuOptionsRepair, {type="description",name="DsRGuildPersonal_AvAShopMainDesc1",})
            table.insert(MenuOptionsRepair, {type="description",name="DsRGuildPersonal_AvAShopMainDesc2",})
                                    
            for CharNum, CharName in ipairs( DsRGuildLoot.sV.characters ) do
                local Char = DsRglobals:CharDetails(CharName, CharNum)
                -- local Char = ActChar(CharName, CharNum)
                table.insert(MenuOptionsRepair, {type="submenu",name=tostring(Char),controls={BankRepairAssistantSettingsCHAR(CharName, CharNum)}})
            end

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelRepair_1", MenuPanelRepair)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelRepair_1", MenuOptionsRepair) 
        elseif i == 6 then
            local MenuNamePanel   = "MenuPanelAvAshop"
            local MenuNameOption  = "MenuOptionsAvAshop"
            local MenuSetting     = "SettingsAvAshop"

            local MenuPanelAvAshop={
                type        ="panel",
                name        =(DsRMenu and "|c9fb6cd17.|r |t26:26:/esoui/art/vendor/vendor_tabicon_repair_up.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssRepair,
                displayName =(DsRMenu and "|c9fb6cd17.|r |t26:26:/esoui/art/vendor/vendor_tabicon_repair_up.dds|t" or "")..DsR.Localization[DsR.language].IndexPersonalAssRepair,
                author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
            }

            local MenuOptionsAvAshop={}

            table.insert(MenuOptionsAvAshop, {type="checkbox",name="DsRGuildPersonal_RepairMenueOnOff",warning="ReloadUiWarn1",
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairOnOff end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.RepairOnOff = val DsR.UI.ReloadUIButton() end,})
            table.insert(MenuOptionsAvAshop, {type="attention",name="DsRGuildPersonal_RepairMenueDesc",})
            table.insert(MenuOptionsAvAshop, {type="checkbox",name="DsRGuildPersonal_RepairChat",warning=false,
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairChatOnOff end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.RepairChatOnOff = val end,
                                                disabled=function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="subheader",name="DsRGuildPersonal_RepairStores",})
            table.insert(MenuOptionsAvAshop, {type="dropdown",name="DsRGuildPersonal_RepairStoresAuto",
                                                choices	 ={DsRPersonal_REPAIR_ALL,DsRPersonal_REPAIR_WORN,DsRPersonal_REPAIR_NONE},
                                                getFunc	 =function() return DsRGuildPersonal.ACCconfig.RepairstoreRepairMode end,
                                                setFunc	 =function(value) DsRGuildPersonal.ACCconfig.RepairstoreRepairMode = value end,
                                                disabled =function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="subheader",name="DsRGuildPersonal_RepairRepairing",})
            table.insert(MenuOptionsAvAshop, {type="dropdown",name="DsRGuildPersonal_RepairRepairingAuto",
                                                choices	 ={DsRPersonal_REPAIR_ALWAYS, DsRPersonal_REPAIR_RAIDING, DsRPersonal_REPAIR_NEVER},
                                                getFunc	 =function() return DsRGuildPersonal.ACCconfig.RepairMode end,
                                                setFunc	 =function(value) DsRGuildPersonal.ACCconfig.RepairMode = value end,
                                                disabled =function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="checkbox",name="DsRGuildPersonal_RepairRepairingAutoAny",warning=false,
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairAnyKit end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.RepairAnyKit = val end,
                                                disabled=function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="slider",name="DsRGuildPersonal_RepairKit",warning=false,
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairThreshold end,
                                                setFunc=function(value)   DsRGuildPersonal.ACCconfig.RepairThreshold = value end,
                                                min=0,max=100,step=1,default=25,
                                                disabled=function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="subheader",name="DsRGuildPersonal_RepairRecharging",})
            table.insert(MenuOptionsAvAshop, {type="dropdown",name="DsRGuildPersonal_RepairRechargingAuto",
                                                choices	 ={DsRPersonal_REPAIR_ALWAYS, DsRPersonal_REPAIR_RAIDING, DsRPersonal_REPAIR_NEVER},
                                                getFunc	 =function() return DsRGuildPersonal.ACCconfig.RepairrechargeMode end,
                                                setFunc	 =function(value) DsRGuildPersonal.ACCconfig.RepairrechargeMode = value end,
                                                disabled =function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="checkbox",name="DsRGuildPersonal_RepairRechargingAutoAny",warning=false,
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairAnyGem end,
                                                setFunc=function(val) DsRGuildPersonal.ACCconfig.RepairAnyGem = val end,
                                                disabled=function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})
            table.insert(MenuOptionsAvAshop, {type="slider",name="DsRGuildPersonal_RepairRecharge",warning=false,
                                                getFunc=function() return DsRGuildPersonal.ACCconfig.RepairrechargeThreshold end,
                                                setFunc=function(value)   DsRGuildPersonal.ACCconfig.RepairrechargeThreshold = value end,
                                                min=0,max=100,step=1,default=25,
                                                disabled=function() return not DsRGuildPersonal.ACCconfig.RepairOnOff end,})

            DsR.Menu.RegisterPanel("DsRPersonal_MenuPanelAvAshop_1", MenuPanelAvAshop)
            DsR.Menu.RegisterOptions("DsRPersonal_MenuPanelAvAshop_1", MenuOptionsAvAshop) 
        end    
    end
end