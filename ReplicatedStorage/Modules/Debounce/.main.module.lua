function debounce (f)
	local db = false;
	return function (...)
		if (db) then return end
		db = true;
		
		f (...);
		
		db = false;
	end
end

return debounce;