# Pango Backend API

RESTful API for the Pango accommodation booking platform.

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Start MongoDB
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Run development server
npm run dev
```

## API Endpoints

### Health Check
```
GET /health - Check server status
```

### Authentication
```
POST /api/v1/auth/register - Register new user
POST /api/v1/auth/login - Login user
POST /api/v1/auth/logout - Logout user
GET /api/v1/auth/me - Get current user
POST /api/v1/auth/forgot-password - Request password reset
POST /api/v1/auth/reset-password/:token - Reset password
POST /api/v1/auth/verify-email - Verify email
```

### Listings
```
GET /api/v1/listings - Get all listings
GET /api/v1/listings/:id - Get single listing
POST /api/v1/listings - Create listing (auth required)
PUT /api/v1/listings/:id - Update listing (auth required)
DELETE /api/v1/listings/:id - Delete listing (auth required)
GET /api/v1/listings/featured - Get featured listings
GET /api/v1/listings/host/:hostId - Get host's listings
```

### Bookings
```
GET /api/v1/bookings - Get user bookings (auth required)
POST /api/v1/bookings - Create booking (auth required)
GET /api/v1/bookings/:id - Get booking details (auth required)
PUT /api/v1/bookings/:id/confirm - Confirm booking (host only)
PUT /api/v1/bookings/:id/cancel - Cancel booking (auth required)
GET /api/v1/bookings/upcoming - Get upcoming bookings (auth required)
GET /api/v1/bookings/past - Get past bookings (auth required)
```

### Users
```
GET /api/v1/users/:id - Get user by ID
PUT /api/v1/users/profile - Update profile (auth required)
POST /api/v1/users/saved-listings/:listingId - Save listing (auth required)
DELETE /api/v1/users/saved-listings/:listingId - Remove saved listing (auth required)
GET /api/v1/users/saved-listings - Get saved listings (auth required)
```

## Running Tests

```bash
npm test
```

## Project Structure

```
backend/
├── src/
│   ├── config/          # Database configuration
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Custom middleware
│   ├── models/          # Mongoose models
│   ├── routes/          # API routes
│   ├── utils/           # Utility functions
│   ├── app.js           # Express app
│   └── server.js        # Entry point
├── logs/                # Application logs
├── package.json
└── .env.example
```

## Environment Variables

Required variables:
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `JWT_EXPIRE` - Token expiration time

See `.env.example` for all variables.























