#!/usr/bin/env python3
"""Build clean CSVs + ipeds_practice.sqlite from downloaded IPEDS raw files."""

from __future__ import annotations

from pathlib import Path

import pandas as pd
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
CLEAN = ROOT / "data" / "clean"
DB = ROOT / "ipeds_practice.sqlite"

CONTROL_MAP = {1: "public", 2: "private_nonprofit", 3: "private_forprofit"}
LEVEL_MAP = {1: "4-year", 2: "2-year", 3: "less-than-2-year"}


def read_csv(path: Path, **kwargs) -> pd.DataFrame:
    for enc in ("utf-8-sig", "latin-1", "cp1252"):
        try:
            return pd.read_csv(path, encoding=enc, low_memory=False, **kwargs)
        except UnicodeDecodeError:
            continue
    raise RuntimeError(f"Could not decode {path}")


def first_existing(folder: Path, names: list[str]) -> Path:
    for name in names:
        path = folder / name
        if path.exists():
            return path
    raise FileNotFoundError(f"None of {names} in {folder}")


def load_hd(year: int, folder: str, candidates: list[str]) -> pd.DataFrame:
    df = read_csv(first_existing(RAW / folder, candidates))
    df.columns = [c.replace("\ufeff", "") for c in df.columns]
    return pd.DataFrame(
        {
            "unitid": df["UNITID"].astype(int),
            "inst_name": df["INSTNM"].astype(str),
            "state_abbr": df["STABBR"].astype(str),
            "control": df["CONTROL"].map(CONTROL_MAP),
            "level": df["ICLEVEL"].map(LEVEL_MAP),
            "city": df["CITY"].astype(str),
            "directory_year": year,
        }
    )


def load_enrollment(year: int, folder: str, candidates: list[str]) -> pd.DataFrame:
    # EFALEVEL 22 = full-time undergraduate; 42 = part-time undergraduate; 2 = UG total; 1 = all
    df = read_csv(
        first_existing(RAW / folder, candidates),
        usecols=["UNITID", "EFALEVEL", "EFTOTLT"],
    )
    df.columns = [c.replace("\ufeff", "") for c in df.columns]
    ft = df.loc[df["EFALEVEL"] == 22, ["UNITID", "EFTOTLT"]].rename(
        columns={"UNITID": "unitid", "EFTOTLT": "ft_ug"}
    )
    pt = df.loc[df["EFALEVEL"] == 42, ["UNITID", "EFTOTLT"]].rename(
        columns={"UNITID": "unitid", "EFTOTLT": "pt_ug"}
    )
    tot = df.loc[df["EFALEVEL"] == 2, ["UNITID", "EFTOTLT"]].rename(
        columns={"UNITID": "unitid", "EFTOTLT": "ug_total"}
    )
    all_tot = df.loc[df["EFALEVEL"] == 1, ["UNITID", "EFTOTLT"]].rename(
        columns={"UNITID": "unitid", "EFTOTLT": "all_students"}
    )
    out = (
        ft.merge(pt, on="unitid", how="outer")
        .merge(tot, on="unitid", how="outer")
        .merge(all_tot, on="unitid", how="outer")
    )
    out["year"] = year
    out["ft_ug"] = out["ft_ug"].fillna(0).astype(int)
    out["pt_ug"] = out["pt_ug"].fillna(0).astype(int)
    out["ug_total"] = out["ug_total"].fillna(out["ft_ug"] + out["pt_ug"]).astype(int)
    out["grad_enroll"] = (
        out["all_students"].fillna(0).astype(float) - out["ug_total"]
    ).clip(lower=0).astype(int)
    return out[["unitid", "year", "ft_ug", "pt_ug", "ug_total", "grad_enroll"]]


def load_completions(year: int, folder: str, candidates: list[str]) -> pd.DataFrame:
    df = read_csv(
        first_existing(RAW / folder, candidates),
        usecols=["UNITID", "AWLEVEL", "CTOTALT"],
    )
    df.columns = [c.replace("\ufeff", "") for c in df.columns]
    g = df.groupby(["UNITID", "AWLEVEL"], as_index=False)["CTOTALT"].sum()
    g = g.rename(
        columns={"UNITID": "unitid", "AWLEVEL": "award_level", "CTOTALT": "count"}
    )
    g["year"] = year
    g["count"] = g["count"].fillna(0).astype(int)
    return g[["unitid", "year", "award_level", "count"]]


def main() -> None:
    CLEAN.mkdir(parents=True, exist_ok=True)

    institutions = (
        pd.concat(
            [
                load_hd(2022, "HD2022", ["hd2022.csv", "HD2022.csv"]),
                load_hd(2023, "HD2023", ["HD2023.csv", "hd2023.csv"]),
            ],
            ignore_index=True,
        )
        .sort_values(["unitid", "directory_year"])
        .drop_duplicates("unitid", keep="last")
        .drop(columns=["directory_year"])
        .reset_index(drop=True)
    )

    enr = pd.concat(
        [
            load_enrollment(
                2022, "EF2022A", ["ef2022a_rv.csv", "ef2022a.csv", "EF2022A.csv"]
            ),
            load_enrollment(2023, "EF2023A", ["ef2023a.csv", "EF2023A.csv"]),
        ],
        ignore_index=True,
    )
    # Seed duplicates so Prompt 3 (ROW_NUMBER dedupe) has work to do
    dup_seed = enr.sample(n=25, random_state=42).copy()
    dup_seed["ft_ug"] = (dup_seed["ft_ug"] * 0.9).astype(int)
    enrollment = pd.concat([enr, dup_seed], ignore_index=True)

    completions = pd.concat(
        [
            load_completions(
                2022, "C2022_A", ["c2022_a_rv.csv", "c2022_a.csv", "C2022_A.csv"]
            ),
            load_completions(
                2023, "C2023_A", ["C2023_a_RV.csv", "C2023_a.csv", "c2023_a.csv"]
            ),
        ],
        ignore_index=True,
    )

    institutions.to_csv(CLEAN / "institutions.csv", index=False)
    enrollment.to_csv(CLEAN / "enrollment.csv", index=False)
    completions.to_csv(CLEAN / "completions.csv", index=False)

    inst_nynj = institutions[institutions["state_abbr"].isin(["NY", "NJ"])].copy()
    enr_nynj = enrollment[enrollment["unitid"].isin(inst_nynj["unitid"])].copy()
    comp_nynj = completions[completions["unitid"].isin(inst_nynj["unitid"])].copy()
    inst_nynj.to_csv(CLEAN / "institutions_nynj.csv", index=False)
    enr_nynj.to_csv(CLEAN / "enrollment_nynj.csv", index=False)
    comp_nynj.to_csv(CLEAN / "completions_nynj.csv", index=False)

    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    institutions.to_sql("institutions", con, index=False)
    enrollment.to_sql("enrollment", con, index=False)
    completions.to_sql("completions", con, index=False)
    con.executescript(
        """
        CREATE INDEX idx_inst_state ON institutions(state_abbr);
        CREATE INDEX idx_enr_unit_year ON enrollment(unitid, year);
        CREATE INDEX idx_comp_unit_year ON completions(unitid, year);
        """
    )
    con.close()

    print(f"institutions={len(institutions)} enrollment={len(enrollment)} completions={len(completions)}")
    print(f"nynj_institutions={len(inst_nynj)}")
    print(f"wrote {DB}")
    print(f"wrote {CLEAN}")


if __name__ == "__main__":
    main()
