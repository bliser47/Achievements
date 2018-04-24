--[[
	Initialize the listeners
	@return null
]]--
function Achievements.InitializeEventListener()
    Achievements.listeners = Achievements.listeners or {};
end

--[[
	Dispatches a listeners callback then it removes
    the listener if it was only listening once
	@param {Object} listener
	@param {Object[]} ...
	@return null
]]--
function Achievements.DispatchListener(listener, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	listener.callback(listener, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
	if listener.count then
		listener.count = listener.count - 1;
		if listener.count <= 0 then
            Achievements.RemoveListener(listener, " was only a one time listener");
		end
	end
end


--[[
	Adds a listener wich will only listen once
	@param {String} event
	@param {Function} callback
	@return {Object}
]]--
function Achievements.AddListenerOnce(event, callback, arg)
	return Achievements.AddListener(event, callback, arg, 1);
end


--[[
	Adds a callback for an events with possible count
	@param {String} event
	@param {Function} callback
	@param {table} [arg]
	@param {Number} [count]
	@return {Object}
]]--
function Achievements.AddListener(event, callback, arg, count)
	--Achievements.Debug("Trying to start listening to: " .. event);
    Achievements.Listen(event);
	local listener = {
		event = event,
		callback = callback,
        arg = arg,
		count = count
	};
	table.insert(Achievements.listeners, listener);
	return listener;
end


--[[
	Removes a listener
	@param {Object} removeListener
	@param {String} explanation
	@return null
]]--
function Achievements.RemoveListener(removeListener, explanation)
    --Achievements.Debug("Removing listener: " .. removeListener.event .. " (" .. explanation  .. ")");
	local anyoneElseListening = false;
	local removeIndexes = {};
	for index, listener in ipairs(Achievements.listeners) do
		if listener == removeListener then
			table.insert(removeIndexes,index);
		elseif listener.event == removeListener.event then
			anyoneElseListening = true;
		end
	end
	for _, removeIndex in ipairs(removeIndexes) do
		table.remove(Achievements.listeners, removeIndex);
	end
	if not anyoneElseListening then
        Achievements.StopListening(removeListener.event);
	end
	removeListener = null;
end