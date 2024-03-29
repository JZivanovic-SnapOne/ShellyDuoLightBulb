--[[=============================================================================
    File is: light_communicator.lua

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_communicator = "2021.12.01"
end

---@alias colorMode_t LightDevice.COLOR_MODE_FULL_COLOR|LightDevice.COLOR_MODE_CCT
--- Color Mode argument can take 2 different values:
--- 0 -> Full Color (LightDevice.COLOR_MODE_FULL_COLOR)
--- 1 -> CCT (LightDevice.COLOR_MODE_CCT)

---@alias buttonId_t LightDevice.BUTTON_ID_TOP|LightDevice.BUTTON_ID_BOTTOM|LightDevice.BUTTON_ID_TOGGLE
--- Button Id argument can take 3 different values:
--- 0 -> Top Button (LightDevice.BUTTON_ID_TOP)
--- 1 -> Bottom Button (LightDevice.BUTTON_ID_BOTTOM)
--- 2 -> Toggle Button (LightDevice.BUTTON_ID_TOGGLE)

---@alias buttonAction_t LightDevice.BUTTON_ACTION_RELEASE|LightDevice.BUTTON_ACTION_PRESS|LightDevice.BUTTON_ACTION_CLICK|LightDevice.BUTTON_ACTION_DOUBLE_CLICK|LightDevice.BUTTON_ACTION_TRIPLE_CLICK
--- Button Action argument can thake 5 different values:
--- 0 -> Release (LightDevice.BUTTON_ACTION_RELEASE)
--- 1 -> Press (LightDevice.BUTTON_ACTION_PRESS)
--- 2 -> Click (LightDevice.BUTTON_ACTION_CLICK)
--- 3 -> Double Click (LightDevice.BUTTON_ACTION_DOUBLE_CLICK)
--- 4 -> Triple Click (LightDevice.BUTTON_ACTION_TRIPLE_CLICK)
--
--- Use cases examples:
--- When the button has been clicked -> PRESS and CLICK will be received
--- When the button has been pressed, hold and released -> PRESS and RELEASE will be received
--- When the button has been clicked 2 times in a row -> PRESS, CLICK, PRESS, CLICK, DOUBLE_CLICK will be received

---@alias presetLevelCommand_t "MODIFIED"|"ADDED"|"DELETED"
--- There are 3 different ways to change a preset, this type describes what happened with the preset.

--[[=============================================================================
------------------------------- ILLUMINATION HOOKS ------------------------------
===============================================================================]]


--- Used to set the target brightness of where the light is being requested to go.
---@param brightnessTarget int Target brightness value of the dimming process
---@param milliseconds int Duration of the light dimming process in milliseconds
--
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
function LightCom_SetBrightnessTarget(brightnessTarget, milliseconds)
	LogTrace("LightCom_SetBrightnessTarget %d %d", brightnessTarget, milliseconds)
	if milliseconds < 0 then
		milliseconds = 0
	end
	--LightReport_LightBrightnessChanging(brightnessTarget,milliseconds,GetLightLevel())
	local status, err = pcall(TurnOn,brightnessTarget)
	
	LightReport_LightBrightnessChanged(brightnessTarget)
end

function TurnOn(brightness)
    local headers = {}
    myurl = C4:url()
	__IP_ADRESS = Properties ["Set IP adress"]
    myurl:OnDone(function(transfer, responses, errCode, errMsg)
    if (errCode == 0) then
        local lresp = responses[#responses]
        LogTrace("OnDone: transfer succeeded (" .. #responses .. " responses received), last response code: " .. lresp.code)
        for hdr,val in pairs(lresp.headers) do
			LogTrace("OnDone: " .. hdr .. " = " .. val)
        end
        LogTrace("OnDone: body of last response: " ..tostring(lresp.body))
        local data = C4:JsonDecode(lresp.body)
        data.ison = true
    else
        if (errCode == -1) then
			LogTrace("OnDone: transfer was aborted")
        else
			LogTrace("OnDone: transfer failed with error " .. errCode .. ": " .. errMsg .. " (" .. #responses .. " responses completed)")
        end
    end
    end)
	if brightness~= 0 then
    	myurl:Get(__IP_ADRESS.."/light/0?turn=on&brightness="..tostring(brightness), headers)
	else
    	myurl:Get(__IP_ADRESS.."/light/0?turn=off", headers)
	end

end


--- Used to start dimming (ramping up/down, relative dimming), initiated by button press/release,
--- group or scene ramp up/down.
--- @param milliseconds int Duration of the light dimming process in milliseconds
--- @param brightnessTarget int Target brightness value of the light brightness
--- @param x float X color component
--- @param y float Y color component
--- @param colorMode colorMode_t Color Target Color Mode
--
--- For lights that do not support color, color parameters (x, y and colorMode) will be nil
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
--- called in transition time.
function LightCom_StartRampDimming(milliseconds, brightnessTarget, x, y, colorMode)
	LogTrace("LightCom_StartRampDimming Brightness %d %d", milliseconds, brightnessTarget)
	local hasTargetColor = x and y and colorMode
	if hasTargetColor then
		LogTrace("LightCom_StartRampDimming Color %f, %f %d", x, y, colorMode)
		if not CheckColorMode(colorMode) then
			LogError("ERROR: Color mode %d not supported in %s operation mode", colorMode, GetOperationMode())
			hasTargetColor = false
		end
	end
	local OperationMode = GetOperationMode()
	if operationMode.HasMasterDimming and GetMasterDimmingChannel() and not hasTargetColor then
		LogDebug("LightCom_StartRampDimming using master dimming")
		StartRampDimming(brightnessTarget, {{
			channel = GetMasterDimmingChannel(),
			value = ScaleByte(255, brightnessTarget),
			current = ScaleByte(255, GetLightLevel()),
		}}, milliseconds)
	else
		operationMode:StartRampDimming(milliseconds, brightnessTarget,x,y,colorMode)
	end
	LightReport_LightBrightnessChanged(brightnessTarget, milliseconds)
end


--- Used to set the color and brightness target of where the light is being requested to go through scene.
---@param brightnessTarget int Target brightness value of the dimming process
---@param x float X color component
---@param y float Y color component
---@param colorMode colorMode_t Color Target Color Mode
---@param millisecondsBrightness int Duration of the light dimming process in milliseconds
---@param millisecondsColor int Duration of the light color changing process in milliseconds
--
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
--- called in transition time.
function LightCom_RampToColorAndBrightnessTarget(brightnessTarget, x, y, colorMode, millisecondsBrightness, millisecondsColor)
	LogTrace("LightCom_RampToColorAndBrightnessTarget %d %f %f %d %d %d", brightnessTarget, x, y, colorMode, millisecondsBrightness, millisecondsColor)
	millisecondsBrightness = millisecondsBrightness or 0
	millisecondsColor = millisecondsColor or 0
	if millisecondsBrightness < 0 then
		millisecondsBrightness = 0
	end
	if millisecondsColor < 0 then
		millisecondsColor = 0
	end

	pcall(LightCom_SetBrightnessTarget,brightnessTarget,millisecondsBrightness)
	pcall(LightCom_SetColorTarget,x, y, colorMode, millisecondsColor)

	--[[ClearRampDimming()
	LightReport_LightBrightnessChanging(brightnessTarget,milliseconds,GetLightLevel())
	local status, err = pcall(TurnOn,brightnessTarget)
	LogTrace("TurnOn function status %d",status)
	LogTrace("TurnOn function err %d",err)
	
	LightReport_LightBrightnessChanged(brightnessTarget)

	if not CheckColorMode(colorMode) then
		LogError("ERROR: Color mode %d not supported in %s operation mode", colorMode, GetOperationMode())
		x,y,colorMode = GetLightColor()
	end

	local operationMode = GetOperationMode()
	operationMode:RampToColorAndBrightnessTarget(brightnessTarget,x,y,colorMode,millisecondsBrightness,millisecondsColor)]]
end


--- Used to stop ongoing ramping process.
--
--- This hook will be called only if the *AutoRamp* is set to false.
--- Use the LightReport_LightBrightnessChanged report after the function is successfully executed.
function LightCom_RampStop()
	LogTrace("LightCom_RampStop")
end


--- Used to set the color of the color-enabled light.
---@param x float X color component
---@oaram y flash Y color component
---@param colorMode colorMode_t Color Target Color Mode
---@param milliseconds int Duration of the light color changing process in milliseconds
--
--- Target color's chromaticity is specified in CIE 1931 (XYZ) color space.
--- Will be called only if supports_color lightv2 proxy capability is true.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
--- called in transition time.
function LightCom_SetColorTarget(x, y, colorMode, milliseconds)
	LogTrace("LightCom_SetColorTarget x = %f, y = %f, Mode = %d, Rate = %dms", x, y, colorMode, milliseconds)
	--[[if not CheckColorMode (colorMode) then
		LogError("ERROR: Color mode %d not supported in %s operation mode", colorMode, GetOperationMode())
		return
	end
	local operationModeHandlers = GetOperationModeHandlers()]]
	--LightReport_LightColorChanging(x, y, colormode, milliseconds, x, y, ColorMode)
	local temperature = C4:ColorXYtoCCT (x, y)
    pcall(ChangeTemperature,temperature)
	LightReport_LightColorChanged(x,y,colorMode)
	--operationModeHandlers:SetColorTarget(x,y,colorMode,milliseconds)
end


function ChangeTemperature(temperature)
    local headers = {}
    myurl = C4:url()
	__IP_ADRESS = Properties ["Set IP adress"]
    myurl:OnDone(function(transfer, responses, errCode, errMsg)
    if (errCode == 0) then
        local lresp = responses[#responses]
        LogTrace("OnDone: transfer succeeded (" .. #responses .. " responses received), last response code: " .. lresp.code)
        for hdr,val in pairs(lresp.headers) do
			LogTrace("OnDone: " .. hdr .. " = " .. val)
        end
        LogTrace("OnDone: body of last response: " ..tostring(lresp.body))
        local data = C4:JsonDecode(lresp.body)
        data.ison = true
    else
        if (errCode == -1) then
			LogTrace("OnDone: transfer was aborted")
        else
			LogTrace("OnDone: transfer failed with error " .. errCode .. ": " .. errMsg .. " (" .. #responses .. " responses completed)")
        end
    end
    end)
    myurl:Get(__IP_ADRESS.."/light/0?temp="..tostring(temperature), headers)
end


--- Used to hande BUTTON_ACTION proxy commands.
---@param buttonId buttonId_t Id of the triggered button
---@param action buttonAction_t
--
--- This hook will be called only if the *AutoRamp* is set to false.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
function LightCom_ButtonAction(buttonId, action)
	LogTrace("LightCom_ButtonAction %d %d", buttonId, action)
end


--- Used to turn ON the light.
--
--- This hook will be called when the *AutoSwitch* is set to false and the *ON* proxy command has been
--- received. ON proxy command will be triggered by the Custom Programming Light Command *On*.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
function LightCom_On()
	LogTrace("LightCom_On")
end


--- Used to turn OFF the light.
--
--- This hook will be called when the *AutoSwitch* is set to false and the *OFF* proxy command has been
--- received. ON proxy command will be triggered by the Custom Programming Light Command *Off*.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
function LightCom_Off()
	LogTrace("LightCom_Off")
	LightReport_LightBrightnessChanging(0,GetClickRateDown(),0)
	local status, err = pcall(TurnOn,0)
	LogTrace("TurnOn function status %d",status)
	LogTrace("TurnOn function err %d",err)
	
	LightReport_LightBrightnessChanged(0)
end

--- Used to TOGGLE the light.
--
--- This hook will be called when the *AutoSwitch* is set to false and the *TOGGLE* proxy command has been
--- received. ON proxy command will be triggered by the Custom Programming Light Command *Toggle*.
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
--- called if the driver supports *supports_target* capability.
function LightCom_Toggle()
	LogTrace("LightCom_Toggle")
end


--[[=============================================================================
------------------------ ADVANCED LIGHTING SCENE HOOKS --------------------------
===============================================================================]]


--- Call when user Activate Scene
---@param sceneId int Id of the scene
--
--- Will called only if *AutoAls* is false.
function LightCom_ActivateScene(sceneId)
	LogTrace("LightCom_ActivateScene %d", sceneId)
end


--- Call when system All Scenes are Pushed
--
--- Will called only if *AutoAls* is false
function LightCom_AllScenesPushed()
	LogTrace("LightCom_AllScenesPushed")
end


--- Call when system Clear All Scenes
--
--- Will called only if *AutoAls* is false
function LightCom_ClearAllScenes()
	LogTrace("LightCom_ClearAllScenes")
end


--- Call when dealer Push Scene
---@param sceneId int Id of the scene
---@param elements string Scene data XML
---@param flash boolean
---@param ignoreRamp boolean
---@param fromGroup boolean
--
--- Will called only if *AutoAls* is false.
function LightCom_PushScene(sceneId, elements, flash, ignoreRamp, fromGroup)
	LogTrace("LightCom_PushScene %d \"%s\" %s %s %s", sceneId, elements, tostring(flash), tostring(ignoreRamp), tostring(fromGroup))
end


--- Call when user Ramp Scene Down
---@param sceneId int Id of the scene
---@param milliseconds int Duration of the scene ramping process in milliseconds
--
--- Will called only if *AutoAls* is false.
function LightCom_RampSceneDown(sceneId, milliseconds)
	LogTrace("LightCom_RampSceneDown %d %d", sceneId, milliseconds)
end


--- Call when user Ramp Scene Down
---@param sceneId int Id of the scene
---@param milliseconds int Duration of the scene ramping process in milliseconds
--
--- Will called only if *AutoAls* is false.
function LightCom_RampSceneUp(sceneId, milliseconds)
	LogTrace("LightCom_RampSceneUp %d %d", sceneId, milliseconds)
end


---Call when dealer Remove Scene
---@param sceneId int Id of the scene
--
--- Will called only if *AutoAls* is false.
function LightCom_RemoveScene(sceneId)
	LogTrace("LightCom_RemoveScene %d", sceneId)
end


--- Call when user Stop Ramp Scene
---@param sceneId int Id of the scene
--
--- Will called only if *AutoAls* is false.
function LightCom_StopRampScene(sceneId)
	LogTrace("LightCom_StopRampScene %d", sceneId)
end


--[[=============================================================================
------------------------------ LOAD GROUP HOOKS ---------------------------------
===============================================================================]]


--- Call when user Group Ramp to Level
---@param groupId int Id of the group
---@param level int Target light level
---@param milliseconds int Duration of the ramping process in milliseconds
--
--- Will called only if *AutoGroup* is false.
function LightCom_GroupRampToLevel(groupId, level, milliseconds)
	LogTrace("LightCom_GroupRampToLevel %d %d %d", groupId, level, milliseconds)
end


--- Call when user Group Set Level
---@param groupId int Id of the group
---@param level int Target brightness level
--
--- Will called only if AutoGroup is false
--- If the function has been successfully executed, the driver must call
--- the LightReport_LightBrightnessChanged report.
function LightCom_GroupSetLevel(groupId, level)
	LogTrace("LightCom_GroupSetLevel %d %d", groupId, level)
end


--- Call when user Group Start Ramp
---@param groupId int Id of the group
---@param rampUp boolean Indicates ramping up or down
---@param milliseconds int Duration of the ramping process in milliseconds
--
--- Will called only if *AutoGroup* is false.
--- Must call LightReport_LightBrightnessChanged with new level.
function LightCom_GroupStartRamp(groupId, rampUp, milliseconds)
	LogTrace("LightCom_GroupStartRamp %d %s %d", groupId, tostring(rampUp), milliseconds)
end


--- Call when user Group Stop Ramp
---@param groupId int Id of the group
--
--- Will called only if *AutoGroup* is false
--- Must call LightReport_LightBrightnessChanged with the new level.
function LightCom_GroupStopRamp(groupId)
	LogTrace("LightCom_GroupStopRamp %d", groupId)
end


--- Call when system Join to Group
---@param groupId int Id of the group
---@param keepSync boolean Indicates if the sync option is checked in the Composer Pro Properties
--
--- Will called only if *AutoGroup* is false.
function LightCom_JoinGroup(groupId, keepSync)
	LogTrace("LightCom_JoinGroup %d %s", groupId, tostring(keepSync))
end


--- Call when system Leave Group
---@param groupId int Id of the group
--
--- Will called only if *AutoGroup* is false.
function LightCom_LeaveGroup(groupId)
	LogTrace("LightCom_LeaveGroup %d", groupId)
end


--[[=============================================================================
---------------------------- DRIVER PROPERTIES HOOKS ----------------------------
===============================================================================]]


--- Call when dealer change Click Rate Up
---@param milliseconds int Click Rate Up value
function LightCom_SetClickRateUp(milliseconds)
	LogTrace("LightCom_SetClickRateUp %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ClickRateUp(milliseconds)
end


--- Call when dealer change Click Rate Down
---@param milliseconds int Click Rate Down value
function LightCom_SetClickRateDown(milliseconds)
	LogTrace("LightCom_SetClickRateDown %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ClickRateDown(milliseconds)
end


--- Call when dealer change Cold Start Level
---@param level int Cold Start Level Value
function LightCom_SetColdStartLevel(level)
	LogTrace("LightCom_SetColdStartLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_ColdStartLevel(level)
end


--- Call when dealer change Cold Start Time
---@param milliseconds int Cold Start Time value
function LightCom_SetColdStartTime(milliseconds)
	LogTrace("LightCom_SetColdStartTime %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ColdStartTime(milliseconds)
end


--- Call when dealer change Hold Rate Down
---@param milliseconds int Hold Rate Down value
function LightCom_SetHoldRateDown(milliseconds)
	LogTrace("LightCom_SetHoldRateDown %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_HoldRateDown(milliseconds)
end


--- Call when dealer change Hold Rate Up
---@param milliseconds int Hold Rate Up value
function LightCom_SetHoldRateUp(milliseconds)
	LogTrace("LightCom_SetHoldRateUp %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_HoldRateUp(milliseconds)
end


--- Call when dealer change Max On Level
---@param level int Max On Level value
function LightCom_SetMaxOnLevel(level)
	LogTrace("LightCom_SetMaxOnLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_MaxOnLevel(level)
end


--- Call when dealer change Min On Level
---@param level int Min On Level value
function LightCom_SetMinOnLevel(level)
	LogTrace("LightCom_SetMinOnLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_MinOnLevel(level)
end


--- Call when dealer change Preset Level
---@param level int Preset Level value
function LightCom_SetPresetLevel(level)
	LogTrace("LightCom_SetPresetLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_PresetLevel(level)
end


--- Called when a color preset (driver specific) is modified, added or deleted
---@param command presetLevelCommand_t String that describes what is happending with the preset
---@param id int Preset ID
---@param name string Preset name
---@param x float X chromaticity coordinate
---@param y float Y chromaticity coordinate
---@param colorMode colorMode_t Target color mode
function LightCom_UpdateColorPreset(command, id, name, x, y, colorMode)
	LogTrace("LightCom_UpdateColorPreset command = %s, id = %d, name = %s", command, id, name)
end
