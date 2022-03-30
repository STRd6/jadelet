declare type isString = <T extends unknown>(x: string | T) => x is string;
declare type isObject = <T extends unknown>(x: Object | T) => x is Object;
declare type last = <T extends unknown[]>(array: T) => T[number];

declare interface Element extends HTMLElement, Node {
  checked: boolean
  value: string
  onchange: Function
  oninput: Function
  style: any
};

declare interface JadeletParser {
  parse(string): JadeletASTNode;
}

declare interface JadeletAPI {
  parser: JadeletParser;
  Observable: any;
  _elementCleaners: any;
  dispose: any;
  retain: any;
  release: any;
  compile(source: string, opts?: {
    runtime?: string,
    exports?: string
  }): string;
  parse: JadeletParser["parse"];
  exec(ast: JadeletASTNode | string): (context?: Context) => any;
  define(definitions: any): any;
}

declare type makeTemplate = JadeletAPI["exec"]

declare interface Context {
  [Key: string]: any
}

declare interface Binding {
  bind: string
}

declare type JadeletAttribute = string | { bind: string };

declare interface JadeletAttributes {
  id?: JadeletAttribute[]
  class?: JadeletAttribute[]
  style?: JadeletAttribute[]
  [Key: string]: JadeletAttribute
};

declare type JadeletASTNode = [string, JadeletAttributes, JadeletAST[]]
declare type JadeletAST = JadeletASTNode | JadeletAttribute;

declare const Jadelet: JadeletAPI;
declare const assert: any;

declare type Observable = (x: any) => (x: any) => any

declare module "parser.hera" {

}
