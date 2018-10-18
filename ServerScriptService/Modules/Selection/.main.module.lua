local S         = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constants ** --
local DEF_SELECTOR = function(t) return t; end
local DEF_ODDS = function(t) return t.odds; end

-- ** Constructor ** --
local Selection = Module.new();
function S.new (odds, settings)
	if (not settings) then settings = { }; end
	return setmetatable ({
		_moduleName = "ItemSelector",
		
		_getResult = settings.selector or DEF_SELECTOR,
		_getOdds   = settings.getOdds or DEF_ODDS,
		
		_odds = odds
	}, Selection);
end

-- ** Public Methods ** --
function Selection:pick ()
	local item = math.random ();
	self:_log ("Random number chosen is ", item);
	
	local result = self:_match (item);
	return self._getResult (result);
end

-- ** Private Methods ** --
function Selection:_match (randVal)
	local lastItem;
	for _,item in pairs (self._odds) do
		local odds = self._getOdds (item);
		self:_log ("Item has ", odds, " as odds; rand val is ", randVal);
		
		if (randVal <= odds) then
			self:_log ("Selected item");
			return item;
		end
		
		-- Go to the next module to check ...
		-- Also store the last module, in case we don't find a match
		lastItem = item;
		randVal  = randVal - odds;
	end
	
	-- No match - just return the last module listed
	return lastItem;
end


Selection.__index = Selection;
return S;