# Tawasul Service Portal

The end-user service portal for **Sharjah Education Academy (SEA)**. Staff, faculty and students use it to request services, report incidents, see the devices assigned to them and track their requests, in Arabic or English. Agents keep working in the academy's service desk tool (HaloITSM); the portal is the front door.

## What it does

The home page has four service areas:

| Area | What people do there |
| --- | --- |
| **Request Service** | Pick a service (IT, Facilities, Student Services, Translation, Academic Team) and fill in the offering's form. |
| **Report Incident** | Report something broken. Impact and urgency set the priority (P1 to P4); a safety tick makes it P1. |
| **My Devices** | See equipment assigned to you, report a problem with a device, and confirm devices during a device check. |
| **Track My Requests** | Follow status and expected date, reply, cancel, confirm a fix, reopen within 5 days and rate the service. |

Also included:

- **Claude assistant** on the home page: people describe their need and Claude suggests the right offering and pre-fills the form (falls back to keyword matching when Claude is not available).
- **Approvals** for requests that need a manager's decision.
- **Arabic and English** with right-to-left layout.
- **Admin** (owner and Editors only):
  - *Services and offerings*: add services and offerings, build each form (8 field types, bilingual labels, required fields, choice lists), set expected time and approval.
  - *Devices*: register equipment and assign it to people.
  - *Device check*: run an inventory reconciliation, follow answers live, resolve follow-ups and download results as CSV.
  - *Approvers*, *Branding* (brand colour, name, short mark), *Announcement* banner and *Example data*.

## Run it locally with Docker

Requires Docker Desktop.

```bash
docker compose up -d --build
```

Then open <http://localhost:8080>. Stop it with `docker compose down`.

On Windows you can also double-click `scripts\start-tawasul.bat` and `scripts\stop-tawasul.bat`.

> **Preview mode.** Outside claude.ai the portal runs in preview mode with example data and nothing is saved. Sign-in, storage and the Claude assistant come from the claude.ai artifact runtime (see below).

## How it is built

- One self-contained page: `site/index.html` (HTML, CSS and vanilla JavaScript, no build step). Fonts load from Google Fonts.
- Served by `nginx:alpine` in Docker (`Dockerfile`, `nginx.conf`, `docker-compose.yml`).
- The live version runs as a claude.ai artifact and uses its runtime capabilities through `window.claude.use(...)`:

| Capability | Used for |
| --- | --- |
| `db` | Shared storage: `tickets`, `devices`, `confirmations`, `services`, `offerings`, `members`, `settings/main`, `settings/recon` |
| `user` | Who is signed in, names and avatars, people search |
| `sample` | The Claude assistant that routes requests |
| `downloads` | CSV export of device check results |

Access rules in the live artifact: tickets and confirmations are writable by Contributors; devices, services, offerings, approvers and settings only by Editors and the owner.

## Self-hosting for production

To run it on SEA infrastructure, replace the claude.ai runtime calls (the `storage`, `identity & roles` and `boot` sections of `site/index.html`) with:

1. **Sign-in**: Microsoft Entra ID.
2. **Storage**: a database with the collections listed above.
3. **HaloITSM integration**: a small back end that creates a Halo ticket on submit (Halo REST API, OAuth client credentials with a service account), maps each offering to a Halo ticket type and category, matches requesters by email, and receives Halo webhooks to send status changes and agent replies back to the portal.

## Repository layout

```
.
├── site/index.html          The portal
├── Dockerfile               nginx image
├── nginx.conf
├── docker-compose.yml       Runs on port 8080
├── scripts/                 Windows start and stop scripts
└── docs/                    Requirements workbook
```

## Customising

- **Brand colour**: Admin › Branding, or change `--brand` at the top of the `<style>` block.
- **Default catalogue**: the `AREAS0` and `CATALOG0` lists in the script. Changes made in Admin are stored and override these defaults.
