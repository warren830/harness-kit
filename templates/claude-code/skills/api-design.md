---
description: API design patterns and conventions. Use when creating or modifying API endpoints.
---

# API Design Skill

## Endpoint Conventions

```
GET    /api/[resource]         → List resources
GET    /api/[resource]/:id     → Get single resource
POST   /api/[resource]         → Create resource
PUT    /api/[resource]/:id     → Full update
PATCH  /api/[resource]/:id     → Partial update
DELETE /api/[resource]/:id     → Delete resource
```

## Request Validation

ALL user input must be validated at the API boundary. Use schema validation (zod, joi, yup):

```typescript
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(["user", "admin"]).default("user"),
});

// In handler:
const body = createUserSchema.parse(req.body); // throws on invalid input
```

## Response Format

Consistent response structure:

```json
// Success
{ "data": { ... }, "meta": { "page": 1, "total": 42 } }

// Error (RFC 7807-inspired)
{ "error": { "code": "NOT_FOUND", "message": "User not found", "details": {} } }
```

## HTTP Status Codes

| Code | When |
|------|------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Invalid input (validation failure) |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, version conflict) |
| 500 | Server error (unexpected) |

## Security Checklist

- [ ] Input validated with schema
- [ ] Authentication checked
- [ ] Authorization checked (does this user own this resource?)
- [ ] Rate limiting configured
- [ ] No sensitive data in URLs (use body/headers)
- [ ] SQL injection prevented (parameterized queries)
