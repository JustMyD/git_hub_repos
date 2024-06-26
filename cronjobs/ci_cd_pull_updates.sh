#!/bin/bash
# 1 шаг CI/CD
# Забирает из очереди проекты, которые были обновлены в GitHub

IFS=$'\n' read -r -d '' -a queryResults <<< "$(psql -d main -U comediant -c '
select part.InternalId, part.RepositoryName, config.PortForward, config.ProjectPath
from (
        select InternalId, RepositoryName, IsProcessed, row_number() over (partition by RepositoryName order by InternalId desc) as rn
        from git.queue
        where nPartYearMonth = now()::date
) part
join git.projects config on part.RepositoryName = config.ProjectName
where part.rn = 1 and part.IsProcessed = 0 and config.Status = 1
')"

for (( i=2; i<"${#queryResults[@]} - 1"; i++ )) do
    internalId="$(echo "${queryResults[i]}" | cut -d "|" -f1 | tr -d ' ')"
    projectName="$(echo "${queryResults[i]}" | cut -d "|" -f2 | tr -d ' ')"
    projectPath="$(echo "${queryResults[i]}" | cut -d "|" -f4 | tr -d ' ')"
    
    cd $projectPath &&
    git checkout master &&
    git pull &&
    psql -d main -U comediant -c "update git.queue set IsProcessed = 1 where RepositoryName = '$projectName' and InternalId = '$internalId'"
done
