--[[
	Sets the new RootModule.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local DynamicRequire = require(main.Src.Util.DynamicRequire)

local typecheck = t.interface({
	RootModule = t.optional(t.instanceIsA("ModuleScript")),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	if action.RootModule ~= state.RootModule then
		DynamicRequire.Clear()
	end
	return Cryo.Dictionary.join(state, {
		RootModule = action.RootModule or Cryo.None,
	})
end

return Action(script.Name, create, reduce)
