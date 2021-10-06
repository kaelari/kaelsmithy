# kaelsmithy
Kael Smithy is a card game in which cards level up as you play them. The server includes all rules enforcement. The client is not included due to legal complications. The client I used uses art files from the asset store which I can't redistribute by themselves. The code from the client which was written by me is included in the hopes it'll be useful.



How to get this running
Requires a mod-perl server which should load platform/shared.pm and game/gameshared.pm on startup.
You'll need to use the SQL files to create a database for the game. KS_game holds the game data. KS_cards holds the card data, KS_platform holds user data.
Only KS_cards comes with data included. This is intended to show how cards can be created. The system is still limited but is capable of some things.
You'll need a client. One is not included. The scripts for a client are included but are not enough on their own. Creating a client is beyond the scope of this document.

If you want help with anything you can contact me but i make no promise of actually being helpful. my Discord server is: https://discord.gg/gnmGj9R

If you use this for anything credit would be appreciated but is not required. 


