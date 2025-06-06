import { Injectable } from '@angular/core';
import { Apollo } from 'apollo-angular';
import { map, filter } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { GET_WORDS, DELETE_WORD, UPDATE_WORD, ADD_WORD_MUTATION } from '../../graphql/word-queries';
import { Word } from '../../interfaces/word-interface/word';

@Injectable({
  providedIn: 'root'
})
export class WordService {
  constructor(private apollo: Apollo) {}

  getWords(): Observable<Word[]> {
    return this.apollo.watchQuery<{ getWords: Word[] }>({
      query: GET_WORDS
    }).valueChanges.pipe(
      map(result => result.data?.getWords ?? [])
    );
  }

  deleteWord(id: string): Observable<Word> {
    return this.apollo.mutate<{ deleteWord: Word }>({
      mutation: DELETE_WORD,
      variables: { id }
    }).pipe(
      map(result => result.data?.deleteWord as Word)
    );
  }

  updateWord(id: string, word: string, level: string, image?: File): Observable<Word> {
    return this.apollo.mutate<{ updateWord: Word }>({
      mutation: UPDATE_WORD,
      variables: { id, word, level, image }
    }).pipe(
      map(result => result.data?.updateWord as Word)
    );
  }


  addWord(word: string, level: string, image?: File) {
    return this.apollo.mutate<{ createWord: Word }>({
      mutation: ADD_WORD_MUTATION,
      variables: { word, level, image: image ?? null },
      context: { useMultipart: true }
    });
  }






}
