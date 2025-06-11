import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Cart } from './cart/cart'; 
import {Customer} from './customer/customer';
import {Products} from './products/products';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Cart, Customer, Products],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected title = 'angular-task-day1';
}
