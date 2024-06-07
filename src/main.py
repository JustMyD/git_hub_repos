from fastapi import FastAPI
from fastapi.requests import Request
from fastapi.responses import JSONResponse

from db_dto import DbWorker
from utils import set_env_variables

set_env_variables()

app = FastAPI()


@app.post('/git_hub')
async def process_repo_updates(req: Request):
    db_worker = DbWorker()

    data = await req.json()
    repo_name = data['repository']['name']
    external_id = data['head_commit']['id']

    db_worker.update_git_queue(commit_id=external_id, repo_name=repo_name)

    return JSONResponse({'result': 'Success'}, 200)
