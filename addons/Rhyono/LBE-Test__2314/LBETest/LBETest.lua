LBETestAddon = {
Name="LBE Test", 
Purpose="Testing",
Purpose2="Example",
Purpose3="Schema",
Purpose4="2DSchema",
Purpose5="Convert",
Purpose6="Mixed",
Purpose7="NDSchema",
PurposeVersion1="Old",
PurposeVersion2="New",
PurposeVersion3="Old2D",
PurposeVersion4="New2D",
}

function LBETestAddon.Test()
    --Define a prefix, using base 64
    if LBE:DefinePrefix("~1",LBETestAddon.Name,LBETestAddon.Purpose,64) then
        --Some sample data
        LBETestAddon.myData = {true,false,true,true,false,true,false,false}
        --Encode the data
        LBETestAddon.encoded = LBE:Encode(LBETestAddon.myData,LBETestAddon.Name,LBETestAddon.Purpose)
        --Pretend the data was placed in a message
        LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded
        --Parse the mail for only this addon and purpose
        LBETestAddon.newData = LBE:ParseDataToString(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose)       
		--[[
		--["newData"] = {
		--	[1] = {
		--		["addonName"] = "Test"
		--		["base"] = 64
		--		["data"] = "10110100"
		--		["prefix"] = "~1"
		--		["purpose"] = "Testing"
		--		["schema"] = {}
		--	}
		--}
		]]
		
       --Parse the data into a sub-table instead
        LBETestAddon.newData2 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose)    
		--[[
		--["newData2"] = {
		--	[1] = {
		--		["addonName"] = "Test",
		--		["base"] = 64,
		--		["data"] = {
		--			[1] = true,
		--			[2] = false,
		--			[3] = true,
		--			[4] = true,
		--			[5] = false,
		--			[6] = true,
		--			[7] = false,
		--			[8] = false,
		--		},	
		--		["prefix"] = "~1",
		--		["purpose"] = "Testing",
		--		["schema"] = {}
		--	}
		--}
		]]


        --Now let's try it with a second piece of encoded information; defaulting to base 256
        LBE:DefinePrefix("%a4",LBETestAddon.Name,LBETestAddon.Purpose2)
        LBETestAddon.encoded2 = LBE:Encode("0101010",LBETestAddon.Name,LBETestAddon.Purpose2)
        LBETestAddon.spoofedMail = LBETestAddon.encoded2 .. ' Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded
        --No purpose specified this time
        LBETestAddon.newData3 = LBE:ParseDataToString(LBETestAddon.spoofedMail,LBETestAddon.Name)   
		--[[
		--["newData3"] = {
		--	[1] = {
		--		["addonName"] = "Test",
		--		["base"] = 256,
		--		["data"] = "0101010",
		--		["prefix"] = "%a4",
		--		["purpose"] = "Example",
		--		["schema"] = {},
		--	},	
		--	[2] = {
		--		["addonName"] = "Test",
		--		["base"] = 64,
		--		["data"] = "10110100",
		--		["prefix"] = "~1",
		--		["purpose"] = "Testing",
		--		["schema"] = {},
		--	}	
		--}
		]]

		--How about a schema to decode the data back into?
		LBETestAddon.myData2 = {[15]=true,[13]=false,[90]=true,[11]=true}
		--nil or 256 for the default encoding, pass the data along to create a schema
		LBE:DefinePrefix("!!",LBETestAddon.Name,LBETestAddon.Purpose3,nil,LBETestAddon.myData2)
		--now include the data for the actual encoding
		LBETestAddon.encoded3 = LBE:Encode(LBETestAddon.myData2,LBETestAddon.Name,LBETestAddon.Purpose3)
		LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded3
		--with DecodeToString, you will simply get an ordered string, but it is allowed. If you're using a schema, I recommend always using DecodeToTable (fourth parameter of Parse set to false/not included)
		LBETestAddon.newData4 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose3) 
		--[[
		--["newData4"] = {
		--	[1] = {
		--		["addonName"] = "Test",
		--		["base"] = 256,
		--		["data"] = {
		--			[11] = true,
		--			[13] = false,
		--			[15] = true,
		--			[90] = true,
		--		},	
		--		["prefix"] = "!!",
		--		["purpose"] = "Schema",
		--		["schema"] = {
		--			[11] = 0,
		--			[13] = 0,
		--			[15] = 0,
		--			[90] = 0,
		--		},
		--		["schemaType"] = 1
		--	}	
		--}
		]]
		
		--What about a more complex schema?
		LBETestAddon.myData3 = {[2]={[3]=false,[7]=true,[4]=false},[5]={[3]=false,[6]=false,[9]=true},[3]={[1]=true,[2]=true,[3]=false}}
		LBE:DefinePrefix("T2",LBETestAddon.Name,LBETestAddon.Purpose4,nil,LBETestAddon.myData3)
		LBETestAddon.encoded4 = LBE:Encode(LBETestAddon.myData3,LBETestAddon.Name,LBETestAddon.Purpose4)
		LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded4
		LBETestAddon.newData5 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose4) 
		--[[
		--["newData5"] = {]
		--	[1] = {
		--		["addonName"] = "Test",
		--		["base"] = 256,
		--		["data"] = {
		--			[2] = {
		--				[3] = false,
		--				[4] = false,
		--				[7] = true,
		--			},	
		--			[3] = {
		--				[1] = true,
		--				[2] = true,
		--				[3] = false,
		--			},	
		--			[5] = {
		--				[3] = false,
		--				[6] = false,
		--				[9] = true,
		--			},	
		--		},		
		--		["prefix"] = "T2",
		--		["purpose"] = "2DSchema",
		--		["schema"] = {
		--			[2] = {
		--				[3] = 0,
		--				[4] = 0,
		--				[7] = 0,
		--			},	
		--			[3] = {
		--				[1] = 0,
		--				[2] = 0,
		--				[3] = 0,
		--			},	
		--			[5] = {
		--				[3] = 0,
		--				[6] = 0,
		--				[9] = 0,
		--			},	
		--		},
		--		["schemaType"] = 2
		--	}
		--}
		]]

		--Or a schema of multiple dimensions
		LBETestAddon.myNDTable = {
			[2]={
				[1] = {
					[3]=false,
					[7]=true,
					[4]=false
				},
			},
			[5]={
				[3] = {
					[3]=false,
					[6]=false,
					[9]=true
				},
			},
			[3]={
				[1] = {
					[1]=true,
					[2]=true,
					[3]=false
				},
			}
		}
		LBE:DefinePrefix("ND",LBETestAddon.Name,LBETestAddon.Purpose7,nil,LBETestAddon.myNDTable)
		LBETestAddon.encoded7 = LBE:Encode(LBETestAddon.myNDTable,LBETestAddon.Name,LBETestAddon.Purpose7)
		LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded7
		LBETestAddon.newData8 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose7) 
		--[[
		["newData8"] = {
			[1] = {
				["addonName"] = "LBE Test",
				["base"] = 256,
				["data"] = {
					[2] = {
						[1] = {
							[3] = false,
							[4] = false,
							[7] = true,
						}	
					},		
					[3] = {
						[1] = {
							[1] = true,
							[2] = true,
							[3] = false,
						},	
					},		
					[5] = {
						[3] = {
							[3] = false,
							[6] = false,
							[9] = true,
						},	
					},		
				},			
				["prefix"] = "ND",
				["purpose"] = "NDSchema",
				["schema"] = <removed for brevity>,
				["schemaType"] = 2
			}	
		}
		]]
	
		--DefinePrefix should normally be one of the first things done, so if you generate your user data table from an auto-indexed ID list later: use ConvertTable on the seed IDs
		LBETestAddon.myIdTable = {15,30,40,70,100,120}
		LBE:DefinePrefix("F1",LBETestAddon.Name,LBETestAddon.Purpose5,nil,LBE:ConvertTable(LBETestAddon.myIdTable))
		--Later on when you have data
		LBETestAddon.myData4 = {[15]=true,[30]=false,[40]=false,[70]=false,[100]=false,[120]=false}
		LBETestAddon.encoded5 = LBE:Encode(LBETestAddon.myData4,LBETestAddon.Name,LBETestAddon.Purpose5)
		LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded5
		LBETestAddon.newData6 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose5)	
		--[[
		--["newData6"] = {
		--	[1] = {
		--		["addonName"] = "Test",
		--		["base"] = 256,
		--		["data"] = {
		--			[15] = true,
		--			[30] = false,
		--			[40] = false,
		--			[70] = false,
		--			[100] = false,
		--			[120] = false,
		--		},
		--		["prefix"] = "F1",
		--		["purpose"] = "Convert",
		--		["schema"] =  {
		--			[15] = 0,
		--			[30] = 0,
		--			[40] = 0,
		--			[70] = 0,
		--			[100] = 0,
		--			[120] = 0,
		--		},	
		--		["schemaType"] = 1
		--	}
		--}
		]]
		--Mixing numeric and non-numeric indexes can only be done in different dimensions
		LBETestAddon.myMixedTable = {["dog"]={[1]=true,[2]=false,[3]=true},["cat"]={[3]=false,[4]=true,[5]=true,[8]=false},["bird"]={[11]=true,[12]=false}}
		LBE:DefinePrefix("X1",LBETestAddon.Name,LBETestAddon.Purpose6,nil,LBETestAddon.myMixedTable)
		LBETestAddon.encoded6 = LBE:Encode(LBETestAddon.myMixedTable,LBETestAddon.Name,LBETestAddon.Purpose6)
		LBETestAddon.spoofedMail = 'Hi human friend, here\'s my data of the variety you are fond of: ' .. LBETestAddon.encoded6
		LBETestAddon.newData7 = LBE:Parse(LBETestAddon.spoofedMail,LBETestAddon.Name,LBETestAddon.Purpose6)
		--[[
		--["newData7"] = {
		--	[1] = {
		--		["addonName"] = "Test"
		--		["base"] = 256
		--		["data"] = {
		--			["bird"] = {
		--				[11] = true,
		--				[12] = false,
		--			},	
		--			["cat"] = {
		--				[3] = false,
		--				[4] = true,
		--				[5] = true,
		--				[8] = false,
		--			},	
		--			["dog"] = {
		--				[1] = true,
		--				[2] = false,
		--				[3] = true,
		--			},
		--		}
		--		["prefix"] = "X1",
		--		["purpose"] = "Mixed",
		--		["schema"] = {
		--			["bird"] = {
		--				[11] = 0,
		--				[12] = 0,
		--			},	
		--			["cat"] = {
		--				[3] = 0,
		--				[4] = 0,
		--				[5] = 0,
		--				[8] = 0,
		--			},	
		--			["dog"] = {
		--				[1] = 0,
		--				[2] = 0,
		--				[3] = 0,
		--			},
		--		},
		--		["schemaType"] = 2,
		--	}	
		--}
		]]	
    end
	
	-- show in Zgoo for convenience
	LBETestAddon.Show()
