import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

// Extend the Window interface to include 'env'
declare global {
  interface Window {
    env?: {
      apiUrl?: string;
      GCP_KEY?: string;
      [key: string]: any;
    };
  }
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrls: ['./app.scss']
})
export class App {
  protected title = 'mani';

  // Leer env en runtime desde window
  apiUrl = window['env']?.apiUrl || '';
  gcpKey = window['env']?.GCP_KEY || '';

  constructor() {
    console.log('API URL:', this.apiUrl);
    console.log('GCP Key:', this.gcpKey);
  }
}
