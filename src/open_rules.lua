--- The standard opening things rulebook.
-- @module open_rules
return function (rulebooks)

	rulebooks.before.open = {
		{
			name = "the noun exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.responses.unknown["thing"], command.verb), false
				end
			end
		},
		{
			name = "it can be opened",
			action = function (self, command)
				if command.item1.closed == nil then
					return string.format(self.responses.open["cannot"], command.item1.name), false
				end
			end
		},
		{
			name = "it is not already open",
			action = function (self, command)
				if command.item1.closed == false then
					return string.format(self.responses.open["when open"], command.item1.name), false
				end
			end
		},
		{
			name = "it is not locked",
			action = function (self, command)
				if command.item1.locked == true then
					return string.format(self.responses.open["when locked"], command.item1.name), false
				end
			end
		}
	}

	rulebooks.on.open = {
		{
			name = "open the thing",
			action = function (self, command)
				command.item1.closed = false
			end
		}
	}

	rulebooks.after.open = {
		{
			name = "report opened",
			action = function (self, command)
				return string.format(self.responses.open["success"], command.item1.name)
			end
		},
		{
			-- TODO move to finally timing
			name = "list contents of opened",
			action = function (self, command)
				if self.options.auto["list contents of opened"] == true then
					local contents = self:listContents (command.item1)
					return contents
				end
			end
		}
	}

end
