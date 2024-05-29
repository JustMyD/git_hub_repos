from psycopg import connect


class DbWorker:
    def __init__(self):
        self.__connection = connect(dbname='main', user='comediant', password='1234', host='172.17.0.1', port=5432)
        self._cursor = self.__connection.cursor()

    def __del__(self):
        self._cursor.close()
        self.__connection.close()

    def test_db_connection(self):
        sql_template = "select * from tmp_table"

        self._cursor.execute(sql_template)
        result = self._cursor.fetchall()

        return result

    def update_git_queue(self, commit_id, repo_name):
        sql_template = """
            insert into git.queue (nPartYearMonth, LoadDate, ExternalId, RepositoryName, IsProcessed)
            values (NOW()::date, NOW()::timestamp, %s, %s, 0)
        """

        self._cursor.execute(sql_template, (commit_id, repo_name))
        self.__connection.commit()

