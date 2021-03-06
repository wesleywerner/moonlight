--- Provides validation for world models.
--
-- @module world_validator
return function (self, world)

	local warnings = { }
	local errors = { }

	local function log_err (template, ...)
		table.insert (errors, string.format(template, ...))
	end

	local function log_warn (template, ...)
		table.insert (warnings, string.format(template, ...))
	end

	if type(world) ~= "table" then
		log_err ("The world must be table.")
	end

	if #world == 0 then
		log_err ("The world table must contain at least one room.")
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
				if not self:room_by_name (v) then
					-- perhaps the exit points to a door
					local item = self:search_first (v, room)
					if not item then
						log_err ("Exit %q in room %q is invalid", v, room.name)
					elseif not self:room_by_name (item.destination or "") then
						log_err ("Exit %q in room %q is invalid", v, room.name)
					end
				end
			else
				log_err ("The %q exit in %q has to be a fully named compass direction", k, room.name)
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
			-- include hidden items
			if type(test.hides) == "table" then
				for _, v in pairs(test.hides) do
					table.insert (checklist, v)
				end
			end
			-- test exits
			if type(test.destination) == "string" then
				if self:room_by_name (test.destination) then
					hasExitThing = true
				else
					log_err ("The %q destination for %q is invalid", test.destination, test.name)
				end
			end
		end
		return hasExitThing
	end

	-- check rooms have names
	for i, room in ipairs(world) do
		if not room.name then
			room.name = string.format ("Room #%d", i)
			log_err ("Room #%d does not have a name set.", i)
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
			log_warn ("Room %q has no exits", room.name)
		end

		if room.exits then
			local roomOk = testRoomExits (room)
			local roomThingsOk = testThings (room)
			if not roomOk and not roomThingsOk then
				log_warn ("Room %q has no exits", room.name)
			end
		end

	end

	-- attempt to find player persons
	local player_predicate = function (item)
		return item.player == true
	end
	local player_matches = self:search (player_predicate, nil, true)
	if player_matches then
		if #player_matches > 1 then
			log_warn ("%d things are set as %q", #player_matches, "player")
		end
		local first_player =  unpack(player_matches[1])
		self:set_player (first_player)
	end

	-- check that unlock lists contain lists of strings.
	-- check that unlock lists point to valid things.
	-- TODO

	return warnings, errors

end
