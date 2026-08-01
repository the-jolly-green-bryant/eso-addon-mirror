LibLanguage

A library of localization functionality extracted from my LibSFUtils library for general accessibility.
The function here is designed to load strings for the appropriate client language (if available) and 
load the strings from your default language if the client language is unavailable.

This library simplifies and standardizes the content of the language tables to make it easier for
people to contribute translations for your addon. 


Language Table(s)

In order to support multiple languages with your addon, you need to create a table that lists all
of the strings that you display to the user from your addon, assigning them a key that you will
use to retrieve the string value with GetString(). This language table itself is assigned to the two 
character language key for the language it supports.

For example: You could have the following string table defined:
    
    local AC_localization_strings = {
        de = {
            AC_IAKONI_TAG= "Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_1= "Set#1",
            AC_IAKONI_CATEGORY_SET_1_DESC= "#1 Set aus dem AddOn Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_2= "Set#2",
            AC_IAKONI_CATEGORY_SET_2_DESC= "#2 Set aus dem AddOn Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_3= "Set#3",
            AC_IAKONI_CATEGORY_SET_3_DESC= "#3 Set aus dem AddOn Iakoni's Gear Changer",
            },
        
        en = {
            AC_IAKONI_TAG= "Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_1= "Set#1",
            AC_IAKONI_CATEGORY_SET_1_DESC= "#1 Set from Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_2= "Set#2",
            AC_IAKONI_CATEGORY_SET_2_DESC= "#2 Set from Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_3= "Set#3",
            AC_IAKONI_CATEGORY_SET_3_DESC= "#3 Set from Iakoni's Gear Changer",
        },
           
        zh = {
            AC_IAKONI_TAG= "Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_1= "装备配置#1",
            AC_IAKONI_CATEGORY_SET_1_DESC= "#1 号装备配置 Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_2= "装备配置#2",
            AC_IAKONI_CATEGORY_SET_2_DESC= "#2 号装备配置 Iakoni's Gear Changer",
            AC_IAKONI_CATEGORY_SET_3= "装备配置#3",
            AC_IAKONI_CATEGORY_SET_3_DESC= "#3 号装备配置 Iakoni's Gear Changer",
        },
    }
	
This particular table provides support for German, English, and Chinese strings. You would then
initialize your localizations when your addon loads, and after that in order to get the appropriate
string for AC_IAKONI_TAG you would simply call GetString(AC_IAKONI_TAG).


Loading the Language Table(s)

Basically the default language table is loaded first as the strings table for your addon
and then the client language table (if available) updates the strings table with the new
language strings where provided.

Note that your default language table must have ALL of the strings defined for your addon.
If the other language tables miss a particular string value, then the default language value
is left unchanged.

function LibLanguage.LoadLanguage(localization_languages_table, defaultLang)
    Add strings to the string table for the client language (or
    the default language if the client language did not have strings
    defined for it). The localization_strings parameter is a table of language tables
    of localization strings, and the defaultLang parameter defaults to "en" if not
    provided.
	
	With the example table defined above, you would call you initialization
	function:
    
        LibLanguage.LoadLanguage(AC_localization_strings,"en")


Separate Language Files

You can split the definitions of 

        AC_localization_strings["en"], 
		AC_localization_strings["de"], and 
		AC_localization_strings["zh"]
		
into separate files (en.lua for the default, de.lua, zh.lua, etc). Following our example we would have a 
Localisation\de.lua file which would contain:

	AC_localization_strings = AC_localization_strings  or {}

	AC_localization_strings]["de"] = {
		AC_IAKONI_TAG= "Iakoni's Gear Changer",
		AC_IAKONI_CATEGORY_SET_1= "Set#1",
		AC_IAKONI_CATEGORY_SET_1_DESC= "#1 Set aus dem AddOn Iakoni's Gear Changer",
		AC_IAKONI_CATEGORY_SET_2= "Set#2",
		AC_IAKONI_CATEGORY_SET_2_DESC= "#2 Set aus dem AddOn Iakoni's Gear Changer",
		AC_IAKONI_CATEGORY_SET_3= "Set#3",
		AC_IAKONI_CATEGORY_SET_3_DESC= "#3 Set aus dem AddOn Iakoni's Gear Changer",
	}


Then add the following lines to your addon manifest (at the top - the string tables must be 
declared before the code tries to use them):

Localisation\en.lua
Localisation\$(language).lua

(This assumes that your strings files are in a directory called Localization, and that en.lua 
is your default language. $(language) is interpreted into the language that the client is set for, so if 
you are running a German client, the manifest would try to load Localisation\de.lua if it exists.)

This way you will only load the strings for two languages (at most) instead of all of them you have available.
