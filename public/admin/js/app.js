// ==================================
// Homie Admin Panel - JavaScript
// ==================================

const API_BASE_URL = `${window.location.origin}/api/v1`;
let authToken = localStorage.getItem('adminToken') || '';
let currentUser = null;
let charts = {};

// ==================================
// Utility Functions
// ==================================

function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    toast.classList.add('show');
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

function showLoading() {
    document.getElementById('loadingSpinner').style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loadingSpinner').style.display = 'none';
}

async function apiCall(endpoint, options = {}) {
    try {
        const headers = {
            'Content-Type': 'application/json',
            ...(authToken && { 'Authorization': `Bearer ${authToken}` }),
            ...options.headers
        };

        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || 'Request failed');
        }

        return data;
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-GB') + ' ' + date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
}

function formatCurrency(amount) {
    if (amount === undefined || amount === null) return 'N/A';
    return 'TZS ' + amount.toLocaleString();
}

function getInitials(firstName, lastName) {
    return (firstName?.charAt(0) || '') + (lastName?.charAt(0) || '');
}

// ==================================
// Authentication
// ==================================

document.addEventListener('DOMContentLoaded', () => {
    if (authToken) {
        checkAuth();
    } else {
        showLoginScreen();
    }

    // Login form handler
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Logout button handler
    document.getElementById('logoutBtn').addEventListener('click', handleLogout);
    
    // Navigation handlers
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', handleNavigation);
    });

    // Sidebar toggle for mobile
    document.getElementById('sidebarToggle')?.addEventListener('click', toggleSidebar);
});

function showLoginScreen() {
    document.getElementById('loginScreen').style.display = 'flex';
    document.getElementById('adminPanel').style.display = 'none';
}

function showAdminPanel() {
    document.getElementById('loginScreen').style.display = 'none';
    document.getElementById('adminPanel').style.display = 'flex';
    loadDashboard();
}

async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errorDiv = document.getElementById('loginError');

    try {
        showLoading();
        errorDiv.style.display = 'none';

        const response = await apiCall('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });

        console.log('Login response:', response);
        console.log('User role:', response.data.user.role);

        if (response.data.user.role !== 'admin') {
            throw new Error('Access denied. Admin privileges required. Your role: ' + response.data.user.role);
        }

        authToken = response.data.token;
        currentUser = response.data.user;
        localStorage.setItem('adminToken', authToken);
        
        hideLoading();
        showToast('Login successful!', 'success');
        showAdminPanel();
        
    } catch (error) {
        hideLoading();
        errorDiv.textContent = error.message || 'Login failed. Please check your credentials.';
        errorDiv.style.display = 'block';
    }
}

async function checkAuth() {
    try {
        const response = await apiCall('/auth/me');
        
        if (response.data.role === 'admin') {
            currentUser = response.data;
            showAdminPanel();
        } else {
            throw new Error('Not authorized');
        }
    } catch (error) {
        localStorage.removeItem('adminToken');
        authToken = '';
        showLoginScreen();
    }
}

function handleLogout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('adminToken');
        authToken = '';
        currentUser = null;
        showLoginScreen();
        showToast('Logged out successfully', 'info');
    }
}

// ==================================
// Navigation
// ==================================

function handleNavigation(e) {
    e.preventDefault();
    
    const page = e.currentTarget.dataset.page;
    
    // Update active nav link
    document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
    e.currentTarget.classList.add('active');
    
    // Update active page
    document.querySelectorAll('.page-content').forEach(content => content.classList.remove('active'));
    document.getElementById(`${page}Page`).classList.add('active');
    
    // Update page title
    const pageTitle = e.currentTarget.querySelector('span').textContent;
    document.getElementById('pageTitle').textContent = pageTitle;
    
    // Load page data
    switch(page) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'users':
            loadUsers();
            break;
        case 'listings':
            loadListings();
            break;
        case 'moderation':
            loadModeration();
            break;
        case 'bookings':
            loadBookings();
            break;
        case 'payments':
            loadPayments();
            break;
        case 'disputes':
            loadDisputes();
            break;
        case 'support':
            loadSupportTickets();
            break;
        case 'notifications':
            loadNotifications();
            break;
        case 'promotions':
            loadPromotions();
            break;
        case 'analytics':
            loadAnalytics();
            break;
        case 'audit-logs':
            loadAuditLogs();
            break;
        case 'reports':
            // Reports page is static, no loading needed
            break;
        case 'settings':
            loadSettings();
            break;
    }
}

