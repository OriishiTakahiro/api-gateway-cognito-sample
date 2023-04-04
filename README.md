```
$ cd backend
$ pip install -r requirements.txt
$ python-lambda-local -f lambda_handler main.py event.json

$ ava -- aws cognito-idp admin-set-user-password \
  --user-pool-id "ap-northeast-1_MUMuMbr3i" \
  --username "demo-user" \
  --password 'G8J*6zNbCvsZ' \
  --permanent


docker run --env-file ./env -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY  -p 9000:8080 lambda:latest

curl -sS -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d @event.json | jq
```
