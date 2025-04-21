# Homeprint O'Tool

A desktop software that creates duplex "uncut sheet" image files out of individual card graphics. Uncut sheet is similar to "contact sheet" but they have cut guidelines along the edge and graphic has bleed area extending outside of its intended content area to account for duplex printing misalignments or cutting errors.

It only creates `.png` files of the front side and back side of the uncut sheets. If you need them in other formats like `.pdf`, you must process them further on your own. Please be aware of how different printers and printing softwares pair up duplex pages so you don't ended up having wrong card back pairings when they are different.

Not just for printing at home. Some local, less professional print shop acutally has capable printers, but refuses to take in a bunch of individual card images with bleeds and different card backs, and you ask them to make into double sided cards. They understandably only used to their regular service of making business cards in bulk where they look the same with solid color bleeds and don't want any unnecesary hassle of manufacturing card games with more rooms for errors like wrong card back pairing. With this app instead of giving up, you can talk with them about bringing a ready-to-print uncut sheet file and they just print and cut, they might be more willing to do since that's even less work than business cards making that they have to layout on their own. I have managed to turn one regular print shop around here into my personal custom content printing service with this app.

## Walkthrough

- [General Walkthrough](documentation/walkthrough.md)
- [Special Walkthrough for Arkham Horror: The Card Game players](/documentation/ahlcg.md)

## Project's State

It is currently WIP with many rough edges in UI and UX, but it can complete its job if you avoid all the issues as I'm right now playing with the cards laid out from this program. This is also my first experience with Flutter and Dart and that's my personal secondary objective of this project. You can expected the code not looking professional. Known issues are posted in the Issues section, which you can contribute if you are interested, or you can read them to avoid the issue while you use the app.

## Main Sections

- **Project** : Program can read a project specification from a `.json` text file. Inside has instructions how it collects individual card images stored in *relative path* to that `.json` file, along with expected quantity per set of each card, card's content area so it also knows what is considered the bleeds, and ability to group them into sets which make the consumer of this project able to browse and pick just the sets they want.

This program has toolings to author this `.json` file so you can distribute it along with the card images to those who would print the cards at home. Because it uses relative path, it is also possible to author and distribute just the `.json` file to be placed next to a folder of card graphics that others have made but is out of your control.

Any card's front face or back face in the project can "reference" a card face defined separately, called a "symbol". This is mainly to be used as a card back so any correction to this graphic reflects throughout the project. This is also important for the consumer: if they are printing cards at home to be integrated with official-quality cards their printer is often not quite up to par with the official ones. The card back will tell which cards they printed at home. What they can do is to perform color matching of the card backs so they blends better when faced down. With this feature, they only have to edit one central image file.

- **Printing** : For consumer side of the `.json` project file, they'd be able to specify page settings such as paper size or printing margins to match their printer's abilities. They can fine tune how long the cutting guides along the edge are, or increase the gap between cards for easier cutting operation by sacrifice a row or a column from the sheet.

After layout setup is done, they can pick cards from the project in a unit of groups that the project's author defined, or pick an individual card one by one. Consumer can flexibly plan on an exact sequence of cards that will appear on the page, sometimes in a way that the `.json` project's author wasn't expecting.

For example for an A4 paper size that can fit 9 standard cards, if they wanted 1 deck of 52-card playing cards, they would need 6 pages of cards in sequential order, and will have 2 empty spots on the final page that they can select any extra card to fill up. With toolings in this app they can see exactly which page the card ended up on. This might be critical if their printer is not perfect and tends to make error on the same spot, so they could choose the right extra card to add at the end if it ended up screwing the print at that problematic spot.

If they instead wanted 8 decks of 52-cards playing cards, with the same `.json` project file, they can change up the arrangement on their own so one page consists of 9 copies of the same card, and print 52 pages. They would have 9 decks in the end if the printing and cutting were perfect.

It is also common after you finished cutting everything you wanted, you missed some cuts along with printer skewed something in different cards inside each sets you make, and you require a 2nd printing run consisting of only cards that replace those defects. With individual card picking instead of picking by group, it is easy to generate this final patching uncut sheet.