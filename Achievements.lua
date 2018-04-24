Achievements = {
    isDebug = true
};

function Achievements_OnLoad()
    Achievements.frame = this;
    Achievements.InitializeEventHandler();
    Achievements.InitializeEventListener()
    Achievements.AddListenerOnce("ADDON_LOADED",function(_, name)
        if name == "Achievements" then
            Achievements.InitializeModel();
            Achievements.InitializeCore();
            Achievements.InitializeAchievements();
        end
    end)
end