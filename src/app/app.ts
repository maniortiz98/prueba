import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
protected title = 'mani';
  protected gcpKey: string;

  constructor() {
    // Acceder a la variable de .env
    this.gcpKey = process.env['GCP_KEY'] || 'NO_KEY_FOUND';
    console.log('GCP Key:', this.gcpKey);
  }
}
