#!/usr/bin/env bash
#
# harden.sh
#
# Consolidated hardening / customization commands applied to the JIS-CTF:
# VulnUpload base image before use in a live event. Run as root on the
# CLONE only — never on a machine you intend to keep as a clean baseline.
#
# Literal flag values are redacted (XXXXXXXXXXXXXXXXXXXXX) — see
# docs/ for the full explanation of each step.

set -euo pipefail

echo "[1/6] Closing unintended local-root exploit paths..."
# CVE-2021-4034 (PwnKit)
chmod -s /usr/bin/pkexec
# CVE-2021-3156 (Baron Samedit) -- also disables legitimate sudo, intentional
# on this box; see docs/02-remediation.md
chmod -s /usr/bin/sudo
# CVE-2019-7304 (Dirty Sock)
chmod -s /usr/lib/snapd/snap-confine

echo "[2/6] Relocating and securing the final flag..."
mv /var/www/html/flag.txt /root/root.txt
echo "Flag 5: {XXXXXXXXXXXXXXXXXXXXX}" > /root/root.txt

echo "[3/6] Creating the custom privilege-escalation binary (GTFOBins: find)..."
cp /usr/bin/find /usr/local/bin/system_backup
chmod u+s /usr/local/bin/system_backup

echo "[4/6] Renaming default web paths and updating application source..."
cd /var/www/html/
mv flag hidden_flag_dir
mv admin_area portal_secure_99
mv uploaded_files uos_uploads
sed -i 's/uploaded_files/uos_uploads/g' /var/www/html/index.php
# robots.txt was hand-edited to disclose the new paths + decoys; not
# scripted here since it's a one-off content change, not a repeatable command.

echo "[5/6] Reformatting flags to the event-branded format..."
# Pattern-based replace (matches any {digits}-style flag), not a literal
# string match -- a literal match silently failed during QA due to a
# copy/paste encoding mismatch. See docs/04-infrastructure.md.
sed -i 's/{[0-9]\{20,\}}/{XXXXXXXXXXXXXXXXXXXXX}/' /var/www/html/hidden_flag_dir/index.html
sed -i 's/{[0-9]\{20,\}}/{XXXXXXXXXXXXXXXXXXXXX}/' /var/www/html/portal_secure_99/index.html
sed -i 's/{[0-9]\{20,\}}/{XXXXXXXXXXXXXXXXXXXXX}/' /var/www/html/hint.txt
sed -i 's/{[0-9]\{20,\}}/{XXXXXXXXXXXXXXXXXXXXX}/' /etc/mysql/conf.d/credentials.txt

echo "[6/6] Shifting the web service off its default port..."
sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-enabled/000-default.conf
service apache2 restart

echo "Done. Run verify.sh next, then run the full intended solve path by hand"
echo "before taking a final snapshot."