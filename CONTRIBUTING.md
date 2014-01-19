Contributing to Tigerbrew
=========================

Reporting Bugs
--------------
First, please run `brew update` and `brew doctor`.

Second, read the [Troubleshooting Checklist](https://github.com/Homebrew/homebrew/wiki/troubleshooting).

**If you don't read these it will take us far longer to help you with your problem.**

Writing formulae
----------------
Please read:

* [Formula Cookbook](https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook)
* [Ruby Style Guide](https://github.com/styleguide/ruby)

Tigerbrew guidelines
--------------------

* Check [the wiki](https://github.com/mistydemeo/tigerbrew/wiki/Tigerbrew-features) for information on Tigerbrew-specific features, like determining PPC CPU type.

* Don't break Intel builds when contributing PPC fixes. We support Intel Tiger, and in general try to avoid breaking anything that works in Homebrew.

* Try to avoid breaking builds on newer OSs when you submit fixes for Tiger and Intel.
