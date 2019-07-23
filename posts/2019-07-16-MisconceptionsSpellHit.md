---
title: 'Classic WoW misconceptions chapter 1: Spell Hit vs Spell Crit'
---

## Prelude
As I've been building [classicdps.com](https://classicdps.com), I've noticed things which seem inconsistent with the common rhetoric in the private server/WoW classic space. I thought it'd be a fun to start a series which tries to overturn some of these dogmas, or at least cause a little hesitation about holding such strong opinions.

## Spell Hit
I often run numbers through the program to get a feel for it. One thing I noticed a while back was that hit chance didn't work quite as I expected. It's common to hear "max your spell hit chance as your top priority, then prioritize other stats". However, for certain gear combinations, I was surprised to see that gaining 1% spell hit could be eclipsed by other stats, namely 1% crit. We'll be talking about warlocks again, so let's get started.

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

Interesting. At this gear point, the gap widens in favor of spell hit.

### Side note
Why would the gap widen in favor of spell hit? We certainly aren't crit-capped at 10% crit.
I suspect this is due to the benefits of improved shadowbolt, namely a 20% increase to the next 4 shadow spells. As a warlocks crit chance increase, so does their chance to clip existing improved shadow bolt charges by critting again (thus effectively losing the remaining charges, although replacing them with new ones).

Back to the problem at hand: let's give our warlock a strong 9% hit chance.
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

## Going deeper - What about warlocks that _don't_ cast curse of doom
The following is not demonstrated on [classicdps](https://classicdps.com) (there are no talent/spell rotation integrations yet and all warlocks are assumed to use curse of doom).

It turns out for virtually all realistic levels of gear that spell crit eclipses spell hit when curse of doom is not in the rotation. This is because we attribute the raid dps increase from improved shadowbolt to the warlock that caused it. The first percent of spell hit becomes more valuable than spell crit at around ~27-29% crit chance, depending on other stats.

This is because curse of doom is a huge dps gain, but it cannot crit. Therefore it gains an outsized benefit from spell hit compared to spell crit. Once it's removed from the rotation, spell hit looks relatively less beneficial as it's not being carried by the curse.

Well, that's it. I hope you've enjoyed the first in this series -- I plan to post more unconventional quirks as I discover them.

## TL;DR:
When the warlock is casting curse of doom:
- Spell hit outperforms spell crit by roughly 10% at most gear levels until curse of doom is hit-capped. Afterwards, crit outperforms hit.
When the warlock isn't casting curse of doom:
- Spell crit outperforms spell hit when including raid dps benefits at almost all gear levels. This changes at about 27-29% crit chance assuming low hit chance.
