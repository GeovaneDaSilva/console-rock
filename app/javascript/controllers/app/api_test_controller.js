import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'accessToken',
    'accountId',
    'apiKey',
    'apiToken',
    'appId',
    'appSecret',
    'baseUrl',
    'clientId',
    'companyId',
    'companyName',
    'gsmKey',
    'outputDisplay',
    'password',
    'privateApiKey',
    'publicApiKey',
    'refreshToken',
    'secret',
    'subdomain',
    'tenantId',
    'type',
    'username',
    'credentialId'
  ]

  call(event) {
    if(this.customValid(event))
      this.runTest(event);

    event.preventDefault();
  }

  runTest(event) {
    const type = this.typeTarget.innerText
    const accountId = event.target.dataset.account
    const search_params = this.get_search_params(type)
    $.ajax({
      type: "post",
      url: `/accounts/${accountId}/credentials/test`,
      data: new URLSearchParams(search_params).toString(),
      success: (data) => {
        this.update(data);
      }
    })
  }

  customValid(event) {
    const type = this.typeTarget.innerText;
    switch(type) {
      case "syncro":
        return this.syncroValid(event);
      break;
    }
    return true;
  }

  syncroValid(event) {
    if(!this.subdomainTarget.checkValidity()) {
      $("input[type=submit]", this.subdomainTarget.closest("form")).click();
      return false;
    }
    return true;
  }

  update(data) {
    if(data.error) {
      let message = data.message ? data.message : "credential authentication failed.";
      this.outputDisplayTarget.classList.remove("bg-success");
      this.outputDisplayTarget.classList.add("bg-warning");
      this.outputDisplayTarget.innerText = "Error " + data.code + ": " + message;
    } else {
      this.outputDisplayTarget.classList.remove("bg-warning");
      this.outputDisplayTarget.classList.add("bg-success");
      this.outputDisplayTarget.innerText = "Success " + data.code + ": valid credential detected.";
    }
  }

  get_search_params(type){
    // bitdefender, deep_instinct, and haveibeenpwnd are all access_token based
    switch(type){
      case "bitdefender":
        return {
	  app:           type,
	  access_token:  this.accessTokenTarget.value,
	  credential_id: this.credentialIdTarget.value
	}
        break;
      case "deep_instinct":
        return {
	  app:           type,
	  access_token:  this.accessTokenTarget.value,
	  credential_id: this.credentialIdTarget.value
	}
        break;
      case "hibp":
        return {
	  app: type,
	  access_token:  this.accessTokenTarget.value,
	  credential_id: this.credentialIdTarget.value
	}
        break;
      case "connectwise":
        return {
          app: type,
          company_id:      this.companyIdTarget.value,
          public_api_key:  this.publicApiKeyTarget.value,
          private_api_key: this.privateApiKeyTarget.value,
          base_url:        this.baseUrlTarget.value,
          credential_id:   this.credentialIdTarget.value
        }
        break
      case "cylance":
        return {
          app:           type,
          tenant_id:     this.tenantIdTarget.value,
          app_id:        this.appIdTarget.value,
          app_secret:    this.appSecretTarget.value,
          credential_id: this.credentialIdTarget.value,
          base_url:      this.baseUrlTarget.value
        };
        break;
      case "passly":
        return {
          app:           type,
          tenant_id:     this.tenantIdTarget.value,
          app_id:        this.appIdTarget.value,
          app_secret:    this.appSecretTarget.value,
	  credential_id: this.credentialIdTarget.value
        };
        break;
      case "datto":
        return {
          app: type,
          username:      this.usernameTarget.value,
          secret_key:    this.secretTarget.value,
          credential_id: this.credentialIdTarget.value
        }
        break
      case "dns_filter":
        return {
          app: type,
          dns_filter_username: this.usernameTarget.value,
          dns_filter_password: this.passwordTarget.value,
	  credential_id:       this.credentialIdTarget.value
        };
        break;
      case "ironscales":
        return {
	  app: type,
	  refresh_token: this.refreshTokenTarget.value,
	  credential_id: this.credentialIdTarget.value
	}
        break;
      case "kaseya":
        return {
          app: type,
          username:      this.usernameTarget.value,
          password:      this.passwordTarget.value,
          company_name:  this.companyNameTarget.value,
          base_url:      this.baseUrlTarget.value,
          credential_id: this.credentialIdTarget.value
        }
        break
      case "sentinelone":
        return {
	  app: type,
	  api_token:     this.apiTokenTarget.value,
	  credential_id: this.credentialIdTarget.value
	}
        break;
      case "sophos":
        return {
          app: type,
          sophos_client_id:     this.clientIdTarget.value,
          sophos_client_secret: this.secretTarget.value,
	  credential_id:        this.credentialIdTarget.value
        }
	break;
      case "duo":
        return {
	  app: type,
	  duo_host:            this.tenantIdTarget.value,
          duo_integration_key: this.appIdTarget.value,
          duo_secret:          this.appSecretTarget.value,
	  credential_id:       this.credentialIdTarget.value,
	  account_id:          this.accountIdTarget.value
	};
        break;
      case "syncro":
        return {
          app: type,
          subdomain:     this.subdomainTarget.value,
          api_key:       this.apiKeyTarget.value,
          credential_id: this.credentialIdTarget.value
        }
        break
      case "webroot":
        return {
          app: type,
          webroot_username:      this.usernameTarget.value,
          webroot_password:      this.passwordTarget.value,
          webroot_client_id:     this.clientIdTarget.value,
          webroot_client_secret: this.secretTarget.value,
          webroot_gsm_key:       this.gsmKeyTarget.value,
	  credential_id:         this.credentialIdTarget.value
        }
        break;
    }
  }
}
