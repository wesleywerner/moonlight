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

	--- Add a before-rule
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
