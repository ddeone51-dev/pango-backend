# Content Moderation System - Complete Guide

## 📋 Overview

Your Pango app now has a **complete content moderation system** that allows users to report problematic content and admins to review and take action.

---

## 🔄 How It Works

### **For Users (Mobile App):**

#### **Reporting Content**

1. **Where to Report:**
   - When viewing a listing, tap the **flag icon** (🚩) in the top-right corner
   - *(Can be extended to reviews, user profiles, messages in future)*

2. **Report Process:**
   - Select a reason from the list:
     - Inappropriate Content
     - Spam
     - Fraud or Scam
     - False Information
     - Harassment
     - Violence
     - Hate Speech
     - Copyright Violation
     - Privacy Violation
     - Other
   
   - Provide additional details (required)
   - Submit report
   - Get confirmation message

3. **What Happens Next:**
   - Report is sent to admin panel
   - Flagged content goes into moderation queue
   - Admin reviews and takes action
   - You may receive updates on serious cases

---

### **For Admins (Admin Panel):**

#### **Reviewing Reports**

1. **Access Moderation:**
   - Login to admin panel: http://localhost:3000/admin
   - Click **"Moderation"** in sidebar
   - See all flagged content

2. **Review Details:**
   - Content type (listing, review, etc.)
   - Reporter's reason
   - Additional description
   - Evidence/screenshots
   - Priority level
   - Status (pending, under review, etc.)

3. **Take Action:**
   Choose one of these actions:
   - **Warning Sent** - Send warning to content owner
   - **Content Removed** - Remove the flagged content
   - **User Suspended** - Suspend user for 30 days
   - **Account Terminated** - Permanently ban user
   - **Dismiss** - No violation found

4. **Add Notes:**
   - Document your decision
   - Explain reasoning
   - Track for future reference

---

## 🛠️ Technical Implementation

### **Backend API**

**User Report Endpoint:**
```
POST /api/v1/moderation/report
Headers: Authorization: Bearer <token>

Body:
{
  "contentType": "listing",
  "contentId": "listing_id_here",
  "contentOwner": "host_user_id",
  "reason": "fraud",
  "description": "This listing uses fake photos from another website",
  "evidence": ["url_to_screenshot"]  // optional
}
```

**Admin Review Endpoints:**
```
GET  /api/v1/admin/moderation/flagged              - List all flagged content
PUT  /api/v1/admin/moderation/flagged/:id/review   - Review and take action
GET  /api/v1/admin/moderation/reviews              - List reviews for moderation
PUT  /api/v1/admin/moderation/reviews/:id/toggle-visibility  - Hide/show review
DELETE /api/v1/admin/moderation/reviews/:id        - Delete review
GET  /api/v1/admin/moderation/stats                - Moderation statistics
```

---

### **Mobile App Components**

**Files Created:**

1. **`mobile/lib/core/services/report_service.dart`**
   - Service to handle reporting API calls
   - Contains all report reasons
   - Validates report data

2. **`mobile/lib/core/widgets/report_bottom_sheet.dart`**
   - Beautiful bottom sheet UI for reporting
   - Reason selection with radio buttons
   - Description text field
   - Submit button with loading state

3. **Updated: `mobile/lib/features/listing/listing_detail_screen.dart`**
   - Added flag button (🚩) in app bar
   - Integrated report bottom sheet
   - Passes listing details to report

---

### **Database Model**

**FlaggedContent Schema:**
```javascript
{
  contentType: String,      // 'listing', 'review', 'user_profile', 'message'
  contentId: ObjectId,       // ID of the content
  contentOwner: ObjectId,    // User who owns the content
  reportedBy: ObjectId,      // User who reported
  reason: String,            // Violation reason
  description: String,       // Detailed explanation
  evidence: [String],        // URLs to screenshots
  priority: String,          // 'low', 'medium', 'high', 'critical'
  status: String,            // 'pending', 'under_review', 'action_taken', 'dismissed'
  reviewedBy: ObjectId,      // Admin who reviewed
  action: String,            // Action taken
  reviewNotes: String,       // Admin notes
  createdAt: Date,
  reviewedAt: Date
}
```

---

## 📊 Report Reasons Explained

| Reason | Description | Examples |
|--------|-------------|----------|
| **Inappropriate Content** | Offensive material | Adult content, profanity |
| **Spam** | Repetitive content | Same listing posted multiple times |
| **Fraud/Scam** | Deceptive practices | Fake listings, phishing |
| **False Information** | Misleading details | Wrong address, fake amenities |
| **Harassment** | Abusive behavior | Threatening messages |
| **Violence** | Violent content | Threats, dangerous activity |
| **Hate Speech** | Discriminatory content | Racist, sexist content |
| **Copyright** | Stolen content | Unauthorized photos |
| **Privacy** | Privacy violations | Doxxing, personal info |
| **Other** | Other issues | Anything not listed |

---

