#!/usr/bin/env python3
#
# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Unified OpenSSL symbol tooling for stdx.

Subcommands:
1. manifest   Generate required OpenSSL symbol manifest.
2. check      Validate linked artifact against required symbol manifest.
3. force-link Generate linker inputs (GNU ld / Apple ld64) from symbol manifest.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DEFINE_FUNCTION_INC_REL = Path("src/stdx/dynamicLoader/defineFunction.inc")
DEFAULT_OPENSSL_SYMBOLS_C_REL = Path("src/stdx/dynamicLoader/opensslSymbols.c")
DEFAULT_REQUIRED_SYMBOLS_REL = Path("build/generated/openssl_symbols.required.txt")
DEFAULT_SCAN_EXTENSIONS = {".c", ".h", ".cj"}

STYLE_GNU_LD_SCRIPT = "gnu-ld-script"
STYLE_GNU_DRIVER_ARGS = "gnu-driver-args"
STYLE_APPLE_DRIVER_ARGS = "apple-driver-args"

# manifest-related patterns
DEFINE_SYMBOL_RE = re.compile(r"DEFINEFUNCTION(?:CB)?\d+\s*\(\s*([A-Za-z_]\w*)\s*,", re.MULTILINE)
WEAK_SYMBOL_RE = re.compile(r"CANGJIE_PRAGMA_WEAK\s*\(\s*([A-Za-z_]\w*)\s*\)", re.MULTILINE)
FUNC_HEADER_RE = re.compile(
    r"^[^\n;{}]*\b(DYN_[A-Za-z0-9_]+|LoadDynFunc[A-Za-z0-9_]+|LoadFuncFor[A-Za-z0-9_]+)\s*\([^;{}]*\)\s*\{",
    re.MULTILINE,
)
FIND_FUNCTION_RE = re.compile(r"FINDFUNCTION\s*\(\s*[^,]+,\s*([A-Za-z_]\w*)\s*,")
FIND_FUNCTION_I_RE = re.compile(r"FINDFUNCTIONI\s*\(\s*[^,]+,\s*[^,]+,\s*([A-Za-z_]\w*)\s*,")
API_TOKEN_RE = re.compile(r"\b(DYN_[A-Za-z0-9_]+|LoadDynFunc[A-Za-z0-9_]+|LoadFuncFor[A-Za-z0-9_]+)\b")
DEP_CALL_RE = re.compile(r"\b(DYN_[A-Za-z0-9_]+)\s*\(")

# These are loader symbols, not OpenSSL APIs.
DEFAULT_WEAK_EXCLUDES = {"dlopen", "dlsym", "dlclose"}

# check-related pattern
DEFINED_SYMBOL_RE = re.compile(r"^\s*(?:[0-9A-Fa-f]+)?\s+([A-Za-z])\s+([^\s]+)\s*$")


class ApiBinding:
    def __init__(self) -> None:
        self.symbols: set[str] = set()
        self.deps: set[str] = set()


def _resolve_under_root(path: Path, repo_root: Path) -> Path:
    if path.is_absolute():
        return path
    return repo_root / path


def _load_symbol_lines(path: Path) -> set[str]:
    symbols: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        symbols.add(line)
    return symbols


def _write_symbol_lines(path: Path, symbols: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join(f"{symbol}\n" for symbol in symbols), encoding="utf-8")


def _ensure_binding(bindings: dict[str, ApiBinding], api_name: str) -> ApiBinding:
    binding = bindings.get(api_name)
    if binding is None:
        binding = ApiBinding()
        bindings[api_name] = binding
    return binding


def _extract_function_body(text: str, body_start: int) -> str:
    depth = 1
    idx = body_start
    while idx < len(text) and depth > 0:
        ch = text[idx]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        idx += 1
    return text[body_start : idx - 1]


def _load_all_symbols(define_file: Path, symbols_c: Path, weak_excludes: set[str]) -> set[str]:
    define_text = define_file.read_text(encoding="utf-8")
    symbols_c_text = symbols_c.read_text(encoding="utf-8")

    from_define = set(DEFINE_SYMBOL_RE.findall(define_text))
    from_weak = _extract_weak_symbols(symbols_c_text)
    from_weak.difference_update(weak_excludes)
    return from_define.union(from_weak)


