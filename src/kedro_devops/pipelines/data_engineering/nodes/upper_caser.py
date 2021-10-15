import pandas as pd


def upper_caser(data: pd.DataFrame) -> pd.DataFrame:
    """
    Transforms a dataframe string data to upper case.

    Args:
        data (pd.DataFrame): Raw data to be transformed

    Returns:
        pd.DataFrame: A upper case string dataframe
    """
    return data.applymap(lambda x: x.upper())
