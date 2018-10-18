--[[
	Simple module for controlling a jail cell & wrapping it around an object.
	Has one main function/constructor along with one method:
	
	Constructor:
		Jail.trap (object)
			Purpose: Adds the jail cell around the provided object, trapping it.
			Arguments:
				object  PVInstance  The object to trap inside the jail cell.
				                     Note, if this is a Model, PrimaryPart must be defined.
			Returns: An instance of the Jail class which can be used to remove
			           the jail cell.
	
	Methods:
		remove ()
			Removes the jail cell, freeing the trapped object.
			
	Example:
		local player = game.Players.LocalPlayer.Character; -- The player to trap
		local Jail   = require (workspace.JailCell); -- This module
		
		-- Trap the player in the jail cell
		local jail   = Jail.trap (player);
		
		-- Remove the jail cell after three seconds
		wait (3);
		jail:remove ();
--]]

local Jail = { };
local J    = { };

-- ** Variables ** --
local jailCell = script.Jail;

-- ** Constructor ** --
function J.trap (object)
	local jail = setmetatable ({
		_trapped = object,
		_cell    = jailCell:Clone ();
	}, Jail);
	
	jail:_trap ();
	return jail;
end

-- ** Public Methods ** --
function Jail:remove ()
	self._cell:Destroy ();
end

-- ** Private Methods ** --
function Jail:_trap ()
	local mainPart = self:_getPrimaryPart ();
	if (not mainPart) then return end
	
	self._cell.Parent = workspace;
	self._cell:MoveTo (mainPart.Position);
end

function Jail:_getPrimaryPart ()
	local trapped = self._trapped;
	if (not trapped) then return nil end
	
	if (trapped:IsA("Part")) then return trapped; end
	return trapped.PrimaryPart;
end


Jail.__index = Jail;
return J;