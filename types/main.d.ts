import Observable from "@danielx/observable";
import { Definitions, exec, JadeletParser } from "./types";

declare const Jadelet: {
  Observable: typeof Observable;
  parser: JadeletParser;
  _elementCleaners: any;
  dispose: any;
  retain: any;
  release: any;
  compile(source: string, opts?: {
    runtime?: string,
    exports?: string
  }): string;
  parse: JadeletParser["parse"];
  exec: exec;
  define(definitions: Definitions): typeof Jadelet;
}

export = Jadelet
