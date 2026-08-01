-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

TI.ROSTER = {};

local guild_member_window = ZO_GuildRoster
local GUILD_MEMBER_LIST = ZO_GuildRosterList
local GUILD_MEMBER_HEADER = ZO_GuildRosterHeaders

--- Passe die Header der Memberliste an
local function EditRosterHeader()
	if(not TI.GetCharNameSettings()) then return end
	
	local displayNameControl = GUILD_MEMBER_HEADER:GetNamedChild("DisplayName")
	local zoneControl = GUILD_MEMBER_HEADER:GetNamedChild("Zone")
	local charNameLabel = GUILD_MEMBER_HEADER:GetNamedChild("CharNameName")
	local classControl = GUILD_MEMBER_HEADER:GetNamedChild("Class")
	if(not charNameLabel) then
		local charNameControl = TI:CreateControl(GUILD_MEMBER_HEADER, displayNameControl, "CharName")
		charNameLabel = TI.CreateCharNameLabel(charNameControl, displayNameControl, "Name", {175,30}, "ZoFontGame")
	end

	charNameLabel:SetText(TI.locale["CharNameHeader"])
	charNameLabel:SetVerticalAlignment(TOP)
	charNameLabel:SetFont("ZoFontHeader")
	charNameLabel:SetColor(0.77, 0.76, 0.62, 1)
	displayNameControl:SetDimensions(175,30)
    zoneControl:ClearAnchors()
	zoneControl:SetAnchor(2, charNameLabel, 8, 0)
	zoneControl:SetDimensions(215,30)
    classControl:ClearAnchors()
	classControl:SetAnchor(2, zoneControl, 8, 0)
end

--- Writes a character name in this line/Schreibt einen Charakternamen in diese Zeile
-- @param control CT_CONTROL Row of the new Label
local function addnameToRow(control)
	if(not TI.GetCharNameSettings()) then return end
	local guildId = TI:getNormalizedGuildId(GUILD_HOME.guildId);
	local charName = control.dataEntry.data.characterName
	local zoneName = control.dataEntry.data.formattedZone
	local isOnline = control.dataEntry.data.online
	local accName, _, _, _, lastOnline = GetGuildMemberInfo(guildId, control.dataEntry.data.index)

	local accNameControl = control:GetNamedChild("DisplayName")
	local zoneNameControl = control:GetNamedChild("Zone")
	local charNameControl = control:GetNamedChild("CharName")
	local classControl = control:GetNamedChild("ClassIcon")

	if(not charNameControl) then
		charNameControl = TI.CreateCharNameLabel(control, accNameControl, "CharName")
	end

	--Online/Offline alternatives
	zoneNameControl.zoneText = TI:formatZoneName(zoneName)
	if(isOnline == true) then
		zoneNameControl:SetMouseEnabled(false)
		charNameControl:SetColor(unpack(TI.colors.rosterOnline))
		zoneName = TI:formatZoneName(zoneName)
		zoneNameControl:SetText(zoneNameControl.zoneText);

	else
		charNameControl:SetColor(unpack(TI.colors.rosterOffline))
		zoneNameControl:SetText( TI:secsToTime(lastOnline))

		zoneNameControl:SetMouseEnabled(true)
		zoneNameControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, self.zoneText); ZO_KeyboardGuildRosterRow_OnMouseEnter(control); end);
		zoneNameControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_KeyboardGuildRosterRow_OnMouseExit(control); end);
	end
	zoneNameControl:SetVerticalAlignment(TOP)
	
	-- Char Name Tooltip and value	
	charNameControl:SetText(charName)
	charNameControl.mainChar =  TI.locale.templates["characterName_tooltip"] .. TI.SCANNER.GetTooltipString(GUILD_HOME.guildId, accName);
	charNameControl:SetMouseEnabled(true);
	charNameControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, self.mainChar); ZO_KeyboardGuildRosterRow_OnMouseEnter(control); end);
	charNameControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_KeyboardGuildRosterRow_OnMouseExit(control); end);

	-- Rearrange existing Labels
	accNameControl:SetDimensions(175,30)

	TI.ReAnchorControl(zoneNameControl, charNameControl, 0)
	
	zoneNameControl:SetDimensions(210,30)
	classControl:ClearAnchors()
	classControl:SetAnchor(2, zoneNameControl, 8, 0)

