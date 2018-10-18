local GW = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constructor ** --
local GameWinnings = Module.new ("Player-GameWinnings");
function GW.new ()
	return setmetatable ({
		_winnings = 0
	}, GameWinnings);
end

-- ** Public Getters ** --
function GameWinnings:get ()
	return self._winnings;
end

-- ** Public Setters ** --
function GameWinnings:set (amount)
	self._winnings = amount;
end

-- ** Public Methods ** --
function GameWinnings:add (amount)
	self._winnings = self._winnings + amount;
end
function GameWinnings:reset ()
	self._winnings = 0;
end


GameWinnings.__index = GameWinnings;
return GW;