def _extract_weak_symbols(symbols_c_text: str) -> set[str]:
    # Strip comments first to avoid picking examples like CANGJIE_PRAGMA_WEAK(sym) in docs/comments.
    text = re.sub(r"/\*.*?\*/", "", symbols_c_text, flags=re.DOTALL)
    text = re.sub(r"//.*", "", text)

    symbols: set[str] = set()
    for line in text.splitlines():
        # Skip preprocessor directives so macro definitions like CANGJIE_PRAGMA_WEAK(name)
        # are not treated as real symbol uses.
        if line.lstrip().startswith("#"):
            continue
        symbols.update(WEAK_SYMBOL_RE.findall(line))
    return symbols


def _build_api_bindings(define_file: Path, symbols_c: Path) -> dict[str, ApiBinding]:
    bindings: dict[str, ApiBinding] = {}
    define_text = define_file.read_text(encoding="utf-8")
    symbols_c_text = symbols_c.read_text(encoding="utf-8")

    for symbol in DEFINE_SYMBOL_RE.findall(define_text):
        _ensure_binding(bindings, f"DYN_{symbol}").symbols.add(symbol)

    for match in FUNC_HEADER_RE.finditer(symbols_c_text):
        api_name = match.group(1)
        body = _extract_function_body(symbols_c_text, match.end())
        binding = _ensure_binding(bindings, api_name)

        binding.symbols.update(FIND_FUNCTION_RE.findall(body))
        binding.symbols.update(FIND_FUNCTION_I_RE.findall(body))
        for dep in DEP_CALL_RE.findall(body):
            if dep != api_name:
                binding.deps.add(dep)

    return bindings


def _iter_scan_files(scan_roots: list[Path], scan_extensions: set[str]) -> list[Path]:
    files: list[Path] = []
    for root in scan_roots:
        if root.is_file():
            if root.suffix.lower() in scan_extensions:
                files.append(root)
            continue
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix.lower() in scan_extensions:
                files.append(path)
    return files


def _collect_api_tokens(scan_roots: list[Path], scan_extensions: set[str]) -> set[str]:
    tokens: set[str] = set()
    for file_path in _iter_scan_files(scan_roots, scan_extensions):
        text = file_path.read_text(encoding="utf-8", errors="ignore")
        tokens.update(API_TOKEN_RE.findall(text))
    return tokens


def _resolve_symbols_for_apis(
    used_apis: set[str], bindings: dict[str, ApiBinding], known_symbols: set[str]
) -> tuple[set[str], set[str]]:
    cache: dict[str, set[str]] = {}
    visiting: set[str] = set()
    unmapped_apis: set[str] = set()

    def resolve(api_name: str) -> set[str]:
        if api_name in cache:
            return cache[api_name]
        if api_name in visiting:
            return set()

        visiting.add(api_name)
        out: set[str] = set()
        binding = bindings.get(api_name)
        if binding is not None:
            out.update(symbol for symbol in binding.symbols if symbol in known_symbols)
            for dep in binding.deps:
                out.update(resolve(dep))
        else:
            if api_name.startswith("DYN_"):
                candidate = api_name[4:]
                if candidate in known_symbols:
                    out.add(candidate)
                elif not (api_name.startswith("DYN_CJ") or api_name.startswith("DYN_Cj")):
                    unmapped_apis.add(api_name)
            elif api_name.startswith("LoadDynFunc") or api_name.startswith("LoadFuncFor"):
                unmapped_apis.add(api_name)

        visiting.remove(api_name)
        cache[api_name] = out
        return out

    all_symbols: set[str] = set()
    for api_name in used_apis:
        all_symbols.update(resolve(api_name))
    return all_symbols, unmapped_apis


