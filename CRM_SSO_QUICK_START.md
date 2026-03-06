# CRM SSO Quick Start Guide

## 🚀 Phase 1: Start CRM Server

```bash
cd crm-example
npm install
cp env.example .env
npm run dev
```

Server: http://localhost:3000
Test: `student1` / `password123`

## 🔧 Phase 2: Setup Tutor Plugin

```bash
cd tutor-crm-sso
pip install -e .
tutor plugins enable crm-sso
tutor config save
tutor local restart
```

## ⚙️ Phase 3: Configure OpenEDX

1. Truy cập: http://local.openedx.io/admin
2. Vào: Third Party Auth > OAuth2 Provider Configs
3. Tạo config:
   - **Enabled**: ✅
   - **Backend Name**: `crm-oauth2`
   - **Client ID**: `openedx-sso`
   - **Client Secret**: `openedx-secret-key-12345`
   - **Auth URL**: `http://YOUR_IP:3000/oauth/authorize`
   - **Token URL**: `http://YOUR_IP:3000/oauth/token`
   - **User Info URL**: `http://YOUR_IP:3000/oauth/userinfo`

> ⚠️ **Lưu ý**: Thay `YOUR_IP` bằng IP máy bạn (không dùng localhost vì Docker container không thấy localhost của host)

## 🎯 Test SSO

1. Login vào CRM: http://localhost:3000
2. Click "Đi tới OpenEDX" button
3. Auto-redirect và login vào OpenEDX!

