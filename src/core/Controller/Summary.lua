function GetTotalAchievementPoints()
    return 0;
end

function GetLatestCompletedAchievements()
    local latestCompletedAchievementIds = {}

    --table.sort(latestCompletedAchievementIds,TA.SortAchievements);
    return latestCompletedAchievementIds;
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