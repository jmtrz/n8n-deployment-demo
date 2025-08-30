import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DeploymentStatus } from '../../../shared/models/deployment.model';

@Component({
  selector: 'app-deployment-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="deployment-card" [class]="'status-' + deployment.status">
      <div class="card-header">
        <div class="repository-info">
          <h3 class="repository-name">{{ deployment.repository }}</h3>
          <span class="workflow-name">{{ deployment.workflow }}</span>
        </div>
        <div class="status-badge" [class]="'badge-' + deployment.status">
          {{ getStatusText() }}
        </div>
      </div>
      
      <div class="card-body">
        <div class="metrics-row">
          <div class="metric">
            <span class="metric-label">Uptime</span>
            <span class="metric-value">{{ deployment.uptime }}%</span>
          </div>
          <div class="metric">
            <span class="metric-label">Last Deployment</span>
            <span class="metric-value">{{ getFormattedDate() }}</span>
          </div>
        </div>
        
        <div class="last-run" *ngIf="deployment.lastRun">
          <div class="run-info">
            <span class="run-number">#{{ deployment.lastRun.run_number }}</span>
            <span class="branch-name">{{ deployment.lastRun.head_branch }}</span>
            <span class="commit-sha">{{ deployment.lastRun.head_sha.substring(0, 7) }}</span>
          </div>
          <div class="run-actor" *ngIf="deployment.lastRun.actor">
            <img [src]="deployment.lastRun.actor.avatar_url" 
                 [alt]="deployment.lastRun.actor.login"
                 class="actor-avatar">
            <span class="actor-name">{{ deployment.lastRun.actor.login }}</span>
          </div>
        </div>
        
        <div class="recent-runs" *ngIf="deployment.recentRuns.length > 0">
          <h4>Recent Runs</h4>
          <div class="runs-list">
            <div class="run-item" 
                 *ngFor="let run of deployment.recentRuns.slice(0, 3)"
                 [class]="'run-' + run.conclusion">
              <span class="run-status">{{ run.conclusion }}</span>
              <span class="run-branch">{{ run.head_branch }}</span>
              <span class="run-time">{{ getRelativeTime(run.updated_at) }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="card-footer">
        <button class="view-details-btn" (click)="viewDetails()" *ngIf="deployment.lastRun">
          View on GitHub
        </button>
      </div>
    </div>
  `,
  styleUrl: './deployment-card.component.css'
})
export class DeploymentCardComponent {
  @Input() deployment!: DeploymentStatus;

  getStatusText(): string {
    switch (this.deployment.status) {
      case 'success': return 'Deployed';
      case 'failure': return 'Failed';
      case 'in_progress': return 'Deploying';
      case 'cancelled': return 'Cancelled';
      default: return 'Pending';
    }
  }

  getFormattedDate(): string {
    if (this.deployment.lastDeployment === 'Never' || this.deployment.lastDeployment === 'Error') {
      return this.deployment.lastDeployment;
    }
    
    const date = new Date(this.deployment.lastDeployment);
    return date.toLocaleString();
  }

  getRelativeTime(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    return `${diffDays}d ago`;
  }

  viewDetails(): void {
    if (this.deployment.lastRun?.html_url) {
      window.open(this.deployment.lastRun.html_url, '_blank');
    }
  }
}