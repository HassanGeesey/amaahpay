# AmaahPay — Product Requirements Document (PRD)

**Version:** 2.0  
**Date:** 2026-04-20  
**Status:** Approved

---

## 1. Overview

AmaahPay is a mobile application built with **Flutter**, native for iOS & Android. It is a subscription-based business management platform that enables merchants to track customer credit/deposits, manage product sales, and generate reports. The platform supports **two user roles**, **bilingual UI** (English & Somali), and **dual-currency display** (USD & SOS).

---

## 2. Goals & Objectives

- Provide a simple, fast mobile tool for small merchants to manage credit and deposit transactions.
- Allow administrators to manage merchant subscriptions and billing.
- Ensure cross-platform support with native performance using Flutter.

---

## 3. User Roles

| Role                | Description                                                         |
| ------------------- | ------------------------------------------------------------------- |
| **Admin**           | Creates and manages merchant users. Handles billing and activation. |
| **User (Merchant)** | Manages their own customers, products, sales, and reports.          |

> All merchant users share the same role — no tiered permissions within the user level.

---

## 4. Platform & Tech Requirements

| Requirement         | Detail                                                  |
| ------------------- | ------------------------------------------------------- |
| **Framework**       | Flutter                                                 |
| **Deployment**      | Android (.apk/AAB) & iOS                                |
| **Languages**       | English & Somali (switchable)                           |
| **Currencies**      | USD & SOS — **both displayed simultaneously**           |
| **Conversion Rate** | Configurable by user (e.g., 1 USD = X SOS)              |
| **Theme**           | Light mode & Dark mode                                  |

---

## 5. Pages & Features

### 5.1 Landing / Onboarding Screen

- Explains the app's purpose and value.
- Login entry point.
- A note for new users: _"Contact admin via WhatsApp"_ → links to `wa.me/252619444629`.

---

### 5.2 Authentication

#### Login
- "Remember Me" feature.
- Fields: **Email** + **Password**.
- Role-based redirection based on Admin/User status.

#### Password Reset
- Users cannot self-reset passwords.
- Flow: User contacts their admin → Admin creates a new password for them.

---

### 5.3 Admin Panel

#### User Management
- View a list of all merchant users.
- Create a new user with: Name, Email, Phone, Shop Name, Password.
- Edit user details.
- Deactivate / reactivate users manually.
- Reset a user's password.

> When a user account is first created, it is **automatically disabled** until the admin activates it after payment.

#### Billing Configuration (Per User)
- Admin sets a billing plan for each user:
  - **Billing cycle:** Monthly (30 days) or Yearly (12 months)
  - **Price:** Configurable per user
- Admin activates the user after confirming payment.
- At the end of the billing cycle, the user is **automatically deactivated**.
- If the user pays again, the admin reactivates them and the cycle repeats.

#### Admin Reports
- **Payment History:** All payments received per user (date, amount, plan type).
- **Activation History:** Log of all activate/deactivate events per user (date, action, triggered by whom).

---

### 5.4 User Panel (Merchant)

#### 5.4.1 Customers
**Add a Customer:**
| Field   | Default |
| ------- | ------- |
| Name    | —       |
| Phone   | —       |
| Credit  | 0       |
| Deposit | 0       |

**Customer List Page Shows:**
- Customer name & phone
- Current credit/deposit balance
- Transaction history
- Transactions can be edited or deleted by the user.

---

#### 5.4.2 Products
**Create a Product:**
| Field         | Notes                             |
| ------------- | --------------------------------- |
| Product Name  | —                                 |
| Unit          | e.g., kg, litre, piece            |
| Default Price | Can be overridden at time of sale |

---

#### 5.4.3 Sales
**A. Credit / Deposit Operations**
| Scenario | Behavior |
| -------- | -------- |
| Customer deposits & has outstanding credit | Amount first deducts from credit; remaining goes to deposit |
| Customer uses credit & has deposit funds | Amount first deducts from deposit; remaining becomes credit |

**B. Product Sales**
1. Select/Create customer.
2. Add products, override price, set quantity.
3. Enter cash paid.
4. Tap Confirm Sale → Payment breakdown popup.

---

#### 5.4.4 Reports
- **Filters:** Customer, Date Range
- **Columns:** Date, Customer Name, Product, Amount Paid, Credit Balance, Deposit Balance
- **Export:** Print, Download as PDF, CSV

---

#### 5.4.5 Settings
- Language (English / Somali)
- Currency Conversion Rate (1 USD = X SOS)
- Theme (Light/Dark)

---

## 6. Billing Lifecycle

Admin creates user (DISABLED) → User pays offline → Admin activates & sets cycle → App warns user 3 days before expiry → Account auto-deactivates at expiry.

---

## 7. Notifications

- **3 days before expiry:** In-app notification.
- **Grace period (last 3 days):** Persistent red banner.
- **Account deactivated:** Blocked screen.

---

## 8. Localization & Currency

- Somali is LTR — no RTL support needed.
- Values shown as `$10.00 / 27,000 SOS`.
- If conversion rate is unset, prompt user before proceeding.

---

## 9. Non-Functional Requirements

- **Performance:** Native 60fps navigation natively compiled by Flutter.
- **Security:** Strict role-based routing (Users cannot access Admin UI).
- **Data:** Backend synced (e.g., Supabase) with offline capabilities.
