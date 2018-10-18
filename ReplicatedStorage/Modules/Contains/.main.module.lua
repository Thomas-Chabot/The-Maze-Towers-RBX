function contains (array, object)
	for _,element in pairs (array) do
		if (element == object) then
			return true;
		end
	end
	return false;
end

return contains;