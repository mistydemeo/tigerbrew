Tigerbrew
=========

A little experimental fork of [Homebrew][homebrew] that adds support for PowerPC Macs, and Intel Macs running Tiger (or Leopard and Snow Leopard).

Certs are now updated, if you have SSL issues just re-run the installer script below to install more recent certs as of October 2021.

Installation
============

You will first need the newest version of Xcode for your operating system installed. All downloads below will require an Apple Developer account.

* For Tiger that's [Xcode 2.5, available from Apple here](https://developer.apple.com/download/more/?=xcode%202.5)
* For Leopard 10.5 use [Xcode 3.1.4](https://developer.apple.com/services-account/download?path=/Developer_Tools/xcode_3.1.4_developer_tools/xcode314_2809_developerdvd.dmg).
* Snow Leopard 10.6.8 use [Xcode 4.2](https://developer.apple.com/services-account/download?path=/Developer_Tools/xcode_4.2_for_snow_leopard/xcode_4.2_for_snow_leopard.dmg)

A very useful website for finding Xcode releases is [Xcode Releases](https://xcodereleases.com/) which lists every version of Xcode releases, with working links and the version of OSX that supported that release.

On the computer you're reading this on, control or right click this link and save it (the option will be something like "Save Link As" or "Download Linked File" depending on your browser) to disk:

<https://raw.github.com/mistydemeo/tigerbrew/go/install>

Transfer it to your Tiger or Leopard machine along with Xcode.

<!-- Advanced users may wish to use TenFourFox instead -->

Type `ruby` followed by a space into your terminal prompt, then drag and drop the `install` file onto the same terminal window, and press return.

You'll also want to make sure that /usr/local/bin and /usr/local/sbin are in your PATH. (Unlike later Mac OS versions, /usr/local/bin isn't in the default PATH.) If you use bash as your shell, add this line to your ~/.bash_profile:

```sh
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
```

What Packages Are Available?
----------------------------
1. You can [browse the Formula directory on GitHub][formula].
2. Or type `brew search` for a list.
3. Or use `brew desc` to browse packages from the command line.

More Documentation
------------------
`brew help` or `man brew` or check our [wiki][].

FAQ
---

### How do I switch from homebrew?

Run these commands from your terminal. You must have git installed.

```
cd `brew --repository`
git remote set-url origin https://github.com/mistydemeo/tigerbrew.git
git fetch origin
git reset --hard origin/master
```

### Something broke!

Many of the formulae in the repository have been tested, but there are still many that haven't been tested on Tiger and/or PowerPC yet. If something doesn't work, [report a bug][issues] (or submit a [pull request][prs]!) and we'll get it working.

Credits
-------

Homebrew is originally by [mxcl][mxcl], a splendid chap. This fork is by [mistydemeo](https://github.com/mistydemeo), incorporating some code originally written by @sceaga.

License
-------
Code is under the [BSD 2 Clause (NetBSD) license][license].

[Homebrew]:http://brew.sh
[wiki]:https://github.com/mistydemeo/tigerbrew/wiki
[mxcl]:http://twitter.com/mxcl
[formula]:https://github.com/mistydemeo/tigerbrew/tree/master/Library/Formula
[license]:https://github.com/mistydemeo/tigerbrew/blob/master/Library/Homebrew/LICENSE
[issues]:https://github.com/mistydemeo/tigerbrew/issues
[prs]:https://github.com/mistydemeo/tigerbrew/pulls
[tip]:https://www.gratipay.com/mistydemeo/
