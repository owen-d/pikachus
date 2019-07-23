---
title: 'Elitist Quirks: Introducing classicdps.com'
---

## Disclaimer
This is an announcement for [classicdps.com](https://classicdps.com), a website which calculates dps and stat prioritizations based on the gear you're currently wearing. If you'd like to avoid me waxing philosophical on why I love theorycrafting and how this project came about, feel free to head over there and bail on the rest of this post :).

## Origin Story
This story starts in the days of TBC. I had just discovered the infamous Elitist Jerks forum and thanks to my high school math classes was able to understand some of the content. I used to pour over the spreadsheets and theorycrafting pages (shoutout to my favorite, the post-2.4 arcane mage theorycrafting [thread](http://web.archive.org/web/20081222150323/http://elitistjerks.com/f31/t25772-mage_raiding_arcane_mage_post_2_4_a/)). Looking back, it's a toss up as to whether I enjoyed theorycrafting or playing the game more.

Fast-forward to present day. I've been programming professionally for a number of years now and had an ~8year stint on private servers (/wave to my old European friends in Enigmatic - Emerald Dream, especially Numielle). In my time away from retail, the theorycrafting didn't slow down, but rather picked up -- perhaps stimulated by private server quirks/bugs. It's been phenomenal reading all the guides and technical forum posts that have come out of that scene,  advancing the state of the art for an old but lovable game. I figure it's about my time to contribute; I've had some time off work recently and decided to start modeling vanilla game mechanics for fun.

## How it works
I wanted to build something that _estimated_ combat. I didn't want to simulate rounds and rounds of combat and spell interactions, but rather try to model combat without actually _performing_ it. I started small, avoiding complicated melee combat for the simpler spell based mechanics. It ended up being more fun than I expected, and what's more, it seemed to be working.

At a high level, we sequence probability distributions together and approximate the resulting dps. It can certainly get complex (see my [post](/posts/2019-07-16-Lifetap.html) on figuring out how often to lifetap), but the foundations are relatively simple. For example, a character's class and gear will determine the probability distribution of spells they're likely to cast, which in turn can be transformed into a distribution of of the spell results (i.e. the chance to miss vs hit vs crit).

Once we have an estimation of the dps, it's easy to calculate how much benefit one gets from an additional point of some stat (spell hit, spell damage, you get the idea). That's the crux of the project and is a reactive way to determine stat priorities that adjust based on the gear one is already wearing. An astute reader may notice that these stat priority values are the partial derivatives of one's dps with respect to some stat.

## Limitations
Right now, we only have support for caster dps classes. Melees will come later, but I prioritized spell-based classes because modeling them is somewhat simpler. 

## What this allows us to do
- Calculate Equivalence Points (EP), or how much benefit one stat gives relative to other stats on a per-character basis, automatically. It adjusts calculations based on the gear you're already wearing.
- Help loot distribution by looking at the dps benefits gear gives to specific raiders.
- Lays the groundwork for finding ideal stat distributions at different gear tiers for different classes and specs.

## What about healers?
Healers are a little more complex than damage dealers because they often aren't concerned with maximizing healing per second (hps) like damage dealers are with dps. Fight mechanics like incoming burst damage and encounter duration come into play, causing different stats to be more or less valuable for different fights. As an example, in longer fights the benefits of spirit, mp5, etc become a lot more valuable to them. Other fights require intense throughput but don't last as long, increasing the benefit of raw +healing and +crit. These considerations make it hard to create blanket statements as to what is "best". I'd like to add support for them, possibly with sliders for fight longevity, but I'm waiting to see how that idea develops. Please let me know if you have suggestions or want this feature.

## Contact
Feel free to hit me up on Twitter @[castle_vanity](https://twitter.com/castle_vanity) or on the classic theorycrafting discord (caliph). I'm particularly looking for some help finding information like:
- what are the armor/resistance levels for different bosses
- How do certain talents/debuffs interact? Which things are additive and which are multiplicative? What's the order of operations in which they are applied?

Better information helps us build better, more reliable models. Have fun with [classicdps](https://classicdps.com)!
