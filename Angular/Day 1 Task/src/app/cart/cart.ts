import { Component } from '@angular/core';
import { Cart as CartService } from '../cart'; // Import cart service

@Component({
  selector: 'app-cart',
  templateUrl: './cart.html',
  styleUrls: ['./cart.css']
})
export class Cart {
  constructor(public cartService: CartService) {}

  get cartItemCount() {
    return this.cartService.getCartItemCount();
  }
}
