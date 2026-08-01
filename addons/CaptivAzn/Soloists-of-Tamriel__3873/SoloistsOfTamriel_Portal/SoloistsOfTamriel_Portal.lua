-- *** SoloistsOfTamriel_Portal ***
-- *** created by CaptivAzn ***
-- *** for the ESO Guild - Soloists of Tamriel ***

-- *** NO PERMISSION is given to copy, change, edit, nor alter the files, coding, nor content of ***
-- *** this addon without the express written permission of this addon's creator, CaptivAzn. ***

-- *** THIS ADD-ON IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR ***
-- *** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, ***
-- *** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE ***
-- *** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER ***
-- *** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ***
-- *** OUT OF OR IN CONNECTION WITH THE ADD-ON OR THE USE OR OTHER DEALINGS IN ***
-- *** THE ADD-ON. ***


SoloistsOfTamriel_Portal = {}
SoloistsOfTamriel_Portal.name = "SoloistsOfTamriel_Portal"

function SoloistsOfTamriel_Portal.PortToHouse0()
	d("...porting you to your HOME, Willowpond Haven! :)")
	RequestJumpToHouse(107)
end

function SoloistsOfTamriel_Portal.PortToHouse99()
	d("...porting you to your HOME, Velothie Reverie! :)")
	RequestJumpToHouse(20)
end

function SoloistsOfTamriel_Portal.PortToHouse1()
	d("...magically porting you to the Soloists of Tamriel's BANNERED GUILDHALL in Blackwood... Ayleid well is at the other end of the bridge. Crafting stations & assistants are in the 2nd house. Mundus stones are up the ramp. Target dummies are in the waterfall cave. Have an awesome day! :)")
	JumpToSpecificHouse("@CaptivAzn", 107)
end

function SoloistsOfTamriel_Portal.PortToHouse2()
	d("...magically porting you to the Soloists of Tamriel's DOOMCHAR GUILDHALL in Malabal Tor, with crafting stations & target dummies available. Have a fantastic day! :)")
	JumpToSpecificHouse("@uriX3", 90)
end

function SoloistsOfTamriel_Portal.PortToHouse3()
	d("...magically porting you to the Soloists of Tamriel's CRAFTING CLOSET in Elsweyr for a chill crafting time! :)")
	JumpToSpecificHouse("@CaptivAzn", 68)
end

function SoloistsOfTamriel_Portal.PortToHouse4()
	d("...porting you to the Soloists of Tamriel's ALDMERI DOMINION hub in Grahtwood. Enjoy! :)")
	JumpToSpecificHouse("@CaptivAzn", 13)
end

function SoloistsOfTamriel_Portal.PortToHouse5()
	d("...porting you to the Soloists of Tamriel's DAGGERFALL COVENANT hub in Glenumbra. Enjoy! :)")
	JumpToSpecificHouse("@CaptivAzn", 2)
end

function SoloistsOfTamriel_Portal.PortToHouse6()
	d("...porting you to the Soloists of Tamriel's EBONHEART PACT hub in Mournhold. Enjoy! :)")
	JumpToSpecificHouse("@CaptivAzn", 6)
end

function SoloistsOfTamriel_Portal.PortToHouse7()
	d("...quietly porting you to the Soloists of Tamriel's OUTLAWS REFUGE hub in Reaper's March for a quick getaway! :)")
	JumpToSpecificHouse("@CaptivAzn", 23)
end

function SoloistsOfTamriel_Portal.OnAddOnLoaded(event, addonName)
	if addonName == SoloistsOfTamriel_Portal.name then
		SLASH_COMMANDS["/rtb1"] = SoloistsOfTamriel_Portal.PortToHouse0
		SLASH_COMMANDS["/rtb2"] = SoloistsOfTamriel_Portal.PortToHouse99
		SLASH_COMMANDS["/rtb"] = SoloistsOfTamriel_Portal.PortToHouse1
		SLASH_COMMANDS["/sot1"] = SoloistsOfTamriel_Portal.PortToHouse1
		SLASH_COMMANDS["/sot2"] = SoloistsOfTamriel_Portal.PortToHouse2
		SLASH_COMMANDS["/sot3"] = SoloistsOfTamriel_Portal.PortToHouse3
		SLASH_COMMANDS["/ad"] = SoloistsOfTamriel_Portal.PortToHouse4
		SLASH_COMMANDS["/dc"] = SoloistsOfTamriel_Portal.PortToHouse5
		SLASH_COMMANDS["/ep"] = SoloistsOfTamriel_Portal.PortToHouse6
		SLASH_COMMANDS["/outlaw"] = SoloistsOfTamriel_Portal.PortToHouse7
		EVENT_MANAGER:UnregisterForEvent(SoloistsOfTamriel_Portal.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SoloistsOfTamriel_Portal.name, EVENT_ADD_ON_LOADED, SoloistsOfTamriel_Portal.OnAddOnLoaded)
