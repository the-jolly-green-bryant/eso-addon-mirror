
var basePath = "../../SavedVariables/";
var outputPath = "Modules/"
var saveFiles = [
	"HarvestMapAD",
	"HarvestMapEP",
	"HarvestMapDC",
	"HarvestMapDLC",
	"HarvestMapNF"
]

var saveVarTables = {
	HarvestMapAD : "HarvestAD_SavedVars",
	HarvestMapEP : "HarvestEP_SavedVars",
	HarvestMapDC : "HarvestDC_SavedVars",
	HarvestMapDLC : "HarvestDLC_SavedVars",
	HarvestMapNF : "HarvestNF_SavedVars"
}


var reader = WScript.CreateObject("Scripting.FileSystemObject")
function readSaveFile(path) {
	var file = reader.OpenTextFile(path);
	var content = file.ReadAll();
	file.close()
	return content
}

function getEmptySaveFile(savedVar) {
	return saveVarTables[savedVar] + readSaveFile("Main/emptyTable.lua")
}

function exchangeData(savedVar, input, outputFile) {
	var connection = WScript.CreateObject("Msxml2.XMLHTTP");
	connection.open('post', "http://harvestmap.binaryvector.net:8081/", false);
	
	connection.onreadystatechange = function() {
		if (connection.readyState == 4) {
			if (connection.status == 200) {
				var fileStream = WScript.CreateObject("ADODB.Stream");
				fileStream.open();
				fileStream.type = 1;
				fileStream.write(connection.responseBody);
				fileStream.saveToFile(outputFile, 2);
				fileStream.close();
				WScript.Echo("Saved new data for file: " + savedVar)
			} else {
				WScript.Echo("Error while merging file: " + savedVar)
				if (connection.responseText != "") {
					WScript.Echo("The server answered:")
					WScript.Echo(connection.responseText)
				}
			}
		} else if (connection.readyState == 3) {
			WScript.Echo("Receiving answer...")
		} else if (connection.readyState == 2) {
			WScript.Echo("Finished uploading the file.")
		} else if (connection.readyState == 1) {
			WScript.Echo("Uploading file: " + savedVar)
		}
	}
	try {
		connection.send(input)
	} catch(exception) {
		WScript.Echo("Error while downloading data: " + exception.message)
	}
}



for (i = 0; i < saveFiles.length; i++) {
	var savedVar = saveFiles[i];
	var saveFile = basePath + savedVar + "-backup.lua"
	var outputFile = outputPath + savedVar + "/" + savedVar + ".lua"
	var content
	//WScript.Echo(outputFile)
	try {
		if (reader.FileExists(saveFile)) {
			//WScript.Echo("Open file: " + savedVar);
			content = readSaveFile(saveFile);
		} else {
			WScript.Echo("Could not find file: " + savedVar);
			WScript.Echo("Trying again with an empty file...");
			content = getEmptySaveFile(savedVar)
		}
	} catch(exception) {
		WScript.Echo("Could not read file: " + exception.message)
		continue;
	}
	exchangeData(savedVar, content, outputFile)
	WScript.Echo("")
}
