---
paths:
  - "src/api/**"
  - "src/routes/**"
  - "src/app/api/**"
---

# API Development Rules

- All endpoints must validate input with a schema (zod/joi/yup) before processing
- All endpoints must check authentication and authorization
- Error responses must follow the project's error format (see docs/ARCHITECTURE.md)
- All new endpoints must have at least one happy-path and one error-path test
- Do NOT expose internal error details (stack traces, SQL errors) in API responses
- Use appropriate HTTP status codes (see api-design Skill for reference)
