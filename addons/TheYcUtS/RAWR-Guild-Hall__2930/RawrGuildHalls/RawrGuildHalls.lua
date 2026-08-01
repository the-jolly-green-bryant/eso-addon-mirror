RawrGuildHalls = RawrGuildHalls or {}

function RawrGuildHalls_Initialize(eventCode, addOnName)
		
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
		InformationTooltip:AddLine(""..CRN.."|cBFBC99Rawr Community|r"..CRN.."")
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|cBFBC99Меню|r\n"..rmb.."|cBFBC99Домой|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
		
		--Меню
local function Rawr_Menu(control, button)
	if button == 1 then
		local entries = {
				{label = ""..menuGH.."Дворец рассвета", callback = function() JumpToSpecificHouse("@Varlav", 57) end, },
            }
		local SubMenuRW = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:136337|hRawr|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/g7KfMkw") end,},
			}	
		local SubMenuRA = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:563690|hRawrling|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/g7KfMkw") end,},
			}
		local SubMenuRR = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:632234|hRoaring Rawr|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/g7KfMkw") end,},
			}
			ClearMenu()
			AddCustomSubMenuItem(""..menuGH.."Гильдхолл", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..GDscl.."Rawr", SubMenuRW)
			AddCustomSubMenuItem(""..GDscl.."Rawrling", SubMenuRA)
			AddCustomSubMenuItem(""..GDscl.."Roaring Rawr", SubMenuRR)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."ReloadUI", function() ReloadUI() end)
			ShowMenu()
	elseif button == 2 then
		RequestJumpToHouse(GetHousingPrimaryHouse())
	end
end

	if (addOnName ~= "RawrGuildHalls") then return end
		
		--Развернуть чат
	RWbtn =  WINDOW_MANAGER:CreateControl("MaxRWGH", ZO_ChatWindow, CT_BUTTON)
    RWbtn:SetDimensions(20, 20)
    RWbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
   	RWbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    RWbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	RWbtn:SetNormalTexture("RawrGuildHalls/imgs/Rawr.dds")
    RWbtn:SetPressedTexture("RawrGuildHalls/imgs/Rawr.dds")
    RWbtn:SetMouseOverTexture("RawrGuildHalls/imgs/Rawr.dds")
	RWbtn:SetHandler("OnMouseUp", function(control, button) Rawr_Menu(control, button) end)
		
		--Свернуть чат
	RWbtnMin =  WINDOW_MANAGER:CreateControl("MinRWGH", ZO_ChatWindowMinBar, CT_BUTTON)
    RWbtnMin:SetDimensions(25, 25)
    RWbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    RWbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	RWbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    RWbtnMin:SetNormalTexture("RawrGuildHalls/imgs/Rawr.dds")
    RWbtnMin:SetPressedTexture("RawrGuildHalls/imgs/Rawr.dds")
    RWbtnMin:SetMouseOverTexture("RawrGuildHalls/imgs/Rawr.dds")
	RWbtnMin:SetHandler("OnMouseUp", function(control, button) Rawr_Menu(control, button) end)
end

EVENT_MANAGER:RegisterForEvent("RawrGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	RawrGuildHalls_Initialize(...) 	end)