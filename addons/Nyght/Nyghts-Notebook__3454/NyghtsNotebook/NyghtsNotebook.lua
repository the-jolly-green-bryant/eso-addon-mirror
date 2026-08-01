-------------------------------------------------------------------------------------------------
--  Initialize Name Space --
-------------------------------------------------------------------------------------------------
NyghtsNotebook = {}
 
-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
NyghtsNotebook.name = "NyghtsNotebook"
NyghtsNotebook.version = 1.0
NyghtsNotebook.varVersion = 1.0

NyghtsNotebook.init = {
	notes = {}
}

local function listSize()	
	local size = 0
	if(NyghtsNotebook.savedVariables.notes ~= nil) 
	then
		for tblLngth in pairs(NyghtsNotebook.savedVariables.notes) do 
			size = size + 1
		end
	end
	return size
end

local function removeList(listName)
	local newNotebook = {}
	if listSize() > 0 
	then
		for currentName in pairs(NyghtsNotebook.savedVariables.notes) 
		do
			if currentName ~= listName 
			then
				newNotebook[currentName] = NyghtsNotebook.savedVariables.notes[currentName]
			end
		end	
	end
    return newNotebook
end

local function hasListName(listName)
	if listSize() > 0 
	then
		for currentName in pairs(NyghtsNotebook.savedVariables.notes) 
		do
			if currentName == listName 
			then
				return true
			end
		end	
	end
    return false
end

local function getLists()
	d("Notebooks:")
	if listSize() > 0 
	then
		for currentName in pairs(NyghtsNotebook.savedVariables.notes) 
		do
			d(zo_strformat("'<<1>>'", currentName))
		end	
	end
end

local function getListNote(input)
	if input ~= nil
	then
		if hasListName(input)
		then
			d(zo_strformat("Notebook: '<<1>>' <<2>>", input, NyghtsNotebook.savedVariables.notes[input]))
		else
			if input == ''
			then
				getLists()
			else
				d(zo_strformat("Could not find a notebook named '<<1>>'", input))
			end
		end
	else
		getLists()
	end
end

local function getNameAndNote(input)
	foundStart, foundEnd = string.find(input, ":")
	if foundStart ~= nil
	then
		local listName = string.sub(input,1,foundStart - 1)
		local listNote = string.sub(input,foundEnd + 1)
		
		-- remove spaces from beginning and end of name and note
		listName = string.gsub(listName, '^%s', '')
		listName = string.gsub(listName, '%s$', '')
		listNote = string.gsub(listNote, '^%s', '')
		listNote = string.gsub(listNote, '%s$', '')

		if listName == ''
		then
			d("You must specify a notebook name before the :")
		end
		if listNote == ''
		then
			d("You must specify a note after the :")
		end
		if listname ~= '' and listNote ~= ''
		then
			return listName, listNote
		else
			return nil, nil
		end
	else
		d("You must specify a notebook name and note using the : to separate the notebook name from the note")
		return nil, nil
	end		
end

local function remove(input)
	local listName, noteToRemove = getNameAndNote(input)
	if listName ~= nil
	then
		if hasListName(listName) 
		then
			if noteToRemove == '*'
			then
				d(zo_strformat("Deleting notebook '<<1>>'", listName))
				NyghtsNotebook.savedVariables.notes = removeList(listName)
			else
				local currentNote = NyghtsNotebook.savedVariables.notes[listName]
				local newNote = "";	
				d(zo_strformat("Deleting note '<<1>>' from notebook '<<2>>'", noteToRemove, listName))
				for noteItem in string.gmatch(currentNote, "[^\r\n]+") 
				do
					if(noteItem~=noteToRemove)
					then
						newNote = newNote .. string.char(10) .. string.char(13) .. noteItem
					end
				end
				NyghtsNotebook.savedVariables.notes[listName] = newNote
			end
		else
			d(zo_strformat("Could not find a notebook named '<<1>>'", listName))
		end
	end
end

local function addItem(input)
	local listName, listNote = getNameAndNote(input)
	if listName ~= nil
	then
		if hasListName(listName) 
		then
			currentNote = NyghtsNotebook.savedVariables.notes[listName]
			newNote = currentNote .. string.char(10) .. string.char(13) .. listNote 
			d(zo_strformat("Adding the note '<<1>>' in your notebook under '<<2>>'", listNote, listName))
			NyghtsNotebook.savedVariables.notes[listName] = newNote
		else
			d(zo_strformat("Creating the note '<<1>>' within notebook '<<2>>'", listNote, listName))
			NyghtsNotebook.savedVariables.notes[listName] = string.char(10) .. string.char(13) .. listNote
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function NyghtsNotebook:Initialize()
	-- load the currently saved variables and set defautls for unknown items.
	NyghtsNotebook.savedVariables  = ZO_SavedVars:NewCharacterIdSettings("NyghtsNotes", NyghtsNotebook.varVersion, nil, NyghtsNotebook.init)
	
	-- Handle Removing an item or an entire list
	SLASH_COMMANDS["/nn-"] = function(input)
		remove(input)
	end
	
	-- Handle Adding an item to a List
	SLASH_COMMANDS["/nn+"] = function(input)
		addItem(input)
	end
	
	-- Handle Getting a note
	SLASH_COMMANDS["/nn"] = function(input)
		getListNote(input)
	end
	
	--[[ unregister the addon from the EVENT_ADD_ON_LOADED so that code won't run again --]]
	EVENT_MANAGER:UnregisterForEvent(NyghtsNotebook.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Wait for AddOn to Load --
-------------------------------------------------------------------------------------------------
function NyghtsNotebook.OnAddOnLoaded(event, addonName)
	-- Only do something if the AddOn Loaded is the NyghtsNotebook AddOn
	if addonName == NyghtsNotebook.name then
		NyghtsNotebook:Initialize()
	end
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(NyghtsNotebook.name, EVENT_ADD_ON_LOADED, NyghtsNotebook.OnAddOnLoaded)