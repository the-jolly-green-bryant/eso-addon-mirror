local myAddonName				 = 'EideticMemoryOfItem'
EMOI = {}
EMOI.init = false
EMOI.SavedVar = {}
EMOI.SavedVar.Default = {
	fontSize = 16,
	pageLines = 25,
	posX = 200,
	posY = 100,
	addedLog = true,
	auto = false,
	sortMode = { mode = "time", bool = true },
	saveData = {},
	filteredList = {},
	filter = "",
}
local function CreateRandStr(length)
  local length = length or 0
  if length <= 0 then
    return nil
  end

  local random_strs = {}
  if length > 0 then
    math.randomseed(os.time())
    for i= 1, length do 
      local a = math.random(97,122) -- a~zのどれかを指定する数字
      local c = math.random(65,90)  -- A~Zのどれかを指定する数字
      local i = math.random(48,57)  -- 0~9のどれかを指定する数字
      local w = math.random(1,3)    -- 大文字、小文字、数字を決めるランダム値
      if w == 1 then table.insert(random_strs, string.char(a)) end
      if w == 2 then table.insert(random_strs, string.char(c)) end
      if w == 3 then table.insert(random_strs, string.char(i)) end
    end
  end
  -- 文字列に変換して、戻り値とする。
  return table.concat(random_strs, "")

end
function EMOI.filter()
	EMOI.SavedVar.savedVariables.filteredList = {}
	for index, data in pairs(EMOI.SavedVar.savedVariables.saveData) do
		if string.match(data.itemName,EMOI.SavedVar.savedVariables.filter) then
			table.insert(EMOI.SavedVar.savedVariables.filteredList, data)
		end
	end
	--table.insert(EMOI.SavedVar.savedVariables.filteredList, data)
end
function EMOI.sort(str,force)
	if EMOI.SavedVar.savedVariables.mode == str then
		if force == nil then
			EMOI.SavedVar.savedVariables.bool = not EMOI.SavedVar.savedVariables.bool
		else
			EMOI.SavedVar.savedVariables.bool = force
		end
	else
		EMOI.SavedVar.savedVariables.bool = true
	end
	if EMOI.SavedVar.savedVariables.bool then
		table.sort(EMOI.SavedVar.savedVariables.saveData,
			function(a,b)
			return (a[str] < b[str])
		end)
	else
		table.sort(EMOI.SavedVar.savedVariables.saveData,
			function(b,a)
			return (a[str] < b[str])
		end)
	end
	EMOI.filter()
	EMOI.SavedVar.savedVariables.mode = str
	EMOI.setLines(1)
end
local function GetItemID(itemLink)
  local itemId = itemLink:match("|H[^:]+:item:([^:]+):")
  -- d("itemLink:"..itemLink)
  return tonumber(itemId)
end
local function addData2(r,data,index,max)
	for i = 1 , max do
		index = index + 1
		if EMOI.SavedVar.savedVariables.saveData[index] ~= nil then
			if (data.itemID == EMOI.SavedVar.savedVariables.saveData[index].itemID) then
				--d("Already exists")
				EVENT_MANAGER:UnregisterForUpdate(myAddonName.."1"..r)
				return
			end
		end
	end
	EVENT_MANAGER:UnregisterForUpdate(myAddonName.."1"..r)
	if(index >= table.maxn(EMOI.SavedVar.savedVariables.saveData)) then
		table.insert(EMOI.SavedVar.savedVariables.saveData, data)
		if EMOI.SavedVar.savedVariables.addedLog then d("EMOI_added:"..data.itemLink) end
		--EMOI.sort("time",true)
		EMOI.lastestPage()
		return
	end
	EVENT_MANAGER:RegisterForUpdate(myAddonName.."1"..r, 250, function () addData2(r,data,index,max) end)
end
local function addData(data,index)
	index = index or 0
	local r = CreateRandStr(20)
	--addData2(r,data,index,50)
	EVENT_MANAGER:RegisterForUpdate(myAddonName.."1"..r, 250, function () addData2(r,data,index,100) end)
end
function EMOI.lastestPage()
	local maxPage = table.maxn(EMOI.SavedVar.savedVariables.filteredList) / EMOI.SavedVar.savedVariables.pageLines
	maxPage = math.ceil(maxPage)
	EMOI.setLines(maxPage)
