# iOS 11 App Store Transition

Just another attempt to simulate App Store's Card transition:

![demo](https://raw.githubusercontent.com/aunnnn/AppStoreiOS11InteractiveTransition/master/appstoreios11demo.gif)

You can check out my previous approach [here](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition_old). This one is a total rewrite with minor difference in approach. It has better effect/performance, better code organization, and has fixes for some issues found in the previous repo.

## Overview
All is done with native APIs (`UIViewControllerAnimatedTransitioning`, etc.), no external libraries. This is **NOT a library** to install or ready to use, it's an experiementation/demo project to show how such App Store presentation might work.

Interesting transitioning stuffs here:
- `PresentCardAnimator`: Animation code for presentation,
- `DismissCardAnimator`: Animation code for dismissal,
- `CardPresentationController`: Blur effect view and overall aspect of the presentation,
- `CardDetailViewController`: Interactive shrinking pan gesture code.

## Features (that you might not know exist!)
- [x] Status bar animation
- [x] Very responsive card cell highlighting animation
- [x] Card bouncing up animation (Two animations at work: spring for moving to place, linear for card expansion)
- [x] Damping and duration depends on how far the card needs to travel on screen
- [x] Drag down to dismiss when reach the top of content page
  - [x] Scroll back up to cancel the dismissal!
- [x] Left screen edge pan to dismiss

## TODOs
- [ ] Fix layout/top area on iPhone X
- [ ] Support continuous video/gif playing from home to detail page (This requires some work to use a whole view controller as a card cell content from the first page!)
- [ ] Add blurry close button at the top right of detail page
- [ ] Perfecting card bouncing up animation (still can't figure out how to achieve that *smooth bounciness* like the App Store.)

Here are some implementation details:

### HomeViewController
- The card cell needs to be very responsive to touch, so we must set `collectionView.delaysContentTouch = false` (it's `true` by default, to prevent premature cell highlighting, e.g., on table view),
- Then in `touchesBegan` and `touchesCancellled/Ended` I add highlighting animation code there,
- `.allowsUserInteraction` is needed in highlighting animation, so that you can continue to scroll immediately while the unhighlighted animation is taking place.

### Presentation
- TBD...

### Dismissing
- TBD...

### Weird Bugs
- [ ] This is hard to explain, but there's some space on card view top edge during presentation despite constant 0 of their topAnchors. **What's weirder** is that it's already unintentionally fixed by setting a top anchor's constant to value >= 1 (or <= -1). Setting it to any values in the range of (-1, 1) doesn't work.
- [ ] Blur effect view in the back seems to not showing up properly when we're in dismissal pan mode (especially on iOS 12). But sometimes it happens on iOS 11 too! Proobably due to my incomplete understanding of viewWillAppear/beginTransition/redraw life cycle. 
