import ObservableType from "@danielx/observable"
import JadeletType from "./main"
import assertType from "assert"

declare global {
  // Test helpers
  var Event: typeof Event;
  var Jadelet: typeof JadeletType
  var Observable: typeof ObservableType;
  var assert: typeof assertType;
  var dispatch: (element: Element, eventName: string, options?: Object) => boolean
  var makeTemplate: typeof JadeletType["exec"];

  interface Element {
    innerText: string
  }
}
