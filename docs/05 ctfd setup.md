# 05 — CTFd Platform Setup

[CTFd](https://ctfd.io/) was used as the challenge platform and live
scoreboard for the event — this covers how it was deployed and configured.

## Deployment

Run locally (organizer's laptop) via Docker:

```bash
git clone https://github.com/CTFd/CTFd.git
cd CTFd
docker compose up -d
```

CTFd listens on port `8000` by default. For the live event, the host was
made reachable to participants over a dedicated hotspot (see
[04-infrastructure.md](04-infrastructure.md)) rather than the open internet —
this is a closed, single-event scoreboard, not a public-facing service.

## Configuration

- **Mode:** Users (individual/solo), not Teams — matches the event's
  individual-participation format
- **Visibility:** challenges set to Visible from the start, so participants
  can see what's ahead even before unlocking it
- **Scoring:** 5 challenges across 3 categories (Enumeration, Web
  Exploitation, Privilege Escalation), 50 / 100 / 150 / 200 / 250 points,
  750 total

## Progressive unlock (challenge chaining)

Each challenge after the first was configured with a **Requirement**
pointing at the previous challenge, so Flag 2 doesn't appear on the
scoreboard until Flag 1 is solved, and so on. In CTFd's admin panel this is
set per-challenge under:

```
Challenges → [challenge] → Edit Challenge → Requirements → select the prerequisite challenge
```

This was the main reason a **non-admin test account** was used to verify
behavior — CTFd's admin/hidden-user view bypasses requirement checks
entirely, so everything looks unlocked and solvable from an admin session
regardless of whether the chaining is actually configured correctly. Testing
as an ordinary registered user was the only way to confirm participants
would actually see the intended progressive unlock.

## Flags

Each challenge's flag was set as a **Static** flag (exact match,
case-sensitive), entered by copy-pasting the value directly from the target
VM's output rather than retyping it — retyping had already introduced one
typo during manual editing of the VM itself, so the same risk was avoided
here by never hand-typing a flag value twice.

## Verification pass

Before going live, a full run was done with a disposable test account:

1. Register a normal (non-admin) account
2. Confirm only Flag 1's challenge is visible initially
3. Submit an intentionally wrong/old flag → confirm "Incorrect" (this
   catches a leftover duplicate flag entry from an earlier placeholder,
   which would otherwise let a stale value still be accepted)
4. Submit the real Flag 1 value → confirm "Correct", points awarded, and
   Flag 2 becomes visible
5. Repeat through Flag 5, confirming the score reaches the full 750 and
   each flag unlocks the next in order

The test account and its submissions were deleted afterward so the live
scoreboard started clean for real participants.