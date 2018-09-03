# iOS 11 App Store Transition

Just another attempt to simulate App Store's Card transition:

![demo](https://raw.githubusercontent.com/aunnnn/AppStoreiOS11InteractiveTransition/master/appstoreios11demo.gif)

You can check out my previous approach [here](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition_old). This one is a total rewrite with minor difference in approach. It has better effect/performance, better code organization, and has fixes for some issues found in the previous repo.

*Checkout implementation details in slides under `MobileConf` folder, skip to the last section ('5 Phases of Interaction')*

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

## 5 Phases of Interaction
### 1. Highlighting
- The card cell needs to be very responsive to touch, so we must set `collectionView.delaysContentTouch = false` (it's `true` by default, to prevent premature cell highlighting, e.g., on table view).
- Put scaling down animation in `touchesBegan` and `touchesCancellled/Ended`.
- `.allowsUserInteraction` is needed in animation options, so that you can always continue to scroll immediately while the unhighlighted animation is taking place.

### 2. Before Presenting
- Need to stop all animations, using `cardCell.layer.removeAllAnimations`. Also prevent any future highlighting animation with a flag.
- Get current card frame (that is currently animated scaling down) with `cardCell.layer.presentation().frame`, then convert it to screen coordinates.
- Get presented view controller (`CardDetailViewController`)'s view and position it with AutoLayout at the original card cell's position
- Hide original card cell's position

### 3. Presenting*
- Simply animating frame/AutoLayout constraints with Spring animation won't work.
- Best alternative (that I can think of right now) is to **animate with two different animation curves: linear for card expansion, and spring for moving up to place.**
#### Wait, how to animate different AutoLayout constraints with different animation curves?
- Turns out you can animate different constraints in two animation blocks, like this:
```swift
// Animate constraints on the same view with different animation curves
UIView.animate(withDuration: 0.6 * 0.8) {
  self.widthAnchor.constant = 200
  self.heightAnchor.constant = 320
  self.targetView.layoutIfNeeded()
}
UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
  self.topAnchor.constant = -200
  self.targetView.layoutIfNeeded()
}) { (finished) in ... }
```

### 4. Interactively Dismissing
- Need to handle left screen edge pan and drag down pan.
  - For drag down we'll add a new pan gesture. Make it able to detect *simultaneously* with `scrollView`'s pan.
    - This means we need to carefully handle when the `dragDownMode` begins, save the starting drag point to calculate dragging progress, as it usually begins on `.change`, not `.began`.
  - For left edge pan just use `UIScreenEdgePanGestureRecognizer`.
- Give priority to left edge pan by:
```swift
dragDownPan.require(toFail: leftEdgePan)
scrollView.panGestureRecognizer.require(toFail: leftEdgePan)
```
  - Note that the method `a.require(toFail: b)` is confusingly named. It actually means `a` must *wait* for `b` to fail first before it can start. So just read it like `a.wait(toFail: b)` when you see that.
- To smoothly transition to shrinking mode when reach the top of scroll view, just use scrollView's delegate:
```swift
var draggingDownToDismiss = false // A flag to check mode

func scrollViewDidScroll(_ scrollView: UIScrollView) {
  if draggingDownToDismiss || (scrollView.isTracking && scrollView.contentOffset.y < 0) {
    draggingDownToDismiss = true
    scrollView.contentOffset = .zero // * This is important to make it stick at the top
  }
  scrollView.showsVerticalScrollIndicator = !draggingDownToDismiss
}
```
- Handle shrinking on drag using `UIViewPropertyAnimator`:
```swift
let shrinking = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
  self.view.transform = .init(scaleX: 0.8, y: 0.8)
  self.view.layer.cornerRadius = 16
})
shrinking.pauseAnimation()
```
- Carefully handle `progress/fractionComplete` of the animator by understaning when corresponding gestures are began! Use a combination of `gesture.translation(in: _)` and `gesture.location(in: nil)`, etc.
- Reverse animation on drag down pan gesture ended/cancelled:
```swift
shrinking!.pauseAnimation()
shrinking!.isReversed = true

// Disable gesture until reverse closing animation finishes.
gesture.isEnabled = false
shrinking!.addCompletion { [unowned self] (pos) in
  self.didCancelDismissalTransition()
  gesture.isEnabled = true
}
shrinking!.startAnimation()
```

### 5. Dismissing
- Just do animation back to original cell's position.

### Weird Bugs
- [ ] This is hard to explain, but there's some space on card view top edge during presentation despite constant 0 of their topAnchors. **What's weirder** is that it's already unintentionally fixed by setting a top anchor's constant to value >= 1 (or <= -1). Setting it to any values in the range of (-1, 1) doesn't work.
- [ ] Blur effect view in the back seems to not showing up properly when we're in dismissal pan mode (especially on iOS 12). But sometimes it happens on iOS 11 too! Proobably due to my incomplete understanding of viewWillAppear/beginTransition/redraw life cycle. 
