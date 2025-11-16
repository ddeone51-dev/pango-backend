# 🎛️ Complete Admin Dashboard Guide - Everything You Can See

## 📍 Access Your Admin Dashboard

**URL:** `http://localhost:3000/admin` (development)  
**URL:** `https://your-domain.com/admin` (production)

**Login:**
- Email: `admin@pango.co.tz`
- Password: `AdminPassword123!` (or your custom password)

---

## 📊 Dashboard Overview

Your admin dashboard has **12 main sections**. Here's everything you can see:

---

## 1️⃣ **DASHBOARD** (Home Page)
*Location: Sidebar → Dashboard*

### 📈 Real-Time Statistics Cards
Display key metrics at a glance:

| Metric | Shows | Icon |
|--------|-------|------|
| **Total Users** | Total registered users + % growth | 👥 |
| **Properties** | Total listings + active count | 🏢 |
| **Bookings** | Total bookings + % growth | 📅 |
| **Revenue** | Total platform revenue + % growth | 💰 |

### 📊 Interactive Charts (Selectable Time Periods)

1. **Users Over Time Chart** 📈
   - Line graph showing user registration trends
   - Filter options:
     - Last 7 Days
     - Last 30 Days ✓ (default)
     - Last 6 Months
     - Last Year

2. **Revenue Over Time Chart** 💹
   - Bar graph showing platform revenue trends
   - Same time period filters as Users chart

### 🔔 Recent Activity
Real-time updates showing:

| Section | What's Shown |
|---------|-------------|
| **Recent Users** | Latest user registrations |
| **Recent Bookings** | Latest booking activity |

---

## 2️⃣ **USERS** (User Management)
*Location: Sidebar → Content Management → Users*

### 🔍 Features
- **View all users** (guests, hosts, admins)
- **Search** by name, email, or phone
- **Filter by role:**
  - All Roles
  - Guests 👤
  - Hosts 🏠
  - Admins 🛡️

### 📋 User Table Shows:
| Column | Information |
|--------|------------|
| ID | User unique identifier |
| Name | Full name |
| Email | Email address |
| Phone | Phone number |
| Role | guest/host/admin |
| Status | Active/Inactive |
| Joined | Registration date |
| Actions | View/Edit/Delete buttons |

### ⚙️ User Actions:
- ✏️ **Edit** - Change user role or status
- 👁️ **View** - See detailed user profile + payout info
- 🗑️ **Delete** - Remove user account
- 📄 **Pagination** - Navigate through users

---

## 3️⃣ **HOSTS** (Host Approvals & Management)
*Location: Sidebar → Content Management → Hosts*

### 🎯 Purpose
Review and manage host onboarding requests

### 🔍 Features
- **Search** hosts by name, email, or phone
- **Filter by status:**
  - All Status
  - ⏳ Pending - Awaiting approval
  - ✅ Approved - Active hosts
  - ❌ Rejected - Rejected applications

### 📋 Hosts Table Shows:
| Column | Information |
|--------|------------|
| ID | Host unique identifier |
| Name | Host full name |
| Email | Host email |
| Phone | Host phone |
| Status | pending/approved/rejected |
| Requested | Application date |
| Actions | Approve/Reject/View buttons |

### ⚙️ Host Actions:
- ✅ **Approve** - Activate host account
- ❌ **Reject** - Reject application (sends notification)
- 👁️ **View Details** - See complete host profile + **payout settings**
- 📊 **View Analytics** - See host's bookings and revenue

---

## 4️⃣ **PROPERTIES** (Listing Management)
*Location: Sidebar → Content Management → Properties*

### 🏠 Purpose
Manage and moderate all property listings

### 🔍 Features
- **Search** properties by title or location
- **Filter by status:**
  - All Status
  - ✅ Approved - Visible to guests
  - ⏳ Pending - Awaiting review
  - ❌ Rejected - Hidden listings

