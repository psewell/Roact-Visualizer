local GUID = [[564A1C48%-74D3%-4521%-8083%-CC9757532BCF]]

local scriptPlate = [[
--564A1C48-74D3-4521-8083-CC9757532BCF%s564A1C48-74D3-4521-8083-CC9757532BCF%s

local script = getfenv().script
local require = getfenv().require
%s
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Cryo = require(main.Packages.Cryo)

local DynamicRequire
local modules = {}

local function dynamicRequire(module, overrideRequire, overrideScript)
	local scriptName
	if string.find(module.Name, " %(Roact Visualizer%)") then
		scriptName = "Roact-Visualizer." .. string.gsub(module.Name, " %(Roact Visualizer%)", "")
	else
		scriptName = module:GetFullName()
	end
	local newSource = string.format(scriptPlate, module:GetDebugId(), scriptName, module.Source)
	local func, err = loadstring(newSource)
	assert(func, err)
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

local function dynamicRequireImpl(module, parentId, overrideScript, force, static)
	local src = module.Source
	local id = module:GetDebugId()
	if modules[id] == nil then
		modules[id] = {
			Module = module,
			IsDirty = true,
			Dependencies = {},
			Static = static,
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
			return dynamicRequireImpl(dependency, id, nil, nil, static)
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

local function reqStaticModule(module)
	local result = (dynamicRequireImpl(module, nil, nil, false, true))
	return result
end

local function getErrorTraceback(err, traceback)
	local items = string.split(traceback, "\n")
	local scriptName, lineNumber, debugId

	if (string.find(err, GUID)) then
		err = string.gsub(err, ".*%-%-" .. GUID, "")
		debugId = string.gsub(err, GUID .. ".*", "")
		err = string.gsub(err, ".*" .. GUID, "")
		local nameString = string.gsub(err, "%.%.%.\"%]%:.*", "")
		scriptName = nameString
		local numString = string.gsub(err, ".*%.%.%.\"%]%:", "")
		numString = string.gsub(numString, "%:.*", "")
		lineNumber = tonumber(numString) - 4
		err = string.gsub(err, ".*%.%.%.\"%]%:%d*%:%s*", "")
	else
		scriptName = string.gsub(items[2], ".*" .. GUID, "")
		local debugIdString = string.gsub(items[2], ".*%-%-" .. GUID, "")
		debugId = string.gsub(debugIdString, GUID .. ".*", "")
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
	end

	local module
	if debugId and modules[debugId] and modules[debugId].Module
		and modules[debugId].Module.Parent ~= nil then
		module = modules[debugId].Module
	end

	return string.format("%s:%i: %s", scriptName, lineNumber, err), module and {
		Script = module,
		LineNumber = lineNumber,
	} or nil
end

local function isInRequireChain(module)
	local id = module:GetDebugId()
	return modules[id] ~= nil
end

local function clear()
	modules = Cryo.Dictionary.filter(modules, function(value)
		return value.Static
	end)
	DynamicRequire.___modules_TEST_ONLY = modules
end

local function getActiveModules()
	local active = Cryo.Dictionary.filter(modules, function(value)
		return value.Module ~= nil and not value.Static
	end)
	return active
end

DynamicRequire = {
	Require = req,
	RequireWithCacheResult = reqWithCacheResult,
	RequireStaticModule = reqStaticModule,
	ForceRequire = force,
	GetErrorTraceback = getErrorTraceback,
	IsInRequireChain = isInRequireChain,
	Clear = clear,
	GetActiveModules = getActiveModules,
	___modules_TEST_ONLY = modules,
}

return DynamicRequire
