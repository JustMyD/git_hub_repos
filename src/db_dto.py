import os

from psycopg import connect


class DbWorker:
    def __init__(self):
        self.__connection = connect(
            dbname=os.getenv('POSTGRESQL_DBNAME'),
            user=os.getenv('POSTGRESQL_USERNAME'),
            password=os.getenv('POSTGRESQL_USERPASSWORD'),
            host=os.getenv('DOCKER_HOST'),
            port=os.getenv('POSTGRESQL_PORT')
        )
        self._cursor = self.__connection.cursor()

    def __del__(self):
        self._cursor.close()
        self.__connection.close()

    def update_git_queue(self, commit_id, repo_name):
        sql_template = """
            insert into git.queue (nPartYearMonth, LoadDate, ExternalId, RepositoryName, IsProcessed)
            values (NOW()::date, NOW()::timestamp, %s, %s, 0)
        """

        self._cursor.execute(sql_template, (commit_id, repo_name))
        self.__connection.commit()

