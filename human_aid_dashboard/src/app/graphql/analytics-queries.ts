import gql from "graphql-tag";

export const GET_USER_STATS = gql`
  query getUserStats {
    getUserStats {
      numAdults
      numChildren
      numParents
    }
  }
`;
