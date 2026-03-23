---
description: Security review patterns. Use when auditing code for vulnerabilities or reviewing security-sensitive changes.
---

# Security Audit Skill

## OWASP Top 10 Quick Check

| Vulnerability | What to Look For |
|--------------|------------------|
| Injection (SQL, NoSQL, OS) | String concatenation in queries. Use parameterized queries. |
| Broken Auth | Missing auth checks on endpoints. Token/session mishandling. |
| Sensitive Data Exposure | Secrets in code/logs. PII in URLs. Missing encryption. |
| XSS | Unescaped user input in HTML. Use framework's auto-escaping. |
| Broken Access Control | Missing ownership checks ("can user X access resource Y?"). |
| Security Misconfiguration | Default credentials. Debug mode in production. Open CORS. |
| Insecure Dependencies | Known CVEs in dependencies. Run `npm audit` / `pip audit`. |

## Code Review Security Checklist

- [ ] All user input validated at API boundary (never trust client data)
- [ ] No secrets in source code (API keys, passwords, tokens)
- [ ] No secrets in logs (mask sensitive fields)
- [ ] Authentication checked on all non-public endpoints
- [ ] Authorization checked (resource ownership, role-based access)
- [ ] SQL/NoSQL queries use parameterized inputs
- [ ] File uploads validated (type, size, name sanitization)
- [ ] Rate limiting on authentication endpoints
- [ ] HTTPS enforced, no mixed content
- [ ] Error messages don't leak internal details to users
