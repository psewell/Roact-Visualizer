local CurrentElement = script.CurrentElement
local Roact = script.Roact

--[[
	Edit this script to modify the tree passed to the Roact Visualizer.
	This is where you can place any Context providers.
	You can also use it to make your own containers for the current component.

	You can reference the following variables:
		CurrentElement: The current element in the Roact Visualizer window.
		Roact: A reference to your local Roact install.
]]

return Roact.oneChild({CurrentElement})
