---
inclusion: auto
name: api-design
description: REST API design patterns, input validation, error handling, and security practices. Use when creating or modifying API endpoints.
---

# API Design Patterns

## Endpoint Structure

```
GET    /api/[resource]         → List (with pagination)
GET    /api/[resource]/:id     → Get one
POST   /api/[resource]         → Create
PUT    /api/[resource]/:id     → Full update
PATCH  /api/[resource]/:id     → Partial update
DELETE /api/[resource]/:id     → Delete
```

## Input Validation

Every endpoint must validate input at the boundary:

```typescript
// Use zod schemas
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});

// In route handler:
const body = createUserSchema.parse(await request.json());
```

## Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": { "field": "email", "received": "not-an-email" }
  }
}
```

## Status Codes

- 200: Success (GET, PUT, PATCH)
- 201: Created (POST)
- 204: No content (DELETE)
- 400: Bad request (validation failure)
- 401: Not authenticated
- 403: Not authorized
- 404: Not found
- 409: Conflict
- 500: Server error

## Security Checklist

- [ ] Input validated with schema
- [ ] Auth checked
- [ ] Authorization checked (ownership)
- [ ] No internal errors leaked to client
- [ ] Rate limiting configured
