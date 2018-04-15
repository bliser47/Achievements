Achievements.categories = {};
Achievements.achievements = {};

Achievements.addAchievement = function(achievement)
    table.insert(Achievements.achievements,achievement);
    local achievementId = table.getn(Achievements.achievements);
    if achievement.category then
        table.insert(Achievements.categories[achievement.category].achievementIds,achievementId);
    end
    achievement.complete = false;
    achievement.criterias = achievement.criterias or {};
    return achievementId;
end

Achievements.addCategory = function(name, parent)
    table.insert(Achievements.categories,{
        name = name,
        parent = parent or -1,
        achievementIds = {}
    });
    local categoryId = table.getn(Achievements.categories);
    Achievements.categories[categoryId].id = categoryId;
    return categoryId;
end

Achievements.loadAchievement = function(achievement)
    Achievements.Debug("Loading achievement: " .. achievement.name);
    for _, criteria in ipairs(achievement.criterias) do
        criteria.parent = achievement;
        if not AchievementsDB.char.achievements[achievement.key] then
            Achievements.loadCriteria(criteria);
        else
            criteria.complete = true;
        end
    end
end


Achievements.loadCriteria = function(criteria)
    Achievements.Debug("Loading criteria " .. criteria.key);
    if not AchievementsDB.char.criterias[criteria.key] then
        for _, event in ipairs(criteria.events) do
            Achievements.loadEvent(event,criteria);
        end
    else
        criteria.complete = true;
    end
end


Achievements.loadEvent = function(event, criteria)
    Achievements.Debug("Loading event: " .. event);
    criteria.listeners = criteria.listeners or {};
    table.insert(criteria.listeners, Achievements.AddListener(event, function(listener, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
        Achievements.Debug("Calling criteria objective: " .. criteria.key);
        local criteria = listener.arg.criteria;
        local self = listener.arg.self;
        if criteria.objective(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12) then
            self.completeCriteria(criteria);
        end
    end, {
        criteria = criteria,
        self = Achievements
    }));
end


Achievements.completeCriteria = function(criteria)
    Achievements.Debug("Completing criteria: " .. criteria.key);
    criteria.complete = true;
    AchievementsDB.char.criterias[criteria.key] = time();
    if criteria.listeners then
        for _, listener in ipairs(criteria.listeners) do
            Achievements.RemoveListener(listener, "criteria complete: " .. criteria.key );
        end
    end
    criteria.listeners = {};
    Achievements.checkAchievementComplete(criteria.parent);
    Achievements.OnEvent("ACHIEVEMENT_BOOK_CRITERIA_COMPLETE",criteria);
end


Achievements.checkAchievementComplete = function(achievement)
    local completeCriterias = 0;
    local totalCriterias = 0;
    for _, criteria in ipairs(achievement.criterias) do
        if criteria.complete then
            completeCriterias = completeCriterias + 1;
        end
        totalCriterias = totalCriterias + 1;
    end
    local requiredCriterias = achievement.required or totalCriterias;
    if completeCriterias >= requiredCriterias then
        Achievements.completeAchievement(achievement);
    end
end


Achievements.completeAchievement = function(achievement, onLoad)
    if achievement.previous then
        Achievements.CompleteAchievement(GetPreviousAchievement(achievement.id,nil,onLoad));
    end

    achievement.complete = true;

    AchievementsDB.char.achievements[achievement.key] = time();
    Achievements.Debug("Completing achievement: " .. achievement.name)
    Achievements.OnEvent("ACHIEVEMENT_BOOK_ACHIEVEMENT_COMPLETE",achievement);
end


Achievements.Debug = function(obj)
    if Achievements.isDebug then
        DEFAULT_CHAT_FRAME:AddMessage(obj);
    end
end

Achievements.InitializeCore = function()
    ACHIEVEMENT_CATEGORY_GENERAL = Achievements.addCategory("General");
    Achievements.Debug("Initializing core");

    AchievementsDB = AchievementsDB or {};
    AchievementsDB.char = AchievementsDB.char or {};
    AchievementsDB.char.achievements = AchievementsDB.char.achievements or {};
    AchievementsDB.char.criterias = AchievementsDB.char.criterias or {};

    if Achievements.achievements then
        for _, achievement in pairs(Achievements.achievements) do
            Achievements.loadAchievement(achievement);
        end
    end
end
