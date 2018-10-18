local Stat = { };
local S    = { };

function S.new (min, max)
	return setmetatable ({
		_min = min,
		_max = max
	}, Stat);
end

function Stat:calculate (percentage)
	local valuesRange = self._max - self._min;
	local valueOffset = valuesRange * percentage;
	
	return self._min + valueOffset;
end

function Stat:max () return self._max; end
function Stat:min () return self._min; end

Stat.__index = Stat;
return S;