### 📋 Properties Table Shows:
| Column | Information |
|--------|------------|
| ID | Listing unique ID |
| Title | Property name |
| Host | Host name |
| Location | City/District |
| Price/Night | Nightly rate |
| Status | approved/pending/rejected |
| Created | Creation date |
| Actions | Edit/Delete/View buttons |

### ⚙️ Property Actions:
- ✅ **Approve** - Make listing visible to guests
- ❌ **Reject** - Hide inappropriate listings
- 🗑️ **Delete** - Remove listing permanently
- 👁️ **View** - See full property details
- 📊 **View Bookings** - See bookings for this property

---

## 5️⃣ **MODERATION** (Content Moderation)
*Location: Sidebar → Content Management → Moderation*

### 🚨 Purpose
Manage flagged/reported content

### 📊 Moderation Statistics:
| Stat | Meaning |
|------|---------|
| **Total Flagged** | Total items reported for violations |
| **Pending Review** | Items awaiting admin action |
| **Actions Taken** | Items where action was taken |
| **Dismissed** | False reports or resolved issues |

### 🔍 Features
- **Filter by status:**
  - ⏳ Pending - Awaiting review
  - 🔍 Under Review - Being investigated
  - ✅ Action Taken - Issue resolved
  - ❌ Dismissed - Not a violation

- **Filter by content type:**
  - Listings 🏠
  - Reviews ⭐
  - User Profiles 👤
  - Messages 💬

### 📋 Moderation Table Shows:
| Column | Information |
|--------|------------|
| ID | Report ID |
| Content Type | Type of flagged content |
| Reason | Why it was reported |
| Reported By | Who reported it |
| Priority | High/Medium/Low |
| Status | Current status |
| Created | Report date |
| Actions | Review/Action buttons |

### ⚙️ Moderation Actions:
- 🔍 **Review** - See flagged content
- ✅ **Approve** - Content is OK
- ❌ **Remove** - Delete inappropriate content
- ⛔ **Suspend** - Temporarily block content
- 🗑️ **Delete User** - Remove account if severe

---

## 6️⃣ **BOOKINGS** (Booking Management)
*Location: Sidebar → Operations → Bookings*

### 📅 Purpose
Manage all platform bookings

### 📊 Booking Statistics:
| Stat | Shows |
|------|-------|
| **Total Bookings** | All-time bookings |
| **Completed** | Finished bookings |
| **Pending** | Awaiting confirmation |
| **Cancelled** | Cancelled bookings |

### 🔍 Features
- **Search** by booking ID, guest name, or property
- **Filter by booking status:**
  - ⏳ Pending - Awaiting confirmation
  - ✅ Confirmed - Confirmed bookings
  - 🏨 In Progress - Currently happening
  - ✓ Completed - Finished bookings
  - ❌ Cancelled - Cancelled bookings

- **Filter by payment status:**
  - ⏳ Pending - Awaiting payment
  - ✅ Paid - Payment completed
  - ❌ Failed - Payment failed
  - 💸 Refunded - Refunded bookings

### 📋 Bookings Table Shows:
| Column | Information |
|--------|------------|
| ID | Booking ID |
| Guest | Guest name |
| Property | Property name |
| Check-in | Check-in date |
| Check-out | Check-out date |
| Status | Booking status |
| Payment | Payment status |
| Amount | Total amount |
| Actions | Edit/View/Cancel buttons |

### ⚙️ Booking Actions:
- 👁️ **View** - See booking details
- ✅ **Confirm** - Confirm booking
- ❌ **Cancel** - Cancel booking
- 💳 **View Payment** - See payment details
- 📧 **Send Message** - Notify guest/host

---

## 7️⃣ **PAYMENTS** (Payment Transactions)
*Location: Sidebar → Operations → Payments*

### 💳 Purpose
Monitor all platform payments and transactions

### 📊 Payment Statistics:
| Stat | Shows |
|------|-------|
| **Total Amount** | All-time payment volume |
| **Completed Amount** | Successfully paid |
| **Pending Amount** | Awaiting payment |
| **Failed Amount** | Failed transactions |

