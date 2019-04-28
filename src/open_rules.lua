--- The standard opening things rulebook.
-- @module open_rules
return function (rulebooks)

	rulebooks.before.open = {
		{
			name = "the noun exist",
			action = function (self, command)
				if not command.first_item then
					return string.format(self.responses.unknown["thing"], command.verb), false
				end
			end
		},
		{
			name = "it can be opened",
			action = function (self, command)
				if command.first_item.closed == nil then
					return string.format(self.responses.open["cannot"], command.first_item.name), false
				end
			end
		},
		{
			name = "it is not already open",
			action = function (self, command)
				if command.first_item.closed == false then
					return string.format(self.responses.open["when open"], command.first_item.name), false
				end
			end
		},
		{
			name = "it is not locked",
			action = function (self, command)
				if command.first_item.locked == true then
					return string.format(self.responses.open["when locked"], command.first_item.name), false
				end
			end
		}
	}

	rulebooks.on.open = {
		{
			name = "open the thing",
			action = function (self, command)
				command.first_item.closed = false
			end
		}
	}

	rulebooks.after.open = {
		{
			name = "report opened",
			action = function (self, command)
				return string.format(self.responses.open["success"], command.first_item.name)
			end
		},
		{
			-- TODO move to finally timing
			name = "list contents of opened",
			action = function (self, command)
				if self.options.auto["list contents of opened"] == true then
					local contents = self:list_contents (command.first_item)
					return contents
				end
			end
		}
	}

end
