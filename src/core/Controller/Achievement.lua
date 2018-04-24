function GetAchievementInfo(id, arg)
    if arg and Achievements.categories[id] then
        return GetAchievementInfo(Achievements.categories[id].achievementIds[arg]);
    elseif Achievements.achievements[id] then
        return id,
        Achievements.achievements[id].name,
        Achievements.achievements[id].points,
        Achievements.achievements[id].complete and true or nil,
        Achievements.achievements[id].complete and Achievements.achievements[id].complete[2] or nil,
        Achievements.achievements[id].complete and Achievements.achievements[id].complete[1] or nil,
        Achievements.achievements[id].complete and Achievements.achievements[id].complete[3] or nil,
        Achievements.achievements[id].description,
        Achievements.achievements[id].flags or 0,
        Achievements.achievements[id].texture,
        Achievements.achievements[id].reward or "",
        Achievements.achievements[id].key,
        Achievements.achievements[id].completeTime;
    end
end


function GetNextAchievement(id)
    if Achievements.achievements[id] then
        if Achievements.achievements[id].next then
            local _, _, _, comp = GetAchievementInfo(Achievements.achievements[id].next);
            return Achievements.achievements[id].next, comp;
        end
    end
end


function GetPreviousAchievement(id)
    if Achievements.achievements[id] then
        return Achievements.achievements[id].previous
    end
end


function GetAchievementCategory(id)
    if Achievements.achievements[id] then
        return Achievements.achievements[id].category;
    end
end


function GetAchievementNumCriteria(id)
    if Achievements.achievements[id] then
        return table.getn(Achievements.achievements[id].visibleCriteria);
    end
end