local gameTags = {
	Characters = "Characters",

	UIRemote = "UIRemote",
	Remotes = "Remotes",
	ServerEvents = "ServerEvents",
	
	MazeSpawn = "Spawn",
	AttackSystem = "AttackSystem"
}

function initGlobals ()
	_G.GameTags = gameTags;
end

return initGlobals;