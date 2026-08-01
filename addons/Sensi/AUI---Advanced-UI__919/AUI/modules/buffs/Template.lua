local templates = {}

function AUI.Buffs.GetThemeNames()
	local names = {}

	for _internName, data in pairs(templates) do	
		table.insert(names, {[_internName] = data.name})
	end

	return names
end

function AUI.Buffs.GetCurrentTemplateData()
	return currentTemplate	
end

function AUI.Buffs.AddTemplate(_name, _internName, _version, _data)
	
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.templateData = _data

	if not templates[_internName] then
		templates[_internName] = data
	end
end

function AUI.Buffs.LoadTemplate(_name)
	local templateData = templates[_name]
	
	if not templateData then
		_name = "AUI_Tactical"
		templateData = templates[_name]
	end

	templateData.settings = {}
	templateData.settings.version = templateData.version		

	currentTemplate = templateData
	
	AUI.Buffs.LoadSettings()
	
	return templateData
end