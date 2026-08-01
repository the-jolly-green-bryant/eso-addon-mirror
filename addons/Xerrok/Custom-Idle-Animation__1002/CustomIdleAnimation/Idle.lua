Idle = class(
	function (idle, emoteSlashName, minimumTime, priority, loop)
		idle.emoteSlashName = emoteSlashName
		idle.minimumTime = minimumTime
		idle.priority = priority
		idle.loop = loop
	end
)

function Idle.Copy(savedIdle)
	return Idle(savedIdle.emoteSlashName, savedIdle.minimumTime, savedIdle.priority, savedIdle.loop)
end

function Idle:Play()
	PlayEmoteByIndex(emoteBySlashNames[self.emoteSlashName].emoteIndex)
end