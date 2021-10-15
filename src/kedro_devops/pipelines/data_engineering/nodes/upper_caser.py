import pandas as pd


def upper_caser(data: pd.DataFrame) -> pd.DataFrame:
    return data.applymap(lambda x: x.upper())