function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('active');
}

// ==================================
// Dashboard
// ==================================

async function loadDashboard() {
    try {
        showLoading();
        
        const [stats, chartData] = await Promise.all([
            apiCall('/admin/dashboard/stats'),
            apiCall('/admin/dashboard/charts?period=30days')
        ]);
        
        updateDashboardStats(stats.data);
        updateCharts(chartData.data);
        updateRecentActivity(stats.data);
        
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to load dashboard data', 'error');
        console.error(error);
    }
}

function updateDashboardStats(data) {
    const { overview, thisMonth, growth } = data;
    
    // Update stat cards
    document.getElementById('totalUsers').textContent = (overview.totalUsers || 0).toLocaleString();
    document.getElementById('totalListings').textContent = (overview.totalListings || 0).toLocaleString();
    document.getElementById('activeListings').textContent = `${overview.activeListings || 0} active`;
    document.getElementById('totalBookings').textContent = (overview.totalBookings || 0).toLocaleString();
    document.getElementById('totalRevenue').textContent = formatCurrency(overview.totalRevenue || 0);
    
    // Update growth indicators
    document.getElementById('userGrowth').textContent = `${growth.users}%`;
    document.getElementById('bookingGrowth').textContent = `${growth.bookings}%`;
    document.getElementById('revenueGrowth').textContent = `${growth.revenue}%`;
}

