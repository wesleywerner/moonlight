--- The standard rulebooks table.
-- Provides functions to make working with rulebooks easier.
-- @module rulebooks
return function (rulebooks)

	--- Ensures the default rule categories exist.
	function rulebooks.reset (self)
		self.before = { }
		self.on = { }
		self.after = { }
		self.turn = { }
	end

	--- Gets a formatted string of all defined rules.
	function rulebooks.list (self)
		local output = ""
		for timing, collection in pairs(self) do
			if type (collection) == "table" then
				for action, rules in pairs(collection) do
					output = output .. string.format("[The %s.%s book]\n", timing, action)
					for _, rule in ipairs(rules) do
						output = output .. string.format("The %s rule\n", rule.name)
					end
					output = output .. "\n"
				end
			end
		end
		return output
	end

	--- Add a before-rule.
	--
	-- @param self @{instance}
	--
	-- @param verb
	-- The verb affected by this rule
	function rulebooks.addBefore (self, verb, name, action)
		self.before[verb] = self.before[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.before[verb], newrule)
	end

	function rulebooks.addOn (self, verb, name, action)
		self.on[verb] = self.on[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.on[verb], newrule)
	end

	function rulebooks.addAfter (self, verb, name, action)
		self.after[verb] = self.after[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.after[verb], newrule)
	end

	rulebooks.reset (rulebooks)

end
