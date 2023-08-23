--[[=============================================================================
    File is: light_main.lua

    Copyright 2023 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "light_proxy.light_device_class"
require "light_proxy.light_reports"
require "light_proxy.light_apis"
require "light_communicator"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_main = "2023.04.28"
end


TheLight = nil		-- can only have one Light in a driver, this should probably change

function CreateLightProxy(BindingID, ProxyInstanceName, ButtonLinkBindingIdBase)
	if(TheLight == nil) then
		TheLight = LightDevice:new(BindingID, ProxyInstanceName, ButtonLinkBindingIdBase)

		if(TheLight ~= nil) then
			TheLight:InitialSetup()
		else
			LogFatal("CreateLightProxy  Failed to instantiate Light")
		end
	end
end


function ON_DRIVER_LATEINIT.LightProxySupport()
	if(TheLight ~= nil) then
		TheLight:LateSetup()
	else
		LogFatal("ON_DRIVER_LATEINIT.LightProxySupport Failed to instantiate light")
	end
end

