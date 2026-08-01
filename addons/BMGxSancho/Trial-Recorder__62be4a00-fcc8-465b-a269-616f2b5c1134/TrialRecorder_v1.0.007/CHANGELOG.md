# Trial Recorder Changelog

## v1.0.007

- Replaced the direct leaderboard request with ESO's native `LEADERBOARD_LIST_MANAGER:QueryLeaderboardData` flow.
- Added the native `EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED` refresh event.
- Added robust trial-to-raid ID matching for formatted or localized Veteran leaderboard names.
- Delays result reading briefly after ESO returns data so rank and score fields can populate.
- Preserves the existing account-wide leaderboard cache and character attribution.


## v1.0.007

- Uses ESO's native raid leaderboard query event before reading leaderboard results.
- Searches the returned leaderboard rows for the player's Online ID to retrieve the account's ranked entry, including the character that earned it.
- Retains the native current-character leaderboard result as a fallback.
- Saves best-known leaderboard results account-wide by trial and character.
- Displays the leaderboard character beneath score and rank.
- Adds the character name to every Recent Clears entry.
- Keeps weekly and regular leaderboard results separate.

## v1.0.005

- Requested fresh leaderboard data when a trial was selected.
- Added weekly leaderboard support and regular fallback.
