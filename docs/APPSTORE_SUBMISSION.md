# Nextcloud App Store Submission Guide

This document provides a complete guide for submitting the Scores app to the Nextcloud App Store.

## Prerequisites

### 1. Certificate Setup ✅ COMPLETED

**Status**: Certificate Signing Request (CSR) created and submitted

- Private key: `~/.nextcloud/certificates/scores.key`
- CSR file: `~/.nextcloud/certificates/scores.csr`
- Pull Request: https://github.com/nextcloud/app-certificate-requests/pull/856

**Waiting for**: Nextcloud team to review and approve the CSR, then provide the signed certificate (`scores.crt`)

### 2. Required Files ✅ VERIFIED

All required files are present and compliant:

- ✅ `appinfo/info.xml` - Validates against App Store schema
- ✅ `CHANGELOG.md` - Follows Keep a Changelog format
- ✅ `LICENSE` - AGPL-3.0 license included
- ✅ `README.md` - Complete documentation
- ✅ GitHub repository configured

## Submission Process

### Phase 1: Wait for Certificate Approval

1. **Monitor the Pull Request**: https://github.com/nextcloud/app-certificate-requests/pull/856
2. **When approved**, Nextcloud will provide `scores.crt` (signed certificate)
3. **Save the certificate**: Copy the certificate content to `~/.nextcloud/certificates/scores.crt`

### Phase 2: Generate Registration Signature

Once you have the signed certificate, generate the registration signature:

```bash
echo -n "scores" | openssl dgst -sha512 -sign ~/.nextcloud/certificates/scores.key | openssl base64
```

**Save this signature** - you'll need it for registration.

### Phase 3: Sign the App

Run the signing script to create `appinfo/signature.json`:

```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/sign-app.sh
```

This will:
- Build the app (npm run build)
- Generate SHA512 hashes for all app files
- Sign the hashes with your private key
- Create `appinfo/signature.json`

### Phase 4: Create Distribution Package

Create the final tar.gz archive for upload:

```bash
./project-files/scripts/package-app.sh
```

This creates: `project-files/dist/scores-0.9.7.tar.gz`

### Phase 5: Generate Release Signature

Sign the release archive:

```bash
openssl dgst -sha512 -sign ~/.nextcloud/certificates/scores.key /Users/Michele/Sites/scores/project-files/dist/scores-0.9.7.tar.gz | openssl base64
```

**Save this signature** - you'll need it when uploading the release.

### Phase 6: Upload to GitHub Releases

Create a GitHub release with the signed package:

```bash
cd /Users/Michele/Sites/scores
gh release create v0.9.7 \
  --title "Scores v0.9.7 - Nextcloud App Store Release" \
  --notes-file CHANGELOG.md \
  project-files/dist/scores-0.9.7.tar.gz
```

This creates a permanent download URL for the App Store.

### Phase 7: Register App on App Store

Visit: https://apps.nextcloud.com/developer/apps/new

Fill in the registration form:

**App ID**: `scores`

**Certificate** (paste the entire content of `~/.nextcloud/certificates/scores.crt`):
```
-----BEGIN CERTIFICATE-----
[Certificate content provided by Nextcloud]
-----END CERTIFICATE-----
```

**Signature** (from Phase 2):
```
[Base64 signature from registration command]
```

**GitHub Account**: Verify your GitHub account with visible email address

Click **Register**

### Phase 8: Submit First Release

Visit: https://apps.nextcloud.com/developer/apps/releases/new

Fill in the release form:

**App ID**: `scores`

**Download URL**:
```
https://github.com/micheledimeo/scores/releases/download/v0.9.7/scores-0.9.7.tar.gz
```

**Release Signature** (from Phase 5):
```
[Base64 signature from release signing command]
```

**Nightly**: No (uncheck)

Click **Upload Release**

The App Store will:
1. Download the archive
2. Verify the signature
3. Validate the structure
4. Extract and parse `appinfo/info.xml`
5. Verify CHANGELOG.md format
6. Publish if all checks pass

## Verification Checklist

Before submission, verify:

- [ ] Certificate approved and `scores.crt` saved
- [ ] Registration signature generated
- [ ] App signed with `signature.json` created
- [ ] Distribution package created
- [ ] Release signature generated
- [ ] GitHub release created with permanent URL
- [ ] All required files present in archive
- [ ] No `.git` directories in archive
- [ ] CHANGELOG.md version matches info.xml
- [ ] info.xml validates against schema

## Post-Submission

After successful submission:

1. **Monitor**: Check the App Store listing at https://apps.nextcloud.com/apps/scores
2. **Testing**: Install the app from the App Store on a test Nextcloud instance
3. **Updates**: For future releases, repeat Phases 3-8

## Security Notes

⚠️ **Important Security Practices**:

- **NEVER** commit `signature.json` to git (already in `.gitignore`)
- **NEVER** share or commit your private key (`scores.key`)
- **Always** resign the app after any code changes
- **Store** private key securely with restricted permissions (600)
- **Backup** private key in a secure location

## Troubleshooting

### Certificate Not Approved
- Check PR comments for issues
- Verify GitHub profile email is visible
- Ensure app ID matches repository

### Signature Verification Failed
- Ensure you're using the correct private key
- Verify certificate content is complete
- Check that signature.json is properly formatted

### Archive Validation Failed
- Verify no .git directories in archive
- Check that app folder name matches app ID
- Ensure info.xml is valid XML

### Version Mismatch
- Verify version in info.xml matches CHANGELOG.md
- Check that version follows semantic versioning (X.Y.Z)

## Support Resources

- **App Store Documentation**: https://nextcloudappstore.readthedocs.io/
- **Developer Manual**: https://docs.nextcloud.com/server/stable/developer_manual/
- **Forum**: https://help.nextcloud.com/c/dev/
- **GitHub Issues**: https://github.com/nextcloud/appstore/issues

## Current Status

- ✅ Certificates generated
- ✅ CSR submitted (PR #856)
- ✅ Documentation prepared
- ✅ Signing scripts ready
- ⏳ Waiting for certificate approval
- ⏳ App registration pending
- ⏳ Release submission pending

Once the certificate is approved, follow Phases 2-8 to complete the submission.
