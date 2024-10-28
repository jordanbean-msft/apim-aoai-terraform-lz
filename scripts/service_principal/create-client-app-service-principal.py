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

    ad_app_details = create_app_registration(display_name=display_name)

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

if __name__ == '__main__':
    main()