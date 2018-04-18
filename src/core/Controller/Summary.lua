function GetTotalAchievementPoints()
    return 0;
end

function GetLatestCompletedAchievements()
    local achievementList = {}
    for id,achievement in pairs(Achievements.achievements) do
        if achievement.complete then
            table.insert(achievementList,id)
        end
    end
    return achievementList
end


function GetNumCompletedAchievements()
    local total, completed = 0, 0;
    for _,achievement in pairs(Achievements.achievements) do
        if achievement.complete then
            completed = completed + 1
        end
        total = total + 1
    end
    return total,completed
end