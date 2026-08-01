MMGuildHalls = MMGuildHalls or {}

function MMGuildHalls_Initialize(eventCode, addOnName)
		
		--Текстуры
	lmb = '|t25:25:ESOUI/art/miscellaneous/icon_lmb.dds|t'
	rmb = '|t25:25:ESOUI/art/miscellaneous/icon_rmb.dds|t'
	dvd = '|t200:2:esoui/art/ava/ava_seigecontrols_divider.dds|t'
	CRN = '|t25:25:esoui/art/icons/guildranks/guild_indexicon_misc01_up.dds|t'
	menuGH = '|t25:25:esoui/art/journal/leaderboard_tabicon_home_up.dds|t'
	--menuGD = '|t25:25:esoui/art/contacts/tabicon_friends_up.dds|t'
	GDscl = '|t25:25:esoui/art/chatwindow/chat_friendsonline_up.dds|t'
	GDtrd = '|t25:25:esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds|t'
	ADD = '|t25:25:esoui/art/progression/addpoints_up.dds|t'
	Discord = '|t25:25:esoui/art/help/help_tabicon_cs_disabled.dds|t'
	RUI = '|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t'

		--Тултип
local function ShowTooltip(control)
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)
		InformationTooltip:AddLine(""..CRN.."|cBFBC99Merry Madness Community|r"..CRN.."")
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|cBFBC99Меню|r\n"..rmb.."|cBFBC99Домой|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
		
		--Меню
local function MM_Menu(control, button)
	if button == 1 then
		local entries = {
				{label = ""..menuGH.."Чертоги Лунного Избранника", callback = function() JumpToSpecificHouse("@AniriMur", 70) end, },
            }
		local SubMenuMM = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:576172|hMerry Madness|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/vQAtHnC") end,},
			}
			ClearMenu()
			AddCustomSubMenuItem(""..menuGH.."Гильдхолл", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..GDscl.."Merry Madness", SubMenuMM)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."ReloadUI", function() ReloadUI() end)
			ShowMenu()
	elseif button == 2 then
		RequestJumpToHouse(GetHousingPrimaryHouse())
	end
end

	if (addOnName ~= "MMGuildHalls") then return end
		
		--Развернуть чат
	MMbtn =  WINDOW_MANAGER:CreateControl("MaxMMGH", ZO_ChatWindow, CT_BUTTON)
    MMbtn:SetDimensions(20, 20)
    MMbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
   	MMbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    MMbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	MMbtn:SetNormalTexture("MMGuildHalls/imgs/MM.dds")
    MMbtn:SetPressedTexture("MMGuildHalls/imgs/MM.dds")
    MMbtn:SetMouseOverTexture("MMGuildHalls/imgs/MM.dds")
	MMbtn:SetHandler("OnMouseUp", function(control, button) MM_Menu(control, button) end)
		
		--Свернуть чат
	MMbtnMin =  WINDOW_MANAGER:CreateControl("MinMMGH", ZO_ChatWindowMinBar, CT_BUTTON)
    MMbtnMin:SetDimensions(25, 25)
    MMbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    MMbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	MMbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    MMbtnMin:SetNormalTexture("MMGuildHalls/imgs/MM.dds")
    MMbtnMin:SetPressedTexture("MMGuildHalls/imgs/MM.dds")
    MMbtnMin:SetMouseOverTexture("MMGuildHalls/imgs/MM.dds")
	MMbtnMin:SetHandler("OnMouseUp", function(control, button) MM_Menu(control, button) end)
end

EVENT_MANAGER:RegisterForEvent("MMGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	MMGuildHalls_Initialize(...) 	end)