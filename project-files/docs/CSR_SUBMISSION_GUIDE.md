# Certificate Signing Request (CSR) Submission Guide

## 📋 Your CSR is Ready!

The Certificate Signing Request (CSR) has been generated and copied to your clipboard.

---

## 🚀 Steps to Submit CSR to Nextcloud

### 1. Fork the Certificate Repository

Go to: https://github.com/nextcloud/appstore-issues

Click **"Fork"** to create your own copy.

### 2. Create CSR File

In your forked repository:

1. Navigate to the `certificate` folder (or create it if it doesn't exist)
2. Create a new file named: `scores.csr`
3. Paste the CSR content (already in your clipboard!)
4. Commit the file

### 3. Create Pull Request

1. Go to your fork on GitHub
2. Click **"Pull Request"**
3. Title: `Certificate request for scores app`
4. Description:
   ```
   Certificate Signing Request for scores Nextcloud app

   - App ID: scores
   - App Name: Scores
   - Description: View and play MusicXML scores in Nextcloud
   - Repository: https://github.com/micheledimeo/scores
   - Developer: Michele (micheledimeo@gmail.com)
   ```
5. Submit the Pull Request

### 4. Wait for Approval

- Nextcloud team will review your CSR
- Timeline: Usually 1-2 weeks
- You'll receive the signed certificate as a comment in the PR or via email

### 5. After Receiving Certificate

Once you receive the signed certificate:

1. Save it as: `~/.nextcloud/certificates/scores.crt`
2. Then proceed with app registration at https://apps.nextcloud.com/developer/apps/new

---

## 📄 Your CSR Content

```
-----BEGIN CERTIFICATE REQUEST-----
MIIEeTCCAmECAQAwNDETMBEGA1UEAwwKbXhtbHNjb3JlczEQMA4GA1UECgwHTWlj
aGVsZTELMAkGA1UEBhMCSVQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
AQCUk77xH1InMelcsZ9kN+feY+sgrgmonEqqKuGRG9OS2cxhqUiSci+vaCOR0h8i
gwrWBiWRY/XpS+vK0i5C13g/IXZV4JE72d/HkcYAx7xcfc0jdzygA8K/2Wrhd//m
iRx1hUH5mnVo1ia9sRrPWdZhwtNB/3paN04Wy94/DQnx4z+ZDRw5oGSGIOo/cE1U
rLfdK5UbwCD5UDl35fmEgYX5U1oN5QXrDtVdrKvlNQnPCPlMpqhRT3IlEqoSfYsR
AeVcj/nval0kgiCOqR7Gbp+4mz1gonYfqb/3irKOxDzKDLHKaiKIWZCVgzOQxsLC
Tab1tRmHtFR0/4CCfnKYFeyLFSDew1wO5VZoX7bv7UhS/1KYDr/ikmx0lXV//zcu
XYt0QZtg1Swu0VXHFqa31LbKs8kN7XCq3GP4wdpRZF35suy/eoyyrtjD3YI+NdRF
qxiXGw5JCQUdU4p3u50IgnVULRY9GYfsntuC9O+ULww80odN1mdxOz287T7irGYC
SZk6ty+isHKKRkR8oxaCBLx8pyw5rpR/Nbs5J6jCWC4LKunpqnkMRGzWScJ5I3g5
l30wj3ZtYATuAgzACyoA5LzRzH5MzI62Yli+pTzPTceCd2SBqGNSzH1TUrm8wv6Y
1XRaN3x3vOq6ZTvawEr+NfSeL6C1XRYP3wXK86zOnRvURQIDAQABoAAwDQYJKoZI
hvcNAQELBQADggIBAAUpR5h4cUSmR6EU3I8Vub2JQfKhSw+w+ZflUvMt/iaha4iV
+4zHf7WSpDP22Z2wG5sqpaAs3rtXvr/NpawBYwm8nhbiI76MXkiRPtqsPOQ8M38c
DrdQrnMTFvKpCLrQS5DI/XCuH4EWAL1jQBCdlkZWMtEZdz3oMic05B+EnX/0Q/NV
RW/VrMgv5z7vkngGD2S2slmYVmB/HzThD9Gv/leDAagYKIxreRbq2fY0c3fi5fKp
lCZCacsV3iDtgsfCHUPelhvJ+lbkeYCEh4b9ezmhN2nmAxwSPb7vO3fF9AFgzTov
N5mpm/cwPa5Ha6rJfa2hJ+aAYEflzHy1Id58kymtPpNf5bbDWiN0ge4g6GBK0xpA
05EzdV1p+uYKSLZqC0WPSmQzg9XoCeTQaZxNJeWqtXtN6ifrj2NjXzVat82N2XZj
68j6peeDEdcN3h8BpY5zDbO3O+gtpcjxTA0uaKqyNZu2tOFGNCsEghcAkg3TjnVI
vBTItY1SBr0TSzPylNrX5rFD2OcyNTvCpgCJy3EtJHOZTKt4q+kuGTYSg4/Cvd2H
kVw2Y66nQC4FNiYy9w2GY20zrUaj1qc6lmVdjw4nJfcR8bA1mF7DC4xG2djHlJ/L
0XepnY3AEAsMcH5HuqZH62hMvBjtlbbKyjVs/LeYXUy9nGoa80RGBCB1y3ho
-----END CERTIFICATE REQUEST-----
```

---

## 🔐 Important Files (Keep Secure!)

- **Private Key:** `~/.nextcloud/certificates/scores.key`
  - ⚠️ NEVER share this file!
  - Keep multiple secure backups

- **CSR:** `~/.nextcloud/certificates/scores.csr`
  - Already submitted via PR

- **Certificate:** `~/.nextcloud/certificates/scores.crt`
  - Will be provided by Nextcloud team after CSR approval

---

## ⏳ Timeline

1. **Today**: Submit CSR via Pull Request
2. **1-2 weeks**: Wait for review and approval
3. **After approval**: Receive signed certificate
4. **Then**: Register app on Nextcloud App Store

---

## 📞 Support

If you need help during the process:
- GitHub Issues: https://github.com/nextcloud/appstore-issues
- Nextcloud Forums: https://help.nextcloud.com/

---

Generated: 2025-11-10
App: scores v0.9.5
