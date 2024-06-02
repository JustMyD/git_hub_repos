from os import environ

from redis import Redis

ENV_VARS = ('POSTGRESQL_PORT', 'POSTGRESQL_DBNAME', 'POSTGRESQL_USERNAME', 'POSTGRESQL_USERPASSWORD')


def set_env_variables():
    redis_client = Redis(host='0.0.0.0', port=6379)

    for var in ENV_VARS:
        environ[var] = redis_client.get(var).decode('utf8')

