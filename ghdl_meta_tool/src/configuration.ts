import {red} from "https://deno.land/std@0.123.0/fmt/colors.ts"
import { join,  } from "https://deno.land/std@0.224.0/path/mod.ts";
import { existsSync } from "https://deno.land/std/fs/mod.ts";
import { parse } from "jsr:@std/yaml";
import { Schema, validate } from "https://deno.land/x/jtd@v0.1.0/mod.ts";

import * as configSchema from "../config_schema.json" with { type: "json" };


export interface configurationTask {
    top: string
    arch: string
    dep: string[]
    stop_time: string
}

export interface configuration {
    libs:  { [key: string]: string[] };
    tasks: { [key: string]: configurationTask }
    std: string;
    basedir: string;
}

export async function loadConfig(f: string): Promise<configuration> {
    const decoder = new TextDecoder("utf-8");
    const docRaw = parse(decoder.decode(await Deno.readFile(f)));

    const errors = validate(configSchema.default as Schema, docRaw);
    
    
    if(errors.length > 0) {
        console.error(red("Syntax Error in Config"));

        errors.forEach((e) => {
            console.error(`\t- ${e.instancePath} (schema: ${e.schemaPath})`)
        });

        Deno.exit(-1);
    }

    const doc = docRaw as configuration;

    if(!existsSync(doc.basedir)) {
        console.error(`Basedir '${doc.basedir}' does not exist!`);
        Deno.exit(-1);
    }

    doc.basedir = await Deno.realPath(doc.basedir);
    return doc;
}

export function resolveFiles(conf: configuration): Set<string> {
    function resolveLib(conf: configuration, deps: string[]): [string[], Set<string>] {
        let missingFiles: Set<string> = new Set();
        
        let res: string[] = [];
        
        deps.forEach(d => {
            if(d.includes(".vhdl")) {
                // File
                const filepath = join(conf.basedir, d);
                if(!existsSync(filepath))
                    missingFiles.add(filepath);
                else
                    res.push(filepath);
            } else {
                // Library
                const lib = conf.libs[d];
                if(lib === undefined) {
                    missingFiles.add(d);
                } else {
                    const [resFiles, resMissingFiles] = resolveLib(conf, lib);
                    res = res.concat(resFiles);
                    missingFiles = new Set([...missingFiles, ...resMissingFiles]);
                }
            }
        })
        
        return [res, missingFiles];
    }

    let missingFiles: Set<string> = new Set();

    for(const taskName in conf.tasks) {
        const task = conf.tasks[taskName];
        const [files, resMissingFiles] = resolveLib(conf, task.dep);

        missingFiles = new Set([...missingFiles, ...resMissingFiles]);
        task.dep = files;
    }
    
    return missingFiles;
}
