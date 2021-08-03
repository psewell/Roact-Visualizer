--!nolint DeprecatedGlobal

local GUID = [[564A1C4874D345218083CC9757532BCF]]

local scriptPlate = "local script = getfenv().script local require = getfenv().require %s"
local scriptNamePlate = "%s%s%s%s"

local main = script:FindFirstAncestor("Roact-Visualizer")
local Cryo = require(main.Packages.Cryo)

local DynamicRequire
local modules = {}

local function isEqual(str1, str2)
	return str1 == str2
end

local function dynamicRequire(module, overrideRequire, overrideScript)
	local scriptName
	if string.find(module.Name, " %(Roact Visualizer%)") then
		scriptName = "Roact-Visualizer." .. string.gsub(module.Name, " %(Roact Visualizer%)", "")
	else
		scriptName = module:GetFullName()
	end
	local newSource = string.format(scriptPlate, module.Source)
	local func, err = loadstring(newSource,
		string.format(scriptNamePlate, module:GetDebugId(), GUID, scriptName, GUID))
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
				or not isEqual(modules[dependencyId].Source, dependencyModule.Source) then
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

	if isDirty or not isEqual(modules[id].Source, src)
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
	local scriptName, lineNumber, debugId

	if string.find(err, "%[string \"") then
		-- Syntax error
		err = string.gsub(err, ".*%[string \"", "")
		local errorData = string.split(err, GUID)
		debugId = errorData[1]
		scriptName = errorData[2]
		lineNumber = tonumber(errorData[3]:match("%d+"))
		err = string.gsub(errorData[3], "\"%]%:%d+%:%s*", "", 1)
	else
		-- Runtime error
		local items = string.split(traceback, "\n")
		local errorLocation = items[2]
		local errorData = string.split(errorLocation, GUID)
		debugId = errorData[1]
		scriptName = errorData[2]
		lineNumber = tonumber(errorData[3]:match("%d+"))
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
