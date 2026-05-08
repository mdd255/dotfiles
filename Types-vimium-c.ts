export interface GeneratedType {
    name:               string;
    "@time":            string;
    time:               number;
    environment:        Environment;
    exclusionRules:     any[];
    keyLayout:          number;
    keyMappings:        string[];
    linkHintCharacters: string;
    searchEngines:      string[];
    vimSync:            boolean;
}

export interface Environment {
    extension: string;
    platform:  string;
    chromium:  number;
}

