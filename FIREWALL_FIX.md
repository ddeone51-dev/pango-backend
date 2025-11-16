# Fix Connection Timeout - Windows Firewall

## The Issue
Your phone can't connect to the backend because Windows Firewall is blocking port 3000.

## Quick Fix (2 minutes)

### Option 1: Allow Node.js Through Firewall

1. Open **Windows Defender Firewall**:
   - Press `Windows + R`
   - Type: `firewall.cpl`
   - Press Enter

2. Click **"Allow an app or feature through Windows Defender Firewall"**

3. Click **"Change settings"**

4. Click **"Allow another app..."**

5. Browse to: `C:\Program Files\nodejs\node.exe`

6. Click **"Add"**

7. Make sure both **Private** and **Public** are checked

8. Click **OK**

### Option 2: Turn Off Firewall Temporarily (Testing Only)

1. Open **Windows Security**
2. Click **Firewall & network protection**
3. Click your active network (Private network)
4. Turn **OFF** Microsoft Defender Firewall
5. Test the app
6. **Remember to turn it back ON after testing!**

### Option 3: Allow Port 3000 Manually

1. Open **Windows Defender Firewall**
2. Click **"Advanced settings"** (left side)
3. Click **"Inbound Rules"** (left side)
4. Click **"New Rule..."** (right side)
5. Select **"Port"** → Next
6. Select **"TCP"** and enter **"3000"** → Next
7. Select **"Allow the connection"** → Next
8. Check all three boxes (Domain, Private, Public) → Next
9. Name: **"Pango Backend"** → Finish

## Verify It Works

After fixing firewall, test from your phone's browser:
- Open Chrome on your Pixel 6
- Go to: `http://10.42.217.17:3000/health`
- You should see: `{"success":true,"message":"Server is healthy"}`

If you see that, the app will work!

























