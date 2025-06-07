// analytics.service.ts
import { Injectable } from '@angular/core';
import { Apollo } from 'apollo-angular';
import gql from 'graphql-tag';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { GET_USER_STATS } from '../../graphql/analytics-queries';


@Injectable({
  providedIn: 'root'
})
export class AnalyticsService {

  constructor(private apollo: Apollo) {}

  getUserStats(): Observable<{ numAdults: number; numChildren: number; numParents: number }> {
    return this.apollo.watchQuery<{ getUserStats: { numAdults: number; numChildren: number; numParents: number } }>({
      query: GET_USER_STATS
    }).valueChanges.pipe(
      map(result => result.data.getUserStats)
    );
  }
}
