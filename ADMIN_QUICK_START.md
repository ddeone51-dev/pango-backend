# 🚀 Pango Admin Panel - Quick Start

## ⚡ **Get Started in 3 Steps**

### **Step 1: Create Admin User**
```bash
cd backend
node scripts/createAdmin.js
```
Follow the prompts to create your admin account.

### **Step 2: Start Backend**
```bash
npm run dev
```
Server will start on `http://localhost:3000`

### **Step 3: Access Admin Panel**
Open your browser:
```
http://localhost:3000/admin
```
Login with your admin credentials!

---

## 🎯 **Quick Access**

| Feature | URL |
|---------|-----|
| **Admin Panel** | `http://localhost:3000/admin` |
| **API Docs** | `http://localhost:3000/api-docs` (if configured) |
| **Health Check** | `http://localhost:3000/health` |

---

## 📊 **Features at a Glance**

### **Dashboard**
- Real-time stats (users, properties, bookings, revenue)
- Interactive charts
- Recent activity feed
- Growth indicators

### **User Management**
- View all users (guests, hosts, admins)
- Search & filter
- Edit roles
- Delete accounts
- View user details & activity

### **Property Management**
- View all listings
- Approve/Reject pending properties
- Search & filter
- Delete listings
- Review property details

### **Booking Management**
- View all bookings
- Filter by status & payment
- Confirm/Cancel bookings
- Track revenue
- Monitor guest activity

### **Reports**
- Financial reports
- User engagement analytics
- Property performance metrics
- Export to CSV

### **Settings**
- Notification preferences
- Security settings
- System configuration

---

## 🔑 **Default Test Credentials**

After running `createAdmin.js`, you'll have:
- Email: Your entered email
- Password: Your entered password
- Role: admin

---

## 🎨 **Admin Panel Features**

✅ **Responsive Design** - Works on desktop, tablet, mobile
✅ **Real-time Analytics** - Live dashboard with charts
✅ **Secure Authentication** - JWT-based with role protection
✅ **Modern UI** - Clean, professional interface
✅ **Search & Filter** - Find anything quickly
✅ **Pagination** - Handle large datasets
✅ **Export Reports** - Download data as CSV
✅ **Activity Tracking** - Monitor all actions

---

## 📱 **Mobile Access**

The admin panel is fully responsive:
- Hamburger menu on mobile
- Touch-friendly buttons
- Scrollable tables
- Optimized layouts

---

## 🔐 **Security**

- ✅ Admin-only access (role-based)
- ✅ JWT token authentication
- ✅ Secure password hashing
- ✅ Session management
- ✅ Protected API endpoints

---

## 🛠️ **Troubleshooting**

### **Can't login?**
1. Check backend is running (`npm run dev`)
2. Verify MongoDB is connected
3. Ensure admin user exists (run `createAdmin.js`)
4. Check browser console for errors

### **Dashboard empty?**
1. Verify backend server is running
2. Check MongoDB has data
3. Open browser DevTools → Network tab
4. Look for failed API calls

### **Charts not showing?**
1. Check Chart.js is loaded
2. Verify data from API
3. Check browser console

---

## 📚 **File Structure**

```
backend/
├── public/
│   └── admin/
│       ├── index.html         # Admin panel UI
│       ├── css/
│       │   └── style.css      # Styles
│       └── js/
│           └── app.js         # Functionality
├── src/
│   ├── controllers/
│   │   └── adminController.js # Admin logic
│   ├── middleware/
│   │   └── adminAuth.js       # Auth protection
│   └── routes/
│       └── adminRoutes.js     # Admin routes
└── scripts/
    └── createAdmin.js         # Create admin user
```

---

## 🎯 **Common Tasks**

### **Create New Admin:**
```bash
node scripts/createAdmin.js
```

### **Approve a Listing:**
1. Go to Properties page
2. Find pending listing
3. Click ✓ (approve) button

### **Delete a User:**
1. Go to Users page
2. Find user
3. Click 🗑️ (delete) button
4. Confirm deletion

### **Generate Report:**
1. Go to Reports page
2. Select report type
3. Click "Generate"
4. Click "Export as CSV" to download

### **Change Settings:**
1. Go to Settings page
2. Adjust preferences
3. Click "Save Settings"

---

## 📊 **Dashboard Stats Explained**

| Metric | Description |
|--------|-------------|
| **Total Users** | All registered users (guests + hosts + admins) |
| **Properties** | Total listings (active + pending + rejected) |
| **Bookings** | All bookings ever made |
| **Revenue** | Total amount from paid bookings |
| **Growth %** | Percentage increase this month vs last month |

---

## 🔗 **API Endpoints**

All admin endpoints require authentication:

```
Authorization: Bearer <your_jwt_token>
```

### **Dashboard:**
- `GET /api/v1/admin/dashboard/stats` - Get statistics
- `GET /api/v1/admin/dashboard/charts?period=30days` - Get chart data

### **Users:**
- `GET /api/v1/admin/users?page=1&limit=10` - List users
- `GET /api/v1/admin/users/:id` - Get user details
- `PUT /api/v1/admin/users/:id` - Update user
- `DELETE /api/v1/admin/users/:id` - Delete user

### **Properties:**
- `GET /api/v1/admin/listings?page=1&limit=10` - List properties
- `PUT /api/v1/admin/listings/:id/status` - Approve/Reject
- `DELETE /api/v1/admin/listings/:id` - Delete property

### **Bookings:**
- `GET /api/v1/admin/bookings?page=1&limit=10` - List bookings
- `PUT /api/v1/admin/bookings/:id/status` - Update status

### **Reports:**
- `GET /api/v1/admin/reports?type=financial&startDate=2024-01-01&endDate=2024-12-31`

---

## 🎊 **Tips & Best Practices**

1. **Regular Monitoring**: Check dashboard daily
2. **Prompt Approvals**: Review pending listings quickly
3. **User Support**: Respond to booking issues
4. **Data Export**: Download reports monthly
5. **Security**: Change admin password regularly
6. **Backups**: Export important data
7. **Activity Review**: Monitor suspicious actions

---

## 🆘 **Need Help?**

- 📖 Full Guide: `ADMIN_PANEL_GUIDE.md`
- 🐛 Issues: Check browser console
- 💬 Contact: admin@pango.co.tz

---

**You're all set! Access your admin panel and start managing Pango!** 🚀

**URL:** http://localhost:3000/admin







