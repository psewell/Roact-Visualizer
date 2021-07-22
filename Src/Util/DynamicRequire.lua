local scriptPlate = [[
local ___env = getfenv()
local script = ___env.script
local require = ___env.require

%s
]]

local modules = {}

local function dynamicRequire(module, overrideRequire)
	local newSource = string.format(scriptPlate, module.Source)
	local func, err = loadstring(newSource)
	if err then error(err) end
	local env = getfenv(func)
	env.script = module
	env.require = overrideRequire
	setfenv(func, env)
	local result = func()
	return result
end

local function dynamicRequireImpl(module, parentId)
	local src = module.Source
	local id = module:GetDebugId()
	if modules[id] == nil then
		modules[id] = {
			IsDirty = true,
			Dependencies = {},
		}
	end

	local isDirty = modules[id].IsDirty
	if not isDirty then
		for dependencyId, dependencyModule in pairs(modules[id].Dependencies) do
			if modules[dependencyId] == nil or modules[dependencyId].IsDirty
				or modules[dependencyId].Source ~= dependencyModule.Source then
				isDirty = true
				break
			end
		end
	end

	if parentId and modules[parentId] then
		modules[parentId].Dependencies[id] = module
	end

	if isDirty or modules[id].Source ~= src then
		-- This module has changed. We need to dynamically require it.
		modules[id].Dependencies = {}
		modules[id].Source = src
		local result = dynamicRequire(module, function(dependency)
			return dynamicRequireImpl(dependency, id)
		end)
		modules[id].Cached = result
		modules[id].IsDirty = false
		return result
	else
		-- Module hasn't changed. If none of its dependencies have changed,
		-- we need to return the cached version of this module.
		-- This will prevent things like Roact from invalidating the cache.
		return modules[id].Cached
	end
end

return function(module)
	local result = (dynamicRequireImpl(module, nil))
	return result
end
