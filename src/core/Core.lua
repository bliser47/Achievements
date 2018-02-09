Achievements = {
    categories = {},
    achievements = {}
}

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



ACHIEVEMENT_CATEGORY_GENERAL = Achievements.addCategory("General");