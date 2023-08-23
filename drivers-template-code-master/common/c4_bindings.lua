--[[=============================================================================
	File is: c4_bindings.lua
    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

ON_BINDING_CHANGED = {}

--[[=============================================================================
    OnBindingChanged(idBinding, class, bIsBound)

    Description:
    Function called by Director when a binding changes state(bound or unbound).

    Parameters:
    idBinding(int) - ID of the binding whose state has changed.
    class(string)  - Class of binding that has changed.
                     A single binding can have multiple classes(i.e. COMPONENT,
                     STEREO, RS_232, etc).
    bIsBound(bool) - Whether the binding has been bound or unbound.

    Returns:
    None
===============================================================================]]
function OnBindingChanged(idBinding, class, bIsBound)

	-- Call all ON_BINDING_CHANGED functions
	for k,v in pairs(ON_BINDING_CHANGED) do
		if (ON_BINDING_CHANGED[k] ~= nil and type(ON_BINDING_CHANGED[k]) == "function") then
			C4:ErrorLog("OnBindingChanged: ON_BINDING_CHANGED." .. k .. "()")
			local status, err = pcall(ON_BINDING_CHANGED[k], idBinding, class, bIsBound)
			if (not status) then
				C4:ErrorLog("LUA_ERROR: " .. err)
			end
		end
	end
end

