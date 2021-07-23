--[[
	Sets the new RootModule.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	RootModule = t.instanceIsA("ModuleScript"),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		RootModule = action.RootModule,
	})
end

return Action(script.Name, create, reduce)