end

--Experimental code.
local processedRows = {}
local function AddRowHandler(row)
	if(not row or processedRows[row:GetName()]) then return end
	d("updating handler for " .. row:GetName())
	local oldUpdateHandler = row:GetHandler("OnTextChanged");
	if(oldUpdateHandler) then
		--d("set new Handler ".. row:GetName());
		local dn = row:GetNamedChild("DisplayName");
		dn:SetHandler("OnTextChanged", function(...)
			d(GetTimeString() .. ": OnTextChanged on ".. row:GetName() .. " called (new)");
			oldUpdateHandler(...);
			addnameToRow(row);
		end)
	else
		--d("post hook old handler " .. row:GetName());
		local dn = row:GetNamedChild("DisplayName");
		dn:SetHandler("OnTextChanged", function()
			d(GetTimeString() .. ": OnTextChanged on ".. row:GetName() .. " called");
			addnameToRow(row);
		end)
	end
	processedRows[row:GetName()] = true;
end

--Experimental code.
local function UpdateHandlers()
	d("updating handlers");
	for _,row in pairs(GUILD_MEMBER_LIST.activeControls) do
		AddRowHandler(row)
	end
	d(processedRows);

	if(#processedRows<20) then
		zo_callLater(UpdateHandlers, 5000);
	end

	--[[
	--Listen for new entries in active controls table
	 ]]
--	setmetatable(GUILD_MEMBER_LIST.activeControls,
--		{
--			__newindex = function (table, key, value)
--				AddRowHandler(value)
--			end
--		}
--	);

--	local oldListUpdateHandler = ZO_GuildRosterListContents:GetHandler("OnScrollOffsetChanged");
--	if(oldListUpdateHandler) then
--		ZO_GuildRosterListContents:SetHandler("OnScrollOffsetChanged", function(self, ...)
--			d("updating list (new)")
--			oldListUpdateHandler(self, ...);
--			UpdateGuildList();
--		end)
--	else
--		ZO_GuildRosterListContents:SetHandler("OnScrollOffsetChanged", function(self)
--			d("updating list")
--			UpdateGuildList();
--		end)
--	end
end

--- Updates Guild List with Charnames
local function UpdateGuildList(eventCode, a,b,c)
	if(not TI.GetCharNameSettings()) then return end

	if(not GUILD_MEMBER_LIST:IsHidden()) then
		TI.IterateGuildList()
	end
end

---Iterates through guild list
function TI.IterateGuildList()
	if(not TI.GetCharNameSettings()) then return end

	for _,row in pairs(GUILD_MEMBER_LIST.activeControls) do
		addnameToRow(row)
	end
end

function TI.ROSTER.Initialize()
	EditRosterHeader()
	TI.IterateGuildList()

	--Uncomment to use experimental updating of rows. Not stable in this release!
--	UpdateHandlers();

	ZO_PreHook("ZO_ScrollList_UpdateScroll", UpdateGuildList)
	TI.postHook("ZO_KeyboardGuildRosterRow_OnMouseUp", UpdateGuildList)
	TI.postHook("ZO_KeyboardGuildRoster_OnInitialized", UpdateGuildList)
	TI.postHook("ZO_SortHeader_OnMouseUp", UpdateGuildList)
	TI.postHook("OnSearchTextChanged", UpdateGuildList, "GUILD_ROSTER_KEYBOARD")
	TI.postHook("UnlockSelection", UpdateGuildList, "GUILD_ROSTER_KEYBOARD")
end