def _collect_manifest_symbols_from_sources(
    define_file: Path,
    symbols_c: Path,
    profile_file: Path | None,
    scan_roots: list[Path],
    scan_ext: list[str],
    weak_exclude: list[str],
) -> tuple[list[str], set[str]]:
    weak_excludes = set(DEFAULT_WEAK_EXCLUDES)
    weak_excludes.update(weak_exclude)

    known_symbols = _load_all_symbols(define_file, symbols_c, weak_excludes)
    unmapped_apis: set[str] = set()

    if scan_roots:
        bindings = _build_api_bindings(define_file, symbols_c)
        scan_extensions = (
            {ext if ext.startswith(".") else f".{ext}" for ext in scan_ext}
            if scan_ext
            else set(DEFAULT_SCAN_EXTENSIONS)
        )
        used_apis = _collect_api_tokens(scan_roots, {ext.lower() for ext in scan_extensions})
        symbols, unmapped_apis = _resolve_symbols_for_apis(used_apis, bindings, known_symbols)
    else:
        symbols = known_symbols

    if profile_file is not None:
        allow = _load_symbol_lines(profile_file)
        symbols = {name for name in symbols if name in allow}

    return sorted(symbols), unmapped_apis


def _cmd_manifest(args: argparse.Namespace) -> int:
    repo_root = args.repo_root.resolve()
    define_file = _resolve_under_root(args.define_function_inc, repo_root)
    symbols_c = _resolve_under_root(args.openssl_symbols_c, repo_root)
    output = _resolve_under_root(args.output, repo_root)
    profile_file = _resolve_under_root(args.profile_file, repo_root) if args.profile_file else None
    unmapped_output = _resolve_under_root(args.unmapped_output, repo_root) if args.unmapped_output else None
    scan_roots = [_resolve_under_root(path, repo_root) for path in args.scan_root]

    symbol_list, unmapped_apis = _collect_manifest_symbols_from_sources(
        define_file=define_file,
        symbols_c=symbols_c,
        profile_file=profile_file,
        scan_roots=scan_roots,
        scan_ext=args.scan_ext,
        weak_exclude=args.weak_exclude,
    )
    _write_symbol_lines(output, symbol_list)

    if unmapped_output is not None:
        _write_symbol_lines(unmapped_output, sorted(unmapped_apis))

    print(f"generated {len(symbol_list)} symbols -> {output}", file=sys.stderr)
    if unmapped_apis:
        print(f"warning: found {len(unmapped_apis)} unmapped API tokens", file=sys.stderr)
        if unmapped_output is None:
            sample = ", ".join(sorted(unmapped_apis)[:20])
            if sample:
                print(f"sample unmapped APIs: {sample}", file=sys.stderr)

    if args.fail_on_unmapped and unmapped_apis:
        return 2
    return 0


def _nm_candidates(explicit_nm: str | None) -> list[str]:
    out: list[str] = []
    if explicit_nm:
        out.append(explicit_nm)
    env_nm = os.environ.get("NM", "")
    if env_nm:
        out.append(env_nm)
    out.extend(["llvm-nm", "nm", "gcc-nm"])

    seen: set[str] = set()
    deduped: list[str] = []
    for cand in out:
        if cand in seen:
            continue
        seen.add(cand)
        deduped.append(cand)
    return deduped


