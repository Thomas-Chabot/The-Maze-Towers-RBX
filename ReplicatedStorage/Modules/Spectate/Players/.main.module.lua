--[[
	Main class for handling the Players array. Allows Players to be removed from the
	  array & can be cycled through using next and back methods.
	
	Constructor:
		Arguments:
			playersArr  - Array of Player  - The Players to be in the array.
	
	Methods:
		getTarget() : Player
			Returns the current player.
		next ()
			Cycles through the array, moving to the next player.
		prev ()
			Cycles through the array, moving to the previous player.
		remove (player : Player)
			Removes the given player from the array.
--]]

local Players = { };
local P       = { };

function P.new (playersArr)
	return setmetatable ({
		_players = playersArr,
		_curIndex = 1
	}, Players);
end

-- ** Public Methods ** --
function Players:getTarget ()
	return self._players [self._curIndex];
end

function Players:next ()
	return self:_incIndex (1);
end
function Players:prev ()
	return self:_incIndex (-1);
end

function Players:numAvailable ()
	return #self._players;
end

function Players:remove (player)
	local index = self:_indexOf (player);
	if (index == -1) then return false end
	
	-- Remove the player
	self:_remove (index);
	
	-- Update the current index
	self:_updateIndex (index);
end

-- ** Private Methods ** --
-- Player Removal
function Players:_remove (playerIndex)
	table.remove (self._players, playerIndex);
end

-- Indices
function Players:_indexOf (player)
	for index,plyr in pairs (self._players) do
		if (plyr == player) then
			return index;
		end
	end
	return -1;
end

function Players:_incIndex (increment)
	self._curIndex = self._curIndex + increment;
	self:_cycleIndex ();
end
function Players:_updateIndex (index)
	if (self._curIndex > index) then
		-- In this case, because curIndex is > index,
		-- removing index will shift curIndex backwards by one
		self._curIndex = self._curIndex - 1;
	elseif (self._curIndex == index) then
		-- Was viewing the removed player.
		-- Just move to the next (this is automatic),
		--  but cycle index to ensure stays within range
		self:_cycleIndex ();
	end
end
function Players:_cycleIndex ()
	-- Logic here: The index has to be 1 <= index <= #players.
	-- If we go outside that, fix our index
	local index = self._curIndex;
	
	if (index > #self._players) then
		-- Assume we have three players; move to index 4; want to go back to 1.
		-- 4 % 3 ==> 1, this gives us our index
		index = index - #self._players;
	elseif (index < 1) then
		-- When we move back to index 0, we want to go to #self._players;
		-- In case we move further back, subtract the difference
		index = #self._players - index;
	end
	
	self._curIndex = index;
end


Players.__index = Players;
return P;