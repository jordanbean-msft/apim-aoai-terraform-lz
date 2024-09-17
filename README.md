# apim-aoai-terraform-lz

![architecture](./.img/architecture.png)

## Disclaimer

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.**

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription & resource group
- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform#windows)
- `Owner` level permissions on the resource group you wish to apply the Terraform to (since it uses RBAC to set up access to Cosmos, OpenAI, Key Vault, etc)
- [REST Client for VS Code](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)

### Azure

A virtual network of at least a `/25` and 2 subnets (each at least `/27` ) to associate with API Management & the private endpoints.

### Entra ID

2 service principals, one to represent OpenAI at the API Management level and one to represent your application.

#### OpenAI Service Principal

- Set the `redirect-uri` in the `Single Page Application` to `https://<name-of-api-management-service>.developer.azure-api.net/signin` (you can do this after setting up API Management). You should also check the box for `Implicit grant and hybrid flows->ID tokens`.
- Expose a scope called `user_impersonation` and specify an `Application ID URI`. This permission should require admin consent.

#### Application Service Principal

- Needs to have the `Application ID URI/user-impersonation` API permission to the OpenAI Service Principal configured above. You will need to get admin consent for this scope before use.
- Redirect_Uri
    - For the `sample-openai.http` file (or a regular web application that wants to authenticate an interactive signed-in user), add a `Web->redirect_uri`.
    - For the `sample-openai.ipynb` file, add a `Mobile and desktop applications->redirect_uri`.

## Deployment

1. Update the `infra/provider.conf.json` file with where you intend to store the Terraform state file.
1. Update the `infra/main.tfvars.json` file with specifics of your environment.
1. **Optional**: Set the `ARM_SUBSCRIPITON_ID` environment variable if using the Azure CLI for authentication.

    ```powershell
    $env:ARM_SUBSCRIPTION_ID="1234-5678-9012-3456"
    ```

1. Run the following command to initialize Terraform

    ```shell
    cd infra
    terraform init -backend-config ./provider.conf.json
    ```

1. Run the following command to plan your Terraform deployment

    ```shell
    terraform plan -var-file="./main.tfvars.json" -out "tfplan"
    ```

1. Run the following command to apply your Terraform deployment

    ```shell
    terraform apply "tfplan"
    ```

## Test

- Use the included `sample-openai.http` file
- Use the Python notebook `sample-openai.ipynb` file

## Links
