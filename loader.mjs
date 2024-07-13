import { pathToFileURL } from 'url';
import "./register.js"

const baseURL = pathToFileURL(process.cwd() + '/').href;
const extensionsRegex = /\.jadelet$/;

export async function resolve(specifier, context, defaultResolve) {
  const { parentURL = baseURL } = context;

  if (extensionsRegex.test(specifier)) {
    return {
      url: new URL(specifier, parentURL).href
    };
  }

  // Let Node.js handle all other specifiers.
  return defaultResolve(specifier, context, defaultResolve);
}

export async function load(url, context, defaultLoad) {
  if (extensionsRegex.test(url)) {
    return { format: "commonjs" };
  }

  // Let Node.js handle all other URLs.
  return defaultLoad(url, context, defaultLoad);
}
