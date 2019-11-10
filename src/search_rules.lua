--- The standard search rulebook.
-- @module search_rules
return function (rulebooks)

	rulebooks.before.search = rulebooks.before.search or { }

	rulebooks.before.search = {
		{
			name = "the noun exists",
			action = function (self, command)
				if not command.first_item then
					return self.responses.search["too broad"], false
				end
			end
		},
		{
			name = "the noun is hiding something",
			action = function (self, command)
				if not command.first_item.hides then
					return self.responses.search["unlucky"], false
				end
			end
		},
	}

	rulebooks.on.search = {
		{
			name = "report the search is starting",
			action = function (self, command)
				return string.format (self.responses.search["report"], command.first_item.name)
			end
		},
		{
			name = "reveal the hidden items",
			action = function (self, command)

				-- store found things on the command
				command.found = { }

				local parent = command.first_item

				for _, found in ipairs(command.first_item.hides) do

					-- store for later use
					table.insert (command.found, found)

					-- move the found thing into view
					if type(parent.supports) == "table" then
						self:move_thing_onto (found, parent)
					elseif type(parent.contains) == "table" then
						self:move_thing_into (found, parent)
					else
						self:move_thing_into (found, self.room)
					end

				end
			end
		},
	}

	rulebooks.after.search = {
		{
			name = "the list of things found",
			action = function (self, command)
				if command.found then
					for _, found in ipairs(command.found) do
						table.insert (self.output,
							string.format(self.responses.search["found"], self:format_name(found)))
					end
				end
			end
		},
		{
			-- TODO move to FINALLY timing
			name = "apply the take-found-things option",
			action = function (self, command)
				if self.options.flags["take things searched"] then
					for _, found in ipairs(command.found) do
						self:simulate (self:parse("take " .. found.name))
					end
				end
			end
		},
	}

end
