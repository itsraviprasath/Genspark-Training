import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { WeatherCardComponent } from './components/weather-card/weather-card.component';

@NgModule({
  declarations: [AppComponent, WeatherCardComponent],
  imports: [BrowserModule, HttpClientModule, FormsModule],
  bootstrap: [AppComponent]
})
export class AppModule {}