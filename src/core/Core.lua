Achievements.categories = {};
Achievements.achievements = {};
Achievements.criterias = {};


Achievements.addCriteria = function(criteria, parent)

    table.insert(Achievements.criterias,criteria);
    local criteriaID = table.getn(Achievements.criterias);

    criteria.parent = parent;
    criteria.id = criteriaID
    criteria.progress = criteria.required and 1 or 0
    criteria.required = criteria.required or 1;
    criteria.format = criteria.format or (criteria.required and "%d / %d");
    criteria.value = criteria.value or function() return 0 end;

    if (criteria.name or criteria.required > 1) and not criteria.hidden  then
        table.insert(parent.visibleCriteria,criteria.id);
    end

    return criteriaID;
end

Achievements.addAchievement = function(achievement)
    table.insert(Achievements.achievements,achievement);
    local achievementId = table.getn(Achievements.achievements);
    Achievements.Debug(achievement.name);
    if achievement.category then
        table.insert(Achievements.categories[achievement.category].achievementIds,achievementId);
    end
    if Achievements.isAchievementComplete(achievement) then
        achievement.complete = Achievements.getAchievementCompleteDate(achievement);
    end

    local criteriaObjects = achievement.criterias;
    achievement.visibleCriteria = {};
    achievement.criterias = {};
    for _, criteria in ipairs(criteriaObjects) do
        table.insert(achievement.criterias,Achievements.addCriteria(criteria, achievement));
    end
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
    --Achievements.Debug("Loading achievement: " .. achievement.name);
    if not achievement.complete then
        for _, criteria in ipairs(achievement.criterias) do
            criteria.parent = achievement;
            Achievements.loadCriteria(criteria);
        end
    end
end


Achievements.loadCriteria = function(criteria)
    --Achievements.Debug("Loading criteria " .. criteria.key);
    if not criteria.complete then
        for _, event in ipairs(criteria.events) do
            Achievements.loadEvent(event,criteria);
        end
        for _, event in ipairs(criteria.singleEvents) do
            Achievements.loadEvent(event,criteria,1);
        end
    end
end


Achievements.loadEvent = function(event, criteria, listenCount)
    --Achievements.Debug("Loading event: " .. event);
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
    },listenCount));
end


Achievements.completeCriteria = function(criteria)
    Achievements.Debug("Completing criteria: " .. criteria.key);
    criteria.complete = true;
    Achievements.saveCriteria(criteria);
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
    if requiredCriterias > 0 and completeCriterias >= requiredCriterias then
        Achievements.completeAchievement(achievement);
    end
end


Achievements.completeAchievement = function(achievement, onLoad)
    if achievement.previous then
        Achievements.completeAchievement(GetPreviousAchievement(achievement.id,nil,onLoad));
    end
    Achievements.saveAchievement(achievement)
    achievement.complete = Achievements.getAchievementCompleteDate(achievement);
    Achievements.Debug("Completing achievement: " .. achievement.name)
    Achievements.OnEvent("ACHIEVEMENT_BOOK_ACHIEVEMENT_COMPLETE",achievement);
end


Achievements.InitializeCore = function()
    ACHIEVEMENT_CATEGORY_GENERAL = Achievements.addCategory("General");
    Achievements.Debug("Initializing core");
    if Achievements.achievements then
        for _, achievement in pairs(Achievements.achievements) do
            Achievements.loadAchievement(achievement);
        end
    end
end
