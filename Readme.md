
# Deathroll Companion

This addon is a simple companion for anyone wanting to gamble their live savings away in WoW through so-called deathrolls.

## Features

Currently the only feature of this addon is the automatic rolling in a deathroll against a single opponent. Also, although you can't currently display them, your stats as to how often and how much gold you win/lose is already being tracked.

### Usage

In order to use the addon you simply have to use the chat commant `/deathroll` (or `/dr` for short):

 - `/deathroll <amount>` will start a deathroll for anyone to join with given amount (in gold) as the bet
 - `/deathroll accept` will accept someone elses invitation to a deathroll (through a roll in chat)

## Installation

This addon is officially available from [its Wago Addons page](https://addons.wago.io/addons/deathrollcompanion), as well as through [GitHub releases](https://github.com/JP1998/DeathrollCompanion/releases). Furthermore you can download the source code directly from [the GitHub repository](https://github.com/JP1998/DeathrollCompanion).

I've chosen these platforms because they are the ones I personally use, and at this time I don't see a reason to create releases for other platforms, as there is no demand. Nonetheless, I understand some people also use WowInterface or CurseForge, so if you'd like me to create releases on any other addon platform please [create an issue on GitHub](https://github.com/JP1998/DeathrollCompanion/issues/new) and I'll look into it.

## Planned features and improvements

 - Actual display of the currently collected stats (e.g. if you target someone and use the command `/deathroll stats` you see your stats in deathrolls against your current target).
 - If you lose a deathroll and you trade your opponent (or they trade you) the gold should automatically be populated. Automatically accepting the trade, however, is neither wished nor possible.
 - Better selection of which deathroll offer you want to accept. If there are multiple rolls that have happened recently you should be able to target someone to accept **their** offer, or just specify your opponents name as an additional argument to the accept command.

## Contribute

You are very welcome to contribute to this repository by cloning it and once you've made changes opening a pull request. I'll take a look at those changes as soon as I am able to.
