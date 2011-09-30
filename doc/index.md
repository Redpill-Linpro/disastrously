# Welcome to Disastrously

Disastrously is an incident tracker written for Redpill Linpro.


## Documentation

[Background](background.md)

:   Information on how Disastrously came about.

[Status](status.md)

:   Current development status.

[Install](install.md)

:   Information on installing and deploying Disastrously.

[Development](development.md)

:   Information useful to developers.

[User documentation](user.md)

:   Information on using Disastrously.


# Redpill Linpro

[Open source](opensource.md)

:   Issues and TODOs surrounding open sourcing Disastrously.

[Wiki](https://wiki.redpill-linpro.com/Disastrously)

:   In-house documentation (sysop doc etc.).


It is recommended that you use a copy of the production database during
testing, check out the Development doc above.

Remember that we're going to open the code, so anything specific to Redpill
Linpro has to be kept seperate. The plan is most likely to have a
redpill-linpro branch that contains our specific changes and acts as our
internal master, let staging branch off redpill-linpro, and let master be the
official and public vendor branch. When vendor changes are made, add those to
master and merge master into our own redpill-linpro branch.
