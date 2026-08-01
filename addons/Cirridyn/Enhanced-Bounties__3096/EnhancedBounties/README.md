# Enhanced Bounties
Enhanced Bounties is a mod for The Elder Scrolls Online.

## Introduction
Enhanced Bounties tracks stolen items in the player's inventory, displaying the number and gold value of these items both on the Infamy UI and in the arrest dialog.

### **Who** is Enhanced Bounties?
Enhanced Bounties is not a "who," but I am! I'm just a gamer and tech geek who enjoys programming and problem solving. Sometimes I use these powers for good.

### **What** is Enhanced Bounties?
Enhanced Bounties monitors the player character's inventory, including worn items, and displays to the player the overall quantity and total gold value of all stolen items.

### **When** is Enhanced Bounties?
Enhanced Bounties updates its stored values whenever items enter or leave the tracked inventories, as well as when the addon is first loaded.

### **Where** is Enhanced Bounties?
A new text label is added alongside the bounty display of the Infamy UI, showing the details of stolen items so long as the player has a bounty and is carrying stolen items. When arrested by a guard, the dialog option to pay the bounty includes the same information.

### **Why** is Enhanced Bounties?
I was previously using the addon True Bounty, made by kawamonkey, but I was dissatisfied that it only displayed the information in the "pay bounty" arrest dialog option. With True Bounty as my basis, I decided to create something similar, however with a number of technical improvements and the addition of an Infamy UI component to display the information "live" to the player.

### **How** is Enhanced Bounties?
It's doing well, I think. Bits don't speak, so I can't be sure. How it functions is simple. Whenever an event occurs that involves an item entering or leaving the bag or worn items inventories, the addon will take stock of all stolen items in those two inventories and their gold value. The data of the "pay bounty" arrest dialog option is also overridden, replacing the existing dialog text with an updated version including the information tracked by this addon if the player has stolen items in their possession.

**[Compatibility Warning]** Due to the nature of how dialog option overriding must function, I cannot promise Enhanced Bounties will or even can be compatible with other addons which might modify dialog options.

## Manual Installation
To install this addon manually, extract the contents of the ZIP archive to your Elder Scrolls Online "AddOns" folder.

## Changelog
*1.3.2*
> - Adjusted arrest dialog forfeit text.

*1.3.1*
> - Adjusted arrest dialog code to only modify the bounty payment dialog option if the player possesses stolen items

*1.3.0*
> - Updated Infamy UI display to include quantity of stolen items

*1.2.0*
> - Implemented comparable functionality to [True Bounty](https://www.esoui.com/downloads/info3008-TrueBounty.html) to
> update the arrest forfeit dialog option

*1.1.0*
> - Refactored current implementation

*1.0.0*
> - Implemented stolen goods gold value updates when item interactions occur within backpack or equipment
> - ZOS Infamy UI
>   - Added stolen goods gold value display alongside bounty price