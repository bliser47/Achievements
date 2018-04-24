function GetAchievementCriteriaInfo(id, arg)

    if arg then
        if Achievements.achievements[id] then
            id = Achievements.achievements[id].criterias[arg];
        end
    end

    local criteria = Achievements.criterias[id];
    if criteria then

        local criteriaValue;
        if criteria.value then
            if criteria.complete or criteria.parent.complete then
                criteriaValue = criteria.required
            else
                criteriaValue = criteria.value(criteria);
            end
        end

        return criteria.name or "",
        criteria.achievement and 8 or 0,
        criteria.complete,
        criteriaValue,
        criteria.required,
        criteria.complete,
        criteria.progress,
        criteria.achievement,
        criteria.format,
        criteria;
    end
end