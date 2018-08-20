# AppStoreiOS11Transition

Just another attempt to simulate App Store's Card transition.

![demo](https://raw.githubusercontent.com/aunnnn/AppStoreiOS11InteractiveTransition/master/appstoreios11.gif)

You can also check out my previous approach [here](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition_old). This one is a total rewrite and has better effect/performance/code.

## Overview
All is done with native APIs (`UIViewControllerAnimatedTransitioning`, etc.), no external libraries. This is **not** a library to install or use, it's an experiementation/demo project to show how such App Store presentation might work.

Interesting transitioning stuffs here:
- `PresentCardAnimator`: Animation code for presentation,
- `DismissCardAnimator`: Animation code for dismissal,
- `CardPresentationController`: Blur effect view and overall aspect of the presentation,
- `CardDetailViewController`: Interactive shrinking pan gesture code.

## Features (that you might not know exist)
- [x] Very responsive card cell highlighting animation
- [x] Bouncing up card animation using container view + AutoLayout
- [x] Damping/duration depends on how far the card needs to travel on screen
- [x] Support drag down to dismiss when reach the top of content page
- [x] Support transition back to scroll when you scroll back up to cancel the dismissal
- [x] Support left screen edge pan gesture 
- [x] 

Here are some implementation details:

### HomeViewController
- The card cell needs to be very responsive to touch, so we must set `collectionView.delaysContentTouch = false` (it's `true` by default, to prevent premature cell highlighting, e.g., on table view),
- Then in `touchesBegan` and `touchesCancellled/Ended` I add highlighting animation code there,
- `.allowsUserInteraction` is needed in highlighting animation, so that you can continue to scroll immediately while the unhighlighted animation is taking place.

### Presentation
- TBD...

### Dismissing
- TBD...
