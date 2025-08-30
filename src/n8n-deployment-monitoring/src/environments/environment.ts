export const environment = {
  production: false,
  githubToken: '', // Empty since repo is public - no token needed
  defaultRepositories: [
    {
      owner: 'jmtrz',
      repo: 'n8n-deployment-demo',
      workflow: '🗒️n8n terraform plan/apply',
      token: ''
    }
  ]
};