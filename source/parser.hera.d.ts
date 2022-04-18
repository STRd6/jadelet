import { JadeletASTNode } from "../types/types"

interface JadeletParser {
  parse(source: string): JadeletASTNode;
}

export = JadeletParser
