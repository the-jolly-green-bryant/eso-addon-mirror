QuickDestroyKeyStrip = ZO_Object:Subclass()

function QuickDestroyKeyStrip:New(name, keybind, callback, alignment)
	local obj = ZO_Object.New(self)
	obj:Init(name, keybind, callback, alignment)
	return obj
end

local function createStripDescriptor(name, keybind, callback, alignment)
	return {{
		alignment = alignment or KEYBIND_STRIP_ALIGN_RIGHT,
		name = name,
		keybind = keybind,
		callback = callback
	}}
end

function QuickDestroyKeyStrip:Init(name, keybind, callback, alignment)
	self.stripDescriptor = createStripDescriptor(name, keybind, callback, alignment)
	self.wasAdded = false
end

function QuickDestroyKeyStrip:Add(onlyIfBound)
	if (not onlyIfBound or self:IsBound()) then
		KEYBIND_STRIP:AddKeybindButtonGroup(self.stripDescriptor)
		self.wasAdded = true
	end
end

function QuickDestroyKeyStrip:Remove()
	if (self.wasAdded) then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.stripDescriptor)
		self.wasAdded = false
	end
end

function QuickDestroyKeyStrip:IsBound()
	local layer, category, action = GetActionIndicesFromName(self.stripDescriptor[1]["keybind"])
	for binding = 1, GetMaxBindingsPerAction() do
		local keyCode,_,_,_,_ = GetActionBindingInfo(layer, category, action, binding)
		if (keyCode > 0) then
			return true
		end
	end
	return false
end
