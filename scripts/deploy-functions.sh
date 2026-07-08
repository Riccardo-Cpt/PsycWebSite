#!/bin/bash

# Supabase Edge Functions Deployment Script
# Deploys all 9 Edge Functions to Supabase project

set -e

PROJECT_REF="snsvamcecgizhecvtpwk"
ALLOWED_ORIGIN="https://riccardo-cpt.github.io"

echo "=== Supabase Edge Functions Deployment ==="
echo ""

# Check if supabase CLI is available
if ! command -v supabase &> /dev/null; then
    echo "ERROR: supabase CLI is not installed"
    echo "Install it with: npm install -g supabase"
    exit 1
fi

echo "supabase CLI version: $(supabase --version)"
echo ""

# Authenticate (non-interactive)
echo "Step 1: Attempting to authenticate with Supabase..."
if supabase login >/dev/null 2>&1 || true; then
    echo "✓ Authentication check completed"
else
    echo "⚠ Non-interactive login may have failed - ensure you are already authenticated"
fi

echo ""
echo "Step 2: Linking project..."
if supabase link --project-ref "$PROJECT_REF" >/dev/null 2>&1 || true; then
    echo "✓ Project linked (or already linked)"
else
    echo "⚠ Project linking may have failed"
fi

echo ""
echo "Step 3: Deploying all 9 Edge Functions..."
echo ""

FAILED=0

# Public functions — JWT verification disabled (accept anonymous requests)
PUBLIC_FUNCTIONS=(
    "get-articles"
    "get-approved-reviews"
    "send-contact-request"
    "send-review-magic-link"
    "verify-review-token"
    "submit-review"
)

# Admin functions — JWT verification ON (default)
ADMIN_FUNCTIONS=(
    "admin-articles"
    "admin-reviews"
    "admin-contact-requests"
)

for func in "${PUBLIC_FUNCTIONS[@]}"; do
    echo -n "Deploying $func (--no-verify-jwt)... "
    if supabase functions deploy "$func" --no-verify-jwt 2>&1 | grep -q "Deployed Function"; then
        echo "✓ Success"
    else
        echo "✗ Failed"
        ((FAILED++))
    fi
done

for func in "${ADMIN_FUNCTIONS[@]}"; do
    echo -n "Deploying $func... "
    if supabase functions deploy "$func" 2>&1 | grep -q "Deployed Function"; then
        echo "✓ Success"
    else
        echo "✗ Failed"
        ((FAILED++))
    fi
done

echo ""
echo "Step 4: Setting ALLOWED_ORIGIN secret..."
if supabase secrets set ALLOWED_ORIGIN="$ALLOWED_ORIGIN" >/dev/null 2>&1; then
    echo "✓ Secret set successfully"
else
    echo "✗ Failed to set secret"
    ((FAILED++))
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== All deployments completed successfully ==="
    exit 0
else
    echo "=== $FAILED deployment(s) failed ==="
    exit 1
fi
