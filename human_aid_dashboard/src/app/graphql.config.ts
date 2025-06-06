// graphql.config.ts
import { Apollo } from 'apollo-angular';
import { HttpLink } from 'apollo-angular/http';
import { InMemoryCache } from '@apollo/client/core';
import { APOLLO_OPTIONS } from 'apollo-angular';
import { provideHttpClient } from '@angular/common/http';
import { createUploadLink } from 'apollo-upload-client';

export function createApollo(): any {
  const uploadLink = createUploadLink({
    uri: 'http://localhost:5500/graphql',
  });

  return {
    link: uploadLink,
    cache: new InMemoryCache(),
  };
}

export const graphqlProviders = [
  provideHttpClient(),
  Apollo,
  HttpLink,
  {
    provide: APOLLO_OPTIONS,
    useFactory: createApollo,
    deps: [],
  },
];
