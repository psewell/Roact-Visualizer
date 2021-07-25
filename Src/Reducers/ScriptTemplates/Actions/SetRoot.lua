--[[
	Sets the Root template script.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Root = t.instanceIsA("ModuleScript"),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		Root = action.Root,
	})
end

return Action(script.Name, create, reduce)