### 🔍 Features
- **Search** by email, phone, or transaction reference
- **Filter by status:**
  - ✅ Completed - Successful payments
  - ⏳ Pending - Awaiting payment
  - ❌ Failed - Failed transactions
  - 💸 Refunded - Refunded payments

- **Filter by payment method:**
  - 📱 M-Pesa
  - 💳 Card/Stripe
  - 🏦 PesaPal
  - 💰 Other methods

### 📋 Payments Table Shows:
| Column | Information |
|--------|------------|
| ID | Transaction ID |
| Source | Payment source |
| Status | Payment status |
| Amount | Transaction amount |
| Currency | Currency (TZS, USD, etc) |
| Method | Payment method |
| Customer | Customer name/email |
| Booking | Booking ID |
| Created | Transaction date |
| Actions | View/Export buttons |

### 📥 Payment Actions:
- 👁️ **View** - See payment details
- 📊 **Export to CSV** - Download payment data
- 📄 **Export to PDF** - Generate PDF report
- 🔍 **View Disputes** - Check if disputed

---

## 8️⃣ **DISPUTES** (Dispute Resolution)
*Location: Sidebar → Operations → Disputes*

### ⚖️ Purpose
Manage booking disputes and complaints

### 📊 Dispute Statistics:
| Stat | Shows |
|------|-------|
| **Total Disputes** | All reported disputes |
| **Open** | Unresolved disputes |
| **In Progress** | Being investigated |
| **Resolved** | Settled disputes |

### 🔍 Features
- **Search** disputes by ID or user
- **Filter by priority:** High, Medium, Low
- **Filter by status:** Open, In Progress, Resolved

### 📋 Disputes Table Shows:
| Column | Information |
|--------|------------|
| ID | Dispute ID |
| Booking | Booking involved |
| Type | Type of dispute |
| Raised By | Guest or Host |
| Priority | High/Medium/Low |
| Status | Current status |
| Date | Date reported |
| Actions | Investigate/Resolve buttons |

### ⚙️ Dispute Actions:
- 👁️ **View** - See dispute details
- 📝 **Add Notes** - Document investigation
- ✅ **Resolve** - Mark as resolved
- 💰 **Issue Refund** - Process refund
- 📧 **Notify Parties** - Inform involved parties

---

## 9️⃣ **SUPPORT TICKETS** (Customer Support)
*Location: Sidebar → Support & Communication → Support Tickets*

### 🎧 Purpose
Manage customer support requests

### 📊 Support Statistics:
| Stat | Shows |
|------|-------|
| **Total Tickets** | All support requests |
| **Open** | Unresolved tickets |
| **In Progress** | Being worked on |
| **Closed** | Resolved tickets |

### 🔍 Features
- **Search** by ticket ID or customer name
- **Filter by priority:** Critical, High, Medium, Low
- **Filter by status:** Open, In Progress, Closed

### 📋 Tickets Table Shows:
| Column | Information |
|--------|------------|
| ID | Ticket ID |
| Title | Issue title |
| Category | Support category |
| Priority | Issue priority |
| Status | Current status |
| Created | Submission date |
| Actions | View/Respond buttons |

### ⚙️ Ticket Actions:
- 👁️ **View** - See full ticket details
- 💬 **Reply** - Send response to user
- ✅ **Resolve** - Mark ticket as resolved
- 🏷️ **Assign** - Assign to team member
- 📌 **Escalate** - Increase priority

---

## 🔟 **NOTIFICATIONS** (Broadcast Messages)
*Location: Sidebar → Support & Communication → Notifications*

### 🔔 Purpose
Send platform-wide notifications to users

### ✨ Features
- **Compose messages** for all users
- **Target specific user groups:**
  - All Users 👥
  - Guests Only 👤
  - Hosts Only 🏠
  - Admins Only 🛡️

- **Schedule notifications** for future sending
- **Track delivery** and read rates

### 📋 Notification Actions:
- ✍️ **Compose** - Write new notification
- 📤 **Send** - Broadcast message
- 📊 **View Analytics** - See delivery stats
- 📋 **History** - See past notifications

