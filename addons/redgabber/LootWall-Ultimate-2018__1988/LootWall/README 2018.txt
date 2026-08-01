This addon is a continued project started by @Vicodine in 2014.
My revision 1.0 add some new features as described below.


How it works ?

1st, The "Min. quality to keep" filter is applied : the eligible items are keep, non-eligible are junked. 
It concerns ALL the items but the "trash and white". For these, an additional check is done, see 3th.

2nd, The "trait and crafting ressources" filters are applied.

3th, The "Normal & Trash quality" filter operates in last, but only when all others filters has been applied without effect.

The stock & currency is always checked when a destroy action is fired.

The stock limit is applied when you have an existing stock of an item in bag, and you want to prevent unwanted destroy.
For example, you have a x100 pile of materials in your bag and for any reason you change the behavior to destroy these materials : your entire pile would be destroyed, very dangerous.
Here you can set a threashold that check your existing stock and prevent from destruction.

This may also be applied when you looted too much identical items in one loot. It can happen in farming areas or dungeons. That way, you Junk the items instead of destroying it. 
When is it usefull ? if you loot same x30 materials in one shot, maybe you would at least be interested to push it to Junk on the fly. 

The prompted "out of combat Lootbox" override the rules, but the destroy check (automatic or manual loot) is always performed. "stock and currency" thresholds are respected. 

The prompted lootBox is used to have full control over automatic behaviors. Then your rules are saved and loaded prior to your next gaming session and applied first to any loot.

I wanted do not offer more filtering options. That way, the addon is easy to configure and not "rule headhache".
More you have filters up, more you can go wrong. counterpart of that, filters are a little bit more permissive.

Also, i wanted to respect the @Vicodine original concept i like, when i choose to continue his work.

The filtering is not as deep as others addons, but i wanted it user-friendly to match the usual common way of use.
I don't think Teso need an hardcore farming tool. But, due to the trash concept and due to the bag out of space, we need a better control over the inventory.

At least, i just considerate this as a confortable pragmatic tool that occurate in most common situation.

For deeper filters, you can check for others addons and do the trick you want.

DO NOT use multiple inventory looter addons together. Some filtering edge effects could occurs. Be aware of that.

I highly recommand to disable automatic trash sales at vendors, even if the addon suggests to enable it.

Don't miss to activate auto-loot in gameplay settings.


Enjoy :)


LootWall Ultimate continued by @Redgabber 2018
v 1.0.8 
      + Bump API 100023 SumerSet
      + Jewelry crafting and researchable types added to filters
      + modified rule for stock limit, now keep instead of junk
v 1.0.7
      + now the advanced lootbox show the item popup and auto-close
v 1.0.6 
      + minor correction
v 1.0.5
      + minor fix to chat when item is pending
      + added itemlink to chat when the prompt lootbox window opens.
v 1.0.4
      + extended items type exclusions
      + modified currency slider, now minimum is zero
v 1.0.3
      + setup : new calibration for better income on low quality items
      + setup : new calibration to prevent destroy action
      + new text info in chat box
      + modified check on normal quality. Now same as trash quality, but with currency exception.
      + somes fixes
v1.0.2 
      + modified text
v1.0.1
      + modified text and added ruleset alert to chat
v 1.0
+ added auto "Keep and unjunk" action
+ added auto "Junk" action
+ added auto "Destroy ALL" action
+ added log to chat (actions, itemlink, icons, looted & stock quantities, ruleset, warning)
+ Destroy is now secure and safe to use
+ modified prompt rules (no longer prompt for lower quality items if no specific behavior, go to trash)
+ Better control of Prompt action
+ more secure OnInventoryUpdate
+ now soul gems are always Keep
+ modified old text with new features
+ Strealined. Smoother to use


For deeper filters, you can check for others addons and do the trick you want.