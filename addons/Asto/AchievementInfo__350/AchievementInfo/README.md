# AchievementInfo

[![Version Status](https://monitoring.f-brinker.de/api/badge/18/status?style=plastic&upLabel=Up%20to%20date&downLabel=Outdated)](https://monitoring.f-brinker.de/status/eso)
[![Build Status](https://git.f-brinker.de/fbrinker/elderscrolls-addon-achievementInfo/actions/workflows/build.yaml/badge.svg)](https://git.f-brinker.de/fbrinker/elderscrolls-addon-achievementInfo/actions)

[![Latest Releases](https://badgen.net/badge/releases/latest)](https://git.f-brinker.de/fbrinker/elderscrolls-addon-achievementInfo/releases)
[![Downloads](https://badgen.net/https/scripts.f-brinker.de/esoui-stats/badge-total.php?cache=1800)](https://www.esoui.com/downloads/info350-AchievementInfo.html)
[![Favorites](https://badgen.net/https/scripts.f-brinker.de/esoui-stats/badge-fav.php?cache=1800)](https://www.esoui.com/downloads/info350-AchievementInfo.html)

This is a **The Elderscrolls Online** addon. [See all details and the download @ESOUI](http://www.esoui.com/downloads/info350-AchievementInfo.html#info).

[Issue-Tracker](https://git.f-brinker.de/fbrinker/elderscrolls-addon-achievementInfo/issues)

## Description

### What is this AddOn about?

I like achievements, and I like to know what to do to complete them and what type of achievements exist without browsing through the entire achievement catalog: This AddOn displays lightweight chat notifications if you make progress in an achievement (please see the screenshots).

### Features

* Shows chat notifications if you do something that is needed for an achievement
* Triggers on each action or just in x% steps of the achievement's requirements (configurable)
* Can show some details in the chat notification like (kill 250/1000 Humanoids)
* You can toggle the notifications for each category
* Lightweight: It is not always present and shows up only when necessary
* You can enable account-wide settings

![preview screenshot](screenshots/chat-1.jpg)

## Why is this a public project?

In case I quit or pause playing TESO and cannot maintain this addon, feel free to contribute to keep this up to date and running.
I'll still be available here and be able to update the ESOUI page.

## How to contribute?

**IMPORTANT: Github is a mirror.** Please contribute at [git.f-brinker.de/elderscrolls-addon-achievementInfo](https://git.f-brinker.de/fbrinker/elderscrolls-addon-achievementInfo) - You can log in with your Github or Gitlab account (OAuth2).

Then, create a fork of the repository, do what you have to do, and create a pull-request afterward. Feel free to contact me any time.

#### Linting
Luacheck is used to check the LUA code. [Documentation](https://luacheck.readthedocs.io/en/stable/index.html)

## API Version Upgrade
* Increment the API Version in the _AchievementInfo.txt_ file
* Commit: `git commit -am "New Api Version"`
* Add new Tag `git tag x.yz`
* Push `git push && git push --tags`