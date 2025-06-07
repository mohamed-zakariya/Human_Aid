import { Component } from '@angular/core';
import { AnalyticsService } from '../../services/anlytics/analytics.service';

@Component({
  selector: 'app-home',
  standalone: true,
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {

  constructor(private analyticsService: AnalyticsService) {}

  numAdults: number = 0;
  numChildren: number = 0;
  Guardians: number = 0;

  ngOnInit() {
  this.analyticsService.getUserStats().subscribe({
    next: stats => {
      console.log('User stats:', stats);
      this.numAdults = stats.numAdults;
      this.numChildren = stats.numChildren;
      this.Guardians = stats.numParents;
      // use stats.numAdults, stats.numChildren, stats.numParents
    },
    error: err => console.error('Error loading stats:', err)
  });
}


}
