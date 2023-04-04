from nanoid import generate
import jwt
import json
import os


def lambda_handler(event, context):

    issuer = os.environ["JWKS_HOST"]
    client_id = os.environ["CLIENT_ID"]
    jwks_url = f"{issuer}/.well-known/jwks.json"

    try:

        token = event["headers"]["Authorization"]
        jwks_client = jwt.PyJWKClient(jwks_url)

        signing_key = jwks_client.get_signing_key_from_jwt(token)

        decoded_payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=client_id,
            issuer=issuer,
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "GeneratedId": generate(),
                    # https://aws-lambda-for-python-developers.readthedocs.io/en/latest/02_event_and_context/
                    "AuthenticationInfo": decoded_payload,
                }
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "message": str(e),
        }
