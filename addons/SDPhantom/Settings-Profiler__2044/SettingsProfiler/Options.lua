--[[	Settings Profiler - Options Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

--------------------------
--[[	Namespace	]]
--------------------------
local AddOnName=debug.traceback():match("\nuser:/AddOns/([^/]+)");
local AddOn=_G[AddOnName];

--------------------------
--[[	Options API	]]
--------------------------
do--	function AddOn:RefreshOptionsPanels()
--	This can be called many times when multiple SaveModules are requesting updates, This makes sure we only update once
	local Namespace,Queued=AddOnName.."_API_RefreshOptionsPanels",false;
	local function OnTimeout()
		EVENT_MANAGER:UnregisterForUpdate(Namespace);

		if not ZO_GamepadOptionsTopLevel:IsControlHidden() then GAMEPAD_OPTIONS:RefreshOptionsList(); end
		if not ZO_OptionsWindow:IsControlHidden() then
--			KEYBOARD_OPTIONS:UpdateAllPanelOptions(SAVE_CURRENT_VALUES);--	Refresh standard options

--			Refresh all options
			for _,controllist in pairs(KEYBOARD_OPTIONS.controlTable) do
				for _,control in ipairs(controllist) do
					local data=control.data;
					if KEYBOARD_OPTIONS:IsControlTypeAnOption(data) then
						data.value=ZO_Options_UpdateOption(control);--	Same as ZO_KeyboardOptions:UpdatePanelOptions(SAVE_CURRENT_VALUES)
					elseif not control:IsControlHidden() then control:SetHidden(true); control:SetHidden(false); end--	Simulate panel change
				end
			end
		end

		Queued=false;
	end

	function AddOn:RefreshOptionsPanels()
		if Queued then return; end
		EVENT_MANAGER:RegisterForUpdate(Namespace,0,OnTimeout);
		Queued=true;
	end
end

--	ToDo:		Build an options GUI
--	Reference:	EsoUI\PregameAndIngame\ZO_Options\Keyboard\ZO_Options_Keyboard.lua