---

## 1️⃣1️⃣ **PROMOTIONS** (Marketing)
*Location: Sidebar → Marketing → Promotions*

### 🎁 Purpose
Create and manage promotional offers

### 🛠️ Features
- **Create discount codes**
- **Set discount percentages** or fixed amounts
- **Set expiration dates**
- **Track usage** and redemption
- **Apply to specific properties** or platform-wide

### 📋 Promotions Table Shows:
| Column | Information |
|--------|------------|
| Code | Promo code |
| Description | What's offered |
| Discount | % or amount |
| Expiry | Expiration date |
| Uses | Times used |
| Status | Active/Expired |
| Actions | Edit/Delete buttons |

### ⚙️ Promotion Actions:
- ✏️ **Edit** - Modify promotion
- 🗑️ **Delete** - Remove promotion
- 📊 **View Analytics** - See usage stats
- 📋 **View Users** - See who used it

---

## 1️⃣2️⃣ **ANALYTICS & REPORTS**
*Location: Sidebar → Analytics & Reports*

### 📊 **Analytics Section**

**Real-time platform metrics:**
- Active users online
- Current bookings in progress
- Recent payments
- System health status

**Advanced analytics:**
- User demographics
- Geographic distribution
- Revenue trends
- Booking patterns

---

## 1️⃣3️⃣ **REPORTS** (Detailed Reporting)
*Location: Sidebar → Analytics & Reports → Reports*

### 📄 Report Types:

#### 1. **Financial Report** 💰
```
Shows:
- Total Revenue (all-time and period)
- Total Bookings
- Average Booking Value
- Revenue by Property
- Revenue by Payment Method
- Monthly Revenue Trends
- Tax Summary (platform fees, host payouts)
```

#### 2. **User Engagement Report** 👥
```
Shows:
- New User Registrations
- Active Users (monthly, weekly, daily)
- User Retention Rate
- Booking Frequency
- User Demographics
- Geographic Distribution
- Sign-up Sources
```

#### 3. **Property Performance Report** 🏠
```
Shows:
- Top Performing Properties
- Booking Count per Property
- Revenue per Property
- Average Rating per Property
- Occupancy Rate per Property
- Low-Performing Properties
- Property Category Performance
```

### 📥 Report Features:
- 📅 **Select date ranges** (custom periods)
- 📊 **View as charts** (visual representation)
- 📋 **View as tables** (detailed data)
- 📥 **Export to CSV** (for Excel)
- 📄 **Export to PDF** (for printing/sharing)

---

## 1️⃣4️⃣ **AUDIT LOGS** (System Monitoring)
*Location: Sidebar → Analytics & Reports → Audit Logs*

### 🔍 Purpose
Track all admin actions for security and compliance

### 📋 Audit Log Shows:
| Column | Information |
|--------|------------|
| Action | What was done |
| Admin | Who did it |
| Resource | What was affected |
| Before | Previous value |
| After | New value |
| Timestamp | When it happened |
| IP Address | Admin's IP |
| Status | Success/Failed |

### 🔍 Features:
- **Search** by admin name or action type
- **Filter by action:** Create, Update, Delete, Approve, Reject
- **Filter by resource:** User, Listing, Booking, etc.
- **Filter by date range**

---

## 1️⃣5️⃣ **SETTINGS** (System Configuration)
*Location: Sidebar → System → Settings*

### ⚙️ Purpose
Configure admin panel and system settings

### 🔧 Settings Categories:

#### **1. General Settings**
- Platform name
- Support email
- Support phone
- Website URL
- Company address

#### **2. Email Configuration**
- Email notifications for new bookings
- Email alerts for issues
- Booking reminders
- Payment notifications
- Support ticket updates

#### **3. SMS Configuration**
- SMS notifications enabled/disabled
- Alert thresholds
- Priority contacts
- Message templates

#### **4. Security Settings**
- Session timeout duration
- Password requirements
- Two-factor authentication
- IP whitelist
- Admin activity logging

