FILES AND COLUMN DICTIONARY
channel_week.csv: one row per reporting week and paid channel.
  week_start: Monday date; channel: Meta or Google; spend: USD media spend;
  platform_purchases: attributed purchases, including new and repeat customers;
  platform_revenue: attributed gross revenue before refunds, excluding tax/shipping.
  This table contains no website session or checkout counts.

sessions.csv: one row per website session, including those without product actions.
  session_id: unique session key; started_at: session-start timestamp;
  week_start: Monday of the session-start week; channel: supplied reporting channel;
  device_type: mobile or desktop. Device analysis is available but not separately required.

funnel_events.csv: one row per recorded action.
  event_id: unique event key; session_id: session in which it occurred;
  event_type: view_item, add_to_cart, or begin_checkout;
  occurred_at: event timestamp. Repeated actions within one session have distinct IDs.
  Purchases come from orders, not a purchase event in this file.

orders.csv: one row per successfully paid order.
  order_id: unique order key; customer_id: customer key;
  week_start: Monday of the purchase week; last_click_channel: supplied attribution;
  gross_revenue: USD before refunds, excluding tax/shipping;
  session_id: linked session key; paid_at: successful payment timestamp.
  A customer can place multiple orders. A session can also contain multiple orders.

customers.csv: one row per customer appearing in the orders extract.
  customer_id: unique customer key; first_paid_order_id: first-ever paid order.
  IDs beginning H are historical orders outside the extract. History is complete
  for determining first orders. Do not infer first order from the earliest visible row.

refunds.csv: one row per refund transaction received by the September 22 snapshot.
  refund_id: unique transaction key; order_id: refunded order;
  refund_amount: positive USD amount. An order may have several refund transactions.
  Total refunds do not exceed gross revenue. A refund does not undo a paid order.

RELATIONSHIPS
funnel_events.session_id -> sessions.session_id: many actions to one session.
orders.session_id -> sessions.session_id: potentially many orders to one session.
orders.customer_id -> customers.customer_id: many orders to one customer.
refunds.order_id -> orders.order_id: potentially many refunds to one order.
channel_week has a compound key (week_start, channel). Compare it with results
at the same reporting grain; matching week and channel does not connect an
individual event to an individual order. The session_id establishes that link.

TIME, COHORTS, AND FUNNEL MEMBERSHIP
All timestamps are UTC in YYYY-MM-DD HH:MM:SS format. Weeks start Monday.
Sessions start in September 7–13 or September 14–20, 2026. Snapshot: September 22.
Each session has a complete 24-hour observation window.
Acquisition reporting uses the paid order's purchase week and last-click channel.
The funnel groups sessions by session-start week and sessions.channel.
Within a session, count progression through Session -> Product view -> Add to
cart -> Checkout -> Purchase. Required event order is view_item, add_to_cart,
begin_checkout, then paid order. All must occur at or after session start and
strictly before 24 hours after start. Equal timestamps are allowed. A qualifying
sequence is sufficient even if actions repeat. A stage requires its preceding
stages. Each stage counts a session once, regardless of events or order count.
For each adjacent conversion rate, divide by the preceding stage's session count.
Refunds do not remove purchase-stage completion. Keep sessions with no events
and no purchases in the session denominator. A session may start in one calendar
week and purchase in the next within its observation window; use the session link.

BUSINESS DEFINITIONS
New customers are acquired on first-ever successfully paid orders; refunds do
not erase acquisition. NC CAC = spend / newly acquired customers.
Net revenue = gross less all refunds received by snapshot, assigned to the
original paid order's week and channel. New-customer net revenue uses first-ever
orders only. Other orders are repeat orders. Backend net ROAS = net revenue / spend.
Platform ROAS = platform gross revenue / spend. Platforms use seven-day click
and one-day view attribution, reported by purchase week for this fictional case.
Backend last click uses the final eligible non-direct channel in the seven days
before purchase. Session channel assignments are already supplied and agree
with linked order channels in this fixture. No attribution model construction
or identity resolution is required. Platform claims may overlap; no order-level
platform attribution bridge is supplied. A blended result covers only Meta/Google.
Use NULL/unavailable for a zero denominator. Distinguish percent and percentage points.

SCOPE
The two new granular tables and session links support reconstructing this
same-session funnel. They do not represent a full cross-device customer journey
or establish why performance changed. This is synthetic assessment data.
