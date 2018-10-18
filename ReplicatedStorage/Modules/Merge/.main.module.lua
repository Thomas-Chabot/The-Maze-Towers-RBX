function merge (t1, t2)
	if (not t1 or #t1 == 0) then return t2 end
	
	local result = {unpack (t1)};
	for _,elem in pairs (t2) do
		table.insert (result, elem);
	end
	
	return result;
end

return merge;