--[[=============================================================================
    File is: light_apis.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.

	API calls for developers using light template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_apis = "2021.11.30"
end


--[[=============================================================================
	Set that driver is Dimmer Type
		value - boolean
===============================================================================]]
function SetTypeDimmer(value)
	TheLight:SetTypeDimmer(value)
end


--[[=============================================================================
	Set Auto handling ON, OFF, TOGGLE
		value - boolean
===============================================================================]]
function SetAutoSwitch(value)
	TheLight:SetAutoSwitch(value)
end


--[[=============================================================================
	Set Auto handling Button Actions
		value - boolean
===============================================================================]]
function SetAutoButton(value)
	TheLight:SetAutoButton(value)
end


--[[=============================================================================
	Set Auto handling Group
		value - boolean
===============================================================================]]
function SetAutoGroup(value)
	TheLight:SetAutoGroup(value)
end


--[[=============================================================================
	Set Auto handling Group commands
		value - boolean
===============================================================================]]
function SetAutoGroupCommands(value)
	TheLight:SetAutoGroupCommands(value)
end

--[[=============================================================================
	Set Auto handling Advanced Lighting Scenes commands
		value - boolean
===============================================================================]]
function SetAutoAls(value)
	TheLight:SetAutoAls(value)
end


--[[=============================================================================
	Set Debounce time for Button Action in auto handlinge buttons
		milliseconds - integer
	Set only if AutoButton is true
===============================================================================]]
function SetButtonDebounceMilliseconds(milliseconds)
	TheLight:SetButtonDebounceMilliseconds(milliseconds)
end


--[[=============================================================================
	Make Table from ALS elements XML
		elements - XML string
===============================================================================]]
function LightAlsXmlToTable(elements)
	return TheLight:AlsXmlToTable(elements)
end


--[[=============================================================================
	Return current light color. Returns the following values:
		x and y that represent chromaticity of the color in the CIE 1931 xyY color space.
		colorMode that specifies if color is full color (LightDevice.COLOR_MODE_FULL_COLOR) or
		CCT (LightDevice.COLOR_MODE_CCT).
		If current color is not set, returns nil for each color component
===============================================================================]]
function GetLightColor()
	return TheLight:GetLightColor()
end


--[[=============================================================================
	Return current light level.
===============================================================================]]
function GetLightLevel()
	return TheLight:GetLightLevel()
end

--[[=============================================================================
	Set Warm Dimming feature
		value - boolean
	If WarmDimming is set True, parameters of WarmDimming should be set with
	SetWarmDimmingFunctionParameters function.
===============================================================================]]
function SetWarmDimming(value)
	TheLight:SetWarmDimming(value)
end

--[[=============================================================================
	Set Warm Dimming Function parameters
		k - number (float)
		n - number (float)
	Parameters k and n are parameters of linear function (f(x) = k*x + n).
	x is light brightness and f(x) is cct that will be set.
===============================================================================]]
function SetWarmDimmingFunctionParameters(k,n)
	TheLight:SetWarmDimmingFunctionParameters(k,n)
end

--[[=============================================================================
	Return CTT min and max value.
===============================================================================]]
function GetCCTRange()
	return TheLight:getCCTRange()
end

--[[=============================================================================
	Return current light state.
===============================================================================]]
function GetLightState()
	return TheLight:GetLightState()
end


--[[=============================================================================
	Return light preset level.
===============================================================================]]
function GetPresetLevel()
	return TheLight:GetPresetLevel()
end

--[[=============================================================================
	Return light click up rate.
===============================================================================]]
function GetClickRateUp()
	return TheLight:GetClickRateUp()
end

--[[=============================================================================
	Return light click down rate .
===============================================================================]]
function GetClickRateDown()
	return TheLight:GetClickRateDown()
end

--[[=============================================================================
	Return light hold up rate.
===============================================================================]]
function GetHoldRateUp()
	return TheLight:GetHoldRateUp()
end

--[[=============================================================================
	Return light hold down rate .
===============================================================================]]
function GetHoldRateDown()
	return TheLight:GetHoldRateDown()
end

--[[=============================================================================
	Gets the default Off/On Colors
	Returns two tables with x, y and mode fields for Off/On colors respectively
		{x = x_off, y = y_off, mode = mode_off}, {x = x_on, y = y_on, mode = mode_on }
===============================================================================]]
function GetDefaultColors()
	return TheLight:GetDefaultColors()
end

--[[=============================================================================
	Return WarmDimming boolean value.
===============================================================================]]
function IsWarmDimmingEnabled()
	return TheLight:IsWarmDimmingEnabled()
end
--[[=============================================================================
	Calculate Warm Dimming Function parameters
		cctRange - table {min = cctMin, max = cctMax}
	Parameter cctRange contains min and max cct values that will be used for WD.
===============================================================================]]
function CalculateWarmDimmingFunctionParameters(cctRange)
	TheLight:CalculatePiecewiseLinearWarmDimming(cctRange)
end

--[[=============================================================================
	Return light online state boolean value.
===============================================================================]]
function GetLightOnlineStatus()
	return TheLight:GetLightOnlineStatus()
end