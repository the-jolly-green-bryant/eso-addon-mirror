# SocialIcons

SocialIcons displays icon of users in your friends list and guild rooster windows.


As I am a fan of the concept "An Addon should do one thing and do it well", I wanted to create a small addon that only focuses on displaying player icons from LibCustomIcons in friends list and guild rooster windows.
But the main reason is that OSI has not yet implemented the new LCI API and will soon break when merged textures will come to LibCustomIcons. So this addon is also a workaround for that issue.
SocialIcons is made to be compatible with OdySupportIcons, so even if you use both addons, they will not conflict with each other.

If you want to see player icons in those windows without needing to install a fully featured addon like OdySupportIcons, this is the addon for you!

## FAQ
- **Will you add support for icons in chat?**
- No! This is not possible anymore after LibCustomIcons switches to use merged textures because there is no way to inject coordinates into textures embedded into strings. But I already asked ZoS for this feature. When they will implement it, i will add support for that. But until then, it is not possible. 
If you want chat icon support now, you have to use OdySupportIcons. But be aware that when LibCustomIcons switches to merged textures, the OdySupportIcons chat icon feature will also break.


- **Will there be an option to display icons over players heads in the world?**
- No! This addon only focuses on friends list and guild rooster windows. If you want that feature, you have to use OdySupportIcons.


- **Will there be an option to display icons in other windows like group roster?**
- No! This addon is ment to be as minimal invasive as possible. There are reasons for this. How should you handle icon prioritization with other addons like OSI and Crutch? Should they check if you have SocialIcons installed? Should i check? That just makes it a lot more complicated for no reason. If you want icons in other windows, use OdySupportIcons or Crutch.


## Credits
This Project is heavily inspired by OdySupportIcons feature to display player icons in guild & friend list! Even tho the system works differently, the idea is basically the same. So credits where credits are due: Thanks to the authors of OdySupportIcons for the inspiration!
This Addon has copies of the status textures from OdySupportIcons! They are NOT made by me! All credits for those textures go to the authors of OdySupportIcons!