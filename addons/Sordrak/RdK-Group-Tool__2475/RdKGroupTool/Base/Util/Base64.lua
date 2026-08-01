-- RdK Group Tool Base64
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.base64 = RdKGToolUtil.base64 or {}
local RdKGToolBase64 = RdKGToolUtil.base64
RdKGToolBase64.returnCodes = {}
RdKGToolBase64.returnCodes.SUCCESS = 0
RdKGToolBase64.returnCodes.FAILED = 1

local keySpace = { [0] =
   'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
   'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
   'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
   'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}

function RdKGToolBase64.Encode(content)
	local retVal = ""
	local errorCode = RdKGToolBase64.returnCodes.FAILED
	if type(content) == "string" then
		content = {content:byte(1,content:len())}
	
	end
	return retVal, errorCode
end

function RdKGToolBase64.Decode(content)
	local retVal = ""
	local errorCode = RdKGToolBase64.returnCodes.FAILED
	if type(content) == "string" then
	
	
	end
	return retVal, errorCode
end