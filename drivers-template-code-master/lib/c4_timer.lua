--[[=============================================================================
    c4_timer Class

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]
require "common.c4_driver_declarations"
require "lib.c4_object"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_timer = "2022.04.28"
end

c4_timer = inheritsFrom(nil)

function c4_timer:construct(name, interval, units, Callback, repeating, CallbackParam)
	self._name = name
	self._timerID = TimerLibGetNextTimerID()
	self._interval = interval
	self._units = units
	self._repeating = repeating or false
	self._Callback = Callback
	self._CallbackParam = CallbackParam or ""
	self._id = 0
	self._onceOnly = false

	gTimerLibTimers[self._timerID] = self
	if (LOG ~= nil and type(LOG) == "table") then
		LogTrace("Created timer %s", (self._name or "Un-named"))
	end
end

function c4_timer:StartTimer(...)
	self:KillTimer()

	-- optional parameters (interval, units, repeating)
	if ... then
		local interval = select(1, ...)
		local units = select(2, ...)
		local repeating = select(3, ...)

		self._interval = interval or self._interval
		self._units = units or self._units
		self._repeating = repeating or self._repeating
	end

	if (tonumber(self._interval) > 0) then
--		if (LOG ~= nil and type(LOG) == "table") then
--			LogTrace("Starting Timer: %d (%s)", self._timerID, (self._name or "Un-named"))
--		end

		self._id = C4:AddTimer(self._interval, self._units, self._repeating)

--		if (LOG ~= nil and type(LOG) == "table") then
--			LogTrace("Started Timer: %d (%s)  Id: %d", self._timerID, (self._name or "Un-named"), self._id)
--		end
	end
end

function c4_timer:KillTimer()
	if (self._id) then
		self._id = C4:KillTimer(self._id)
	end
end

function c4_timer:SetCallbackParam(NewParam)
	self._CallbackParam = NewParam
end

function c4_timer:TimerStarted()
	return (self._id ~= 0)
end

function c4_timer:TimerStopped()
	return (self._id == 0)
end

function c4_timer:GetTimerInterval()
	return (self._interval)
end

function TimerLibGetNextTimerID()
	gTimerLibTimerCurID = gTimerLibTimerCurID + 1
	return gTimerLibTimerCurID
end

function ON_DRIVER_EARLY_INIT.c4_timer(strDit)
	gTimerLibTimers = {}
	gTimerLibTimerCurID = 0
end

function ON_DRIVER_DESTROYED.c4_timer(strDit)
	-- Kill open timers
	for k,v in pairs(gTimerLibTimers) do
		v:KillTimer()
	end
end

--[[=============================================================================
    OnTimerExpired(idTimer)

    Description:
    Function called by Director when the specified Control4 timer expires.

    Parameters:
    idTimer(string) - Timer ID of expired timer.
===============================================================================]]
function OnTimerExpired(idTimer)
--	LogTrace("OnTimerExpired %d", idTimer)
	for k,v in pairs(gTimerLibTimers) do
		if (idTimer == v._id) then
			if (v._Callback) then
				v._Callback(v._CallbackParam)
			end
			
			if(v._onceOnly) then
--				LogTrace("Remove Timer: %d (%s)", k, tostring(v._name))
				v:KillTimer()
				gTimerLibTimers[k] = nil
			end
		end
	end
end

--[[=============================================================================
    CreateTimer(name, interval, units, callback, repeating, callbackParam)

    Description: 
    Creates a named timer with the given attributes

    Parameters:
    name(string)       - The name of the timer being created
    interval(int)      - The amount of the given time between calls to the
                         timers callback function
    units(string)      - The time of time interval used (e.g. MILLISECONDS, SECONDS, MINUTES, HOURS)
    callback(functin)  - The function to call when the timer expires
    repeating(bool)    - Parameter indicating whether the timer should be
                         called repeatedly until cancelled
    callbackParam(...) - Parameters to be passed to the callback function

    Returns:
    A handle to the timer
===============================================================================]]
function CreateTimer(name, interval, units, callback, repeating, callbackParam)
	timer = c4_timer:new(name, interval, units, callback, repeating, callbackParam)
	return timer
end

--[[=============================================================================
    StartTimer(handle, ...)

    Description: 
    Starts the timer created by calling the CreateTimer functions

    Parameters:
    handle(timer)   - Handle to a created timer object
    interval(int)   - The amount of the given time between calls to the
                      timers callback function
    units(string)   - The time of time interval used (e.g. SECONDS, MINUTES, ...)
    repeating(bool) - Parameter indicating whether the timer should be
                      called repeatedly until cancelled

    Returns:
    None
===============================================================================]]
function StartTimer(handle, ...)
	handle:StartTimer(...)
end

--[[=============================================================================
    KillTimer(handle)

    Description: 
    Starts the timer created by calling the CreateTimer functions

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    None
===============================================================================]]
function KillTimer(handle)
	handle:KillTimer()
end

--[[=============================================================================
    TimerStarted(handle)

    Description: 
    Identifies whether a timer has been started or not

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns true if a the given timer handle has been started, or false otherwise
===============================================================================]]
function TimerStarted(handle)
	return handle:TimerStarted()
end

--[[=============================================================================
    TimerStopped(handle)

    Description: 
    Identifies whether a timer has been stopped or not

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns true if a the given timer handle has been stopped, or false otherwise
===============================================================================]]
function TimerStopped(handle)
	return handle:TimerStopped()
end

--[[=============================================================================
    GetTimerInterval(handle)

    Description: 
    Gets the interval setting of the given timer

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns the interval setting of the given timer
===============================================================================]]
function GetTimerInterval(handle)
	return handle:GetTimerInterval()
end


--[[=============================================================================
	OneShotTimers are non-repeating timers that start running as soon as they
	are created.  They are handy for a quick single use delayed action.
	Originally implemented by RyanE.
===============================================================================]]

--[[=============================================================================
    OneShotTimerAdd(nInterval, strUnits, fCallback, Name)

    Description: 
    Adds and starts a non-repeating timer by wrapping calls to the more general timer routines

    Parameters:
    nInterval(int)      - The amount of the given time between calls to the
                         timers callback function
    strUnits(string)   - The time of time nInterval used (e.g. MILLISECONDS, SECONDS, MINUTES, HOURS)
    callback(function) - The function to call when the timer expires
    name(string)       - The name of the timer being created

    Returns:
    Nothing
===============================================================================]]
function OneShotTimerAdd(nInterval, strUnits, fCallback, name, callbackParam)
	local OSTimer  = CreateTimer(name, nInterval, strUnits, fCallback, false, callbackParam or "")
	OSTimer._onceOnly = true
	OSTimer:StartTimer()
end

--[[=============================================================================
    OneShotTimerKill(Name)

    Description: 
    Finds and kills a previously crested One Shot Timer

    Parameters:
    name(string)       - The name of the timer to be killed

    Returns:
    Nothing
===============================================================================]]
function OneShotTimerKill(Name)
	for k,v in pairs(gTimerLibTimers) do
		if(v._name == Name) then
			v:KillTimer()
		end
	end
end

--[[=============================================================================
    c4_timer Unit Tests
===============================================================================]]
-- function __test_c4_timer()
	-- require "test.C4Virtual"
	-- require "lib.c4_log"
	-- require "common.c4_init"

	-- OnDriverInit()

	-- local LOG = c4_log:new("test_c4_timer")
	-- LOG:SetLogLevel(5)
	-- LOG:OutputPrint(true)

	-- function OnTestTimerExpired()
		-- c4Timer:KillTimer()
	-- end

	-- -- create an instance of the timer
	-- c4Timer = c4_timer:new("Test", 45, "MINUTES", OnTestTimerExpired)

	-- assert(c4Timer._id == 0, "_id is not equal to '0' it is: " .. c4Timer._id)
	-- c4Timer:StartTimer()
	-- assert(c4Timer._id == 10001, "_id is not equal to '10001' it is: " .. c4Timer._id)
	-- assert(c4Timer:TimerStarted() == true, "TimerStarted is not equal to true it is: " .. tostring(c4Timer:TimerStarted()))
	-- assert(c4Timer:TimerStopped() == false, "TimerStopped is not equal to false it is: " .. tostring(c4Timer:TimerStopped()))
	-- OnTimerExpired(c4Timer._id)
	-- assert(c4Timer:TimerStarted() == false, "TimerStarted is not equal to false it is: " .. tostring(c4Timer:TimerStarted()))
	-- assert(c4Timer:TimerStopped() == true, "TimerStopped is not equal to true it is: " .. tostring(c4Timer:TimerStopped()))
-- end
