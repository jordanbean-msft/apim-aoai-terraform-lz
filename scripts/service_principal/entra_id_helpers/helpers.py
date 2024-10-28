import subprocess
import json
import uuid
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def call_azure_cli(cmd):
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    result_stdout = result.stdout.decode("utf-8")
    result_stderr = result.stderr.decode("utf-8")

    logging.debug(result_stdout)
    logging.debug(f"Error: {result_stderr}")

    return result_stdout

def create_app_registration(display_name, web_direct_uri, public_redirect_uri, required_resource_access):
    logging.info(f'Creating app registration with display name: {display_name}')

    cmd = ["az", "ad", "app", "create", 
        "--display-name", display_name, 
        "--sign-in-audience", "AzureAdMyOrg"
    ]

    if web_direct_uri:
        cmd.extend(["--web-redirect-uris", web_direct_uri])

    if public_redirect_uri:
        cmd.extend(["--public-client-redirect-uris", public_redirect_uri])

    if required_resource_access:
        cmd.extend(["--required-resource-access", json.dumps(required_resource_access)])

    result = call_azure_cli(cmd)

    ad_app_details = json.loads(result)

    logging.info(f'App registration created with appId: {ad_app_details["appId"]}')

    return ad_app_details

def create_user_impersonation_scope(appId, id):
    user_impersonation_scope_id = str(uuid.uuid4())

    user_impersonation_scope = {
        "id": user_impersonation_scope_id,
        "isEnabled": True,
        "type": "Admin",
        "value": "user_impersonation",
        "userConsentDisplayName": "Allow the application to access the user_impersonation scope",
        "userConsentDescription": "Allow the application to access the user_impersonation scope",
        "adminConsentDisplayName": "Allow the application to access the user_impersonation",
        "adminConsentDescription": "Allow the application to access the user_impersonation scope"
    }

    body = {
        "api": {
            "oauth2PermissionScopes": [user_impersonation_scope]
        }
    }

    add_oauth2_permission_cmd = ["az", "rest", "--method", "patch", 
        "--uri", f"https://graph.microsoft.com/v1.0/applications/{id}",
        "--body", json.dumps(body)
    ]

    # NOTE: this will throw an error on subsequent runs if the scope already exists, ignore the error
    call_azure_cli(add_oauth2_permission_cmd)

    logging.info(f'Added user_impersonation scope to app registration')

    return user_impersonation_scope_id

def add_other_app_registration_fields(tags, appId, id):
    body = {
        "tags": tags.split(","),
        "identifierUris": [
            f"api://{appId}"
        ]
    }

    add_other_fields_cmd = ["az", "rest", "--method", "patch", 
        "--uri", f"https://graph.microsoft.com/v1.0/applications/{id}",
        "--body", json.dumps(body)
    ]

    call_azure_cli(add_other_fields_cmd)

    logging.info(f'Added tags to app registration')

def instantiate_service_principal(appId):
    instantiate_sp_cmd = ["az", "ad", "sp", "create", 
        "--id", appId
    ]

    result = call_azure_cli(instantiate_sp_cmd)
    
    ad_sp_details = json.loads(result)

    logging.info(f'Service principal created for appId: {appId}')

    return ad_sp_details

def add_owners(owner_upns, id):
    for owner in owner_upns.split(","):
        # lookup owner object id based upon UPN
        lookup_owner_cmd = ["az", "ad", "user", "show", 
            "--id", owner
        ]

        result = call_azure_cli(lookup_owner_cmd)

        owner_details = json.loads(result)
        owner_id = owner_details['id']

        add_owners_cmd = ["az", "ad", "app", "owner", "add", 
            "--id", id,
            "--owner-object-id", owner_id
        ]

        call_azure_cli(add_owners_cmd)

        logging.info(f'Added owner {owner} to app registration')

def add_password(id):
    body = {
        "passwordCredential": {
            "displayName": "Service Principal Password"
        }
    }

    add_password_cmd = ["az", "rest", "--method", "post",
        "--uri", f"https://graph.microsoft.com/v1.0/applications/{id}/addPassword",
        "--body", json.dumps(body)
    ]

    result = call_azure_cli(add_password_cmd)

    logging.info(f'Added password to app registration')

    return json.loads(result)

__all__ = ['create_app_registration', 'create_user_impersonation_scope', 'add_other_app_registration_fields', 'instantiate_service_principal', 'add_owners', 'add_password']
