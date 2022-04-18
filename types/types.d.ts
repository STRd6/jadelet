export type isString = <T extends unknown>(x: string | T) => x is string;
export type isObject = <T extends unknown>(x: Object | T) => x is Object;
export type last = <T extends unknown[]>(array: T) => T[number];

export interface JadeletElement extends HTMLElement {
  checked: boolean
  value: string
  style: any
}

export interface JadeletParser {
  parse(source: string): JadeletASTNode;
}

export type exec = (ast: JadeletASTNode | string) => (context?: Context) => JadeletElement;

export interface Context {
  [Key: string]: any
}

export interface Binding {
  bind: string
}

export type JadeletAttribute = string | { bind: string };

export type JadeletAttributes = {
  [Key: string]: JadeletAttribute | undefined
} & {
  id?: JadeletAttribute[],
  class?: JadeletAttribute[],
  style?: JadeletAttribute[],
}

type x = JadeletAttributes["id"]
type y = JadeletAttributes["checked"]

export type ArrayedAttributes = "id" | "class" | "style"

export type JadeletAttributeValue<T extends string> =
  T extends ArrayedAttributes
  ? JadeletAttribute[]
  : JadeletAttribute

export type JadeletASTNode = [string, JadeletAttributes, JadeletAST[]]
export type JadeletAST = JadeletASTNode | JadeletAttribute;
