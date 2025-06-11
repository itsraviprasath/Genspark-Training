import { Component } from '@angular/core';
import { Cart as CartService } from '../cart';

@Component({
  selector: 'app-products',
  templateUrl: './products.html',
  styleUrls: ['./products.css']
})
export class Products {
  products = [
    { id: 1, name: 'Product 1', imageUrl: 'https://via.placeholder.com/150' },
    { id: 2, name: 'Product 2', imageUrl: 'https://via.placeholder.com/150' },
    { id: 3, name: 'Product 3', imageUrl: 'https://via.placeholder.com/150' }
  ];

  constructor(private cartService: CartService) {}

  updateCart(productId: number) {
    this.cartService.increaseCount();
  }
}