def _run_nm(nm_tool: str, artifact: Path) -> subprocess.CompletedProcess[str]:
    variants = [
        [nm_tool, "--defined-only", str(artifact)],
        [nm_tool, "-g", "--defined-only", str(artifact)],
        [nm_tool, "-gU", str(artifact)],
    ]
    last_err: subprocess.CompletedProcess[str] | None = None
    for cmd in variants:
        proc = subprocess.run(
            cmd,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if proc.returncode == 0:
            return proc
        last_err = proc
    assert last_err is not None
    return last_err


def _normalize_symbol(name: str) -> set[str]:
    base = name.split("@@", 1)[0].split("@", 1)[0]
    out = {base}
    if base.startswith("_") and len(base) > 1:
        out.add(base[1:])
    return out


def _parse_defined_symbols(output: str) -> set[str]:
    defined: set[str] = set()
    for raw in output.splitlines():
        line = raw.strip()
        if not line or line.endswith(":"):
            continue
        match = DEFINED_SYMBOL_RE.match(line)
        if not match:
            continue
        sym_type = match.group(1)
        sym_name = match.group(2)
        if sym_type.upper() == "U":
            continue
        defined.update(_normalize_symbol(sym_name))
    return defined


def _cmd_check(args: argparse.Namespace) -> int:
    repo_root = args.repo_root.resolve()
    required_symbols = _resolve_under_root(args.required_symbols, repo_root)
    artifact = _resolve_under_root(args.artifact, repo_root)

    required = _load_symbol_lines(required_symbols)
    if not required:
        print(f"error: empty required symbol list: {required_symbols}", file=sys.stderr)
        return 2

    nm_errs: list[str] = []
    defined: set[str] = set()
    used_nm = None
    for nm_tool in _nm_candidates(args.nm):
        resolved = shutil.which(nm_tool) if os.path.sep not in nm_tool else nm_tool
        if not resolved:
            continue
        proc = _run_nm(resolved, artifact)
        if proc.returncode != 0:
            nm_errs.append(f"{resolved}: {proc.stderr.strip()}")
            continue
        defined = _parse_defined_symbols(proc.stdout)
        used_nm = resolved
        break

    if used_nm is None:
        print("error: failed to run nm tool. attempts:", file=sys.stderr)
        for err in nm_errs:
            print(f"  {err}", file=sys.stderr)
        return 3

    missing = sorted(required.difference(defined))
    if missing:
        print(
            f"error: {len(missing)} required OpenSSL symbols are missing in {artifact}",
            file=sys.stderr,
        )
        for name in missing:
            print(name, file=sys.stderr)
        return 4

    print(
        f"symbol check passed: {len(required)} symbols found in {artifact} (nm={used_nm})",
        file=sys.stderr,
    )
    return 0


def _load_symbol_list(path: Path) -> list[str]:
    return sorted(_load_symbol_lines(path))


def _guess_default_force_link_output(style: str) -> Path:
    if style == STYLE_GNU_LD_SCRIPT:
        return Path("build/generated/openssl_force_link.gnu.ld")
    if style == STYLE_GNU_DRIVER_ARGS:
        return Path("build/generated/openssl_force_link.gnu.args")
    return Path("build/generated/openssl_force_link.apple.args")


def _emit_gnu_ld_script(symbols: list[str]) -> str:
    lines = [
        "/* Auto-generated by tools/openssl/openssl_symbols_tool.py */",
        "/* Force undefined references for OpenSSL symbols to pull required objects from static archives. */",
        "EXTERN(",
    ]
    lines.extend(f"    {name}" for name in symbols)
    lines.append(");")
    lines.append("")
    return "\n".join(lines)


def _emit_gnu_driver_args(symbols: list[str]) -> str:
    return "".join(f"-Wl,-u,{name}\n" for name in symbols)


def _emit_apple_driver_args(symbols: list[str]) -> str:
    return "".join(f"-Wl,-u,_{name}\n" for name in symbols)


def _cmd_force_link(args: argparse.Namespace) -> int:
    repo_root = args.repo_root.resolve()
    output = args.output if args.output is not None else _guess_default_force_link_output(args.style)
    output = _resolve_under_root(output, repo_root)
    unmapped_apis: set[str] = set()

    if args.required_symbols is not None:
        required_symbols = _resolve_under_root(args.required_symbols, repo_root)
        symbols = _load_symbol_list(required_symbols)
        if not symbols:
            print(f"error: no symbols found in {required_symbols}", file=sys.stderr)
            return 2
    else:
        define_file = _resolve_under_root(args.define_function_inc, repo_root)
        symbols_c = _resolve_under_root(args.openssl_symbols_c, repo_root)
        profile_file = _resolve_under_root(args.profile_file, repo_root) if args.profile_file else None
        unmapped_output = _resolve_under_root(args.unmapped_output, repo_root) if args.unmapped_output else None
        scan_roots = [_resolve_under_root(path, repo_root) for path in args.scan_root]
        symbols, unmapped_apis = _collect_manifest_symbols_from_sources(
            define_file=define_file,
            symbols_c=symbols_c,
            profile_file=profile_file,
            scan_roots=scan_roots,
            scan_ext=args.scan_ext,
            weak_exclude=args.weak_exclude,
        )
        if not symbols:
            print("error: no symbols resolved from source inputs", file=sys.stderr)
            return 2
        if unmapped_output is not None:
            _write_symbol_lines(unmapped_output, sorted(unmapped_apis))
        if args.fail_on_unmapped and unmapped_apis:
            print(f"error: found {len(unmapped_apis)} unmapped API tokens", file=sys.stderr)
            return 2

    if args.style == STYLE_GNU_LD_SCRIPT:
        content = _emit_gnu_ld_script(symbols)
    elif args.style == STYLE_GNU_DRIVER_ARGS:
        content = _emit_gnu_driver_args(symbols)
    else:
        content = _emit_apple_driver_args(symbols)

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")
    print(f"generated {len(symbols)} entries -> {output}", file=sys.stderr)
    if unmapped_apis and args.required_symbols is None and args.unmapped_output is None:
        sample = ", ".join(sorted(unmapped_apis)[:20])
        print(f"warning: found {len(unmapped_apis)} unmapped API tokens", file=sys.stderr)
        if sample:
            print(f"sample unmapped APIs: {sample}", file=sys.stderr)
    return 0


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Unified OpenSSL symbol tooling for stdx.")
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    manifest = subparsers.add_parser("manifest", help="Generate required symbol manifest.")
    manifest.set_defaults(run=_cmd_manifest)
    manifest.add_argument("--repo-root", type=Path, default=DEFAULT_REPO_ROOT)
    manifest.add_argument("--define-function-inc", type=Path, default=DEFAULT_DEFINE_FUNCTION_INC_REL)
    manifest.add_argument("--openssl-symbols-c", type=Path, default=DEFAULT_OPENSSL_SYMBOLS_C_REL)
    manifest.add_argument("--profile-file", type=Path, default=None)
    manifest.add_argument("--output", type=Path, default=DEFAULT_REQUIRED_SYMBOLS_REL)
    manifest.add_argument("--weak-exclude", action="append", default=[])
    manifest.add_argument("--scan-root", type=Path, action="append", default=[])
    manifest.add_argument("--scan-ext", action="append", default=[])
    manifest.add_argument("--unmapped-output", type=Path, default=None)
    manifest.add_argument("--fail-on-unmapped", action="store_true")

    check = subparsers.add_parser("check", help="Validate linked artifact symbols.")
    check.set_defaults(run=_cmd_check)
    check.add_argument("--repo-root", type=Path, default=DEFAULT_REPO_ROOT)
    check.add_argument("--artifact", type=Path, required=True)
    check.add_argument("--required-symbols", type=Path, default=DEFAULT_REQUIRED_SYMBOLS_REL)
    check.add_argument("--nm", default=None)

    force_link = subparsers.add_parser("force-link", help="Generate force-link script/args.")
    force_link.set_defaults(run=_cmd_force_link)
    force_link.add_argument("--repo-root", type=Path, default=DEFAULT_REPO_ROOT)
    force_link.add_argument(
        "--required-symbols",
        type=Path,
        default=None,
        help=(
            "Path to symbol manifest. If omitted, symbols are derived directly from "
            "--define-function-inc/--openssl-symbols-c (+ optional scan/profile filters)."
        ),
    )
    force_link.add_argument(
        "--style",
        choices=[STYLE_GNU_LD_SCRIPT, STYLE_GNU_DRIVER_ARGS, STYLE_APPLE_DRIVER_ARGS],
        default=STYLE_GNU_LD_SCRIPT,
    )
    force_link.add_argument("--output", type=Path, default=None)
    force_link.add_argument("--define-function-inc", type=Path, default=DEFAULT_DEFINE_FUNCTION_INC_REL)
    force_link.add_argument("--openssl-symbols-c", type=Path, default=DEFAULT_OPENSSL_SYMBOLS_C_REL)
    force_link.add_argument("--profile-file", type=Path, default=None)
    force_link.add_argument("--weak-exclude", action="append", default=[])
    force_link.add_argument("--scan-root", type=Path, action="append", default=[])
    force_link.add_argument("--scan-ext", action="append", default=[])
    force_link.add_argument("--unmapped-output", type=Path, default=None)
    force_link.add_argument("--fail-on-unmapped", action="store_true")

    return parser


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()
    return int(args.run(args))


if __name__ == "__main__":
    raise SystemExit(main())
