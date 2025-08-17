// TypeScript declarations for SurfingKeys API

declare global {
  interface SurfingKeysAPI {
    Hints: {
      style(css: string, mode?: string): void;
    };
    Visual: {
      style(element: string, css: string): void;
    };
    map(key: string, target: string, domain?: string): void;
    unmap(key: string, domain?: string): void;
    unmapAllExcept(keys: string[], domain?: RegExp)
    addSearchAlias(alias: string, name: string, url: string, suggestion?: string): void;
    removeSearchAlias(alias: string): void;
  }

  interface SurfingKeysSettings {
    theme: string;
    [key: string]: any;
  }

  const api: SurfingKeysAPI;
  const settings: SurfingKeysSettings;
}

export {};
