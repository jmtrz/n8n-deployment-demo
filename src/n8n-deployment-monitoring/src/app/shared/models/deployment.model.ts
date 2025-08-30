export interface GitHubWorkflowRun {
  id: number;
  name: string;
  head_branch: string;
  head_sha: string;
  status: 'queued' | 'in_progress' | 'completed';
  conclusion: 'success' | 'failure' | 'neutral' | 'cancelled' | 'skipped' | 'timed_out' | 'action_required' | null;
  created_at: string;
  updated_at: string;
  html_url: string;
  jobs_url: string;
  logs_url: string;
  run_number: number;
  event: string;
  actor: {
    login: string;
    avatar_url: string;
  };
  workflow_id: number;
}

export interface GitHubWorkflowRunsResponse {
  total_count: number;
  workflow_runs: GitHubWorkflowRun[];
}

export interface DeploymentStatus {
  repository: string;
  workflow: string;
  status: 'success' | 'failure' | 'in_progress' | 'pending' | 'cancelled';
  lastRun: GitHubWorkflowRun | null;
  recentRuns: GitHubWorkflowRun[];
  uptime: number;
  lastDeployment: string;
}