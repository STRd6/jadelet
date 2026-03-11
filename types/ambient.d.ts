import ObservableType from "@danielx/observable"
import type Jadelet from "../source/index.civet"
import assertType from "assert"

declare global {
  // Test helpers
  var Event: typeof Event;
  var Jadelet: Jadelet
  var Observable: typeof ObservableType;
  var assert: typeof assertType;
  var dispatch: (element: Element, eventName: string, options?: Object) => boolean
  var makeTemplate: typeof Jadelet["exec"];

  interface Element {
    innerText: string
  }
}
