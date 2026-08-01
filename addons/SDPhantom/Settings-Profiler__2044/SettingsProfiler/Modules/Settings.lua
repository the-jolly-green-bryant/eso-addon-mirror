--[[	Settings Profiler - Settings Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

local AddOnName,ModuleName=debug.traceback():match("\nuser:/AddOns/([^/]+).-([^/:]+)%.lua");
local AddOn=_G[AddOnName];

----------------------------------
--[[	Settings Scanner	]]
----------------------------------
local SettingFormat="%d,%d";
local SettingsList={}; do--	Cached list of settings IDs
	local OptionsControlTypes={--	From EsoUI\PregameAndIngame\ZO_Options\ZO_SharedOptions.lua
		[OPTIONS_FINITE_LIST]			=true;
		[OPTIONS_DROPDOWN]			=true;
		[OPTIONS_CHECKBOX]			=true;
		[OPTIONS_SLIDER]			=true;
		[OPTIONS_HORIZONTAL_SCROLL_LIST]	=true;
		[OPTIONS_COLOR]				=true;
		[OPTIONS_CHAT_COLOR]			=true;
	};

	for id,panel in ipairs({--	Scan these panels from ZO_SharedOptions_SettingsData
		SETTING_PANEL_GAMEPLAY;
		SETTING_PANEL_CAMERA;
		SETTING_PANEL_INTERFACE;
		SETTING_PANEL_NAMEPLATES;
		SETTING_PANEL_SOCIAL;
		SETTING_PANEL_COMBAT;
	}) do
		for _,system in pairs(ZO_SharedOptions_SettingsData[panel]) do
			for _,setting in pairs(system) do
				if setting.controlType~=OPTIONS_INVOKE_CALLBACK and setting.system and setting.settingId then
					SettingsList[SettingFormat:format(setting.system,setting.settingId)]={setting.system,setting.settingId};
				end
			end
		end
	end
end

----------------------------------
--[[	Module Registration	]]
----------------------------------
local SetSetting=SetSetting;

AddOn:RegisterSaveModule(ModuleName,{
	Save=function(self,save)
		save=save or {}; for k,v in pairs(SettingsList) do save[k]=GetSetting(v[1],v[2]); end return save;
	end;

	Load=function(self,save)
		for k,v in pairs(SettingsList) do local val=save[k]; if val and val~="" then SetSetting(v[1],v[2],val); end end
		AddOn:RefreshOptionsPanels();
	end;

	Hooks={
		{_G,"SetSetting",function(self,save,system,setting,val)
			local key=SettingFormat:format(system,setting);
			if SettingsList[key] and val~=nil and val~="" then
				save=save or {};
				if type(val)=="boolean" then val=val and "1" or "0";
				else val=tostring(val); end

				save[key]=val;
				return true,save;
			end
		end};
	};
});
