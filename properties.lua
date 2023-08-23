IP_ADRESS = "Set IP adress"

PROPERTY_GATEWAY_LINE = "Gateway Line"

PROPERTY_MASTER_DIMMING = "Master Dimming"
PROPERTY_MASTER_DIMMING_CHANNEL = "Master Dimming Channel"

PROPERTY_WMR = "White Mixing Ratio"

function ON_DRIVER_EARLY_INIT.ChannelsTouched(strDit)
    local channelsTouched = C4:PersistGetValue("ChannelsTouched")
    if channelsTouched ~= nil then return end

    if strDit == "DIT_ADDING" then
        C4:PersistSetValue("ChannelsTouched", false)
    else
        -- Make sure to mark channels as touched when updating a driver from an older version
        C4:PersistSetValue("ChannelsTouched", true)
    end
end

ON_PROPERTY_CHANGED[PROPERTY_WMR] = function()
    if gInitializingDriver then return end

    local x, y, colorMode = GetLightColor()
    LightCom_SetColorTarget(x, y, colorMode, 0)
end

function GetWhiteMixingRatio() return tonumber(Properties[PROPERTY_WMR]) end

PROPERTY_DRIVER_STATUS = "Driver Status"

function ShowProperties(properties)
    for _, prop in ipairs(properties) do ShowProperty(prop) end
end

function HideProperties(properties)
    for _, prop in ipairs(properties) do HideProperty(prop) end
end

---Show or hide Gateway Line property depending on the number of available lines
function UpdateGatewayLineVisibility()
    local lines = PersistData.Lines or {}
    local numLines = #lines

    local prop = tonumber(Properties[PROPERTY_GATEWAY_LINE])
    local propList = table.concat(lines, ',')

    local selectedLine = ''
    if numLines == 1 then
        selectedLine = lines[1]
    else
        local found
        -- Check if previously selected line is in the list
        for _, v in ipairs(lines) do
            if v == prop then
                found = prop
                break
            end
        end
        if found then selectedLine = found end
    end
    SetDriverStatus({LineSelected = selectedLine ~= ''})
    C4:UpdatePropertyList(PROPERTY_GATEWAY_LINE, propList, tostring(selectedLine))
end

---Return gateway line in use
---If gateway has a single line, use that line. Otherwise, use line selected from properties
---@return number Gateway line
function GetGatewayLine()
    local lines = PersistData.Lines or {}
    local numLines = #lines
    if numLines == 1 then
        return lines[1]
    else
        return Properties[PROPERTY_GATEWAY_LINE]
    end
end


ON_PROPERTY_CHANGED[PROPERTY_GATEWAY_LINE] = function(strProperty)
    SetDriverStatus({LineSelected = tonumber(strProperty) ~= nil})
    if not gInitializingDriver then QueryCurrentChannels(true) end
end

function GetOperationMode()
    if IsCustomLEDTape() then
        return Properties[PROPERTY_MODE]
    else
        local data = GetLEDTapeData()
        return data[PROPERTY_MODE]
    end
end

function IsMasterDimmingEnabled()
    return Properties[PROPERTY_MASTER_DIMMING] == "Yes"
end

function OnMasterDimmingChanged()
    if IsMasterDimmingEnabled() then
        ShowProperty(PROPERTY_MASTER_DIMMING_CHANNEL)
        -- Set current color and brightness
        local x, y, colorMode = GetLightColor()
        local brightness = GetLightLevel()
        local operationMode = GetOperationModeHandlers()
        if x and y and colorMode and brightness then
            operationMode:RampToColorAndBrightnessTarget(brightness, x, y, colorMode, 0, 0)
        end

        if not gInitializingDriver and operationMode.HasMasterDimming then
            StartQueryTimer({[GetMasterDimmingChannel()] = true})
        end
    else
        HideProperty(PROPERTY_MASTER_DIMMING_CHANNEL)
    end
end

ON_PROPERTY_CHANGED[PROPERTY_MASTER_DIMMING] = OnMasterDimmingChanged

ON_PROPERTY_CHANGED[PROPERTY_MASTER_DIMMING_CHANNEL] = function()
    if not gInitializingDriver then
        local masterDimmingChannel = GetMasterDimmingChannel()
        if masterDimmingChannel then
            StartQueryTimer({[masterDimmingChannel] = true})
        end
        -- Mark that any channel is touched. Default values will not be set on mode change.
        C4:PersistSetValue("ChannelsTouched", true)
    end
end

---Get master dimming channel
---@return number|nil Channel number if master dimming is enabled, nil otherwise
function GetMasterDimmingChannel()
    return IsMasterDimmingEnabled() and tonumber(Properties[PROPERTY_MASTER_DIMMING_CHANNEL]) or nil
end



--#region Driver Status

gStatus = {
    -- Is the driver connected to a gateway?
    GatewayConnected = nil,
    -- Is Gateway Line selected
    LineSelected = nil,
}

---Set driver status flags and update Driver Status property
---@param tStatus table of status flags to update
function SetDriverStatus(tStatus)
    tStatus = tStatus or {}
    LogTrace('SetDriverStatus %s', C4:JsonEncode(tStatus))
    for k, v in pairs(tStatus) do gStatus[k] = v end

    local strStatus = 'OK'
    -- Order of if statements matter. Messages with a higher priority should be at the top.
    if not gStatus.GatewayConnected then
        strStatus = 'Not Connected to a Digital Lighting Gateway'
    elseif not gStatus.LineSelected then
        strStatus = 'Gateway Line not selected'
    end

    UpdateProperty(PROPERTY_DRIVER_STATUS, strStatus)
end

--#endregion