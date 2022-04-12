declare module "jadelet" {
  type isString = <T extends unknown>(x: string | T) => x is string;
  type isObject = <T extends unknown>(x: Object | T) => x is Object;
  type last = <T extends unknown[]>(array: T) => T[number];

  interface Element {
    checked: boolean
    value: string
    onchange: Function
    oninput: Function
    style: any
  }

  export interface JadeletParser {
    parse(string): JadeletASTNode;
  }

  export interface JadeletAPI {
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
    exec(ast: JadeletASTNode | string): (context?: Context) => Element;
    define(definitions: any): any;
  }

  type makeTemplate = JadeletAPI["exec"]

  interface Context {
    [Key: string]: any
  }

  interface Binding {
    bind: string
  }

  type JadeletAttribute = string | { bind: string };

  type JadeletAttributes = {
    [Key: string]: JadeletAttribute
  } & {
    id?: JadeletAttribute[],
    class?: JadeletAttribute[],
    style?: JadeletAttribute[],
  }

  type JadeletASTNode = [string, JadeletAttributes, JadeletAST[]]
  type JadeletAST = JadeletASTNode | JadeletAttribute;

  type Observable = (x: any) => (x: any) => any
}
