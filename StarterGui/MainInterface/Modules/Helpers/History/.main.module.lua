--[[
	This is the main module for controlling the history of screens the player has
	  gone through. It supports moving backwards & forwards to return to screens.
	
	The constructor takes no arguments
	
	Available Methods:
		back () : Any
			Purpose: Returns to the previous screen in the player's history.
			Returns: The details for the previous screen; this will be some element added
			           through the add() method.
		next () : Any
			Purpose: Moves forward through the player's history to the next screen.
			Returns: The details for the player's next screen. This is the opposite of back.
		
		add (details : Any)
			Purpose: Adds a new screen to the player's history.
			Arguments:
				details  Any  The details for the new screen. This should be enough info
				                to be able to return to the screen from.
			Returns: None
			Side Effect: If the player has moved back through their history,
			               all history past the current point will be erased.
		
		replace (details : Any)
			Purpose: Replaces the active screen details with the provided screen.
			Arguments:
				details  Any  The details for the new screen. This should be enough info
				                to be able to return to the screen from.
			Returns: None
			
		isLast () : Boolean
			Returns true if the player can no longer move forward through their history.
		
		isFirst () : Boolean
			Returns true if the player can no longer move back through their history.	
--]]

local History = { };
local H       = { };

-- ** Constants ** --
local HIST_MIN_INDEX = 1;
local HIST_NEXT = 1;

-- ** Constructor ** --
function H.new ()
	return setmetatable ({
		_history = { },
		
		_cur     = 0,
		_numHistories = 0
	}, History);
end

-- ** Public Methods ** --
function History:clear ()
	self._cur = 0;
	self._numHistories = 0;
	self._history = { };
end

function History:back ()
	return self:_updateIndex (-1);
end

function History:next ()
	return self:_updateIndex (1);
end
function History:add (details)
	self:_addToHistory (details);
end
function History:replace (details)
	self:_replaceCurrentHistory (details);
end
function History:isLast ()
	return self:_isLast ();
end
function History:isFirst ()
	return self:_isFirst ();
end

-- ** Private Methods ** --
-- Set the values in the history
function History:_getHistoryData ()
	return self._history [self._cur];
end
function History:_setHistoryData (details, isNewHistory)
	self._history [self._cur] = details;
	if (isNewHistory == false) then return end
	
	self:_addNewHistory();
end

function History:_addNewHistory ()
	-- When we add a new history, erase everything after this point
	self._numHistories = self._cur;
end
function History:_incrementNumHistories ()
	self._numHistories = self._numHistories + 1;
end

-- Increment the history offset from moving forward / moving backward
function History:_incrementIndex (offset)
	local newIndex = self:_findIndex (self._cur + offset);
	self._cur = newIndex;
end

-- Keep an index within range of 1 <= value <= numHistories
function History:_findIndex (newValue)
	-- If it's the first index, just return that (in case of before first index)
	if (self:_isFirst (newValue)) then
		return HIST_MIN_INDEX;
	end	
	
	-- If it's the last index, return that (in case past that point)
	if (self:_isLast (newValue)) then
		return self._numHistories;
	end
	
	return newValue;
end

-- Check if index can be moved backward / forward
function History:_isFirst (index)
	if (not index) then index = self._cur; end
	return index <= HIST_MIN_INDEX;
end
function History:_isLast (index)
	if (not index) then index = self._cur; end
	return index >= self._numHistories;
end

-- The main helper methods
function History:_updateIndex (offset)
	self:_incrementIndex (offset);
	return self:_getHistoryData ();
end
function History:_addToHistory (details)
	self:_incrementNumHistories ();
	
	self:_incrementIndex (HIST_NEXT);
	self:_setHistoryData (details);
end
function History:_replaceCurrentHistory (details)
	self:_setHistoryData (details, false);
end


History.__index = History;
return H;