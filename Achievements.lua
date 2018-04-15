Achievements = {
    isDebug = true
};

function Achievements_OnLoad()
    Achievements.frame = this;
    Achievements.InitializeEventHandler();
    Achievements.InitializeEventListener()
    Achievements.AddListenerOnce("ADDON_LOADED",function(_, name)
        if name == "Achievements" then
            Achievements.InitializeCore();
        end
    end)
end