#### **5. Approval Settings**
- Auto-approve listings (yes/no)
- Manual approval required
- Listing review time limit
- Host verification requirements

#### **6. Payment Settings**
- Payment methods enabled
- Transaction fees
- Refund policies
- Payout frequency
- Minimum payout amount

#### **7. Display Settings**
- Items per page (tables)
- Date format preference
- Currency display
- Language preference

#### **8. Notification Preferences**
- Alert types (critical, warning, info)
- Notification frequency
- Notification channels
- Do Not Disturb hours

---

## 🎯 Quick Navigation Reference

| Section | Icon | Purpose |
|---------|------|---------|
| Dashboard | 📊 | Real-time overview |
| Users | 👥 | Manage all users |
| Hosts | 🏠 | Approve/manage hosts |
| Properties | 🏢 | Manage listings |
| Moderation | 🚩 | Review flagged content |
| Bookings | 📅 | Manage bookings |
| Payments | 💳 | Monitor transactions |
| Disputes | ⚖️ | Resolve disputes |
| Support | 🎧 | Customer support |
| Notifications | 🔔 | Send messages |
| Promotions | 🎁 | Manage discounts |
| Analytics | 📈 | View trends |
| Reports | 📄 | Generate reports |
| Audit Logs | 📋 | Track actions |
| Settings | ⚙️ | Configure system |

---

## 🔐 Security Features

✅ **JWT Authentication** - Secure token-based access  
✅ **Admin-Only Access** - Role-based access control  
✅ **Action Logging** - All admin actions tracked  
✅ **Session Timeout** - Auto-logout after inactivity  
✅ **Password Hashing** - Bcrypt encryption  
✅ **HTTPS** - Encrypted communication  
✅ **Audit Trail** - Complete activity history  

---

## 💡 Pro Tips

1. **Use Search** - Quickly find users, properties, bookings
2. **Use Filters** - Narrow down results by status, type, date
3. **Batch Actions** - Select multiple items for bulk operations
4. **Export Data** - Download data for external analysis
5. **Set Alerts** - Configure notifications for important events
6. **Review Regularly** - Check analytics weekly for trends
7. **Audit Logs** - Monitor admin activities for security
8. **Backup Reports** - Export reports regularly

---

## 🆘 Common Tasks

### **Approve a New Host**
1. Go to Hosts section
2. Filter by "Pending" status
3. Review host information
4. Click "Approve" button

### **Review Flagged Content**
1. Go to Moderation section
2. Filter by "Pending" status
3. Review the flagged content
4. Click "Approve" or "Remove"

### **Check Platform Revenue**
1. Go to Dashboard
2. View "Total Revenue" card
3. Go to Reports → Financial Report
4. Select date range and export

### **Find a Specific Booking**
1. Go to Bookings section
2. Use search box with booking ID or guest name
3. Filter by status if needed
4. Click to view full details

### **Send Announcement to All Users**
1. Go to Notifications
2. Click "Compose New"
3. Write message
4. Select target: "All Users"
5. Click "Send Now"

### **Generate Monthly Report**
1. Go to Reports section
2. Select "Financial Report"
3. Set date range (1st to last day of month)
4. Click "Export to PDF"

---

## ✅ Checklist - What You Can Do

✅ View real-time platform statistics  
✅ Manage users (view, edit, delete)  
✅ Approve/reject host applications  
✅ Manage property listings  
✅ Moderate flagged content  
✅ Track all bookings  
✅ Monitor payments  
✅ Resolve disputes  
✅ Handle support tickets  
✅ Send notifications  
✅ Create promotions  
✅ View analytics  
✅ Generate reports  
✅ Track admin actions  
✅ Configure system settings  

---

## 🎉 You Have Full Platform Control!

Your admin dashboard gives you **complete visibility** into every aspect of the Pango platform. Use it to:
- Monitor platform health 📊
- Manage users and hosts 👥
- Approve content 📋
- Track revenue 💰
- Support customers 🎧
- Make data-driven decisions 📈

**Access your admin panel now at:** `http://localhost:3000/admin`

---


