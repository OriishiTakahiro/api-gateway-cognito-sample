FROM public.ecr.aws/lambda/python:3.9
ENV AWS_DEFAULT_REGION ap-northeast-1

COPY ./main.py ./
COPY ./requirements.txt ./

RUN pip install -r requirements.txt 

CMD ["main.lambda_handler"]

