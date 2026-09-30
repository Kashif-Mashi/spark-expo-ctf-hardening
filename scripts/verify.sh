#!/usr/bin/env bash
#
# verify.sh
#
# Post-hardening verification pass. Run as root after harden.sh, and again
# after any manual change. Doesn't assume a prior command succeeded --
# re-reads actual state, which is what caught real bugs during QA
# (see docs/04-infrastructure.md).

set -uo pipefail

echo "== SUID audit: pkexec / sudo / snap-confine must NOT appear below =="
find / -perm -4000 -type f 2>/dev/null

echo
echo "== Custom privesc binary should be present and setuid =="
ls -la /usr/local/bin/system_backup

echo
echo "== Flag files: confirm event-branded format, not the original numeric strings =="
for f in /var/www/html/hidden_flag_dir/index.html \
         /var/www/html/portal_secure_99/index.html \
         /var/www/html/hint.txt \
         /etc/mysql/conf.d/credentials.txt \
         /root/root.txt; do
  echo "--- $f ---"
  cat "$f" 2>/dev/null || echo "(not found)"
  echo
done

echo "== Confirm no leftover original-format flag strings anywhere under webroot =="
grep -rE '\{[0-9]{20,}\}' /var/www/html/ 2>/dev/null && \
  echo "!! Found an unreplaced original flag string above -- fix before proceeding" || \
  echo "OK: none found"

echo
echo "== Port check (run from an attacker machine, not the target itself) =="
echo "nmap -p- <target-ip>   # expect only 22/tcp and 8080/tcp open, 80 closed"

echo
echo "== Manual step (not automatable): =="
echo "SSH in as the low-privileged user and confirm the full intended solve"
echo "path still works end-to-end, including:"
echo "  /usr/local/bin/system_backup . -exec /bin/sh -p \\; -quit"
echo "...should return a root shell. Confirm with: whoami"