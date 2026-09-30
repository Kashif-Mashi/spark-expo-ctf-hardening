# 02 — Remediation

Each unintended exploit path found in [01](01-vulnerability-analysis.md) was
closed individually, then re-tested to confirm the fix held and nothing else
broke.

## CVE-2021-4034 — PwnKit (pkexec)

`pkexec` runs as a setuid-root binary. The bug is in its own argument-handling
logic, so as long as the binary retains its setuid bit, it's exploitable
regardless of any sudoers configuration.

**Fix:** strip the setuid bit so the binary can no longer run with elevated
privileges at all.

```bash
chmod -s /usr/bin/pkexec
```

**Verification:**

```bash
ls -la /usr/bin/pkexec        # confirm no 's' in the permission bits
```

then re-run the public PwnKit exploit against a low-privilege shell and
confirm it no longer returns root.

## CVE-2021-3156 — Baron Samedit (sudo)

Same class of bug: the heap overflow is in `sudo`'s own argument parsing, and
only works because `sudo` itself runs setuid-root. The proper fix is a
version upgrade (≥1.8.31p3 / 1.9.5p2); since this box has no supported
package mirror for its EOL Ubuntu release, the setuid bit was stripped
instead as a functional equivalent.

```bash
chmod -s /usr/bin/sudo
```

**Trade-off, noted deliberately:** this disables `sudo` entirely for every
user on the box, not just the exploit. That's an acceptable trade for this
use case — no participant is meant to have legitimate `sudo` rights anyway —
but it's worth flagging explicitly rather than treating it as a side effect,
since in a different context it would be the wrong fix.

## CVE-2019-7304 — Dirty Sock (snapd)

Same pattern again: `snap-confine` is setuid-root, and the flaw is in `snapd`'s
own command handling.

```bash
chmod -s /usr/lib/snapd/snap-confine
```

## Post-patch verification pass

After all three fixes, a full SUID re-enumeration confirmed none of the
three binaries retained their setuid bit:

```bash
find / -perm -4000 -type f 2>/dev/null
```

The kernel itself (`4.4.0-72-generic`) was also checked against known n-day
kernel exploits (e.g. Dirty COW, CVE-2016-5195) — this build post-dates that
particular fix, but a kernel exploit-suggester pass is recommended before
any future reuse of this base image, since new n-days for old kernels
surface over time.

Finally, the **entire intended 5-flag chain was re-walked end-to-end** after
patching, to confirm none of the fixes had broken legitimate functionality
the challenge depends on (e.g. SSH, the web application, file uploads).