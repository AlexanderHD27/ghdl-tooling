import { TaskInterface, TaskStatus } from "./src/cli.ts";
import { configuration, loadConfig, resolveFiles } from "./src/configuration.ts";

let config: configuration;

const steps = [
    {
        "name": "Load Config",
        "fn": async (task: TaskInterface) => {
            config = await loadConfig("example/config.yaml");
            return true;
        }
    },
    {
        "name": "Resolve Files",
        // deno-lint-ignore require-await
        "fn": async (task: TaskInterface) => {
            const missingFiles = resolveFiles(config);
            if(missingFiles.size > 0) {
                console.error("Missing files or libs:");
                missingFiles.forEach(f => console.error(`\t- ${f}`));
                return false;
            } else {
                return true;
            }
        }
    }
];

// Loading & Validating Config

import { sleep } from "https://deno.land/x/sleep/mod.ts"

let currentTask: TaskInterface | undefined;

Deno.addSignalListener("SIGINT", () => {
    if(currentTask !== undefined) {
        currentTask.end(TaskStatus.INTERRUPTION);
    }

    Deno.exit(-1);
})

let i = 0;
for (const s of steps) {
    const task = new TaskInterface(s.name, i, steps.length);
    i++;
    
    currentTask = task;
    const res: boolean = await s.fn(task);
    currentTask = undefined;
    
    if(!res) {
        task.end(TaskStatus.FAILED);
        Deno.exit(-1);
    } else {
        task.end(TaskStatus.SUCCESS);
    }
}
