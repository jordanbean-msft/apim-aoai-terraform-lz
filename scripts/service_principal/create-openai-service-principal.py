import logging
from entra_id_helpers.helpers import create_app_registration, create_user_impersonation_scope, add_other_app_registration_fields, instantiate_service_principal, add_owners

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def main():
    display_name = input('Display Name: ')
    tags = input('Tags (comma-separated): ')
    owner_upns = input('Owner User Principal Names (comma-separated): ')

    ad_app_details = create_app_registration(display_name=display_name)

    add_other_app_registration_fields(tags=tags, appId=ad_app_details['appId'], id=ad_app_details['id'])
    
    scope_id = create_user_impersonation_scope(appId=ad_app_details['appId'], id=ad_app_details['id'])

    add_owners(owner_upns=owner_upns, id=ad_app_details['id'])

    sp = instantiate_service_principal(appId=ad_app_details['appId'])

    add_owners(owner_upns=owner_upns, id=sp['id'])

    logging.info('')
    logging.info(f'OpenAI Client ID: {ad_app_details["appId"]}')
    logging.info(f'OpenAI Scope: api://{ad_app_details['appId']}/user_impersonation')
    logging.info(f'OpenAI Scope ID: {scope_id}')

if __name__ == '__main__':
    main()