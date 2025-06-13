import { Component } from '@angular/core';
import { WeatherService } from './services/weather.service';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  city: string = '';
  weather$!: Observable<any>;

  constructor(private weatherService: WeatherService) {}

  getWeather() {
    if (this.city) {
      this.weather$ = this.weatherService.getWeather(this.city);
    }
  }
}