--[[	Settings Profiler - Chat Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

local AddOnName,ModuleName=debug.traceback():match("\nuser:/AddOns/([^/]+).-([^/:]+)%.lua");
local AddOn=_G[AddOnName];

------------------------------------------
--[[	Individual Save Functions	]]
------------------------------------------
local function MakeSavePath(tbl,...) tbl=tbl or {}; return AddOn.MakePath(tbl,...),tbl; end

local function SaveFontSize(self,save,size)
	save=save or {};
	save.FontSize=size or GetChatFontSize();
	return true,save;
end

local function SaveCategoryColor(self,save,category,...)
	local tbl,save=MakeSavePath(save,"Categories",category,"Color");
	if select("#",...)>0 then
		tbl[1],tbl[2],tbl[3]=...;--	R,G,B
	else
		tbl[1],tbl[2],tbl[3]=GetChatCategoryColor(category);
	end
	return true,save;
end

local function SaveCategoryChatBubble(self,save,category,enabled)
	local tbl,save=MakeSavePath(save,"Categories",category);
	if enabled==nil then enabled=IsChatBubbleCategoryEnabled(category); end
	tbl.ChatBubble=enabled;
	return true,save;
end

local function SaveContainerColor(self,save,container,...)
	local tbl,save=MakeSavePath(save,"Containers",container,"Color");
	if select("#",...)>0 then
		tbl[1],tbl[2],tbl[3],tbl[4],tbl[5]=...;--	R,G,B,MinAlpha,MaxAlpha
	else
		tbl[1],tbl[2],tbl[3],tbl[4],tbl[5]=GetChatContainerColors(container);
	end
	return true,save;
end

local function SaveContainerTabInfo(self,save,container,tab,...)
	local tbl,save=MakeSavePath(save,"Containers",container,"Tabs",tab);
	if select("#",...)>0 then
		tbl.Name,tbl.Locked,tbl.Interactable,tbl.Timestamps=...;
	else
		local _; tbl.Name,tbl.Locked,tbl.Interactable,_,tbl.Timestamps=GetChatContainerTabInfo(container,tab);
	end
	return true,save;
end

local function SaveContainerTabCategory(self,save,container,tab,category,enabled)
	local tbl,save=MakeSavePath(save,"Containers",container,"Tabs",tab,"Categories");
	if enabled==nil then enabled=IsChatContainerTabCategoryEnabled(container,tab,category); end
	tbl[category]=enabled;
	return true,save;
end

----------------------------------
--[[	Compound Save Functions	]]
----------------------------------
local function SaveTab(self,save,container,tab)
	local _; _,save=MakeSavePath(save,"Containers",container,"Tabs",tab);
	SaveContainerTabInfo(self,save,container,tab);
	for i=1,GetNumChatCategories() do SaveContainerTabCategory(self,save,container,tab,i); end
	return true,save;
end

local function SaveContainer(self,save,container)
	local _; _,save=MakeSavePath(save,"Containers",container);
	SaveContainerColor(self,save,container);
	for i=1,GetNumChatContainerTabs(container) do SaveTab(self,save,container,i); end
	return true,save;
end

----------------------------------
--[[	Module Registration	]]
----------------------------------
local AddChatContainer=AddChatContainer;
local AddChatContainerTab=AddChatContainerTab;
local RemoveChatContainer=RemoveChatContainer;
local RemoveChatContainerTab=RemoveChatContainerTab;

local SetChatFontSize=SetChatFontSize;
local SetChatCategoryColor=SetChatCategoryColor;
local SetChatBubbleCategoryEnabled=SetChatBubbleCategoryEnabled;
local SetChatContainerColors=SetChatContainerColors;
local SetChatContainerTabInfo=SetChatContainerTabInfo;
local SetChatContainerTabCategoryEnabled=SetChatContainerTabCategoryEnabled;

AddOn:RegisterSaveModule(ModuleName,{
	Save=function(self,save)
		save=save or {};

		SaveFontSize(self,save);
		for i=1,GetNumChatCategories() do
			SaveCategoryColor(self,save,i);
			SaveCategoryChatBubble(self,save,i);
		end

		for i=1,GetNumChatContainers() do
			SaveContainerColor(self,save,i);
			for j=1,GetNumChatContainerTabs(i) do
				SaveContainerTabInfo(self,save,i,j);
				for k=1,GetNumChatCategories() do
					SaveContainerTabCategory(self,save,i,j,k);
				end
			end
		end

		return save;
	end;

	Load=function(self,save)
		SetChatFontSize(save.FontSize);--	Set Font Size
		for categoryid,categorydata in ipairs(save.Categories) do
			SetChatCategoryColor(categoryid,unpack(categorydata.Color));--	Set Chat Color
			SetChatBubbleCategoryEnabled(categoryid,categorydata.ChatBubble);--	Set Chat Bubble
		end

		local numcontainers=GetNumChatContainers();
		for containerid,containerdata in ipairs(save.Containers) do
			if containerid>numcontainers then AddChatContainer(); end
			SetChatContainerColors(categoryid,unpack(containerdata.Color));--	Set Container Color/Alpha (R,G,B,MinAlpha,MaxAlpha)

			local numtabs=GetNumChatContainerTabs(containerid);
			for tabid,tabdata in ipairs(containerdata.Tabs) do
				if tabid>numtabs then AddChatContainerTab(containerid,tabdata.Name,false); end--	Add Tab
				SetChatContainerTabInfo(containerid,tabid,tabdata.Name,tabdata.Locked,tabdata.Interactable,tabdata.Timestamps);--	Set Tab Info
				for categoryid,enabled in ipairs(tabdata.Categories) do
					SetChatContainerTabCategoryEnabled(containerid,tabid,categoryid,enabled);--	Set Categories
				end
			end
			for i=numtabs,#containerdata.Tabs+1,-1 do RemoveChatContainerTab(containerid,i); end--	Trim Tabs
		end
		for i=numcontainers,#save.Containers+1,-1 do--	Trim Containers
			for j=GetNumChatContainerTabs(i),1 do RemoveChatContainerTab(i,j); end
			RemoveChatContainer(i);
		end

		AddOn:RefreshOptionsPanels();--	Refresh Options Panels (if shown)
		if CHAT_SYSTEM.loaded then--	Refresh CHAT_SYSTEM
			CHAT_SYSTEM.suppressSave=true;--	Don't let CHAT_SYSTEM call our hooks while we're refreshing it

--			Simple stuff
			CHAT_SYSTEM:SetFontSize(GetChatFontSize());--	Set Font Size
			for categoryid,categorydata in ipairs(save.Categories) do--	Set Channel Colors
				CHAT_SYSTEM:OnChatCategoryColorChanged(categoryid,unpack(categorydata.Color));
			end

--			Containers and Tabs
			local numcontainers=GetNumChatContainers();
			for i=1,numcontainers do
				local container=CHAT_SYSTEM.containers[i];
				if container then
					local numwindows=#container.windows;
					container:LoadSettings(container.settings);--	Load Container Settings (sets given table to container.settings, giving that so it stays the same)
					for j=1,numwindows do--	container:LoadSettings() handled adding tabs for us (update existing tabs)
						container:SetTabName(j,save.Containers[i].Tabs[j].Name);--	Set Name
						container:LoadWindowSettings(container.windows[j]);--		Load Tab Settings
					end
					for j=numwindows,GetNumChatContainerTabs(i)+1,-1 do container:RemoveWindow(j); end--	Trim Tabs
				else CHAT_SYSTEM:CreateChatContainer(); end--	New Container (loads settings from game)
			end
			for i=#CHAT_SYSTEM.containers,numcontainers+1,-1 do--	Trim Containers
				local container=CHAT_SYSTEM.containers[i];
				for j=#container.windows,1,-1 do container:RemoveWindow(j); end--	CHAT_SYSTEM:DestroyContainer() calls assert() if there are tabs left
				CHAT_SYSTEM:DestroyContainer(container);--	Odd this takes the object instead of an ID, but it gets that from container.id
			end

			CHAT_SYSTEM.suppressSave=false;--	We're done here
		end
	end;

	Hooks={
		{_G,"AddChatContainer",function(self,save) return SaveContainer(self,save,GetNumChatContainers()); end,true};
		{_G,"AddChatContainerTab",function(self,save,container) return SaveTab(self,save,container,GetNumChatContainerTabs(container)); end,true};
		{_G,"RemoveChatContainer",function(self,save,container) table.remove(save.Containers,container); return true,save end};
		{_G,"RemoveChatContainerTab",function(self,save,container,tab) table.remove(save.Containers[container].Tabs,tab); return true,save end};

		{_G,"SetChatFontSize",SaveFontSize};
		{_G,"ResetChatFontSizeToDefault",SaveFontSize};
		{_G,"SetChatCategoryColor",SaveCategoryColor};
		{_G,"ResetChatCategoryColorToDefault",SaveCategoryColor};
		{_G,"SetChatBubbleCategoryEnabled",SaveCategoryChatBubble};

		{_G,"SetChatContainerColors",SaveContainerColor};
		{_G,"ResetChatContainerColorsToDefault",SaveContainerColor};
		{_G,"SetChatContainerTabInfo",SaveContainerTabInfo};
		{_G,"ResetChatContainerTabToDefault",SaveContainerTabInfo};
		{_G,"SetChatContainerTabCategoryEnabled",SaveContainerTabCategory};
	};
});
