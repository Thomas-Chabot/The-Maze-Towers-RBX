--[[
	This is the main module for player spectating. This allows players to spectate
	  other players (which means they can watch the other player on their screen).
	
	Notes:
		This module has support for Gamepad Controllers, Mobile Devices & Laptops/Desktops.
		Gamepads can switch by L2 or R2 ;
		Laptops, Desktops & mobile devices can switch using the arrow interface.
	
	Requirements:
		This module must be run locally.
	
	Constructor:
		The constructor takes no arguments.
	
	Methods:
		setup (players : Array of Player)
			This must be called before the Spectate module can be used. This will setup
			  the players that can be watched through Spectating.
			Arguments:
				players  Each of the players that can be spectated. Should be
				           {game.Players.Player1, game.Players.Player2, ...}
			Returns: None
		
		removePlayer (player : Player)
			Removes the player from the watchable players array. If the player is being
			  watched when they are removed, will automatically switch to the next player.
			Arguments:
				player  This is the player to remove from the array.
			Returns: None
		
		activate ()
			This activates spectating, which will allow the player to spectate.
			Automatically switches the player to watching the first player 
			  from the Players array.
		
		deactivate ()
			This deactivates spectating, so input will be ignored.
			Also switches the camera back to watching the local player.
--]]

local Spectate = { };
local S        = { };

-- ** Dependencies ** --
local Players = require (script.Players);
local Input   = require (script.Input);
local Camera  = require (script.Camera);

-- ** Constructor ** --
function S.new ()
	local spectate = setmetatable ({
		_active = false,
		
		_camera  = Camera.new (),
		_input   = Input.new (),
		_players = nil
	}, Spectate);
	
	spectate:_init ();
	return spectate;
end

-- ** Public Methods ** --
function Spectate:setup (playersArr)
	self._players = Players.new (playersArr);
end
function Spectate:removePlayer (player)
	if (not self._players) then return end
	self._players:remove (player);
end

function Spectate:activate ()
	self._input:activate ();
	self:_updateCam ();
end
function Spectate:deactivate ()
	self._input:deactivate ();
	self:_setCamTarget (game.Players.LocalPlayer);
end


-- ** Private Methods ** --
-- Initialization
function Spectate:_init ()
	self:_listenForEvents ();
end
function Spectate:_listenForEvents ()
	self._input.Next.Event:connect (function ()
		self:_next ();
	end)
	self._input.Back.Event:connect (function ()
		self:_back ();
	end)
end

-- Cycling
function Spectate:_next ()
	self._players:next ();
	self:_updateCam ();
end
function Spectate:_back ()
	self._players:prev ();
	self:_updateCam ();
end

-- Camera
function Spectate:_updateCam ()
	if (not self._players) then
		print ("Players not found");
		return;
	end
	
	local target = self:_getCurrentTarget();
	if (not target) then
		self:deactivate ();
	else
		self:_setCamTarget (target);
	end
end
function Spectate:_setCamTarget (targ)
	self._camera:setTarget (targ);
end

-- Target
function Spectate:_getCurrentTarget ()
	-- If we have < 1 players, there's no target - set to the player himself
	if (self._players:numAvailable () < 1) then
		return nil;
	end
	
	return self._players:getTarget ();
end

Spectate.__index = Spectate;
return S;