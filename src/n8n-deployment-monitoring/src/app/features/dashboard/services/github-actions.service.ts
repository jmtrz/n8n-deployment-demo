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
    
    return this.http.get<GitHubWorkflowRunsResponse>(url, {
      headers: this.getHeaders(token),
      params: {
        per_page: '10',
        status: 'completed'
      }
    }).pipe(
      catchError(error => {
        console.error('Error fetching workflow runs:', error);
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
        const workflowRuns = response.workflow_runs.filter(run => {
          const runName = run.name.toLowerCase();
          const searchName = workflowName.toLowerCase();
          
          // Exact match first
          if (runName === searchName) return true;
          
          // Contains match
          if (runName.includes(searchName) || searchName.includes(runName)) return true;
          
          // Remove emojis and special chars for comparison
          const cleanRunName = runName.replace(/[^\w\s]/gi, '').trim();
          const cleanSearchName = searchName.replace(/[^\w\s]/gi, '').trim();
          
          return cleanRunName.includes(cleanSearchName) || cleanSearchName.includes(cleanRunName);
        });

        const lastRun = workflowRuns[0] || null;
        const successfulRuns = workflowRuns.filter(run => run.conclusion === 'success');
        const uptime = workflowRuns.length > 0 ? (successfulRuns.length / workflowRuns.length) * 100 : 0;

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
          recentRuns: workflowRuns.slice(0, 5),
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