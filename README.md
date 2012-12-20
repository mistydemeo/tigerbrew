Tigerbrew
=========

A little experimental fork of [Homebrew][homebrew] that adds support for PowerPC Macs, and Macs running Tiger (or Leopard).

Installation
============

Paste this into a terminal prompt:

```sh
ruby -e "$(curl -fsSkL raw.github.com/mistydemeo/tigerbrew/go)"
```

What Packages Are Available?
----------------------------
1. You can [browse the Formula directory on GitHub][formula].
2. Or type `brew search` for a list.
3. Or run `brew server` to browse packages off of a local web server.
4. Or visit [braumeister.org][braumeister] to browse packages online.

More Documentation
------------------
`brew help` or `man brew` or check our [wiki][].

FAQ
---

### Why "experimental"?

This fork is brand-new - I started it a few weeks ago. Most of the essential functionality should be working now, but there's still a lot that hasn't been tested. You can help out by trying it out and reporting anything that doesn't currently work.

### Does it work with Leopard? How about Intel?

The only hardware I have to test with is a PowerPC PowerBook with Tiger. I'd *love* to support Leopard and Intel processors, but since I don't have the hardware I can't proactively work to support them.

I am completely willing to help you if something doesn't work, though. Just write up a bug report and I'll see if I can get it fixed.

### How about Panther (or older)?

Man, I have no idea. Backporting stuff to Tiger is challenging enough, I have a feeling Panther's going to need even more attention. If you have a Panther machine and you really, really want Homebrew... give it a try I guess? Probably you'll need to put a lot of work into making it work.

### Something broke!

Many of the formulae in the repository are currently untested on Tiger and/or PowerPC. If something doesn't work, report a bug (or submit a pull request!) and we'll get it working.

Credits
-------

Homebrew is originally by [mxcl][mxcl], a splendid chap. This fork is by @mistydemeo, incorporating some code originally written by @sceaga.

[homebrew]:http://mxcl.github.com/homebrew
[wiki]:http://wiki.github.com/mxcl/homebrew
[mxcl]:http://twitter.com/mxcl
[formula]:http://github.com/mistydemeo/tigerbrew/tree/master/Library/Formula/
[braumeister]:http://braumeister.org
