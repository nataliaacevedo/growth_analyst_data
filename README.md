# Growth Analyst Technical Assessment

This repository contains my solution to a technical assessment for a Growth Analyst role. The exercise uses a synthetic e-commerce dataset (two weeks of September 2026, Meta and Google paid channels) to measure customer acquisition, reconstruct a same-session conversion funnel, and critically review a colleague's conclusion about channel performance.

All data is fictional and was provided as part of the assessment.

## What the assessment covers

1. **Acquisition reporting** by purchase week and last-click channel: new customers, NC CAC, net revenue (after refunds), repeat orders and backend net ROAS, compared against platform-reported numbers.
2. **Session funnel** by session-start week and channel: Session -> Product view -> Add to cart -> Checkout -> Purchase, with each stage counted once per session within a 24-hour window.
3. **Validation** of both outputs against the source tables.
4. **Critique and communication**: a short written response (max. 250 words) to a colleague's unverified claims, with a supporting table.

## Repository structure

```
.
├── README.md                     This file: context and navigation
├── README.txt                    Data dictionary and business rules provided with the assessment
├── setup.sql                     Script that creates and loads all tables
├── growth_practical.sqlite       SQLite database with the tables and the views created in this solution
├── *.csv                         Raw source tables (same data as setup.sql)
├── queries/
│   ├── adquisition.sql           Creates the acquisition_weekly view (step 1)
│   ├── adquisition_summary.sql   Reads the main acquisition metrics from acquisition_weekly
│   ├── session_funnel.sql        Funnel query, used while developing step 2
│   └── session_funnel_view.sql   Creates the session_funnel view (step 2)
├── validations/
│   ├── adquisition_validation.sql  Reconciles acquisition_weekly totals with the source tables
│   └── funnel_validation.sql       Checks that no funnel stage is larger than the stage before it
├── step_4.txt                    Prompt for step 4
└── step_4_response.md            Step 4 answer: response to the colleague, supporting table and notes
```

## Source tables

| Table | Grain | Used for |
|---|---|---|
| `channel_week` | Week and channel | Spend and platform-reported purchases and revenue |
| `sessions` | Website session | Funnel denominator, session week and channel |
| `funnel_events` | User action within a session | Product view, add to cart and checkout stages |
| `orders` | Paid order | Purchases, gross revenue, last-click channel |
| `customers` | Customer | First-ever paid order, to identify new customers |
| `refunds` | Refund transaction | Net revenue |

Full column definitions, relationships and business definitions are in `README.txt`.

## How to run

The queries are written for **SQLite** (they use functions such as `unixepoch`).

1. Open `growth_practical.sqlite` with any SQLite client (DB Browser for SQLite, DBeaver, the VS Code SQLite extension or the `sqlite3` CLI). To rebuild it from scratch, run `setup.sql` on an empty database.
2. Run `queries/adquisition.sql` and `queries/session_funnel_view.sql` to create the `acquisition_weekly` and `session_funnel` views (they already exist in the provided `.sqlite` file).
3. Run the files in `validations/` to check the views against the source tables.
4. Read `step_4_response.md` for the final write-up.

## Where to find each answer

| Step | Location |
|---|---|
| 1. Acquisition | `queries/adquisition.sql` (view `acquisition_weekly`), summary in `queries/adquisition_summary.sql` |
| 2. Funnel | `queries/session_funnel_view.sql` (view `session_funnel`) |
| 3. Validation | `validations/` |
| 4. Critique and communication | `step_4_response.md` |

## Key assumptions

- Backend data (orders, customers, refunds) is treated as the source of truth; platform figures from `channel_week` are only used for comparison.
- Refunds are counted up to the September 22 snapshot and assigned to the week and channel of the original order.
- Customers whose first paid order ID starts with `H` were acquired before this extract and are not counted as new.
- Blended metrics cover only Meta and Google, since those are the only channels with spend.
- More detail on assumptions and limitations is in the notes section of `step_4_response.md`.
