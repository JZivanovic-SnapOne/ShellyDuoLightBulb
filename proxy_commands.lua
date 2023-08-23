require "common.c4_bindings"

GATEWAY_BINDINGID = 1


function UpdateNetworkStatus(tParams)
	local status = tParams.STATUS
	LightReport_OnlineChanged(status)
end

function PRX_CMD.LINES_INFO(idBinding, tParams)
	SetLinesInfo(tParams)
end

function EX_CMD.LINES_INFO(tParams)
	SetLinesInfo(tParams)
end

function SetLinesInfo(tParams)
	local dmxLines = {}
	-- Line is an index in the tParams
	for k, v in pairs(tParams) do
		-- This is a line
		if tonumber(k) then
			LogDebug('Line %d %s', tonumber(k), v)
			if v == 'DMX' then table.insert(dmxLines, tonumber(k)) end
		end
	end
	PersistData.Lines = dmxLines
	UpdateGatewayLineVisibility()
end

EX_CMD.DMX_LEVELS = function(tParams)
	C4PrintTable(tParams)

	local channels = {}
	for k, v in pairs(tParams) do
		local channel = tonumber(k)
		if channel then channels[channel] = tonumber(v) end
	end

	local index, bUpdateColor = next(gQueryQueue)
	if index then table.remove(gQueryQueue, index) end
	LogTrace("HandleChannelUpdate: Update Color = %s", tostring(bUpdateColor))

	local operationMode = GetOperationModeHandlers()
	local masterDimmingChannel = operationMode.HasMasterDimming and GetMasterDimmingChannel()
	local brightness

	if masterDimmingChannel then
		brightness = GetPercent(channels[masterDimmingChannel])
		if bUpdateColor then
			local _, x, y, colorMode = operationMode:GetStateFromChannels(channels)
			if x and y and colorMode then
				LightReport_LightColorChanged(x, y, colorMode)
			end
		end
	else
		local b, x, y, colorMode = operationMode:GetStateFromChannels(channels)
		brightness = b
		if bUpdateColor and x and y and colorMode then
			LightReport_LightColorChanged(x, y, colorMode)
		end
	end
	LightReport_LightBrightnessChanged(brightness)
end


ON_BINDING_CHANGED[GATEWAY_BINDINGID] = function(idBinding, class, bIsBound)
	if idBinding == GATEWAY_BINDINGID then
		SetDriverStatus({GatewayConnected = bIsBound})
	end
end