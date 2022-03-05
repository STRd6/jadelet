interface JadeletAPI {
  parser: JadeletParser;
  Observable: any;
  _elementCleaners: any;
  dispose: any;
  retain: any;
  release: any;
  compile(source: string, opts?: {
    runtime?:string,
    exports?:string
  }): string;
  parse: JadeletParser["parse"];
  exec(ast: JadeletASTNode|string): (context?: Context) => any;
  define(definitions: any): any;
}

declare const makeTemplate: JadeletAPI["exec"];

interface Context {
  [Key: string]: any
}

interface Binding {
  bind: string
}

type JadeletAttribute = string | {bind: string};

interface JadeletAttributes {
  id?: JadeletAttribute[]
  class?: JadeletAttribute[]
  style?: JadeletAttribute[]
  [Key: string]: JadeletAttribute
};

type JadeletASTNode = [string, JadeletAttributes, JadeletAST[] ]
type JadeletAST = JadeletASTNode | JadeletAttribute;

declare const Jadelet:JadeletAPI;
declare const assert:any;

declare type isString = <T extends unknown>(x: string | T) => x is string;
declare type isObject = <T extends unknown>(x: Object | T) => x is Object;
declare type last = <T extends unknown[]>(array:T) => T[number];

interface Element extends HTMLElement, Node {
  checked: boolean
  value: string
  onchange: Function
  oninput: Function
  style: any
};

declare const Observable = (x:any) => (x:any) => any;
