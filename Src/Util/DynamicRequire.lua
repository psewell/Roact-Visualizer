local GLOBALS = {
	-- Roblox globals
	delay = delay,
	DebuggerManager = DebuggerManager,
	elapsedTime = elapsedTime,
	PluginManager = PluginManager,
	printidentity = printidentity,
	require = require,
	settings = settings,
	spawn = spawn,
	stats = stats,
	tick = tick,
	time = time,
	typeof = typeof,
	UserSettings = UserSettings,
	version = version,
	wait = wait,
	warn = warn,
	Enum = Enum,
	game = game,
	shared = shared,
	workspace = workspace,

	-- Lua globals
	assert = assert,
	collectgarbage = collectgarbage,
	error = error,
	getfenv = getfenv,
	getmetatable = getmetatable,
	ipairs = ipairs,
	loadstring = loadstring,
	newproxy = newproxy,
	next = next,
	pairs = pairs,
	pcall = pcall,
	print = print,
	rawequal = rawequal,
	rawget = rawget,
	rawset = rawset,
	select = select,
	setfenv = setfenv,
	setmetatable = setmetatable,
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	unpack = unpack,
	xpcall = xpcall,
	_G = _G,
	_VERSION = _VERSION,

	-- Roblox libraries
	bit32 = bit32,
	coroutine = coroutine,
	debug = debug,
	math = math,
	os = os,
	string = string,
	table = table,
	utf8 = utf8,
}

return function(module)
	local src = module.Source
	local func = loadstring(src)
	GLOBALS.script = module
	setfenv(func, GLOBALS)
	return func()
end
