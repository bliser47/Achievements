function GetCategoryList()
    return {0};
end


function GetCategoryInfo(id)
    if id == 92 then
        return "General",-1,0;
    end
    return "Unused",-1,0;
end


function GetAchievementInfo(id)
    return id, "Sneaky", 10, false, nil, nil, nil, "Pick pickot a mob", nill, "Interface\\Icons\\ability_stealth"
end

function GetTotalAchievementPoints()
    return 0;
end

function GetLatestCompletedAchievements()
    return {};
end

function GetCategoryNumAchievements(category)
    return 1,0;
end

function GetNumCompletedAchievements()
    return 1,0;
end