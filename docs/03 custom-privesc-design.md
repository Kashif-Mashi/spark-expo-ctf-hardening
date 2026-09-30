# 03 — Designing a Custom Privilege-Escalation Challenge

## Why this was necessary

Once the three unintended exploit paths were closed (see
[02](02-remediation.md)), the base machine had a problem in the other
direction: **the published version never required real privilege escalation
at all.** The final flag was reachable simply by SSHing in as the
low-privileged user (`technawi`) whose credentials were disclosed via
`hint.txt`. For a competition explicitly meant to select participants for a
Red Team CTF, "capture the flag by logging in" doesn't test the skill it's
supposed to test.

## Design

**1. Move the final flag out of reach of a low-privileged user.**

```bash
mv /var/www/html/flag.txt /root/root.txt
```

The flag content itself was then replaced (value redacted below) so it could
only be read by root, or by a user who has actually escalated:

```bash
echo "Flag 5: {XXXXXXXXXXXXXXXXXXXXX}" > /root/root.txt
```

**2. Create a genuine, discoverable misconfiguration.**

Rather than leaving a known CVE as the "intended" path (which would have the
same public-writeup problem described in
[04](04-infrastructure.md)), a classic **GTFOBins-style SUID
misconfiguration** was built from scratch:

```bash
cp /usr/bin/find /usr/local/bin/system_backup
chmod u+s /usr/local/bin/system_backup
```

This copies the `find` binary — which has a well-documented
[GTFOBins](https://gtfobins.github.io/gtfobins/find/) privilege-escalation
technique — to an innocuous-looking name and grants it the setuid bit. The
binary is functionally identical to `find`; only the name changes, so the
underlying exploitation technique is unaffected.

## Intended solve path

A participant with a foothold as `technawi` is expected to:

1. Enumerate SUID binaries: `find / -perm -4000 -type f 2>/dev/null`
2. Notice `/usr/local/bin/system_backup` — a non-standard binary with the
   setuid bit set, sitting alongside expected system binaries
3. Recognize (via inspection, `file`, or behavior testing) that it behaves
   identically to `find`, and recall or look up the corresponding GTFOBins
   technique
4. Exploit it directly:

   ```bash
   /usr/local/bin/system_backup . -exec /bin/sh -p \; -quit
   ```

   `find`'s `-exec` flag, combined with `-p` (preserve privileges) on the
   spawned shell, yields a root shell.

5. Read the flag from `/root/root.txt`

## Why this design choice

This mirrors a class of misconfiguration red-teamers genuinely encounter —
an unexpected setuid binary that requires recognizing an exploitation
*pattern* rather than running an off-the-shelf CVE script — which fits the
event's purpose (selection for a Red Team CTF) better than relying on a
publicly patched, tool-automated exploit.