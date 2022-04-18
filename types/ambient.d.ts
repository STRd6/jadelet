import ObservableType from "@danielx/observable"
import JadeletType from "./main"
import assertType from "assert"

declare global {
  var assert: typeof assertType;
  var Observable: typeof ObservableType;
  var makeTemplate: typeof JadeletType["exec"];
  var Jadelet: typeof JadeletType
}
