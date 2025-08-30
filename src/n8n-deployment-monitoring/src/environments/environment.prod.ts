export const environment = {
  production: true,
  githubToken: '', // Use Azure App Settings or Key Vault in production
  defaultRepositories: [
    {
      owner: 'your-username',
      repo: 'your-repository', 
      workflow: 'deploy',
      token: ''
    }
  ]
};