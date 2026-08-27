Legacy Shopping List recovery
=============================

This compatibility loader recovers lists stored before the add-on manifest was
renamed from ShoppingList to GravvyShoppingList.

Installation
------------

1. Close ESO and back up both SavedVariables/ShoppingList.lua and
   SavedVariables/GravvyShoppingList.lua if they exist.
2. Copy the ShoppingList folder beside the GravvyShoppingList folder in ESO's
   AddOns directory. Do not copy it inside GravvyShoppingList.
3. Enable "Shopping List Legacy Data Recovery" and "Shopping List" in ESO's
   Add-Ons screen, then log in or reload the UI.

The current add-on creates a safety copy, merges every old active and archived
list with the current data, and records that source so it cannot import twice.
Existing current lists and settings are not overwritten. The loader deliberately
does not create the obsolete global named ShoppingList, so it does not trigger
Master Merchant's retired-importer warning.

After Shopping List reports the recovered list count, this compatibility loader
may be disabled. Keep the SavedVariables files and a full SLB1 backup until the
recovered lists have been checked.
