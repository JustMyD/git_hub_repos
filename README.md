# GitHub CI/CD project

CI/CD для проектов GitHub.

Цикл работы:
- Ловит исходящие от GitHub события обновлений по проектам
- Пулит обновления на сервер
- Обновляет образы докера
- Запускает обновленные образы

Nginx перенаправляет запросы с эндпоинта '/git_hub' на 8001 порт. \
Микросервис (FastAPI) слушает события на 8001 порту. \
Для процесса обработки заявок организована очередь в виде таблицы на Postgresql. \
Микросервис сохраняет в таблицу `git.queue` заявку об обновлении проекта со статусом 0. \
Задание `ci_cd_pull_updates.sh` подхватывает заявки со статусом 0, пулит обновления из GitHub и обновляет статус заявки в 1. \
Задание `ci_cd_update_docker_images.sh` подхватывает заявки со статусом 1, обновляет образы обновленных проектов, запускает обновленные образы и обновляет статус заявки в 2.

## Связанные объекты
main.git.queue - Таблица. Очередь для заявок на обновление проектов GitHub. \
main.git.projects - Таблица. Настройки для проектов GitHub. \
ci_cd_pull_updates.sh - cronjob. Раз в несколько минут пулит обновления из GitHub. \
ci_cd_update_docker_images.sh - cronjob. Раз в несколько минут пересобирает-запускает образы докера по обновленным проектам.

