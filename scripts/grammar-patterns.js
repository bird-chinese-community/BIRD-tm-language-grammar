const patternKeys = new Set(["match", "begin", "end", "while"]);

export const collectGrammarPatterns = (value, patterns = []) => {
  if (Array.isArray(value)) {
    for (const item of value) collectGrammarPatterns(item, patterns);
    return patterns;
  }

  if (!value || typeof value !== "object") return patterns;

  const name = typeof value.name === "string" ? value.name : "";
  for (const [key, item] of Object.entries(value)) {
    if (patternKeys.has(key) && typeof item === "string") {
      patterns.push({ key, name, source: item });
    } else {
      collectGrammarPatterns(item, patterns);
    }
  }

  return patterns;
};

export const compilePatterns = (patterns) =>
  patterns.flatMap((pattern) => {
    try {
      return [{ ...pattern, regex: new RegExp(pattern.source, "i") }];
    } catch {
      return [];
    }
  });

export const collectLiteralWords = (patterns) =>
  new Set(
    patterns.flatMap(
      ({ source }) =>
        source.replace(/\\[A-Za-z]/g, " ").match(/[A-Za-z_][A-Za-z0-9_-]*/g) ?? [],
    ),
  );

export const collectScopeNames = (value, names = new Set()) => {
  if (Array.isArray(value)) {
    for (const item of value) collectScopeNames(item, names);
    return names;
  }

  if (!value || typeof value !== "object") return names;

  if (typeof value.name === "string") names.add(value.name);
  for (const item of Object.values(value)) collectScopeNames(item, names);
  return names;
};

export const matchesFullPhrase = (patterns, phrase) =>
  patterns.some(({ regex }) => {
    const match = regex.exec(phrase);
    return match?.index === 0 && match[0].length === phrase.length;
  });

export const isSemanticPattern = ({ name, key }) =>
  key === "match" && /^(?:constant|keyword|storage|support)\./.test(name);
