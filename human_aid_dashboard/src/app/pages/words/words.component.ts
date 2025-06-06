import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { WordService } from '../../services/words/words-service.service';
import { Word } from '../../interfaces/word-interface/word'; // Make sure this exists and is correct

@Component({
  selector: 'app-words',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './words.component.html',
  styleUrls: ['./words.component.css']
})
export class WordsComponent implements OnInit {
  words: Word[] = [];
  showAddModal = false;
  selectedFile: File | null = null;
  selectedFileName = '';
  imagePreview = '';
  isEditMode = false;
  editingWordId: string | null = null;

  newWord = {
    word: '',
    level: '' as 'Beginner' | 'Intermediate' | 'Advanced' | '',
    imageUrl: ''
  };

  constructor(private wordService: WordService) {}

  ngOnInit() {
    this.loadWords();
  }

  loadWords() {
    this.wordService.getWords().subscribe({
      next: (data) => {
        this.words = data;
        console.log('Loaded words:', this.words.map(w => ({id: w.id, word: w.word})));
      },
      error: (err) => {
        console.error('Failed to fetch words:', err);
      }
    });
  }

  saveWords() {
    localStorage.setItem('words', JSON.stringify(this.words));
  }

  toggleAddModal() {
    this.showAddModal = !this.showAddModal;
    if (!this.showAddModal) {
      this.resetForm();
    }
  }

  closeModal(event: Event) {
    if (event.target === event.currentTarget) {
      this.toggleAddModal();
    }
  }

  onImageSelected(event: Event) {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];

    if (file) {
      this.selectedFile = file;
      this.selectedFileName = file.name;

      const reader = new FileReader();
      reader.onload = (e) => {
        this.imagePreview = e.target?.result as string;
      };
      reader.readAsDataURL(file);
    }
  }

  hasValidImage(word: Word): boolean {
    return Boolean(word.imageUrl?.trim());
  }

  handleImageError(event: Event): void {
    const img = event.target as HTMLImageElement;
    const container = img.closest('.image-container');

    img.style.display = 'none';
    container?.classList.add('image-error');
  }

  openEditModal(word: Word) {
    this.isEditMode = true;
    this.editingWordId = word.id;
    this.newWord = {
      word: word.word ?? '',
      level: word.level ?? '',
      imageUrl: word.imageUrl ?? ''
    };
    this.imagePreview = word.imageUrl ?? '';
    this.showAddModal = true;
  }


  addWord(): void {
    const { word, level } = this.newWord;

    if (!word?.trim() || !level) {
      return;
    }

    if (this.isEditMode && this.editingWordId !== null) {
      this.wordService.updateWord(
        this.editingWordId,
        word.trim(),
        level,
        this.selectedFile || undefined
      ).subscribe({
        next: updated => {
          const index = this.words.findIndex(w => w.id === updated.id);
          if (index !== -1) {
            this.words[index] = updated;
          }
          this.saveWords();
          this.toggleAddModal();
          this.resetForm();
        },
        error: err => console.error('Error updating word:', err)
      });
    } else {
      this.wordService.addWord(word.trim(), level, this.selectedFile ?? undefined).subscribe({
        next: result => {
          const newWord = result.data?.createWord;  // matches the mutation name now
          if (newWord) {
            this.words.push(newWord);
            this.toggleAddModal();
            this.resetForm();
          } else {
            console.error('No word returned from mutation:', result);
          }
        },
        error: err => console.error('Error adding word:', err)
      });


    }
  }


  resetForm() {
    this.newWord = {
      word: '',
      level: '',
      imageUrl: ''
    };
    this.selectedFile = null;
    this.selectedFileName = '';
    this.imagePreview = '';
    this.isEditMode = false;
    this.editingWordId = null;
  }

  deleteWord(id: string) {
    if (confirm('Are you sure you want to delete this word?')) {
      this.wordService.deleteWord(id).subscribe({
        next: () => {
          this.words = this.words.filter(word => word.id !== id);
        },
        error: err => console.error('Error deleting word:', err)
      });
    }
  }

  trackByWord(index: number, word: Word): string {
    return word.id;
  }

  getTotalWords(): number {
    return this.words.length;
  }

  getWordsByLevel(level: string): number {
    return this.words.filter(word => word.level === level).length;
  }
}
