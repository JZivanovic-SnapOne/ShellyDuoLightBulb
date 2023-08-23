--[[=============================================================================
    File is: light_reports.lua

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_reports = "2021.05.22"
end


--[[=============================================================================
	Set Button Action
		buttonId - integer
		action - integer
			0 - release
			1 - push
			2 - single tap
			3 - double tap
			4 - triple tap
===============================================================================]]
function LightReport_ButtonAction(buttonId, action)
	TheLight:ReportLightButtonAction(buttonId, action)
end


--[[=============================================================================
	Set Buton Info
		buttonId - integer
		onColor - string
		offColor - string
		currentColor - string
		name - string
===============================================================================]]
function LightReport_ButtonInfo(buttonId, onColor, offColor, currentColor, name)
	TheLight:ReportLightButtonInfo(buttonId, onColor, offColor, currentColor, name)
end


--[[=============================================================================
	Set Click Rate Down
		milliseconds - integer
===============================================================================]]
function LightReport_ClickRateDown(milliseconds)
	TheLight:ReportLightClickRateDown(milliseconds)
end


--[[=============================================================================
	Set Click Rate Up
		milliseconds - integer
===============================================================================]]
function LightReport_ClickRateUp(milliseconds)
	TheLight:ReportLightClickRateUp(milliseconds)
end


--[[=============================================================================
	Set Cold Start Level
		level - integer 0-100
===============================================================================]]
function LightReport_ColdStartLevel(level)
	TheLight:ReportLightColdStartLevel(level)
end


--[[=============================================================================
	Set Cold Start Time
		milliseconds - integer
===============================================================================]]
function LightReport_ColdStartTime(milliseconds)
	TheLight:ReportLightColdStartTime(milliseconds)
end


--[[=============================================================================
	Set Hold Rate Down
		milliseconds - integer
===============================================================================]]
function LightReport_HoldRateDown(milliseconds)
	TheLight:ReportLightHoldRateDown(milliseconds)
end


--[[=============================================================================
	Set Hold Rate Up
		milliseconds - integer
===============================================================================]]
function LightReport_HoldRateUp(milliseconds)
	TheLight:ReportLightHoldRateUp(milliseconds)
end


--[[=============================================================================
	Set Light Level
		level - integer 0-100
===============================================================================]]
function LightReport_LightLevel(level)
	TheLight:ReportLightLightLevel(level)
end


--[[=============================================================================
	Part of the new Level Target API, used to notify the proxy that a lights brightness is changing.
		target - integer
		milliseconds - integer
		current - integer
===============================================================================]]
function LightReport_LightBrightnessChanging(target, milliseconds, current)
	TheLight:ReportLightBrightnessChanging(target, milliseconds, current)
end

--[[=============================================================================
	Part of the new Level Target API, used to notify the proxy that a lights brightness is changed.
		current - integer
		milliseconds - integer
===============================================================================]]
function LightReport_LightBrightnessChanged(current)
	TheLight:ReportLightBrightnessChanged(current)
end


--[[=============================================================================
	Set Max Level for On
		level - integer 0-100
===============================================================================]]
function LightReport_MaxOnLevel(level)
	TheLight:ReportLightMaxOnLevel(level)
end


--[[=============================================================================
	Set Min Level for On
		level - integer 0-100
===============================================================================]]
function LightReport_MinOnLevel(level)
	TheLight:ReportLightMinOnLevel(level)
end



--[[=============================================================================
	Set Number of Buttons
		number - integer
===============================================================================]]
function LightReport_NumberButtons(number)
	TheLight:ReportLightNumberButtons(number)
end


--[[=============================================================================
	Set Online Change Status
		status - boolean
===============================================================================]]
function LightReport_OnlineChanged(status)
	TheLight:ReportLightOnlineChanged(status)
end


--[[=============================================================================
	Set Preset Level
		level - integer 0-100
===============================================================================]]
function LightReport_PresetLevel(level)
	TheLight:ReportLightPresetLevel(level)
end


--[[=============================================================================
	Notify change in this device's capabilities.
		tParams - Table with capabilities that changed
===============================================================================]]
function LightReport_DynamicCapabilitiesChanged(tCapabilities)
	TheLight:ReportDynamicCapabilitiesChanged(tCapabilities)
end


--[[=============================================================================
	Notify that the color is changing. Color is specified in the CIE 1931 (XYZ) color space
		xTarget - x chromaticity coordinate (float) of the target color
		yTarget - y chromaticity coordinate (float) of the target color
		targetColorMode - Target color mode
			LightDevice.COLOR_MODE_FULL_COLOR = 0 (Full color)
			LightDevice.COLOR_MODE_CCT        = 1 (Color temperature)
		milliseconds - Integer - transition/ramp time to get to the target color
		xCurrent - Optional x chromaticity coordinate (float) of the current color
		yCurrent - Optional y chromaticity coordinate (float) of the current color
		currentColorMode - Current color mode
			LightDevice.COLOR_MODE_FULL_COLOR = 0 (Full color)
			LightDevice.COLOR_MODE_CCT        = 1 (Color temperature)
===============================================================================]]
function LightReport_LightColorChanging(xTarget, yTarget, targetColorMode, milliseconds,
		xCurrent, yCurrent, currentColorMode)
	TheLight:ReportLightColorChanging(xTarget, yTarget, targetColorMode, milliseconds,
		xCurrent, yCurrent, currentColorMode)
end


--[[=============================================================================
	Notify that the color changed.
		x - x coordinate (float) in the CIE 1931 xyY color space chromaticity diagram
		y - y coordinate (float) in the CIE 1931 xyY color space chromaticity diagram
		colorMode - Color mode
			LightDevice.COLOR_MODE_FULL_COLOR = 0 (Full color)
			LightDevice.COLOR_MODE_CCT        = 1 (Color temperature)
===============================================================================]]
function LightReport_LightColorChanged(x, y, colorMode)
	TheLight:ReportLightColorChanged(x, y, colorMode)
end
