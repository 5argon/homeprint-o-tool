# Fine Print Card Studio

A software that can export printer-ready 2-sided layout graphics for card games. Create a "project" once, then you can export it to variety of paper size and specifications matching what your local print shop or your own printer wants.

## Planned Features

- Supports different card rotation "rule" for 2-sided printing. When creating a project you can specify a front and back of each individual card. The output place the backside according to the rule you set so it assembles into the same card.
- Supports reusing the same graphic in different card instance. (e.g. Need only one card back graphic if all cards use the same thing.)
- Hybrid bleed support : The graphic can have bleed on, then you can add more bleed by mirroring the graphic.
- Infinite bleed : You can have as big bleed as you like, it crops automatically depending on how tight the final output layout is. The crop is also independent on vertical and horizontal.
- Can organize cards into groups. It can annotate each card in the output.
- Optimized multiple copies : Fill in empty space of the previous copy to save paper.
- Exclude : Each output can exclude subset of cards by groups or individually without modifying the project.
- Preconfigured output preset as file that author of project can distribute alongside. (e.g. Output on A4 paper.)
- Scaling debugger : Input graphics can be as large or as small as you like. When outputting the project, the debugger shows whether the graphic got enlarged or shrinked, by how many percent, depending on your output format and DPI.

## Project Structure

- `card_studio` : Inside that folder is a [Flutter](https://flutter.dev/) project that builds into the native Windows / macOS app.
