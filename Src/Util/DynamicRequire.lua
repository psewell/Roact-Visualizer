local GUID = [[564A1C48%-74D3%-4521%-8083%-CC9757532BCF]]

local scriptPlate = [[
--564A1C48-74D3-4521-8083-CC9757532BCF%s
--%s
local script = getfenv().script
local require = getfenv().require
%s
]]

local DynamicRequire
local modules = {}

local function dynamicRequire(module, overrideRequire, overrideScript)
	local newSource = string.format(scriptPlate, module:GetFullName(),
		module:GetDebugId(), module.Source)
	local func = loadstring(newSource)
	if func == nil then
		return {}
	end
	local env = getfenv(func)
	env.script = overrideScript or module
	env.require = overrideRequire
	setfenv(func, env)
	local result = func()
	return result
end

local function checkDependencies(id)
	local isDirty = modules[id].IsDirty
	if not isDirty then
		for dependencyId, dependencyModule in pairs(modules[id].Dependencies) do
			if modules[dependencyId] == nil or dependencyModule == nil
				or dependencyModule.Parent == nil or modules[dependencyId].IsDirty
				or modules[dependencyId].Source ~= dependencyModule.Source then
				return true
			end
			local isDependencyDirty = checkDependencies(dependencyId)
			if isDependencyDirty then
				return true
			end
		end
	end
	return isDirty
end

local function dynamicRequireImpl(module, parentId, overrideScript, force)
	local src = module.Source
	local id = module:GetDebugId()
	if modules[id] == nil then
		modules[id] = {
			Module = module,
			IsDirty = true,
			Dependencies = {},
		}
	end

	local isDirty = checkDependencies(id)
	if parentId and modules[parentId] then
		modules[parentId].Dependencies[id] = module
	end

	if isDirty or modules[id].Source ~= src
		or (parentId == nil and force) then
		-- This module has changed. We need to dynamically require it.
		modules[id].Dependencies = {}
		modules[id].Source = src
		local result = dynamicRequire(module, function(dependency)
			return dynamicRequireImpl(dependency, id)
		end, parentId == nil and overrideScript or nil)
		modules[id].Cached = result
		modules[id].IsDirty = false
		return result, false
	else
		-- Module hasn't changed. If none of its dependencies have changed,
		-- we need to return the cached version of this module.
		-- This will prevent things like Roact from invalidating the cache.
		return modules[id].Cached, true
	end
end

local function req(module)
	local result = (dynamicRequireImpl(module, nil))
	return result
end

local function force(module, overrideScript)
	local result = (dynamicRequireImpl(module, nil, overrideScript, true))
	return result
end

local function reqWithCacheResult(module, overrideScript)
	local result, didCache = dynamicRequireImpl(module, nil, overrideScript)
	return result, didCache
end

local function getErrorTraceback(err, traceback)
	local items = string.split(traceback, "\n")
	local scriptName = string.sub(items[2], 39)
	local debugId = string.sub(items[3], 3)
	local lineNumber
	for index = 1, #items do
		local item = items[index]
		if (string.find(item, "Src.Util.DynamicRequire"))
			and string.find(item, "function dynamicRequire") then
			local lineNumberItem = items[index - 1]
			lineNumber = string.match(lineNumberItem, ".*%f[%d.](%d*%.?%d+)")
			lineNumber = tonumber(lineNumber) - 4
			break
		end
	end
	if lineNumber == nil then
		local seenId = false
		for index = 1, #items do
			local item = items[index]
			if (string.find(item, GUID)) then
				if seenId then
					local lineNumberItem = items[index - 1]
					lineNumber = string.match(lineNumberItem, ".*%f[%d.](%d*%.?%d+)")
					lineNumber = tonumber(lineNumber) - 4
					break
				else
					seenId = true
				end
			end
		end
	end
	local module
	if modules[debugId] and modules[debugId].Module
		and modules[debugId].Module.Parent ~= nil then
		module = modules[debugId].Module
	end
	err = string.gsub(err, "%[.*%]:%d*: ", "")
	return string.format("%s:%i: %s", scriptName, lineNumber, err), module and {
		Script = module,
		LineNumber = lineNumber,
	} or nil
end

local function clear()
	modules = {}
	DynamicRequire.___modules_TEST_ONLY = modules
end

DynamicRequire = {
	Require = req,
	RequireWithCacheResult = reqWithCacheResult,
	ForceRequire = force,
	GetErrorTraceback = getErrorTraceback,
	Clear = clear,
	___modules_TEST_ONLY = modules,
}

return DynamicRequire
