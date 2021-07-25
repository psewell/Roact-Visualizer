--[[HELP
	(You can disable these comments by unchecking "Show Help" in Settings.)

	Edit this script to modify the tree passed to the Roact Visualizer.
	You can reference the following variables:
		CurrentElement: The current component in the Roact Visualizer.
		Roact: A reference to your local Roact install.

	EXAMPLES:
		-- Providing a Roact Context
		return Roact.createElement(MyContext.Provider, {
			value = myContextValue,
		}, CurrentElement}))

		-- White background
		return Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, CurrentElement))
HELP]]