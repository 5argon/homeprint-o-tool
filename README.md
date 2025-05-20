# Homeprint O'Tool

![Uncut Sheet](documentation/image/uncut-sheet.jpg)

A desktop software that creates duplex ["uncut sheet"](https://en.wikipedia.org/wiki/Uncut_currency_sheet) image files out of individual graphics.

Uncut sheet is similar to "contact sheet", but they have cut guidelines along the edge, and graphic has [bleed area](https://en.wikipedia.org/wiki/Bleed_(printing)) extending outside of its intended content area to account for duplex printing misalignments or cutting errors. You define bleed area of each graphics inversely by their content area instead (specify the part you want).

Though you can use this program to layout anything you like, such as photos that you don't need to care about the back side at all, it is originally designed to print card game graphics. From this point on I'll refer to each unit of printing as a "card", and the front and back graphic of the card is "front face" and "back face" respectively.

It only creates `.png` files of the front side and back side of the uncut sheets. If you need them in other formats like `.pdf`, you must process them further in other programs on your own. Please be aware of how different printers and printing softwares pair up duplex pages so you don't ended up having wrong back face pairings when they are different.


## Walkthrough

- [General Walkthrough](documentation/walkthrough.md)
- [Special Walkthrough for Arkham Horror: The Card Game players](/documentation/ahlcg.md)

## Project's State

This is my first experience with Flutter and Dart and that's my personal secondary objective of this project. You can expected the code not looking professional.

It is currently in beta perhaps with many rough edges in UI and UX, but it can complete its job.

Known issues are posted in the Issues section, which you can contribute if you are interested, or you can read them to avoid the issue while you use the app.