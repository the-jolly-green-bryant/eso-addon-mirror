So guys, we are proud to present and welcome you to our very own raid addon. This hasn’t been trialed with a fullish group yet, but the signs are promising, and we hope everyone is on board for giving it a go for Wednesdays raid.

There are a few things that stand out with this addon that others addons/other guilds have not done, in which we’d like to keep this inside the guild.

Drop the Ultibomb folder in your addons folder, /reloadui, and that is it for now.

**Commands:**

**If you are running a destro, or a negate, or both, you will need to run this command in group:**

```
/ultibomb on
```
This will make the addon visible, and begin to send your ultimate data, and recieve other group members ultimate data

**If you wish to have the addon present, but don’t have either a Negate or Destro:**

```
/ultibomb watch
```

This will turn the addon on, in a read-only mode. This means the addon will be visible for you, updating with group data. But your information will not be sent, thus not creating unnecessary network traffic.

**If you need to refresh the addon, if a value is wrong, or looks like it is not updating:**

```/ultibomb refresh```
or
```/ultibomb r```

**To turn the addon off and to stop streaming data back and forth:**

```/ultibomb off```

Some words of warning, if you have any other Ultimate addon running, Rueultimate, RaidNotifier, Odehack or some other guild variety, these will generate unneccessary messages and bog down your network traffic. And/or potentially causing this addon to stop/crash.

Also, if you have the addon **LibGroupSocket** enabled in your Addons, please turn it off, as it’ll conflict with the internal version of the same addon within Ultibomb