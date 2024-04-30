import { configurationTask } from "./configuration.ts";

enum VHDL_STD {
    STD87  = "97",
    STD93  = "93",
    STD93c = "93c",
    STD00  = "00",
    STD02  = "02",
    STD08  = "08",
    STD19  = "19"
}

enum ANALYSIS_WARNINGS {
    LIBRARY_REPLACE = "-Wlibrary",
    DEFAULT_BENDING = "-Wdefault-binding",
    MISSING_BINDING = "-Wbinding",
    UNCONNECTED_PORT = "-Wport",
    RESERVED_KEYWORD = "-Wreserved",
    UNKNOWN_PRAGMA = "-Wpragma",
    NESTED_COMMENT = "-Wnested-comment",
    TOOL_DIRECTIVE = "-Wdirective",
    WIRED_PARENTHESES = "-Wparenthesis",
    VITAL_GENERIC_NAME = "-Wvital-generic",
    DELAYED_CHECKS = "-Wdelayed-checks",
    NOT_REQUIRED_ANALYZE_PACKAGE_BODY = "-Wbody",
    SPEC_NOT_APPLY = "-Wspecs",
    INCORRECT_UNIVERSAL = "-Wuniversal",
    MISMATCH_BOUNDS_SCALAR_PORT = "-Wport-bounds",
    RUNTIME_ERROR = "-Wruntime-error",
    POSTPONED_DELTA_CYCLE = "-Wdelta-cycle",
    MISSING_WAIT_STATEMENT = "-Wno-wait",
    SHARED_UNPROTECTED_VARIABLE ="-Wshared",
    HIDE_HIDES_HIDE = "-Whide",
    SUBPROGRAM_UNUSED = "-Wunused",
    SIGNAL_NEVER_ASSIGNED = "-Wnowrite",
    PURE_FUNCTION_VIOLATION = "-Wpure",
    STATIC_ASSERTS = "-Wanalyze-assert",
    INCORRECT_USE_OF_ATTRIBUTE = "-Wattribute",
    UNLESS_CODE = "-Wuseless",
    MISSING_PORT_ASSOCIATION = "-Wno-assoc",
    MISSING_STATIC = "-Wstatic",
}

interface ghdlWorkspace {
    std: VHDL_STD,
    stdPrefix: string,
    librariesPaths: string[]
}

export function ghdlCheckSyntax() {

}

export function ghdlAnalysis(task: configurationTask) {
    
}

export function ghdlElaboration() {

}

export function ghdlRun() {

}