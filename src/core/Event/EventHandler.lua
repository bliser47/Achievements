--[[
	Register an event
	@param {string} event
	@returns {undefined}
--]]
function Achievements.RegisterEvent(event)
    Achievements.Debug("Registering Event: " .. event);
    Achievements.frame:RegisterEvent(event);
end


--[[
	Unregister an event
	@param {string} event
	@returns {undefined}
--]]
function Achievements.UnregisterEvent(event)
    Achievements.Debug("Unregistering Event: " .. event);
    Achievements.frame:UnregisterEvent(event);
end


--[[
	Return whether we are already
	listening to an event or not
	@param {string} addEvent
	@returns {boolean}
]]--
function Achievements.AlreadyListening(addEvent)
	for _, event in ipairs(Achievements.events) do
		if event == addEvent then
			return true;
		end
	end
	return false;
end


--[[
	Start listening to an event
	if not already listening to it
	@param {string} addEvent
	@returns {undefined}
]]--
function Achievements.Listen(addEvent)
	if not Achievements.AlreadyListening(addEvent) then
		table.insert(Achievements.events, addEvent);
        Achievements.RegisterEvent(addEvent);
	else
		Achievements.Debug("Already listening to: " .. addEvent);
	end
end


--[[
	Stop listening to an event
	@param {string} removeEvent
	@returns {undefined}
]]--
function Achievements.StopListening(removeEvent)
	for index, event in ipairs(Achievements.events) do
		if event == removeEvent then
			table.remove(Achievements.events, index);
			return Achievements.UnregisterEvent(event);
		end
	end
end


--[[
	When an event happens
	@param {string} event
	@param {list} ...
	@returns {undefined}
]]--
function Achievements.OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	Achievements.Debug("Event: " .. event);
	for _, listener in ipairs(Achievements.listeners) do
		if listener.event == event then
            Achievements.DispatchListener(listener, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
		end
	end
end


--[[
	Initialize the events
	@return null
]]--
function Achievements.InitializeEventHandler()
    Achievements.events = Achievements.events or {};
    Achievements.frame:SetScript("OnEvent", function()
		Achievements.Debug("Frame Event: " .. event);
		Achievements.OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
	end);
end