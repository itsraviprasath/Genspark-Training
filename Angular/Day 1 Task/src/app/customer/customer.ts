import { Component } from '@angular/core';

@Component({
  selector: 'app-customer',
  templateUrl: './customer.html',
  styleUrls: ['./customer.css']
})
export class Customer {
  likes = 0;
  dislikes = 0;

  onLike() {
    this.likes++;
  }

  onDislike() {
    this.dislikes++;
  }
}
