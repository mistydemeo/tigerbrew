Tigerbrew
=========

A little experimental fork of [Homebrew][homebrew] that adds support for PowerPC Macs, and Macs running Tiger (or Leopard).

Installation
============

Paste this into a terminal prompt:

```sh
ruby -e "$(curl -fsSkL raw.github.com/mistydemeo/tigerbrew/go/install)"
```

You'll also want to make sure that /usr/local/bin and /usr/local/sbin are in your PATH. (Unlike later Mac OS versions, /usr/local/bin isn't in the default PATH.) If you use bash as your shell, add this line to your ~/.bash_profile:

```sh
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
```

What Packages Are Available?
----------------------------
1. You can [browse the Formula directory on GitHub][formula].
2. Or type `brew search` for a list.

More Documentation
------------------
`brew help` or `man brew` or check our [wiki][].

FAQ
---

### How do I switch from homebrew?

Run these commands from your terminal. You must have git installed.

```
cd `brew --repository`
git remote rm origin
git remote add origin https://github.com/mistydemeo/tigerbrew.git
git fetch origin
git reset --hard origin/master
```

### Something broke!

Many of the formulae in the repository have been tested, but there are still many that haven't been tested on Tiger and/or PowerPC yet. If something doesn't work, [report a bug][issues] (or submit a [pull request][prs]!) and we'll get it working.

Credits
-------

Homebrew is originally by [mxcl][mxcl], a splendid chap. This fork is by @mistydemeo, incorporating some code originally written by @sceaga.

License
-------
Code is under the [BSD 2 Clause (NetBSD) license][license].

Donations
---------
We accept tips through [Gittip][tip].

[![Gittip](http://img.shields.io/gittip/mistydemeo.svg)](https://www.gittip.com/mistydemeo/)

<<<<<<< HEAD
[Homebrew]:http://brew.sh
[wiki]:https://github.com/mistydemeo/tigerbrew/wiki
[mxcl]:http://twitter.com/mxcl
[formula]:https://github.com/mistydemeo/tigerbrew
[license]:https://github.com/mistydemeo/tigerbrew/blob/master/Library/Homebrew/LICENSE
[issues]:https://github.com/mistydemeo/tigerbrew/issues
[prs]:https://github.com/mistydemeo/tigerbrew/pulls
[tip]:https://www.gittip.com/mistydemeo/
=======
[home]:http://brew.sh
[wiki]:https://github.com/Homebrew/homebrew/wiki
[mistydemeo]:https://github.com/mistydemeo
[adamv]:https://github.com/adamv
[jacknagel]:https://github.com/jacknagel
[mikemcquaid]:https://github.com/mikemcquaid
[asparagui]:https://github.com/asparagui
[mxcl]:https://github.com/mxcl
[formula]:https://github.com/Homebrew/homebrew/tree/master/Library/Formula/
[braumeister]:http://braumeister.org
[license]:https://github.com/Homebrew/homebrew/tree/master/Library/Homebrew/LICENSE
[tip]:https://www.gittip.com/Homebrew/
>>>>>>> Homebrew/master
