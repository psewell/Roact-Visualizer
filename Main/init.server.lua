local DynamicRequire = require(script.Parent.Src.Util.DynamicRequire)
local TestEZ = require(script.Parent.Packages.TestEZ)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		DynamicRequire.Require(workspace.TestScript)
		print("Finished")
	end
end)

TestEZ.TestBootstrap:run({
	script.Parent.Src.Util,
})
