import { Component, OnInit, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.css'
})
export class MainLayoutComponent implements OnInit {
  isOpen = false;
  isDarkMode = false;
  showProfileDropdown = false;

  constructor(private router: Router) {}

  ngOnInit() {
    // Check for saved dark mode preference
    const savedDarkMode = localStorage.getItem('darkMode');
    this.isDarkMode = savedDarkMode === 'true';
    this.applyDarkMode();
  }

  toggleSidebar() {
    this.isOpen = !this.isOpen;
  }

  toggleDarkMode() {
    this.isDarkMode = !this.isDarkMode;
    localStorage.setItem('darkMode', this.isDarkMode.toString());
    this.applyDarkMode();
  }

  private applyDarkMode() {
    if (this.isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }

  toggleProfileDropdown() {
    this.showProfileDropdown = !this.showProfileDropdown;
  }

  onLogout() {
    // Add your logout logic here
    console.log('Logging out...');
    this.router.navigate(['/login']);
  }

  // Close sidebar when clicking outside on mobile
  @HostListener('document:click', ['$event'])
  onDocumentClick(event: Event) {
    const target = event.target as HTMLElement;
    
    // Close profile dropdown if clicked outside
    if (!target.closest('.profile-dropdown')) {
      this.showProfileDropdown = false;
    }
    
    // Close sidebar on mobile if clicked outside
    if (window.innerWidth < 1024 && !target.closest('.sidebar') && !target.closest('.hamburger-btn')) {
      this.isOpen = false;
    }
  }

  // Close sidebar on window resize to desktop
  @HostListener('window:resize', ['$event'])
  onResize() {
    if (window.innerWidth >= 1024) {
      this.isOpen = false;
    }
  }
}