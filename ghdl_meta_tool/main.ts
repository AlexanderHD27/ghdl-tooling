import * as tty from "https://deno.land/x/tty/mod.ts";
import { TerminalSpinner } from "https://deno.land/x/spinners/mod.ts";

import {red} from "https://deno.land/std@0.123.0/fmt/colors.ts"
import { configuration, loadConfig, resolveFiles } from "./src/configuration.ts";

let config: configuration;

const steps = [
    {
        "name": "Load Config",
        "fn": async () => {
            config = await loadConfig("example/config.yaml");
            return true;
        }
    },
    {
        "name": "Resolve Files",
        // deno-lint-ignore require-await
        "fn": async () => {
            const missingFiles = resolveFiles(config);
            if(missingFiles.size > 0) {
                console.error(red("Missing files or libs:"));
                missingFiles.forEach(f => console.error(red(`\t- ${f}`)));
                return false;
            } else {
                return true;
            }
        }
    }
];

// Loading & Validating Config

let i = 1;
for (const s of steps) {
    const text = `[${i}/${steps.length}] ${s.name}`;
    i++;
    console.log(text);

    const res: boolean = await s.fn();
    if(!res)
        Deno.exit(-1);
}

// Analysis

await tty.hideCursor();

await tty.clearLine();
console.log("Waiting...");
