import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject, interval, takeUntil, switchMap, startWith, of, Observable } from 'rxjs';
import { GitHubActionsService } from '../services/github-actions.service';
import { DeploymentStatus } from '../../../shared/models/deployment.model';
import { DeploymentCardComponent } from './deployment-card.component';
import { environment } from '../../../../environments/environment';

interface RepositoryConfig {
  owner: string;
  repo: string;
  workflow: string;
  token?: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, DeploymentCardComponent],
  template: `
    <div class="dashboard-container">
      <header class="dashboard-header">
        <h1>Deployment Status Dashboard</h1>
        <div class="header-actions">
          <button class="refresh-btn" (click)="refreshData()" [disabled]="isLoading">
            <span class="refresh-icon" [class.spinning]="isLoading">⟳</span>
            Refresh
          </button>
          <button class="config-btn" (click)="showConfig = !showConfig">
            ⚙️ Configure
          </button>
        </div>
      </header>

      <div class="config-panel" *ngIf="showConfig">
        <div class="config-form">
          <h3>Add Repository</h3>
          <div class="form-row">
            <input [(ngModel)]="newRepo.owner" placeholder="Owner (e.g., microsoft)" class="form-input">
            <input [(ngModel)]="newRepo.repo" placeholder="Repository (e.g., vscode)" class="form-input">
          </div>
          <div class="form-row">
            <input [(ngModel)]="newRepo.workflow" placeholder="Workflow name (e.g., deploy)" class="form-input">
            <input [(ngModel)]="newRepo.token" placeholder="GitHub Token (optional)" type="password" class="form-input">
          </div>
          <div class="form-actions">
            <button (click)="addRepository()" class="add-btn" [disabled]="!isValidNewRepo()">
              Add Repository
            </button>
          </div>
        </div>
      </div>

      <div class="dashboard-stats" *ngIf="deployments.length > 0">
        <div class="stat-card">
          <span class="stat-value">{{ getSuccessfulDeployments() }}</span>
          <span class="stat-label">Successful</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ getFailedDeployments() }}</span>
          <span class="stat-label">Failed</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ getInProgressDeployments() }}</span>
          <span class="stat-label">In Progress</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ getAverageUptime() }}%</span>
          <span class="stat-label">Avg Uptime</span>
        </div>
      </div>

      <div class="deployments-grid" *ngIf="!isLoading || deployments.length > 0">
        <app-deployment-card 
          *ngFor="let deployment of deployments" 
          [deployment]="deployment">
        </app-deployment-card>
      </div>

      <div class="loading-state" *ngIf="isLoading && deployments.length === 0">
        <div class="loading-spinner"></div>
        <p>Loading deployment status...</p>
      </div>

      <div class="empty-state" *ngIf="!isLoading && deployments.length === 0">
        <div class="empty-icon">📊</div>
        <h2>No repositories configured</h2>
        <p>Add your first repository to start monitoring deployments</p>
        <button class="add-first-btn" (click)="showConfig = true">
          Add Repository
        </button>
      </div>

      <div class="error-state" *ngIf="error">
        <div class="error-icon">⚠️</div>
        <p>{{ error }}</p>
        <button (click)="refreshData()" class="retry-btn">Retry</button>
      </div>
    </div>
  `,
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit, OnDestroy {
  deployments: DeploymentStatus[] = [];
  isLoading = false;
  error: string | null = null;
  showConfig = false;
  
  newRepo: RepositoryConfig = {
    owner: '',
    repo: '',
    workflow: '',
    token: ''
  };

  private repositories: RepositoryConfig[] = environment.defaultRepositories.map(repo => ({
    ...repo,
    token: repo.token || environment.githubToken
  }));

  private destroy$ = new Subject<void>();
  private refreshInterval = 30000; // 30 seconds

  constructor(private githubService: GitHubActionsService) {}

  ngOnInit(): void {
    this.loadDeployments();
    this.startAutoRefresh();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private startAutoRefresh(): void {
    interval(this.refreshInterval)
      .pipe(
        takeUntil(this.destroy$),
        startWith(0),
        switchMap(() => {
          if (!this.isLoading) {
            this.loadDeployments();
          }
          return of(null);
        })
      )
      .subscribe();
  }

  loadDeployments(): void {
    this.isLoading = true;
    this.error = null;
    const deploymentObservables: Observable<DeploymentStatus>[] = [];

    this.repositories.forEach(repo => {
      const observable = this.githubService.getDeploymentStatus(
        repo.owner, 
        repo.repo, 
        repo.workflow, 
        repo.token
      );
      
      deploymentObservables.push(observable);
    });

    if (deploymentObservables.length === 0) {
      this.isLoading = false;
      return;
    }

    // Convert observables to promises for Promise.all
    const deploymentPromises = deploymentObservables.map(obs => 
      obs.toPromise().then(result => result!)
    );

    Promise.all(deploymentPromises)
      .then(results => {
        this.deployments = results.filter(Boolean) as DeploymentStatus[];
        this.isLoading = false;
      })
      .catch(error => {
        console.error('Error loading deployments:', error);
        this.error = 'Failed to load deployment data. Please check your configuration.';
        this.isLoading = false;
      });
  }

  refreshData(): void {
    this.loadDeployments();
  }

  addRepository(): void {
    if (this.isValidNewRepo()) {
      this.repositories.push({...this.newRepo});
      this.newRepo = { owner: '', repo: '', workflow: '', token: '' };
      this.showConfig = false;
      this.loadDeployments();
    }
  }

  isValidNewRepo(): boolean {
    return !!(this.newRepo.owner && this.newRepo.repo && this.newRepo.workflow);
  }

  getSuccessfulDeployments(): number {
    return this.deployments.filter(d => d.status === 'success').length;
  }

  getFailedDeployments(): number {
    return this.deployments.filter(d => d.status === 'failure').length;
  }

  getInProgressDeployments(): number {
    return this.deployments.filter(d => d.status === 'in_progress').length;
  }

  getAverageUptime(): number {
    if (this.deployments.length === 0) return 0;
    const total = this.deployments.reduce((sum, d) => sum + d.uptime, 0);
    return Math.round(total / this.deployments.length);
  }
}