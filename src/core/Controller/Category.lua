function GetCategoryList()
    local categoryList = {};
    for categoryId,_ in pairs(Achievements.categories) do
       table.insert(categoryList,categoryId);
    end
    return categoryList;
end


function GetCategoryInfo(id)
    if Achievements.categories[id] then
        return Achievements.categories[id].name, Achievements.categories[id].parent, 0;
    end
end


function GetCategoryNumAchievements(id)
    local num, total = 0, 0;
    if Achievements.categories[id] then
        for _,achievementId in pairs(Achievements.categories[id].achievementIds) do
            if Achievements.achievements[achievementId].complete then
                num = num + 1
            end
            total = total + 1
        end
    end
    return total, num;
end