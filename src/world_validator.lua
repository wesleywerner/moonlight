return function (self, world)

	local issues = { }

	local function logerr (template, ...)
		table.insert (issues, string.format(template, ...))
	end

	if type(world) ~= "table" then
		logerr ("The world must be table.")
	end

	if #world == 0 then
		logerr ("The world table must contain at least one room.")
	end

	-- helper to test exits in rooms
	local function testRoomExits (room)
		local hasCompassDirection = false
		for k, v in pairs(room.exits) do
			-- exit is named properly
			local validDirections = {
				["north"] = true,
				["south"] = true,
				["east"] = true,
				["west"] = true,
				["northwest"] = true,
				["northeast"] = true,
				["southwest"] = true,
				["southeast"] = true,
				["in"] = true,
				["out"] = true
			}
			if validDirections[k] then
				hasCompassDirection = true
				if not self:roomByName (v) then
					-- perhaps the exit points to a door
					local item = self:search(v, room)
					if not item or not self:roomByName (item.destination or "") then
						logerr ("Exit %q in room %q is invalid", v, room.name)
					end
				end
			else
				logerr ("The %q exit in %q has to be a fully named compass direction", k, room.name)
			end
			-- destination is valid
		end

		return hasCompassDirection
	end

	-- helper to test exits on things
	local function testThings (room)
		local hasExitThing = false
		local checklist = { }
		for _, v in pairs(room.contains) do
			table.insert (checklist, v)
		end
		while #checklist > 0 do
			local test = table.remove(checklist)
			-- include contained items
			if type(test.contains) == "table" then
				for _, v in pairs(test.contains) do
					table.insert (checklist, v)
				end
			end
			-- include supported items
			if type(test.supports) == "table" then
				for _, v in pairs(test.supports) do
					table.insert (checklist, v)
				end
			end
			-- test exits
			if type(test.destination) == "string" then
				if self:roomByName (test.destination) then
					hasExitThing = true
				else
					logerr ("The %q destination for %q is invalid", test.destination, test.name)
				end
			end
		end
		return hasExitThing
	end

	-- check rooms have names
	for i, room in ipairs(world) do
		if not room.name then
			logerr ("Room #%d does not have a name set.", i)
		end
	end

	-- check for duplicate named rooms
	for i, room in ipairs(world) do
		for n, dupcheck in ipairs(world) do
			if room ~= dupcheck and room.name == dupcheck.name then
				logerr ("Rooms %d and %d both have the same name %q", i, n, room.name)
			end
		end
	end

	-- check all rooms have exits
	for _, room in ipairs(world) do

		if not room.exits then
			logerr ("Room %q has no exits", room.name)
		end

		if room.exits then
			local roomOk = testRoomExits (room)
			local roomThingsOk = testThings (room)
			if not roomOk and not roomThingsOk then
				logerr ("Room %q has no exits", room.name)
			end
		end

	end

	-- return valid, issues
	return #issues == 0, issues

end
