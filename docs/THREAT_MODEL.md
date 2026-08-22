# Threat Model

> Fill in each section below. The `devsecops-infinity.yml` plan-phase of the
> security-compliance-hub workflow looks for this file at `docs/THREAT_MODEL.md`
> and fails the build if it's missing. This template is a starting point — a
> thorough threat model is a living document, not a one-time artifact.

## 1. System overview

**What does this system do?**
<!-- 1–3 sentences describing the product and its purpose. -->

**Users and actors**
<!-- Who interacts with it? End users, admins, CI bots, upstream services, etc. -->

**Trust boundaries**
<!-- Where does trust change? Internet → load balancer, app → database,
app → third-party API, CI → deploy target, etc. List each boundary. -->

## 2. Assets

What is valuable and needs protection? Categories to consider:

| Asset | Sensitivity | Where it lives |
|---|---|---|
| _e.g. user credentials_ | High | Postgres `users` table |
| _e.g. session tokens_ | High | Redis, HTTP cookies |
| _e.g. business logic IP_ | Medium | Source repo |

## 3. Threats (STRIDE)

For each trust boundary and asset, enumerate threats across STRIDE:

- **S**poofing — can an attacker impersonate a user or service?
- **T**ampering — can data be modified in transit or at rest?
- **R**epudiation — can actions be performed without an audit trail?
- **I**nformation disclosure — can data leak to an unauthorized party?
- **D**enial of service — can the system be made unavailable?
- **E**levation of privilege — can a low-privilege actor gain high privilege?

| # | Threat | Asset affected | STRIDE | Likelihood | Impact | Mitigation | Status |
|---|---|---|---|---|---|---|---|
| 1 | _e.g. session cookie theft via XSS_ | Session tokens | I | Med | High | CSP + httpOnly + SameSite | Implemented |

## 4. Mitigations already in place

List the controls you rely on today. Examples:

- Authentication: <!-- OAuth / password + TOTP / magic links / etc. -->
- Authorization: <!-- RBAC / per-resource ACL / etc. -->
- Transport: <!-- TLS 1.2+ on all endpoints, HSTS, etc. -->
- Secrets management: <!-- env vars, vault, cloud KMS, etc. -->
- Logging & audit: <!-- which actions are logged, retention, etc. -->
- Dependency hygiene: <!-- Dependabot, weekly scan workflows, etc. -->

## 5. Residual risks

Threats you are knowingly accepting (with reasoning) or cannot mitigate yet.

## 6. Out of scope

What this threat model intentionally does **not** cover (e.g. physical
attacks on the datacenter, compromised developer laptops, zero-days in the
runtime).

## 7. Review cadence

This document was last reviewed on **YYYY-MM-DD**. Revisit:

- After any architectural change that alters a trust boundary.
- At least every 6 months.
- After any security incident, as part of the post-mortem.

---

Useful references:
- [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
- [Microsoft STRIDE](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [NIST SP 800-154 Guide to Data-Centric System Threat Modeling](https://csrc.nist.gov/pubs/sp/800/154/ipd)
