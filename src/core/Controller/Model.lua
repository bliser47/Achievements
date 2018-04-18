Achievements.saveCriteria = function(criteria)
    AchievementsDB.char[UnitName("player")].criterias[criteria.key] = time();
end

Achievements.saveAchievement = function(achievement)
    AchievementsDB.char[UnitName("player")].achievements[achievement.key] = time();
end

Achievements.isAchievementComplete = function(achievement)
    return AchievementsDB.char[UnitName("player")].achievements[achievement.key];
end

Achievements.isCriteriaComplete = function(criteria)
    return AchievementsDB.char[UnitName("player")].criterias[criteria.key];
end

Achievements.getAchievementCompleteDate = function(achievement)
    local dataObject = date("*t",AchievementsDB.char[UnitName("player")].achievements[achievement.key]);
    return {
        tostring(dataObject.day),
        tostring(dataObject.month),
        string.sub(tostring(dataObject.year),3)
    }
end

Achievements.InitializeModel = function()
    local playerName = UnitName("player");
    AchievementsDB = AchievementsDB or {};
    AchievementsDB.char = AchievementsDB.char or {};
    AchievementsDB.char[playerName] = AchievementsDB.char[playerName] or {};
    AchievementsDB.char[playerName].achievements = AchievementsDB.char[playerName].achievements or {};
    AchievementsDB.char[playerName].criterias = AchievementsDB.char[playerName].criterias or {};
end