end
function EMOI.addData(str)
	if string.match(str,"|H(.-):(.-)|h(.-)|h")then
		local data = {}
		local itemLink = str
		data.itemLink = itemLink
		data.time = os.time()
		data.charName = GetUnitName("player")
		data.zoneIndex = GetCurrentMapZoneIndex()
		data.itemID = GetItemID(itemLink)
		data.itemName = GetItemLinkName(itemLink)
		data.memo = ""
		addData(data,0)
	end
end
function EMOI.setLines(page)
	if page == nil then page = 1 end
	EMOI.UI.page = page
	local index = 1
	for i, line in ipairs(EMOI.UI.lines) do
		if i <= EMOI.SavedVar.savedVariables.pageLines then
			index = i + (EMOI.SavedVar.savedVariables.pageLines * (page - 1))
			local text = "---"
			if index <= table.maxn(EMOI.SavedVar.savedVariables.filteredList) then
				text = EMOI.SavedVar.savedVariables.filteredList[index].itemLink or "---"
				line.data = EMOI.SavedVar.savedVariables.filteredList[index]
				line.tableIndex = index
			end
			line:SetText(text)
		end
	end
	local maxPage = table.maxn(EMOI.SavedVar.savedVariables.filteredList) / EMOI.SavedVar.savedVariables.pageLines
	maxPage = math.ceil(maxPage)
	EMOI.UI.label:SetText("Page:"..page.."/"..maxPage.."   -   "..table.maxn(EMOI.SavedVar.savedVariables.filteredList).." / "..table.maxn(EMOI.SavedVar.savedVariables.saveData).."items")
end
function EMOI.addDataOnce(str)
	if string.match(str,"|H(.-):(.-)|h(.-)|h")then
		local data = {}
		local itemLink = str
		data.itemLink = itemLink
		data.time = os.time()
		data.charName = GetUnitName("player")
		data.zoneIndex = GetCurrentMapZoneIndex()
		data.itemID = GetItemID(itemLink)
		data.itemName = GetItemLinkName(itemLink)
		data.memo = ""
		for i, ver1 in pairs(EMOI.SavedVar.savedVariables.saveData) do
			if EMOI.SavedVar.savedVariables.saveData[i] ~= nil then
				if (data.itemID == EMOI.SavedVar.savedVariables.saveData[i].itemID) then
					--d("Already exists")
					--if EMOI.SavedVar.savedVariables.addedLog then d("Already exists:"..data.itemLink) end
					return
				end
			end
		end
		table.insert(EMOI.SavedVar.savedVariables.saveData, data)
		if EMOI.SavedVar.savedVariables.addedLog then d("EMOI_added:"..data.itemLink) end
		--EMOI.sort("time",true)
		EMOI.lastestPage()
	end
end
local function onSlotUpdate(event, bagId, slotIndex, isNew)
	if EMOI.SavedVar.savedVariables.auto then 
		local itemLink = GetItemLink(bagId,slotIndex)
		--EMOI.addData(itemLink)
		EMOI.addDataOnce(itemLink)
	end
end
local function eventRegister()
	--EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_CURSOR_PICKUP, OnPickup)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)
end
local function init( event, addon )
	if ( addon ~= myAddonName ) then return end
	EMOI.SavedVar.savedVariables	 = ZO_SavedVars:NewAccountWide("EMOISavedVar", 1, nil, EMOI.SavedVar.Default)
	eventRegister()
	EMOI.CreateSettingsWindow()
	EMOI.UI.createUI()
	EMOI.filter()
	EMOI.setLines(nil)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_EMOI", "Toggle EideticMemoryOfItemUI")
	--eventRegister()
	EMOI.init = true
end
EVENT_MANAGER:RegisterForEvent(myAddonName, EVENT_ADD_ON_LOADED, init)
	
local function TKMEMO_cmd(value)
	if (EMOI.UI.MainAnchor == nil) then return end
	EMOI.UI.MainAnchor:ToggleHidden()
	
end
SLASH_COMMANDS["/emoi"] = TKMEMO_cmd
