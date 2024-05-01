import * as tty from "https://deno.land/x/tty/mod.ts";

export enum TaskStatus {
    SUCCESS, FAILED, INTERRUPTION, RUNNING
}

const COLOR_RESET = "\x1b[0m"
const COLOR_RED = "\x1b[0;31m"
const COLOR_YELLOW = "\x1b[1;33m"
const COLOR_GREEN = "\x1b[32m"
const COLOR_BLUE = "\x1b[1;30m"

const spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

const decoder = new TextDecoder();
const encoder = new TextEncoder();

function formatTimeDuration(t: number): string {
    const ms = Math.floor(t % 1000).toFixed(0).padStart(3, "0");
    const s = Math.floor((t/1000) % 60).toFixed(0);
    const min = Math.floor((t/1000*60) % 60).toFixed(0);
    const h = Math.floor(t/1000*60*60).toFixed(0);

    if(t > 1000 * 60 * 60) {
        return `${h}h ${min}min ${s}s`
    } else if(t > 1000 * 60) {
        return `${min}min ${s}s`
    } else if(t > 1000) {
        return `${s}s ${ms}ms`
    } else {
        return `${ms}ms`
    }
}

export class TaskInterface {
    name: string;
    numbering: string;
    startTime: number;

    errorCount: number;
    warningCount: number;
    updateInterval: number | undefined;

    statusTextRight: string;
    statusTextLeft: string;
    spinnerCounter: number;

    status: TaskStatus;

    constructor(name: string, n: number, total: number) {
        this.name = name;
        this.numbering = `${n+1}/${total}`;
        this.startTime = 0;

        this.errorCount = 0;
        this.warningCount = 0;

        this.statusTextRight = "";
        this.statusTextLeft = "";
        this.spinnerCounter = 0;
        this.status = TaskStatus.RUNNING;
    }

    async start() {
        
        tty.hideCursorSync();
        tty.clearLineSync();
        
        this.spinnerCounter = 0;
        //console.log("━ " + this.name + " " + "━".repeat(Deno.consoleSize().columns - 3 - this.name.length ))
        
        this.startTime = performance.now();
        this.updateStatusText();

        this.updateInterval = setInterval(() => {
            this.updateStatusText();
            this.drawTitleLine();
            this.spinnerCounter = (this.spinnerCounter + 1) % spinner.length;
        }, 100);
    }

    async end(status: TaskStatus) {


        clearInterval(this.updateInterval);

        this.status = status;
        this.updateStatusText();
        this.drawTitleLine();
        Deno.stdout.write(encoder.encode("\n"));
        tty.showCursorSync();
    }

    updateStatusText() {
        const stopTime = performance.now();
        let spinnerIcon = "";

        switch (this.status) {
            case TaskStatus.FAILED:
                spinnerIcon = COLOR_RED + "✘" + COLOR_RESET;
                break;

            case TaskStatus.SUCCESS:
                spinnerIcon = COLOR_GREEN + "✔" + COLOR_RESET;
                break;

            case TaskStatus.INTERRUPTION:
                spinnerIcon = COLOR_RED + "⏹" + COLOR_RESET;
                break;

            default:
                spinnerIcon = COLOR_YELLOW + spinner[this.spinnerCounter] + COLOR_RESET;
                this.spinnerCounter++;
                break;
        }

        this.statusTextLeft = `${spinnerIcon} [${this.numbering}] ${this.name}`;
        this.statusTextRight = `${formatTimeDuration(stopTime - this.startTime)}`;   
    }

    drawTitleLine() {
        Deno.stdout.writeSync(encoder.encode( this.statusTextLeft + " ".repeat(Deno.consoleSize().columns - (this.statusTextLeft.length + this.statusTextRight.length)) + this.statusTextRight  + "\r"));
    }


    write(color: string, ...data: any[]) {
        
        const content = data.map(d => String(d)).join(" ");
        const text = "\r\x1b[2K" + color + content + (color.length > 0 ? COLOR_RESET : "") + "\n";
        
        Deno.stdout.write(encoder.encode(text));
        this.drawTitleLine();
    }

    log(...data: any[]) {
        this.write("", ...data);
    }

    warning(...data: any[]) {
        this.write(COLOR_YELLOW, ...data);
        this.warningCount++;
    }

    error(...data: any[]) {
        this.write(COLOR_RED, ...data);
        this.errorCount++;
    }

    async info(...data: any[]) {
        this.write(COLOR_BLUE, ...data);
        this.errorCount++;
    }

    async getCurrentCursorPosition(): Promise<[number, number]> {
        const pos = new Uint8Array(6);

        Deno.stdin.setRaw(true);
        await tty.position();
        await Deno.stdin.read(pos);
        Deno.stdin.setRaw(false);
        const [r, c, ] = decoder.decode(pos.slice(2)).replace("R", "").split(";");
        return [Number.parseInt(r), Number.parseInt(c)];
    }

}