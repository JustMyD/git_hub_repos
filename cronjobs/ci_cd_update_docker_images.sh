#!/bin/bash
# 2 шаг CI/CD
# Отвечает за сборку образов для обновленных проектов, запуск обновленных образов и удаление старых образов

IFS=$'\n' read -r -d '' -a queryResults <<< "$(psql -d main -U comediant -c '
select part.InternalId, part.RepositoryName, config.PortForward, config.ProjectPath
from (
        select InternalId, RepositoryName, IsProcessed, row_number() over (partition by RepositoryName order by InternalId desc) as rn
        from git.queue
        where nPartYearMonth = now()::date
) part
join git.projects config on part.RepositoryName = config.ProjectName
where part.rn = 1 and part.IsProcessed = 0
')"

for (( i=2; i<"${#queryResults[@]} - 1"; i++ )) do
    internalId="$(echo "${queryResults[i]}" | cut -d "|" -f1 | tr -d ' ')"
    projectName="$(echo "${queryResults[i]}" | cut -d "|" -f2 | tr -d ' ')"
    portForward="$(echo "${queryResults[i]}" | cut -d "|" -f3)"
    projectPath="$(echo "${queryResults[i]}" | cut -d "|" -f4 | tr -d ' ')"
    echo "$internalId" "$projectName" "$portForward"
    
    docker build --network=host -t "$projectName" "$projectPath" &&
    docker rm $projectName &&
    docker run -d $portForward --name $projectName $projectName &&
    psql -d main -U comediant -c "update git.queue set IsProcessed = 2 where RepositoryName = '$projectName' and InternalId = '$internalId'"
done
