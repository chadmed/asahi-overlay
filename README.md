# Asahi Linux Gentoo Overlay

An overlay for Gentoo providing packages to better support Apple Silicon
devices.

## Installing this overlay
If you used my installer script (coming soon), you should not need to
do anything. That script sets up this repo automatically. For all other users:

1. Go clone asahi-gentoosupport.
2. Copy `repo.conf` into `/etc/portage/repos.conf/` and rename the file
`asahi.conf`
3. Run `emaint sync -r asahi`.

## Using this overlay
This overlay takes priority over the main Gentoo ebuild tree, so no
intervention is necessary to install the correct versions of software
for Apple Silicon devices. If, however, you wish to use the vanilla
Gentoo version of any package we override, append `::gentoo` to the
package atom when calling `emerge`. For example, say we provide a patched
Mesa that incorporates things not yet found in the upstream repo...

* To install our version of Mesa, you would run:
```shell
emerge -av mesa
```

* To use the default Gentoo ebuild for Mesa instead, you would run:
```shell
emerge -av media-libs/mesa::gentoo
```

Note the use of the _full_ package atom when specifying a repo.
