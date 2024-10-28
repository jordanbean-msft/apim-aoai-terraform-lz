import logging
from entra_id_helpers.helpers import create_app_registration, create_user_impersonation_scope, add_other_app_registration_fields, instantiate_service_principal, add_owners, add_password

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def main():
    display_name = input('Display Name: ')
    tags = input('Tags (comma-separated): ')
    owner_upns = input('Owner User Principal Names (comma-separated): ')
    openai_client_id = input('OpenAI Client ID: ')
    openai_scope_id = input('OpenAI Scope ID: ')
    web_redirect_uri = input('Web Redirect URI (leave blank for none): ')
    public_redirect_uri = input('Desktop Redirect URI (leave blank for none): ')

    ad_app_details = create_app_registration(display_name=display_name, 
        web_direct_uri=web_redirect_uri, 
        public_redirect_uri=public_redirect_uri,
        required_resource_access=[
            {
                "resourceAppId": openai_client_id, 
                "resourceAccess": [
                    {
                        "id": openai_scope_id, 
                        "type": "Scope"
                    }
                ]
            }
        ]
    )

    add_other_app_registration_fields(tags=tags, appId=ad_app_details['appId'], id=ad_app_details['id'])
    
    scope_id = create_user_impersonation_scope(appId=ad_app_details['appId'], id=ad_app_details['id'])

    add_owners(owner_upns=owner_upns, id=ad_app_details['id'])

    password = add_password(id=ad_app_details['id'])

    sp = instantiate_service_principal(appId=ad_app_details['appId'])

    add_owners(owner_upns=owner_upns, id=sp['id'])

    logging.info('')
    logging.info(f'Client App Client ID: {ad_app_details["appId"]}')
    logging.info(f'Client App Client Secret: {password["secretText"]}')
    logging.info(f'Client App Scope: api://{ad_app_details['appId']}/user_impersonation')
    logging.info(f'Client App Web Redirect URI: {web_redirect_uri}')
    logging.info(f'Client App Desktop Redirect URI: {public_redirect_uri}')

if __name__ == '__main__':
    main()