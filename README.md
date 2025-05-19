# 📅 Smart Event Planning App

## Overview
**Smart Event Planning App** is a mobile application built to streamline the event planning process by enabling seamless collaboration between two primary roles: Vendors and Organizers. The platform offers a centralized, interactive space where users can connect as well as coordinate effortlessly. Whether it's booking a venue, choosing a catering service, or finding the perfect decor, this app simplifies it all.

## 🚀 Features

### 1. Splash Screen
- Displays app logo and name for 3–5 seconds.

<div>
  <img src="screenshots/ss1.png" width="150" style="margin-right: 10px;"/>
  <img src="screenshots/ss2.png" width="150"/>
</div>

---

### 2. Authentication Flow
- Google Sign-In via Firebase Authentication.
- Persistent login using session management.
- Redirects:
  - To **Sign-Up Screen** if the user is not logged in.
  - To **Role-based Dashboard** if authenticated.

<img src="screenshots/ss3.png" width="150"/>

---

### 3. User Role Selection
- Users choose between **Vendor** or **Organizer** roles.
- Role-based access delivers a tailored user experience.

<img src="screenshots/ss4.png" width="150"/>

---

### 4. Vendor Dashboard
- View a list of uploaded services and upcoming booked events.

<img src="screenshots/ss12.png" width="150"/>

- Edit existing service posts.

<div>
  <img src="screenshots/ss13.png" width="150" style="margin-right: 10px;"/>
  <img src="screenshots/ss133.png" width="150"/>
</div>

- Add new services with:
  - Category selection (e.g., Food, Decor, Venue)

<img src="screenshots/ss14.png" width="150"/>

---

### 5. Booking Requests
- View incoming booking details:
  - Organizer Name, Service, Date, Status
- Accept or Reject bookings with one tap.

<img src="screenshots/ss15.png" width="150"/>

---

### 6. Organizer Dashboard
- Browse services by category: **Food**, **Decor**, **Venue**.

<div>
  <img src="screenshots/ss5.png" width="150" style="margin-right: 10px;"/>
  <img src="screenshots/ss6.png" width="150"/>
</div>

- Submit booking requests by selecting date and time.
- Users can view and post comments on services and experiences.

<div>
  <img src="screenshots/ss10.png" width="150" style="margin-right: 10px;"/>
  <img src="screenshots/ss11.png" width="150"/>
</div>

#### My Bookings
- View bookings by status: **Pending**, **Accepted**, **Rejected**.
- Option to cancel bookings.

<img src="screenshots/ss7.png" width="150"/>

---

### 7. Search & Filtering
- Keyword search for services or vendors.
- Filter results by category for easy discovery.

<div>
  <img src="screenshots/ss8.png" width="150" style="margin-right: 10px;"/>
  <img src="screenshots/ss9.png" width="150"/>
</div>

---

## Technologies Used
- **Flutter**
- **Firebase Authentication**
- **Firebase Firestore**
- **BLoC Pattern for State Management**
