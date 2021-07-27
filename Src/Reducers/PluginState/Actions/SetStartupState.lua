--[[
	Sets the startup state, which can be accepted or rejected.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	RootModule = t.optional(t.instanceIsA("ModuleScript")),
	PropsScripts = t.optional(t.instanceIsA("ModuleScript")),
	RootScripts = t.optional(t.instanceIsA("ModuleScript")),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		StartupState = {
			RootModule = action.RootModule,
			PropsScripts = action.PropsScripts,
			RootScripts = action.RootScripts,
		},
	})
end

return Action(script.Name, create, reduce)
