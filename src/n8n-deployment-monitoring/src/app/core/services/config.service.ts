import { Injectable } from '@angular/core';

export interface AppConfig {
  githubToken: string;
  apiUrl: string;
  environment: string;
}

@Injectable({
  providedIn: 'root'
})
export class ConfigService {
  private config: AppConfig;

  constructor() {
    // Try to load from environment variables or fallback to default
    this.config = {
      githubToken: this.getEnvVar('GITHUB_TOKEN') || this.getEnvVar('NG_APP_GITHUB_TOKEN') || '',
      apiUrl: this.getEnvVar('API_URL') || 'https://api.github.com',
      environment: this.getEnvVar('NODE_ENV') || 'development'
    };
  }

  private getEnvVar(key: string): string | undefined {
    // In Angular, we need to access environment variables differently
    // For now, we'll use a simple approach
    if (typeof window !== 'undefined' && (window as any).env) {
      return (window as any).env[key];
    }
    return undefined;
  }

  get githubToken(): string {
    return this.config.githubToken;
  }

  get apiUrl(): string {
    return this.config.apiUrl;
  }

  get environment(): string {
    return this.config.environment;
  }

  // Method to set token dynamically (for testing)
  setGithubToken(token: string): void {
    this.config.githubToken = token;
  }

  // Method to check if config is properly loaded
  isConfigured(): boolean {
    return !!this.config.githubToken;
  }
}