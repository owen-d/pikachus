---
title: 'Elitist Quirks: Introducing classicdps.com'
---

## Disclaimer
This is an announcement for classicdps.com, a website which calculates dps and stat prioritizations based on the gear you're currently wearing. If you'd like to avoid me waxing philosophical on why I love theorycrafting and how this project came about, feel free to head over there and bail on the rest of this post :).

## Origin Story
I guess this story starts in the days of TBC. I had just discovered the infamous Elitist Jerks forum and thanks to my high school math classes was able to understand some of the content. I used to pour over the spreadsheets and theorycrafting pages (shoutout to my favorite, the post-2.4 arcane mage theorycrafting [thread](http://web.archive.org/web/20081222150323/http://elitistjerks.com/f31/t25772-mage_raiding_arcane_mage_post_2_4_a/)). Looking back, it's a toss up as to whether I enjoyed theorycrafting or playing the game more.

Fast-forward to present day. I've been programming professionally for a number of years now and had an ~8year stint on private servers (/wave to my old European friends in Enigmatic - Emerald Dream, especially Numielle). It's been phenomenal reading all the guides and technical forum posts that have come out of that scene -- advancing the state of the art for an old but lovable game. I've had some time off work recently and decided to start modeling vanilla game mechanics for fun.

## How it works
Well, it ended up being more fun than I expected, and what's more, it seemed to be working. From a high level, we sequence probability distributions together (i.e. the chance you miss vs hit vs crit) and approximate the resulting dps. It can certainly get complex (see my [post](/posts/2019-07-16-Lifetap.html) on figuring out how often to lifetap), but the foundations are relatively simple.

Once we have an estimation of the dps, it's easy to calculate how much benefit one gets from an additional point of some stat (spell hit, spell damage, you get the idea). That's the crux of the project and is a reactive way to determine stat priorities that adjust based on the gear one is already wearing. 

Right now, we only have support for caster dps classes. Melees will come later, but I prioritized spell-based classes because modeling them is somewhat simpler. Healers are a little more complex than damage dealers because they often aren't concerned with maximizing healing per second (hps) like damage dealers are with dps. Fight mechanics like incoming burst damage and encounter duration come into play, causing different stats to be more or less valuable for different fights. As an example, in longer fights the benefits of spirit, mp5, etc become a lot more valuable to them. Other fights require intense throughput but don't last as long, increasing the benefit of raw +healing and +crit. These considerations make it hard to create blanket statements as to what is "best". I'd like to add support for them, possibly with sliders for fight longevity, but I'm waiting to see how that idea develops. Please let me know if you have suggestions or want this feature.

## What this allows us to do
- Calculate Equivalence Points (EP) on a per-character basis, automatically. We can adjust calculations based on the gear you're already wearing.
- Help loot distribution by looking at the dps benefits gear gives to specific raiders.
- Lays the groundwork for finding ideal stat distributions at different gear tiers for different classes and specs.


## Contact
Feel free to hit me up on Twitter @[castle_vanity](https://twitter.com/castle_vanity) or on the classic theorycrafting discord (caliph). I'm particularly looking for some help finding information like:
- what are the armor/resistance levels for different bosses
- How do certain talents/debuffs interact? Which things are additive and which are multiplicative? What's the order of operations in which they are applied?

Better information helps us build better, more reliable models. Have fun with the classicdps.com!
