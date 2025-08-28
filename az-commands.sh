
# This will output the values you need for your GitHub secrets
# Run this script only once - then add the output values to your GitHub repository secrets. The GitHub Actions workflows will handle authentication automatically after that.
az ad sp create-for-rbac \
    --name "github-actions-terraform" \
    --role Contributor \
    --scopes /subscriptions/0b1194e2-addf-4aa2-b22c-0d4c58fa1720 \
    --sdk-auth