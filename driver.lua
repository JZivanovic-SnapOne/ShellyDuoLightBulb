require "lib.c4_queue"

require "common.c4_driver_declarations"
require "common.c4_common"
require "common.c4_property"
require "common.c4_init"
require "common.c4_command"
require "common.c4_diagnostics"
require "common.c4_notify"
require "common.c4_utils"
require "light_proxy.light_reports"
require "light_proxy.light_main"
require "light_communicator"
require "proxy_commands"
require "properties"


gRampDimmingInfo = nil
gRampDimmingTimer = nil

gQueryTimer = nil
gQueryQueue = {}

LIGHT_PROXY_BINDINGID = 5001
LIGHT_PROXY_BUTTON_LINK_BINDINGID_BASE = 300

DMX_QUERY_TIMEOUT_SECONDS = 5

__IP_ADRESS = nil


function isTableEmpty(t)
	if(type(t) ~= 'table') then return nil end
	if(next(t)==nil) then return true end
	return false
end


---Report dynamic capabilities here, does not work in OnDriverInit, where the mode property gets
---updated.
function ON_DRIVER_LATEINIT.Capabilities()
	CreateLightProxy(LIGHT_PROXY_BINDINGID,"Light Proxy",LIGHT_PROXY_BUTTON_LINK_BINDINGID_BASE)
end

function ON_DRIVER_LATEINIT.Init()
	SetLogName("Control4 DMX Light Load")

	CreateLightProxy(LIGHT_PROXY_BINDINGID,"Light Proxy",LIGHT_PROXY_BUTTON_LINK_BINDINGID_BASE)
	LightReport_OnlineChanged(true)
	SetAutoAls(true)
	SetAutoSwitch(true)
	SetAutoButton(true)
	SetAutoGroup(true)
	SetAutoGroupCommands(true)

	local x, y, mode = GetLightColor()
	if (x and y and mode) then
		LightReport_LightColorChanged(x, y, mode)
	else
		-- If current color does not exist, request it from the gateway
		QueryCurrentChannels(true)
	end
end

function ON_DRIVER_LATEINIT.DriverStatus()
	local tStatus = {}
	local gateway = C4:GetBoundProviderDevice(C4:GetDeviceID(), GATEWAY_BINDINGID)

	tStatus.GatewayConnected = gateway ~= nil
	tStatus.LineSelected = (#(PersistData.Lines or {}) > 0) and (tonumber(GetGatewayLine()))
	SetDriverStatus(tStatus)
end

function StartRampDimming(brightnessTarget, channels, transitionTime)
	gRampDimmingInfo = {
		StartTime = C4:GetTime(),
		Channels = channels,
		Rate = transitionTime,
		BrightnessTarget = brightnessTarget,
		BrightnessCurrent = GetLightLevel()
	}
	
end
