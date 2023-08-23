--[[=============================================================================
    Function for changing properties

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]
require "common.c4_driver_declarations"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_property = "2020.09.23"
end

--[[=============================================================================
    OnPropertyChanged(sProperty)

    Description
    Function called by Director when a property changes value. The value of the
    property that has changed can be found with: Properties[sName]. Note that
    OnPropertyChanged is not called when the Property has been changed by the
    driver calling the UpdateProperty command, only when the Property is changed
    by the user from the Properties Page. This function is called by Director
    when a property changes value.

    Parameters
    sProperty(string) - Name of property that has changed.

    Returns
    Nothing
===============================================================================]]
function OnPropertyChanged(sProperty)
	local propertyValue = Properties[sProperty]

	if (LOG ~= nil and type(LOG) == "table") then
		LogTrace("OnPropertyChanged(" .. sProperty .. ") changed to: " .. Properties[sProperty])
	end

	-- Remove any spaces (trim the property)
	local trimmedProperty = string.gsub(sProperty, " ", "")
	local status = true
	local err = ""

	if (ON_PROPERTY_CHANGED[sProperty] ~= nil and type(ON_PROPERTY_CHANGED[sProperty]) == "function") then
		status, err = pcall(ON_PROPERTY_CHANGED[sProperty], propertyValue)
	elseif (ON_PROPERTY_CHANGED[trimmedProperty] ~= nil and type(ON_PROPERTY_CHANGED[trimmedProperty]) == "function") then
		status, err = pcall(ON_PROPERTY_CHANGED[trimmedProperty], propertyValue)
	end

	if (not status) then
		LogError("LUA_ERROR: " .. err)
	end
end

--[[=============================================================================
    UpdateProperty(propertyName, propertyValue)
  
    Description:
    Sets the value of the given property in the driver
  
    Parameters:
    propertyName(string)  - The name of the property to change
    propertyValue(string) - The value of the property being changed
  
    Returns:
    None
===============================================================================]]
function UpdateProperty(propertyName, propertyValue)
	if (Properties[propertyName] ~= nil) then
		C4:UpdateProperty(propertyName, propertyValue)
	end
end


--[[=============================================================================
    GetPropertyValue(propertyName)
  
    Description:
    gets the value of the given property in the driver
  
    Parameters:
    propertyName(string)  - The name of the property to get
  
    Returns: The value of the requested property.  Nil if it doesn't exist.

===============================================================================]]
function GetPropertyValue(propertyName)
	return Properties[propertyName]
end


--[[=============================================================================
    HideProperty(propertyName)
  
    Description:
    Sets the property to not be shown on the properties page
  
    Parameters:
    propertyName(string)  - The name of the property to hide
  
    Returns:
    None
===============================================================================]]
function HideProperty(propertyName)
	if (Properties[propertyName] ~= nil) then
		C4:SetPropertyAttribs(propertyName, 1)	-- hide the property
	end
end


--[[=============================================================================
    ShowProperty(propertyName)
  
    Description:
    Sets the property to be shown on the properties page
  
    Parameters:
    propertyName(string)  - The name of the property to show
  
    Returns:
    None
===============================================================================]]
function ShowProperty(propertyName)
	if (Properties[propertyName] ~= nil) then
		C4:SetPropertyAttribs(propertyName, 0)		-- show the property
	end
end
