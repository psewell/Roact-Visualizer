local DynamicRequire = require(script.Parent.Src.Util.DynamicRequire)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		DynamicRequire.Require(workspace.TestScript)
		print("Finished")
	end
end)
