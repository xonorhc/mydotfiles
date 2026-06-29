# API Documentation

## Overview

Brief description of what this API does and its main purpose.

**Base URL:** `https://api.example.com/v1`  
**Version:** 1.0  
**Last Updated:** [Date]

## Authentication

### API Key Authentication

Include your API key in the request header:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" https://api.example.com/v1/endpoint
```

### OAuth 2.0

For OAuth 2.0 authentication, follow these steps:

1. Register your application
2. Get authorization code
3. Exchange for access token

## Rate Limiting

- **Rate Limit:** 1000 requests per hour
- **Headers:** 
  - `X-RateLimit-Limit`: Request limit per hour
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Time when rate limit resets

## Endpoints

### Users

#### GET /users

Retrieve all users.

**Parameters:**
- `limit` (optional): Number of users to return (default: 10)
- `offset` (optional): Number of users to skip (default: 0)

**Response:**
```json
{
  "users": [
    {
      "id": "123",
      "name": "John Doe",
      "email": "john@example.com",
      "created_at": "2023-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "limit": 10,
  "offset": 0
}
```

#### GET /users/{id}

Retrieve a specific user by ID.

**Parameters:**
- `id` (required): User ID

**Response:**
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2023-01-01T00:00:00Z"
}
```

#### POST /users

Create a new user.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2023-01-01T00:00:00Z"
}
```

## Error Handling

The API returns standard HTTP status codes:

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error

**Error Response Format:**
```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "The request is invalid",
    "details": "Additional error details"
  }
}
```

## SDKs and Libraries

### JavaScript/Node.js
```bash
npm install example-api-client
```

### Python
```bash
pip install example-api-client
```

## Support

For API support, contact:
- **Email:** api-support@example.com
- **Documentation:** https://docs.example.com
- **Status Page:** https://status.example.com
