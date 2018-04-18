Achievements.Debug = function(obj)
    if Achievements.isDebug then
        if type(obj) == "table" then
            for i,v in pairs(obj) do
                --DEFAULT_CHAT_FRAME:AddMessage(i);
                Achievements.Debug(v);
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(obj);
        end
    end
end