end

function LBETestAddon.Versioning()
	--Every time the structure of the data changes, the prefix should change. 
	
	--If the new structure is a direct extension to the old structure (numeric index with greater value or alphabetical index later in the alphabet), then you can use the old data with the new schema like this:
	LBETestAddon.version1Data = "V1фo3" --contents before encoding: {[5]=true,[6]=false,[7]=true}
	LBETestAddon.version2Schema = {[5]=false,[6]=false,[7]=false,[8]=false,[9]=false} --contains the same base indexes, but has some extra
	--create the old prefix but with the new schema
	LBE:DefinePrefix("V1",LBETestAddon.Name,LBETestAddon.PurposeVersion1,64,LBETestAddon.version2Schema)
	--create the new prefix with its new schema as well
	LBE:DefinePrefix("V2",LBETestAddon.Name,LBETestAddon.PurposeVersion2,64,LBETestAddon.version2Schema)
	--with mixed schemas, you can't use decode because it needs to know the ONE prefix in play; use Parse instead (this example is only using one data string and wants a table, so we'll use the exact function)
	--there are multiple schemas from the same addon that are considered acceptable, so do not define the purpose
	LBETestAddon.version2ParseData = LBE:ParseFirst(LBETestAddon.version1Data,LBETestAddon.Name)
	--if data is returned, it likely succeeded
	if #LBETestAddon.version2ParseData > 0 then
		-- it will succeed and the result will be {[5]=true,[6]=false,[7]=true,[8]=false,[9]=false}		
		LBETestAddon.version2Data = LBETestAddon.version2ParseData[1].data
	else
		--an even older version that wasn't parsed; this branch won't be reached in this example case
		--If the schema has utterly changed (e.g. went from one to two dimension, changed from numeric indexes to alphabetical, added numeric indexes of sporadic value [adding a 3 when 1 and 4 exist], etc.), you will need to ignore the old data and return a fresh blank version of the current schema
		LBETestAddon.version2Data = LBE:CloneSchema(LBETestAddon.Name,LBETestAddon.PurposeVersion2)		
	end
	
	--If the schema has deviated in many ways (e.g. 2D table that now has an extra value or any indexes removed from the new table), you will need to decode it with the old schema, then convert it to the new schema
	LBETestAddon.version3Data = "V3фOg5" --contents before encoding: {["car"]={[3]=false,[4]=false,[5]=true,[6]=true},["plane"]={[1]=true,[2]=false,[3]=true}}
	LBETestAddon.version3Schema = {["car"]={[3]=false,[4]=false,[5]=false,[6]=false},["plane"]={[1]=false,[2]=false,[3]=false}}
	LBE:DefinePrefix("V3",LBETestAddon.Name,LBETestAddon.PurposeVersion3,64,LBETestAddon.version3Schema)
	
	LBETestAddon.version4Schema = {["car"]={[3]=false,[4]=false,[5]=false},["plane"]={[1]=false,[2]=false,[3]=false},["zebra"]={[2]=false,[3]=false,[4]=false}}
	LBE:DefinePrefix("V4",LBETestAddon.Name,LBETestAddon.PurposeVersion4,64,LBETestAddon.version4Schema)
	
	--parse the data
	LBETestAddon.version4ParseData = LBE:ParseFirst(LBETestAddon.version3Data,LBETestAddon.Name)
	if #LBETestAddon.version2ParseData > 0 then
		--check the version via the purpose
		if LBETestAddon.version4ParseData[1].purpose == LBETestAddon.PurposeVersion3 then
			--since it's old, it will need converted with the new schema's info; this would still work even if the base used was different
			LBETestAddon.version4Data = LBE:ConvertSchema(LBETestAddon.version4ParseData[1].data,LBETestAddon.Name,LBETestAddon.PurposeVersion4)
			--the data now fits into the allowed values of the new schema
			--[[
			--["version4Data"] = {
			--	["car"] = {
			--		[3] = false,
			--		[4] = false,
			--		[5] = true,
			--	}	,
			--	["plane"] = {
			--		[1] = true,
			--		[2] = false,
			--		[3] = true,
			--	},
			--	["zebra"] = {
			--		[2] = false,
			--		[3] = false,
			--		[4] = false,
			--	},
			--}
			]]
		elseif LBETestAddon.version4ParseData[1].purpose == LBETestAddon.PurposeVersion4 then
			--this branch won't be reached, but if it was the newest version
			LBETestAddon.version4Data = LBETestAddon.version4ParseData[1].data
		else
			--this branch won't be reached, but if it was another version 
			LBETestAddon.version4Data = LBE:CloneSchema(LBETestAddon.Name,LBETestAddon.PurposeVersion4)
		end
	else
		--this branch won't be reached, but if it was another version 
		LBETestAddon.version4Data = LBE:CloneSchema(LBETestAddon.Name,LBETestAddon.PurposeVersion4)	
	end
	
	-- if the data had come from a safe source (such as saved variables where you know which schema (or schemas if including previous versions) to expect, you can do a much shorter procedure
	LBETestAddon.version4xData = LBE:ParseTrusted(LBETestAddon.version3Data,LBETestAddon.Name,LBETestAddon.PurposeVersion4)
	
	-- show in Zgoo for convenience
	LBETestAddon.Show()
end


function LBETestAddon.Show()
	if Zgoo then
		Zgoo.CommandHandler(LBETestAddon)
	end
end

SLASH_COMMANDS["/lbetest"] = LBETestAddon.Test
SLASH_COMMANDS["/lbetestversioning"] = LBETestAddon.Versioning
if Zgoo then
	SLASH_COMMANDS["/lbetestshow"] = LBETestAddon.Show
end
