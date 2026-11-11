# Step 4: Critique and communicate

## Response to colleague

Thanks for sharing. The data does not support scaling Meta yet.

1. **ROAS.** 2.5 to 3.0 is platform gross ROAS: 7-day click / 1-day view, overlapping with Google, including repeat buyers and before refunds. Meta backend net ROAS fell from 1.61 to 1.56 (-3%) and Meta NC CAC rose from $150 to $200 (+33%). Acquisition efficiency got worse.
2. **"110 new customers."** 110 is platform-attributed purchases (75 + 35), new and repeat, possibly double counted. Backend shows 82 orders and 55 new customers in week two (Meta 30, Google 25).
3. **Checkout.** Meta session-to-checkout held at 1.0%, but checkout-to-purchase dropped from 51.0% to 41.7% (-9.3 pp). Checkout is not stable. Google held at about 51%.
4. **+25% Meta spend.** Not justified. Meta new customers fell 25% (40 to 30) on flat spend, while Google NC CAC improved from $200 to $160.

**Finding:** Meta's week-two revenue came from repeat orders (11 to 21), not acquisition. Blended NC CAC rose from $167 to $182.

**Recommendation:** Keep Meta spend flat, investigate the Meta checkout-to-purchase drop, and wait for more weeks before moving budget to Google.

**Follow-up pulls:**
1. Meta checkout-to-purchase by device and day, plus payment errors: shows whether the drop is a fixable site issue before spending more.
2. 8 to 12 weeks of NC CAC and backend net ROAS by channel: shows whether week two is noise or a trend that justifies reallocation.

**Main limitation:** Two weeks and small counts (25 to 40 new customers per channel-week); changes may be noise.

### Supporting table

| Week | Channel | Spend | Platform ROAS | Backend net ROAS | New customers | NC CAC | Repeat orders | Session to checkout | Checkout to purchase |
|---|---|---|---|---|---|---|---|---|---|
| Sep 7 | Meta | $6,000 | 2.50 | 1.61 | 40 | $150 | 11 | 1.0% | 51.0% |
| Sep 14 | Meta | $6,000 | 3.00 | 1.56 | 30 | $200 | 21 | 1.0% | 41.7% |
| Sep 7 | Google | $4,000 | 1.50 | 1.20 | 20 | $200 | 5 | 1.0% | 50.0% |
| Sep 14 | Google | $4,000 | 1.75 | 1.47 | 25 | $160 | 6 | 1.2% | 51.7% |

Sources: `acquisition_weekly` and `session_funnel` views.

---

## Supporting notes (not part of the 250-word response)

### Assumptions
- Backend data (orders, customers, refunds) is the source of truth for acquisition; platform figures are only used to show the gap.
- "Meta's checkout rate at 1%" refers to sessions reaching checkout over total sessions (100/10,000 and 120/12,000).
- Efficiency is judged on NC CAC and backend net ROAS, not platform ROAS.
- Spend in `channel_week` is complete and only covers Meta and Google, so blended figures exclude other channels.

### Other risks
- **Immature refunds:** refunds are only counted up to the September 22 snapshot, so week-two net revenue is likely overstated compared to week one.
- **Platform overlap:** Meta and Google can both claim the same order, and there is no order-level bridge to reconcile them.
- **Same-session funnel:** the funnel does not capture cross-device or multi-session journeys, so purchases completed in a later session are missing.
- **Traffic mix:** Meta sessions grew 20% (10,000 to 12,000) with flat spend; new traffic may be lower intent, which could explain the checkout drop instead of a site issue.

### Conclusions
- The colleague's four claims rely on platform-reported metrics that overstate performance; backend data shows Meta acquisition getting less efficient.
- The main operational signal is the Meta checkout-to-purchase drop, which should be diagnosed before any budget increase.
- Google looks better in week two, but two weeks are not enough to justify reallocation.
