"""
估值数据抓取脚本
从东方财富获取 A股/港股 基本面数据，从 Yahoo Finance 获取美股数据
输出 JSON 到 docs/valuation/ 目录供 GitHub Pages 托管
"""
import json
import os
import requests
from datetime import date

OUTPUT_DIR = "docs/valuation"
os.makedirs(OUTPUT_DIR, exist_ok=True)

TODAY = date.today().isoformat()

# 东方财富 A股估值数据接口
EASTMONEY_URL = "https://push2.eastmoney.com/api/qt/clist/get"


def fetch_eastmoney(market_id: int, market_code: str) -> list[dict]:
    """从东方财富获取估值数据"""
    params = {
        "pn": 1, "pz": 500, "po": 1,
        "np": 1, "fltt": 2, "invt": 2,
        "fs": f"m:{market_id}",
        "fields": "f2,f3,f9,f12,f14,f20,f23,f26,f37,f115",
        # f2=最新价 f3=涨跌幅 f9=PE f12=代码 f14=名称 f20=总市值 f23=PB f37=ROE f115=股息率
        "ut": "fa5fd1943c7b386f172d6893dbfba10b",
    }
    try:
        resp = requests.get(EASTMONEY_URL, params=params, timeout=30)
        data = resp.json().get("data", {}).get("diff", [])
    except Exception as e:
        print(f"Error fetching {market_code}: {e}")
        return []

    results = []
    for item in data:
        if not item.get("f12") or item.get("f9") == "-":
            continue
        pe = item.get("f9")
        pb = item.get("f23")
        roe = item.get("f37")
        div_yield = item.get("f115")
        market_cap = item.get("f20")

        results.append({
            "symbol": item["f12"],
            "market": market_code,
            "name": item.get("f14", ""),
            "pe": pe if isinstance(pe, (int, float)) else None,
            "pb": pb if isinstance(pb, (int, float)) else None,
            "roe": roe if isinstance(roe, (int, float)) else None,
            "dividendYield": div_yield if isinstance(div_yield, (int, float)) else None,
            "marketCap": round(market_cap / 1e8, 2) if isinstance(market_cap, (int, float)) else None,
            "pePercentile": None,  # 需要历史数据计算，后续迭代
            "pbPercentile": None,
            "updateDate": TODAY,
        })
    return results


def fetch_a_share() -> list[dict]:
    """获取沪深 A 股"""
    sh = fetch_eastmoney(1, "SH")
    sz = fetch_eastmoney(0, "SZ")
    return sh + sz


def fetch_hk_share() -> list[dict]:
    """获取港股"""
    return fetch_eastmoney(116, "HK")


def fetch_us_share() -> list[dict]:
    """获取美股（通过东方财富）"""
    return fetch_eastmoney(105, "US")


def save_json(data: list[dict], filename: str):
    path = os.path.join(OUTPUT_DIR, filename)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(data)} items to {path}")


if __name__ == "__main__":
    print("Fetching A-share data...")
    a_data = fetch_a_share()
    save_json(a_data, "a-share.json")

    print("Fetching HK-share data...")
    hk_data = fetch_hk_share()
    save_json(hk_data, "hk-share.json")

    print("Fetching US-share data...")
    us_data = fetch_us_share()
    save_json(us_data, "us-share.json")

    print("Done!")
