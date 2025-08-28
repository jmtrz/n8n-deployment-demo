az ad sp create-for-rbac `
    --name "github-actions-terraform" `
    --role Contributor `
    --scopes /subscriptions/0b1194e2-addf-4aa2-b22c-0d4c58fa1720 `
    --sdk-auth

# {
#   "clientId": "09b763f1-a114-464b-933c-4a41a1c65bd3",
#   "clientSecret": "yyj8Q~2kzjHZV-5tC4Sr1XhZXT3Kmz1pCcHrqauX",
#   "subscriptionId": "0b1194e2-addf-4aa2-b22c-0d4c58fa1720",
#   "tenantId": "8d1ddb6b-3652-46a7-95e7-7154ed7a38d1",
#   "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
#   "resourceManagerEndpointUrl": "https://management.azure.com/",
#   "activeDirectoryGraphResourceId": "https://graph.windows.net/",
#   "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
#   "galleryEndpointUrl": "https://gallery.azure.com/",
#   "managementEndpointUrl": "https://management.core.windows.net/"
# }