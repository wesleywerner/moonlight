--- Split a string.
local function split (s, delimiter)
    local result = { };
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--- Find a value in a table via a predicate function.
local function find (t, f)
	for k, v in pairs(t) do
		if f(k, v) then
			return v
		end
	end
	return nil
end

--- Filter a table by a predicate function.
local function filter (t, f)
	local matches = {}
	for k, v in pairs(t) do
		if f(k, v) then
			table.insert(matches, v)
		end
	end
	return matches
end

--- Get the index of a value in a table.
local function indexOf (t, cmp)
	for k, v in ipairs(t) do
		if v == cmp then
			return k
		end
	end
	return 0
end

--- Test if a table contains a value.
local function contains (t, cmp)
	return indexOf(t, cmp) > 0
end

return {
	split = split,
	find = find,
	filter = filter,
	indexOf = indexOf,
	contains = contains
}
