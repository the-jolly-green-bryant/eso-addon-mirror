#LibSort 1.0

**Table of Contents**  
- [Rationale](#user-content-rationale)
    - [API](#user-content-api)
        - [Register](#user-content-register)
        - [RegisterNumeric](#user-content-registernumeric)
        - [RegisterBoolean](#user-content-registerboolean)
        - [RegisterString](#user-content-registerstring)
        - [Unregister](#user-content-unregister)
        - [RegisterDefaultOrder](#user-content-registerdefaultorder)

##Rationale

Currently, the way ESO sorts items is essentially by column, you have a data point for each item, eg, **name** and you sort the list of objects by that data point.

One thing that this default sorting mechanism offers, however, is a tiebreaker option. If we're sorting by **name** and a tiebreaker is required, because we are comparing two items with the same name, it falls to the tiebreaker datapoint to determine order of result, eg **stackSize**

Now the general sorting of items in the real world doesn't just fall to a single data point, or two. It generally requires a series of different datapoints to sort by, and we can take advantage of this 'tiebreaker' to 
chain together lists of different datapoints to sort by. So we can sort by **Name**, then by **StackSize**, then by **SlotId**. 

That's well and fine for what's existing in the current set of datapoints, however we have access to a lot more information about the item than is currently being stored.

To do this, however, we need to inject the required datapoints into the list object so that it has the required information to process the sort order as ascertained by our adjustment of how the tiebreakers chain together.

First we prehook ChangeSort. This will allow us to pick out the inventory being looked at, process the entries in there to inject the appropriate information, and then pass back to the original ChangeSort for the actual sorting.

We now have information about the item, where it's from (*slotType*) and where it is (*bag* and *index*)

And thanks to the new API, we have two new functions that will return information about the item in regards to what sort of weapon or armour it is.

So as an example, we'll use the new Weapon info function to inject data to allow the game to sort by weapontype

	GetItemWeaponType(link)

is the function we're using to obtain the information required. 

Or at least through

	local link = GetItemLink(bag, index)
	local weaponType = GetItemWeaponType(link)

If we then inject this information into the data object
	
	control:GetParent().dataEntry.data.weaponType = weaponType

we can then include another entry into the sortKeys for default header

	local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
	sortKeys["weaponType"] = {isNumeric = true, tiebreaker = "name"}

and we will end up sorting by the type of weapon returned by that function. (Note that as it's a pure number, and not necessarily in the order you may want, you'll have to actually adjust the real value of the datapoint to something more suitable)

---

In any case, now that we know what we need to do, this library should do most of the heavy lifting for you. Chances are I'll have to give it it's own Settings panel so people can reorder the sort order as they wish, but you should be able to register your addon to allow data injection and process the index/bag combinations to store whatever datapoints you want.

---
##API

###Register
This will register a numeric sortKey
    
    LibSort:Register(addonName, name, desc, key, func)

(Note this is an alias for **RegisterNumeric** and will assume a numeric sortKey)
- *addonName* - The name of the registering addon 
    + Example: "Item Sort"
- *name* - A unique registration name 
    + Example: "ISWeaponSort"
- *desc* - A description of how the sort applies 
    + Example: "Will sort by Weapon Type"
- *key* - A unique key used to identify the datapoint
    + Example: "weaponType"
- *func* - The function to call to retrieve the sort value. Function signature **needs** to be (bag, index)
    + Example: ItemSort.WeaponSort

###RegisterNumeric
This will register a numeric sortKey
    
    LibSort:RegisterNumeric(addonName, name, desc, key, func)
Arguments as above

###RegisterBoolean
This will register a boolean sortKey
    
    LibSort:RegisterBoolean(addonName, name, desc, key, func)
Arguments as above

###RegisterString
This will register a string sortKey

    LibSort:RegisterString(addonName, name, desc, key, func)
Arguments as above

###Unregister
This will unregister a sortKey registration

    LibSort:Unregister(addonName, name)

- *addonName* - The name of the registering addon 
    + Example: "Item Sort"
- *name* - A unique registration name 
    + Example: "ISWeaponSort"

###RegisterDefaultOrder
Your addon may have multiple registrations, and this function will allow you to indicate what order you want them in as a block. Call this function *after* you have completed your registrations

There are two tables you can pass in, for *low level* and *high level* keys. 

- Low level keys are values that are unique to certain types of items, like weaponType, and armourType. 
- High level keys are those linked to values that are common across larger swathes of items, like item level, or name. 
 

If you separate your keys in the two tables, LibSort will first chain all the low level keys before all high level keys, so that multiple addons can apply sort orders without getting cut off. (It's highly recommended that you split keys if you use high level definitions)

Default behaviour, by not using this API call will be order of registration at a high level to avoid breaking other registrations, and thus may not work as you expect, so make sure you set it.

    LibSort:RegisterDefaultOrder(addonName, keyTableLow, keyTableHigh)

- *addonName* -The name of the registering addon
    + Example: "Item Sort"
- *keyTableLow* - A table indicating the order of low level sortKeys for this addon
    + Example: {"weaponType", "armorEquipType", "armorType"}
- *keyTableHigh* - **Optional** A table indicating of the order of high level sortKeys for this addon
    + Example: {"subjectiveItemLevel"}

###SetDebugging
Set the debug flag for the library. Not actually used atm, but for future stuff.

    LibSort:SetDebugging(flag)

- *flag* - a boolean indicating if you wish to have debug messages
