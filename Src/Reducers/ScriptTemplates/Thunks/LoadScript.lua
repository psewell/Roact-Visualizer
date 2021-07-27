--[[
	Loads a script from SavedScripts.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Update = require(script.Parent.Update)
local t = require(main.Packages.t)
local typecheck = t.interface({
	Name = t.string,
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
		local SavedScripts = state.SavedScripts

		local source = SavedScripts[props.Container][props.Name]
		local scriptType = Type[props.Container]
		local template = state.ScriptTemplates[scriptType]
		template.Source = source

		store:dispatch(Update())
	end
end
