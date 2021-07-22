local DynamicRequire = require(script.Parent.Src.Util.DynamicRequire)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		DynamicRequire(workspace.TestScript)
	end
end)
