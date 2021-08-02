--[[
	Loads a script from SavedScripts.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Update = require(script.Parent.Update)
local t = require(main.Packages.t)
local typecheck = t.interface({
	Name = t.union(t.instanceIsA("ModuleScript"), t.string),
	Container = t.literal("RootScripts", "PropsScripts"),
})

local Type = {
	RootScripts = "Root",
	PropsScripts = "Props",
}

return function(props)
	return function(store)
		assert(typecheck(props))
		local state = store:getState()

		local source
		if t.string(props.Name) then
			local SavedScripts = state.SavedScripts
			source = SavedScripts[props.Container][props.Name]
		else
			source = props.Name.Source
		end

		local scriptType = Type[props.Container]
		local template = state.ScriptTemplates[scriptType]
		template.Source = source

		store:dispatch(Update())
	end
end
