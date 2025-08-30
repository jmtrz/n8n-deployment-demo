import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, map, catchError, of } from 'rxjs';
import { GitHubWorkflowRunsResponse, DeploymentStatus } from '../../../shared/models/deployment.model';
import { environment } from '../../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class GitHubActionsService {
  private readonly baseUrl = 'https://api.github.com';
  
  constructor(private http: HttpClient) {}

  private getHeaders(token?: string): HttpHeaders {
    const headers: any = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'N8N-Deployment-Monitor'
    };
    
    const authToken = token || environment.githubToken;
    if (authToken) {
      headers['Authorization'] = `Bearer ${authToken}`;
    }
    
    return new HttpHeaders(headers);
  }

  getWorkflowRuns(owner: string, repo: string, workflowId?: string, token?: string): Observable<GitHubWorkflowRunsResponse> {
    const url = workflowId 
      ? `${this.baseUrl}/repos/${owner}/${repo}/actions/workflows/${workflowId}/runs`
      : `${this.baseUrl}/repos/${owner}/${repo}/actions/runs`;
    
    const authToken = token || environment.githubToken;
    console.log('Making GitHub API request to:', url);
    console.log('Using token:', authToken ? 'Yes (length: ' + authToken.length + ')' : 'No');
    
    return this.http.get<GitHubWorkflowRunsResponse>(url, {
      headers: this.getHeaders(token),
      params: {
        per_page: '20'
        // Remove status filter to get all runs (completed, in_progress, queued)
      }
    }).pipe(
      catchError(error => {
        console.error('Error fetching workflow runs:', error);
        if (error.status === 401) {
          console.error('GitHub API Authentication failed. Please check your token.');
          console.error('Token being used:', authToken ? 'Token provided (length: ' + authToken.length + ')' : 'No token provided');
        }
        return of({
          total_count: 0,
          workflow_runs: []
        });
      })
    );
  }

  getDeploymentStatus(owner: string, repo: string, workflowName: string, token?: string): Observable<DeploymentStatus> {
    return this.getWorkflowRuns(owner, repo, undefined, token).pipe(
      map(response => {
        console.log('Total workflow runs found:', response.total_count);
        console.log('Available workflows:', response.workflow_runs.map(r => r.name));
        console.log('Looking for workflow:', workflowName);
        
        const workflowRuns = response.workflow_runs.filter(run => {
          const runName = run.name.toLowerCase();
          const searchName = workflowName.toLowerCase();
          
          // Exact match first
          if (runName === searchName) {
            console.log('Exact match found:', run.name);
            return true;
          }
          
          // Contains match
          if (runName.includes(searchName) || searchName.includes(runName)) {
            console.log('Contains match found:', run.name);
            return true;
          }
          
          // Remove emojis and special chars for comparison
          const cleanRunName = runName.replace(/[^\w\s]/gi, '').trim();
          const cleanSearchName = searchName.replace(/[^\w\s]/gi, '').trim();
          
          if (cleanRunName.includes(cleanSearchName) || cleanSearchName.includes(cleanRunName)) {
            console.log('Clean match found:', run.name, '→', cleanRunName);
            return true;
          }
          
          return false;
        });
        
        console.log('Filtered workflow runs:', workflowRuns.length);
        
        // If no matches found, show all workflows for debugging
        const finalWorkflowRuns = workflowRuns.length > 0 ? workflowRuns : response.workflow_runs;
        if (workflowRuns.length === 0) {
          console.log('No workflow matches found, showing all workflows');
        }

        const lastRun = finalWorkflowRuns[0] || null;
        const successfulRuns = finalWorkflowRuns.filter(run => run.conclusion === 'success');
        const uptime = finalWorkflowRuns.length > 0 ? (successfulRuns.length / finalWorkflowRuns.length) * 100 : 0;

        let status: 'success' | 'failure' | 'in_progress' | 'pending' | 'cancelled' = 'pending';
        
        if (lastRun) {
          if (lastRun.status === 'in_progress') {
            status = 'in_progress';
          } else if (lastRun.conclusion === 'success') {
            status = 'success';
          } else if (lastRun.conclusion === 'failure') {
            status = 'failure';
          } else if (lastRun.conclusion === 'cancelled') {
            status = 'cancelled';
          }
        }

        return {
          repository: `${owner}/${repo}`,
          workflow: workflowName,
          status,
          lastRun,
          recentRuns: finalWorkflowRuns.slice(0, 5),
          uptime: Math.round(uptime),
          lastDeployment: lastRun ? lastRun.updated_at : 'Never'
        };
      }),
      catchError(error => {
        console.error('Error getting deployment status:', error);
        return of({
          repository: `${owner}/${repo}`,
          workflow: workflowName,
          status: 'failure' as const,
          lastRun: null,
          recentRuns: [],
          uptime: 0,
          lastDeployment: 'Error'
        });
      })
    );
  }
}