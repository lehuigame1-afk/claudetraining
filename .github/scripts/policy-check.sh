#!/usr/bin/env bash
# Enforces the CLAUDE.md constraints on index.html. CI helper only.
fail=0
for pat in 'localStorage' 'sessionStorage' 'indexedDB' 'document\.cookie' '!important' 'alert\(' 'confirm\(' '<script[^>]*src=' '@import' '@font-face'; do
  if grep -nE "$pat" index.html; then
    echo "::error::Forbidden pattern: $pat"
    fail=1
  fi
done

# Any external URL other than the FormSubmit endpoint is forbidden.
if grep -oE 'https?://[^" )<>]+' index.html | grep -v '^https://formsubmit.co/ajax/'; then
  echo "::error::Unexpected external URL"
  fail=1
fi

exit $fail
