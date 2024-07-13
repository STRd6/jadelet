import { register } from "node:module";
import { pathToFileURL } from "node:url";
register("@danielx/civet/esm", pathToFileURL("./"));
