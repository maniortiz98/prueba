import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { env } from './env.config';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected title = 'mani';

  constructor() {
    console.log('API URL:', env.API_URL);
    console.log('GCP Key:', env.GCP_KEY);
  }
}
