# Spark Expo CTF — Boot2Root VM Hardening & Event Infrastructure

Write-up on hardening, customizing, and deploying a Boot2Root machine for a live,
university-wide Capture the Flag competition (Spark Expo, University of Sargodha),
run as a selection round for NaSCon's Red Team CTF.

**Base machine:** [JIS-CTF: VulnUpload](https://www.vulnhub.com/entry/jis-ctf-vulnupload,228/)
(VulnHub, Ubuntu 16.04) — used as a starting point and substantially modified
before use in a live competition (see below).

> **Note on flags:** All literal flag values in this repo are redacted
> (`XXXXXXXXXXXXXXXXXXXXX`). This machine is reused for future selection
> rounds, so exact answers are intentionally withheld — everything else
> (methodology, commands, CVEs, design decisions) is documented in full.

## What this covers

The base VM, as published, only required an unauthenticated login bypass and
a file upload vulnerability to reach a low-privileged shell — no real
privilege escalation was required to capture the final flag, and the
underlying OS shipped with several years-old, unpatched local-root
vulnerabilities that would let anyone with a copy of the VM bypass the
intended challenge chain entirely with public exploit tooling.

This repo documents the process of turning it into something suitable for a
live, competitive, red-team-style event:

| Doc | Covers |
|---|---|
| [`docs/01-vulnerability-analysis.md`](docs/01-vulnerability-analysis.md) | Recon of the base machine, the intended flag chain, and the *unintended* vulnerabilities found in the base image |
| [`docs/02-remediation.md`](docs/02-remediation.md) | Patching the unintended local-root CVEs without breaking the intended challenge |
| [`docs/03-custom-privesc-design.md`](docs/03-custom-privesc-design.md) | Designing a genuine, from-scratch privilege-escalation challenge (GTFOBins-based) to replace the trivial original path |
| [`docs/04-infrastructure.md`](docs/04-infrastructure.md) | Web-path/flag obfuscation, CTFd scoring integration, QA process, and event-day network architecture for ~10 simultaneous participants |
| [`docs/05-ctfd-setup.md`](docs/05-ctfd-setup.md) | Deploying and configuring CTFd itself — challenge chaining, scoring, and the verification pass before going live |

Supporting scripts (commands used, flag values redacted):

- [`scripts/harden.sh`](scripts/harden.sh) — all customization/hardening commands in one place
- [`scripts/verify.sh`](scripts/verify.sh) — the verification pass run after every change

## Tech stack

`VirtualBox` · `Ubuntu 16.04 LTS` · `Apache / PHP` · `CTFd` (challenge platform & scoreboard) · `Kali Linux` (attacker tooling) · `nmap`, `gobuster`, `GTFOBins` methodology

## Outcome

- 5 progressive flags (750 points) spanning Enumeration, Web Exploitation, and
  Privilege Escalation, unlocking in order via CTFd's challenge-requirement chaining
- All three unintended local-root exploit paths in the base image closed and re-verified
- A custom, from-scratch privilege-escalation challenge replacing the original's
  trivial path
- Deployed live to ~10 simultaneous participants, each in an isolated
  attack environment, with a centrally hosted live scoreboard