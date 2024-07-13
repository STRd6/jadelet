import { JadeletASTNode } from "../types/types"

declare const JadeletParser: {
  parse(source: string): JadeletASTNode;
}

export = JadeletParser
