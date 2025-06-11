import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class Cart {
  private cartItemCount = 0;

  constructor() {}

  increaseCount() {
    this.cartItemCount++;
  }

  getCartItemCount() {
    return this.cartItemCount;
  }
}