## 🎯 Features

### **User Protection:**
✅ Anonymous reporting  
✅ Easy-to-use interface  
✅ Multiple reason options  
✅ Detailed description field  
✅ Confirmation feedback  
✅ Duplicate report prevention  

### **Admin Tools:**
✅ Centralized moderation queue  
✅ Priority sorting  
✅ Multiple action options  
✅ Decision documentation  
✅ Audit trail  
✅ Statistics & analytics  

### **System Features:**
✅ Auto-prioritization (fraud/violence = high priority)  
✅ Duplicate detection  
✅ Email notifications  
✅ Action logging  
✅ Status tracking  
✅ Evidence attachment  

---

## 🚀 How to Use

### **As a User:**

1. **Open the mobile app**
2. **Browse to any property**
3. **Tap the flag icon** (🚩) in top-right
4. **Select a reason** from the list
5. **Describe the issue** in detail
6. **Submit report**
7. **Done!** Admins will review

### **As an Admin:**

1. **Go to admin panel:** http://localhost:3000/admin
2. **Click "Moderation"** in sidebar
3. **See all pending reports**
4. **Click on a report** to review details
5. **Choose action:**
   - Warn user
   - Remove content
   - Suspend account
   - Dismiss report
6. **Add notes** explaining your decision
7. **Submit** - Action is executed automatically

---

## 📈 Statistics Available

The moderation section tracks:
- Total reports received
- Reports by content type
- Reports by reason
- Reports by status
- Average response time
- Actions taken breakdown
- Top reporters
- Repeat offenders

---

## ⚖️ Best Practices

### **For Effective Moderation:**

1. **Review within 24-48 hours** - Quick response maintains trust
2. **Read all details** - Don't rush decisions
3. **Check evidence** - Look at screenshots/proof
4. **Document decisions** - Write clear notes
5. **Be consistent** - Apply rules equally
6. **Escalate when needed** - Flag serious issues
7. **Follow up** - Monitor repeat offenders

### **For Users:**

1. **Report genuine issues** - Don't abuse the system
2. **Provide details** - Help admins understand
3. **Be specific** - Clear descriptions help
4. **Include evidence** - Screenshots are valuable
5. **Don't spam** - One report per issue

---

## 🔒 Privacy & Security

- ✅ Reports are **anonymous** to content owners
- ✅ Reporter identity **protected**
- ✅ Admin notes are **private**
- ✅ All actions **logged** for audit
- ✅ Duplicate reports **prevented**
- ✅ Data **encrypted** in transit

---

## 🎨 UI Features

**Mobile App:**
- Beautiful bottom sheet design
- Radio button selection
- Multi-line description field
- Loading states
- Success/error messages
- Smooth animations

**Admin Panel:**
- Sortable table
- Priority badges
- Status indicators
- Action buttons
- Modal windows
- Filtering options

---

## 📝 Example Workflow

### **Scenario: Fake Listing**

**User Side:**
1. User views listing with suspicious photos
2. Taps flag icon
3. Selects "Fraud or Scam"
4. Writes: "Photos are stolen from Booking.com"
5. Submits report

**Admin Side:**
1. Report appears in moderation queue (HIGH priority)
2. Admin reviews listing
3. Verifies photos are indeed stolen
4. Selects "Content Removed"
5. Adds note: "Confirmed stolen photos via reverse image search"
6. Submits action

**System Actions:**
1. Listing is removed immediately
2. Host receives notification
3. Action logged in audit logs
4. Email sent to host
5. Reporter notified of resolution

---

## 🔧 Configuration

**Priority Levels:**
- `fraud` or `violence` reports = **HIGH** priority
- All other reports = **MEDIUM** priority
- Admins can manually adjust priority

**Actions & Consequences:**
- **Warning** → Email notification sent
- **Content Removed** → Content hidden from platform
- **User Suspended** → 30-day account suspension
- **Account Terminated** → Permanent ban

---

## ✅ Current Status

**✅ Implemented:**
- Backend API endpoints
- Database models
- Admin review interface
- Mobile report button
- Report bottom sheet
- API integration
- Duplicate prevention
- Priority system
- Action logging

**🎯 Ready to Use:**
- Users can report listings now
- Admins can review and take action
- All features are functional

**🔄 Can Be Extended To:**
- Reviews (report fake/spam reviews)
- User profiles (report fake accounts)
- Messages (report harassment)
- Images (report inappropriate photos)

---

## 📞 Summary

You now have a **complete, production-ready content moderation system** that:

✅ Allows users to easily report problems  
✅ Gives admins powerful review tools  
✅ Maintains platform quality and safety  
✅ Protects users from fraud and abuse  
✅ Provides full audit trail  
✅ Scales with your platform  

**The report button (🚩) is now visible on every listing detail page in your mobile app!**

---

**Created:** October 11, 2025  
**Version:** 1.0.0  
**Status:** Fully Functional ✅






