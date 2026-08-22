# ServiceConnect

Home-services booking platform built with Rails 8, PostgreSQL, JWT REST APIs, GraphQL, Active Storage, and Active Job.

## Setup

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
bundle exec rails test
```

Development uses local Active Storage; production is configured for Solid Queue (see `config/queue.yml`). Start its worker with `bin/jobs` when not running it through Puma.

## Demo accounts

All seed accounts use `DemoPass123!`: `admin@serviceconnect.test`, `customer1@serviceconnect.test`, `provider1@serviceconnect.test` (approved), and `provider4@serviceconnect.test` (suspended/rejected edge case).

## API and GraphQL

REST authentication: `POST /api/v1/auth/register`, `/login`, `/refresh`, `/logout`, `/forgot-password`, `/reset-password`; current user: `GET /api/v1/auth/me`.

Key REST resources: `/api/v1/providers`, `/api/v1/bookings`, `/api/v1/bookings/:booking_id/messages`, `/api/v1/notifications`, and `/api/v1/bookings/:booking_id/review`. Provider search supports category, city, rating, price, availability date, and pagination. Private documents upload through `POST /api/v1/documents/:kind`.

Use `POST /graphql` (or `/graphiql` in development) with a Bearer JWT. Key queries: `currentUser`, `providers`, `provider`, `bookings`, `booking`, `notifications`, `adminDashboard`, `providerDashboard`. Key mutations: `createBooking`, `acceptBooking`, `rejectBooking`, `confirmBooking`, `startBooking`, `completeBooking`, `cancelBooking`, `createMessage`, `createReview`, `approveProvider`, and `suspendUser`.

## Presentation

Provider web workflow: `/provider-dashboard`, `/provider-profile`, `/provider-services`, `/availability`. Protected admin workflow: `/admin/dashboard`. REST and GraphQL share booking creation/status services, with transactions, locking, activity logs, notifications, and scheduled reminders.
