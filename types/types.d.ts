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

/*
  TODO: Can bindObservable do this magic?
  <T extends string>(
    element: JadeletElement,
    value: JadeletAttribute | Function,
    context: Context,
    update: (v: T) => void
  ): void
  <S extends string, T extends Binding<S>, C extends Context>(
    element: JadeletElement,
    value: T,
    context: C,
    update: (v: C[S]) => void
  ): void
*/

export interface bindObservable {

  (
    element: Element,
    value: JadeletAttribute | Function,
    context: Context,
    update: (value: any) => void
  ): void
}

export type exec = (ast: JadeletASTNode | string) => (context?: Context) => JadeletElement;

export interface Context {
  [Key: string]: any
}

export interface Binding<T extends string> {
  bind: T
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
