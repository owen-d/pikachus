---
title: 'Classic WoW misconceptions chapter 1: Spell Hit vs Spell Crit'
---

## Prelude
As I've been building classicdps.com, I've noticed things which seem inconsistent with the common rhetoric in the private server/WoW classic space. I thought it'd be a fun to start a series which tries to overturn some of these dogmas, or at least cause a little hesitation about holding such strong convictions.

## Spell Hit
Often while developing classicdps.com I'll run numbers through the program to get a feel for it. One thing I noticed a while back was that hit chance didn't work quite as I expected. It's common to hear "max your spell hit chance as your top priority, then prioritize other stats". However, for certain gear combinations, I was surprised to see that gaining 1% spell hit could be eclipsed by other stats, namely 1% crit. We'll be talking about warlocks again, so let's get started.

We're going to be looking at the dps gained by adding 1% of spell crit vs 1% of spell hit for warlocks with 300 spell damage.

Gearset 1: 300 spell damage, 0% crit, 0% hit.
```
dps (warlock): 406.10648 -> expected dps at this gear level
(SpellHit,4.6422424) -> dps gained by adding 1% spell hit
(SpellCrit,4.2705383) -> dps gained by adding 1% spell crit
```

Ok, spell hit edges out crit here. 0% crit isn't even attainable though. At 60 a warlock will have a base crit chance, let's guess ~10%.
Gearset 2: 300 spell damage, 10% crit, 0% hit.
```
dps (warlock): 448.09277
(SpellHit,4.7948)
(SpellCrit,4.102356)
```

Interesting. At this gear point, the gap widens in favor of spell hit. I'm guessing why they were so close earlier is due to the benefits of improved shadowbolt that warlocks get, namely a 20% increase to the next 4 shadow spells. However, as a warlocks crit chance increase, so does their chance to clip existing improved shadow bolt charges by critting again (thus effectively losing the remaining charges, although replacing them with new ones).

Now let's give our warlock a strong 9% hit chance.
Gearset 3: 300 spell damage, 10% crit, 9% hit.
```
dps (warlock): 491.24564
(SpellHit,4.794739)
(SpellCrit,4.215576)
```

This all seems in line with hit > crit right? Let's try one more example:
Gearset 4: 300 spell damage, 10% crit, 10% hit.
```
dps (warlock): 496.04037
(SpellHit,3.5812378)
(SpellCrit,4.2281494)
```

What happened? Spell crit just jumped past spell hit! More appropriately, spell hit slowed down. This took me a while to figure out and I almost missed it by attributing it to improved shadowbolt and ruin causing crit to jump ahead of hit.

## Who's behind the mask?
Currently, warlocks are coded with an SM/Ruin variant and have 3 points in suppression. We also assume they'll be casting curse of doom instead of Elements or Shadow. The three points in suppression yield 6% spell hit for affliction spells only (curses count). Therefore, affliction spells reach hit cap at 10% hit from gear! Once that threshold has been reached, curses no longer glean any benefit from spell hit and crit eclipses hit. This is great news for many warlocks -- no need to stress over trying to get the near impossible 16% hit, but don't worry, 10% will be hard enough to maintain :).

Well, that's it. I hope you've enjoyed the first in this series -- I plan to share more data that contradicts common dogmas as I come across it.

## TL;DR:
Spell hit outperforms spell crit by roughly 10% at most gear levels until capped, with one caveat:
If the warlock is using curse of doom and has points in the affliction talent Suppression (gives spell hit), crit outperforms hit once spell capped for affliction spells.