function updateCharts(data) {
    // Destroy existing charts if they exist
    if (charts.users) charts.users.destroy();
    if (charts.revenue) charts.revenue.destroy();
    
    // Users Chart
    const usersCtx = document.getElementById('usersChart').getContext('2d');
    const usersLabels = data.usersOverTime.map(d => new Date(d._id).toLocaleDateString('en-GB'));
    const usersData = data.usersOverTime.map(d => d.count);
    
    charts.users = new Chart(usersCtx, {
        type: 'line',
        data: {
            labels: usersLabels,
            datasets: [{
                label: 'New Users',
                data: usersData,
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Revenue Chart
    const revenueCtx = document.getElementById('revenueChart').getContext('2d');
    const revenueLabels = data.revenueOverTime.map(d => new Date(d._id).toLocaleDateString('en-GB'));
    const revenueData = data.revenueOverTime.map(d => d.revenue);
    
    charts.revenue = new Chart(revenueCtx, {
        type: 'bar',
        data: {
            labels: revenueLabels,
            datasets: [{
                label: 'Revenue (TZS)',
                data: revenueData,
                backgroundColor: 'rgba(102, 126, 234, 0.8)',
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

function updateRecentActivity(data) {
    // Recent Users
    const usersList = document.getElementById('recentUsersList');
    usersList.innerHTML = '';
    
    data.recentUsers?.forEach(user => {
        const item = document.createElement('div');
        item.className = 'activity-item';
        item.innerHTML = `
            <div class="activity-avatar">${getInitials(user.profile.firstName, user.profile.lastName)}</div>
            <div class="activity-details">
                <h4>${user.profile.firstName} ${user.profile.lastName}</h4>
                <p>${user.email} • ${formatDate(user.createdAt)}</p>
            </div>
        `;
        usersList.appendChild(item);
    });
    
    // Recent Bookings
    const bookingsList = document.getElementById('recentBookingsList');
    bookingsList.innerHTML = '';
    
    data.recentBookings?.forEach(booking => {
        const item = document.createElement('div');
        item.className = 'activity-item';
        item.innerHTML = `
            <div class="activity-avatar">${getInitials(booking.userId?.profile?.firstName, booking.userId?.profile?.lastName)}</div>
            <div class="activity-details">
                <h4>${booking.listingId?.title || 'N/A'}</h4>
                <p>${formatCurrency(booking.totalAmount)} • ${formatDate(booking.createdAt)}</p>
            </div>
        `;
        bookingsList.appendChild(item);
    });
}

// ==================================
// Users Management
// ==================================

let currentUsersPage = 1;

async function loadUsers(page = 1) {
    try {
        showLoading();
        
        const search = document.getElementById('userSearch')?.value || '';
        const role = document.getElementById('userRoleFilter')?.value || '';
        
        const queryParams = new URLSearchParams({
            page,
            limit: 10,
            ...(search && { search }),
            ...(role && { role })
        });
        
        const response = await apiCall(`/admin/users?${queryParams}`);
        
        displayUsers(response.data);
        updatePagination('usersPagination', response.currentPage, response.pages, loadUsers);
        
        currentUsersPage = page;
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to load users', 'error');
        console.error(error);
    }
}

function displayUsers(users) {
    const tbody = document.getElementById('usersTableBody');
    
    if (!users || users.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">No users found</td></tr>';
        return;
    }
    
    tbody.innerHTML = users.map(user => `
        <tr>
            <td><code>${user._id.substring(0, 8)}...</code></td>
            <td>${user.profile?.firstName || 'N/A'} ${user.profile?.lastName || ''}</td>
            <td>${user.email}</td>
            <td>${user.phoneNumber || 'N/A'}</td>
            <td><span class="badge badge-info">${user.role}</span></td>
            <td><span class="badge ${user.accountStatus === 'active' ? 'badge-success' : 'badge-danger'}">${user.accountStatus || 'active'}</span></td>
            <td>${formatDate(user.createdAt)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn-icon" onclick="viewUser('${user._id}')" title="View">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-icon" onclick="editUser('${user._id}')" title="Edit">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-icon" onclick="deleteUser('${user._id}')" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

async function viewUser(userId) {
    try {
        showLoading();
        const response = await apiCall(`/admin/users/${userId}`);
        hideLoading();
        
        // Create modal or redirect to detail view
        alert(JSON.stringify(response.data, null, 2));
    } catch (error) {
        hideLoading();
        showToast('Failed to load user details', 'error');
    }
}

async function editUser(userId) {
    const newRole = prompt('Enter new role (guest, host, admin):');
    if (!newRole) return;
    
    try {
        showLoading();
        await apiCall(`/admin/users/${userId}`, {
            method: 'PUT',
            body: JSON.stringify({ role: newRole })
        });
        hideLoading();
        showToast('User updated successfully', 'success');
        loadUsers(currentUsersPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to update user', 'error');
    }
}

async function deleteUser(userId) {
    if (!confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
        return;
    }
    
    try {
        showLoading();
        await apiCall(`/admin/users/${userId}`, { method: 'DELETE' });
        hideLoading();
        showToast('User deleted successfully', 'success');
        loadUsers(currentUsersPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to delete user', 'error');
    }
}

// Add event listeners for user filters
document.getElementById('userSearch')?.addEventListener('input', () => loadUsers(1));
document.getElementById('userRoleFilter')?.addEventListener('change', () => loadUsers(1));

// ==================================
// Listings Management
// ==================================

let currentListingsPage = 1;

async function loadListings(page = 1) {
    try {
        showLoading();
        
        const search = document.getElementById('listingSearch')?.value || '';
        const status = document.getElementById('listingStatusFilter')?.value || '';
        
        const queryParams = new URLSearchParams({
            page,
            limit: 10,
            ...(search && { search }),
            ...(status && { status })
        });
        
        console.log('Loading listings from:', `/admin/listings?${queryParams}`);
        const response = await apiCall(`/admin/listings?${queryParams}`);
        console.log('Listings response:', response);
        
        if (!response || !response.data) {
            throw new Error('Invalid response format');
        }
        
        displayListings(response.data);
        updatePagination('listingsPagination', response.currentPage, response.pages, loadListings);
        
        currentListingsPage = page;
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast(`Failed to load listings: ${error.message}`, 'error');
        console.error('Listings error:', error);
    }
}

function displayListings(listings) {
    const tbody = document.getElementById('listingsTableBody');
    
    if (!listings || listings.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">No listings found</td></tr>';
        return;
    }
    
    tbody.innerHTML = listings.map(listing => `
        <tr>
            <td><code>${listing._id.substring(0, 8)}...</code></td>
            <td>${listing.title?.en || listing.title?.sw || listing.title || 'N/A'}</td>
            <td>${listing.hostId?.profile?.firstName || 'N/A'} ${listing.hostId?.profile?.lastName || ''}</td>
            <td>${listing.location.city}, ${listing.location.region}</td>
            <td>${formatCurrency(listing.pricing?.basePrice)}</td>
            <td><span class="badge ${getStatusBadge(listing.status)}">${listing.status || 'pending'}</span></td>
            <td>${formatDate(listing.createdAt)}</td>
            <td>
                <div class="action-buttons">
                    ${listing.status === 'pending' ? `
                        <button class="btn-icon" onclick="approveListing('${listing._id}')" title="Approve">
                            <i class="fas fa-check"></i>
                        </button>
                        <button class="btn-icon" onclick="rejectListing('${listing._id}')" title="Reject">
                            <i class="fas fa-times"></i>
                        </button>
                    ` : ''}
                    <button class="btn-icon" onclick="deleteListing('${listing._id}')" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function getStatusBadge(status) {
    const badges = {
        'approved': 'badge-success',
        'pending': 'badge-warning',
        'rejected': 'badge-danger'
    };
    return badges[status] || 'badge-info';
}

async function approveListing(listingId) {
    try {
        showLoading();
        await apiCall(`/admin/listings/${listingId}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status: 'approved' })
        });
        hideLoading();
        showToast('Listing approved successfully', 'success');
        loadListings(currentListingsPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to approve listing', 'error');
    }
}

async function rejectListing(listingId) {
    if (!confirm('Are you sure you want to reject this listing?')) return;
    
    try {
        showLoading();
        await apiCall(`/admin/listings/${listingId}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status: 'rejected' })
        });
        hideLoading();
        showToast('Listing rejected', 'success');
        loadListings(currentListingsPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to reject listing', 'error');
    }
}

async function deleteListing(listingId) {
    if (!confirm('Are you sure you want to delete this listing? This action cannot be undone.')) {
        return;
    }
    
    try {
        showLoading();
        await apiCall(`/admin/listings/${listingId}`, { method: 'DELETE' });
        hideLoading();
        showToast('Listing deleted successfully', 'success');
        loadListings(currentListingsPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to delete listing', 'error');
    }
}

// Add event listeners for listing filters
document.getElementById('listingSearch')?.addEventListener('input', () => loadListings(1));
document.getElementById('listingStatusFilter')?.addEventListener('change', () => loadListings(1));

// ==================================
// Content Moderation
// ==================================

let currentModerationPage = 1;

async function loadModeration(page = 1) {
    try {
        showLoading();
        
        const status = document.getElementById('moderationStatusFilter')?.value || '';
        const contentType = document.getElementById('moderationTypeFilter')?.value || '';
        
        const queryParams = new URLSearchParams({
            page,
            limit: 20,
            ...(status && { status }),
            ...(contentType && { contentType })
        });
        
        console.log('Loading moderation data from:', `/admin/moderation/flagged?${queryParams}`);
        const response = await apiCall(`/admin/moderation/flagged?${queryParams}`);
        console.log('Moderation response:', response);
        
        if (response && response.data) {
            displayFlaggedContent(response.data.flaggedItems || []);
            updateModerationStats(response.data.stats || []);
            
            if (response.data.pagination) {
                updatePagination(
                    'moderationPagination',
                    response.data.pagination.page,
                    response.data.pagination.pages,
                    loadModeration
                );
            }
        }
        
        currentModerationPage = page;
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast(`Failed to load moderation data: ${error.message}`, 'error');
        console.error('Moderation error:', error);
    }
}

function displayFlaggedContent(flaggedItems) {
    const tbody = document.getElementById('moderationTableBody');
    
    if (!flaggedItems || flaggedItems.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">No flagged content found</td></tr>';
        return;
    }
    
    tbody.innerHTML = flaggedItems.map(item => `
        <tr>
            <td><code>${item._id.substring(0, 8)}...</code></td>
            <td><span class="badge badge-info">${item.contentType}</span></td>
            <td>${formatReason(item.reason)}</td>
            <td>${item.reportedBy?.email || 'Anonymous'}</td>
            <td><span class="badge ${getPriorityBadge(item.priority)}">${item.priority}</span></td>
            <td><span class="badge ${getModerationStatusBadge(item.status)}">${item.status}</span></td>
            <td>${formatDate(item.createdAt)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn-icon" onclick="reviewFlaggedContent('${item._id}')" title="Review">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function updateModerationStats(stats) {
    const statusCounts = {};
    stats.forEach(s => {
        statusCounts[s._id] = s.count;
    });
    
    document.getElementById('totalFlagged').textContent = Object.values(statusCounts).reduce((a, b) => a + b, 0);
    document.getElementById('pendingReviews').textContent = statusCounts['pending'] || 0;
    document.getElementById('actionsTaken').textContent = statusCounts['action_taken'] || 0;
    document.getElementById('dismissedReports').textContent = statusCounts['dismissed'] || 0;
}

function formatReason(reason) {
    return reason.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
}

function getPriorityBadge(priority) {
    const badges = {
        'low': 'badge-info',
        'medium': 'badge-warning',
        'high': 'badge-danger',
        'critical': 'badge-danger'
    };
    return badges[priority] || 'badge-info';
}

function getModerationStatusBadge(status) {
    const badges = {
        'pending': 'badge-warning',
        'under_review': 'badge-info',
        'action_taken': 'badge-success',
        'dismissed': 'badge-secondary',
        'escalated': 'badge-danger'
    };
    return badges[status] || 'badge-info';
}

async function reviewFlaggedContent(itemId) {
    // TODO: Implement review modal with action options
    showToast('Review modal coming soon', 'info');
}

// Add event listeners for moderation filters
document.getElementById('moderationStatusFilter')?.addEventListener('change', () => loadModeration(1));
document.getElementById('moderationTypeFilter')?.addEventListener('change', () => loadModeration(1));

// ==================================
// Payments Management
// ==================================

let currentPaymentsPage = 1;
let paymentSearchTimeout;

async function loadPayments(page = 1) {
    try {
        showLoading();

        const status = document.getElementById('paymentStatusFilter')?.value || '';
        const method = document.getElementById('paymentMethodFilter')?.value || '';
        const search = document.getElementById('paymentSearch')?.value.trim() || '';

        const queryParams = new URLSearchParams({
            page,
            limit: 20,
            ...(status && { status }),
            ...(method && { method }),
            ...(search && { search }),
        });

        const response = await apiCall(`/admin/payments/transactions?${queryParams}`);

        if (response && response.data) {
            const { transactions = [], pagination, stats } = response.data;
            displayPayments(transactions);
            updatePaymentsStats(stats);
            if (pagination) {
                updatePagination(
                    'paymentsPagination',
                    pagination.page,
                    pagination.pages,
                    loadPayments
                );
                currentPaymentsPage = pagination.page;
            }
        }

        hideLoading();
    } catch (error) {
        hideLoading();
        console.error(error);
        showToast(error.message || 'Failed to load payments', 'error');
    }
}

function displayPayments(transactions) {
    const tbody = document.getElementById('paymentsTableBody');

    if (!tbody) return;

    if (!transactions || transactions.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">No transactions found</td></tr>';
        return;
    }

    tbody.innerHTML = transactions.map((payment) => {
        const customerName = payment.user
            ? `${payment.user.profile?.firstName || ''} ${payment.user.profile?.lastName || ''}`.trim()
            : '';
        const customerLabel = customerName || payment.customerEmail || payment.customerPhone || 'N/A';

        const bookingLabel = payment.booking
            ? `<span class="badge badge-info">#${payment.booking._id.substring(0, 6).toUpperCase()}</span>`
            : '<span class="badge badge-secondary">N/A</span>';

        return `
            <tr>
                <td><code>${payment.id.substring(0, 8)}...</code></td>
                <td>
                    <div class="table-cell-title">${customerLabel}</div>
                    <div class="table-cell-subtitle">${payment.customerEmail || ''}</div>
                </td>
                <td>
                    <div class="table-cell-title">${formatCurrency(payment.amount)}</div>
                    <div class="table-cell-subtitle">${payment.currency}</div>
                </td>
                <td>${(payment.paymentMethod || 'N/A').replace(/_/g, ' ')}</td>
                <td><span class="badge ${getPaymentBadge(payment.status)}">${payment.status}</span></td>
                <td>${bookingLabel}</td>
                <td>${formatDate(payment.createdAt)}</td>
                <td>${payment.completedAt ? formatDate(payment.completedAt) : '—'}</td>
            </tr>
        `;
    }).join('');
}

function updatePaymentsStats(stats = {}) {
    const {
        totalAmount = 0,
        completedAmount = 0,
        pendingAmount = 0,
        failedAmount = 0,
        totalCount = 0,
        completedCount = 0,
        pendingCount = 0,
        failedCount = 0,
    } = stats;

    const setText = (id, value) => {
        const el = document.getElementById(id);
        if (el) {
            el.textContent = typeof value === 'number' ? formatCurrency(value) : value;
        }
    };

    const setCount = (id, count) => {
        const el = document.getElementById(id);
        if (el) {
            const safeCount = count || 0;
            el.textContent = `${safeCount} transaction${safeCount === 1 ? '' : 's'}`;
        }
    };

    setText('paymentsTotalAmount', totalAmount);
    setText('paymentsCompletedAmount', completedAmount);
    setText('paymentsPendingAmount', pendingAmount);
    setText('paymentsFailedAmount', failedAmount);
    setCount('paymentsTotalCount', totalCount);
    setCount('paymentsCompletedCount', completedCount);
    setCount('paymentsPendingCount', pendingCount);
    setCount('paymentsFailedCount', failedCount);
}

document.getElementById('paymentStatusFilter')?.addEventListener('change', () => loadPayments(1));
document.getElementById('paymentMethodFilter')?.addEventListener('change', () => loadPayments(1));
document.getElementById('paymentSearch')?.addEventListener('input', () => {
    clearTimeout(paymentSearchTimeout);
    paymentSearchTimeout = setTimeout(() => loadPayments(1), 400);
});
document.getElementById('paymentSearch')?.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        e.preventDefault();
        loadPayments(1);
    }
});

// ==================================
// Disputes Management
// ==================================

async function loadDisputes() {
    showToast('Disputes page coming soon - API ready', 'info');
}

// ==================================
// Support Tickets
// ==================================

async function loadSupportTickets() {
    showToast('Support tickets page coming soon - API ready', 'info');
}

// ==================================
// Notifications
// ==================================

async function loadNotifications() {
    showToast('Notifications page coming soon - API ready', 'info');
}

// ==================================
// Promotions
// ==================================

async function loadPromotions() {
    showToast('Promotions page coming soon - API ready', 'info');
}

// ==================================
// Analytics
// ==================================

async function loadAnalytics() {
    showToast('Analytics page coming soon - API ready', 'info');
}

// ==================================
// Audit Logs
// ==================================

async function loadAuditLogs() {
    showToast('Audit logs page coming soon - API ready', 'info');
}

// ==================================
// Bookings Management
// ==================================

let currentBookingsPage = 1;

async function loadBookings(page = 1) {
    try {
        showLoading();
        
        const status = document.getElementById('bookingStatusFilter')?.value || '';
        const paymentStatus = document.getElementById('paymentStatusFilter')?.value || '';
        
        const queryParams = new URLSearchParams({
            page,
            limit: 10,
            ...(status && { status }),
            ...(paymentStatus && { paymentStatus })
        });
        
        const response = await apiCall(`/admin/bookings?${queryParams}`);
        
        displayBookings(response.data);
        updatePagination('bookingsPagination', response.currentPage, response.pages, loadBookings);
        
        currentBookingsPage = page;
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to load bookings', 'error');
        console.error(error);
    }
}

function displayBookings(bookings) {
    const tbody = document.getElementById('bookingsTableBody');
    
    if (!bookings || bookings.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="text-center">No bookings found</td></tr>';
        return;
    }
    
    tbody.innerHTML = bookings.map(booking => `
        <tr>
            <td><code>${booking._id.substring(0, 8)}...</code></td>
            <td>${booking.userId?.profile?.firstName || 'N/A'} ${booking.userId?.profile?.lastName || ''}</td>
            <td>${booking.listingId?.title || 'N/A'}</td>
            <td>${new Date(booking.checkIn).toLocaleDateString('en-GB')}</td>
            <td>${new Date(booking.checkOut).toLocaleDateString('en-GB')}</td>
            <td>${formatCurrency(booking.totalAmount)}</td>
            <td><span class="badge ${getStatusBadge(booking.status)}">${booking.status}</span></td>
            <td><span class="badge ${getPaymentBadge(booking.paymentStatus)}">${booking.paymentStatus?.toUpperCase() || 'PENDING'}</span></td>
            <td>
                <div class="action-buttons">
                    <button class="btn-icon" onclick="updateBookingStatus('${booking._id}', 'confirmed')" title="Confirm">
                        <i class="fas fa-check"></i>
                    </button>
                    <button class="btn-icon" onclick="updateBookingStatus('${booking._id}', 'cancelled')" title="Cancel">
                        <i class="fas fa-ban"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function getPaymentBadge(status) {
    const badges = {
        'completed': 'badge-success',
        'paid': 'badge-success',
        'pending': 'badge-warning',
        'refunded': 'badge-info',
        'failed': 'badge-danger',
        'cancelled': 'badge-secondary'
    };
    return badges[status?.toLowerCase?.()] || 'badge-info';
}

async function updateBookingStatus(bookingId, newStatus) {
    try {
        showLoading();
        await apiCall(`/admin/bookings/${bookingId}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status: newStatus })
        });
        hideLoading();
        showToast(`Booking ${newStatus} successfully`, 'success');
        loadBookings(currentBookingsPage);
    } catch (error) {
        hideLoading();
        showToast('Failed to update booking', 'error');
    }
}

// Add event listeners for booking filters
document.getElementById('bookingStatusFilter')?.addEventListener('change', () => loadBookings(1));
document.getElementById('paymentStatusFilter')?.addEventListener('change', () => loadBookings(1));

// ==================================
// Reports
// ==================================

let currentReport = null;

async function generateReport(type) {
    try {
        showLoading();
        
        const today = new Date();
        const thirtyDaysAgo = new Date(today.setDate(today.getDate() - 30));
        
        const queryParams = new URLSearchParams({
            type,
            startDate: thirtyDaysAgo.toISOString(),
            endDate: new Date().toISOString()
        });
        
        const response = await apiCall(`/admin/reports?${queryParams}`);
        
        currentReport = response;
        displayReport(response);
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to generate report', 'error');
        console.error(error);
    }
}

function displayReport(report) {
    const resultDiv = document.getElementById('reportResult');
    const contentDiv = document.getElementById('reportContent');
    
    contentDiv.innerHTML = `
        <h4>${report.type.replace('-', ' ').toUpperCase()} Report</h4>
        <p>Period: ${new Date(report.period.startDate).toLocaleDateString()} - ${new Date(report.period.endDate).toLocaleDateString()}</p>
        <pre>${JSON.stringify(report.data, null, 2)}</pre>
    `;
    
    resultDiv.style.display = 'block';
}

function exportReport() {
    if (!currentReport) {
        showToast('No report to export', 'warning');
        return;
    }
    
    // Convert report to CSV
    const csv = JSON.stringify(currentReport.data, null, 2);
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${currentReport.type}-report-${Date.now()}.csv`;
    a.click();
    
    showToast('Report exported successfully', 'success');
}

// ==================================
// Settings
// ==================================

function loadSettings() {
    // Load settings from localStorage or API
    const settings = JSON.parse(localStorage.getItem('adminSettings') || '{}');
    
    document.getElementById('emailNotifications').checked = settings.emailNotifications !== false;
    document.getElementById('smsNotifications').checked = settings.smsNotifications || false;
    document.getElementById('adminAlerts').checked = settings.adminAlerts !== false;
    document.getElementById('listingApproval').value = settings.listingApproval || 'manual';
    document.getElementById('sessionTimeout').value = settings.sessionTimeout || 60;
    document.getElementById('itemsPerPage').value = settings.itemsPerPage || 10;
    document.getElementById('dateFormat').value = settings.dateFormat || 'DD/MM/YYYY';
}

function saveSettings() {
    const settings = {
        emailNotifications: document.getElementById('emailNotifications').checked,
        smsNotifications: document.getElementById('smsNotifications').checked,
        adminAlerts: document.getElementById('adminAlerts').checked,
        listingApproval: document.getElementById('listingApproval').value,
        sessionTimeout: document.getElementById('sessionTimeout').value,
        itemsPerPage: document.getElementById('itemsPerPage').value,
        dateFormat: document.getElementById('dateFormat').value
    };
    
    localStorage.setItem('adminSettings', JSON.stringify(settings));
    showToast('Settings saved successfully', 'success');
}

function resetSettings() {
    if (confirm('Are you sure you want to reset all settings to default values?')) {
        localStorage.removeItem('adminSettings');
        loadSettings();
        showToast('Settings reset to defaults', 'info');
    }
}

// ==================================
// Pagination Helper
// ==================================

function updatePagination(containerId, currentPage, totalPages, loadFunction) {
    const container = document.getElementById(containerId);
    
    if (!container) return;
    
    let html = '';
    
    // Previous button
    html += `<button ${currentPage === 1 ? 'disabled' : ''} onclick="${loadFunction.name}(${currentPage - 1})">
        <i class="fas fa-chevron-left"></i> Previous
    </button>`;
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            html += `<button class="${i === currentPage ? 'active' : ''}" onclick="${loadFunction.name}(${i})">${i}</button>`;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            html += '<span>...</span>';
        }
    }
    
    // Next button
    html += `<button ${currentPage === totalPages ? 'disabled' : ''} onclick="${loadFunction.name}(${currentPage + 1})">
        Next <i class="fas fa-chevron-right"></i>
    </button>`;
    
    container.innerHTML = html;
}

// ==================================
// Chart Period Selectors
// ==================================

document.getElementById('usersChartPeriod')?.addEventListener('change', async (e) => {
    try {
        showLoading();
        const response = await apiCall(`/admin/dashboard/charts?period=${e.target.value}`);
        updateCharts(response.data);
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to update chart', 'error');
    }
});

document.getElementById('revenueChartPeriod')?.addEventListener('change', async (e) => {
    try {
        showLoading();
        const response = await apiCall(`/admin/dashboard/charts?period=${e.target.value}`);
        updateCharts(response.data);
        hideLoading();
    } catch (error) {
        hideLoading();
        showToast('Failed to update chart', 'error');
    }
});

// Make functions globally accessible
window.viewUser = viewUser;
window.editUser = editUser;
window.deleteUser = deleteUser;
window.approveListing = approveListing;
window.rejectListing = rejectListing;
window.deleteListing = deleteListing;
window.updateBookingStatus = updateBookingStatus;
window.generateReport = generateReport;
window.exportReport = exportReport;
window.saveSettings = saveSettings;
window.resetSettings = resetSettings;


