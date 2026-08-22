# ServiceConnect

ServiceConnect is a home-services booking platform. It provides a Rails web application for providers and administrators, plus versioned REST and GraphQL APIs for customer-facing mobile clients.

## Overview

The project uses a Ruby on Rails backend with a PostgreSQL database, server-rendered web application, REST API, and GraphQL API. Its APIs are designed to support React Native mobile integration; no React Native application is included in this repository. The platform has Customer, Provider, and Administrator roles.

## Key Features

- JWT access-token authentication with refresh-token, logout, password-reset, and current-user endpoints.
- Role-based and record-level authorization for customers, providers, and administrators.
- Service categories, provider discovery, provider profiles, provider services, and availability management.
- Booking creation and lifecycle management with availability and overlap validation; booking creation and status changes use transactions and locking.
- Booking reviews with ratings, comments, average rating, and total-review tracking.
- Booking-scoped messaging and user notifications.
- Provider and administrator dashboards, including provider approval and user account-status actions.
- Active Storage profile images and authenticated document upload endpoints.
- Active Job jobs for booking notifications, reminders, and provider-rating refreshes.
- Activity logs for selected booking, provider, and user actions.
- Automated Rails test suite.

## Technology Stack

| Technology | Purpose |
| --- | --- |
| Ruby on Rails 8.1 | Backend, web application, REST API, and Active Job |
| PostgreSQL | Application database |
| GraphQL Ruby | GraphQL API schema and execution |
| JWT and bcrypt | Token authentication and password hashing |
| Active Storage | Profile-image and document attachments |
| Solid Queue | Production background-job adapter |
| Turbo and Stimulus | Web application interactions |
| Minitest, Capybara, Selenium | Automated testing |

## Architecture

```text
Customer Mobile App
        |
  REST / GraphQL
        v
Ruby on Rails Backend
        |
        +-- PostgreSQL
        +-- Active Storage
        +-- Background Jobs
        |
        +-- Web Application
        +-- Provider Dashboard
        +-- Admin Dashboard
```

The Rails application is the shared business and authorization layer for both APIs and web workflows. PostgreSQL stores application data, Active Storage manages attachments, and background jobs process notifications, reminders, and rating updates.

## User Roles

### Customer

Customers can manage addresses and customer-profile data, browse approved providers, create and manage their own bookings, exchange messages with booking participants, receive notifications, and review completed bookings.

### Provider

Providers can manage their profile, services, availability, and profile image; view their own bookings; accept, reject, start, and complete eligible bookings; and view their dashboard.

### Administrator

Administrators can access the admin dashboard, approve or reject provider profiles, suspend or reactivate users, inspect dashboard activity, and manage service categories through the API.

## REST API

Base path: `/api/v1`

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/auth/register` | Register a user |
| POST | `/auth/login` | Authenticate and receive tokens |
| POST | `/auth/refresh` | Refresh an access token |
| POST | `/auth/logout` | Revoke a refresh token |
| GET | `/auth/me` | Return the authenticated user |
| POST | `/auth/forgot-password` | Request a password reset |
| POST | `/auth/reset-password` | Reset a password |
| GET | `/providers` | List approved providers with supported filters and pagination |
| GET | `/providers/:id` | Show an approved provider |
| GET | `/providers/:id/availability` | List an approved provider’s active availability |
| GET | `/providers/:id/reviews` | List an approved provider’s reviews |
| GET, POST | `/bookings` | List accessible bookings or create a customer booking |
| GET | `/bookings/:id` | Show an accessible booking |
| PATCH | `/bookings/:id/accept`, `/reject`, `/confirm`, `/start`, `/complete`, `/cancel` | Change booking status when authorized |
| GET, POST | `/bookings/:booking_id/messages` | List or create booking messages |
| POST | `/bookings/:booking_id/review` | Create a review for a completed booking |
| GET | `/notifications` | List the authenticated user’s notifications |
| PATCH | `/notifications/:id/read`, `/notifications/read_all` | Mark one or all notifications as read |
| GET, PATCH | `/provider-profile` | Show or update the current provider profile |
| POST, DELETE | `/provider-profile/image` | Upload or remove the current provider profile image |
| POST | `/documents/:kind` | Upload authenticated provider or customer documents |

Additional implemented REST resources include addresses, customer profiles, availabilities, provider services, service categories, reviews, and individual notifications.

## GraphQL API

`POST /graphql`

GraphQL supports client-selected data for mobile and web screens while using the same authentication and authorization rules as the REST API. In development, GraphiQL is available at `/graphiql`.

Verified queries include `currentUser`, `serviceCategories`, `providers`, `provider`, `bookings`, `booking`, `messages`, `notifications`, `reviews`, `availabilities`, `providerServices`, `adminDashboard`, and `providerDashboard`.

```graphql
query CurrentUser {
  currentUser { id firstName lastName email role status }
}

query Categories {
  serviceCategories { id name description active }
}

query Providers {
  providers { id businessName averageRating totalReviews }
}

query Provider($id: ID!) {
  provider(id: $id) { id businessName description hourlyRate approvalStatus }
}

query Bookings {
  bookings { id status scheduledAt estimatedDuration estimatedPrice }
}

query Notifications {
  notifications { id bookingId notificationType message read createdAt }
}
```

Implemented mutations include `createBooking`, `acceptBooking`, `rejectBooking`, `confirmBooking`, `startBooking`, `completeBooking`, `cancelBooking`, `createMessage`, `createReview`, address/profile/provider-service/availability mutations, notification read mutations, `approveProvider`, and `suspendUser`.

## Booking Lifecycle

Bookings start as `pending`. A provider can change a pending booking to `accepted` or `rejected`; a customer can confirm an accepted booking; a provider can start a confirmed booking (`in_progress`) and complete it (`completed`). A customer or the assigned provider can cancel an eligible booking (`cancelled`). The implemented transition rules are:

```text
pending -> accepted | rejected | cancelled
accepted -> confirmed | cancelled
confirmed -> in_progress | cancelled
in_progress -> completed
```

## Reviews & Ratings

A review belongs to one booking and contains a rating from 1 to 5 and a required comment. Only the customer of a completed booking can create its review. Provider profiles store the calculated average rating and total review count.

## Data & Demo Seed

The current seed script creates the five active service categories: Carpentry, Cleaning, Electrical, Painting, and Plumbing. It creates one administrator, five customers, and five provider accounts; each seeded provider is linked to services in every category, weekly availability, and booking data. It also creates 20 bookings across multiple statuses, plus completed-booking reviews, messages, and notifications. One seeded provider is suspended and has a rejected profile.

The current seed script does **not** create 25 category-specific active providers or a provider named “Ali Electrical Services”; those claims are intentionally omitted because they are not present in the repository’s implementation source.

## Currency

All ServiceConnect service and booking prices are represented in Pakistani Rupees (PKR).

Example: `PKR 1,800`

## Demo Accounts

Development/demo accounts seeded by `bin/rails db:seed`:

| Role | Email | Password |
| --- | --- | --- |
| Administrator | `admin@serviceconnect.test` | `DemoPass123!` |
| Customer | `customer1@serviceconnect.test` | `DemoPass123!` |
| Provider | `provider1@serviceconnect.test` | `DemoPass123!` |

Do not use these credentials outside a local development or demonstration environment.

## Setup

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

Run the automated test suite with:

```bash
bundle exec rails test
```
