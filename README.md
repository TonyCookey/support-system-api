# Support System API (Rails Backend)

This is the backend API for the Support System API, built with Ruby on Rails (API-only). It provides endpoints

- Create Ticket
- Create Ticket with Attachment
- Comment (Agent & Customer)
- Export Closed Tickets (Agent - Past 1 Month)

---

## Development Setup

### Prerequisites

- Ruby 3.1+ (3.4.x recommended)
- Rails 7 or 8
- PostgreSQL

---

### Setup

```bash
# Clone the repo

git clone https://github.com/TonyCookey/support-system-api.git

cd support-system-api

# Install dependencies
bundle install

# Copy environment files (optional)
cp .env.example .env

# Setup the database
rails db:create db:migrate

# Start the Rails server
rails server

```

### Testing

```
bundle exec rspec

```
