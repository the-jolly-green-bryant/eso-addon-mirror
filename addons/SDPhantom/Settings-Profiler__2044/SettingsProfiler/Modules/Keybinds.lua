--[[	Settings Profiler - Keybinds Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

local AddOnName,ModuleName=debug.traceback():match("\nuser:/AddOns/([^/]+).-([^/:]+)%.lua");

local KeybindKeyFormat="%s|%d";
local KeybindValFormat="%d,%d,%d,%d,%d";
local KeybindValPattern="(%d+),(%d+),(%d+),(%d+),(%d+)";
local KeybindValInvalid=KeybindValFormat:format(KEY_INVALID,KEY_INVALID,KEY_INVALID,KEY_INVALID,KEY_INVALID);

local NumActionLayers=GetNumActionLayers();
local NumActionBindings=GetMaxBindingsPerAction();

local BindKeyToAction=IsProtectedFunction("BindKeyToAction") and function(...) return CallSecureProtected("BindKeyToAction", ...) end or BindKeyToAction;
local UnbindKeyFromAction=IsProtectedFunction("UnbindKeyFromAction") and function(...) return CallSecureProtected("UnbindKeyFromAction", ...) end or UnbindKeyFromAction;

----------------------------------
--[[	Helper Functions	]]
----------------------------------
local GenerateModifierMask; do--	function GenerateModifierMask(mod1,mod2,mod3,mod4)
	local ModMasks={};
	for i,key in ipairs({KEY_CTRL,KEY_ALT,KEY_SHIFT,KEY_COMMAND}) do ModMasks[key]=2^(i-1); end
	function GenerateModifierMask(mod1,mod2,mod3,mod4)
		return (ModMasks[mod1] or 0)+(ModMasks[mod2] or 0)+(ModMasks[mod3] or 0)+(ModMasks[mod4] or 0);
	end
end

local function EncodeBinding(key,mod1,mod2,mod3,mod4)
	if key==KEY_INVALID then return KeybindValInvalid; end--	If key is invalid, don't process the modifiers, they should be invalid too (Modifiers bound as the main key shows up as such)
	return KeybindValFormat:format(key,mod1,mod2,mod3,mod4);
end

local function DecodeBinding(bind)
	if not bind then return KEY_INVALID,KEY_INVALID,KEY_INVALID,KEY_INVALID,KEY_INVALID; end
	local key,mod1,mod2,mod3,mod4=bind:match(KeybindValPattern);
	key,mod1,mod2,mod3,mod4=tonumber(key) or KEY_INVALID,tonumber(mod1) or KEY_INVALID,tonumber(mod2) or KEY_INVALID,tonumber(mod3) or KEY_INVALID,tonumber(mod4) or KEY_INVALID;
	if key==KEY_INVALID then mod1,mod2,mod3,mod4=KEY_INVALID,KEY_INVALID,KEY_INVALID,KEY_INVALID; end
	return key,mod1,mod2,mod3,mod4;
end

local function AreBindsEqual(a,...)--	First arg has to be an encoded bind string, second can be encoded or raw values
	if a==nil or (...)==nil then return false; end--	Don't allow nil to equal anything, even itself
	if a==(...) then return true; end--	Quick hack for same bind strings being equal
	local keya,mod1a,mod2a,mod3a,mod4a=DecodeBinding(a);
	local keyb,mod1b,mod2b,mod3b,mod4b=...;--	If given (key,mod1,mod2,mod3,mod4)
	if select("#",...)<=1 then keyb,mod1b,mod2b,mod3b,mod4b=DecodeBinding(keyb); end--	We were only given the binding string, decode that
	return keya==keyb and GenerateModifierMask(mod1a,mod2a,mod3a,mod4a)==GenerateModifierMask(mod1b,mod2b,mod3b,mod4b);--	Modifiers are given by key code and can show up in random order, compare by generated bitfield
end

local function KeybindIterator(_,lastaction)--	Usage:	for name,layer,category,action in KeybindIterator do
	local layer,category,action=1,1,0;
	if lastaction then layer,category,action=GetActionIndicesFromName(lastaction); end
	if not (layer and category and action) then return nil,nil,nil,nil; end

	for newlayer=layer,NumActionLayers do
		local _,numcategories=GetActionLayerInfo(newlayer);
		for newcategory=(newlayer==layer and category or 1),numcategories do
			_,numactions=GetActionLayerCategoryInfo(newlayer,newcategory);
			for newaction=((newlayer==layer and newcategory==category) and action+1 or 1),numactions do
				local name,rebind,hidden=GetActionInfo(newlayer,newcategory,newaction);
				if name and rebind and not hidden then return name,newlayer,newcategory,newaction; end
			end
		end
	end

	return nil,nil,nil,nil;
end

----------------------------------
--[[	Module Registration	]]
----------------------------------
_G[AddOnName]:RegisterSaveModule(ModuleName,{
	Save=function(self,save)
		save=save or {};
		for name,layer,category,action in KeybindIterator do
			for binding=1,NumActionBindings do
				save[KeybindKeyFormat:format(name,binding)]=EncodeBinding(GetActionBindingInfo(layer,category,action,binding));
			end
		end
		return save;
	end;

	Load=function(self,save)
		if not save then return; end
		for name,layer,category,action in KeybindIterator do
			for binding=1,NumActionBindings do
				local data=save[KeybindKeyFormat:format(name,binding)];
				if data then
					if not AreBindsEqual(data,GetActionBindingInfo(layer,category,action,binding)) then
						local key,mod1,mod2,mod3,mod4=DecodeBinding(data);
						if key~=KEY_INVALID then BindKeyToAction(layer,category,action,binding,key,mod1,mod2,mod3,mod4);
						else UnbindKeyFromAction(layer,category,action,binding); end
					end
				end
			end
		end
	end;

	Events={
		{EVENT_KEYBINDING_SET},function(self,save,_,layer,category,action,binding,key,mod1,mod2,mod3,mod4)
--			Does fire for internal keybinds cascading off changes
			local name,rebind,hidden=GetActionInfo(layer,category,action);
			if not name or not rebind or hidden then return; end

--			Tends to fire after :Load() is called
			save=save or {};
			local bindkey=KeybindKeyFormat:format(name,binding);
			if not AreBindsEqual(save[bindkey],key,mod1,mod2,mod3,mod4) then save[bindkey]=EncodeBinding(key,mod1,mod2,mod3,mod4); return true,save; end
		end;
		{EVENT_KEYBINDING_CLEARED},function(self,save,_,layer,category,action,binding)
--			Does fire for internal keybinds cascading off changes
			local name,rebind,hidden=GetActionInfo(layer,category,action);
			if not name or not rebind or hidden then return; end

--			Tends to fire after :Load() is called
			save=save or {};
			local bindkey=KeybindKeyFormat:format(name,binding);
			if not AreBindsEqual(save[bindkey],KeybindValInvalid) then save[bindkey]=KeybindValInvalid; return true,save; end
		end;
	};

	MinSaveVersion=2;
});
