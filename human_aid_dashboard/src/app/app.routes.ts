import { Routes } from '@angular/router';
import { LoginComponent } from './auth/login/login.component';
import { MainLayoutComponent } from './layout/main-layout/main-layout.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  {
    path: 'dashboard',
    component: MainLayoutComponent,
    children: [
      { path: '', redirectTo: 'home', pathMatch: 'full' },
      { 
        path: 'home', 
        loadComponent: () => import('./pages/home/home.component').then(c => c.HomeComponent)
      },
      // Add more child routes here as you create components
      // { path: 'students', loadComponent: () => import('./pages/students/students.component').then(c => c.StudentsComponent) },
      // { path: 'attendance', loadComponent: () => import('./pages/attendance/attendance.component').then(c => c.AttendanceComponent) },
    ]
  },
  { path: '**', redirectTo: 'login' } // Wildcard route for 404 page
];