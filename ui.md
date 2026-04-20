# AmaahPay — UI & Design Specifications

## 1. Design System

**Theme:** Editorial Minimal with Warm/Agri accents (based on previous iterations)  
**Primary Characteristic:** Clean white space, distinct typography, bold but warm brand colors that feel accessible to small merchants.

### Color Palette
- **Primary:** Warm Sunset Orange (`#E65100` / `Colors.orange[900]`)
- **Secondary:** Deep Earth Brown (`#4E342E` / `Colors.brown[800]`) 
- **Background (Light):** Off-White (`#FAFAFA` / `Colors.grey[50]`)
- **Background (Dark):** Soft Black (`#121212`)
- **Success:** Muted Green (`#2E7D32` / `Colors.green[800]`)
- **Error / Deactivation:** Soft Red (`#D32F2F` / `Colors.red[700]`)

### Typography
- **Headings:** Google Fonts "Outfit" (bold, friendly, modern)
- **Body:** Google Fonts "Inter" (highly legible for numbers and lists)
- Flutter Implementation: `GoogleFonts.outfit()` for Display styles, `GoogleFonts.inter()` for Body styles.

---

## 2. Global Components

### Buttons
- **Primary:** Filled `ElevatedButton` using the Primary Warm Sunset color, smooth rounded corners (`borderRadius: 8.0`).
- **Secondary:** `OutlinedButton` using the Primary color for text/border.
- **Micro-interactions:** Subtle scaling up on tap down (e.g., using `InkWell` / `splashColor`).

### Inputs
- Clean `TextFormField` with an `OutlineInputBorder`.
- Subtle gray border when inactive, Primary color border with a 2px thickness when focused.
- Labels float above input field.

### Dual-Currency Display Widget
- A reusable Flutter component `DualCurrencyText(usd: 10, sos: 27000)` that handles the `$10.00 / 27,000 SOS` formatting.
- The SOS value should be visually de-emphasized (e.g., secondary text color, slightly smaller font) to keep the UI from feeling cluttered.

---

## 3. Screen Layouts

### Admin Dashboard Layout
- **Navigation:** Bottom Navigation Bar (Users, Reports, Settings).
- **Header:** White App Bar, elevated slightly, showing "AmaahPay Admin".
- **Lists:** User Cards with active/disabled badges. Disabled = Grayed out, Active = Green indicator.

### Merchant (User) Dashboard Layout
- **Navigation:** Bottom Navigation Bar (Home, Customers, Sales, Settings).
- **Customers List:** Avatar (initials), Name, Phone, and distinct columns for Credit (Red text) and Deposit (Green text).
- **Sales Flow (POS):** 
  - Cart layout with a sliding bottom sheet for the "Confirm Sale / Breakdown" popup.

### Modals & Dialogs
- **Alerts:** Center screen `AlertDialog` (e.g., for deactivation warnings).
- **Form Popovers:** `showModalBottomSheet` for adding products/customers on the fly.
