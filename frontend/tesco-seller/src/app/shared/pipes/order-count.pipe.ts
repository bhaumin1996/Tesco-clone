import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'orderCount', standalone: true, pure: true })
export class OrderCountPipe implements PipeTransform {
  transform(orders: { statusName: string }[], tab: string): number {
    return orders.filter(o => o.statusName === tab).length;
  }
}
